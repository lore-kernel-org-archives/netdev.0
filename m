From: Antonio Quartulli <a@unstable.cc>
Subject: [PATCH 16/17] batman-adv: replace ethertype variable with ETH_P_BATMAN for readability
Date: Wed, 11 May 2016 03:30:04 +0800
Message-ID: <1462908605-27412-17-git-send-email-a__7059.97927948392$1462909141$gmane$org@unstable.cc>
References: <1462908605-27412-1-git-send-email-a@unstable.cc>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Marek Lindner <mareklindner@neomailbox.ch>,
	Antonio Quartulli <a@unstable.cc>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from s2.neomailbox.net ([5.148.176.60]:32811 "EHLO s2.neomailbox.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751063AbcEJTiv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 10 May 2016 15:38:51 -0400
In-Reply-To: <1462908605-27412-1-git-send-email-a@unstable.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Marek Lindner <mareklindner@neomailbox.ch>

Signed-off-by: Marek Lindner <mareklindner@neomailbox.ch>
Reviewed-by: Sven Eckelmann <sven@narfation.org>
Signed-off-by: Antonio Quartulli <a@unstable.cc>
---
 net/batman-adv/soft-interface.c | 8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/net/batman-adv/soft-interface.c b/net/batman-adv/soft-interface.c
index 3a0fc3c18444..343d2c904399 100644
--- a/net/batman-adv/soft-interface.c
+++ b/net/batman-adv/soft-interface.c
@@ -186,7 +186,6 @@ static int batadv_interface_tx(struct sk_buff *skb,
 	struct batadv_priv *bat_priv = netdev_priv(soft_iface);
 	struct batadv_hard_iface *primary_if = NULL;
 	struct batadv_bcast_packet *bcast_packet;
-	__be16 ethertype = htons(ETH_P_BATMAN);
 	static const u8 stp_addr[ETH_ALEN] = {0x01, 0x80, 0xC2, 0x00,
 					      0x00, 0x00};
 	static const u8 ectp_addr[ETH_ALEN] = {0xCF, 0x00, 0x00, 0x00,
@@ -216,7 +215,8 @@ static int batadv_interface_tx(struct sk_buff *skb,
 	case ETH_P_8021Q:
 		vhdr = vlan_eth_hdr(skb);
 
-		if (vhdr->h_vlan_encapsulated_proto != ethertype) {
+		/* drop batman-in-batman packets to prevent loops */
+		if (vhdr->h_vlan_encapsulated_proto != htons(ETH_P_BATMAN)) {
 			network_offset += VLAN_HLEN;
 			break;
 		}
@@ -404,7 +404,6 @@ void batadv_interface_rx(struct net_device *soft_iface,
 {
 	struct batadv_bcast_packet *batadv_bcast_packet;
 	struct batadv_priv *bat_priv = netdev_priv(soft_iface);
-	__be16 ethertype = htons(ETH_P_BATMAN);
 	struct vlan_ethhdr *vhdr;
 	struct ethhdr *ethhdr;
 	unsigned short vid;
@@ -434,7 +433,8 @@ void batadv_interface_rx(struct net_device *soft_iface,
 
 		vhdr = (struct vlan_ethhdr *)skb->data;
 
-		if (vhdr->h_vlan_encapsulated_proto != ethertype)
+		/* drop batman-in-batman packets to prevent loops */
+		if (vhdr->h_vlan_encapsulated_proto != htons(ETH_P_BATMAN))
 			break;
 
 		/* fall through */
-- 
2.8.2
