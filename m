From: Ben Hutchings <ben@decadent.org.uk>
Subject: [PATCH net-next] cassini: Make missing firmware non-fatal
Date: Mon, 01 Jul 2013 00:13:27 +0100
Message-ID: <1372634007.5155.51.camel@deadeye.wl.decadent.org.uk>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-avYUO6uWSs+KlAn3Tlq1"
Cc: Jose Andres Arias Velichko <Andres.Arias@PaisLinux.net>,
	712674@bugs.debian.org, netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:46438 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751732Ab3F3XNk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 30 Jun 2013 19:13:40 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-avYUO6uWSs+KlAn3Tlq1
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

The firmware patch for the Saturn PHY fixes a bug, but is not absolutely
essential.  And its licence is unclear, so it is not included in all
distributions.  Just log an error message and continue if it is missing
or invalid.

References: http://bugs.debian.org/712674
Signed-off-by: Ben Hutchings <ben@decadent.org.uk>
Tested-by: Jose Andres Arias Velichko <Andres.Arias@PaisLinux.net> (against=
 3.2)
---
 drivers/net/ethernet/sun/cassini.c |   18 ++++++++----------
 1 file changed, 8 insertions(+), 10 deletions(-)

diff --git a/drivers/net/ethernet/sun/cassini.c b/drivers/net/ethernet/sun/=
cassini.c
index 4c682a3..759441b 100644
--- a/drivers/net/ethernet/sun/cassini.c
+++ b/drivers/net/ethernet/sun/cassini.c
@@ -808,44 +808,43 @@ static int cas_reset_mii_phy(struct cas *cp)
 	return limit <=3D 0;
 }
=20
-static int cas_saturn_firmware_init(struct cas *cp)
+static void cas_saturn_firmware_init(struct cas *cp)
 {
 	const struct firmware *fw;
 	const char fw_name[] =3D "sun/cassini.bin";
 	int err;
=20
 	if (PHY_NS_DP83065 !=3D cp->phy_id)
-		return 0;
+		return;
=20
 	err =3D request_firmware(&fw, fw_name, &cp->pdev->dev);
 	if (err) {
 		pr_err("Failed to load firmware \"%s\"\n",
 		       fw_name);
-		return err;
+		return;
 	}
 	if (fw->size < 2) {
 		pr_err("bogus length %zu in \"%s\"\n",
 		       fw->size, fw_name);
-		err =3D -EINVAL;
 		goto out;
 	}
 	cp->fw_load_addr=3D fw->data[1] << 8 | fw->data[0];
 	cp->fw_size =3D fw->size - 2;
 	cp->fw_data =3D vmalloc(cp->fw_size);
-	if (!cp->fw_data) {
-		err =3D -ENOMEM;
+	if (!cp->fw_data)
 		goto out;
-	}
 	memcpy(cp->fw_data, &fw->data[2], cp->fw_size);
 out:
 	release_firmware(fw);
-	return err;
 }
=20
 static void cas_saturn_firmware_load(struct cas *cp)
 {
 	int i;
=20
+	if (!cp->fw_data)
+		return;
+
 	cas_phy_powerdown(cp);
=20
 	/* expanded memory access mode */
@@ -5083,8 +5082,7 @@ static int cas_init_one(struct pci_dev *pdev, const s=
truct pci_device_id *ent)
 	if (cas_check_invariants(cp))
 		goto err_out_iounmap;
 	if (cp->cas_flags & CAS_FLAG_SATURN)
-		if (cas_saturn_firmware_init(cp))
-			goto err_out_iounmap;
+		cas_saturn_firmware_init(cp);
=20
 	cp->init_block =3D (struct cas_init_block *)
 		pci_alloc_consistent(pdev, sizeof(struct cas_init_block),


--=-avYUO6uWSs+KlAn3Tlq1
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIVAwUAUdC7l+e/yOyVhhEJAQrg3Q/+J33iTnl44d7INAgIYGDTWxcKZZCaaWww
I4sxKGmkegXfUZYwjvr3RQogi+BVP54O5Fdtigw5q3rCOpHvju6s8qOfjx+hOtHc
yMK16TXEHJIE5+6/7ouOwQH4ALxD2HgDByNL2mN1zjnOpnBDCPMp9o1n4vhWPcKr
t7gagq8qbgnu9sh51b7EmU+60qTs4pvN+al7a2IIdaof8Bn58WayntOOJC5PB4Rm
zzXbjR1EZL8x1e0hIMHGNiRorwLRkKEIXGCe4fW8Rq5A3x2bQdzYYfNdaiZ45i3I
VZG044SIYXfSfZts0SkwyKNgXu2/4slVlL9s0rMJPPgUOkrJB8wHDq1Pt70yOHZi
uH8eVTnL3Hwup8IeZKpyraCgzepbAkCaaAEEr5X7a0ZvH/c3OLLL8eblBG8/jRa6
dW8Q4ezqFZKfNRmPWwns6BbhQx/Jw51zug4e5kXa5aj6bV0CHHzhVvmNWZJ4plKm
RoBpNmdhKCKBLNPGiIwrGahZdSjEhxNEp24jho3iKdLVLZbMz76kJUQABZ9Z6HkP
U6qWb5CDO9OAbQSHAqGhi6T22+tGwbk6EDvLrOJQwQa61pMtSUKs/sEF+9OK5RWt
YIaGj3jNLXe2P99Io/13/Q/XWvy3FV2vD4tD7gK8xaFK9dqrOxyzN6lf6SLHzg32
mAH1Z/oJJ4E=
=4KQ0
-----END PGP SIGNATURE-----

--=-avYUO6uWSs+KlAn3Tlq1--
