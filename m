From: Joe Perches <joe@perches.com>
Subject: Re: [net-next PATCH 3/4] qlge: Reduce debug print output.
Date: Fri, 30 Oct 2009 15:44:46 -0700
Message-ID: <1256942686.1917.66.camel@Joe-Laptop.home>
References: <1256940816-27540-1-git-send-email-ron.mercer@qlogic.com>
	 <1256940816-27540-4-git-send-email-ron.mercer@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Ron Mercer <ron.mercer@qlogic.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.perches.com ([173.55.12.10]:1140 "EHLO mail.perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932958AbZJ3Wom (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 30 Oct 2009 18:44:42 -0400
In-Reply-To: <1256940816-27540-4-git-send-email-ron.mercer@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2009-10-30 at 15:13 -0700, Ron Mercer wrote:
> Signed-off-by: Ron Mercer <ron.mercer@qlogic.com>
[]
> diff --git a/drivers/net/qlge/qlge.h b/drivers/net/qlge/qlge.h
> index b9f65e0..502c3af 100644
> --- a/drivers/net/qlge/qlge.h
> +++ b/drivers/net/qlge/qlge.h
> @@ -27,6 +27,18 @@
>  		dev_printk(KERN_##klevel, &((qdev)->pdev->dev),	\
>  			   "%s: " fmt, __func__, ##args);  \
>         } while (0)
> +#if 0
> +#define QPRINTK_DBG(qdev, nlevel, klevel, fmt, args...)	\
> +	do {	\
> +		if (!((qdev)->msg_enable & NETIF_MSG_##nlevel))	\
> +			;					\
> +		else						\
> +			dev_printk(KERN_##klevel, &((qdev)->pdev->dev),	\
> +					"%s: " fmt, __func__, ##args);  \
> +	} while (0)
> +#else
> +#define QPRINTK_DBG(qdev, nlevel, klevel, fmt, args...)
> +#endif

This uses an inverted test and it doesn't verify the args to
dev_printk when not #defined.

How about:

#ifdef DEBUG
#define QPRINTK_DBG(qdev, nlevel, klevel, fmt, args...)	do {	\
	if ((qdev)->msg_enable & NETIF_MSG_##nlevel)		\
		dev_printk(KERN_##klevel, &((qdev)->pdev->dev),	\
			   "%s: " fmt, __func__, ##args);	\
} while (0)
#else
#define QPRINTK_DBG(qdev, nlevel, klevel, fmt, args...)	do {	\
	if (0 && (qdev)->msg_enable & NETIF_MSG_##nlevel)	\
		dev_printk(KERN_##klevel, &((qdev)->pdev->dev),	\
			   "%s: " fmt, __func__, ##args);	\
} while (0)
#endif


