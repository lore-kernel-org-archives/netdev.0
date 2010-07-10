From: Dan Carpenter <error27@gmail.com>
Subject: Re: [PATCH 2/3] macsonic: free irq if sonic_open() fails
Date: Sat, 10 Jul 2010 13:22:29 +0200
Message-ID: <20100710112229.GX19184@bicker>
References: <1278759661-7731-1-git-send-email-segooon@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: kernel-janitors@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	Finn Thain <fthain@telegraphics.com.au>,
	Uwe =?iso-8859-1?Q?Kleine-K=F6nig?=
	<u.kleine-koenig@pengutronix.de>, Tejun Heo <tj@kernel.org>,
	Geert Uytterhoeven <geert@linux-m68k.org>,
	netdev@vger.kernel.org
To: Kulikov Vasiliy <segooon@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:40429 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753015Ab0GJLYU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 10 Jul 2010 07:24:20 -0400
Content-Disposition: inline
In-Reply-To: <1278759661-7731-1-git-send-email-segooon@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Jul 10, 2010 at 03:01:00PM +0400, Kulikov Vasiliy wrote:

> +	if (dev->irq == IRQ_AUTO_3) {
> +		retval = request_irq(IRQ_NUBUS_9, macsonic_interrupt,
> +					IRQ_FLG_FAST, "sonic", dev);
> +		if (retval) {
> +			printk(KERN_ERR "%s: unable to get IRQ %d.\n",
> +					dev->name, IRQ_NUBUS_9);
> +			goto err_irq;
>  		}
> -	return sonic_open(dev);
> +	}
> +	retval = sonic_open(dev);
> +	if (retval)
> +		goto err_irq_nubus;
> +	return 0;
> +
> +err_irq_nubus:

This should be:

+	if (dev->irq == IRQ_AUTO_3)
+		free_irq(IRQ_NUBUS_9, dev);

> +err_irq:
> +	free_irq(dev->irq, dev);
> +err:
> +	return retval;
>  }

regards,
dan carpenter

