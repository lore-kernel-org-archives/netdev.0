From: Pali =?utf-8?q?Roh=C3=A1r?= <pali.rohar@gmail.com>
Subject: Re: wl1251 & mac address & calibration data
Date: Tue, 22 Nov 2016 18:05:13 +0100
Message-ID: <201611221805.13606@pali>
References: <201611111820.52072@pali> <20161122153141.GT13735@pali> <CA+BoTQkSOJ85PiT=pjmH234sviCj-LVWWM=64KbCe4AG9CMNUg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart10355501.CvPRMbuW7A";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Cc: Kalle Valo <kvalo@codeaurora.org>, Pavel Machek <pavel@ucw.cz>,
        Ivaylo Dimitrov <ivo.g.dimitrov.75@gmail.com>,
        Sebastian Reichel <sre@kernel.org>,
        Aaro Koskinen <aaro.koskinen@iki.fi>,
        Tony Lindgren <tony@atomide.com>,
        "linux-wireless" <linux-wireless@vger.kernel.org>,
        Network Development <netdev@vger.kernel.org>,
        linux-kernel@vger.kernel.org
To: Michal Kazior <michal.kazior@tieto.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CA+BoTQkSOJ85PiT=pjmH234sviCj-LVWWM=64KbCe4AG9CMNUg@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--nextPart10355501.CvPRMbuW7A
Content-Type: Text/Plain;
  charset="utf-8"
Content-Transfer-Encoding: quoted-printable

On Tuesday 22 November 2016 17:14:28 Michal Kazior wrote:
> On 22 November 2016 at 16:31, Pali Roh=C3=A1r <pali.rohar@gmail.com> wrot=
e:
> > On Tuesday 22 November 2016 16:22:57 Michal Kazior wrote:
> >> On 21 November 2016 at 16:51, Pali Roh=C3=A1r <pali.rohar@gmail.com>
> >> wrote:
> >> > On Friday 11 November 2016 18:20:50 Pali Roh=C3=A1r wrote:
> >> >> Hi! I will open discussion about mac address and calibration
> >> >> data for wl1251 wireless chip again...
> >> >>=20
> >> >> Problem: Mac address & calibration data for wl1251 chip on
> >> >> Nokia N900 are stored on second nand partition (mtd1) in
> >> >> special proprietary format which is used only for Nokia N900
> >> >> (probably on N8x0 and N9 too). Wireless driver wl1251.ko
> >> >> cannot work without mac address and calibration data.
> >>=20
> >> Same problem applies to some ath9k/ath10k supported routers. Some
> >> even carry mac address as implicit offset from ethernet mac
> >> address. As far as I understand OpenWRT cooks cal blobs on first
> >> boot prior to loading modules.
> >=20
> > So... wl1251 on Nokia N900 is not alone and this problem is there
> > for more drivers and devices. Which means we should come up with
> > some generic solution.
>=20
> This isn't particularly a problem for ath9k/ath10k.
>=20
> Let me give you more background on ath10k.
>=20
> ath10k devices can come with caldata and macaddr stored in their
> OTP/EEPROM. In that case a generic "template" board file is used.
> Userspace doesn't need to do anything special.
>=20
> Some vendors however decide to use flash partition to store caldata.
> In that case ath10k expects userspace to prepare
> cal-$bus-$devname.bin files, each for a different radio (you can
> have multiple radios on a system).
>=20
> Now translating this for wl1251 I would expect it should also use
> something like wl1251-nvs-sdio-0x0001.bin for devices like N900 that
> have caldata on flash partition (instead of the generic
> wl1251-nvs.bin). I'm not sure if wl1251-nvs.bin is something
> comparable to (the generic) board.bin ath10k has though. Maybe the
> entire idea behind wl1251-nvs.bin is flawed as it's supposed to be
> device specific and is oblivious to possibility of having multiple
> wl1251 radios on one system (probably sane assumption from practical
> standpoint but still).

Basically nvs data are device specific, in ideal case they should be=20
generated in factory by some calibration process (or so).

> >> >> Absence of mac address cause that driver generates random mac
> >> >> address at every kernel boot which has couple of problems
> >> >> (unstable identifier of wireless device due to udev permanent
> >> >> storage rules; unpredictable behaviour for dhcp mac address
> >> >> assignment, mac address filtering, ...).
> >> >>=20
> >> >> Currently there is no way to set (permanent) mac address for
> >> >> network interface from userspace. And it does not make sense
> >> >> to implement in linux kernel large parser for proprietary
> >> >> format of second nand partition where is mac address stored
> >> >> only for one device -- Nokia N900.
> >> >>=20
> >> >> Driver wl1251.ko loads calibration data via request_firmware()
> >> >> for file wl1251-nvs.bin. There are some "example" calibration
> >> >> file in linux- firmware repository, but it is not suitable for
> >> >> normal usage as real calibration data are per-device specific.
> >>=20
> >> You could hook up a script that cooks up the cal/mac file via
> >> modprobe's install hook, no?
> >=20
> > Via modprobe hook I can either pass custom module parameter or call
> > any other system (shell) commands.
> >=20
> > As wl1251.ko does not accept mac_address as module parameter, such
> > modprobe hook does not help -- as there is absolutely no way from
> > userspace to set or change (permanent) mac address.
>=20
> Quoting modprobe.d manual:
> >       install modulename command...
> >      =20
> >           This command instructs modprobe to run your
> >           command instead of inserting the module in the
> >           kernel as normal. The command can be any shell
> >           command: this allows you to do any kind of
> >           complex processing you might wish. [...]

I know. But this do not allow me to send mac address to kernel -- as=20
kernel does not support such command yet (reason for my first question).

> You can hook up a script that cooks up wl1251-nvs.bin (caldata,
> macaddr) and then insmod the actual wl1251.ko module. Or you can just
> cook up the nvs on first device boot and store it in /lib/firmware
> (possibly overwriting the "generic" wl1251 from linux-firmware).

This is what I would like to prevent -- overwriting (possible readonly)=20
system files with some device specific. It is really bad idea!

=2D-=20
Pali Roh=C3=A1r
pali.rohar@gmail.com

--nextPart10355501.CvPRMbuW7A
Content-Type: application/pgp-signature; name=signature.asc 
Content-Description: This is a digitally signed message part.

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iEYEABECAAYFAlg0eskACgkQi/DJPQPkQ1KpUgCdEhjP8T0b0vZ00AxX6CeDL/Wy
UiMAn3ynIB+PnRJkxwsiZ27rgggBA1vt
=mEYs
-----END PGP SIGNATURE-----

--nextPart10355501.CvPRMbuW7A--
