From: Pali =?utf-8?q?Roh=C3=A1r?= <pali.rohar@gmail.com>
Subject: Re: wl1251: NVS firmware data
Date: Mon, 8 Dec 2014 22:11:22 +0100
Message-ID: <201412082211.22352@pali>
References: <201411271506.20457@pali> <201412081747.30965@pali> <20141208205721.GA14895@kroah.com>
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart3309978.raKky74fON";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Cc: Ming Lei <ming.lei@canonical.com>, Pavel Machek <pavel@ucw.cz>,
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
To: "Greg Kroah-Hartman" <gregkh@linuxfoundation.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20141208205721.GA14895@kroah.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--nextPart3309978.raKky74fON
Content-Type: Text/Plain;
  charset="utf-8"
Content-Transfer-Encoding: quoted-printable

On Monday 08 December 2014 21:57:21 Greg Kroah-Hartman wrote:
> On Mon, Dec 08, 2014 at 05:47:30PM +0100, Pali Roh=C3=A1r wrote:
> > On Monday 08 December 2014 17:37:14 Greg Kroah-Hartman wrote:
> > > On Mon, Dec 08, 2014 at 11:18:18PM +0800, Ming Lei wrote:
> > > > On Sat, Dec 6, 2014 at 9:02 PM, Pali Roh=C3=A1r
> >=20
> > <pali.rohar@gmail.com> wrote:
> > > > > On Saturday 06 December 2014 13:49:54 Pavel Machek=20
wrote:
> > > > >  /**
> > > > >=20
> > > > > + * request_firmware_prefer_user: - prefer usermode
> > > > > helper for loading firmware + * @firmware_p: pointer
> > > > > to firmware image
> > > > > + * @name: name of firmware file
> > > > > + * @device: device for which firmware is being loaded
> > > > > + *
> > > > > + * This function works pretty much like
> > > > > request_firmware(), but it prefer + * usermode helper.
> > > > > If usermode helper fails then it fallback to direct
> > > > > access. + * Usefull for dynamic or model specific
> > > > > firmware data. + **/
> > > > > +int request_firmware_prefer_user(const struct
> > > > > firmware **firmware_p, +                         =20
> > > > > const char *name, struct device *device) +{
> > > > > +       int ret;
> > > > > +       __module_get(THIS_MODULE);
> > > > > +       ret =3D _request_firmware(firmware_p, name,
> > > > > device, +                               FW_OPT_UEVENT
> > > > > | FW_OPT_PREFER_USER); +     =20
> > > > > module_put(THIS_MODULE); +       return ret;
> > > > > +}
> > > > > +EXPORT_SYMBOL_GPL(request_firmware_prefer_user);
> > > >=20
> > > > I'd like to introduce request_firmware_user() which only
> > > > requests firmware from user space, and this way is
> > > > simpler and more flexible since we have
> > > > request_firmware_direct() already.
> > >=20
> > > Why would a driver care about what program provides the
> > > firmware?  It shouldn't at all, and we want to get rid of
> > > the userspace firmware loader, not encourage drivers to
> > > use it "exclusively" at all.
> >=20
> > Do not remove it! Without userspace firmware loader it is
> > impossible to load dynamic firmware files.
>=20
> You should not be loading "dynamic" firmware files with the
> firmware interface, as that's not a "firmware" file anymore,
> it's a "special binary file that my driver needs to be
> created and sent into the kernel."
>=20
> Use your own custom usermode helper for stuff like this, not
> the firmware interface.  But use a binary sysfs file if you
> want, that seems to make sense for it...
>=20
> greg k-h

Nokia for this problem invented its own netlink interface into=20
wl1251 driver. But because it was specific for N900 device it was=20
rejected for inclusion into mainline kernel.

=2D-=20
Pali Roh=C3=A1r
pali.rohar@gmail.com

--nextPart3309978.raKky74fON
Content-Type: application/pgp-signature; name=signature.asc 
Content-Description: This is a digitally signed message part.

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iEYEABECAAYFAlSGE/oACgkQi/DJPQPkQ1Li4ACfUYeNAfILh+bSTeMLUeaNxmoP
lBMAmgNKHgHgFHFsXaApXxS0uSzMPEJz
=85FL
-----END PGP SIGNATURE-----

--nextPart3309978.raKky74fON--
