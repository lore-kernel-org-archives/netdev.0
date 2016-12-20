From: Pali =?utf-8?q?Roh=C3=A1r?= <pali.rohar@gmail.com>
Subject: Re: wl1251 & mac address & calibration data
Date: Tue, 20 Dec 2016 18:06:30 +0100
Message-ID: <201612201806.30109@pali>
References: <201611111820.52072@pali> <87shpiu8j8.fsf@kamboji.qca.qualcomm.com> <20161220165658.GI4920@atomide.com>
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart1556567.hMCQUv6Cce";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Cc: Kalle Valo <kvalo@codeaurora.org>,
        Arend Van Spriel <arend.vanspriel@broadcom.com>,
        Daniel Wagner <wagi@monom.org>,
        "Luis R. Rodriguez" <mcgrof@kernel.org>,
        Tom Gundersen <teg@jklm.no>,
        Johannes Berg <johannes@sipsolutions.net>,
        Ming Lei <ming.lei@canonical.com>,
        Mimi Zohar <zohar@linux.vnet.ibm.com>,
        Bjorn Andersson <bjorn.andersson@linaro.org>,
        =?utf-8?q?Rafa=C5=82_Mi=C5=82ecki?= <zajec5@gmail.com>,
        Sebastian Reichel <sre@kernel.org>,
        Pavel Machek <pavel@ucw.cz>,
        Michal Kazior <michal.kazior@tieto.com>,
        Ivaylo Dimitrov <ivo.g.dimitrov.75@gmail.com>,
        Aaro Koskinen <aaro.koskinen@iki.fi>,
        "linux-wireless" <linux-wireless@vger.kernel.org>,
        Network Development <netdev@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
To: Tony Lindgren <tony@atomide.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20161220165658.GI4920@atomide.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--nextPart1556567.hMCQUv6Cce
Content-Type: Text/Plain;
  charset="utf-8"
Content-Transfer-Encoding: quoted-printable

On Tuesday 20 December 2016 17:56:58 Tony Lindgren wrote:
> * Kalle Valo <kvalo@codeaurora.org> [161220 03:47]:
> > Arend Van Spriel <arend.vanspriel@broadcom.com> writes:
> > > On 18-12-2016 13:09, Pali Roh=C3=A1r wrote:
> > >> File wl1251-nvs.bin is provided by linux-firmware package and
> > >> contains default data which should be overriden by model
> > >> specific calibrated data.
> > >=20
> > > Ah. Someone thought it was a good idea to provide the "one ring
> > > to rule them all". Nice.
> >=20
> > Yes, that was a bad idea. wl1251-nvs.bin in linux-firmware.git
> > should be renamed to wl1251-nvs.bin.example, or something like
> > that, as it should be only installed to a real system only if
> > there's no real calibration data available (only for developers to
> > use, not real users).
>=20
> Makes sense to me. Note that with the recent changes to wlcore, we
> can now easily provide board specific calibration firmware simply by
> adding a new compatible value. So for n900, we could have something
> like compatible =3D "ti,wl1251-n900" and have it point to n900
> specific calibration file wl1251-nvs-n900.bin. Of course this won't
> help with the mac address, or any of the device specific data..
>=20
> That is assuming the calibration values are the same for each similar
> device and don't have to be generated for each device. And naturally
> wl1251 needs simlar changes done to make use of devices specific
> calibration files.
>=20
> Regards,
>=20
> Tony

As wrote in another thread "wl1251 NVS calibration data format"=20
calibration data for wl1251 (wl1251-nvs.bin) contains also MAC address,=20
which kernel sends to wl1251 chip. Kernel just do not use it.

So... my idea now is:

1) extend request_firmware function family with ability to use userspace=20
helper first and fallback to VFS

2) teach wl1251.ko to parse MAC address from wl1251-nvs.bin and use it=20
(in case it is not empty or 00:00:20:07:03:09 which is in that example=20
linux-firmware package)

3) write Nokia n900 specific userspace helper for providing data when=20
kernel requests wl1251-nvs.bin. So userspace helper reads MAC address=20
and calibration data from CAL, place MAC address into calibration data=20
and send put it into kernel.

Are you OK with this idea?

=2D-=20
Pali Roh=C3=A1r
pali.rohar@gmail.com

--nextPart1556567.hMCQUv6Cce
Content-Type: application/pgp-signature; name=signature.asc 
Content-Description: This is a digitally signed message part.

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iEYEABECAAYFAlhZZRYACgkQi/DJPQPkQ1I1xACfZWpxaKnyNajNikWwd4wuqPDa
5xYAoIGSU/ZHBncjr/KprD/DQ0nIqYQw
=e5J8
-----END PGP SIGNATURE-----

--nextPart1556567.hMCQUv6Cce--
