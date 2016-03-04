From: Andrey Konovalov <andreyknvl-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: Possible double-free in the usbnet driver
Date: Sat, 5 Mar 2016 02:00:29 +0300
Message-ID: <CA+fCnZdjGLT1wkzZXMJ8WHMzmTqcvUVBEN2tZCvwJQfAab8pyg@mail.gmail.com>
References: <CA+55aFxqwjs5gs6Fw2jmTteWM4hZTnr7Ls111ExNTieObLs82Q@mail.gmail.com>
	<CA+fCnZfS51F7WZEM1YTSPDMWSzvBTJWGf5cRWv5LrNCSOf_-qA@mail.gmail.com>
	<1457131342.8935.2.camel@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
	Dmitry Vyukov <dvyukov-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>,
	Alexander Potapenko <glider-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>,
	Kostya Serebryany <kcc-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>,
	Greg Kroah-Hartman <gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org>,
	USB list <linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Network Development <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Oliver Neukum <oneukum-l3A5Bk7waGM@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1457131342.8935.2.camel-l3A5Bk7waGM@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Sat, Mar 5, 2016 at 1:42 AM, Oliver Neukum <oneukum-l3A5Bk7waGM@public.gmane.org> wrote:
> On Sat, 2016-03-05 at 01:26 +0300, Andrey Konovalov wrote:
>> and when I run the vm and connect the device I get:
>>
>> [   23.672662] cdc_ncm 1-1:1.6: bind() failure
>> [   23.673447] usbnet_probe(): freeing netdev: ffff88006ab48000
>> [   23.675822] usbnet_probe(): freeing netdev: ffff88006ab48000
>>
>> So this seems to be a double-free (or at least a double free_netdev()
>> call), but the object gets freed twice from usbnet_probe() and not
>> from usbnet_disconnect(), so you're right that the latter doesn't get
>> called. I'm not sure how usbnet_probe() ends up being called twice.
>
> Do you have lsusb?

You mean inside the vm?
I do.

>
>         Regards
>                 Oliver
>
>
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
