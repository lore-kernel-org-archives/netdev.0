From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH] forcedeth: Additional ethtool support
Date: Sun, 10 Jul 2005 19:28:33 +0200
Message-ID: <20050710172833.GA1951@electric-eye.fr.zoreil.com>
References: <42D101EC.6000608@colorfullife.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jeff Garzik <jgarzik@pobox.com>, Netdev <netdev@oss.sgi.com>,
        renaud.lienhart@free.fr
Return-path: <netdev-bounce@oss.sgi.com>
To: Manfred Spraul <manfred@colorfullife.com>
Content-Disposition: inline
In-Reply-To: <42D101EC.6000608@colorfullife.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi Manfred,

Manfred Spraul <manfred@colorfullife.com> :
[...]
> --- 2.6/drivers/net/forcedeth.c	2005-07-10 12:38:53.000000000 +0200
> +++ build-2.6/drivers/net/forcedeth.c	2005-07-10 12:51:12.000000000 +0200
[...]
> +static void nv_get_regs(struct net_device *dev, struct ethtool_regs *regs, void *buf)
> +{
> +	struct fe_priv *np = get_nvpriv(dev);
> +	u8 __iomem *base = get_hwbase(dev);
> +	u32 *rbuf = (u32 *)buf;

Unneeded cast from void *

> +	int i;
> +
> +	regs->version = FORCEDETH_REGS_VER;
> +	spin_lock_irq(&np->lock);
> +	for (i=0;i<FORCEDETH_REGS_SIZE/sizeof(u32);i++)
> +		rbuf[i] = readl(base + i*sizeof(u32));

memcpy_fromio ?

[...]
> @@ -2092,16 +2141,11 @@
>  	}
>  
>  	/* handle different descriptor versions */
> -	if (pci_dev->device == PCI_DEVICE_ID_NVIDIA_NVENET_1 ||
> -			pci_dev->device == PCI_DEVICE_ID_NVIDIA_NVENET_2 ||
> -			pci_dev->device == PCI_DEVICE_ID_NVIDIA_NVENET_3 ||    
> -			pci_dev->device == PCI_DEVICE_ID_NVIDIA_NVENET_12 ||
> -			pci_dev->device == PCI_DEVICE_ID_NVIDIA_NVENET_13) {
> -		np->desc_ver = DESC_VER_1;
> - 		np->pkt_limit = NV_PKTLIMIT_1;
> -	} else {
> +	np->desc_ver = DESC_VER_1;
> + 	np->pkt_limit = NV_PKTLIMIT_1;
   ^^
(nit) a space hides before the tab.

> +	if (id->driver_data & DEV_HAS_LARGEDESC) {
>  		np->desc_ver = DESC_VER_2;
> - 		np->pkt_limit = NV_PKTLIMIT_1;
> + 		np->pkt_limit = NV_PKTLIMIT_2;
   ^^
(nit) a space hides before the tab.

--
Ueimor
