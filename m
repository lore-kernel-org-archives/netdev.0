From: maximilian attems <janitor@sternwelten.at>
Subject: [patch] handle kmalloc fails: tokenring/3c359
Date: Tue, 23 Dec 2003 11:57:57 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031223105757.GB1486@mail.sternwelten.at>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="3uo+9/B/ebqu+fSQ"
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: kj <kernel-janitors@osdl.org>
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--3uo+9/B/ebqu+fSQ
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

while looking at kj mails from 200212 and 200301
this patch slept through
originally from: Pablo Menichini <pablo@menichini.com.ar>
rediffed and compile tested
patch applies on plain 2.6.0

a++
max


--- a/drivers/net/tokenring/3c359.c	2003-10-08 21:24:51.000000000 +0200
+++ b/drivers/net/tokenring/3c359.c	2003-12-23 10:18:27.000000000 +0100
@@ -642,7 +642,20 @@
 	 */
 	/* These MUST be on 8 byte boundaries */
 	xl_priv->xl_tx_ring =3D kmalloc((sizeof(struct xl_tx_desc) * XL_TX_RING_S=
IZE) + 7, GFP_DMA | GFP_KERNEL) ;=20
+	if (xl_priv->xl_tx_ring =3D=3D NULL) {
+		printk(KERN_WARNING "%s: Not enough memory to allocate rx buffers.\n",
+				     dev->name);
+		free_irq(dev->irq,dev);
+		return -ENOMEM;
+	}
 	xl_priv->xl_rx_ring =3D kmalloc((sizeof(struct xl_rx_desc) * XL_RX_RING_S=
IZE) +7, GFP_DMA | GFP_KERNEL) ;=20
+	if (xl_priv->xl_tx_ring =3D=3D NULL) {
+		printk(KERN_WARNING "%s: Not enough memory to allocate rx buffers.\n",
+				     dev->name);
+		free_irq(dev->irq,dev);
+		kfree(xl_priv->xl_tx_ring);
+		return -ENOMEM;
+	}
 	memset(xl_priv->xl_tx_ring,0,sizeof(struct xl_tx_desc) * XL_TX_RING_SIZE)=
 ;=20
 	memset(xl_priv->xl_rx_ring,0,sizeof(struct xl_rx_desc) * XL_RX_RING_SIZE)=
 ;=20
=20

--3uo+9/B/ebqu+fSQ
Content-Type: application/pgp-signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.3 (GNU/Linux)

iD8DBQE/6B+16//kSTNjoX0RAqpKAKCIiQvZAsXIWsQNM2NTPjyYhs8KVQCfQFKH
orACopW0Jof1yeaOhfrKcL0=
=zE07
-----END PGP SIGNATURE-----

--3uo+9/B/ebqu+fSQ--
