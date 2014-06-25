From: Evgeny Boger <boger-hVk9LwgH4SrGCOCKMErq+g@public.gmane.org>
Subject: Re: [PATCH v2] Add support for GPIOs for SMSC LAN95xx chips.
Date: Wed, 25 Jun 2014 21:54:00 +0400
Message-ID: <53AB0CB8.2090007@contactless.ru>
References: <20140513.180121.1755290421111591028.davem@davemloft.net>	<1403671574-16857-1-git-send-email-boger@contactless.ru> <CAN_we7MbMywYzysn_Q_iRAOZZuE+KU_jDJxMW-Qz0KK0RHwSRQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Steve Glendinning <steve.glendinning-nksJyM/082jR7s880joybQ@public.gmane.org>,
	David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	USB list <linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Daniele Forsi <dforsi-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <CAN_we7MbMywYzysn_Q_iRAOZZuE+KU_jDJxMW-Qz0KK0RHwSRQ-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

06/25/2014 02:34 PM, Daniele Forsi =D0=BF=D0=B8=D1=88=D0=B5=D1=82:
> 2014-06-25 6:46 GMT+02:00 Evgeny Boger:
>
>> There might be 11 GPIOs in total.
> do you mean "12 GPIOs"? You say later they are 0-based and the last o=
ne is "11"


>
>> Last three GPIOs  (offsets 8-11, 0-based) are shared with FDX, LNKA,=
 SPD
>> LEDs respectively.
> so you mean the last "four"?
> and you may want to remove the extra space before the open parenthesi=
s

My mistake. 11 GPIOs in total, eight of them (0-7) are normal GPIOs,=20
while three other are multiplexed with link activity LEDs.
So it should read like "offset 8-10, 0-based".

Actually, the numbering scheme according to datasheets differs a bit=20
between LAN9500 and LAN951x:

=46or LAN951x:
GPIOs with offsets 0-7 are named "GPIO3" - "GPIO7", offsets 8-10 are fo=
r=20
"GPIO0" - "GPIO2" (these three are multiplexed with nFDX_LED, nLNKA_LED=
,=20
nSPD_LED).

=46or LAN9500:
The datasheet name is the same as the corresponding offset, i.e. offset=
s=20
0-10 are for "GPIO0"-"GPIO10".

What do you think, shoud I write some note about this numbering scheme?=
=20
If so, where it would be better to place such a note?






>
> also there are still several unneeded newlines
>
>> diff --git a/drivers/net/usb/smsc95xx.c b/drivers/net/usb/smsc95xx.c
>> @@ -68,6 +70,15 @@ struct smsc95xx_priv {
>>          spinlock_t mac_cr_lock;
>>          u8 features;
>>          u8 suspend_flags;
>> +
>> +       struct usbnet *dev;
>> +static int smsc95xx_gpio_request(struct gpio_chip *gpio, unsigned o=
ffset)
>> +       mutex_unlock(&pdata->gpio_lock);
>> +
>> +
>> +       return (ret < 0) ? ret : 0;
>> +}
>> +
>> +static void smsc95xx_gpio_free(struct gpio_chip *gpio, unsigned off=
set)
>> +       if (ret < 0)
>> +               netif_err(pdata->dev, ifdown, pdata->dev->net,
>> +                       "error freeing gpio %d\n", offset);
>> +
>> +}
> and in other places
>
>> +static void smsc95xx_gpio_set(struct gpio_chip *gpio, unsigned offs=
et,
>> +                               int value)
>> +{
>> +       if (ret < 0) {
>> +               netif_err(pdata->dev, ifdown, pdata->dev->net,
>> +                       "error writing gpio %d=3D%d\n", offset, valu=
e);
>> +               return;
>> +       }
>> +}
> no need to put a "return" there at he end of the function (if it's
> defensive programming then you didn't put return in similar code in a
> previous function)
>


--=20
=D0=A1 =D1=83=D0=B2=D0=B0=D0=B6=D0=B5=D0=BD=D0=B8=D0=B5=D0=BC,
     =D0=95=D0=B2=D0=B3=D0=B5=D0=BD=D0=B8=D0=B9 =D0=91=D0=BE=D0=B3=D0=B5=
=D1=80
     =D0=9E=D0=9E=D0=9E =D0=91=D0=B5=D1=81=D0=BA=D0=BE=D0=BD=D1=82=D0=B0=
=D0=BA=D1=82=D0=BD=D1=8B=D0=B5 =D1=83=D1=81=D1=82=D1=80=D0=BE=D0=B9=D1=81=
=D1=82=D0=B2=D0=B0
     http://contactless.ru
     +7 (919) 965 88 36

--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
