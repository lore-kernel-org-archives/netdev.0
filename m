From: Alan Stern <stern-nwvwT67g6+6dFdvTe/nMLpVzexx5G7lz@public.gmane.org>
Subject: Re: a new problem with the hso driver
Date: Thu, 11 Sep 2008 18:39:47 -0400 (EDT)
Message-ID: <Pine.LNX.4.44L0.0809111835350.3949-100000@iolanthe.rowland.org>
References: <48C93F75.4000703@option.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Linux USB kernel mailing list <linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Linux netdev Mailing list <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Greg Kroah-Hartman <gregkh-l3A5Bk7waGM@public.gmane.org>,
	Andrew Bird <ajb-5+cxppFmGx6/3pe1ocb+s/XRex20P6io@public.gmane.org>
To: Denis Joseph Barrow <D.Barow-x9gZzRpC1QbQT0dZR+AlfA@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <48C93F75.4000703-x9gZzRpC1QbQT0dZR+AlfA@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Thu, 11 Sep 2008, Denis Joseph Barrow wrote:

> Hi Greg/Andrew,
> I've a minor problem.
> If you put the hso driver into powersave mode
> by going into /sysfs
> 
> cd /sys/
>  find . -name idVendor | xargs -n 1 | grep -H af0
>  cd ./devices/pci0000:00/0000:00:1d.7/usb5/5-4/
>  or wherever the idVendor is at.
>  cd power/
> echo auto > level
> 
> Then let the driver sleep for about 2 minutes.a
> 
> It can't be woken up, it appears that the 
> usb layer is looking for a reset_resume
> function to be implemented. 
> 
> We get the following messages from the kernel
> [12518.790072] hso 2-2:1.0: no reset_resume for driver hso?
> [12518.790081] hso 2-2:1.1: no reset_resume for driver hso?
> [12518.790085] hso 2-2:1.2: no reset_resume for driver hso?
> 
> How do I implement a reset resume function?
> could somebody tell me & put in a few comments in include/linux/usb.h

See Documentation/usb/power-management.txt.

> Our customer says the device has gone into an S3 sleep
> whatever the difference between this & the reduced power mode
> it goes into after 2 seconds when it calls hso_suspend I don't know.
> 
> On a slightly related issue
> we get an error -22 ie -EINVAL from usb_submit_urb
> this though I haven't investigated properly appears to happen when the device is suspended
> but appears to have no adverse effect on the driver
> it still seems to work, I haven't really investigated this, whats happening?
> but would greatly appreciate being pointed in the right direction.

-EINVAL can indicate several possible errors, but as far as I remember, 
none of them are associated with the device being suspended.  If you 
try to submit an URB to a suspended device, you'll get -EHOSTUNREACH.

Alan Stern

--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
