From: "Fu, Zhonghui" <zhonghui.fu-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>
Subject: Re: [PATCH v3] brcmfmac: avoid duplicated suspend/resume operation
Date: Sun, 15 Feb 2015 10:40:45 +0800
Message-ID: <54E0072D.3020802@linux.intel.com>
References: <54DC1D7D.5050407@linux.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
To: Kalle Valo <kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>, brudley-dY08KVG/lbpWk0Htik3J/w@public.gmane.org,
	Arend van Spriel <arend-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>,
	Franky Lin <frankyl-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>, meuleman-dY08KVG/lbpWk0Htik3J/w@public.gmane.org,
	linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org, pieterpg-dY08KVG/lbpWk0Htik3J/w@public.gmane.org, hdegoede-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org,
	wens-jdAy2FN1RRM@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	brcm80211-dev-list-dY08KVG/lbpWk0Htik3J/w@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	"linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <54DC1D7D.5050407-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


Any comments to this patch? Can it be accepted?

Thanks,
Zhonghui

On 2015/2/12 11:26, Fu, Zhonghui wrote:
> From a05d35ab334c20970c236fb971dae88810078c88 Mon Sep 17 00:00:00 2001
> From: Fu Zhonghui <zhonghui.fu-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>
> Date: Thu, 12 Feb 2015 10:49:35 +0800
> Subject: [PATCH v3] brcmfmac: avoid duplicated suspend/resume operation
>
> WiFi chip has 2 SDIO functions, and PM core will trigger
> twice suspend/resume operations for one WiFi chip to do
> the same things. This patch avoid this case.
>
> Acked-by: Arend van Spriel <arend-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>
> Signed-off-by: Fu Zhonghui <zhonghui.fu-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>
> ---
> Changes in v3:
> - Rebase to wireless-drivers-next/master branch
>
>  drivers/net/wireless/brcm80211/brcmfmac/bcmsdh.c | 13 ++++++++++++-
>  1 file changed, 12 insertions(+), 1 deletion(-)
>
> diff --git a/drivers/net/wireless/brcm80211/brcmfmac/bcmsdh.c b/drivers/net/wireless/brcm80211/brcmfmac/bcmsdh.c
> index 7944224..b8832a7 100644
> --- a/drivers/net/wireless/brcm80211/brcmfmac/bcmsdh.c
> +++ b/drivers/net/wireless/brcm80211/brcmfmac/bcmsdh.c
> @@ -1117,9 +1117,13 @@ static int brcmf_ops_sdio_suspend(struct device *dev)
>  	struct brcmf_bus *bus_if;
>  	struct brcmf_sdio_dev *sdiodev;
>  	mmc_pm_flag_t sdio_flags;
> +	struct sdio_func *func = dev_to_sdio_func(dev);
>  
>  	brcmf_dbg(SDIO, "Enter\n");
>  
> +	if (func->num == 2)
> +		return 0;
> +
>  	bus_if = dev_get_drvdata(dev);
>  	sdiodev = bus_if->bus_priv.sdio;
>  
> @@ -1148,9 +1152,16 @@ static int brcmf_ops_sdio_suspend(struct device *dev)
>  static int brcmf_ops_sdio_resume(struct device *dev)
>  {
>  	struct brcmf_bus *bus_if = dev_get_drvdata(dev);
> -	struct brcmf_sdio_dev *sdiodev = bus_if->bus_priv.sdio;
> +	struct brcmf_sdio_dev *sdiodev;
> +	struct sdio_func *func = dev_to_sdio_func(dev);
>  
>  	brcmf_dbg(SDIO, "Enter\n");
> +
> +	if (func->num == 2)
> +		return 0;
> +
> +	sdiodev = bus_if->bus_priv.sdio;
> +
>  	if (sdiodev->pdata && sdiodev->pdata->oob_irq_supported)
>  		disable_irq_wake(sdiodev->pdata->oob_irq_nr);
>  	brcmf_sdio_wd_timer(sdiodev->bus, BRCMF_WD_POLL_MS);
> -- 1.9.1
>

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
