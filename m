From: Sabrina Dubroca <sd@queasysnail.net>
Subject: [PATCH net] macsec: fix netlink attribute for key id
Date: Wed, 18 May 2016 13:34:40 +0200
Message-ID: <fdff01d3a343b5ee16cd034d743b62a543befcf4.1463570397.git.sd@queasysnail.net>
Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Sabrina Dubroca <sd@queasysnail.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:49146 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751492AbcERLez (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 18 May 2016 07:34:55 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In my last commit I replaced MACSEC_SA_ATTR_KEYID by
MACSEC_SA_ATTR_KEY.

Fixes: 8acca6acebd0 ("macsec: key identifier is 128 bits, not 64")
Signed-off-by: Sabrina Dubroca <sd@queasysnail.net>
---
 drivers/net/macsec.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/macsec.c b/drivers/net/macsec.c
index 92eaab95ae2b..9e803bbcc0b6 100644
--- a/drivers/net/macsec.c
+++ b/drivers/net/macsec.c
@@ -1645,7 +1645,7 @@ static int macsec_add_rxsa(struct sk_buff *skb, struct genl_info *info)
 	if (tb_sa[MACSEC_SA_ATTR_ACTIVE])
 		rx_sa->active = !!nla_get_u8(tb_sa[MACSEC_SA_ATTR_ACTIVE]);
 
-	nla_memcpy(rx_sa->key.id, tb_sa[MACSEC_SA_ATTR_KEY], MACSEC_KEYID_LEN);
+	nla_memcpy(rx_sa->key.id, tb_sa[MACSEC_SA_ATTR_KEYID], MACSEC_KEYID_LEN);
 	rx_sa->sc = rx_sc;
 	rcu_assign_pointer(rx_sc->sa[assoc_num], rx_sa);
 
@@ -1784,7 +1784,7 @@ static int macsec_add_txsa(struct sk_buff *skb, struct genl_info *info)
 		return -ENOMEM;
 	}
 
-	nla_memcpy(tx_sa->key.id, tb_sa[MACSEC_SA_ATTR_KEY], MACSEC_KEYID_LEN);
+	nla_memcpy(tx_sa->key.id, tb_sa[MACSEC_SA_ATTR_KEYID], MACSEC_KEYID_LEN);
 
 	spin_lock_bh(&tx_sa->lock);
 	tx_sa->next_pn = nla_get_u32(tb_sa[MACSEC_SA_ATTR_PN]);
-- 
2.8.2
