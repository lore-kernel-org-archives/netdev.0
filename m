From: Antonio Quartulli <a@unstable.cc>
Subject: [PATCH 10/15] batman-adv: Add kernel-doc for batadv_interface_rx
Date: Wed,  4 May 2016 06:23:45 +0800
Message-ID: <1462314230-16257-11-git-send-email-a@unstable.cc>
References: <1462314230-16257-1-git-send-email-a@unstable.cc>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Sven Eckelmann <sven@narfation.org>,
	Marek Lindner <mareklindner@neomailbox.ch>,
	Antonio Quartulli <a@unstable.cc>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from s2.neomailbox.net ([5.148.176.60]:29844 "EHLO s2.neomailbox.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756436AbcECWlT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 3 May 2016 18:41:19 -0400
In-Reply-To: <1462314230-16257-1-git-send-email-a@unstable.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sven Eckelmann <sven@narfation.org>

Signed-off-by: Sven Eckelmann <sven@narfation.org>
Signed-off-by: Marek Lindner <mareklindner@neomailbox.ch>
Signed-off-by: Antonio Quartulli <a@unstable.cc>
---
 net/batman-adv/soft-interface.c | 18 ++++++++++++++++++
 1 file changed, 18 insertions(+)

diff --git a/net/batman-adv/soft-interface.c b/net/batman-adv/soft-interface.c
index e158235ada06..d78c560852d7 100644
--- a/net/batman-adv/soft-interface.c
+++ b/net/batman-adv/soft-interface.c
@@ -381,6 +381,24 @@ end:
 	return NETDEV_TX_OK;
 }
 
+/**
+ * batadv_interface_rx - receive ethernet frame on local batman-adv interface
+ * @soft_iface: local interface which will receive the ethernet frame
+ * @skb: ethernet frame for @soft_iface
+ * @recv_if: interface on which the batman-adv packet was received
+ * @hdr_size: size of already parsed batman-adv header
+ * @orig_node: originator from which the batman-adv packet was sent
+ *
+ * Sends a ethernet frame to the receive path of the local @soft_iface.
+ * skb->data has still point to the batman-adv header with the size @hdr_size.
+ * The caller has to have parsed this header already and made sure that at least
+ * @hdr_size bytes are still available for pull in @skb.
+ *
+ * The packet may still get dropped. This can happen when the encapsulated
+ * ethernet frame is invalid or contains again an batman-adv packet. Also
+ * unicast packets will be dropped directly when it was sent between two
+ * isolated clients.
+ */
 void batadv_interface_rx(struct net_device *soft_iface,
 			 struct sk_buff *skb, struct batadv_hard_iface *recv_if,
 			 int hdr_size, struct batadv_orig_node *orig_node)
-- 
2.8.2
