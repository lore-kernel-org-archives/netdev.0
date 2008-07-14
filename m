From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH RFC 01/10] mlx4_en: Include file
Date: Mon, 14 Jul 2008 17:17:25 +0100
Message-ID: <20080714161724.GS19302@solarflare.com>
References: <487B6569.5000806@mellanox.co.il>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jeff@garzik.org, netdev@vger.kernel.org,
	Liran Liss <liranl@mellanox.co.il>, tziporet@mellanox.co.il,
	Roland Dreier <rdreier@cisco.com>
To: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smarthost02.mail.mbr-roch.zen.net.uk ([212.23.3.141]:41360 "EHLO
	smarthost02.mail.zen.net.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752686AbYGNQRb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Jul 2008 12:17:31 -0400
Content-Disposition: inline
In-Reply-To: <487B6569.5000806@mellanox.co.il>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Yevgeny Petrilin wrote:
[...]
> +#ifdef CONFIG_MLX4_EN_DEBUG
> +#define mlx4_dbg(mdev, format, arg...)	\
> +	printk(KERN_DEBUG "%s %s: " format , DRV_NAME ,\
> +		(&mdev->pdev->dev)->bus_id , ## arg)
> +#else /* CONFIG_MLX4_DEBUG */
> +#define mlx4_dbg(mdev, format, arg...) do { (void) mdev; } while (0)
> +#endif /* CONFIG_MLX4_DEBUG */
> +
> +#define mlx4_err(mdev, format, arg...) \
> +	printk(KERN_ERR "%s %s: " format , DRV_NAME ,\
> +		(&mdev->pdev->dev)->bus_id , ## arg)
> +#define mlx4_info(mdev, format, arg...) \
> +	printk(KERN_INFO "%s %s: " format , DRV_NAME ,\
> +		(&mdev->pdev->dev)->bus_id , ## arg)
> +#define mlx4_warn(mdev, format, arg...) \
> +	printk(KERN_WARNING "%s %s: " format , DRV_NAME ,\
> +		(&mdev->pdev->dev)->bus_id , ## arg)

I think these should be defined in terms of dev_dbg etc.

[...]
> +#ifdef CONFIG_MLX4_EN_PREFETCH
> +	#define PREFETCH(x)		prefetch(x)
> +#else
> +	#define PREFETCH(x)
> +#endif
> +
> +#ifdef CONFIG_MLX4_EN_SW_COUNTERS
> +#define DO_SW_COUNTERS			1
> +#define SET_SW_COUNTER(cnt, val)	((cnt) = (val))
> +#define INC_SW_COUNTER(cnt)		(++(cnt))
> +#define ADD_SW_COUNTER(cnt, add)	((cnt) += (add))
> +#else
> +#define DO_SW_COUNTERS			0
> +#define SET_SW_COUNTER(cnt, val)
> +#define INC_SW_COUNTER(cnt)
> +#define ADD_SW_COUNTER(cnt, add)
> +#endif

The do-nothing implementations should be do {} while (0).

[...]
> +/*
> + * Useful macros
> + */
> +
> +#define ROUNDUP_LOG2(x)		ilog2(roundup_pow_of_two(x))
> +#define XNOR(x, y)		(!(x) == !(y))
> +#define MIN(a, b)		((a) < (b) ? (a) : (b))
> +#define MAX(a, b)		((a) > (b) ? (a) : (b))

So useful that <linux/kernel.h> already has quite a few of them...

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
