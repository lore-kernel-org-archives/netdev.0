From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [PATCH] net: sched: dev_deactivate_many(): use msleep(1)
 instead of yield() to wait for outstanding qdisc_run calls
Date: Sun, 09 Mar 2014 19:09:20 +0000
Message-ID: <1394392160.15968.13.camel@deadeye.wl.decadent.org.uk>
References: <1393976987-23555-1-git-send-email-mkl@pengutronix.de>
	 <20140306.160622.59358366688518505.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-HLK62Vvp03QgiYslYuPS"
Cc: mkl@pengutronix.de, linux-rt-users@vger.kernel.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	kernel@pengutronix.de
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20140306.160622.59358366688518505.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-HLK62Vvp03QgiYslYuPS
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Thu, 2014-03-06 at 16:06 -0500, David Miller wrote:
> From: Marc Kleine-Budde <mkl@pengutronix.de>
> Date: Wed,  5 Mar 2014 00:49:47 +0100
>=20
> > @@ -839,7 +839,7 @@ void dev_deactivate_many(struct list_head *head)
> >       /* Wait for outstanding qdisc_run calls. */
> >       list_for_each_entry(dev, head, unreg_list)
> >               while (some_qdisc_is_busy(dev))
> > -                     yield();
> > +                     msleep(1)
> >  }
>=20
> I don't understand this.
>=20
> yield() should really _mean_ yield.
>=20
> The intent of a yield() call, like this one here, is unambiguously
> that the current thread cannot do anything until some other thread
> gets onto the cpu and makes forward progress.
>
> Therefore it should allow lower priority threads to run, not just
> equal or higher priority ones.

Until when?

yield() is not a sensible operation in a preemptive multitasking system,
regardless of RT.

Ben.

--=20
Ben Hutchings
I say we take off; nuke the site from orbit.  It's the only way to be sure.

--=-HLK62Vvp03QgiYslYuPS
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIVAwUAUxy8YOe/yOyVhhEJAQrJHw//feVCWU5pdCrAekF77WydJLMswCI4BugN
ah3nj6js5/ajHTmmyZl7sFtWrhCmbbsqzOYSWHkcCANiPbvKFAIHexKo/7B9FXTV
xBSIjsFvRY4iTdzJyprksEMCXuVj/kplcCFU8191bWlvzCOAPbDhF7karD2HjbLd
QV2yjzTDOpAmMis/IhKg8uFEczq5L2gIFB/IIVyLwoLPVyn9QyexcKKo4qe5RKpB
ER/BItPozmZzbHRPmhIXAjyr/ky/Jz8de9sM85Z8wh1HTicPGL/FHnWj2MR+NPPx
H8BiKg1NXEXyKvQsRJEY9r2XTeXnWIhclBTUiLNhRvTAyuz/U8eLDeXNIPnvC0NS
WiyQLH9yseJ3R2UcSMc3tROnFl+fJ6z+Im6LDyiN+GSgi1BI9mz3XSoS5fvL7o3c
HBuaR1PJShQvvt5zDay9hT30hhghbL/BTW1Oirxv/KbDX290uUkkyLaAOeGaQajr
uClALOSrgFGKd6SE/+MFzpG5Hh0vLnr6bPnFrLYv0Ww5T1G+byoOWELE6ZkFVcZj
90KjkTr0iRSs1IJD8mCAh/HSEYLsTOKVe6kYxa1r2+LVIixYEcOw5bKVImAfHvgz
UY5z8BsDBjYjz2yzNq73bEnr2M3kwCcBRCBNbLS645TkOWJnz+pDrhbRhseX9VWe
iHvuoyHWDrU=
=A78/
-----END PGP SIGNATURE-----

--=-HLK62Vvp03QgiYslYuPS--
