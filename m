From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH_V4] dm9000: Add regulator and reset support to dm9000
Date: Wed, 14 Jan 2015 16:47:32 -0500 (EST)
Message-ID: <20150114.164732.1058665183210615359.davem@davemloft.net>
References: <1421231777-12589-1-git-send-email-Zubair.Kakakhel@imgtec.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, s.hauer-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org,
	sergei.shtylyov-M4DtvfQ/ZS1MRgGoP+s0PdBPR1lH4CV8@public.gmane.org
To: Zubair.Kakakhel-1AXoQHu6uovQT0dZR+AlfA@public.gmane.org
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1421231777-12589-1-git-send-email-Zubair.Kakakhel-1AXoQHu6uovQT0dZR+AlfA@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Zubair Lutfullah Kakakhel <Zubair.Kakakhel-1AXoQHu6uovQT0dZR+AlfA@public.gmane.org>
Date: Wed, 14 Jan 2015 10:36:17 +0000

> +	power = devm_regulator_get(dev, "vcc");
> +	if (PTR_ERR(power) == -EPROBE_DEFER)
> +		return -EPROBE_DEFER;
> +	if (IS_ERR(power)) {
> +		dev_dbg(dev, "no regulator provided\n");

I know it may seem silly, but to me it is more logical to always
guard PTR_ERR() uses with IS_ERR().

Therefore could you please restructure this as:

	if (IS_ERR(power)) {
		if (PTR_ERR(power) == -EPROBE_DEFER)
			return -EPROBE_DEFER;
		else
			dev_dbg(dev, "no regulator provided\n");
	} else {

Thanks.
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
