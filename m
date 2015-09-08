From: Corinna Vinschen <vinschen@redhat.com>
Subject: Re: [PATCH net 3/3] r8169: increase the lifespan of the hardware
 counters dump area.
Date: Tue, 8 Sep 2015 10:09:00 +0200
Message-ID: <20150908080900.GG20288@calimero.vinschen.de>
References: <cover.1441454454.git.romieu@fr.zoreil.com>
 <fb3db9039225ed3a030e779565b8e11f99fc8ae2.1441454454.git.romieu@fr.zoreil.com>
 <20150906103732.GF30539@calimero.vinschen.de>
 <20150907144412.GA26524@calimero.vinschen.de>
 <20150907215251.GA4897@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
	protocol="application/pgp-signature"; boundary="Mjqg7Yu+0hL22rav"
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
	pomidorabelisima@gmail.com
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-n.franken.de ([193.175.24.27]:51352 "EHLO
	mail-n.franken.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752005AbbIHIJC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Sep 2015 04:09:02 -0400
Content-Disposition: inline
In-Reply-To: <20150907215251.GA4897@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--Mjqg7Yu+0hL22rav
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Sep  7 23:52, Francois Romieu wrote:
> Corinna Vinschen <vinschen@redhat.com> :
> [...]
> > I have a bit of a problem with this patch.  It crashes when loading the
> > driver manually w/ modprobe.  For some reason dev_get_stats is called
> > during rtl_init_one and at that time the counters pointer is NULL, so
> > the kernel gets a SEGV.
> >
> >  After I worked around that I got a SEGV in
> > rtl_remove_one, which I still have to find out why.  I didn't test with
> > the latest kernel, though, so I still have to check if that's the reason
> > for the crashes.  That takes a bit longer, I just wanted to let you
> > know.
>=20
> Call me stupid: I forgot that it's perfectly fine to request the stats
> of a down interface. :o/
>=20
> Updated patch is on the way.
>=20
> > There's also a problem with rtl8169_cmd_counters:  It always calls
> > rtl_udelay_loop_wait_low w/ rtl_reset_counters_cond, even when called
> > from rtl8169_update_counters, where it should call
> > rtl_udelay_loop_wait_low w/ rtl_counters_cond to check for the
> > CounterDump flag, rather than for the CounterReset flag.
> >=20
> > For now I applied the below patch, but I think it's a bit ugly to
> > conditionalize the rtl_cond struct by the incoming flag value.
>=20
> <captain obvious>
>=20
> Let's check both at once:
>=20
> 	return RTL_R32(CounterAddrLow) & (CounterDump | CounterReset);

If you're sure that's valid, then why not?  It's certainly cleaner
code.


Corinna

--Mjqg7Yu+0hL22rav
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBCAAGBQJV7pebAAoJEPU2Bp2uRE+gAPwQAJU7GzjijBUqwbcGu3NfhNgb
LJT6LGtF1kKrp2l8jwcKZ/IQU0OFiWy9Ozx8o0IMesa63YOBVuE36OnHZAABuCYr
RyKYWmbEH3+vEdLbwrO9CTK1wJ6704EMyyGKMuxlTsOBBrSTv1y/P6wyy+KzUocd
ALp00Y/HWN30zUuF/D9rfHEV1hJ776QVxj4t0he2BShiH8Fz0GxyJPHXA65cafiM
R1ytsntNcnzJXVZ3fj6r5WgT3DX1o23rKFIdZV+32fN8lGnKy/Bcte2s5uJHmYoD
otIss5q3YG75u69Nu+aq+kSx7KmggNZPHQPqJFNHJrrfXOzcX9JH2ABjVK7p7VXW
28jkG0nurCy5V2i0Xdszk1AUN69PAFHmkX3MTk0mFE8kKXwTGjqGKT7u1PlSc9qX
rytrdj4+FmfibrlbpfCjwhjTwDgsEhmIJOqXt4wMGT+Eq1wfv/vUDsRoSQ+Dg2EX
dJ7ANYK1068E3Q4ZnXtpeB9oGG4b3Vh4o+OmRaC5/mc6+Mb0Ksg7PGnz6Vjl/mIS
6rqPq0bDO30nlE7GJ+o5YXumllY2IJelHlO2NblhF4g6ZCF6hP2XgoX1KT+Fx+9Q
btR4oeDo1MynQkr7jlez2nzetefWCWdqTgds+oudys+xMoT5BekCDydN/OZnD1WG
KYFOGwQ61nIW4f4cPIqB
=l0JL
-----END PGP SIGNATURE-----

--Mjqg7Yu+0hL22rav--
