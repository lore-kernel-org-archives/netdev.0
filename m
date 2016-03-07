From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH] cdc_ncm: do not call usbnet_link_change from
 cdc_ncm_bind
Date: Mon, 07 Mar 2016 15:58:37 -0500 (EST)
Message-ID: <20160307.155837.483651456794896295.davem@davemloft.net>
References: <CA+fCnZdurxGBsOrANb_m5BLK1BKzH3J_GmZ=dbH=ABThgFNGxg@mail.gmail.com>
	<20160307.145406.188091362181073486.davem@davemloft.net>
	<87k2le815w.fsf_-_@nemi.mork.no>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: andreyknvl-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org,
	oneukum-IBi9RG/b67k@public.gmane.org, dvyukov-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, glider-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org,
	kcc-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org,
	linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: bjorn-yOkvZcmFvRU@public.gmane.org
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <87k2le815w.fsf_-_-lbf33ChDnrE/G1V5fR+Y7Q@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

=46rom: Bj=F8rn Mork <bjorn-yOkvZcmFvRU@public.gmane.org>
Date: Mon, 7 Mar 2016 21:15:36 +0100

> usbnet_link_change will call schedule_work and should be
> avoided if bind is failing. Otherwise we will end up with
> scheduled work referring to a netdev which has gone away.
>=20
> Instead of making the call conditional, we can just defer
> it to usbnet_probe, using the driver_info flag made for
> this purpose.
>=20
> Fixes: 8a34b0ae8778 ("usbnet: cdc_ncm: apply usbnet_link_change")
> Reported-by: Andrey Konovalov <andreyknvl-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
> Suggested-by: Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
> Signed-off-by: Bj=F8rn Mork <bjorn-yOkvZcmFvRU@public.gmane.org>
=2E..
> Even with Oliver's generic fix we should still fix the inconsistency
> in cdc_ncm, as pointed out by Linus.
>=20
> This is a slightly different approach than the patch proposed by Linu=
s.
> When I started looking at this I couldn't figure out why we were doin=
g
> this differently in this driver from all the other usbnet drivers
> disabling the link at probe time.  So let's make it consistent.  Then=
 at
> least we get consistent bugs :)

=46air enough, applied and queued up for -stable.

Thanks.
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
