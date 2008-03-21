From: David Brownell <david-b-yBeKhBN/0LDR7s880joybQ@public.gmane.org>
Subject: Re: use of preempt_count instead of in_atomic() at leds-gpio.c
Date: Fri, 21 Mar 2008 10:04:04 -0700
Message-ID: <200803211004.05106.david-b@pacbell.net>
References: <20080316184349.GA28543@khazad-dum.debian.net> <20080321003604.GC20788@khazad-dum.debian.net> <20080320180802.426ad2d1.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Henrique de Moraes Holschuh <hmh-N3TV7GIv+o9fyO9Q7EP/yw@public.gmane.org>,
	Richard Purdie <rpurdie-Fm38FmjxZ/leoWH0uzbU5w@public.gmane.org>,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Ingo Molnar <mingo-X9Un+BFzKDI@public.gmane.org>,
	Geert Uytterhoeven <geert-Td1EMuHUCqxL1ZNQvxDV9g@public.gmane.org>,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Martin Schwidefsky <schwidefsky-tA70FqPdS9bQT0dZR+AlfA@public.gmane.org>,
	Heiko Carstens <heiko.carstens-tA70FqPdS9bQT0dZR+AlfA@public.gmane.org>,
	linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	video4linux-list-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org,
	Stefan Richter <stefanr-MtYdepGKPcBMYopoZt5u/LNAH6kLmebB@public.gmane.org>,
	lm-sensors-GZX6beZjE8VD60Wz+7aTrA@public.gmane.org
To: Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20080320180802.426ad2d1.akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Content-Disposition: inline
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Thursday 20 March 2008, Andrew Morton wrote:
> ./drivers/net/usb/pegasus.c
>=20
> =A0 Possibly buggy: deadlockable (I assume)

Looks just unecessary to me ... ethtool MII ops get called from
a task context, as I recall, and other drivers just rely on that.

- Dave

=3D=3D=3D=3D=3D=3D=3D=3D=3D CUT HERE
Remove superfluous in-atomic() check; ethtool MII ops are called
from task context.

Signed-off-by: David Brownell <dbrownell-Rn4VEauK+AKRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
---
 drivers/net/usb/pegasus.c |    6 +-----
 1 file changed, 1 insertion(+), 5 deletions(-)

--- g26.orig/drivers/net/usb/pegasus.c	2008-03-21 08:53:28.000000000 -0=
700
+++ g26/drivers/net/usb/pegasus.c	2008-03-21 08:54:07.000000000 -0700
@@ -1128,12 +1128,8 @@ pegasus_get_settings(struct net_device *
 {
 	pegasus_t *pegasus;
=20
-	if (in_atomic())
-		return 0;
-
 	pegasus =3D netdev_priv(dev);
 	mii_ethtool_gset(&pegasus->mii, ecmd);
