From: Felipe Balbi <balbi@ti.com>
Subject: Re: SYSFS "errors"
Date: Tue, 19 Feb 2013 15:15:00 +0200
Message-ID: <20130219131500.GW23197@arwen.pp.htv.fi>
References: <20130218222618.GA21818@kroah.com>
 <20130218224405.GB21493@pd.tnic>
 <20130219070310.2cadad7a@redhat.com>
 <20130219101121.GJ23197@arwen.pp.htv.fi>
 <20130219081149.46972f56@redhat.com>
 <20130219114345.GA26623@pd.tnic>
 <20130219091610.2b746a30@redhat.com>
 <20130219123502.GD26623@pd.tnic>
 <20130219094640.2abf1a66@redhat.com>
 <20130219130626.GE26623@pd.tnic>
Reply-To: <balbi@ti.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="ZcaUvQ23gCOmDTXi"
To: Borislav Petkov <bp@alien8.de>,
	Mauro Carvalho Chehab <mchehab@redhat.com>, <balbi@ti.com>,
	Greg KH <gregkh@linuxfoundation.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Steven Rostedt <rostedt@goodmis.org>,
	Frederic Weisbecker <fweisbec@gmail.com>,
	Ingo Molnar <mingo@redhat.com>, <JBottomley@parallels.com>,
	<linux-scsi@vger.kernel.org>, <davem@davemloft.net>,
	<netdev@vger.kernel.org>,
	Doug Thompson <dougthompson@xmission.com>,
	<linux-edac@vger.kernel.org>, <rjw@sisk.pl>,
	<linux-pm@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20130219130626.GE26623@pd.tnic>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--ZcaUvQ23gCOmDTXi
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Tue, Feb 19, 2013 at 02:06:26PM +0100, Borislav Petkov wrote:
> On Tue, Feb 19, 2013 at 09:46:40AM -0300, Mauro Carvalho Chehab wrote:
> > Ah, now I see what you're meaning. That would require to dynamically
> > create a per-mci DEVICE_ATTR().
>=20
> Dude, look at the code, we do that already. And you're using it with
> dev_attr_sdram_scrub_rate.
>=20
> Simply change the permissions of the attribute before calling
> device_create_file.
>=20
> pseudo:
>=20
> 	umode_t mode =3D 0;
>=20
> 	if (mci->set...)
> 		mode |=3D S_IWUSR;
>=20
> 	if (mci->get...)
> 		mode |=3D S_IRUGO;
>=20
>=20
> 	dev_attr_sdram_scrub_rate.attr.mode =3D mode;
>=20
> 	device_create_file(&mci->dev, &dev_attr_sdram_scrub_rate);
>=20
> > No, on both cases, open() will return an error (-ENOENT against -EPERM).
>=20
> What if it is a shell script doing:
>=20
> cat /sys/devices/system/edac/mc/mc0/sdram_scrub_rate

what's the problem with that ?

$ cat /path/to/file/that/doesnt/exist.txt
cat: /path/to/file/that/doesnt/exist.txt: No such file or directory

Didn't see any gates to hell opening here...

--=20
balbi

--ZcaUvQ23gCOmDTXi
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIcBAEBAgAGBQJRI3rUAAoJEIaOsuA1yqREp/wP/AoA2wUA0ToOzavHNs50dGnG
VxS3PV4P73EFKSYjOB5Wh9OM9w23nD9EHnC6/A4dCxNUmeyRZOpXDzt1Fs55cOuU
iP7WiABg4sghiP7hXI1F+ghiCdS6KDJZfdy7MG2p8W2oBUXQYiHa9JreT+ZgmH65
C0yXFsPRtTtjbP+EXCDMUlsG8x0+I1R+cM2CWfO3lyKewzlk29EO6gidEw9vDZbL
X1LwhudfXgbtu3qOZzMFlpBPTHQxDa6WQ77NjHUZHgEkmr33WoULeyyzS1HAekHL
uoW8JSTa5+Ap9kO0aOhUDQu0LnYDtTacUpplcXNCW8rnvBBiTTfUvRYCaMrd9hEp
7ZA3li/FgNbk5AGsF5g0MSCIPNVqNR2ZuVt8Fzy2bkR50sVc8j4/b5J6xvt31Lcs
j3QeYriKpKCM/aUg0YYApbTuE+H0rX5TtcE99Vbka82ipbqPgBbcjHMV/EPRpucr
6/Ga/oE0oW7nI8/UK5Sab7ZDTjEiKM9mjPsCPWosZOByhPJQR/8O5BLIgmdZGSSs
w/NC8YRzGrNi4+m7gcv679kU0t9xhXk5y64RL5Akls4Ynn7e0wfbxif/ArRrVWUK
8ygIYN90pytl20GA5wndLUcSBzngDQfHK71qO69jqBZe7OB3HPduJPDmdfZMOah6
qm8LQfxczrSIvM5/kx65
=RvxY
-----END PGP SIGNATURE-----

--ZcaUvQ23gCOmDTXi--
