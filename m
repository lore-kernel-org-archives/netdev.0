From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH 1/1] ipv6 addrconf: add IFA_F_NOPREFIXROUTE flag to suppress creation of IP6 routes
Date: Tue, 7 Jan 2014 13:01:11 +0100
Message-ID: <20140107120111.GB24730@order.stressinduktion.org>
References: <20140106160139.GB10204@order.stressinduktion.org> <1389029375-17698-1-git-send-email-thaller@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: Jiri Pirko <jiri@resnulli.us>, netdev@vger.kernel.org,
	stephen@networkplumber.org, dcbw@redhat.com
To: Thomas Haller <thaller@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:44843 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750843AbaAGMBN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Jan 2014 07:01:13 -0500
Content-Disposition: inline
In-Reply-To: <1389029375-17698-1-git-send-email-thaller@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jan 06, 2014 at 06:29:35PM +0100, Thomas Haller wrote:
> @@ -3662,8 +3666,10 @@ static int inet6_addr_modify(struct inet6_ifaddr *ifp, u32 ifa_flags,
>  	if (!(ifp->flags&IFA_F_TENTATIVE))
>  		ipv6_ifa_notify(0, ifp);
>  
> -	addrconf_prefix_route(&ifp->addr, ifp->prefix_len, ifp->idev->dev,
> -			      expires, flags);
> +	if (ifa_flags & IFA_F_NOPREFIXROUTE == 0) {
> +		addrconf_prefix_route(&ifp->addr, ifp->prefix_len, ifp->idev->dev,
> +				      expires, flags);
> +	}

Actually, if we switch from IFA_F_NOPREFIXROUTE to !IFA_F_NOPREFIXROUTE we
have to remove the prefix route, no?

Greetings,

  Hannes
