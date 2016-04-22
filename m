From: Sabrina Dubroca <sd@queasysnail.net>
Subject: [PATCH net v2 7/9] macsec: fix SA leak if initialization fails
Date: Fri, 22 Apr 2016 11:28:07 +0200
Message-ID: <0af413c382a3683dbf816a2e45ba7c21ddee53f4.1461315621.git.sd@queasysnail.net>
References: <cover.1461315621.git.sd@queasysnail.net>
Cc: Lance Richardson <lrichard@redhat.com>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Johannes Berg <johannes@sipsolutions.net>,
	Dan Carpenter <dan.carpenter@oracle.com>,
	Sabrina Dubroca <sd@queasysnail.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:42703 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754132AbcDVJ2m (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 22 Apr 2016 05:28:42 -0400
In-Reply-To: <cover.1461315621.git.sd@queasysnail.net>
In-Reply-To: <cover.1461315621.git.sd@queasysnail.net>
References: <cover.1461315621.git.sd@queasysnail.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fixes: c09440f7dcb3 ("macsec: introduce IEEE 802.1AE driver")
Reported-by: Lance Richardson <lrichard@redhat.com>
Signed-off-by: Sabrina Dubroca <sd@queasysnail.net>
Acked-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
---
 drivers/net/macsec.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/drivers/net/macsec.c b/drivers/net/macsec.c
index 826c6c9ce7fd..b37d348b8ea0 100644
--- a/drivers/net/macsec.c
+++ b/drivers/net/macsec.c
@@ -1627,6 +1627,7 @@ static int macsec_add_rxsa(struct sk_buff *skb, struct genl_info *info)
 	rx_sa = kmalloc(sizeof(*rx_sa), GFP_KERNEL);
 	if (!rx_sa || init_rx_sa(rx_sa, nla_data(tb_sa[MACSEC_SA_ATTR_KEY]),
 				 secy->key_len, secy->icv_len)) {
+		kfree(rx_sa);
 		rtnl_unlock();
 		return -ENOMEM;
 	}
@@ -1771,6 +1772,7 @@ static int macsec_add_txsa(struct sk_buff *skb, struct genl_info *info)
 	tx_sa = kmalloc(sizeof(*tx_sa), GFP_KERNEL);
 	if (!tx_sa || init_tx_sa(tx_sa, nla_data(tb_sa[MACSEC_SA_ATTR_KEY]),
 				 secy->key_len, secy->icv_len)) {
+		kfree(tx_sa);
 		rtnl_unlock();
 		return -ENOMEM;
 	}
-- 
2.8.0
