From: Stefan Roese <sr@denx.de>
Subject: [PATCH v2] net: stmmac: Fix clock en-/disable calls
Date: Fri,  8 Jun 2012 11:21:05 +0200
Message-ID: <1339147265-19188-1-git-send-email-sr@denx.de>
Cc: Viresh Kumar <viresh.linux@gmail.com>,
	Giuseppe Cavallaro <peppe.cavallaro@st.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mo-p05-ob.rzone.de ([81.169.146.180]:55384 "EHLO
	mo-p05-ob.rzone.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934007Ab2FHJVY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Jun 2012 05:21:24 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

clk_{un}prepare is mandatory for platforms using common clock framework.
Since these drivers are used by SPEAr platform, which supports common
clock framework, add clk_{un}prepare() support for them. Otherwise
the clocks are not correctly en-/disabled and ethernet support doesn't
work.

Signed-off-by: Stefan Roese <sr@denx.de>
Cc: Viresh Kumar <viresh.linux@gmail.com>
Cc: Giuseppe Cavallaro <peppe.cavallaro@st.com>
---
v2:
- Patch description added. Sorry for missing this in the 1st patch
  revision.

 drivers/net/ethernet/stmicro/stmmac/stmmac.h |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac.h b/drivers/net/ethernet/stmicro/stmmac/stmmac.h
index 6b5d060..f46d8d0 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac.h
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac.h
@@ -109,7 +109,7 @@ struct stmmac_priv *stmmac_dvr_probe(struct device *device,
 static inline int stmmac_clk_enable(struct stmmac_priv *priv)
 {
 	if (!IS_ERR(priv->stmmac_clk))
-		return clk_enable(priv->stmmac_clk);
+		return clk_prepare_enable(priv->stmmac_clk);
 
 	return 0;
 }
@@ -119,7 +119,7 @@ static inline void stmmac_clk_disable(struct stmmac_priv *priv)
 	if (IS_ERR(priv->stmmac_clk))
 		return;
 
-	clk_disable(priv->stmmac_clk);
+	clk_disable_unprepare(priv->stmmac_clk);
 }
 static inline int stmmac_clk_get(struct stmmac_priv *priv)
 {
-- 
1.7.10.4
