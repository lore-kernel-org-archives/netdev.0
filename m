From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] - vxlan: gro not effective for intel 82599
Date: Fri, 26 Jun 2015 07:15:49 +0200
Message-ID: <1435295749.4110.51.camel@edumazet-glaptop2.roam.corp.google.com>
References: <5981772fe36e64f8fec5997a4c7aa08f@imap.linux.ibm.com>
	 <CALx6S36JQaPg9Otg4pv5ah16JGaEXzo1xDL4jXKBdziUTVvXmw@mail.gmail.com>
	 <0b2eff60824ac7b7d3a672da9be9bf99@imap.linux.ibm.com>
	 <CALx6S35o-KgViFy6dU5FXA=B2wCJFQjaGPxp22MMhUWP94ZS=A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Ramu Ramamurthy <sramamur@linux.vnet.ibm.com>,
	"David S. Miller" <davem@davemloft.net>,
	Tom Herbert <therbert@google.com>,
	Jiri Benc <jbenc@redhat.com>, James Morris <jmorris@namei.org>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	pradeeps@linux.vnet.ibm.com, jkidambi@us.ibm.com
To: Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f178.google.com ([209.85.212.178]:34278 "EHLO
	mail-wi0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751461AbbFZFPy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Jun 2015 01:15:54 -0400
Received: by wicnd19 with SMTP id nd19so35150855wic.1
        for <netdev@vger.kernel.org>; Thu, 25 Jun 2015 22:15:53 -0700 (PDT)
In-Reply-To: <CALx6S35o-KgViFy6dU5FXA=B2wCJFQjaGPxp22MMhUWP94ZS=A@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2015-06-25 at 19:57 -0700, Tom Herbert wrote:

> That may be, but this change would affect all uses of GRO with UDP
> encapsulation not just for intel 10G NICs. For instance, pushing a lot
> of checksum calculation into the napi for a single queue device could
> overwhelm the corresponding CPU-- this is the motivation for the
> restriction in the first place. We need to do a little more diligence
> here.

We made the choice of computing checksums years ago when GRO was enabled
for GRE packets, as many NIC are not able to validate TCP checksums with
this configuration.

Sure, in some cases this can increase load on softirq handlers, but
there are some ways to spread load on multi queue NIC.
