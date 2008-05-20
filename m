From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [RFC, VLAN]: Propagate selected feature bits to VLAN devices
Date: Tue, 20 May 2008 15:48:23 +0100
Message-ID: <20080520144822.GR28241@solarflare.com>
References: <4832E223.7020206@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Peter Warasin <peter@endian.com>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 82-69-137-158.dsl.in-addr.zen.co.uk ([82.69.137.158]:35334 "EHLO
	uklogin.uk.level5networks.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1763847AbYETOsd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 May 2008 10:48:33 -0400
Content-Disposition: inline
In-Reply-To: <4832E223.7020206@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Patrick McHardy wrote:
> diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
> index b11e6e1..3be4559 100644
> --- a/include/linux/netdevice.h
> +++ b/include/linux/netdevice.h
> @@ -514,10 +514,11 @@ struct net_device
>  #define NETIF_F_NETNS_LOCAL	8192	/* Does not change network namespaces */
>  #define NETIF_F_MULTI_QUEUE	16384	/* Has multiple TX/RX queues */
>  #define NETIF_F_LRO		32768	/* large receive offload */
> +#define NETIF_F_VLAN_TSO	65536	/* Supports TSO for VLANs */
> 
>  	/* Segmentation offload features */
> -#define NETIF_F_GSO_SHIFT	16
> -#define NETIF_F_GSO_MASK	0xffff0000
> +#define NETIF_F_GSO_SHIFT	20
> +#define NETIF_F_GSO_MASK	0xfff00000

I really don't think it's a good idea to move around existing flags.  How
about stealing some of the unused high-order bits of NETIF_F_GSO_MASK
instead?

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
