From: damuzi000 <damuzi000@gmail.com>
Subject: [PATCH 1/1] When timestamping is enabled, stmmac_tx_clean will call stmmac_get_tx_hwtstamp to get tx TS. It's possible that skb is NULL because there are other network frames that use several descriptors. So we must return immediately in stmmac_get_tx_hwtstamp if skb is NULL to avoid system crash.
Date: Sun, 12 Jan 2014 10:01:35 +0800
Message-ID: <1389492095-6589-1-git-send-email-damuzi000@gmail.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	damuzi000 <damuzi000@gmail.com>
To: peppe.cavallaro@st.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Signed-off-by: damuzi000 <damuzi000@gmail.com>
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
