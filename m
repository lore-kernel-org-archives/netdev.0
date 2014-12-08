From: Pali =?utf-8?q?Roh=C3=A1r?= <pali.rohar@gmail.com>
Subject: Re: wl1251: NVS firmware data
Date: Mon, 8 Dec 2014 16:22:25 +0100
Message-ID: <201412081622.25541@pali>
References: <201411271506.20457@pali> <201412061402.21514@pali> <CACVXFVPOLfDuqc0nLb-zM8vH618DLXy0xtZbUOn5_XvdxRZSDw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart6013142.Y7C6ce8dYc";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Cc: Pavel Machek <pavel@ucw.cz>,
	"Greg Kroah-Hartman" <gregkh@linuxfoundation.org>,
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
To: Ming Lei <ming.lei@canonical.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CACVXFVPOLfDuqc0nLb-zM8vH618DLXy0xtZbUOn5_XvdxRZSDw@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--nextPart6013142.Y7C6ce8dYc
Content-Type: Text/Plain;
  charset="utf-8"
Content-Transfer-Encoding: quoted-printable

On Monday 08 December 2014 16:18:18 Ming Lei wrote:
> On Sat, Dec 6, 2014 at 9:02 PM, Pali Roh=C3=A1r=20
<pali.rohar@gmail.com> wrote:
> > On Saturday 06 December 2014 13:49:54 Pavel Machek wrote:
> >  /**
> >=20
> > + * request_firmware_prefer_user: - prefer usermode helper
> > for loading firmware + * @firmware_p: pointer to firmware
> > image
> > + * @name: name of firmware file
> > + * @device: device for which firmware is being loaded
> > + *
> > + * This function works pretty much like request_firmware(),
> > but it prefer + * usermode helper. If usermode helper fails
> > then it fallback to direct access. + * Usefull for dynamic
> > or model specific firmware data. + **/
> > +int request_firmware_prefer_user(const struct firmware
> > **firmware_p, +                           const char *name,
> > struct device *device) +{
> > +       int ret;
> > +       __module_get(THIS_MODULE);
> > +       ret =3D _request_firmware(firmware_p, name, device,
> > +                               FW_OPT_UEVENT |
> > FW_OPT_PREFER_USER); +       module_put(THIS_MODULE);
> > +       return ret;
> > +}
> > +EXPORT_SYMBOL_GPL(request_firmware_prefer_user);
>=20
> I'd like to introduce request_firmware_user() which only
> requests firmware from user space, and this way is simpler
> and more flexible since we have request_firmware_direct()
> already.
>=20
> Thanks,
> Ming Lei

Ming, for wl1251 NVS data we need to load use usermode helper and=20
fallback to direct load. So I think it is better to handle this=20
request in firmware code and not in driver.

=2D-=20
Pali Roh=C3=A1r
pali.rohar@gmail.com

--nextPart6013142.Y7C6ce8dYc
Content-Type: application/pgp-signature; name=signature.asc 
Content-Description: This is a digitally signed message part.

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iEYEABECAAYFAlSFwjEACgkQi/DJPQPkQ1LiOwCfYDvcaBsb2UkGRzsc6RY/9zSb
K5cAnj47jXkv66tvdcHMuFCFs2a0Itc2
=mV9Q
-----END PGP SIGNATURE-----

--nextPart6013142.Y7C6ce8dYc--
