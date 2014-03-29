From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [PATCH net-next 15/17] bna: remove open-coded skb_cow_head.
Date: Sat, 29 Mar 2014 12:26:28 +0100
Message-ID: <5f87e4774eda1f10fb4f3d4483d4a2e329a2da7b.1396090802.git.romieu@fr.zoreil.com>
References: <cover.1396090802.git.romieu@fr.zoreil.com>
Cc: netdev@vger.kernel.org, Rasesh Mody <rmody@brocade.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:60879 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751624AbaC2L0x (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 29 Mar 2014 07:26:53 -0400
In-Reply-To: <cover.1396090802.git.romieu@fr.zoreil.com>
In-Reply-To: <cover.1396090802.git.romieu@fr.zoreil.com>
References: <cover.1396090802.git.romieu@fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
Cc: Rasesh Mody <rmody@brocade.com>
---
 drivers/net/ethernet/brocade/bna/bnad.c | 10 ++++------
 1 file changed, 4 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/brocade/bna/bnad.c b/drivers/net/ethernet/brocade/bna/bnad.c
index a881e98..675550f 100644
--- a/drivers/net/ethernet/brocade/bna/bnad.c
+++ b/drivers/net/ethernet/brocade/bna/bnad.c
@@ -2496,12 +2496,10 @@ bnad_tso_prepare(struct bnad *bnad, struct sk_buff *skb)
 {
 	int err;
 
-	if (skb_header_cloned(skb)) {
-		err = pskb_expand_head(skb, 0, 0, GFP_ATOMIC);
-		if (err) {
-			BNAD_UPDATE_CTR(bnad, tso_err);
-			return err;
-		}
+	err = skb_cow_head(skb, 0);
+	if (err < 0) {
+		BNAD_UPDATE_CTR(bnad, tso_err);
+		return err;
 	}
 
 	/*
-- 
1.9.0
