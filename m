From: Oliver Neukum <oneukum-l3A5Bk7waGM@public.gmane.org>
Subject: Re: use-after-free in usbnet
Date: Thu, 22 Mar 2012 10:08:46 +0100
Message-ID: <201203221008.46882.oneukum@suse.de>
References: <CACVXFVP+U1k7JFTmbabF-k8F3bO9zc58c3tLG6=1nQPcrR9p1g@mail.gmail.com> <Pine.LNX.4.44L0.1203211201560.1369-100000@iolanthe.rowland.org> <CACVXFVOVjnWjqpKxbU98DAyUC_OSb8ZL-3WcyYuFXgPJn5UyuA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Alan Stern <stern-nwvwT67g6+6dFdvTe/nMLpVzexx5G7lz@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Fedora Kernel Team <kernel-team-rxtnV0ftBwyoClj4AeEUq9i2O/JbrIOy@public.gmane.org>,
	Dave Jones <davej-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
To: Ming Lei <tom.leiming-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <CACVXFVOVjnWjqpKxbU98DAyUC_OSb8ZL-3WcyYuFXgPJn5UyuA-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Am Mittwoch, 21. M=E4rz 2012, 17:22:59 schrieb Ming Lei:

> -
> +               usb_get_urb(urb);
>                 spin_unlock_irqrestore(&q->lock, flags);
>                 // during some PM-driven resume scenarios,
>                 // these (async) unlinks complete immediately
> @@ -597,6 +597,7 @@ static int unlink_urbs (struct usbnet *dev, struc=
t
> sk_buff_head *q)
>                         netdev_dbg(dev->net, "unlink urb err, %d\n", =
retval);
>                 else
>                         count++;
> +               usb_put_urb(urb);


Hi,

this looks good, but could you add a comment explaining the reason for
taking a reference?

	Regards
		Oliver
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
