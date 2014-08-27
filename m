From: Giuseppe Cavallaro <peppe.cavallaro@st.com>
Subject: [PATCH (net.git)] stmmac: fix tipo on mmc crc error
Date: Wed, 27 Aug 2014 08:26:13 +0200
Message-ID: <1409120773-28003-1-git-send-email-peppe.cavallaro@st.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx07-00178001.pphosted.com ([62.209.51.94]:59757 "EHLO
	mx07-00178001.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755252AbaH0G0U (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Aug 2014 02:26:20 -0400
Received: from pps.filterd (m0046668.ppops.net [127.0.0.1])
	by mx07-00178001.pphosted.com (8.14.5/8.14.5) with SMTP id s7R6NqAS031261
	for <netdev@vger.kernel.org>; Wed, 27 Aug 2014 08:26:18 +0200
Received: from beta.dmz-eu.st.com (beta.dmz-eu.st.com [164.129.1.35])
	by mx07-00178001.pphosted.com with ESMTP id 1p0q7bn8cn-1
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NOT)
	for <netdev@vger.kernel.org>; Wed, 27 Aug 2014 08:26:18 +0200
Received: from zeta.dmz-eu.st.com (zeta.dmz-eu.st.com [164.129.230.9])
	by beta.dmz-eu.st.com (STMicroelectronics) with ESMTP id 1164031
	for <netdev@vger.kernel.org>; Wed, 27 Aug 2014 06:26:06 +0000 (GMT)
Received: from Webmail-eu.st.com (Safex1hubcas21.st.com [10.75.90.44])
	by zeta.dmz-eu.st.com (STMicroelectronics) with ESMTP id 5FB2E2C153
	for <netdev@vger.kernel.org>; Wed, 27 Aug 2014 06:26:16 +0000 (GMT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>

This patch is to fix a typo on mmc rx crc error when reported by ethtool.

Signed-off-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>
---
 drivers/net/ethernet/stmicro/stmmac/mmc.h          |    2 +-
 drivers/net/ethernet/stmicro/stmmac/mmc_core.c     |    2 +-
 .../net/ethernet/stmicro/stmmac/stmmac_ethtool.c   |    2 +-
 3 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/mmc.h b/drivers/net/ethernet/stmicro/stmmac/mmc.h
index 8607488..192c249 100644
--- a/drivers/net/ethernet/stmicro/stmmac/mmc.h
+++ b/drivers/net/ethernet/stmicro/stmmac/mmc.h
@@ -68,7 +68,7 @@ struct stmmac_counters {
 	unsigned int mmc_rx_octetcount_g;
 	unsigned int mmc_rx_broadcastframe_g;
 	unsigned int mmc_rx_multicastframe_g;
-	unsigned int mmc_rx_crc_errror;
+	unsigned int mmc_rx_crc_error;
 	unsigned int mmc_rx_align_error;
 	unsigned int mmc_rx_run_error;
 	unsigned int mmc_rx_jabber_error;
diff --git a/drivers/net/ethernet/stmicro/stmmac/mmc_core.c b/drivers/net/ethernet/stmicro/stmmac/mmc_core.c
index 50617c5..08c483b 100644
--- a/drivers/net/ethernet/stmicro/stmmac/mmc_core.c
+++ b/drivers/net/ethernet/stmicro/stmmac/mmc_core.c
@@ -196,7 +196,7 @@ void dwmac_mmc_read(void __iomem *ioaddr, struct stmmac_counters *mmc)
 	mmc->mmc_rx_octetcount_g += readl(ioaddr + MMC_RX_OCTETCOUNT_G);
 	mmc->mmc_rx_broadcastframe_g += readl(ioaddr + MMC_RX_BROADCASTFRAME_G);
 	mmc->mmc_rx_multicastframe_g += readl(ioaddr + MMC_RX_MULTICASTFRAME_G);
-	mmc->mmc_rx_crc_errror += readl(ioaddr + MMC_RX_CRC_ERRROR);
+	mmc->mmc_rx_crc_error += readl(ioaddr + MMC_RX_CRC_ERRROR);
 	mmc->mmc_rx_align_error += readl(ioaddr + MMC_RX_ALIGN_ERROR);
 	mmc->mmc_rx_run_error += readl(ioaddr + MMC_RX_RUN_ERROR);
 	mmc->mmc_rx_jabber_error += readl(ioaddr + MMC_RX_JABBER_ERROR);
diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_ethtool.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_ethtool.c
index 9af50ba..cf4f38d 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_ethtool.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_ethtool.c
@@ -175,7 +175,7 @@ static const struct stmmac_stats stmmac_mmc[] = {
 	STMMAC_MMC_STAT(mmc_rx_octetcount_g),
 	STMMAC_MMC_STAT(mmc_rx_broadcastframe_g),
 	STMMAC_MMC_STAT(mmc_rx_multicastframe_g),
-	STMMAC_MMC_STAT(mmc_rx_crc_errror),
+	STMMAC_MMC_STAT(mmc_rx_crc_error),
 	STMMAC_MMC_STAT(mmc_rx_align_error),
 	STMMAC_MMC_STAT(mmc_rx_run_error),
 	STMMAC_MMC_STAT(mmc_rx_jabber_error),
-- 
1.7.4.4
