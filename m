From: Pavel Machek <pavel@ucw.cz>
Subject: Re: wl1251 & mac address & calibration data
Date: Wed, 23 Nov 2016 23:23:35 +0100
Message-ID: <20161123222335.GA4788@amd>
References: <201611111820.52072@pali>
 <20161122153141.GT13735@pali>
 <CA+BoTQkSOJ85PiT=pjmH234sviCj-LVWWM=64KbCe4AG9CMNUg@mail.gmail.com>
 <201611221805.13606@pali>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
        protocol="application/pgp-signature"; boundary="ZGiS0Q5IWpPtfppv"
Cc: Michal Kazior <michal.kazior@tieto.com>,
        Kalle Valo <kvalo@codeaurora.org>,
        Ivaylo Dimitrov <ivo.g.dimitrov.75@gmail.com>,
        Sebastian Reichel <sre@kernel.org>,
        Aaro Koskinen <aaro.koskinen@iki.fi>,
        Tony Lindgren <tony@atomide.com>,
        linux-wireless <linux-wireless@vger.kernel.org>,
        Network Development <netdev@vger.kernel.org>,
        linux-kernel@vger.kernel.org
To: Pali =?iso-8859-1?Q?Roh=E1r?= <pali.rohar@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <201611221805.13606@pali>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--ZGiS0Q5IWpPtfppv
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi!

> > > As wl1251.ko does not accept mac_address as module parameter, such
> > > modprobe hook does not help -- as there is absolutely no way from
> > > userspace to set or change (permanent) mac address.
> >=20
> > Quoting modprobe.d manual:
> > >       install modulename command...
> > >      =20
> > >           This command instructs modprobe to run your
> > >           command instead of inserting the module in the
> > >           kernel as normal. The command can be any shell
> > >           command: this allows you to do any kind of
> > >           complex processing you might wish. [...]
>=20
> I know. But this do not allow me to send mac address to kernel -- as=20
> kernel does not support such command yet (reason for my first
> question).

Plus, this does not really work for cases where wl1251 is not a
module.

> > You can hook up a script that cooks up wl1251-nvs.bin (caldata,
> > macaddr) and then insmod the actual wl1251.ko module. Or you can just
> > cook up the nvs on first device boot and store it in /lib/firmware
> > (possibly overwriting the "generic" wl1251 from linux-firmware).
>=20
> This is what I would like to prevent -- overwriting (possible readonly)=
=20
> system files with some device specific. It is really bad idea!

Agreed.

"ifconfig hw ether XX" normally sets the address. I guess that's
ioctl? And I guess we should use similar mechanism for permanent
address.

Best regards,

									Pavel
--=20
(english) http://www.livejournal.com/~pavelmachek
(cesky, pictures) http://atrey.karlin.mff.cuni.cz/~pavel/picture/horses/blo=
g.html

--ZGiS0Q5IWpPtfppv
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iEYEARECAAYFAlg2FucACgkQMOfwapXb+vIcGACgjENv4xLN8EJGdCGycJou4Gzd
U6QAn0XrkW6/p2NecQtidQwEX5Rs0lYL
=o1Xt
-----END PGP SIGNATURE-----

--ZGiS0Q5IWpPtfppv--
