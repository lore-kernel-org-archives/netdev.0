From: Antonio Quartulli <ordex@autistici.org>
Subject: [PATCH 14/16] batman-adv: drop STP over batman
Date: Sat,  7 Apr 2012 20:49:56 +0200
Message-ID: <1333824598-27771-15-git-send-email-ordex@autistici.org>
References: <1333824598-27771-1-git-send-email-ordex@autistici.org>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Simon Wunderlich <simon.wunderlich@s2003.tu-chemnitz.de>,
	Simon Wunderlich <siwu@hrz.tu-chemnitz.de>,
	Antonio Quartulli <ordex@autistici.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from investici.nine.ch ([217.150.252.179]:61201 "EHLO
	confino.investici.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754678Ab2DGStk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 7 Apr 2012 14:49:40 -0400
In-Reply-To: <1333824598-27771-1-git-send-email-ordex@autistici.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Simon Wunderlich <simon.wunderlich@s2003.tu-chemnitz.de>

Signed-off-by: Simon Wunderlich <siwu@hrz.tu-chemnitz.de>
Signed-off-by: Antonio Quartulli <ordex@autistici.org>
---
 net/batman-adv/soft-interface.c |    8 ++++++++
 1 file changed, 8 insertions(+)

diff --git a/net/batman-adv/soft-interface.c b/net/batman-adv/soft-interface.c
index 4d639b3..10ab49a 100644
--- a/net/batman-adv/soft-interface.c
+++ b/net/batman-adv/soft-interface.c
@@ -130,6 +130,8 @@ static int interface_tx(struct sk_buff *skb, struct net_device *soft_iface)
 	struct hard_iface *primary_if = NULL;
 	struct bcast_packet *bcast_packet;
 	struct vlan_ethhdr *vhdr;
+	static const uint8_t stp_addr[ETH_ALEN] = {0x01, 0x80, 0xC2, 0x00, 0x00,
+						   0x00};
 	unsigned int header_len = 0;
 	int data_len = skb->len, ret;
 	short vid = -1;
@@ -159,6 +161,12 @@ static int interface_tx(struct sk_buff *skb, struct net_device *soft_iface)
 	/* Register the client MAC in the transtable */
 	tt_local_add(soft_iface, ethhdr->h_source, skb->skb_iif);
 
+	/* don't accept stp packets. STP does not help in meshes.
+	 * better use the bridge loop avoidance ...
+	 */
+	if (compare_eth(ethhdr->h_dest, stp_addr))
+		goto dropped;
+
 	if (is_multicast_ether_addr(ethhdr->h_dest)) {
 		do_bcast = true;
 
-- 
1.7.9.4
