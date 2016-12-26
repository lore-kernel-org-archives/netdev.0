From: Pavel Machek <pavel@ucw.cz>
Subject: Re: [PATCH 2/6] wl1251: Use request_firmware_prefer_user() for
 loading NVS calibration data
Date: Mon, 26 Dec 2016 16:43:53 +0100
Message-ID: <20161226154353.GA27087@amd>
References: <1482598381-16513-1-git-send-email-pali.rohar@gmail.com>
 <1482598381-16513-3-git-send-email-pali.rohar@gmail.com>
 <e728586e-80bf-c9e0-0063-71da4c4aba85@broadcom.com>
 <201612252146.44496@pali>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
        protocol="application/pgp-signature"; boundary="y0ulUmNC+osPPQO6"
Cc: Arend Van Spriel <arend.vanspriel@broadcom.com>,
        Ming Lei <ming.lei@canonical.com>,
        "Luis R. Rodriguez" <mcgrof@kernel.org>,
        Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
        Kalle Valo <kvalo@codeaurora.org>,
        David Gnedt <david.gnedt@davizone.at>,
        Michal Kazior <michal.kazior@tieto.com>,
        Daniel Wagner <wagi@monom.org>,
        Tony Lindgren <tony@atomide.com>,
        Sebastian Reichel <sre@kernel.org>,
        Ivaylo Dimitrov <ivo.g.dimitrov.75@gmail.com>,
        Aaro Koskinen <aaro.koskinen@iki.fi>,
        Grazvydas Ignotas <notasas@gmail.com>,
        linux-kernel@vger.kernel.org, linux-wireless@vger.kernel.org,
        netdev@vger.kernel.org
To: Pali =?iso-8859-1?Q?Roh=E1r?= <pali.rohar@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <201612252146.44496@pali>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--y0ulUmNC+osPPQO6
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi!

> > > NVS calibration data for wl1251 are model specific. Every one
> > > device with wl1251 chip has different and calibrated in factory.
> > >=20
> > > Not all wl1251 chips have own EEPROM where are calibration data
> > > stored. And in that case there is no "standard" place. Every
> > > device has stored them on different place (some in rootfs file,
> > > some in dedicated nand partition, some in another proprietary
> > > structure).
> > >=20
> > > Kernel wl1251 driver cannot support every one different storage
> > > decided by device manufacture so it will use
> > > request_firmware_prefer_user() call for loading NVS calibration
> > > data and userspace helper will be responsible to prepare correct
> > > data.
> >=20
> > Responding to this patch as it provides a lot of context to discuss.
> > As you might have gathered from earlier discussions I am not a fan
> > of using user-space helper. I can agree that the kernel driver,
> > wl1251 in this case, should be agnostic to platform specific details
> > regarding storage solutions and the firmware api should hide that.
> > However, it seems your only solution is adding user-space to the mix
> > and changing the api towards that. Can we solve it without
> > user-space help?
>=20
> Without userspace helper it means that userspace helper code must be=20
> integrated into kernel.
>=20
> So what is userspace helper doing?
>=20
> 1) Read MAC address from CAL
> 2) Read NVS data from CAL
> 3) Modify MAC address in memory NVS data (new for this patch series)
> 4) Modify in memory NVS data if we in FCC country
>=20
> Checking for country is done via dbus call to either Maemo cellular=20
> daemon or alternatively via REGDOMAIN in /etc/default/crda. I have plan=
=20
> to use ofono (instead Maemo cellular daemon) too...
>=20
> Currently we are using closed Nokia proprietary CAL library.
>=20
> Steps 1) and 2) needs closed library, step 4) needs dbus call.

I guess pointer to the source code implementing this would be welcome.

> > But on other devices that use wl1251, but for instance have no
> > userspace helper the request to userspace will fail (after 60 sec?)
> > and try VFS after that. Maybe not so nice.
>=20
> Currently support for those devices is broken (like for N900) as without=
=20
> proper NVS data they do not work correctly...

Is it expected to work at all, perhaps with degraded performance /
range? Because it seems to work for me.

Thanks,
									Pavel
--=20
(english) http://www.livejournal.com/~pavelmachek
(cesky, pictures) http://atrey.karlin.mff.cuni.cz/~pavel/picture/horses/blo=
g.html

--y0ulUmNC+osPPQO6
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iEYEARECAAYFAlhhOrkACgkQMOfwapXb+vIJqgCgw0tnfrODGbsPnBpMzA4rxgtr
99sAn0v9SsNhaOQAYNu3EQECGsCdYzOk
=pwaf
-----END PGP SIGNATURE-----

--y0ulUmNC+osPPQO6--
