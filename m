From: Giuseppe Cavallaro <peppe.cavallaro@st.com>
Subject: [PATCH (net.git) 4/4] stmmac: fix PLS bit setting when EEE is active
Date: Tue, 26 Aug 2014 09:16:23 +0200
Message-ID: <1409037383-3213-5-git-send-email-peppe.cavallaro@st.com>
References: <1409037383-3213-1-git-send-email-peppe.cavallaro@st.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Giuseppe Cavallaro <peppe.cavallaro@st.com>,
	nandini sharma <nandini.sharma@st.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx07-00178001.pphosted.com ([62.209.51.94]:47437 "EHLO
	mx07-00178001.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757278AbaHZHQj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Aug 2014 03:16:39 -0400
Received: from pps.filterd (m0046670.ppops.net [127.0.0.1])
	by mx07-00178001.pphosted.com (8.14.5/8.14.5) with SMTP id s7Q79pTM026764
	for <netdev@vger.kernel.org>; Tue, 26 Aug 2014 09:16:37 +0200
Received: from beta.dmz-eu.st.com (beta.dmz-eu.st.com [164.129.1.35])
	by mx07-00178001.pphosted.com with ESMTP id 1p0hrgs1yx-1
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NOT)
	for <netdev@vger.kernel.org>; Tue, 26 Aug 2014 09:16:37 +0200
Received: from zeta.dmz-eu.st.com (zeta.dmz-eu.st.com [164.129.230.9])
	by beta.dmz-eu.st.com (STMicroelectronics) with ESMTP id B5C2634
	for <netdev@vger.kernel.org>; Tue, 26 Aug 2014 07:16:27 +0000 (GMT)
Received: from Webmail-eu.st.com (Safex1hubcas21.st.com [10.75.90.44])
	by zeta.dmz-eu.st.com (STMicroelectronics) with ESMTP id 180A2164E5
	for <netdev@vger.kernel.org>; Tue, 26 Aug 2014 07:16:36 +0000 (GMT)
In-Reply-To: <1409037383-3213-1-git-send-email-peppe.cavallaro@st.com>
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
index 48a112f..5b5bbc3 100644
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
