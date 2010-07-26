From: Elly Jones <ellyjones-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Subject: Re: [patch] usbnet: fix 100% CPU use on suspended device
Date: Mon, 26 Jul 2010 09:26:59 -0400
Message-ID: <AANLkTik=b3ps_iMOC=mjDs2quLwBPUKbiqn0nKU3EbB1@mail.gmail.com>
References: <AANLkTi=pSkOuiFGAK4inPdm-KbLuVrz51e2T6eV51ts0@mail.gmail.com>
	<20100725.215739.183063953.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20100725.215739.183063953.davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Mon, Jul 26, 2010 at 12:57 AM, David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org> wr=
ote:
> From: Elly Jones <ellyjones-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
> Date: Wed, 21 Jul 2010 14:51:48 -0400
>
>> Subject: [patch] usbnet: fix 100% CPU use on suspended device
>> From: Elly Jones <ellyjones-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
>>
>> This patch causes the usbnet module not to attempt to submit URBs to=
 the device
>> if the device is not ready to accept them. This fixes a misbehavior =
trigged by
>> the Qualcomm Gobi driver (released under GPL through their Code Auro=
ra
>> initiative) which causes the usbnet core to consume 100% of CPU atte=
mpting and
>> failing to submit URBs. This patch is against Linus's 2.6 repo commi=
t
>> a9f7f2e74ae0e6a801a2433dc8e9124d73da0cb4.
>> Signed-off-by: Elizabeth Jones <ellyjones-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
>
> If the Qualcomm Gobi driver is the only one where this happens, maybe=
 the
> real problem is in that driver.

The member in question (dev->udev->can_submit) is documented as 'URBs
may be submitted'. The existing code doesn't honor that flag. It is
somewhat puzzling that (so far) only the Gobi driver seems to use that
flag, but I don't think the bug lies in their driver here.

> I'm not applying this until a USB person looks more deeply into this.

Alright. Can you suggest a particular USB person to bother?

>> ---
>> diff --git a/drivers/net/usb/usbnet.c b/drivers/net/usb/usbnet.c
>> index 81c76ad..df7e72e 100644
>> --- a/drivers/net/usb/usbnet.c
>> +++ b/drivers/net/usb/usbnet.c
>> @@ -1172,6 +1172,7 @@ static void usbnet_bh (unsigned long param)
>> =A0 =A0 =A0 // or are we maybe short a few urbs?
>> =A0 =A0 =A0 } else if (netif_running (dev->net) &&
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0netif_device_present (dev->net) &=
&
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0dev->udev->can_submit &&
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0!timer_pending (&dev->delay) &&
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0!test_bit (EVENT_RX_HALT, &dev->f=
lags)) {
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 int =A0 =A0 temp =3D dev->rxq.qlen;
>> --
>

-- Elly
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
