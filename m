From: =?UTF-8?q?Micha=C5=82=20Miros=C5=82aw?= <mirq-linux@rere.qmqm.pl>
Subject: [PATCH] net: ehea: convert to hw_features
Date: Sun, 17 Apr 2011 12:15:47 +0200 (CEST)
Message-ID: <20110417101547.11CF913A69@rere.qmqm.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Breno Leitao <leitao@linux.vnet.ibm.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rere.qmqm.pl ([89.167.52.164]:48107 "EHLO rere.qmqm.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756589Ab1DQKPt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 17 Apr 2011 06:15:49 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Micha=C5=82 Miros=C5=82aw <mirq-linux@rere.qmqm.pl>
---
 drivers/net/ehea/ehea_ethtool.c |   23 -----------------------
 drivers/net/ehea/ehea_main.c    |    4 +++-
 2 files changed, 3 insertions(+), 24 deletions(-)

diff --git a/drivers/net/ehea/ehea_ethtool.c b/drivers/net/ehea/ehea_et=
htool.c
index 3e2e734..5f13491 100644
--- a/drivers/net/ehea/ehea_ethtool.c
+++ b/drivers/net/ehea/ehea_ethtool.c
@@ -162,11 +162,6 @@ static void ehea_set_msglevel(struct net_device *d=
ev, u32 value)
 	port->msg_enable =3D value;
 }
=20
-static u32 ehea_get_rx_csum(struct net_device *dev)
-{
-	return 1;
-}
-
 static char ehea_ethtool_stats_keys[][ETH_GSTRING_LEN] =3D {
 	{"sig_comp_iv"},
 	{"swqe_refill_th"},
@@ -263,34 +258,16 @@ static void ehea_get_ethtool_stats(struct net_dev=
ice *dev,
=20
 }
=20
-static int ehea_set_flags(struct net_device *dev, u32 data)
-{
-	/* Avoid changing the VLAN flags */
-	if ((data & (ETH_FLAG_RXVLAN | ETH_FLAG_TXVLAN)) !=3D
-	    (ethtool_op_get_flags(dev) & (ETH_FLAG_RXVLAN |
-					  ETH_FLAG_TXVLAN))){
-		return -EINVAL;
-	}
-
-	return ethtool_op_set_flags(dev, data, ETH_FLAG_LRO
-					| ETH_FLAG_TXVLAN
-					| ETH_FLAG_RXVLAN);
-}
-
 const struct ethtool_ops ehea_ethtool_ops =3D {
 	.get_settings =3D ehea_get_settings,
 	.get_drvinfo =3D ehea_get_drvinfo,
 	.get_msglevel =3D ehea_get_msglevel,
 	.set_msglevel =3D ehea_set_msglevel,
 	.get_link =3D ethtool_op_get_link,
-	.set_tso =3D ethtool_op_set_tso,
 	.get_strings =3D ehea_get_strings,
 	.get_sset_count =3D ehea_get_sset_count,
 	.get_ethtool_stats =3D ehea_get_ethtool_stats,
-	.get_rx_csum =3D ehea_get_rx_csum,
 	.set_settings =3D ehea_set_settings,
-	.get_flags =3D ethtool_op_get_flags,
-	.set_flags =3D ehea_set_flags,
 	.nway_reset =3D ehea_nway_reset,		/* Restart autonegotiation */
 };
=20
diff --git a/drivers/net/ehea/ehea_main.c b/drivers/net/ehea/ehea_main.=
c
index f75d314..ce2f0ca 100644
--- a/drivers/net/ehea/ehea_main.c
+++ b/drivers/net/ehea/ehea_main.c
@@ -3262,10 +3262,12 @@ struct ehea_port *ehea_setup_single_port(struct=
 ehea_adapter *adapter,
 	dev->netdev_ops =3D &ehea_netdev_ops;
 	ehea_set_ethtool_ops(dev);
=20
+	dev->hw_features =3D NETIF_F_SG | NETIF_F_FRAGLIST | NETIF_F_TSO
+		      | NETIF_F_IP_CSUM | NETIF_F_HW_VLAN_TX | NETIF_F_LRO;
 	dev->features =3D NETIF_F_SG | NETIF_F_FRAGLIST | NETIF_F_TSO
 		      | NETIF_F_HIGHDMA | NETIF_F_IP_CSUM | NETIF_F_HW_VLAN_TX
 		      | NETIF_F_HW_VLAN_RX | NETIF_F_HW_VLAN_FILTER
-		      | NETIF_F_LLTX;
+		      | NETIF_F_LLTX | NETIF_F_RXCSUM;
 	dev->watchdog_timeo =3D EHEA_WATCH_DOG_TIMEOUT;
=20
 	if (use_lro)
--=20
1.7.2.5

