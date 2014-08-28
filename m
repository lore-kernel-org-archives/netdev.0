From: Giuseppe Cavallaro <peppe.cavallaro@st.com>
Subject: [PATCH (net.git) 4/4] stmmac: fix PLS bit setting when EEE is active
Date: Thu, 28 Aug 2014 08:11:44 +0200
Message-ID: <1409206304-23239-5-git-send-email-peppe.cavallaro@st.com>
References: <1409206304-23239-1-git-send-email-peppe.cavallaro@st.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <davem@davemloft.net>, Giuseppe Cavallaro <peppe.cavallaro@st.com>,
	nandini sharma <nandini.sharma@st.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx08-00178001.pphosted.com ([91.207.212.93]:50745 "EHLO
	mx08-00178001.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S934150AbaH1GMC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Aug 2014 02:12:02 -0400
In-Reply-To: <1409206304-23239-1-git-send-email-peppe.cavallaro@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In case of PLS is active the PLS (PHY Link Status) bit in
the Reg12 has to be set to allow the MAC to asserts the LPI
pattern when the link is ok.

Signed-off-by: nandini sharma <nandini.sharma@st.com>
Signed-off-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>
---
 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c |    7 +++----
 1 files changed, 3 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
index b8d931e..eb5b7c4 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
@@ -321,10 +321,9 @@ bool stmmac_eee_init(struct stmmac_priv *priv)
 			priv->hw->mac->set_eee_timer(priv->hw,
 						     STMMAC_DEFAULT_LIT_LS,
 						     tx_lpi_timer);
-		} else
-			/* Set HW EEE according to the speed */
-			priv->hw->mac->set_eee_pls(priv->hw,
-						   priv->phydev->link);
+		}
+		/* Set HW EEE according to the speed */
+		priv->hw->mac->set_eee_pls(priv->hw, priv->phydev->link);
 
 		pr_debug("stmmac: Energy-Efficient Ethernet initialized\n");
 
-- 
1.7.4.4
