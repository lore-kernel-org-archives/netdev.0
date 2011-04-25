From: Paul Stewart <pstew-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>
Subject: Re: [PATCHv5] usbnet: Resubmit interrupt URB once if halted
Date: Mon, 25 Apr 2011 11:41:29 -0700
Message-ID: <BANLkTim1Np+RT-js-HPFvBA5yM=EFoPs6w@mail.gmail.com>
References: <20110422152451.3C5A9202ED@glenhelen.mtv.corp.google.com>
	<Pine.LNX.4.44L0.1104221129530.1877-100000@iolanthe.rowland.org>
	<BANLkTi=xBJuSFNPO3hkKu+N2tNspw=FZNQ@mail.gmail.com>
	<201104240836.47491.oliver@neukum.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Alan Stern <stern-nwvwT67g6+6dFdvTe/nMLpVzexx5G7lz@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org,
	bhutchings-s/n/eUQHGBpZroRs9YW3xA@public.gmane.org
To: Oliver Neukum <oliver-GvhC2dPhHPQdnm+yROfE0A@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <201104240836.47491.oliver-GvhC2dPhHPQdnm+yROfE0A@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Sat, Apr 23, 2011 at 11:36 PM, Oliver Neukum <oliver-GvhC2dPhHPQdnm+yROfE0A@public.gmane.org> wro=
te:
> Am Freitag, 22. April 2011, 17:59:15 schrieb Paul Stewart:
>> >
>> >> =A0 =A0 =A0 free_netdev(net);
>> >> =A0 =A0 =A0 usb_put_dev (xdev);
>> >> =A0}
>> >> @@ -1285,6 +1291,10 @@ int usbnet_suspend (struct usb_interface *=
intf, pm_message_t message)
>> >> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* wake the device
>> >> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0*/
>> >> =A0 =A0 =A0 =A0 =A0 =A0 =A0 netif_device_attach (dev->net);
>> >> +
>> >> + =A0 =A0 =A0 =A0 =A0 =A0 /* Stop interrupt URBs */
>> >> + =A0 =A0 =A0 =A0 =A0 =A0 if (dev->interrupt)
>> >> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 usb_kill_urb(dev->inter=
rupt);
>> >> =A0 =A0 =A0 }
>> >> =A0 =A0 =A0 return 0;
>> >> =A0}
>> >
>> > There is a subtle question here: When is the best time to kill the
>> > interrupt URB? =A0Without knowing any of the details, I'd guess th=
at the
>> > interrupt URB reports asynchronous events and the driver could run=
 into
>> > trouble if one of those events occurred while everything else was
>> > turned off. =A0This suggests that the interrupt URB should be kill=
ed as
>> > soon as possible rather than as late as possible. =A0But maybe it =
doesn't
>> > matter; it all depends on the design of the driver.
>>
>> I'm not sure I can answer this question either. =A0As it stands, nob=
ody
>> was killing them before. =A0Just trying to make it better.
>
> Hm. Are we looking at the same code?

Perhaps not.  I'm working out of the netdev-2.6 git repository.  Is
this the wrong place?

> usbnet_suspend now has:
>
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0/*
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 * accelerate emptying of the rx and q=
ueues, to avoid
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 * having everything error out.
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 */
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0netif_device_detach (dev->net);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0usbnet_terminate_urbs(dev);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0usb_kill_urb(dev->interrupt);
>
> This suggests that if you want to resubmit the interrupt URB in resum=
e()
> you do it first. Which drivers use the interrupt URB?

The asix driver uses it fo signal link status.

>
> =A0 =A0 =A0 =A0Regards
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0Oliver
>
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
