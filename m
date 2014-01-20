From: Joe Perches <joe@perches.com>
Subject: [PATCH 3/7] atm: Use ether_addr_copy
Date: Mon, 20 Jan 2014 09:52:16 -0800
Message-ID: <891b9869ad352a40f4e8f6dea28cf2da0ce6fde7.1390239869.git.joe@perches.com>
References: <cover.1390239869.git.joe@perches.com>
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay0015.hostedemail.com ([216.40.44.15]:35805 "EHLO
	smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752156AbaATRwf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Jan 2014 12:52:35 -0500
In-Reply-To: <cover.1390239869.git.joe@perches.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use ether_addr_copy instead of memcpy(a, b, ETH_ALEN) to
save some cycles on arm and powerpc.

Signed-off-by: Joe Perches <joe@perches.com>
---
 net/atm/lec.c | 9 +++++----
 net/atm/mpc.c | 2 +-
 2 files changed, 6 insertions(+), 5 deletions(-)

diff --git a/net/atm/lec.c b/net/atm/lec.c
index f23916b..0b73ae9 100644
--- a/net/atm/lec.c
+++ b/net/atm/lec.c
@@ -521,7 +521,7 @@ send_to_lecd(struct lec_priv *priv, atmlec_msg_type type,
 	if (data != NULL)
 		mesg->sizeoftlvs = data->len;
 	if (mac_addr)
-		memcpy(&mesg->content.normal.mac_addr, mac_addr, ETH_ALEN);
+		ether_addr_copy(&mesg->content.normal.mac_addr, mac_addr);
 	else
 		mesg->content.normal.targetless_le_arp = 1;
 	if (atm_addr)
@@ -1565,7 +1565,7 @@ static struct lec_arp_table *make_entry(struct lec_priv *priv,
 		pr_info("LEC: Arp entry kmalloc failed\n");
 		return NULL;
 	}
-	memcpy(to_return->mac_addr, mac_addr, ETH_ALEN);
+	ether_addr_copy(to_return->mac_addr, mac_addr);
 	INIT_HLIST_NODE(&to_return->next);
 	setup_timer(&to_return->timer, lec_arp_expire_arp,
 			(unsigned long)to_return);
@@ -1887,7 +1887,8 @@ lec_arp_update(struct lec_priv *priv, const unsigned char *mac_addr,
 					entry = tmp;
 				} else {
 					entry->status = ESI_FORWARD_DIRECT;
-					memcpy(entry->mac_addr, mac_addr, ETH_ALEN);
+					ether_addr_copy(entry->mac_addr,
+							mac_addr);
 					entry->last_used = jiffies;
 					lec_arp_add(priv, entry);
 				}
@@ -2263,7 +2264,7 @@ lec_arp_check_empties(struct lec_priv *priv,
 				  &priv->lec_arp_empty_ones, next) {
 		if (vcc == entry->vcc) {
 			del_timer(&entry->timer);
-			memcpy(entry->mac_addr, src, ETH_ALEN);
+			ether_addr_copy(entry->mac_addr, src);
 			entry->status = ESI_FORWARD_DIRECT;
 			entry->last_used = jiffies;
 			/* We might have got an entry */
diff --git a/net/atm/mpc.c b/net/atm/mpc.c
index 3af1275..b71ff6b 100644
--- a/net/atm/mpc.c
+++ b/net/atm/mpc.c
@@ -478,7 +478,7 @@ static const uint8_t *copy_macs(struct mpoa_client *mpc,
 			return NULL;
 		}
 	}
-	memcpy(mpc->mps_macs, router_mac, ETH_ALEN);
+	ether_addr_copy(mpc->mps_macs, router_mac);
 	tlvs += 20; if (device_type == MPS_AND_MPC) tlvs += 20;
 	if (mps_macs > 0)
 		memcpy(mpc->mps_macs, tlvs, mps_macs*ETH_ALEN);
-- 
1.8.1.2.459.gbcd45b4.dirty
