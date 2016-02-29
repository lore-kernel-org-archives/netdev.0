From: Alexandre TORGUE <alexandre.torgue@st.com>
Subject: [PATCH v3 11/17] stmmac: set dirty index out of the loop
Date: Mon, 29 Feb 2016 14:27:37 +0100
Message-ID: <1456752463-27128-12-git-send-email-alexandre.torgue@st.com>
References: <1456752463-27128-1-git-send-email-alexandre.torgue@st.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <peppe.cavallaro@st.com>, <fabrice.gasnier@st.com>,
	<maxime.coquelin@st.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx08-00178001.pphosted.com ([91.207.212.93]:45921 "EHLO
	mx07-00178001.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1755379AbcB2N2t (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Feb 2016 08:28:49 -0500
Received: from pps.filterd (m0046661.ppops.net [127.0.0.1])
	by mx08-00178001.pphosted.com (8.15.0.59/8.15.0.59) with SMTP id u1TDRniW019374
	for <netdev@vger.kernel.org>; Mon, 29 Feb 2016 14:28:47 +0100
Received: from beta.dmz-ap.st.com (beta.dmz-ap.st.com [138.198.100.35])
	by mx08-00178001.pphosted.com with ESMTP id 21b3jgaqf5-1
	(version=TLSv1/SSLv3 cipher=ECDHE-RSA-AES256-SHA bits=256 verify=NOT)
	for <netdev@vger.kernel.org>; Mon, 29 Feb 2016 14:28:47 +0100
Received: from zeta.dmz-ap.st.com (ns6.st.com [138.198.234.13])
	by beta.dmz-ap.st.com (STMicroelectronics) with ESMTP id 6934123
	for <netdev@vger.kernel.org>; Mon, 29 Feb 2016 13:28:44 +0000 (GMT)
Received: from Webmail-ap.st.com (eapex1hubcas1.st.com [10.80.176.8])
	by zeta.dmz-ap.st.com (STMicroelectronics) with ESMTP id 0CB9FF7
	for <netdev@vger.kernel.org>; Mon, 29 Feb 2016 13:28:43 +0000 (GMT)
In-Reply-To: <1456752463-27128-1-git-send-email-alexandre.torgue@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Giuseppe Cavallaro <peppe.cavallaro@st.com>

The dirty index can be updated out of the loop where all the
tx resources are claimed. This will help on performances too.
Also a useless debug printk has been removed from the main loop.

Signed-off-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>
Signed-off-by: Alexandre TORGUE <alexandre.torgue@st.com>

diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
index d31179f..2e4c10a 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
@@ -1340,9 +1340,6 @@ static void stmmac_tx_clean(struct stmmac_priv *priv)
 			}
 			stmmac_get_tx_hwtstamp(priv, entry, skb);
 		}
-		if (netif_msg_tx_done(priv))
-			pr_debug("%s: curr %d, dirty %d\n", __func__,
-				 priv->cur_tx, priv->dirty_tx);
 
 		if (likely(priv->tx_skbuff_dma[entry].buf)) {
 			if (priv->tx_skbuff_dma[entry].map_as_page)
@@ -1372,8 +1369,8 @@ static void stmmac_tx_clean(struct stmmac_priv *priv)
 		priv->hw->desc->release_tx_desc(p, priv->mode);
 
 		entry = STMMAC_GET_ENTRY(entry, DMA_TX_SIZE);
-		priv->dirty_tx = entry;
 	}
+	priv->dirty_tx = entry;
 
 	netdev_completed_queue(priv->dev, pkts_compl, bytes_compl);
 
-- 
1.9.1
