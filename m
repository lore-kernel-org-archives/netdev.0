From: Giuseppe Cavallaro <peppe.cavallaro@st.com>
Subject: [PATCH (net-next.git) 11/18] stmmac: set dirty index out of the loop
Date: Mon, 4 Jan 2016 14:06:56 +0100
Message-ID: <1451912823-5245-12-git-send-email-peppe.cavallaro@st.com>
References: <1451912823-5245-1-git-send-email-peppe.cavallaro@st.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <alexandre.torgue@st.com>,
	Giuseppe Cavallaro <peppe.cavallaro@st.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx08-00178001.pphosted.com ([91.207.212.93]:40911 "EHLO
	mx07-00178001.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1753702AbcADMyR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Jan 2016 07:54:17 -0500
Received: from pps.filterd (m0046660.ppops.net [127.0.0.1])
	by mx08-00178001.pphosted.com (8.14.5/8.14.5) with SMTP id u04CrGNO022850
	for <netdev@vger.kernel.org>; Mon, 4 Jan 2016 13:54:16 +0100
Received: from beta.dmz-eu.st.com (beta.dmz-eu.st.com [164.129.1.35])
	by mx08-00178001.pphosted.com with ESMTP id 2034vyx78g-1
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NOT)
	for <netdev@vger.kernel.org>; Mon, 04 Jan 2016 13:54:16 +0100
Received: from zeta.dmz-eu.st.com (zeta.dmz-eu.st.com [164.129.230.9])
	by beta.dmz-eu.st.com (STMicroelectronics) with ESMTP id BE48E31
	for <netdev@vger.kernel.org>; Mon,  4 Jan 2016 12:53:32 +0000 (GMT)
Received: from Webmail-eu.st.com (Safex1hubcas21.st.com [10.75.90.44])
	by zeta.dmz-eu.st.com (STMicroelectronics) with ESMTP id 01F5150F6
	for <netdev@vger.kernel.org>; Mon,  4 Jan 2016 12:54:15 +0000 (GMT)
In-Reply-To: <1451912823-5245-1-git-send-email-peppe.cavallaro@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The dirty index can be updated out of the loop where all the
tx resources are claimed. This will help on performances too.
Also a useless debug printk has been removed from the main loop.

Signed-off-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>
---
 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c |    5 +----
 1 files changed, 1 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
index 230ded2..daa732f 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
@@ -1357,9 +1357,6 @@ static void stmmac_tx_clean(struct stmmac_priv *priv)
 			}
 			stmmac_get_tx_hwtstamp(priv, entry, skb);
 		}
-		if (netif_msg_tx_done(priv))
-			pr_debug("%s: curr %d, dirty %d\n", __func__,
-				 priv->cur_tx, priv->dirty_tx);
 
 		if (likely(priv->tx_skbuff_dma[entry].buf)) {
 			if (priv->tx_skbuff_dma[entry].map_as_page)
@@ -1390,8 +1387,8 @@ static void stmmac_tx_clean(struct stmmac_priv *priv)
 
 		if (++entry >= txsize)
 			entry = 0;
-		priv->dirty_tx = entry;
 	}
+	priv->dirty_tx = entry;
 
 	netdev_completed_queue(priv->dev, pkts_compl, bytes_compl);
 
-- 
1.7.4.4
