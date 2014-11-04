From: Giuseppe Cavallaro <peppe.cavallaro@st.com>
Subject: [net-next.git 3/3 (V2)] stmmac: remove BUS_MODE_DA
Date: Tue, 4 Nov 2014 15:49:34 +0100
Message-ID: <1415112574-21321-4-git-send-email-peppe.cavallaro@st.com>
References: <1415112574-21321-1-git-send-email-peppe.cavallaro@st.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Giuseppe Cavallaro <peppe.cavallaro@st.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx08-00178001.pphosted.com ([91.207.212.93]:34294 "EHLO
	mx08-00178001.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754351AbaKDPBY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Nov 2014 10:01:24 -0500
Received: from pps.filterd (m0046661.ppops.net [127.0.0.1])
	by mx08-00178001.pphosted.com (8.14.5/8.14.5) with SMTP id sA4ExDG6014297
	for <netdev@vger.kernel.org>; Tue, 4 Nov 2014 16:01:23 +0100
Received: from beta.dmz-eu.st.com (beta.dmz-eu.st.com [164.129.1.35])
	by mx08-00178001.pphosted.com with ESMTP id 1qe8mep943-1
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NOT)
	for <netdev@vger.kernel.org>; Tue, 04 Nov 2014 16:01:23 +0100
Received: from zeta.dmz-eu.st.com (zeta.dmz-eu.st.com [164.129.230.9])
	by beta.dmz-eu.st.com (STMicroelectronics) with ESMTP id A8BFF34
	for <netdev@vger.kernel.org>; Tue,  4 Nov 2014 15:00:54 +0000 (GMT)
Received: from Webmail-eu.st.com (Safex1hubcas21.st.com [10.75.90.44])
	by zeta.dmz-eu.st.com (STMicroelectronics) with ESMTP id 0A1EDB4D96
	for <netdev@vger.kernel.org>; Tue,  4 Nov 2014 15:01:21 +0000 (GMT)
In-Reply-To: <1415112574-21321-1-git-send-email-peppe.cavallaro@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a very old and often unused option to configure
a bit in a register inside the DMA. This support should
not stay under Koption and should be extended for new chips too.
This will be do later maybe via device-tree parameters.
Also no performance impact when remove this setting on STi platforms.

Signed-off-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>
---

V2: re-based on top of the latest updates for net-next

 drivers/net/ethernet/stmicro/stmmac/Kconfig        |   10 ----------
 .../net/ethernet/stmicro/stmmac/dwmac1000_dma.c    |    4 ----
 2 files changed, 0 insertions(+), 14 deletions(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/Kconfig b/drivers/net/ethernet/stmicro/stmmac/Kconfig
index af5228a..33b85ba 100644
--- a/drivers/net/ethernet/stmicro/stmmac/Kconfig
+++ b/drivers/net/ethernet/stmicro/stmmac/Kconfig
@@ -37,14 +37,4 @@ config STMMAC_PCI
 	  D1215994A VIRTEX FPGA board.
 
 	  If unsure, say N.
-
-config STMMAC_DA
-	bool "STMMAC DMA arbitration scheme"
-	default n
-	---help---
-	  Selecting this option, rx has priority over Tx (only for Giga
-	  Ethernet device).
-	  By default, the DMA arbitration scheme is based on Round-robin
-	  (rx:tx priority is 1:1).
-
 endif
diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac1000_dma.c b/drivers/net/ethernet/stmicro/stmmac/dwmac1000_dma.c
index 0c2058a..59d92e8 100644
--- a/drivers/net/ethernet/stmicro/stmmac/dwmac1000_dma.c
+++ b/drivers/net/ethernet/stmicro/stmmac/dwmac1000_dma.c
@@ -70,10 +70,6 @@ static int dwmac1000_dma_init(void __iomem *ioaddr, int pbl, int fb, int mb,
 	if (mb)
 		value |= DMA_BUS_MODE_MB;
 
-#ifdef CONFIG_STMMAC_DA
-	value |= DMA_BUS_MODE_DA;	/* Rx has priority over tx */
-#endif
-
 	if (atds)
 		value |= DMA_BUS_MODE_ATDS;
 
-- 
1.7.4.4
