From: Antonio Quartulli <antonio@meshcoding.com>
Subject: [PATCH 16/16] batman-adv: Add dummy soft-interface rx mode handler
Date: Sun, 13 Oct 2013 13:23:01 +0200
Message-ID: <1381663381-626-17-git-send-email-antonio@meshcoding.com>
References: <1381663381-626-1-git-send-email-antonio@meshcoding.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	=?UTF-8?q?Linus=20L=C3=BCssing?= <linus.luessing@web.de>,
	Marek Lindner <lindner_marek@yahoo.de>,
	Antonio Quartulli <antonio@meshcoding.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.neomailbox.net ([178.209.62.157]:16625 "EHLO
	s3.neomailbox.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754497Ab3JMLw5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 13 Oct 2013 07:52:57 -0400
In-Reply-To: <1381663381-626-1-git-send-email-antonio@meshcoding.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Linus L=C3=BCssing <linus.luessing@web.de>

We do not actually need to set any rx filters for the virtual batman
soft interface. However a dummy handler enables a user to set static
multicast listeners for instance.

Signed-off-by: Linus L=C3=BCssing <linus.luessing@web.de>
Signed-off-by: Marek Lindner <lindner_marek@yahoo.de>
Signed-off-by: Antonio Quartulli <antonio@meshcoding.com>
---
 net/batman-adv/soft-interface.c | 13 +++++++++++++
 1 file changed, 13 insertions(+)

diff --git a/net/batman-adv/soft-interface.c b/net/batman-adv/soft-inte=
rface.c
index 15c7237..e8a2bd6 100644
--- a/net/batman-adv/soft-interface.c
+++ b/net/batman-adv/soft-interface.c
@@ -137,6 +137,18 @@ static int batadv_interface_change_mtu(struct net_=
device *dev, int new_mtu)
 	return 0;
 }
=20
+/**
+ * batadv_interface_set_rx_mode - set the rx mode of a device
+ * @dev: registered network device to modify
+ *
+ * We do not actually need to set any rx filters for the virtual batma=
n
+ * soft interface. However a dummy handler enables a user to set stati=
c
+ * multicast listeners for instance.
+ */
+static void batadv_interface_set_rx_mode(struct net_device *dev)
+{
+}
+
 static int batadv_interface_tx(struct sk_buff *skb,
 			       struct net_device *soft_iface)
 {
@@ -583,6 +595,7 @@ static const struct net_device_ops batadv_netdev_op=
s =3D {
 	.ndo_get_stats =3D batadv_interface_stats,
 	.ndo_set_mac_address =3D batadv_interface_set_mac_addr,
 	.ndo_change_mtu =3D batadv_interface_change_mtu,
+	.ndo_set_rx_mode =3D batadv_interface_set_rx_mode,
 	.ndo_start_xmit =3D batadv_interface_tx,
 	.ndo_validate_addr =3D eth_validate_addr,
 	.ndo_add_slave =3D batadv_softif_slave_add,
--=20
1.8.3.2
