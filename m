From: Alan Stern <stern-nwvwT67g6+6dFdvTe/nMLpVzexx5G7lz@public.gmane.org>
Subject: Re: [PATCH v2 1/4] USB: introduce usb_device_no_sg_constraint()
 helper
Date: Mon, 5 Aug 2013 10:07:34 -0400 (EDT)
Message-ID: <Pine.LNX.4.44L0.1308051005150.1239-100000@iolanthe.rowland.org>
References: <1375692423-9497-2-git-send-email-ming.lei@canonical.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Greg Kroah-Hartman <gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org>,
	Oliver Neukum <oneukum-l3A5Bk7waGM@public.gmane.org>,
	Sarah Sharp <sarah.a.sharp-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>,
	<netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Ming Lei <ming.lei-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1375692423-9497-2-git-send-email-ming.lei-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Mon, 5 Aug 2013, Ming Lei wrote:

> Some host controllers(such as xHCI) can support building
> packet from discontinuous buffers, so introduce one flag
> and helper for this kind of host controllers, then the
> feature can help some applications(such as usbnet) by
> supporting arbitrary length of sg buffers.

> +static inline bool usb_device_no_sg_constraint(struct usb_device *udev)
> +{
> +	if (udev && udev->bus && udev->bus->no_sg_constraint)
> +		return true;
> +	else
> +		return false;
> +}

A more elegant implementation would be:

	return udev && udev->bus && udev->bus->no_sg_constraint;

I doubt it will make any difference to the object code, though.  Apart
from that, this looks fine.

Acked-by: Alan Stern <stern-nwvwT67g6+6dFdvTe/nMLpVzexx5G7lz@public.gmane.org>

--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
