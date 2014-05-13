From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH 1/1] Add support for GPIOs for SMSC LAN95xx chips.
Date: Tue, 13 May 2014 18:01:21 -0400 (EDT)
Message-ID: <20140513.180121.1755290421111591028.davem@davemloft.net>
References: <1399815254-30229-1-git-send-email-boger@contactless.ru>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: steve.glendinning-nksJyM/082jR7s880joybQ@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: boger-hVk9LwgH4SrGCOCKMErq+g@public.gmane.org
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1399815254-30229-1-git-send-email-boger-hVk9LwgH4SrGCOCKMErq+g@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Evgeny Boger <boger-hVk9LwgH4SrGCOCKMErq+g@public.gmane.org>
Date: Sun, 11 May 2014 17:34:14 +0400

> There might be 11 GPIOs in total. Last three GPIOs  (offsets 8-11, 0-based) are shared
> with FDX, LNKA, SPD LEDs respectively. The LEDs are driven by chip by default
> at startup time. Once the corresponding GPIO is requested, the chip LED drive
> logic is disabled.
> 
> Based on commented out code presumably from SMSC original driver.
> https://github.com/olerem/barebox/blob/master/drivers/net/usb/smsc95xx.c
> 
> Signed-off-by: Evgeny Boger <boger-hVk9LwgH4SrGCOCKMErq+g@public.gmane.org>

Won't you need to add some GPIOLIB logic to the Kconfig entry for this
driver?

Also:

> +}
> +
> +
> +static int smsc95xx_gpio_request(struct gpio_chip *gpio, unsigned offset)

One empty line is sufficient between functions, please delete on of these
two.

> +{
> +	int ret = -1;
> +	u32 val, reg;
> +	int type_shift;
> +
> +	struct smsc95xx_priv *pdata =
> +			container_of(gpio, struct smsc95xx_priv, gpio);

Please do not put empty lines in the middle of local function
variable declarations.

> +	int ret = -1;
> +	u32 val, reg;
> +	int type_shift;
> +
> +	struct smsc95xx_priv *pdata =
> +			container_of(gpio, struct smsc95xx_priv, gpio);

Likewise.

> +	int ret = -1;
> +	u32 val, reg;
> +
> +	struct smsc95xx_priv *pdata =
> +			container_of(gpio, struct smsc95xx_priv, gpio);
> +	reg = smsc95xx_gpio_get_register(offset);

Likewise.

> +	int ret = -1;
> +	u32 val, reg;
> +
> +	struct smsc95xx_priv *pdata =
> +			container_of(gpio, struct smsc95xx_priv, gpio);

Likewise.


> +	int ret = -1;
> +	u32 val, reg;
> +
> +	struct smsc95xx_priv *pdata =
> +			container_of(gpio, struct smsc95xx_priv, gpio);
> +	reg = smsc95xx_gpio_get_register(offset);

Likewise and do put an empty line after the variable declarations
and before the first real C statement.

> @@ -1153,17 +1404,32 @@ static int smsc95xx_bind(struct usbnet *dev, struct usb_interface *intf)
>  	dev->net->flags |= IFF_MULTICAST;
>  	dev->net->hard_header_len += SMSC95XX_TX_OVERHEAD_CSUM;
>  	dev->hard_mtu = dev->net->mtu + dev->net->hard_header_len;
> +
> +	ret = smsc95xx_register_gpio(dev);
> +	if (ret < 0)
> +		return ret;
> +
>  	return 0;
>  }

I think you will leak dev->data[0] if you exit here with an error and
without explicitly freeing dev->data[0] like the unbind method does.
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
