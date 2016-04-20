From: Ben Hutchings <ben@decadent.org.uk>
Subject: [PATCH net] atl2: Disable unimplemented scatter/gather feature
Date: Wed, 20 Apr 2016 23:23:08 +0100
Message-ID: <20160420222308.GJ3348@decadent.org.uk>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha512;
	protocol="application/pgp-signature"; boundary="sdJFN6SSISdF2ksn"
Cc: netdev@vger.kernel.org, Justin Yackoski <jyackoski@crypto-nite.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:52993 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751228AbcDTWXM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Apr 2016 18:23:12 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--sdJFN6SSISdF2ksn
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

atl2 includes NETIF_F_SG in hw_features even though it has no support
for non-linear skbs.  This bug was originally harmless since the
driver does not claim to implement checksum offload and that used to
be a requirement for SG.

Now that SG and checksum offload are independent features, if you
explicitly enable SG *and* use one of the rare protocols that can use
SG without checkusm offload, this potentially leaks sensitive
information (before you notice that it just isn't working).  Therefore
this obscure bug has been designated CVE-2016-2117.

Reported-by: Justin Yackoski <jyackoski@crypto-nite.com>
Signed-off-by: Ben Hutchings <ben@decadent.org.uk>
Fixes: ec5f06156423 ("net: Kill link between CSUM and SG features.")
---
 drivers/net/ethernet/atheros/atlx/atl2.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/atheros/atlx/atl2.c b/drivers/net/etherne=
t/atheros/atlx/atl2.c
index 8f76f4558a88..2ff465848b65 100644
--- a/drivers/net/ethernet/atheros/atlx/atl2.c
+++ b/drivers/net/ethernet/atheros/atlx/atl2.c
@@ -1412,7 +1412,7 @@ static int atl2_probe(struct pci_dev *pdev, const str=
uct pci_device_id *ent)
=20
 	err =3D -EIO;
=20
-	netdev->hw_features =3D NETIF_F_SG | NETIF_F_HW_VLAN_CTAG_RX;
+	netdev->hw_features =3D NETIF_F_HW_VLAN_CTAG_RX;
 	netdev->features |=3D (NETIF_F_HW_VLAN_CTAG_TX | NETIF_F_HW_VLAN_CTAG_RX);
=20
 	/* Init PHY as early as possible due to power saving issue  */

--sdJFN6SSISdF2ksn
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIVAwUBVxgBS+e/yOyVhhEJAQrsPhAApyQDaIWvvjV+OQ0mnKf95phPWPX/g314
SKnFDYtJpo27zSRlAR7G4cFBFl2ulHTp0Q5gn8a4S+tGpxyp8ygJc4t9Si/iamwh
4/VRI21lm/WtoOb0CkisK9FDjb8gVS/6AaAz3NLEneCdEfNTbrLltz4tLzFzBkjO
/4bPjNlIdliqYZMNSgFtq+hzkVHa0iL7Mys2KUgkktTjlWhcAHEGahz9FW6r+ei3
c6cF8PnXRClQDkRsKEf+yIwCOmXD8Hg0Di3shV9KT7MQ2FP3lVJ32wJ0fZykmctE
wpmxVOVOEn/t7Nr1Rv0xWe3Jx/Bhw6hast2YSyyyt1BdAUq1VqIU+x9FrIJn52cW
XznHShoj4hd+1l6+LZeU+D1U+PiLNzUOTU4H+L7U6fq5B41GDV0wiaU02cmMZTZG
NZixjiQ3S8aGlpJII2qQdRuBSh5ehM1i5JEC+nKV82G0J9KHEX2FrrVsUErPL7gU
/R+ai4UUhEAnhaJDr/Hpxm/cnge8OsMApUJiDm+ihejbmPRANmktZmtt9HKsnR0O
hpUuO337g/sNl48IOetd2ikEK8TvM8L8a4Qery+jUBhK85UeHMjje6Ob9MF7O57c
kkm3hombHHmB0fsHzY/n22JPAbN5JfVAFtJalDMKxqWTOEw8+z8k0goJzAHTQ1nn
h/71eyl0gOI=
=HQBr
-----END PGP SIGNATURE-----

--sdJFN6SSISdF2ksn--
