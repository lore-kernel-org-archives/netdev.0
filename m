From: Ben Hutchings <ben@decadent.org.uk>
Subject: [PATCH 1/2] netdev: restore MAC address set and validate operations
Date: Fri, 10 Jul 2009 04:54:35 +0100
Message-ID: <1247198075.21924.129.camel@deadeye>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha1"; protocol="application/pgp-signature"; boundary="=-OPz4ut/z0s9SDca6XloY"
Cc: Stephen Hemminger <shemminger@vyatta.com>, stable@vger.kernel.org,
	536455@bugs.debian.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:50673 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751376AbZGJDyo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Jul 2009 23:54:44 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-OPz4ut/z0s9SDca6XloY
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

alloc_etherdev() used to install default implementations of these
operations, but they must now be explicitly installed in struct
net_device_ops.

Signed-off-by: Ben Hutchings <ben@decadent.org.uk>
---
Stephen Hemminger caught most of these omissions.  I think this covers
the rest.

This is applicable to 2.6.30 with small offsets in some files.

Ben.

 drivers/net/arm/ixp4xx_eth.c        |    3 ++-
 drivers/net/ehea/ehea_main.c        |    1 +
 drivers/net/gianfar.c               |    2 ++
 drivers/net/plip.c                  |    2 ++
 drivers/net/ps3_gelic_net.c         |    1 +
 drivers/net/ps3_gelic_wireless.c    |    1 +
 drivers/net/sunvnet.c               |    1 +
 drivers/net/usb/kaweth.c            |    2 ++
 drivers/net/usb/pegasus.c           |    2 ++
 drivers/net/wireless/orinoco/main.c |    3 ++-
 10 files changed, 16 insertions(+), 2 deletions(-)

diff --git a/drivers/net/arm/ixp4xx_eth.c b/drivers/net/arm/ixp4xx_eth.c
index 6f42ad7..87fde32 100644
--- a/drivers/net/arm/ixp4xx_eth.c
+++ b/drivers/net/arm/ixp4xx_eth.c
@@ -1142,7 +1142,8 @@ static const struct net_device_ops ixp4xx_netdev_ops =
=3D {
 	.ndo_start_xmit =3D eth_xmit,
 	.ndo_set_multicast_list =3D eth_set_mcast_list,
 	.ndo_do_ioctl =3D eth_ioctl,
-
+	.ndo_set_mac_address =3D eth_mac_addr,
+	.ndo_validate_addr =3D eth_validate_addr,
 };
=20
 static int __devinit eth_init_one(struct platform_device *pdev)
diff --git a/drivers/net/ehea/ehea_main.c b/drivers/net/ehea/ehea_main.c
index 147c4b0..c7d1886 100644
--- a/drivers/net/ehea/ehea_main.c
+++ b/drivers/net/ehea/ehea_main.c
@@ -3081,6 +3081,7 @@ static const struct net_device_ops ehea_netdev_ops =
=3D {
 #endif
 	.ndo_get_stats		=3D ehea_get_stats,
 	.ndo_set_mac_address	=3D ehea_set_mac_addr,
+	.ndo_validate_addr	=3D eth_validate_addr,
 	.ndo_set_multicast_list	=3D ehea_set_multicast_list,
 	.ndo_change_mtu		=3D ehea_change_mtu,
 	.ndo_vlan_rx_register	=3D ehea_vlan_rx_register,
diff --git a/drivers/net/gianfar.c b/drivers/net/gianfar.c
index 4ae1d25..43d813e 100644
--- a/drivers/net/gianfar.c
+++ b/drivers/net/gianfar.c
@@ -156,6 +156,8 @@ static const struct net_device_ops gfar_netdev_ops =3D =
{
 	.ndo_tx_timeout =3D gfar_timeout,
 	.ndo_do_ioctl =3D gfar_ioctl,
 	.ndo_vlan_rx_register =3D gfar_vlan_rx_register,
+	.ndo_set_mac_address =3D eth_mac_addr,
+	.ndo_validate_addr =3D eth_validate_addr,
 #ifdef CONFIG_NET_POLL_CONTROLLER
 	.ndo_poll_controller =3D gfar_netpoll,
 #endif
diff --git a/drivers/net/plip.c b/drivers/net/plip.c
index 7a62f78..b79f776 100644
--- a/drivers/net/plip.c
+++ b/drivers/net/plip.c
@@ -270,6 +270,8 @@ static const struct net_device_ops plip_netdev_ops =3D =
{
 	.ndo_stop		 =3D plip_close,
 	.ndo_start_xmit		 =3D plip_tx_packet,
 	.ndo_do_ioctl		 =3D plip_ioctl,
+	.ndo_set_mac_address	 =3D eth_mac_addr,
+	.ndo_validate_addr	 =3D eth_validate_addr,
 };
=20
 /* Entry point of PLIP driver.
diff --git a/drivers/net/ps3_gelic_net.c b/drivers/net/ps3_gelic_net.c
index d1a5fb4..a3932c9 100644
--- a/drivers/net/ps3_gelic_net.c
+++ b/drivers/net/ps3_gelic_net.c
@@ -1411,6 +1411,7 @@ static const struct net_device_ops gelic_netdevice_op=
s =3D {
 	.ndo_set_multicast_list =3D gelic_net_set_multi,
 	.ndo_change_mtu =3D gelic_net_change_mtu,
 	.ndo_tx_timeout =3D gelic_net_tx_timeout,
+	.ndo_set_mac_address =3D eth_mac_addr,
 	.ndo_validate_addr =3D eth_validate_addr,
 #ifdef CONFIG_NET_POLL_CONTROLLER
 	.ndo_poll_controller =3D gelic_net_poll_controller,
diff --git a/drivers/net/ps3_gelic_wireless.c b/drivers/net/ps3_gelic_wirel=
ess.c
index b6b3ca9..6932b08 100644
--- a/drivers/net/ps3_gelic_wireless.c
+++ b/drivers/net/ps3_gelic_wireless.c
@@ -2707,6 +2707,7 @@ static const struct net_device_ops gelic_wl_netdevice=
_ops =3D {
 	.ndo_set_multicast_list =3D gelic_net_set_multi,
 	.ndo_change_mtu =3D gelic_net_change_mtu,
 	.ndo_tx_timeout =3D gelic_net_tx_timeout,
+	.ndo_set_mac_address =3D eth_mac_addr,
 	.ndo_validate_addr =3D eth_validate_addr,
 #ifdef CONFIG_NET_POLL_CONTROLLER
 	.ndo_poll_controller =3D gelic_net_poll_controller,
diff --git a/drivers/net/sunvnet.c b/drivers/net/sunvnet.c
index a82fb2a..bc74db0 100644
--- a/drivers/net/sunvnet.c
+++ b/drivers/net/sunvnet.c
@@ -1017,6 +1017,7 @@ static const struct net_device_ops vnet_ops =3D {
 	.ndo_stop		=3D vnet_close,
 	.ndo_set_multicast_list	=3D vnet_set_rx_mode,
 	.ndo_set_mac_address	=3D vnet_set_mac_addr,
+	.ndo_validate_addr	=3D eth_validate_addr,
 	.ndo_tx_timeout		=3D vnet_tx_timeout,
 	.ndo_change_mtu		=3D vnet_change_mtu,
 	.ndo_start_xmit		=3D vnet_start_xmit,
diff --git a/drivers/net/usb/kaweth.c b/drivers/net/usb/kaweth.c
index e013147..238bea1 100644
--- a/drivers/net/usb/kaweth.c
+++ b/drivers/net/usb/kaweth.c
@@ -999,6 +999,8 @@ static const struct net_device_ops kaweth_netdev_ops =
=3D {
 	.ndo_tx_timeout =3D		kaweth_tx_timeout,
 	.ndo_set_multicast_list =3D	kaweth_set_rx_mode,
 	.ndo_get_stats =3D		kaweth_netdev_stats,
+	.ndo_set_mac_address =3D		eth_mac_addr,
+	.ndo_validate_addr =3D		eth_validate_addr,
 };
=20
 static int kaweth_probe(
diff --git a/drivers/net/usb/pegasus.c b/drivers/net/usb/pegasus.c
index 73acbd2..9bea2af 100644
--- a/drivers/net/usb/pegasus.c
+++ b/drivers/net/usb/pegasus.c
@@ -1493,6 +1493,8 @@ static const struct net_device_ops pegasus_netdev_ops=
 =3D {
 	.ndo_set_multicast_list =3D	pegasus_set_multicast,
 	.ndo_get_stats =3D		pegasus_netdev_stats,
 	.ndo_tx_timeout =3D		pegasus_tx_timeout,
+	.ndo_set_mac_address =3D		eth_mac_addr,
+	.ndo_validate_addr =3D		eth_validate_addr,
 };
=20
 static struct usb_driver pegasus_driver =3D {
diff --git a/drivers/net/wireless/orinoco/main.c b/drivers/net/wireless/ori=
noco/main.c
index 345593c..a370e51 100644
--- a/drivers/net/wireless/orinoco/main.c
+++ b/drivers/net/wireless/orinoco/main.c
@@ -2521,6 +2521,8 @@ static const struct net_device_ops orinoco_netdev_ops=
 =3D {
 	.ndo_start_xmit		=3D orinoco_xmit,
 	.ndo_set_multicast_list	=3D orinoco_set_multicast_list,
 	.ndo_change_mtu		=3D orinoco_change_mtu,
+	.ndo_set_mac_address	=3D eth_mac_addr,
+	.ndo_validate_addr	=3D eth_validate_addr,
 	.ndo_tx_timeout		=3D orinoco_tx_timeout,
 	.ndo_get_stats		=3D orinoco_get_stats,
 };
@@ -2555,7 +2557,6 @@ struct net_device
 	priv->wireless_data.spy_data =3D &priv->spy_data;
 	dev->wireless_data =3D &priv->wireless_data;
 #endif
-	/* we use the default eth_mac_addr for setting the MAC addr */
=20
 	/* Reserve space in skb for the SNAP header */
 	dev->hard_header_len +=3D ENCAPS_OVERHEAD;
--=20
1.6.3.3



--=-OPz4ut/z0s9SDca6XloY
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.9 (GNU/Linux)

iD8DBQBKVrt379ZNCRIGYgcRAjCwAKCp8O769F5JvLlmCVgXyNiQAiQddQCgrmfM
X+IZRlVPU1IVRVxHFFqOmn0=
=ouxW
-----END PGP SIGNATURE-----

--=-OPz4ut/z0s9SDca6XloY--
