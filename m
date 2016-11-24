From: Pali =?utf-8?q?Roh=C3=A1r?= <pali.rohar@gmail.com>
Subject: Re: wl1251 & mac address & calibration data
Date: Thu, 24 Nov 2016 19:35:32 +0100
Message-ID: <201611241935.32796@pali>
References: <201611111820.52072@pali> <201611241749.33681@pali> <20161124181138.4i6ehkpohjxfgpbn@earth>
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart3481083.qjsuTUjsto";
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
In-Reply-To: <20161124181138.4i6ehkpohjxfgpbn@earth>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--nextPart3481083.qjsuTUjsto
Content-Type: Text/Plain;
  charset="utf-8"
Content-Transfer-Encoding: quoted-printable

On Thursday 24 November 2016 19:11:39 Sebastian Reichel wrote:
> Hi,
>=20
> On Thu, Nov 24, 2016 at 05:49:33PM +0100, Pali Roh=C3=A1r wrote:
> > On Thursday 24 November 2016 17:08:30 Sebastian Reichel wrote:
> > > On Thu, Nov 24, 2016 at 04:20:45PM +0100, Pali Roh=C3=A1r wrote:
> > > > On Thursday 24 November 2016 16:13:17 Sebastian Reichel wrote:
> > > > > On Thu, Nov 24, 2016 at 09:33:29AM +0100, Pali Roh=C3=A1r wrote:
> > > > > > On Thursday 24 November 2016 08:51:04 Pavel Machek wrote:
> > > > > > > > > "ifconfig hw ether XX" normally sets the address. I
> > > > > > > > > guess that's ioctl?
> > > > > > > >=20
> > > > > > > > This sets temporary address and it is ioctl. IIRC same
> > > > > > > > as what ethtool uses. (ifconfig is already
> > > > > > > > deprecated).
> > > > > > > >=20
> > > > > > > > > And I guess we should use similar mechanism for
> > > > > > > > > permanent address.
> > > > > > > >=20
> > > > > > > > I'm not sure here... Above ioctl =E2=86=91=E2=86=91=E2=86=
=91 is for changing
> > > > > > > > temporary mac address. But here we do not want to
> > > > > > > > change permanent mac address. We want to tell kernel
> > > > > > > > driver current permanent mac address which is stored
> > > > > > >=20
> > > > > > > Well... I'd still use similar mechanism :-).
> > > > > >=20
> > > > > > Thats problematic, because in time when wlan0 interface is
> > > > > > registered into system and visible in ifconfig output it
> > > > > > already needs to have permanent mac address assigned.
> > > > > >=20
> > > > > > We should assign permanent mac address before wlan0 of
> > > > > > wl1251 is registered into system.
> > > > >=20
> > > > > You can just add the MAC address to the NVS data, which is
> > > > > also required for the device initialization.
> > > >=20
> > > > NVS data file has fixed size, there is IIRC no place for it.
> > > >=20
> > > > But one of my suggestion was to use another request_firmware
> > > > for MAC address. So this is similar to what you are proposing,
> > > > as NVS data are loaded by request_firmware too...
> > >=20
> > > Just append it to NVS data and modify the size check accordingly?
> >=20
> > First that would mean to have request_firmware() function which
> > will not use direct VFS access, but instead use userspace helper.
>=20
> Permanent MAC is device specific init data, NVS is device specific
> init data =3D> load together.
>=20
> The userspace helper stuff is only needed to get the data from
> the NAND calibration area on the fly.

But it is needed... and currently request_firmware() prefer direct VFS=20
access...

> > NVS data file with some default values (not suitable for usage) is
> > already present in linux-firmware and available in
> > /lib/firmware/...
>=20
> You mentioned NVS data is fixed size, so this should be enough?
>=20
> switch(loaded_size)
>     case IMAGE_SIZE + MAC_SIZE:
>         /* extract mac */
>         /* fallthrough */
>     case IMAGE_SIZE:
>         /* load NVS */
>         break;
>     default:
>         /* fail */
> }
>=20
> > Also I'm not sure if such thing is allowed by license:
> > https://git.kernel.org/cgit/linux/kernel/git/firmware/linux-firmwar
> > e.git/tree/LICENCE.ti-connectivity
>=20
> concating data is not a modification, otherwise you can't
> put the file in a filesystem.

Ok, if net maintainers agree.

> > > > > I wonder if those information could be put into DT. Iirc some
> > > > > network devices get their MAC address from DT. Maybe we can
> > > > > add all NVS info to DT? How much data is it?
> > > >=20
> > > > Proprietary, signed and closed bootloader NOLO does not support
> > > > DT. So for booting you need to append DTS file to kernel
> > > > image.
> > >=20
> > > Yeah, so NOLO without U-Boot will depend on userspace to fixup
> > > DT.
> > >=20
> > > > U-Boot is optional and can be used as intermediate bootloader
> > > > between NOLO and kernel. But still it has problems with reading
> > > > from nand, so cannot read NVS data nor MAC address.
> > >=20
> > > It may in the future?
> >=20
> > I already tried that, but I failed. I was not able to access N900's
> > nand from u-boot. No idea where was problem...
> >=20
> > And if somebody fix onenand in u-boot, then needs to reimplement
> > Nokia's proprietary parser of that partition where is stored NVS
> > and mac address && make this support in upstream u-boot.
>=20
> Are we talking about this?
>=20
> https://github.com/community-ssu/libcal/blob/master/cal.c
>=20
> That's ~1k loc for read-only.

Yes. There is also read-only alternative library:
https://github.com/pali/0xFFFF/blob/master/src/cal.c

But still, this is proprietary format useful only for one device (or=20
two) and I do not know if such thing could be accepted by u-boot=20
developers...

> Getting NAND working looks harder than porting this to me.

Right.

> > So... I doubt it will be in any future.
> >=20
> > + no men power
>=20
> yeah :(
>=20
> But with that reasoning you should just extract the NVS data
> from NAND and put it in your rootfs.

Not a clean solution. Some rootfs parts can used as readonly. And=20
normally rootfs is flashed into nand, so I still will say that roofs=20
(image) should not contain any device specific data.

> > > > > Userspace application can add all those information to the DT
> > > > > using a DT overlay. Also the u-boot could parse and add it at
> > > > > some point in the future.
> > > >=20
> > > > In case when wl1251 is statically linked into kernel image, it
> > > > is loaded and initialized before even userspace applications
> > > > starts.
> > > >=20
> > > > So no... adding NVS data or MAC address into DT or DT overlay
> > > > is not a solution.
> > >=20
> > > Actually with data loaded from DT you *can* load data quite early
> > > in the boot process, while your suggestions always require
> > > userspace. So you argument against yourself?
> >=20
> > You cannot add DTS in uboot (no support).
>=20
> AFAIK that's supported:
>=20
> http://www.denx.de/wiki/DULG/LinuxFDTBlob
>=20
> "Note that U-Boot makes some automatic modifications to the blob
> before passing it to the kernel - mainly adding and modifying
> information that is learnt at run-time."

I mean we do not have support for due to n900 nand.

> > And if you modify DTS on running kernel from userspace, then it is
> > too late when wl1251 is statically linked into kernel image.
> >=20
> > wl1251 will not wait until some userspace modify DTS and add
> > data...
>=20
> if (nvs info missing)
>     return -EPROBE_DEFER;

=46orever? Only N times? How long? Only N second?

Here we do not know if userspace is going to send data or not.

My guess is that such code will not be accepted into net/wireless=20
subsystem or drivers by maintainers.

> > But request_firmware() in fallback mode *can* wait for userspace so
> > wl1251 can postpone its operation until mdev/udev/whatever starts
> > listening for events and push needed firmware data to kernel.
>=20
> As you said one workaround is waiting. That's not a solution, that
> only works with request_firmware().

Yes, but request_firmware() uses interaction with userspace. Your=20
proposed solution does not do any interaction with userspace that some=20
process needs to fill missing data into DT.

And request_firmware() is already used for loading NVS data.

> > So no, there is no argument against... request_firmware() in
> > fallback mode with userspace helper is by design blocking and
> > waiting for userspace. But waiting for some change in DTS in
> > kernel is just nonsense.
>=20
> I would just mark the wlan device with status =3D "disabled" and
> enable it in the overlay together with adding the NVS & MAC info.

So if you think that this solution make sense, we can wait what net=20
wireless maintainers say about it...

=46or me it looks like that solution can be:

extending request_firmware() to use only userspace helper

and load mac address also via request_firmware() either by appending it=20
into NVS data or via separate call

=2D-=20
Pali Roh=C3=A1r
pali.rohar@gmail.com

--nextPart3481083.qjsuTUjsto
Content-Type: application/pgp-signature; name=signature.asc 
Content-Description: This is a digitally signed message part.

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iEYEABECAAYFAlg3MvQACgkQi/DJPQPkQ1KX8QCeLkghg2hRiQlBTbfghN2HXGf7
RQ0AniLjDafrK7VFlsXHJ7smVHV9cbBP
=g3ke
-----END PGP SIGNATURE-----

--nextPart3481083.qjsuTUjsto--
