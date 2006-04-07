From: Francois Romieu <romieu-W8zweXLXuWQS+FvcfC7Uqw@public.gmane.org>
Subject: Re: [PATCH 17/21] orinoco_pci: use pci_iomap() for resources
Date: Fri, 7 Apr 2006 23:36:19 +0200
Message-ID: <20060407213619.GB15720@electric-eye.fr.zoreil.com>
References: <20060407081019.16107.67672.stgit@dv.roinet.com> <20060407081053.16107.19347.stgit@dv.roinet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, orinoco-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
Return-path: <orinoco-devel-admin-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
To: Pavel Roskin <proski-mXXj517/zsQ@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20060407081053.16107.19347.stgit-fdEtzkpK75rby3iVrkZq2A@public.gmane.org>
Sender: orinoco-devel-admin-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
Errors-To: orinoco-devel-admin-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/orinoco-devel>,
	<mailto:orinoco-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=unsubscribe>
List-Post: <mailto:orinoco-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
List-Help: <mailto:orinoco-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/orinoco-devel>,
	<mailto:orinoco-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=orinoco-devel>
List-Id: netdev.vger.kernel.org

Pavel Roskin <proski-mXXj517/zsQ@public.gmane.org> :
[...]
> diff --git a/drivers/net/wireless/orinoco_pci.c b/drivers/net/wireless/orinoco_pci.c
> index e57e92b..75df90f 100644
> --- a/drivers/net/wireless/orinoco_pci.c
> +++ b/drivers/net/wireless/orinoco_pci.c
> @@ -170,9 +170,7 @@ static int orinoco_pci_init_one(struct p
>  				const struct pci_device_id *ent)
>  {
>  	int err = 0;
> -	unsigned long pci_iorange;
> -	u16 __iomem *pci_ioaddr = NULL;
> -	unsigned long pci_iolen;
> +	void __iomem *pci_ioaddr = NULL;
>  	struct orinoco_private *priv = NULL;
>  	struct orinoco_pci_card *card;
>  	struct net_device *dev = NULL;

(ok, the useless initializers disappear later in the serie)

[...]
> @@ -208,8 +205,8 @@ static int orinoco_pci_init_one(struct p
>  	priv = netdev_priv(dev);
>  	card = priv->card;
>  	card->pci_ioaddr = pci_ioaddr;
> -	dev->mem_start = pci_iorange;
> -	dev->mem_end = pci_iorange + pci_iolen - 1;
> +	dev->mem_start = pci_resource_start(pdev, 0);
> +	dev->mem_end = dev->mem_start + pci_resource_len(pdev, 0) - 1;

Is there a reason why dev->mem_{start/end} should not be removed ?

-- 
Ueimor


-------------------------------------------------------
This SF.Net email is sponsored by xPML, a groundbreaking scripting language
that extends applications into web and mobile media. Attend the live webcast
and join the prime developer group breaking into this new coding territory!
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=110944&bid=241720&dat=121642
