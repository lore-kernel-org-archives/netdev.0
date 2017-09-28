From: Pavel Machek <pavel@ucw.cz>
Subject: Re: [PATCH RFC 3/5] Add KSZ8795 switch driver
Date: Thu, 28 Sep 2017 20:40:59 +0200
Message-ID: <20170928184059.GA2825@amd>
References: <93AF473E2DA327428DE3D46B72B1E9FD41121A87@CHN-SV-EXMX02.mchp-main.com>
 <20170907223625.GW11248@lunn.ch>
 <93AF473E2DA327428DE3D46B72B1E9FD41124D5A@CHN-SV-EXMX02.mchp-main.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
        protocol="application/pgp-signature"; boundary="HcAYCG3uE/tztfnV"
Cc: andrew@lunn.ch, muvarov@gmail.com, nathan.leigh.conrad@gmail.com,
        vivien.didelot@savoirfairelinux.com, f.fainelli@gmail.com,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        Woojung.Huh@microchip.com
To: Tristram.Ha@microchip.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <93AF473E2DA327428DE3D46B72B1E9FD41124D5A@CHN-SV-EXMX02.mchp-main.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--HcAYCG3uE/tztfnV
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi!

On Mon 2017-09-18 20:27:13, Tristram.Ha@microchip.com wrote:
> > > +/**
> > > + * Some counters do not need to be read too often because they are l=
ess
> > likely
> > > + * to increase much.
> > > + */
> >=20
> > What does comment mean? Are you caching statistics, and updating
> > different values at different rates?
> >=20
>=20
> There are 34 counters.  In normal case using generic bus I/O or PCI to re=
ad them
> is very quick, but the switch is mostly accessed using SPI, or even I2C. =
 As the SPI
> access is very slow and cannot run in interrupt context I keep worrying r=
eading
> the MIB counters in a loop for 5 or more ports will prevent other critica=
l hardware
> access from executing soon enough.  These accesses can be getting 1588 PTP
> timestamps and opening/closing ports.  (RSTP Conformance Test sends test =
traffic
> to port supposed to be closed/opened after receiving specific RSTP
> BPDU.)

Hmm. Ok, interesting.

I wonder how well this is going to work if userspace actively 'does
something' with the switch.

It seems to me that even if your statistics code is careful not to do
'a lot' of accesses at the same time, userspace can use other parts of
the driver to do the same, and thus cause same unwanted effects...
									Pavel
--=20
(english) http://www.livejournal.com/~pavelmachek
(cesky, pictures) http://atrey.karlin.mff.cuni.cz/~pavel/picture/horses/blo=
g.html

--HcAYCG3uE/tztfnV
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iEYEARECAAYFAlnNQjsACgkQMOfwapXb+vI92wCgl4NK+GuwHj0FnR6KTbtyJVCS
gaYAn3L8uXsYRLut1YOsHI1hIiTergZT
=zOqY
-----END PGP SIGNATURE-----

--HcAYCG3uE/tztfnV--
