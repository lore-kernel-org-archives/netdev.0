From: Corcodel Marian <asd@marian1000.go.ro>
Subject: Re: [PATCH net v4] r8169: Bad implementation of netif_carrier_*
Date: Fri, 12 Feb 2016 15:40:07 +0200
Message-ID: <1455284407.1894.2.camel@marian1000.go.ro>
References: <1455172063-1959-1-git-send-email-asd@marian1000.go.ro>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 5-14-227-192.residential.rdsnet.ro ([5.14.227.192]:47753 "EHLO
	marian1000.go.ro" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752459AbcBLNkQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Feb 2016 08:40:16 -0500
In-Reply-To: <1455172063-1959-1-git-send-email-asd@marian1000.go.ro>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2016-02-11 at 08:27 +0200, Corcodel Marian wrote:
>   On probe stage what carrier to stop and rest two situation
>   netif_carrier_* is slow and disturbing autonegociation process.
> 
> Signed-off-by: Corcodel Marian <asd@marian1000.go.ro>
> ---
>  drivers/net/ethernet/realtek/r8169.c | 3 ---
>  1 file changed, 3 deletions(-)
> 
> diff --git a/drivers/net/ethernet/realtek/r8169.c
> b/drivers/net/ethernet/realtek/r8169.c
> index 1f75478..0f1adfa 100644
> --- a/drivers/net/ethernet/realtek/r8169.c
> +++ b/drivers/net/ethernet/realtek/r8169.c
> @@ -1675,11 +1675,9 @@ static void __rtl8169_check_link_status(struct
> net_device *dev,
>  		/* This is to cancel a scheduled suspend if there's
> one. */
>  		if (pm)
>  			pm_request_resume(&tp->pci_dev->dev);
> -		netif_carrier_on(dev);
>  		if (net_ratelimit())
>  			netif_info(tp, ifup, dev, "link up\n");
>  	} else {
> -		netif_carrier_off(dev);
>  		netif_info(tp, ifdown, dev, "link down\n");
>  		if (pm)
>  			pm_schedule_suspend(&tp->pci_dev->dev,
> 5000);
> @@ -8441,7 +8439,6 @@ static int rtl_init_one(struct pci_dev *pdev,
> const struct pci_device_id *ent)
>  	if (pci_dev_run_wake(pdev))
>  		pm_runtime_put_noidle(&pdev->dev);
>  
> -	netif_carrier_off(dev);
>  
>  out:
>  	return rc;
How is status with this patch-is accepted or not?
I'm interresed by this patch on order to send another patches wich
depend this.
