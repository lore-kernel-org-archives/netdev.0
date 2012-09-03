From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH net] net: usbnet: fix softirq storm on suspend
Date: Mon, 03 Sep 2012 13:49:56 -0400 (EDT)
Message-ID: <20120903.134956.712552224937949341.davem@davemloft.net>
References: <1346660778-24539-1-git-send-email-bjorn@mork.no>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	ming.lei-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org, oneukum-l3A5Bk7waGM@public.gmane.org
To: bjorn-yOkvZcmFvRU@public.gmane.org
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1346660778-24539-1-git-send-email-bjorn-yOkvZcmFvRU@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

=46rom: Bj=F8rn Mork <bjorn-yOkvZcmFvRU@public.gmane.org>
Date: Mon,  3 Sep 2012 10:26:18 +0200

> Suspending an open usbnet device results in constant
> rescheduling of usbnet_bh.
>=20
> commit 65841fd5 "usbnet: handle remote wakeup asap"
> refactored the usbnet_bh code to allow sharing the
> urb allocate and submit code with usbnet_resume. In
> this process, a test for, and immediate return on,
> ENOLINK from rx_submit was unintentionally dropped.
>=20
> The rx queue will not grow if rx_submit fails,
> making usbnet_bh reschedule itself.  This results
> in a softirq storm if the error is persistent.
> rx_submit translates the usb_submit_urb error
> EHOSTUNREACH into ENOLINK, so this is an expected
> and persistent error for a suspended device. The
> old code tested for this condition and avoided
> rescheduling.  Putting this test back.
>=20
> Cc: <stable-u79uwXL29TY76Z2rM5mHXA@public.gmane.org> # v3.5
> Cc: Ming Lei <ming.lei-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
> Cc: Oliver Neukum <oneukum-l3A5Bk7waGM@public.gmane.org>
> Signed-off-by: Bj=F8rn Mork <bjorn-yOkvZcmFvRU@public.gmane.org>

Applied, thanks.
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
