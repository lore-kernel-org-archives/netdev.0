From: Pali =?utf-8?q?Roh=C3=A1r?= <pali.rohar@gmail.com>
Subject: Re: wl1251 & mac address & calibration data
Date: Sun, 18 Dec 2016 12:04:52 +0100
Message-ID: <201612181204.52928@pali>
References: <201611111820.52072@pali> <201612161140.27241@pali> <68166247-bcd3-f598-7f9e-2139e732233e@broadcom.com>
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart7309338.hiFcT6WmFj";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Cc: Daniel Wagner <wagi@monom.org>,
        "Luis R. Rodriguez" <mcgrof@kernel.org>,
        Tom Gundersen <teg@jklm.no>,
        Johannes Berg <johannes@sipsolutions.net>,
        Ming Lei <ming.lei@canonical.com>,
        Mimi Zohar <zohar@linux.vnet.ibm.com>,
        Bjorn Andersson <bjorn.andersson@linaro.org>,
        =?utf-8?q?Rafa=C5=82_Mi=C5=82ecki?= <zajec5@gmail.com>,
        Kalle Valo <kvalo@codeaurora.org>,
        Sebastian Reichel <sre@kernel.org>,
        Pavel Machek <pavel@ucw.cz>,
        Michal Kazior <michal.kazior@tieto.com>,
        Ivaylo Dimitrov <ivo.g.dimitrov.75@gmail.com>,
        Aaro Koskinen <aaro.koskinen@iki.fi>,
        Tony Lindgren <tony@atomide.com>,
        "linux-wireless" <linux-wireless@vger.kernel.org>,
        Network Development <netdev@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        David Woodh
To: Arend Van Spriel <arend.vanspriel@broadcom.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <68166247-bcd3-f598-7f9e-2139e732233e@broadcom.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--nextPart7309338.hiFcT6WmFj
Content-Type: Text/Plain;
  charset="utf-8"
Content-Transfer-Encoding: quoted-printable

On Sunday 18 December 2016 11:49:53 Arend Van Spriel wrote:
> On 16-12-2016 11:40, Pali Roh=C3=A1r wrote:
> > On Friday 16 December 2016 08:25:44 Daniel Wagner wrote:
> >> On 12/16/2016 03:03 AM, Luis R. Rodriguez wrote:
> >>> For the new API a solution for "fallback mechanisms" should be
> >>> clean though and I am looking to stay as far as possible from the
> >>> existing mess. A solution to help both the old API and new API is
> >>> possible for the "fallback mechanism" though -- but for that I
> >>> can only refer you at this point to some of Daniel Wagner and
> >>> Tom Gunderson's firmwared deamon prospect. It should help pave
> >>> the way for a clean solution and help address other stupid
> >>> issues.
> >>=20
> >> The firmwared project is hosted here
> >>=20
> >> https://github.com/teg/firmwared
> >>=20
> >> As Luis pointed out, firmwared relies on
> >> FW_LOADER_USER_HELPER_FALLBACK, which is not enabled by default.
> >=20
> > I know. But it does not mean that I cannot enable this option at
> > kernel compile time.
> >=20
> > Bigger problem is that currently request_firmware() first try to
> > load firmware directly from VFS and after that (if fails) fallback
> > to user helper.
> >=20
> > So I would need to extend kernel firmware code with new function
> > (or flag) to not use VFS and try only user mode helper.
>=20
> Why do you need the user-mode helper anyway. This is all static data,
> right?

Those are static data, but device specific!

> So why not cook up a firmware file in user-space once and put
> it in /lib/firmware for the driver to request directly.

1. Violates FHS

2. Does not work for readonly /, readonly /lib, readonly /lib/firmware

3. Backup & restore of rootfs between same devices does not work (as=20
rootfs now contains device specific data).

4. Sharing one rootfs (either via nfs or other technology) does not work=20
for more devices (even in state when rootfs is used only by one device=20
at one time).

And it is common that N900 developers have rootfs in laptop and via usb=20
(cdc_ether) exports it over nfs to N900 device and boot system. It=20
basically break booting from one nfs-exported rootfs, as that export=20
become model specific...

> Seems a bit
> overkill to have a {e,}udev or whatever daemon running if the result
> is always the same. Just my 2 cents.

No it is not. It will break couple of other things in Linux and device=20
and model specific calibration data should not be in /lib/firmware! That=20
directory is used for firmware files, not calibration.

=2D-=20
Pali Roh=C3=A1r
pali.rohar@gmail.com

--nextPart7309338.hiFcT6WmFj
Content-Type: application/pgp-signature; name=signature.asc 
Content-Description: This is a digitally signed message part.

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iEYEABECAAYFAlhWbVQACgkQi/DJPQPkQ1JU0ACfbpV61HLErshDjxcPW1WMNO8r
dm4AnRZZOuhu3SZaUvKdNgQfHwAzwZhk
=RKyJ
-----END PGP SIGNATURE-----

--nextPart7309338.hiFcT6WmFj--
