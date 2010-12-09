From: Tobias Klauser <tklauser@distanz.ch>
Subject: [PATCH] stmmac: Remove redundant unlikely()
Date: Thu,  9 Dec 2010 15:50:22 +0100
Message-ID: <1291906222-575-1-git-send-email-tklauser@distanz.ch>
Cc: kernel-janitors@vger.kernel.org
To: Giuseppe Cavallaro <peppe.cavallaro@st.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.zhaw.ch ([160.85.104.50]:62803 "EHLO mx1.zhaw.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751474Ab0LIOuY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 9 Dec 2010 09:50:24 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

IS_ERR() already implies unlikely(), so it can be omitted here.

Signed-off-by: Tobias Klauser <tklauser@distanz.ch>
---
 drivers/net/stmmac/stmmac_main.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/stmmac/stmmac_main.c b/drivers/net/stmmac/stmmac_main.c
index c0dc785..20f803d 100644
--- a/drivers/net/stmmac/stmmac_main.c
+++ b/drivers/net/stmmac/stmmac_main.c
@@ -949,7 +949,7 @@ static int stmmac_sw_tso(struct stmmac_priv *priv, struct sk_buff *skb)
 	       skb, skb->len);
 
 	segs = skb_gso_segment(skb, priv->dev->features & ~NETIF_F_TSO);
-	if (unlikely(IS_ERR(segs)))
+	if (IS_ERR(segs))
 		goto sw_tso_end;
 
 	do {
-- 
1.7.0.4

