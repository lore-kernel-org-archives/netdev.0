From: Antonio Quartulli <ordex-GaUfNO9RBHfsrOwW+9ziJQ@public.gmane.org>
Subject: [PATCH] batman-adv: use ETH_P_BATMAN
Date: Fri, 30 Nov 2012 11:14:10 +0100
Message-ID: <1354270450-25935-2-git-send-email-ordex@autistici.org>
References: <1354270450-25935-1-git-send-email-ordex@autistici.org>
Reply-To: The list for a Better Approach To Mobile Ad-hoc Networking
 <b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org,
 Marek Lindner <lindner_marek-LWAfsSFWpa4@public.gmane.org>
To: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
In-Reply-To: <1354270450-25935-1-git-send-email-ordex-GaUfNO9RBHfsrOwW+9ziJQ@public.gmane.org>
List-Unsubscribe: <https://lists.open-mesh.org/mm/options/b.a.t.m.a.n>,
 <mailto:b.a.t.m.a.n-request-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.open-mesh.org/pipermail/b.a.t.m.a.n/>
List-Post: <mailto:b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
List-Help: <mailto:b.a.t.m.a.n-request-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org?subject=help>
List-Subscribe: <https://lists.open-mesh.org/mm/listinfo/b.a.t.m.a.n>,
 <mailto:b.a.t.m.a.n-request-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org?subject=subscribe>
Errors-To: b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org
Sender: "B.A.T.M.A.N" <b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
List-Id: netdev.vger.kernel.org

The ETH_P_BATMAN ethertype is now defined kernel-wide. Use it instead
of the private BATADV_ETH_P_BATMAN define.

Signed-off-by: Antonio Quartulli <ordex-GaUfNO9RBHfsrOwW+9ziJQ@public.gmane.org>
Signed-off-by: Marek Lindner <lindner_marek-LWAfsSFWpa4@public.gmane.org>
---
 net/batman-adv/hard-interface.c | 3 ++-
 net/batman-adv/packet.h         | 2 --
 net/batman-adv/send.c           | 6 ++++--
 net/batman-adv/soft-interface.c | 9 +++++----
 4 files changed, 11 insertions(+), 9 deletions(-)

diff --git a/net/batman-adv/hard-interface.c b/net/batman-adv/hard-interface.c
index 365ed74..f1d37cd 100644
--- a/net/batman-adv/hard-interface.c
+++ b/net/batman-adv/hard-interface.c
@@ -30,6 +30,7 @@
 #include "bridge_loop_avoidance.h"
 
 #include <linux/if_arp.h>
+#include <linux/if_ether.h>
 
 void batadv_hardif_free_rcu(struct rcu_head *rcu)
 {
@@ -311,7 +312,7 @@ int batadv_hardif_enable_interface(struct batadv_hard_iface *hard_iface,
 {
 	struct batadv_priv *bat_priv;
 	struct net_device *soft_iface;
-	__be16 ethertype = __constant_htons(BATADV_ETH_P_BATMAN);
+	__be16 ethertype = __constant_htons(ETH_P_BATMAN);
 	int ret;
 
 	if (hard_iface->if_status != BATADV_IF_NOT_IN_USE)
diff --git a/net/batman-adv/packet.h b/net/batman-adv/packet.h
index 1c5454d..cb6405bf 100644
--- a/net/batman-adv/packet.h
+++ b/net/batman-adv/packet.h
@@ -20,8 +20,6 @@
 #ifndef _NET_BATMAN_ADV_PACKET_H_
 #define _NET_BATMAN_ADV_PACKET_H_
 
-#define BATADV_ETH_P_BATMAN  0x4305 /* unofficial/not registered Ethertype */
-
 enum batadv_packettype {
 	BATADV_IV_OGM		= 0x01,
 	BATADV_ICMP		= 0x02,
diff --git a/net/batman-adv/send.c b/net/batman-adv/send.c
index c7f7023..4425af9 100644
--- a/net/batman-adv/send.c
+++ b/net/batman-adv/send.c
@@ -28,6 +28,8 @@
 #include "gateway_common.h"
 #include "originator.h"
 
+#include <linux/if_ether.h>
+
 static void batadv_send_outstanding_bcast_packet(struct work_struct *work);
 
 /* send out an already prepared packet to the given address via the
@@ -60,11 +62,11 @@ int batadv_send_skb_packet(struct sk_buff *skb,
 	ethhdr = (struct ethhdr *)skb_mac_header(skb);
 	memcpy(ethhdr->h_source, hard_iface->net_dev->dev_addr, ETH_ALEN);
 	memcpy(ethhdr->h_dest, dst_addr, ETH_ALEN);
-	ethhdr->h_proto = __constant_htons(BATADV_ETH_P_BATMAN);
+	ethhdr->h_proto = __constant_htons(ETH_P_BATMAN);
 
 	skb_set_network_header(skb, ETH_HLEN);
 	skb->priority = TC_PRIO_CONTROL;
-	skb->protocol = __constant_htons(BATADV_ETH_P_BATMAN);
+	skb->protocol = __constant_htons(ETH_P_BATMAN);
 
 	skb->dev = hard_iface->net_dev;
 
diff --git a/net/batman-adv/soft-interface.c b/net/batman-adv/soft-interface.c
index 54800c7..6b548fd 100644
--- a/net/batman-adv/soft-interface.c
+++ b/net/batman-adv/soft-interface.c
@@ -34,6 +34,7 @@
 #include <linux/ethtool.h>
 #include <linux/etherdevice.h>
 #include <linux/if_vlan.h>
+#include <linux/if_ether.h>
 #include "unicast.h"
 #include "bridge_loop_avoidance.h"
 
@@ -146,7 +147,7 @@ static int batadv_interface_tx(struct sk_buff *skb,
 	struct batadv_hard_iface *primary_if = NULL;
 	struct batadv_bcast_packet *bcast_packet;
 	struct vlan_ethhdr *vhdr;
-	__be16 ethertype = __constant_htons(BATADV_ETH_P_BATMAN);
+	__be16 ethertype = __constant_htons(ETH_P_BATMAN);
 	static const uint8_t stp_addr[ETH_ALEN] = {0x01, 0x80, 0xC2, 0x00,
 						   0x00, 0x00};
 	static const uint8_t ectp_addr[ETH_ALEN] = {0xCF, 0x00, 0x00, 0x00,
@@ -172,7 +173,7 @@ static int batadv_interface_tx(struct sk_buff *skb,
 			break;
 
 		/* fall through */
-	case BATADV_ETH_P_BATMAN:
+	case ETH_P_BATMAN:
 		goto dropped;
 	}
 
@@ -302,7 +303,7 @@ void batadv_interface_rx(struct net_device *soft_iface,
 	struct vlan_ethhdr *vhdr;
 	struct batadv_header *batadv_header = (struct batadv_header *)skb->data;
 	short vid __maybe_unused = -1;
-	__be16 ethertype = __constant_htons(BATADV_ETH_P_BATMAN);
+	__be16 ethertype = __constant_htons(ETH_P_BATMAN);
 	bool is_bcast;
 
 	is_bcast = (batadv_header->packet_type == BATADV_BCAST);
@@ -325,7 +326,7 @@ void batadv_interface_rx(struct net_device *soft_iface,
 			break;
 
 		/* fall through */
-	case BATADV_ETH_P_BATMAN:
+	case ETH_P_BATMAN:
 		goto dropped;
 	}
 
-- 
1.8.0
