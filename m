From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH net] r8169: Fix sleeping function called during
 get_stats64
Date: Wed, 9 Sep 2015 22:23:34 +0200
Message-ID: <20150909202334.GA18625@electric-eye.fr.zoreil.com>
References: <1441801223-27534-1-git-send-email-vinschen@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
	pomidorabelisima@gmail.com,
	Konrad Rzeszutek Wilk <konrad@kernel.org>,
	linux-kernel@vger.kernel.org, nic_swsd@realtek.com
To: Corinna Vinschen <vinschen@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:37975 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752676AbbIIUZU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Sep 2015 16:25:20 -0400
Content-Disposition: inline
In-Reply-To: <1441801223-27534-1-git-send-email-vinschen@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Corinna Vinschen <vinschen@redhat.com> :
[...]
> diff --git a/drivers/net/ethernet/realtek/r8169.c b/drivers/net/ethernet/realtek/r8169.c
> index 24dcbe6..630811a 100644
> --- a/drivers/net/ethernet/realtek/r8169.c
> +++ b/drivers/net/ethernet/realtek/r8169.c
[...]
> +	if (!paddr)
> +		return false;

I guess this is the secret recipe.

What about replacing this part with an adequate barrier in rtl_init_one ?

[...]
> @@ -8447,9 +8411,14 @@ static int rtl_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
>  
>  	tp->rtl_fw = RTL_FIRMWARE_UNKNOWN;
>  
> +	tp->CntArray = dma_alloc_coherent (&pdev->dev, sizeof(*tp->CntArray),
> +					   &tp->CntPhysAddr, GFP_KERNEL);
> +	if (!tp->CntArray)
> +		goto err_out_cnt_4;
> +

rc is still zero here so rtl_init_one will return success.

>  	rc = register_netdev(dev);
>  	if (rc < 0)
> -		goto err_out_msi_4;
> +		goto err_out_msi_5;
>  
>  	pci_set_drvdata(pdev, dev);

-- 
Ueimor
