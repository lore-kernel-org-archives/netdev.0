From: Pali =?utf-8?q?Roh=C3=A1r?= <pali.rohar@gmail.com>
Subject: Re: wl1251: NVS firmware data
Date: Mon, 8 Dec 2014 18:11:46 +0100
Message-ID: <201412081811.46943@pali>
References: <201411271506.20457@pali> <201412081747.30965@pali> <E5F3BB54-6365-4856-A231-A5FEDAEA217F@holtmann.org>
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart1715012.6Goo9eDEJj";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Cc: "Greg Kroah-Hartman" <gregkh@linuxfoundation.org>,
	Ming Lei <ming.lei@canonical.com>, Pavel Machek <pavel@ucw.cz>,
	"John W. Linville" <linville@tuxdriver.com>,
	Grazvydas Ignotas <notasas@gmail.com>,
	"linux-wireless@vger.kernel.org" <linux-wireless@vger.kernel.org>,
	Network Development <netdev@vger.kernel.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Ivaylo Dimitrov <ivo.g.dimitrov.75@gmail.com>,
	Aaro Koskinen <aaro.koskinen@iki.fi>,
	Kalle Valo <kvalo@adurom.com>,
	Sebastian Reichel <sre@ring0.de>,
	David Gnedt <david.gnedt@davizone.at>
To: Marcel Holtmann <marcel@holtmann.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <E5F3BB54-6365-4856-A231-A5FEDAEA217F@holtmann.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--nextPart1715012.6Goo9eDEJj
Content-Type: Text/Plain;
  charset="utf-8"
Content-Transfer-Encoding: quoted-printable

On Monday 08 December 2014 18:05:37 Marcel Holtmann wrote:
> Hi Pali,
>=20
> >>>> On Saturday 06 December 2014 13:49:54 Pavel Machek wrote:
> >>>> /**
> >>>>=20
> >>>> + * request_firmware_prefer_user: - prefer usermode
> >>>> helper for loading firmware + * @firmware_p: pointer to
> >>>> firmware image
> >>>> + * @name: name of firmware file
> >>>> + * @device: device for which firmware is being loaded
> >>>> + *
> >>>> + * This function works pretty much like
> >>>> request_firmware(), but it prefer + * usermode helper. If
> >>>> usermode helper fails then it fallback to direct access.
> >>>> + * Usefull for dynamic or model specific firmware data.
> >>>> + **/
> >>>> +int request_firmware_prefer_user(const struct firmware
> >>>> **firmware_p, +                           const char
> >>>> *name, struct device *device) +{
> >>>> +       int ret;
> >>>> +       __module_get(THIS_MODULE);
> >>>> +       ret =3D _request_firmware(firmware_p, name, device,
> >>>> +                               FW_OPT_UEVENT |
> >>>> FW_OPT_PREFER_USER); +       module_put(THIS_MODULE);
> >>>> +       return ret;
> >>>> +}
> >>>> +EXPORT_SYMBOL_GPL(request_firmware_prefer_user);
> >>>=20
> >>> I'd like to introduce request_firmware_user() which only
> >>> requests firmware from user space, and this way is simpler
> >>> and more flexible since we have request_firmware_direct()
> >>> already.
> >>=20
> >> Why would a driver care about what program provides the
> >> firmware?  It shouldn't at all, and we want to get rid of
> >> the userspace firmware loader, not encourage drivers to
> >> use it "exclusively" at all.
> >=20
> > Do not remove it! Without userspace firmware loader it is
> > impossible to load dynamic firmware files.
>=20
> why is this dynamic in the first place. It does not sound like
> dynamic data to me at all. This is like the WiFi MAC
> address(es) or Bluetooth BD_ADDR. They are all static
> information. The only difference is that they are on the host
> accessibly filesystem or storage and not on the device
> itself.
>=20
> To be honest, for Bluetooth we solved this now. If the device
> is missing key information like the calibration data or
> BD_ADDR, then it comes up unconfigured. A userspace process
> can then go and load the right data into it and then the
> device becomes available as Bluetooth device.
>=20
> Trying to use request_firmware to load some random data and
> insist on going through userspace helper for that sounds
> crazy to me. Especially since we are trying hard to get away
> from the userspace loader. Forcing to keep it for new stuff
> sounds backwards to me.
>=20
> With the special Nokia partition in mind, why hasn't this been
> turned into a mountable filesystem or into a driver/subsystem
> that can access the data direct from the kernel. I advocated
> for this some time ago. Maybe there should be a special
> subsystem for access to these factory persistent information
> that drivers then just can access. I seem to remember that
> some systems provide these via ACPI. Why does the ARM
> platform has to be special here?
>=20
> And the problem of getting Ethernet and WiFi MAC address and
> Bluetooth BD_ADDR comes up many many times. Why not have
> something generic here. And don't tell me request_firmware is
> that generic solution ;)
>=20
> Regards
>=20
> Marcel

Hi Marcel. I think you did not understand this problem. This=20
discussion is not about mac address. Please read email thread=20
again and if there are some unclear pars, then ask. Thanks!

=2D-=20
Pali Roh=C3=A1r
pali.rohar@gmail.com

--nextPart1715012.6Goo9eDEJj
Content-Type: application/pgp-signature; name=signature.asc 
Content-Description: This is a digitally signed message part.

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iEYEABECAAYFAlSF29IACgkQi/DJPQPkQ1KsDgCeNZmwr8tIOz9uchTfCHmTGhqs
mwsAni5d+CRKG11fYsdVEyk4Mz3LMAWN
=8APv
-----END PGP SIGNATURE-----

--nextPart1715012.6Goo9eDEJj--
