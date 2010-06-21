From: Andreas Klauer <Andreas.Klauer@metamorpher.de>
Subject: Re: 2.6.34 + IPv6: Oops?
Date: Mon, 21 Jun 2010 22:04:13 +0200
Message-ID: <20100621200413.GA2280@EIS>
References: <20100619175352.GA8482@EIS>
 <20100621153018.GA2433@EIS>
 <20100621162518.GA5972@nuttenaction>
 <20100621102508.2075d677@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Hagen Paul Pfeifer <hagen@jauu.net>, netdev@vger.kernel.org,
	Octavian Purdila <opurdila@ixiacom.com>
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay03.ispgateway.de ([80.67.18.15]:41036 "EHLO
	smtprelay03.ispgateway.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751852Ab0FUUFG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Jun 2010 16:05:06 -0400
Content-Disposition: inline
In-Reply-To: <20100621102508.2075d677@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jun 21, 2010 at 10:25:08AM -0700, Stephen Hemminger wrote:
> It is not handling the case of ifp == NULL.
> 
> Maybe the following (move the assignment into the if block).
> 
> --- a/net/ipv6/ndisc.c	2010-06-21 10:22:20.825637690 -0700
> +++ b/net/ipv6/ndisc.c	2010-06-21 10:24:31.573011996 -0700
> @@ -586,6 +586,7 @@ static void ndisc_send_na(struct net_dev
>  		src_addr = solicited_addr;
>  		if (ifp->flags & IFA_F_OPTIMISTIC)
>  			override = 0;
> +		inc_opt |= ifp->idev->cnf.force_tllao;
>  		in6_ifa_put(ifp);
>  	} else {
>  		if (ipv6_dev_get_saddr(dev_net(dev), dev, daddr,
> @@ -599,7 +600,6 @@ static void ndisc_send_na(struct net_dev
>  	icmp6h.icmp6_solicited = solicited;
>  	icmp6h.icmp6_override = override;
>  
> -	inc_opt |= ifp->idev->cnf.force_tllao;
>  	__ndisc_send(dev, neigh, daddr, src_addr,
>  		     &icmp6h, solicited_addr,
>  		     inc_opt ? ND_OPT_TARGET_LL_ADDR : 0);
> 
> 
> 

Thanks a lot! This fix seems to work fine for me (tested locally only).
I'll see what happens when I apply it to my server tomorrow.

Curious though as to why I wasn't able to reproduce it when compiling 
the kernel with Gentoo's GCC. It doesn't look like it should make any 
difference. Maybe I made a mistake when I tested it with Gentoo.

Regards
Andreas Klauer
