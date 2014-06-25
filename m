From: Daniele Forsi <dforsi@gmail.com>
Subject: Re: [PATCH v2] Add support for GPIOs for SMSC LAN95xx chips.
Date: Wed, 25 Jun 2014 12:34:23 +0200
Message-ID: <CAN_we7MbMywYzysn_Q_iRAOZZuE+KU_jDJxMW-Qz0KK0RHwSRQ@mail.gmail.com>
References: <20140513.180121.1755290421111591028.davem@davemloft.net>
	<1403671574-16857-1-git-send-email-boger@contactless.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Steve Glendinning <steve.glendinning@shawell.net>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	USB list <linux-usb@vger.kernel.org>
To: Evgeny Boger <boger@contactless.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f50.google.com ([209.85.215.50]:50403 "EHLO
	mail-la0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753613AbaFYKeZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Jun 2014 06:34:25 -0400
In-Reply-To: <1403671574-16857-1-git-send-email-boger@contactless.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2014-06-25 6:46 GMT+02:00 Evgeny Boger:

> There might be 11 GPIOs in total.

do you mean "12 GPIOs"? You say later they are 0-based and the last one is "11"

> Last three GPIOs  (offsets 8-11, 0-based) are shared with FDX, LNKA, SPD
> LEDs respectively.

so you mean the last "four"?
and you may want to remove the extra space before the open parenthesis

also there are still several unneeded newlines

> diff --git a/drivers/net/usb/smsc95xx.c b/drivers/net/usb/smsc95xx.c

> @@ -68,6 +70,15 @@ struct smsc95xx_priv {
>         spinlock_t mac_cr_lock;
>         u8 features;
>         u8 suspend_flags;
> +
> +       struct usbnet *dev;

> +static int smsc95xx_gpio_request(struct gpio_chip *gpio, unsigned offset)

> +       mutex_unlock(&pdata->gpio_lock);
> +
> +
> +       return (ret < 0) ? ret : 0;
> +}
> +
> +static void smsc95xx_gpio_free(struct gpio_chip *gpio, unsigned offset)

> +       if (ret < 0)
> +               netif_err(pdata->dev, ifdown, pdata->dev->net,
> +                       "error freeing gpio %d\n", offset);
> +
> +}

and in other places

> +static void smsc95xx_gpio_set(struct gpio_chip *gpio, unsigned offset,
> +                               int value)
> +{

> +       if (ret < 0) {
> +               netif_err(pdata->dev, ifdown, pdata->dev->net,
> +                       "error writing gpio %d=%d\n", offset, value);
> +               return;
> +       }
> +}

no need to put a "return" there at he end of the function (if it's
defensive programming then you didn't put return in similar code in a
previous function)

-- 
Daniele Forsi
