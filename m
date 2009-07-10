From: Ben Hutchings <ben@decadent.org.uk>
Subject: [PATCH 2/2] netdev: restore MTU change operation
Date: Fri, 10 Jul 2009 04:59:01 +0100
Message-ID: <1247198341.21924.133.camel@deadeye>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha1"; protocol="application/pgp-signature"; boundary="=-TKa8p1Z7fK58l9mQsBlI"
Cc: Stephen Hemminger <shemminger@vyatta.com>, stable@vger.kernel.org,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:54975 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751343AbZGJD7H (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Jul 2009 23:59:07 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-TKa8p1Z7fK58l9mQsBlI
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

alloc_etherdev() used to install a default implementation of this
operation, but it must now be explicitly installed in struct
net_device_ops.

Signed-off-by: Ben Hutchings <ben@decadent.org.uk>
---
Sorry about the previous copy without S-o-b.

It's not clear that all these drivers should allow changing MTU, but
they apparently used to.

This is applicable to 2.6.30 except that fec.c does not need to be
changed.

Ben.

 drivers/net/8139too.c        |    1 +
 drivers/net/arm/ixp4xx_eth.c |    1 +
 drivers/net/ehea/ehea_main.c |    1 +
 drivers/net/fec.c            |    1 +
 drivers/net/plip.c           |    1 +
 drivers/net/smc91x.c         |    1 +
 drivers/net/smsc911x.c       |    1 +
 drivers/net/sunvnet.c        |    1 +
 drivers/net/usb/kaweth.c     |    1 +
 drivers/net/usb/pegasus.c    |    1 +
 drivers/net/via-rhine.c      |    1 +
 11 files changed, 11 insertions(+), 0 deletions(-)

diff --git a/drivers/net/8139too.c b/drivers/net/8139too.c
index 8ae72ec..0e2ba21 100644
--- a/drivers/net/8139too.c
+++ b/drivers/net/8139too.c
@@ -908,6 +908,7 @@ static const struct net_device_ops rtl8139_netdev_ops =
=3D {
 	.ndo_open		=3D rtl8139_open,
 	.ndo_stop		=3D rtl8139_close,
 	.ndo_get_stats		=3D rtl8139_get_stats,
+	.ndo_change_mtu		=3D eth_change_mtu,
 	.ndo_validate_addr	=3D eth_validate_addr,
 	.ndo_set_mac_address 	=3D rtl8139_set_mac_address,
 	.ndo_start_xmit		=3D rtl8139_start_xmit,
diff --git a/drivers/net/arm/ixp4xx_eth.c b/drivers/net/arm/ixp4xx_eth.c
index 87fde32..3fe0987 100644
--- a/drivers/net/arm/ixp4xx_eth.c
+++ b/drivers/net/arm/ixp4xx_eth.c
@@ -1142,6 +1142,7 @@ static const struct net_device_ops ixp4xx_netdev_ops =
=3D {
 	.ndo_start_xmit =3D eth_xmit,
 	.ndo_set_multicast_list =3D eth_set_mcast_list,
 	.ndo_do_ioctl =3D eth_ioctl,
+	.ndo_change_mtu =3D eth_change_mtu,
 	.ndo_set_mac_address =3D eth_mac_addr,
 	.ndo_validate_addr =3D eth_validate_addr,
 };
diff --git a/drivers/net/ehea/ehea_main.c b/drivers/net/ehea/ehea_main.c
index c7d1886..e8d46cc 100644
--- a/drivers/net/ehea/ehea_main.c
+++ b/drivers/net/ehea/ehea_main.c
@@ -3080,6 +3080,7 @@ static const struct net_device_ops ehea_netdev_ops =
=3D {
 	.ndo_poll_controller	=3D ehea_netpoll,
 #endif
 	.ndo_get_stats		=3D ehea_get_stats,
+	.ndo_change_mtu		=3D eth_change_mtu,
 	.ndo_set_mac_address	=3D ehea_set_mac_addr,
 	.ndo_validate_addr	=3D eth_validate_addr,
 	.ndo_set_multicast_list	=3D ehea_set_multicast_list,
diff --git a/drivers/net/fec.c b/drivers/net/fec.c
index 0f19b74..d4b9807 100644
--- a/drivers/net/fec.c
+++ b/drivers/net/fec.c
@@ -1642,6 +1642,7 @@ static const struct net_device_ops fec_netdev_ops =3D=
 {
 	.ndo_stop		=3D fec_enet_close,
 	.ndo_start_xmit		=3D fec_enet_start_xmit,
 	.ndo_set_multicast_list =3D set_multicast_list,
+	.ndo_change_mtu		=3D eth_change_mtu,
 	.ndo_validate_addr	=3D eth_validate_addr,
 	.ndo_tx_timeout		=3D fec_timeout,
 	.ndo_set_mac_address	=3D fec_set_mac_address,
diff --git a/drivers/net/plip.c b/drivers/net/plip.c
index b79f776..2ca8b0d 100644
--- a/drivers/net/plip.c
+++ b/drivers/net/plip.c
@@ -270,6 +270,7 @@ static const struct net_device_ops plip_netdev_ops =3D =
{
 	.ndo_stop		 =3D plip_close,
 	.ndo_start_xmit		 =3D plip_tx_packet,
 	.ndo_do_ioctl		 =3D plip_ioctl,
+	.ndo_change_mtu		 =3D eth_change_mtu,
 	.ndo_set_mac_address	 =3D eth_mac_addr,
 	.ndo_validate_addr	 =3D eth_validate_addr,
 };
diff --git a/drivers/net/smc91x.c b/drivers/net/smc91x.c
index fdcbaf8..1c70e99 100644
--- a/drivers/net/smc91x.c
+++ b/drivers/net/smc91x.c
@@ -1774,6 +1774,7 @@ static const struct net_device_ops smc_netdev_ops =3D=
 {
 	.ndo_start_xmit		=3D smc_hard_start_xmit,
 	.ndo_tx_timeout		=3D smc_timeout,
 	.ndo_set_multicast_list	=3D smc_set_multicast_list,
+	.ndo_change_mtu		=3D eth_change_mtu,
 	.ndo_validate_addr	=3D eth_validate_addr,
 	.ndo_set_mac_address 	=3D eth_mac_addr,
 #ifdef CONFIG_NET_POLL_CONTROLLER
diff --git a/drivers/net/smsc911x.c b/drivers/net/smsc911x.c
index 66067f9..94b6d26 100644
--- a/drivers/net/smsc911x.c
+++ b/drivers/net/smsc911x.c
@@ -1779,6 +1779,7 @@ static const struct net_device_ops smsc911x_netdev_op=
s =3D {
 	.ndo_get_stats		=3D smsc911x_get_stats,
 	.ndo_set_multicast_list	=3D smsc911x_set_multicast_list,
 	.ndo_do_ioctl		=3D smsc911x_do_ioctl,
+	.ndo_change_mtu		=3D eth_change_mtu,
 	.ndo_validate_addr	=3D eth_validate_addr,
 	.ndo_set_mac_address 	=3D smsc911x_set_mac_address,
 #ifdef CONFIG_NET_POLL_CONTROLLER
diff --git a/drivers/net/sunvnet.c b/drivers/net/sunvnet.c
index bc74db0..f1e5e45 100644
--- a/drivers/net/sunvnet.c
+++ b/drivers/net/sunvnet.c
@@ -1016,6 +1016,7 @@ static const struct net_device_ops vnet_ops =3D {
 	.ndo_open		=3D vnet_open,
 	.ndo_stop		=3D vnet_close,
 	.ndo_set_multicast_list	=3D vnet_set_rx_mode,
+	.ndo_change_mtu		=3D eth_change_mtu,
 	.ndo_set_mac_address	=3D vnet_set_mac_addr,
 	.ndo_validate_addr	=3D eth_validate_addr,
 	.ndo_tx_timeout		=3D vnet_tx_timeout,
diff --git a/drivers/net/usb/kaweth.c b/drivers/net/usb/kaweth.c
index 238bea1..1f9ec29 100644
--- a/drivers/net/usb/kaweth.c
+++ b/drivers/net/usb/kaweth.c
@@ -999,6 +999,7 @@ static const struct net_device_ops kaweth_netdev_ops =
=3D {
 	.ndo_tx_timeout =3D		kaweth_tx_timeout,
 	.ndo_set_multicast_list =3D	kaweth_set_rx_mode,
 	.ndo_get_stats =3D		kaweth_netdev_stats,
+	.ndo_change_mtu =3D		eth_change_mtu,
 	.ndo_set_mac_address =3D		eth_mac_addr,
 	.ndo_validate_addr =3D		eth_validate_addr,
 };
diff --git a/drivers/net/usb/pegasus.c b/drivers/net/usb/pegasus.c
index 9bea2af..631d269 100644
--- a/drivers/net/usb/pegasus.c
+++ b/drivers/net/usb/pegasus.c
@@ -1493,6 +1493,7 @@ static const struct net_device_ops pegasus_netdev_ops=
 =3D {
 	.ndo_set_multicast_list =3D	pegasus_set_multicast,
 	.ndo_get_stats =3D		pegasus_netdev_stats,
 	.ndo_tx_timeout =3D		pegasus_tx_timeout,
+	.ndo_change_mtu =3D		eth_change_mtu,
 	.ndo_set_mac_address =3D		eth_mac_addr,
 	.ndo_validate_addr =3D		eth_validate_addr,
 };
diff --git a/drivers/net/via-rhine.c b/drivers/net/via-rhine.c
index d3489a3..88c30a5 100644
--- a/drivers/net/via-rhine.c
+++ b/drivers/net/via-rhine.c
@@ -621,6 +621,7 @@ static const struct net_device_ops rhine_netdev_ops =3D=
 {
 	.ndo_start_xmit		 =3D rhine_start_tx,
 	.ndo_get_stats		 =3D rhine_get_stats,
 	.ndo_set_multicast_list	 =3D rhine_set_rx_mode,
+	.ndo_change_mtu		 =3D eth_change_mtu,
 	.ndo_validate_addr	 =3D eth_validate_addr,
 	.ndo_set_mac_address 	 =3D eth_mac_addr,
 	.ndo_do_ioctl		 =3D netdev_ioctl,
--=20
1.6.3.3


--=-TKa8p1Z7fK58l9mQsBlI
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.9 (GNU/Linux)

iD8DBQBKVryE79ZNCRIGYgcRAg/wAJ4minKmrgiGqbc1M+zMSPSN5V09iACgyxOD
ZZ9JxkeRIKF0j+2QkmE0u9M=
=xGxS
-----END PGP SIGNATURE-----

--=-TKa8p1Z7fK58l9mQsBlI--
