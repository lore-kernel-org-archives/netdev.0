From: Steve Glendinning <steve-nksJyM/082jR7s880joybQ@public.gmane.org>
Subject: Re: [PATCH 1/2] smsc75xx: refactor entering suspend modes
Date: Wed, 28 Nov 2012 08:34:59 +0000
Message-ID: <CAKh2mn7+0itrJNxmh6Wv9njGaNOY48N_zfJm6=gTeMoF2VzW4g@mail.gmail.com>
References: <87y5hm9ap5.fsf@nemi.mork.no>
	<Pine.LNX.4.44L0.1211271443150.1489-100000@iolanthe.rowland.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: =?ISO-8859-1?Q?Bj=F8rn_Mork?= <bjorn-yOkvZcmFvRU@public.gmane.org>,
	netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Alan Stern <stern-nwvwT67g6+6dFdvTe/nMLpVzexx5G7lz@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <Pine.LNX.4.44L0.1211271443150.1489-100000-IYeN2dnnYyZXsRXLowluHWD2FQJk+8+b@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi Alan,

>> udev->do_remote_wakeup is set in choose_wakeup() in
>> drivers/usb/core/driver.c.  AFAICS it is always set as long as
>> device_may_wakeup(&udev->dev) is true.
>
> That's right.  But is device_may_wakeup(&udev->dev) true?
>
> By default it wouldn't be.  The normal way to set it is for the user or
> a program to do:
>
>         echo enabled >/sys/bus/usb/devices/.../power/wakeup
>
> Of course, a driver could disregard the user's choice and set the flag
> by itself.

If I set that from userspace the system is able to resume, but I can't
work out how to successfully set this from the driver.  I believe the
driver should be overriding this as if the user has asked for the
device to wake on lan they're expecting this to resume the system.

I've tried placing various combinations of device_set_wakeup_capable
and device_set_wakeup_enable in different places (bind, suspend), but
it still doesn't allow the device to resume from suspend.  How should
I do this?
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
