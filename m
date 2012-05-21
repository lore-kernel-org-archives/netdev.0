From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: manual merge of the usb tree with the net-next tree
Date: Mon, 21 May 2012 16:10:08 +1000
Message-ID: <20120521161008.c0cc00b91642ed7a3875a686@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA256";
 boundary="Signature=_Mon__21_May_2012_16_10_08_+1000_9W0ZzipgqzcrEk5N"
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Sarah Sharp <sarah.a.sharp@linux.intel.com>,
	Kalle Valo <kvalo@qca.qualcomm.com>,
	David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>,
	"John W. Linville" <linville@tuxdriver.com>
To: Greg KH <greg@kroah.com>
Return-path: <linux-next-owner@vger.kernel.org>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Signature=_Mon__21_May_2012_16_10_08_+1000_9W0ZzipgqzcrEk5N
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi Greg,

Today's linux-next merge of the usb tree got a conflict in
drivers/net/wireless/ath/ath6kl/usb.c between commit 9cbee358687e
("ath6kl: add full USB support") from the net-next tree and commit
e1f12eb6ba6f ("USB: Disable hub-initiated LPM for comms devices") from
the usb tree.

Just context changes.  I fixed it up (see below) and can carry the fix as
necessary.
--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

diff --cc drivers/net/wireless/ath/ath6kl/usb.c
index dfbbe9e,f8a27db..0000000
--- a/drivers/net/wireless/ath/ath6kl/usb.c
+++ b/drivers/net/wireless/ath/ath6kl/usb.c
@@@ -1185,12 -403,9 +1185,13 @@@ MODULE_DEVICE_TABLE(usb, ath6kl_usb_ids
  static struct usb_driver ath6kl_usb_driver =3D {
  	.name =3D "ath6kl_usb",
  	.probe =3D ath6kl_usb_probe,
 +	.suspend =3D ath6kl_usb_suspend,
 +	.resume =3D ath6kl_usb_resume,
 +	.reset_resume =3D ath6kl_usb_reset_resume,
  	.disconnect =3D ath6kl_usb_remove,
  	.id_table =3D ath6kl_usb_ids,
 +	.supports_autosuspend =3D true,
+ 	.disable_hub_initiated_lpm =3D 1,
  };
 =20
  static int ath6kl_usb_init(void)

--Signature=_Mon__21_May_2012_16_10_08_+1000_9W0ZzipgqzcrEk5N
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIcBAEBCAAGBQJPudxAAAoJEECxmPOUX5FEs3EQAInERwyZ2W1VLG/dZTl/OzTY
1hMYrhft6PXrB8t4XRZAQuHvR9EvRRE56CLY6cp1mmjTZmvec3onEKP2zW944gv3
qPmjJ5DEwhDX3Rabqtyq67skNvtZFczLud5ZLlwSmKBkc9ZqJ2uxDKaXI1YV1Hb3
bhE+KETEQbI/K42ZqmboJuHwBf6mAsg7u28ad2YGpu2ZAk2nAYmTEZxaffmzOXTm
2GMz52Qcx8OV8OS8X7lBFV8bbdN5yPP0d+0DhYWydTiAZqzgp0XCk+uGjmA89kP9
9OMfz2UVVbINbzNVUoWVrL0ztjFv0syor2Fx68BHFLEd9pkGjrtwbsy6lBbipoZK
Kp41tRyEiRkVbb5u4oiUvd1cipMqT5vyMsncJQgLPcJ32e4resfvvg/LAsD/TpNt
lo9AEmF+a73ZIHCjcvEFhlJjH+EUpV7IE03Du6zq0PqKrS4QYQJbCLAZacwTNNIN
pV2sdTqVlXMmgTYmuKG4SoBrtYqv7JKQGRoBNkxUKJD4I2a/v7/CEdL84j7MTcna
nLHPlazaF+lc+4c9+0MMoh9mis1VsX6R+UtJU6Xzp5/d3noTYUCbEBUG5m7aPbRF
+q4LrnFHpZjZikSwaabzzA2J25GBA3eeREfu4ioTgFmSPgVW4g8XCGKvxhy7Ropv
K7cPVaUjRlOksT9nVGn+
=xABq
-----END PGP SIGNATURE-----

--Signature=_Mon__21_May_2012_16_10_08_+1000_9W0ZzipgqzcrEk5N--
