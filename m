From: Francois Romieu <romieu-W8zweXLXuWQS+FvcfC7Uqw@public.gmane.org>
Subject: Re: [PATCH 16/21] orinoco_pci: disable device and free IRQ when suspending
Date: Fri, 7 Apr 2006 23:24:29 +0200
Message-ID: <20060407212429.GA15720@electric-eye.fr.zoreil.com>
References: <20060407081019.16107.67672.stgit@dv.roinet.com> <20060407081051.16107.87289.stgit@dv.roinet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, orinoco-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
Return-path: <orinoco-devel-admin-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
To: Pavel Roskin <proski-mXXj517/zsQ@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20060407081051.16107.87289.stgit-fdEtzkpK75rby3iVrkZq2A@public.gmane.org>
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
> index 5362c21..e57e92b 100644
> --- a/drivers/net/wireless/orinoco_pci.c
> +++ b/drivers/net/wireless/orinoco_pci.c
> @@ -304,7 +304,9 @@ static int orinoco_pci_suspend(struct pc
>  	
>  	orinoco_unlock(priv, &flags);
>  
> +	free_irq(pdev->irq, dev);
>  	pci_save_state(pdev);
> +	pci_disable_device(pdev);
>  	pci_set_power_state(pdev, PCI_D3hot);
>  
>  	return 0;

/me stares at the thread behind http://lkml.org/lkml/2005/7/30/143

Imho {free/request}_irq during suspend/resume deserves some
explanation.

-- 
Ueimor


-------------------------------------------------------
This SF.Net email is sponsored by xPML, a groundbreaking scripting language
that extends applications into web and mobile media. Attend the live webcast
and join the prime developer group breaking into this new coding territory!
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=110944&bid=241720&dat=121642
