From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] forcedeth: fix checksum flag
Date: Mon, 18 Aug 2008 14:54:42 -0700
Message-ID: <20080818145442.659ab3a3.akpm@linux-foundation.org>
References: <48A4B665.5020802@nvidia.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: jgarzik@pobox.com, manfred@colorfullife.com, netdev@vger.kernel.org
To: Ayaz Abdulla <aabdulla@nvidia.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:59831 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757780AbYHRVzb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Aug 2008 17:55:31 -0400
In-Reply-To: <48A4B665.5020802@nvidia.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 14 Aug 2008 18:49:09 -0400
Ayaz Abdulla <aabdulla@nvidia.com> wrote:

> This patch fixes the checksum feature advertised in device flags. The 
> hardware support TCP/UDP over IPv4 and TCP/UDP over IPv6 (without IPv6 
> extension headers). However, the kernel feature flags do not distinguish 
>   IPv6 with/without extension headers.
> 
> Therefore, the driver needs to use NETIF_F_IP_CSUM instead of 
> NETIF_F_HW_CSUM since the latter includes all IPv6 packets.
> 
> A future patch can created to check for extension headers and perform 
> software checksum calculation.
> 
> Signed-off-by: Ayaz Abdulla <aabdulla@nvidia.com>
> 
> 
> [patch-forcedeth-ipv4csum  text/plain (780B)]
> --- old/drivers/net/forcedeth.c	2008-08-14 18:37:11.000000000 -0400
> +++ new/drivers/net/forcedeth.c	2008-08-14 18:37:05.000000000 -0400
> @@ -5522,7 +5522,7 @@
>  	if (id->driver_data & DEV_HAS_CHECKSUM) {
>  		np->rx_csum = 1;
>  		np->txrxctl_bits |= NVREG_TXRXCTL_RXCHECK;
> -		dev->features |= NETIF_F_HW_CSUM | NETIF_F_SG;
> +		dev->features |= NETIF_F_IP_CSUM | NETIF_F_SG;
>  		dev->features |= NETIF_F_TSO;
>  	}
>  
> @@ -5835,7 +5835,7 @@
>  
>  	dev_printk(KERN_INFO, &pci_dev->dev, "%s%s%s%s%s%s%s%s%s%sdesc-v%u\n",
>  		   dev->features & NETIF_F_HIGHDMA ? "highdma " : "",
> -		   dev->features & (NETIF_F_HW_CSUM | NETIF_F_SG) ?
> +		   dev->features & (NETIF_F_IP_CSUM | NETIF_F_SG) ?
>  		   	"csum " : "",
>  		   dev->features & (NETIF_F_HW_VLAN_RX | NETIF_F_HW_VLAN_TX) ?
>  		   	"vlan " : "",
> 

Is this fix needed in 2.6.25.x and 2.6.26.x?
