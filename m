From: Pali =?utf-8?q?Roh=C3=A1r?= <pali.rohar@gmail.com>
Subject: Re: wl1251 & mac address & calibration data
Date: Thu, 24 Nov 2016 17:49:33 +0100
Message-ID: <201611241749.33681@pali>
References: <201611111820.52072@pali> <20161124152045.GK13735@pali> <20161124160830.kdpbonsz3l26uuo5@earth>
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart2626355.tNxa7UNqEK";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Cc: Pavel Machek <pavel@ucw.cz>,
        Michal Kazior <michal.kazior@tieto.com>,
        Kalle Valo <kvalo@codeaurora.org>,
        Ivaylo Dimitrov <ivo.g.dimitrov.75@gmail.com>,
        Aaro Koskinen <aaro.koskinen@iki.fi>,
        Tony Lindgren <tony@atomide.com>,
        "linux-wireless" <linux-wireless@vger.kernel.org>,
        Network Development <netdev@vger.kernel.org>,
        linux-kernel@vger.kernel.org
To: Sebastian Reichel <sre@kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20161124160830.kdpbonsz3l26uuo5@earth>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--nextPart2626355.tNxa7UNqEK
Content-Type: Text/Plain;
  charset="utf-8"
Content-Transfer-Encoding: quoted-printable

On Thursday 24 November 2016 17:08:30 Sebastian Reichel wrote:
> Hi,
>=20
> On Thu, Nov 24, 2016 at 04:20:45PM +0100, Pali Roh=C3=A1r wrote:
> > On Thursday 24 November 2016 16:13:17 Sebastian Reichel wrote:
> > > On Thu, Nov 24, 2016 at 09:33:29AM +0100, Pali Roh=C3=A1r wrote:
> > > > On Thursday 24 November 2016 08:51:04 Pavel Machek wrote:
> > > > > > > "ifconfig hw ether XX" normally sets the address. I guess
> > > > > > > that's ioctl?
> > > > > >=20
> > > > > > This sets temporary address and it is ioctl. IIRC same as
> > > > > > what ethtool uses. (ifconfig is already deprecated).
> > > > > >=20
> > > > > > > And I guess we should use similar mechanism for permanent
> > > > > > > address.
> > > > > >=20
> > > > > > I'm not sure here... Above ioctl =E2=86=91=E2=86=91=E2=86=91 is=
 for changing
> > > > > > temporary mac address. But here we do not want to change
> > > > > > permanent mac address. We want to tell kernel driver
> > > > > > current permanent mac address which is stored
> > > > >=20
> > > > > Well... I'd still use similar mechanism :-).
> > > >=20
> > > > Thats problematic, because in time when wlan0 interface is
> > > > registered into system and visible in ifconfig output it
> > > > already needs to have permanent mac address assigned.
> > > >=20
> > > > We should assign permanent mac address before wlan0 of wl1251
> > > > is registered into system.
> > >=20
> > > You can just add the MAC address to the NVS data, which is also
> > > required for the device initialization.
> >=20
> > NVS data file has fixed size, there is IIRC no place for it.
> >=20
> > But one of my suggestion was to use another request_firmware for
> > MAC address. So this is similar to what you are proposing, as NVS
> > data are loaded by request_firmware too...
>=20
> Just append it to NVS data and modify the size check accordingly?

=46irst that would mean to have request_firmware() function which will not=
=20
use direct VFS access, but instead use userspace helper.

NVS data file with some default values (not suitable for usage) is=20
already present in linux-firmware and available in /lib/firmware/...

Also I'm not sure if such thing is allowed by license:
https://git.kernel.org/cgit/linux/kernel/git/firmware/linux-firmware.git/tr=
ee/LICENCE.ti-connectivity

> > > I wonder if those information could be put into DT. Iirc some
> > > network devices get their MAC address from DT. Maybe we can add
> > > all NVS info to DT? How much data is it?
> >=20
> > Proprietary, signed and closed bootloader NOLO does not support DT.
> > So for booting you need to append DTS file to kernel image.
>=20
> Yeah, so NOLO without U-Boot will depend on userspace to fixup DT.
>=20
> > U-Boot is optional and can be used as intermediate bootloader
> > between NOLO and kernel. But still it has problems with reading
> > from nand, so cannot read NVS data nor MAC address.
>=20
> It may in the future?

I already tried that, but I failed. I was not able to access N900's nand=20
from u-boot. No idea where was problem...

And if somebody fix onenand in u-boot, then needs to reimplement Nokia's=20
proprietary parser of that partition where is stored NVS and mac address=20
&& make this support in upstream u-boot.

So... I doubt it will be in any future.

+ no men power

> > > Userspace application can add all those information to the DT
> > > using a DT overlay. Also the u-boot could parse and add it at
> > > some point in the future.
> >=20
> > In case when wl1251 is statically linked into kernel image, it is
> > loaded and initialized before even userspace applications starts.
> >=20
> > So no... adding NVS data or MAC address into DT or DT overlay is
> > not a solution.
>=20
> Actually with data loaded from DT you *can* load data quite early in
> the boot process, while your suggestions always require userspace.
> So you argument against yourself?

You cannot add DTS in uboot (no support). And if you modify DTS on=20
running kernel from userspace, then it is too late when wl1251 is=20
statically linked into kernel image.

wl1251 will not wait until some userspace modify DTS and add data...

But request_firmware() in fallback mode *can* wait for userspace so=20
wl1251 can postpone its operation until mdev/udev/whatever starts=20
listening for events and push needed firmware data to kernel.

So no, there is no argument against... request_firmware() in fallback=20
mode with userspace helper is by design blocking and waiting for=20
userspace. But waiting for some change in DST in kernel is just=20
nonsense.

=2D-=20
Pali Roh=C3=A1r
pali.rohar@gmail.com

--nextPart2626355.tNxa7UNqEK
Content-Type: application/pgp-signature; name=signature.asc 
Content-Description: This is a digitally signed message part.

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iEYEABECAAYFAlg3Gh0ACgkQi/DJPQPkQ1IzRACfaqVXvE8L0hQdsNAu5laB+eyP
RgkAoK/tIYnSim7S5BHS0eAkyIMxGRS9
=ypNA
-----END PGP SIGNATURE-----

--nextPart2626355.tNxa7UNqEK--
