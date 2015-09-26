From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH net-next v3] net: Fix Hisilicon Network Subsystem
 Support Compilation
Date: Fri, 25 Sep 2015 21:42:56 -0700 (PDT)
Message-ID: <20150925.214256.1901015223799070196.davem@davemloft.net>
References: <1443169790-54861-1-git-send-email-huangdaode@hisilicon.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, pawel.moll-5wv7dgnIgG8@public.gmane.org, mark.rutland-5wv7dgnIgG8@public.gmane.org,
	ijc+devicetree-KcIKpvwj1kUDXYZnReoRVg@public.gmane.org, galak-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org,
	catalin.marinas-5wv7dgnIgG8@public.gmane.org, will.deacon-5wv7dgnIgG8@public.gmane.org,
	liguozhu-C8/M+/jPZTeaMJb+Lgu22Q@public.gmane.org, Yisen.Zhuang-hv44wF8Li93QT0dZR+AlfA@public.gmane.org,
	paul.gortmaker-CWA4WttNNZF54TAoqtyWWQ@public.gmane.org, dingtianhong-hv44wF8Li93QT0dZR+AlfA@public.gmane.org,
	zhangfei.gao-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org, devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linuxarm-hv44wF8Li93QT0dZR+AlfA@public.gmane.org,
	salil.mehta-hv44wF8Li93QT0dZR+AlfA@public.gmane.org, kenneth-lee-2012-H32Fclmsjq1BDgjK7y7TUQ@public.gmane.org,
	xuwei5-C8/M+/jPZTeaMJb+Lgu22Q@public.gmane.org, lisheng011-hv44wF8Li93QT0dZR+AlfA@public.gmane.org
To: huangdaode-C8/M+/jPZTeaMJb+Lgu22Q@public.gmane.org
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1443169790-54861-1-git-send-email-huangdaode-C8/M+/jPZTeaMJb+Lgu22Q@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: huangdaode <huangdaode-C8/M+/jPZTeaMJb+Lgu22Q@public.gmane.org>
Date: Fri, 25 Sep 2015 16:29:50 +0800

> @@ -191,9 +191,12 @@ static void hns_rcb_ring_init(struct ring_pair_cb *ring_pair, int ring_type)
>  	if (ring_type == RX_RING) {
>  		dsaf_write_dev(q, RCB_RING_RX_RING_BASEADDR_L_REG,
>  			       (u32)dma);
> +#ifdef CONFIG_64BIT
>  		dsaf_write_dev(q, RCB_RING_RX_RING_BASEADDR_H_REG,
>  			       (u32)(dma >> 32));
> -
> +#else
> +		dsaf_write_dev(q, RCB_RING_RX_RING_BASEADDR_H_REG, 0);
> +#endif
>  		dsaf_write_dev(q, RCB_RING_RX_RING_BD_LEN_REG,
>  			       bd_size_type);
>  		dsaf_write_dev(q, RCB_RING_RX_RING_BD_NUM_REG,

CONFIG_64BIT doesn't tell you if _DMA_ addresses are 64-bit or not.

Furthermore there is a portable way to shift a 32-bit value down
32-bits whilst avoiding warnings.

	(x >> 31) >> 1

So you should definitely use that instead of the CONFIG_64BIT test.
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
