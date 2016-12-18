From: Pali =?utf-8?q?Roh=C3=A1r?= <pali.rohar@gmail.com>
Subject: Re: wl1251 & mac address & calibration data
Date: Sun, 18 Dec 2016 13:09:01 +0100
Message-ID: <201612181309.01298@pali>
References: <201611111820.52072@pali> <201612181204.52928@pali> <83b2e9a4-f990-68a8-241e-375e46448d47@broadcom.com>
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart6480445.L2UHAThkLZ";
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
In-Reply-To: <83b2e9a4-f990-68a8-241e-375e46448d47@broadcom.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--nextPart6480445.L2UHAThkLZ
Content-Type: Text/Plain;
  charset="utf-8"
Content-Transfer-Encoding: quoted-printable

On Sunday 18 December 2016 12:54:00 Arend Van Spriel wrote:
> On 18-12-2016 12:04, Pali Roh=C3=A1r wrote:
> > On Sunday 18 December 2016 11:49:53 Arend Van Spriel wrote:
> >> On 16-12-2016 11:40, Pali Roh=C3=A1r wrote:
> >>> On Friday 16 December 2016 08:25:44 Daniel Wagner wrote:
> >>>> On 12/16/2016 03:03 AM, Luis R. Rodriguez wrote:
> >>>>> For the new API a solution for "fallback mechanisms" should be
> >>>>> clean though and I am looking to stay as far as possible from
> >>>>> the existing mess. A solution to help both the old API and new
> >>>>> API is possible for the "fallback mechanism" though -- but for
> >>>>> that I can only refer you at this point to some of Daniel
> >>>>> Wagner and Tom Gunderson's firmwared deamon prospect. It
> >>>>> should help pave the way for a clean solution and help address
> >>>>> other stupid issues.
> >>>>=20
> >>>> The firmwared project is hosted here
> >>>>=20
> >>>> https://github.com/teg/firmwared
> >>>>=20
> >>>> As Luis pointed out, firmwared relies on
> >>>> FW_LOADER_USER_HELPER_FALLBACK, which is not enabled by default.
> >>>=20
> >>> I know. But it does not mean that I cannot enable this option at
> >>> kernel compile time.
> >>>=20
> >>> Bigger problem is that currently request_firmware() first try to
> >>> load firmware directly from VFS and after that (if fails)
> >>> fallback to user helper.
> >>>=20
> >>> So I would need to extend kernel firmware code with new function
> >>> (or flag) to not use VFS and try only user mode helper.
> >>=20
> >> Why do you need the user-mode helper anyway. This is all static
> >> data, right?
> >=20
> > Those are static data, but device specific!
>=20
> So what?
>=20
> >> So why not cook up a firmware file in user-space once and put
> >> it in /lib/firmware for the driver to request directly.
> >=20
> > 1. Violates FHS
>=20
> How?
>=20
> > 2. Does not work for readonly /, readonly /lib, readonly
> > /lib/firmware
>=20
> Que?
>=20
> > 3. Backup & restore of rootfs between same devices does not work
> > (as rootfs now contains device specific data).
>=20
> True.
>=20
> > 4. Sharing one rootfs (either via nfs or other technology) does not
> > work for more devices (even in state when rootfs is used only by
> > one device at one time).
>=20
> Indeed.
>=20
> > And it is common that N900 developers have rootfs in laptop and via
> > usb (cdc_ether) exports it over nfs to N900 device and boot
> > system. It basically break booting from one nfs-exported rootfs,
> > as that export become model specific...
>=20
> These are all you choices and more a logistic issue. If your take is
> that udev is the way to solve those, fine by me.
>=20
> >> Seems a bit
> >> overkill to have a {e,}udev or whatever daemon running if the
> >> result is always the same. Just my 2 cents.
> >=20
> > No it is not. It will break couple of other things in Linux and
> > device
>=20
> Now I am curious. What "couple of other things" will be broken.
>=20
> > and model specific calibration data should not be in /lib/firmware!
> > That directory is used for firmware files, not calibration.
>=20
> What is "firmware"? Really. These are binary blobs required to make
> the device work. And guess what, your device needs calibration data.
> Why make the distinction.
>=20
> Regards,
> Arend

=46ile wl1251-nvs.bin is provided by linux-firmware package and contains=20
default data which should be overriden by model specific calibrated=20
data.

But overwriting that one file is not possible as it next update of=20
linux-firmware package will overwrite it back. It break any normal usage=20
of package management.

Also it is ridiculously broken by design if some "boot" files needs to=20
be overwritten to initialize hardware properly. To not break booting you=20
need to overwrite that file before first boot. But without booting=20
device you cannot read calibration data. So some hack with autoreboot=20
after boot is needed. And how to detect that we have real overwritten=20
calibration data and not default one from linux-firmware? Any heuristic=20
or checks will be broken here. And no, nothing like you need to reboot=20
your device now (and similar concept) from windows world is not=20
accepted.

"firmware" is one for chip. Any N900 device with wl1251 chip needs=20
exactly same firmware "wl1251-fw.bin". But every N900 needs different=20
calibration data which is not firmware.

=2D-=20
Pali Roh=C3=A1r
pali.rohar@gmail.com

--nextPart6480445.L2UHAThkLZ
Content-Type: application/pgp-signature; name=signature.asc 
Content-Description: This is a digitally signed message part.

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iEYEABECAAYFAlhWfF0ACgkQi/DJPQPkQ1JdiACgjqn1rcoZBm2MSGLl4Eo1f5Hk
0qIAni1PInunNV3Rv1/7Y705NSf4PhFx
=cR70
-----END PGP SIGNATURE-----

--nextPart6480445.L2UHAThkLZ--
