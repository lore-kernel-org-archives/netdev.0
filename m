From: Elly Jones <ellyjones-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Subject: Re: [patch] usbnet: fix 100% CPU use on suspended device
Date: Mon, 2 Aug 2010 09:31:33 -0400
Message-ID: <AANLkTi=KbThErL-jXXSVGdkod-p7B7u6eDL5LtnU5SG-@mail.gmail.com>
References: <Pine.LNX.4.44L0.1007261106350.1550-100000@iolanthe.rowland.org>
	<201007261821.15020.oliver@neukum.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Alan Stern <stern-nwvwT67g6+6dFdvTe/nMLpVzexx5G7lz@public.gmane.org>,
	David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	USB list <linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Oliver Neukum <oliver-GvhC2dPhHPQdnm+yROfE0A@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <201007261821.15020.oliver-GvhC2dPhHPQdnm+yROfE0A@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Mon, Jul 26, 2010 at 12:21 PM, Oliver Neukum <oliver-GvhC2dPhHPQdnm+yROfE0A@public.gmane.org> wro=
te:
> Am Montag, 26. Juli 2010, 17:13:23 schrieb Alan Stern:
>> On Mon, 26 Jul 2010, Elly Jones wrote:
>>
>> > > This isn't right. =A0The problem should be fixed some other way.=
 =A0Under
>> > > what circumstances are URBs submitted incorrectly?
>> >
>> > When the device is autosuspended. What is the proper thing for a
>> > device to do here?
>>
>> From looking at the code, it appears that the EVENT_DEV_ASLEEP flag
>> should be tested in usbnet_bh() the way it is in rx_submit(). =A0But=
 I'm
>> not an expert on usbnet; we should ask someone who is, like Oliver.
>
> Sorry, I didn't notice this thread.
>
> The correct way to check for autosuspend in usbnet is to look
> at EVENT_DEV_ASLEEP under txq.lock. That being said, usbnet_bh()
> uses rx_submit() which does the correct check. The bug seems to be
> a lack of error handling in usbnet_bh() regarding the return of rx_su=
bmit()

If rx_submit() fails, should usbnet_bh() just not tasklet_schedule() it=
self?

> =A0 =A0 =A0 =A0Regards
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0Oliver

-- Elly
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
