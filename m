From: Amerigo Wang <amwang@redhat.com>
Subject: [PATCH] bonding: use the correct size for _simple_hash()
Date: Mon, 28 Feb 2011 17:34:28 +0800
Message-ID: <1298885668-3917-1-git-send-email-amwang@redhat.com>
Cc: WANG Cong <amwang@redhat.com>, Jay Vosburgh <fubar@us.ibm.com>,
	netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Clearly it should be the size of ->ip_dst here.
Although this is harmless, but it still reads odd.

Signed-off-by: WANG Cong <amwang@redhat.com>

---
diff --git a/drivers/net/bonding/bond_alb.c b/drivers/net/bonding/bond_alb.c
index 5c6fba8..9bc5de3 100644
--- a/drivers/net/bonding/bond_alb.c
+++ b/drivers/net/bonding/bond_alb.c
@@ -604,7 +604,7 @@ static struct slave *rlb_choose_channel(struct sk_buff *skb, struct bonding *bon
 
 	_lock_rx_hashtbl(bond);
 
-	hash_index = _simple_hash((u8 *)&arp->ip_dst, sizeof(arp->ip_src));
+	hash_index = _simple_hash((u8 *)&arp->ip_dst, sizeof(arp->ip_dst));
 	client_info = &(bond_info->rx_hashtbl[hash_index]);
 
 	if (client_info->assigned) {
