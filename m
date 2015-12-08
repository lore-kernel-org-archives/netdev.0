From: Florian Fainelli <f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH net-next 1/2] net: hns: enet specisies a reference to
 dsaf
Date: Tue, 08 Dec 2015 10:10:47 -0800
Message-ID: <56671D27.5070700@gmail.com>
References: <1449302356-54658-1-git-send-email-yankejian@huawei.com> <1449302356-54658-2-git-send-email-yankejian@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, haifeng.wei-hv44wF8Li93QT0dZR+AlfA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linuxarm-hv44wF8Li93QT0dZR+AlfA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org
To: yankejian <yankejian-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org,
	arnd-r2nGTMty4D4@public.gmane.org, fengguang.wu-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org,
	pawel.moll-5wv7dgnIgG8@public.gmane.org, mark.rutland-5wv7dgnIgG8@public.gmane.org,
	ijc+devicetree-KcIKpvwj1kUDXYZnReoRVg@public.gmane.org, galak-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org,
	catalin.marinas-5wv7dgnIgG8@public.gmane.org, will.deacon-5wv7dgnIgG8@public.gmane.org,
	salil.mehta-hv44wF8Li93QT0dZR+AlfA@public.gmane.org, Yisen.Zhuang-hv44wF8Li93QT0dZR+AlfA@public.gmane.org,
	liguozhu-hv44wF8Li93QT0dZR+AlfA@public.gmane.org, lisheng011-hv44wF8Li93QT0dZR+AlfA@public.gmane.org,
	huangdaode-C8/M+/jPZTeaMJb+Lgu22Q@public.gmane.org, xuwei5-C8/M+/jPZTeaMJb+Lgu22Q@public.gmane.org
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1449302356-54658-2-git-send-email-yankejian-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Subject: s/specisies/specifies/?

On 04/12/15 23:59, yankejian wrote:
> enet is associating with dasf. before this patch, the association is
> the same strings between ae-name and dsa-name. in a general way, enet
> specifies a reference to dsaf should be a good idea. so this patch
> deletes the ae-name in enet, and adds parsing the ae-handle
> from DT to set the associating with dsaf.
> 
> Signed-off-by: yankejian <yankejian-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
> ---
[snip]

> diff --git a/drivers/net/ethernet/hisilicon/hns/hnae.c b/drivers/net/ethernet/hisilicon/hns/hnae.c
> index b364529..3bfe36f 100644
> --- a/drivers/net/ethernet/hisilicon/hns/hnae.c
> +++ b/drivers/net/ethernet/hisilicon/hns/hnae.c
> @@ -95,21 +95,17 @@ static struct hnae_buf_ops hnae_bops = {
>  static int __ae_match(struct device *dev, const void *data)
>  {
>  	struct hnae_ae_dev *hdev = cls_to_ae_dev(dev);
> -	const char *ae_id = data;
>  
> -	if (!strncmp(ae_id, hdev->name, AE_NAME_SIZE))
> -		return 1;
> -
> -	return 0;
> +	return hdev->dev->of_node == data;
>  }
>  
> -static struct hnae_ae_dev *find_ae(const char *ae_id)
> +static struct hnae_ae_dev *find_ae(const struct device_node *ae_node)
>  {
>  	struct device *dev;
>  
> -	WARN_ON(!ae_id);
> +	WARN_ON(!ae_node);
>  
> -	dev = class_find_device(hnae_class, NULL, ae_id, __ae_match);
> +	dev = class_find_device(hnae_class, NULL, ae_node, __ae_match);

of_find_net_device_by_node might be used for this maybe?
-- 
Florian
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
