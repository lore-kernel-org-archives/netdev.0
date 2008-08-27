From: Ayaz Abdulla <aabdulla@nvidia.com>
Subject: Re: [PATCH] forcedeth fix: tx/rx reset
Date: Wed, 27 Aug 2008 10:37:27 -0400
Message-ID: <48B566A7.8060409@nvidia.com>
References: <48B2EDBA.6070802@nvidia.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jgarzik@pobox.com>,
	Manfred Spraul <manfred@colorfullife.com>,
	Andrew Morton <akpm@osdl.org>, nedev <netdev@vger.kernel.org>
To: Ayaz Abdulla <AAbdulla@nvidia.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hqemgate03.nvidia.com ([216.228.112.145]:16055 "EHLO
	hqemgate03.nvidia.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751263AbYH0RkV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Aug 2008 13:40:21 -0400
In-Reply-To: <48B2EDBA.6070802@nvidia.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I am retracting this path for the time being because we believe there is 
other circumstances in play. Once the final root cause is found, I can 
send out the correct patch.

Ayaz


Ayaz Abdulla wrote:
> This patch keeps the HW reset for tx/rx asserted until DMA is enabled.
> This is to ensure that all tx/rx initialization (i.e ring setup) is
> finished before de-asserting the reset.
> 
> Signed-off-by: Ayaz Abdulla <aabdulla@nvidia.com>
> 
> 
> ------------------------------------------------------------------------
> 
> --- old/drivers/net/forcedeth.c	2008-08-25 13:02:17.000000000 -0400
> +++ new/drivers/net/forcedeth.c	2008-08-25 13:02:20.000000000 -0400
> @@ -233,7 +233,7 @@
>  	NvRegTxRxControl = 0x144,
>  #define NVREG_TXRXCTL_KICK	0x0001
>  #define NVREG_TXRXCTL_BIT1	0x0002
> -#define NVREG_TXRXCTL_BIT2	0x0004
> +#define NVREG_TXRXCTL_DMA_DISABLE	0x0004
>  #define NVREG_TXRXCTL_IDLE	0x0008
>  #define NVREG_TXRXCTL_RESET	0x0010
>  #define NVREG_TXRXCTL_RXCHECK	0x0400
> @@ -1555,11 +1555,9 @@
>  	u8 __iomem *base = get_hwbase(dev);
>  
>  	dprintk(KERN_DEBUG "%s: nv_txrx_reset\n", dev->name);
> -	writel(NVREG_TXRXCTL_BIT2 | NVREG_TXRXCTL_RESET | np->txrxctl_bits, base + NvRegTxRxControl);
> +	writel(NVREG_TXRXCTL_DMA_DISABLE | NVREG_TXRXCTL_RESET | np->txrxctl_bits, base + NvRegTxRxControl);
>  	pci_push(base);
>  	udelay(NV_TXRX_RESET_DELAY);
> -	writel(NVREG_TXRXCTL_BIT2 | np->txrxctl_bits, base + NvRegTxRxControl);
> -	pci_push(base);
>  }
>  
>  static void nv_mac_reset(struct net_device *dev)
> @@ -1570,7 +1568,7 @@
>  
>  	dprintk(KERN_DEBUG "%s: nv_mac_reset\n", dev->name);
>  
> -	writel(NVREG_TXRXCTL_BIT2 | NVREG_TXRXCTL_RESET | np->txrxctl_bits, base + NvRegTxRxControl);
> +	writel(NVREG_TXRXCTL_DMA_DISABLE | NVREG_TXRXCTL_RESET | np->txrxctl_bits, base + NvRegTxRxControl);
>  	pci_push(base);
>  
>  	/* save registers since they will be cleared on reset */
> @@ -1589,9 +1587,6 @@
>  	writel(temp1, base + NvRegMacAddrA);
>  	writel(temp2, base + NvRegMacAddrB);
>  	writel(temp3, base + NvRegTransmitPoll);
> -
> -	writel(NVREG_TXRXCTL_BIT2 | np->txrxctl_bits, base + NvRegTxRxControl);
> -	pci_push(base);
>  }
>  
>  static void nv_get_hw_stats(struct net_device *dev)
> 
