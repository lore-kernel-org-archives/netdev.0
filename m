From: Bruce Liu <damuzi000@gmail.com>
Subject: [PATCH net-next] net: stmmac: fix NULL pointer dereference in stmmac_get_tx_hwtstamp
Date: Wed, 15 Jan 2014 22:26:07 +0800
Message-ID: <1389795967-2452-1-git-send-email-damuzi000@gmail.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Bruce Liu <damuzi000@gmail.com>
To: peppe.cavallaro@st.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f42.google.com ([209.85.160.42]:43541 "EHLO
	mail-pb0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751664AbaAOO0h (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Jan 2014 09:26:37 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When timestamping is enabled, stmmac_tx_clean will call
stmmac_get_tx_hwtstamp to get tx TS.
But the skb can be NULL because the last of its tx_skbuff is NULL
if this packet frame is filled in more than one descriptors.

Signed-off-by: Bruce Liu <damuzi000@gmail.com>
---
 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
index 797b56a..47f2287 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
@@ -332,7 +332,7 @@ static void stmmac_get_tx_hwtstamp(struct stmmac_priv *priv,
 		return;
 
 	/* exit if skb doesn't support hw tstamp */
-	if (likely(!(skb_shinfo(skb)->tx_flags & SKBTX_IN_PROGRESS)))
+	if (likely(!skb || !(skb_shinfo(skb)->tx_flags & SKBTX_IN_PROGRESS)))
 		return;
 
 	if (priv->adv_ts)
-- 
1.7.9.5
