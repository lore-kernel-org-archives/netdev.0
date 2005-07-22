From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH] forcedeth: Add support for 64-bit dma addresses.
Date: Fri, 22 Jul 2005 16:56:35 -0400
Message-ID: <42E15D83.7000902@pobox.com>
References: <42E15AE7.3020304@colorfullife.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Netdev <netdev@oss.sgi.com>, Ayaz Abdulla <AAbdulla@nvidia.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Manfred Spraul <manfred@colorfullife.com>
In-Reply-To: <42E15AE7.3020304@colorfullife.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Manfred Spraul wrote:
> +	if (id->driver_data & DEV_HAS_HIGH_DMA) {
> +		np->desc_ver = DESC_VER_3;
> +		dev->features |= NETIF_F_HIGHDMA;
> +		if (pci_set_dma_mask(pci_dev, 0x0000007fffffffffULL)) {
> +			if (pci_set_dma_mask(pci_dev, 0xffffffffULL))
> +				goto out_relreg;
> +		}


setting of NETIF_F_HIGHDMA is wrong, if 64-bit set-dma-mask fails.
