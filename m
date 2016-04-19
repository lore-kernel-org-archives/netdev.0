From: Sabrina Dubroca <sd@queasysnail.net>
Subject: [PATCH net 3/5] macsec: don't put a NULL rxsa
Date: Tue, 19 Apr 2016 19:36:40 +0200
Message-ID: <27136273f5dd531b200c6cb728b39712891871d5.1460967681.git.sd@queasysnail.net>
References: <cover.1460967681.git.sd@queasysnail.net>
Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Johannes Berg <johannes@sipsolutions.net>,
	Dan Carpenter <dan.carpenter@oracle.com>,
	Sabrina Dubroca <sd@queasysnail.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:56414 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932209AbcDSRhN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 19 Apr 2016 13:37:13 -0400
In-Reply-To: <cover.1460967681.git.sd@queasysnail.net>
In-Reply-To: <cover.1460967681.git.sd@queasysnail.net>
References: <cover.1460967681.git.sd@queasysnail.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The "deliver:" path of macsec_handle_frame can be called with
rx_sa == NULL.  Check rx_sa != NULL before calling macsec_rxsa_put().

Fixes: c09440f7dcb3 ("macsec: introduce IEEE 802.1AE driver")
Signed-off-by: Sabrina Dubroca <sd@queasysnail.net>
Acked-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
---
 drivers/net/macsec.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/net/macsec.c b/drivers/net/macsec.c
index 5f3ea8026074..2a2136b7d324 100644
--- a/drivers/net/macsec.c
+++ b/drivers/net/macsec.c
@@ -1161,7 +1161,8 @@ deliver:
 			    macsec_extra_len(macsec_skb_cb(skb)->has_sci));
 	macsec_reset_skb(skb, secy->netdev);
 
-	macsec_rxsa_put(rx_sa);
+	if (rx_sa)
+		macsec_rxsa_put(rx_sa);
 	count_rx(dev, skb->len);
 
 	rcu_read_unlock();
-- 
2.8.0
