From: Sabrina Dubroca <sd@queasysnail.net>
Subject: [PATCH net 1/5] macsec: add missing NULL check after kmalloc
Date: Tue, 19 Apr 2016 19:36:38 +0200
Message-ID: <c986bb2421c817eeb00416bd2055f69040924af5.1460967681.git.sd@queasysnail.net>
References: <cover.1460967681.git.sd@queasysnail.net>
Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Johannes Berg <johannes@sipsolutions.net>,
	Dan Carpenter <dan.carpenter@oracle.com>,
	Sabrina Dubroca <sd@queasysnail.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:51305 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932209AbcDSRhK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 19 Apr 2016 13:37:10 -0400
In-Reply-To: <cover.1460967681.git.sd@queasysnail.net>
In-Reply-To: <cover.1460967681.git.sd@queasysnail.net>
References: <cover.1460967681.git.sd@queasysnail.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fixes: c09440f7dcb3 ("macsec: introduce IEEE 802.1AE driver")
Reported-by: Dan Carpenter <dan.carpenter@oracle.com>
Signed-off-by: Sabrina Dubroca <sd@queasysnail.net>
Acked-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
---
 drivers/net/macsec.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/macsec.c b/drivers/net/macsec.c
index 84d3e5ca8817..f691030ee3df 100644
--- a/drivers/net/macsec.c
+++ b/drivers/net/macsec.c
@@ -1622,8 +1622,8 @@ static int macsec_add_rxsa(struct sk_buff *skb, struct genl_info *info)
 	}
 
 	rx_sa = kmalloc(sizeof(*rx_sa), GFP_KERNEL);
-	if (init_rx_sa(rx_sa, nla_data(tb_sa[MACSEC_SA_ATTR_KEY]), secy->key_len,
-		       secy->icv_len)) {
+	if (!rx_sa || init_rx_sa(rx_sa, nla_data(tb_sa[MACSEC_SA_ATTR_KEY]),
+				 secy->key_len, secy->icv_len)) {
 		rtnl_unlock();
 		return -ENOMEM;
 	}
-- 
2.8.0
