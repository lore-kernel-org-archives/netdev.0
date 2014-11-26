From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next 1/3] net: bcmgenet: add register definitions for EEE
Date: Tue, 25 Nov 2014 21:16:34 -0800
Message-ID: <1416978996-24808-2-git-send-email-f.fainelli@gmail.com>
References: <1416978996-24808-1-git-send-email-f.fainelli@gmail.com>
Cc: davem@davemloft.net, pgynther@google.com,
	Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f174.google.com ([209.85.192.174]:61721 "EHLO
	mail-pd0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752263AbaKZFQm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Nov 2014 00:16:42 -0500
Received: by mail-pd0-f174.google.com with SMTP id w10so2055357pde.33
        for <netdev@vger.kernel.org>; Tue, 25 Nov 2014 21:16:42 -0800 (PST)
In-Reply-To: <1416978996-24808-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add register definitions to control EEE in the UniMAC, RBUF and TBUF
register ranges.

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/ethernet/broadcom/genet/bcmgenet.h | 22 ++++++++++++++++++++++
 1 file changed, 22 insertions(+)

diff --git a/drivers/net/ethernet/broadcom/genet/bcmgenet.h b/drivers/net/ethernet/broadcom/genet/bcmgenet.h
index c4ca7282a601..ea6f0ab566bf 100644
--- a/drivers/net/ethernet/broadcom/genet/bcmgenet.h
+++ b/drivers/net/ethernet/broadcom/genet/bcmgenet.h
@@ -185,6 +185,21 @@ struct bcmgenet_mib_counters {
 #define UMAC_MAC1			0x010
 #define UMAC_MAX_FRAME_LEN		0x014
 
+#define UMAC_EEE_CTRL			0x064
+#define  EN_LPI_RX_PAUSE		(1 << 0)
+#define  EN_LPI_TX_PFC			(1 << 1)
+#define  EN_LPI_TX_PAUSE		(1 << 2)
+#define  EEE_EN				(1 << 3)
+#define  RX_FIFO_CHECK			(1 << 4)
+#define  EEE_TX_CLK_DIS			(1 << 5)
+#define  DIS_EEE_10M			(1 << 6)
+#define  LP_IDLE_PREDICTION_MODE	(1 << 7)
+
+#define UMAC_EEE_LPI_TIMER		0x068
+#define UMAC_EEE_WAKE_TIMER		0x06C
+#define UMAC_EEE_REF_COUNT		0x070
+#define  EEE_REFERENCE_COUNT_MASK	0xffff
+
 #define UMAC_TX_FLUSH			0x334
 
 #define UMAC_MIB_START			0x400
@@ -232,6 +247,10 @@ struct bcmgenet_mib_counters {
 #define  RBUF_RXCHK_EN			(1 << 0)
 #define  RBUF_SKIP_FCS			(1 << 4)
 
+#define RBUF_ENERGY_CTRL		0x9c
+#define  RBUF_EEE_EN			(1 << 0)
+#define  RBUF_PM_EN			(1 << 1)
+
 #define RBUF_TBUF_SIZE_CTRL		0xb4
 
 #define RBUF_HFB_CTRL_V1		0x38
@@ -247,6 +266,9 @@ struct bcmgenet_mib_counters {
 
 #define TBUF_CTRL			0x00
 #define TBUF_BP_MC			0x0C
+#define TBUF_ENERGY_CTRL		0x14
+#define  TBUF_EEE_EN			(1 << 0)
+#define  TBUF_PM_EN			(1 << 1)
 
 #define TBUF_CTRL_V1			0x80
 #define TBUF_BP_MC_V1			0xA0
-- 
2.1.0
