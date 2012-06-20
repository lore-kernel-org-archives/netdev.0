From: Ming Lei <tom.leiming-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH] usbnet: Activate halt interrupt endpoint before re-submit URB
Date: Wed, 20 Jun 2012 18:15:25 +0800
Message-ID: <CACVXFVMy6Hrqgw6rmAXv5YXD86sLF+FUPTRRcXKs40uwN6ioCg@mail.gmail.com>
References: <CA+v9cxad+THL8u7tr_ubD7H7o+6x+qTOXOgowmPDnWUxa8aJtQ@mail.gmail.com>
	<201206201000.21845.oneukum@suse.de>
	<CACVXFVPDV5v3gW5wz44kBsXm0KreHJnkvoxEPZhnLVoaTDw-Yw@mail.gmail.com>
	<201206201058.55519.oneukum@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Huajun Li <huajun.li.lee-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, stern-nwvwT67g6+6dFdvTe/nMLpVzexx5G7lz@public.gmane.org,
	linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Oliver Neukum <oneukum-l3A5Bk7waGM@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <201206201058.55519.oneukum-l3A5Bk7waGM@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Wed, Jun 20, 2012 at 4:58 PM, Oliver Neukum <oneukum-l3A5Bk7waGM@public.gmane.org> wrote:
> Am Mittwoch, 20. Juni 2012, 10:07:55 schrieb Ming Lei:
>> BTW, maybe it is better to add below
>>
>> =A0 =A0 usbnet_defer_kevent(dev, EVENT_STS_HALT);
>>
>> for -EPIPE returned from usb_urb_submit if it will be resent.
>
> Why? If it failed once it'll probably also fail the next time.

-EPIPE just means the endpoint is halted, either from usb_urb_submit
or urb->status, so the HALT should be cleared in the situation.

> In that case we'd need to do something more intrusive
> like resetting the device, but that cannot be done well
> in the generic usbnet part.

IMO, resetting is not needed for -EPIPE, but may be needed for
-EPROTO failure.

Thanks,
--=20
Ming Lei
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
