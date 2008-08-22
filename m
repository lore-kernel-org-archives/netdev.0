From: David Miller <davem@davemloft.net>
Subject: Re: [RFC] ipv6: protocol for address routes
Date: Fri, 22 Aug 2008 05:19:40 -0700 (PDT)
Message-ID: <20080822.051940.203949436.davem@davemloft.net>
References: <20080819085441.7b0184d1@speedy>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51047
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753521AbYHVMTm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Aug 2008 08:19:42 -0400
In-Reply-To: <20080819085441.7b0184d1@speedy>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Tue, 19 Aug 2008 08:54:41 -0700

> This fixes a problem spotted with zebra, but not sure if it is necessary a kernel problem.
> With IPV6 when an address is added to an interface, Zebra creates a duplicate RIB
> entry, one as a connected route, and other as a kernel route.
> 
> When an address is added to an interface the RTN_NEWADDR message causes Zebra
> to create a connected route. In IPV4 when an address is added to an interface a RTN_NEWROUTE
> message is set to user space with the protocol RTPROT_KERNEL. Zebra ignores these messages,
> because it already has the connected route.
> 
> The problem is that route created in IPV6 has route protocol == RTPROT_BOOT.
> Was this a design decision or a bug? This fixes it. Same patch applies to both
> net-2.6 and stable.
> 
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

I don't have any strong opinion and it seems correct to me.

Anyone else have any thoughts before I apply this?

> --- a/net/ipv6/addrconf.c	2008-08-18 21:58:51.000000000 -0700
> +++ b/net/ipv6/addrconf.c	2008-08-18 22:00:26.000000000 -0700
> @@ -1688,6 +1688,7 @@ addrconf_prefix_route(struct in6_addr *p
>  		.fc_dst_len = plen,
>  		.fc_flags = RTF_UP | flags,
>  		.fc_nlinfo.nl_net = dev_net(dev),
> +		.fc_protocol = RTPROT_KERNEL,
>  	};
>  
>  	ipv6_addr_copy(&cfg.fc_dst, pfx);
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
