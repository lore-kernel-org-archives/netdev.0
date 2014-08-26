From: Giuseppe Cavallaro <peppe.cavallaro@st.com>
Subject: [PATCH (net.git) 3/4] stmmac: never check EEE in case of a switch is attached
Date: Tue, 26 Aug 2014 09:16:22 +0200
Message-ID: <1409037383-3213-4-git-send-email-peppe.cavallaro@st.com>
References: <1409037383-3213-1-git-send-email-peppe.cavallaro@st.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx07-00178001.pphosted.com ([62.209.51.94]:57984 "EHLO
	mx07-00178001.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755535AbaHZHQi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Aug 2014 03:16:38 -0400
Received: from pps.filterd (m0046668.ppops.net [127.0.0.1])
	by mx07-00178001.pphosted.com (8.14.5/8.14.5) with SMTP id s7Q7AHn8024488
	for <netdev@vger.kernel.org>; Tue, 26 Aug 2014 09:16:36 +0200
Received: from beta.dmz-eu.st.com (beta.dmz-eu.st.com [164.129.1.35])
	by mx07-00178001.pphosted.com with ESMTP id 1p0hn092tk-1
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NOT)
	for <netdev@vger.kernel.org>; Tue, 26 Aug 2014 09:16:36 +0200
Received: from zeta.dmz-eu.st.com (zeta.dmz-eu.st.com [164.129.230.9])
	by beta.dmz-eu.st.com (STMicroelectronics) with ESMTP id B369731
	for <netdev@vger.kernel.org>; Tue, 26 Aug 2014 07:16:26 +0000 (GMT)
Received: from Webmail-eu.st.com (Safex1hubcas21.st.com [10.75.90.44])
	by zeta.dmz-eu.st.com (STMicroelectronics) with ESMTP id 13471164E5
	for <netdev@vger.kernel.org>; Tue, 26 Aug 2014 07:16:35 +0000 (GMT)
In-Reply-To: <1409037383-3213-1-git-send-email-peppe.cavallaro@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>

This patch is to skip the EEE initialisation when the stmmac
is using a switch (with a fixed phy support).

Signed-off-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>
---
 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c |    5 +++++
 1 files changed, 5 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
index 51a89d4..48a112f 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
@@ -276,6 +276,7 @@ static void stmmac_eee_ctrl_timer(unsigned long arg)
 bool stmmac_eee_init(struct stmmac_priv *priv)
 {
 	bool ret = false;
+	char *phy_bus_name = priv->plat->phy_bus_name;
 
 	/* Using PCS we cannot dial with the phy registers at this stage
 	 * so we do not support extra feature like EEE.
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
