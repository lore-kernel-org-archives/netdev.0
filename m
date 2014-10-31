From: Ben Hutchings <ben@decadent.org.uk>
Subject: [PATCH net] drivers/net: macvtap and tun depend on INET
Date: Fri, 31 Oct 2014 03:10:31 +0000
Message-ID: <1414725031.16849.78.camel@decadent.org.uk>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-m8VRZL9oXcI9eHe2pHxs"
Cc: fengguang.wu@intel.com
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:49904 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753119AbaJaDKr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Oct 2014 23:10:47 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-m8VRZL9oXcI9eHe2pHxs
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

These drivers now call ipv6_proxy_select_ident(), which is defined
only if CONFIG_INET is enabled.  However, they have really depended
on CONFIG_INET for as long as they have allowed sending GSO packets
from userland.

Reported-by: kbuild test robot <fengguang.wu@intel.com>
Signed-off-by: Ben Hutchings <ben@decadent.org.uk>
Fixes: f43798c27684 ("tun: Allow GSO using virtio_net_hdr")
Fixes: b9fb9ee07e67 ("macvtap: add GSO/csum offload support")
Fixes: 5188cd44c55d ("drivers/net, ipv6: Select IPv6 fragment idents for vi=
rtio UFO packets")
---
 drivers/net/Kconfig | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
index 4706386..f9009be 100644
--- a/drivers/net/Kconfig
+++ b/drivers/net/Kconfig
@@ -135,6 +135,7 @@ config MACVLAN
 config MACVTAP
 	tristate "MAC-VLAN based tap driver"
 	depends on MACVLAN
+	depends on INET
 	help
 	  This adds a specialized tap character device driver that is based
 	  on the MAC-VLAN network interface, called macvtap. A macvtap device
@@ -200,6 +201,7 @@ config RIONET_RX_SIZE
=20
 config TUN
 	tristate "Universal TUN/TAP device driver support"
+	depends on INET
 	select CRC32
 	---help---
 	  TUN/TAP provides packet reception and transmission for user space

--=20
Ben Hutchings
The world is coming to an end.	Please log off.

--=-m8VRZL9oXcI9eHe2pHxs
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIVAwUAVFL9ree/yOyVhhEJAQrmVA//eTQTBm4zMHJSEMuwR0gFeb0pUQDEkp6s
/d4syrKtU9YHMrVpOTI6nDh/QrC4xoJMtuASzBvY9yKSNQsWf1bo/Yj3N8CCHFx1
1P05fNAkkKcCA19rxtxymoRG/9ey6ZqOp1bmqZLtHB1sfWmo2XY/MmK8SdtvOrZY
vYFcSAju9+a5godyhPDxgHMBEd4TAZ0wZqmPAV2E7IAian10WlL4Kk9GuCmQr7ii
vS5W4G3KDK68ht3BFpbLj7TLufaVz+qjOwsfS26IYPyWw2GYjZtyAN6y0K3jxUAJ
8eEwjDbtqIntuHuDfstdJJmc7L7NBIsIKSr933NXR9+dgWWQ8W29zOuOObdy9kUY
6CmK3wGfW2p3hOawZbloCPvZXzpCngDPqWsEOe+LCZZdn8eZ333qaYDaymI/u3kQ
qEhjKpAeCLxUmVbgQBWS9vhthUzQorJoVZv2jLgOZCOr2Frh1vBk6PFbcywyj9S8
2ZFQYS6JNVkN+RmnbLtZIwFgLuzEahcqinhLrIZqJTengiuX3II65O2DYWDcsAW8
cMoMyJKWwwnD6zUQ8F1lOz/cbkwcoH32RnOixkSn1nhnf97+4EWRTByMc/zXkdoD
OWWm80qebbl3m5zlb+P4NOnT0hqhk6eiYvjtwh0pTx7gopnt73AebErtmiOvDpwz
4LBTyeL5P7k=
=LBeW
-----END PGP SIGNATURE-----

--=-m8VRZL9oXcI9eHe2pHxs--
