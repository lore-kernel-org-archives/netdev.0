From: Ming Lei <tom.leiming-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH] usbnet: Activate halt interrupt endpoint before re-submit URB
Date: Tue, 19 Jun 2012 23:50:14 +0800
Message-ID: <CACVXFVML6Qd-Js9ekJhsXA9YW=LTXdcmC-874gzHE=4yTnVzdA@mail.gmail.com>
References: <CA+v9cxad+THL8u7tr_ubD7H7o+6x+qTOXOgowmPDnWUxa8aJtQ@mail.gmail.com>
	<201206180923.36091.oneukum@suse.de>
	<CA+v9cxZG6b1O7kOQpeTELtv0vHzqy-8NH84boMpim0BM+tp1eQ@mail.gmail.com>
	<201206181851.49765.oneukum@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Huajun Li <huajun.li.lee-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, stern-nwvwT67g6+6dFdvTe/nMLpVzexx5G7lz@public.gmane.org,
	linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Oliver Neukum <oneukum-l3A5Bk7waGM@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <201206181851.49765.oneukum-l3A5Bk7waGM@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Tue, Jun 19, 2012 at 12:51 AM, Oliver Neukum <oneukum-l3A5Bk7waGM@public.gmane.org> wrote:

>
> Then I am inclined to say that this is not fully thought through
> If the endpoint stalls, the device has detected an error.
> We have no idea how to generically handle this error.
> We might come into a vicious circle.

Why does it come into a vicious circle? If the interrupt endpoint is
HALTed, the clear halt event is scheduled to call usb_clear_halt(int pipe),
and if it returns successfully, the pipe shouldn't be halted any more,
so the later usb_submit_urb() should be OK on the interrupt endpoint.

The similar handling policy is taken for RX/TX endpoints in case they
are halted.

> Could you add a sanity limit for the
> amount of halts we clear?

Looks it is not needed, at least clearing HALT on Rx/Tx endpoints
works well without the limit.

Thanks,
-- 
Ming Lei
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
