From: Ben Hutchings <ben-/+tVBieCtBitmTQ+vhA3Yw@public.gmane.org>
Subject: [PATCH net 3/4] catc: Combine failure cleanup code in catc_probe()
Date: Sat, 4 Feb 2017 16:56:56 +0000
Message-ID: <20170204165656.GX3442@decadent.org.uk>
References: <20170204165451.GU3442@decadent.org.uk>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha512;
        protocol="application/pgp-signature"; boundary="3ioKt2kN+IccB5F4"
Cc: linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20170204165451.GU3442-/+tVBieCtBitmTQ+vhA3Yw@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


--3ioKt2kN+IccB5F4
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Signed-off-by: Ben Hutchings <ben-/+tVBieCtBitmTQ+vhA3Yw@public.gmane.org>
---
 drivers/net/usb/catc.c | 33 +++++++++++++++++----------------
 1 file changed, 17 insertions(+), 16 deletions(-)

diff --git a/drivers/net/usb/catc.c b/drivers/net/usb/catc.c
index 3daa41bdd4ea..985909eab72c 100644
--- a/drivers/net/usb/catc.c
+++ b/drivers/net/usb/catc.c
@@ -776,7 +776,7 @@ static int catc_probe(struct usb_interface *intf, const=
 struct usb_device_id *id
 	struct net_device *netdev;
 	struct catc *catc;
 	u8 broadcast[ETH_ALEN];
-	int i, pktsz;
+	int i, pktsz, ret;
=20
 	if (usb_set_interface(usbdev,
 			intf->altsetting->desc.bInterfaceNumber, 1)) {
@@ -811,12 +811,8 @@ static int catc_probe(struct usb_interface *intf, cons=
t struct usb_device_id *id
 	if ((!catc->ctrl_urb) || (!catc->tx_urb) ||=20
 	    (!catc->rx_urb) || (!catc->irq_urb)) {
 		dev_err(&intf->dev, "No free urbs available.\n");
-		usb_free_urb(catc->ctrl_urb);
-		usb_free_urb(catc->tx_urb);
-		usb_free_urb(catc->rx_urb);
-		usb_free_urb(catc->irq_urb);
-		free_netdev(netdev);
-		return -ENOMEM;
+		ret =3D -ENOMEM;
+		goto fail_free;
 	}
=20
 	/* The F5U011 has the same vendor/product as the netmate but a device ver=
sion of 0x130 */
@@ -913,16 +909,21 @@ static int catc_probe(struct usb_interface *intf, con=
st struct usb_device_id *id
 	usb_set_intfdata(intf, catc);
=20
 	SET_NETDEV_DEV(netdev, &intf->dev);
-	if (register_netdev(netdev) !=3D 0) {
-		usb_set_intfdata(intf, NULL);
-		usb_free_urb(catc->ctrl_urb);
-		usb_free_urb(catc->tx_urb);
-		usb_free_urb(catc->rx_urb);
-		usb_free_urb(catc->irq_urb);
-		free_netdev(netdev);
-		return -EIO;
-	}
+	ret =3D register_netdev(netdev);
+	if (ret)
+		goto fail_clear_intfdata;
+
 	return 0;
+
+fail_clear_intfdata:
+	usb_set_intfdata(intf, NULL);
+fail_free:
+	usb_free_urb(catc->ctrl_urb);
+	usb_free_urb(catc->tx_urb);
+	usb_free_urb(catc->rx_urb);
+	usb_free_urb(catc->irq_urb);
+	free_netdev(netdev);
+	return ret;
 }
=20
 static void catc_disconnect(struct usb_interface *intf)


--3ioKt2kN+IccB5F4
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIVAwUBWJYH2Oe/yOyVhhEJAQoxug//T6elJGdJ8Cb8+qKjZVxieDauYuX23wgf
cHIrXlg6lHfFeTXPYWq7FOADkuM++5WOmUPW84wRAeoZBaXuvOvpWGNhIPF9IU0n
kCIkCzCkJ75EszcFDCm1GXkRdnkFqnR/nk/mscJfj0jxs3hvRu7h/0QhzR7i+LZU
U07ng0IoB+u0XjZnWiv9E2yPKM3KyJoknMLazTTgzsU5r1QsXbHf/dVtpZD/o0AD
Qax/X5KYPchSUxXlxK8ZXBpf3c/hteuAamt+58tAmNzd9SOniBcS+Uq3f5vhBkru
WJeNgKBcrtPJzMZmSVQTw2J8aDFzznRk1ReuGSXfnTBTqz5pyZvlQf5zPHO4Ii/K
1ehjF0K96bbRbPw4TUgq31va2/XP71C0luZiauq1gA2VTLam0RH0jzP/kvOOZ/r2
D3z8XlajZsh5wYM7LplkPDe2TiJd9PU51dSNGLGbUoKajNpSsOYzqu5eM8FkhLq/
y05XfEl5rKAz9edPS455q34jRiQa2pI8BNGCyvwHBusX/8M/basON/SNoj092l2K
zhfOVKih5OeqcBRR5WRQLRwXEEWICFAw20aTWlaFXdNAw1/anYXHpqi8sBIFdGcW
uRpKBk9Q5d/KqdOMOxsqmrK1hHbM79R1q9oiZKSDlZPdgBURN2jzZdzTytXR1+6R
k7BbVQLFyOA=
=sNnH
-----END PGP SIGNATURE-----

--3ioKt2kN+IccB5F4--
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
