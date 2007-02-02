From: jamal <hadi@cyberus.ca>
Subject: Re: [RFC][PATCH][XFRM][0/5] extension for XFRM databases
Date: Fri, 02 Feb 2007 08:35:51 -0500
Message-ID: <1170423351.4000.42.camel@localhost>
References: <20070201114339.E2BD.SHINTA@sfc.wide.ad.jp>
	 <1170336273.3915.12.camel@localhost>
	 <20070202132129.E2EA.SHINTA@sfc.wide.ad.jp>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Francis Dupont <Francis.Dupont@point6.net>,
	Masahide Nakamura <nakam@linux-ipv6.org>,
	usagi-core@linux-ipv6.org
To: Shinta Sugimoto <shinta@sfc.wide.ad.jp>
Return-path: <netdev-owner@vger.kernel.org>
Received: from an-out-0708.google.com ([209.85.132.251]:3244 "EHLO
	an-out-0708.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1161134AbXBBNfz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Feb 2007 08:35:55 -0500
Received: by an-out-0708.google.com with SMTP id b33so601535ana
        for <netdev@vger.kernel.org>; Fri, 02 Feb 2007 05:35:54 -0800 (PST)
In-Reply-To: <20070202132129.E2EA.SHINTA@sfc.wide.ad.jp>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello,

On Fri, 2007-02-02 at 20:25 +0900, Shinta Sugimoto wrote:

> In the design phase, we sorted out the requirements as below:
> 
> (1) Overhead of userland <-> kernel interaction message exchange
>     should be kept minimum.
> (2) There should not be too much requirement for user application
>     to leverage the feature (dynamic update of endpoint).  More
>     specifically, we don't want to expect the user application to
>     have detailed information of IPsec security association
>     (i.e. SPI).
> (3) There should not be negative impact on the existing software
>     which is based on PF_KEYv2 (RFC2367).
> 
> Firstly, if we use the existing messages for updating SPD and SAD,
> we simply need 2 pairs of request/response exchange between the
> userland and kernel for updating a single endpoint.  This is not
> ideal from the perspective of (1).

Ok, if i understand you correctly:
Instead of having from userland one message for updating SAD and another
for updating SPD, you have a single message which updates both?

> Secondly, we need to be careful about updating the endpoint address
> because it may invoke unexpected signaling (ACQUIRE) to the user
> application.  Imagine you update SPD and SAD sequentially while there
> is an outbound flow going on.  The kernel may end up with triggering
> the userland application by unexpected ACQUIRE message due to the
> absence of SAD entry.  In order to avoid this problem, we need a sort
> of atomic update of SPD and SAD entries.  XFRM_MSG_MIGRATE is designed
> and implemented in a way that unexpected ACQUIRE would never occur.
> 

Ok, this is sensible - it could be achieved with two multipart messages
in netlink; but a single message is better.

> Thirdly, we also need to pay attention to the PF_KEYv2 spec.
> XFRM_MSG_UPDSA is derived from SADB_UPDATE message in PF_KEYv2.
> According to the spec, the semantics of SADB_UPDATE is to add a new
> security association with the information provided by previous
> SADB_GETSPI message.  We think it's not a good idea to overload
> the semantics of SADB_UPDATE message because it may confuse legacy
> software from the perspective of (3).  Moreover, caller of
> SADB_UPDATE should specify SPI, source address, and destination
> address, which is a bit problematic from the perspective of (2).
> 


We really dont have this issue with xfrm side.
I think that PF_KEYv2 is just a dinosaur that needs to be extinct.
Continuing to bandaid around it is converting into a mammoth.
I found your first two explanation more reasonable, but not this one.

> From the above reasons, we decided to extend XFRM/PF_KEYv2 for
> dynamic update of the endpoint.  Please note that the mechanism is
> useful not only for Mobile IPv6 but also for Mobile VPN scenario.
> 

Can you explain what you mean by this last part? There are many ways to
achieve mobile VPN - is the end client aware?

> Does this make sense?

Yes, I think I see the logic behind your design. To be 100% convinced,
depends if your answer to the first question i asked is "yes".

cheers,
jamal


