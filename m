From: jamal <hadi@cyberus.ca>
Subject: Re: [RFC][PATCH 0/3][XFRM]: Support packet processing error
	statistics.
Date: Tue, 23 Oct 2007 15:47:33 -0400
Message-ID: <1193168853.4415.56.camel@localhost>
References: <20071017.213523.58458049.davem@davemloft.net>
	 <11930334662094-git-send-email-nakam@linux-ipv6.org>
	 <1193056091.4422.33.camel@localhost>
	 <200710231608.34661.nakam@linux-ipv6.org>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Masahide NAKAMURA <nakam@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rn-out-0910.google.com ([64.233.170.188]:22605 "EHLO
	rn-out-0102.google.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751682AbXJWTrj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Oct 2007 15:47:39 -0400
Received: by rn-out-0102.google.com with SMTP id s46so1698155rnb
        for <netdev@vger.kernel.org>; Tue, 23 Oct 2007 12:47:38 -0700 (PDT)
In-Reply-To: <200710231608.34661.nakam@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2007-23-10 at 16:08 +0900, Masahide NAKAMURA wrote:

> Thanks. I would like you to find too much item at my patch
> for the statistics, too.

I am not anywhere close to a machine where i can give you precise
details to this; the one thing that sticks out in my brain cells is the
SPI mismatch. This (in static setups) seemed to be the most common
mistake i saw (other than a mismatched key). Your stats as you have them
now and as is will catch both in one spot - which is a good start.

> This point is one of what I want to hear comment.
> My patch uses "XFRM_MIB_XXX" because I found "LINUX_MIB_XXX" definition at
> include/linux/snmp.h for TCP extended statistics at /proc/net/netstat and
> it does not seem to be defined by any RFC specification. 

I thought those were part of some MIB somewhere. Doesnt RFC 4898 cover
them?
In any case, it seems to me to be more accurate to not call them MIB
stats if they are not. This doesnt qualify using the macros, utilities
etc used for MIBs.

> Then I feel it is not so bad to
> use _MIB_ for them. Maybe we have another idea to merge them into LINUX_MIB.
> 
> Now we have the following candidates:
> 
> (1) my patch		XFRM_MIB_INHDRERROR
> (2) some extender	XFRM_XXX_INHDRERROR	(XXX is requested)
> (3) not-mib extender	XFRM_NOTMIB_INHDRERROR
> (4) no extender		XFRM_INHDRERROR
> (5) merge linux-mib	LINUX_MIB_XFRMINHDRERROR
> 
> Comments?

I am very tempted to say #4. And when you push this to be a real MIB
stat then 

> 
> > 2) Why /proc? Are you going to make these available also via netlink? 
> 
> Because /proc is easy to see it without any modified application.
> If you want the netlink interface, I can do it as the next step. Do you want it?

Absolutely - it would be much appreciated. And if you dont have time, I
will write and test the user space part extension.

cheers,
jamal

