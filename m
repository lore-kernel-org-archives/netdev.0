From: Giuseppe Cavallaro <peppe.cavallaro@st.com>
Subject: [PATCH (net.git) 3/4 (v2)] stmmac: never check EEE in case of a switch is attached
Date: Thu, 28 Aug 2014 08:11:43 +0200
Message-ID: <1409206304-23239-4-git-send-email-peppe.cavallaro@st.com>
References: <1409206304-23239-1-git-send-email-peppe.cavallaro@st.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <davem@davemloft.net>, Giuseppe CAVALLARO <peppe.cavallaro@st.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx08-00178001.pphosted.com ([91.207.212.93]:50742 "EHLO
	mx08-00178001.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754872AbaH1GL7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Aug 2014 02:11:59 -0400
In-Reply-To: <1409206304-23239-1-git-send-email-peppe.cavallaro@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>

This patch is to skip the EEE initialisation when the stmmac
is using a switch (with a fixed phy support).

Signed-off-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>
---

v2: review local variable declarations

 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c |    5 +++++
 1 files changed, 5 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
index 51a89d4..b8d931e 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
@@ -275,6 +275,7 @@ static void stmmac_eee_ctrl_timer(unsigned long arg)
  */
 bool stmmac_eee_init(struct stmmac_priv *priv)
 {
+	char *phy_bus_name = priv->plat->phy_bus_name;
 	bool ret = false;
 
 	/* Using PCS we cannot dial with the phy registers at this stage
@@ -284,6 +285,10 @@ bool stmmac_eee_init(struct stmmac_priv *priv)
 	    (priv->pcs == STMMAC_PCS_RTBI))
 		goto out;
 
+	/* Never init EEE in case of a switch is attached */
+	if (phy_bus_name && (!strcmp(phy_bus_name, "fixed")))
+		goto out;
+
 	/* MAC core supports the EEE feature. */
 	if (priv->dma_cap.eee) {
 		int tx_lpi_timer = priv->tx_lpi_timer;
-- 
1.7.4.4
