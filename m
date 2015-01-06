From: Sergei Shtylyov <sergei.shtylyov-M4DtvfQ/ZS1MRgGoP+s0PdBPR1lH4CV8@public.gmane.org>
Subject: Re: [PATCH_V3] dm9000: Add regulator and reset support to dm9000
Date: Tue, 06 Jan 2015 15:57:02 +0300
Message-ID: <54ABDB9E.3070400@cogentembedded.com>
References: <1420542916-30169-1-git-send-email-Zubair.Kakakhel@imgtec.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, s.hauer-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org
To: Zubair Lutfullah Kakakhel <Zubair.Kakakhel-1AXoQHu6uovQT0dZR+AlfA@public.gmane.org>,
	davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1420542916-30169-1-git-send-email-Zubair.Kakakhel-1AXoQHu6uovQT0dZR+AlfA@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hello.

On 1/6/2015 2:15 PM, Zubair Lutfullah Kakakhel wrote:

> In boards, the dm9000 chip's power and reset can be controlled by gpio.

> It makes sense to add them to the dm9000 driver and let dt be used to
> enable power and reset the phy.

> Signed-off-by: Zubair Lutfullah Kakakhel <Zubair.Kakakhel-1AXoQHu6uovQT0dZR+AlfA@public.gmane.org>
> Signed-off-by: Paul Burton <paul.burton-1AXoQHu6uovQT0dZR+AlfA@public.gmane.org>

[...]

> diff --git a/drivers/net/ethernet/davicom/dm9000.c b/drivers/net/ethernet/davicom/dm9000.c
> index ef0bb58..246c89d 100644
> --- a/drivers/net/ethernet/davicom/dm9000.c
> +++ b/drivers/net/ethernet/davicom/dm9000.c
[...]
> @@ -1426,11 +1429,49 @@ dm9000_probe(struct platform_device *pdev)
>   	struct dm9000_plat_data *pdata = dev_get_platdata(&pdev->dev);
>   	struct board_info *db;	/* Point a board information structure */
>   	struct net_device *ndev;
> +	struct device *dev = &pdev->dev;
>   	const unsigned char *mac_src;
>   	int ret = 0;
>   	int iosize;
>   	int i;
>   	u32 id_val;
> +	int reset_gpios;
> +	enum of_gpio_flags flags;
> +	struct regulator *power;
> +
> +	power = devm_regulator_get(dev, "vcc");
> +	if (PTR_ERR(power) == -EPROBE_DEFER)
> +			return -EPROBE_DEFER;

    Line over-indented.

[...]
> +	reset_gpios = of_get_named_gpio_flags(dev->of_node, "reset-gpios", 0,
> +					      &flags);
> +	if (gpio_is_valid(reset_gpios)) {
> +		ret = devm_gpio_request_one(dev, reset_gpios, flags,
> +					    "dm9000_reset");
> +		if (ret) {
> +			dev_err(dev, "failed to request reset gpio %d: %d\n",
> +				reset_gpios, ret);
> +			return -ENODEV;
> +		}
> +
> +		gpio_direction_output(reset_gpios, 0);

    You could skip this call as devm_gpio_request_one() can handle that for you.

[...]

WBR, Sergei

--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
