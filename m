From: Jon Mason <jon.mason@exar.com>
Subject: Re: [PATCH net-next] drivers/net/vxge/vxge-main.c: Use pr_<level>
 and netdev_<level>
Date: Tue, 27 Jul 2010 22:21:18 -0500
Message-ID: <20100728032117.GL28630@exar.com>
References: <1280267223.24054.44.camel@Joe-Laptop.home>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ramkrishna Vepa <Ramkrishna.Vepa@exar.com>,
	Sreenivasa Honnur <Sreenivasa.Honnur@exar.com>,
	"David S. Miller" <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gy0-f174.google.com ([209.85.160.174]:43628 "EHLO
	mail-gy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752068Ab0G1DVz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Jul 2010 23:21:55 -0400
Content-Disposition: inline
In-Reply-To: <1280267223.24054.44.camel@Joe-Laptop.home>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jul 27, 2010 at 02:47:03PM -0700, Joe Perches wrote:
> Use pr_fmt, pr_<level> and netdev_<level> where appropriate.
> 
> Signed-off-by: Joe Perches <joe@perches.com>

Acked-by: Jon Mason <jon.mason@exar.com>

> ---
>  drivers/net/vxge/vxge-main.c |   27 +++++++++++----------------
>  1 files changed, 11 insertions(+), 16 deletions(-)
> 
> diff --git a/drivers/net/vxge/vxge-main.c b/drivers/net/vxge/vxge-main.c
> index 94d87e8..c7c5605 100644
> --- a/drivers/net/vxge/vxge-main.c
> +++ b/drivers/net/vxge/vxge-main.c
> @@ -41,6 +41,8 @@
>  *
>  ******************************************************************************/
>  
> +#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
> +
>  #include <linux/if_vlan.h>
>  #include <linux/pci.h>
>  #include <linux/slab.h>
> @@ -144,7 +146,7 @@ vxge_callback_link_up(struct __vxge_hw_device *hldev)
>  
>  	vxge_debug_entryexit(VXGE_TRACE, "%s: %s:%d",
>  		vdev->ndev->name, __func__, __LINE__);
> -	printk(KERN_NOTICE "%s: Link Up\n", vdev->ndev->name);
> +	netdev_notice(vdev->ndev, "Link Up\n");
>  	vdev->stats.link_up++;
>  
>  	netif_carrier_on(vdev->ndev);
> @@ -168,7 +170,7 @@ vxge_callback_link_down(struct __vxge_hw_device *hldev)
>  
>  	vxge_debug_entryexit(VXGE_TRACE,
>  		"%s: %s:%d", vdev->ndev->name, __func__, __LINE__);
> -	printk(KERN_NOTICE "%s: Link Down\n", vdev->ndev->name);
> +	netdev_notice(vdev->ndev, "Link Down\n");
>  
>  	vdev->stats.link_down++;
>  	netif_carrier_off(vdev->ndev);
> @@ -2679,7 +2681,7 @@ vxge_open(struct net_device *dev)
>  
>  	if (vxge_hw_device_link_state_get(vdev->devh) == VXGE_HW_LINK_UP) {
>  		netif_carrier_on(vdev->ndev);
> -		printk(KERN_NOTICE "%s: Link Up\n", vdev->ndev->name);
> +		netdev_notice(vdev->ndev, "Link Up\n");
>  		vdev->stats.link_up++;
>  	}
>  
> @@ -2817,7 +2819,7 @@ int do_vxge_close(struct net_device *dev, int do_io)
>  	}
>  
>  	netif_carrier_off(vdev->ndev);
> -	printk(KERN_NOTICE "%s: Link Down\n", vdev->ndev->name);
> +	netdev_notice(vdev->ndev, "Link Down\n");
>  	netif_tx_stop_all_queues(vdev->ndev);
>  
>  	/* Note that at this point xmit() is stopped by upper layer */
> @@ -3844,9 +3846,7 @@ static pci_ers_result_t vxge_io_slot_reset(struct pci_dev *pdev)
>  	struct vxgedev *vdev = netdev_priv(netdev);
>  
>  	if (pci_enable_device(pdev)) {
> -		printk(KERN_ERR "%s: "
> -			"Cannot re-enable device after reset\n",
> -			VXGE_DRIVER_NAME);
> +		netdev_err(netdev, "Cannot re-enable device after reset\n");
>  		return PCI_ERS_RESULT_DISCONNECT;
>  	}
>  
> @@ -3871,9 +3871,8 @@ static void vxge_io_resume(struct pci_dev *pdev)
>  
>  	if (netif_running(netdev)) {
>  		if (vxge_open(netdev)) {
> -			printk(KERN_ERR "%s: "
> -				"Can't bring device back up after reset\n",
> -				VXGE_DRIVER_NAME);
> +			netdev_err(netdev,
> +				   "Can't bring device back up after reset\n");
>  			return;
>  		}
>  	}
> @@ -4430,13 +4429,9 @@ static int __init
>  vxge_starter(void)
>  {
>  	int ret = 0;
> -	char version[32];
> -	snprintf(version, 32, "%s", DRV_VERSION);
>  
> -	printk(KERN_INFO "%s: Copyright(c) 2002-2010 Exar Corp.\n",
> -		VXGE_DRIVER_NAME);
> -	printk(KERN_INFO "%s: Driver version: %s\n",
> -			VXGE_DRIVER_NAME, version);
> +	pr_info("Copyright(c) 2002-2010 Exar Corp.\n");
> +	pr_info("Driver version: %s\n", DRV_VERSION);
>  
>  	verify_bandwidth();
>  
> 
> 
