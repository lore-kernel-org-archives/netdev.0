From: Joe Perches <joe@perches.com>
Subject: [PATCH net-next 09/14] atm: Use eth_<foo>_addr instead of memset
Date: Mon,  2 Mar 2015 19:54:54 -0800
Message-ID: <59992a3c894be4e54547513c323ebae1ad11852f.1425354528.git.joe@perches.com>
References: <cover.1425354527.git.joe@perches.com>
Cc: "David S. Miller" <davem@davemloft.net>
To: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1425354527.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Use the built-in function instead of memset.

Signed-off-by: Joe Perches <joe@perches.com>
---
 net/atm/lec.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/atm/lec.c b/net/atm/lec.c
index 4b98f89..cd3b379 100644
--- a/net/atm/lec.c
+++ b/net/atm/lec.c
@@ -2001,7 +2001,7 @@ lec_vcc_added(struct lec_priv *priv, const struct atmlec_ioc *ioc_data,
 		if (entry == NULL)
 			goto out;
 		memcpy(entry->atm_addr, ioc_data->atm_addr, ATM_ESA_LEN);
-		memset(entry->mac_addr, 0, ETH_ALEN);
+		eth_zero_addr(entry->mac_addr);
 		entry->recv_vcc = vcc;
 		entry->old_recv_push = old_push;
 		entry->status = ESI_UNKNOWN;
@@ -2086,7 +2086,7 @@ lec_vcc_added(struct lec_priv *priv, const struct atmlec_ioc *ioc_data,
 	entry->vcc = vcc;
 	entry->old_push = old_push;
 	memcpy(entry->atm_addr, ioc_data->atm_addr, ATM_ESA_LEN);
-	memset(entry->mac_addr, 0, ETH_ALEN);
+	eth_zero_addr(entry->mac_addr);
 	entry->status = ESI_UNKNOWN;
 	hlist_add_head(&entry->next, &priv->lec_arp_empty_ones);
 	entry->timer.expires = jiffies + priv->vcc_timeout_period;
-- 
2.1.2
