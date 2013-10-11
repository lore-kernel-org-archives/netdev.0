From: Himanshu Madhani <himanshu.madhani@qlogic.com>
Subject: [PATCH net-next v2 4/9] qlcnic: Update ethtool standard pause settings.
Date: Fri, 11 Oct 2013 14:42:30 -0400
Message-ID: <9b60f4149911bb7b48db7f28bfa9ce646cd407d1.1381538863.git.himanshu.madhani@qlogic.com>
References: <cover.1381538863.git.himanshu.madhani@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <Dept_NX_Linux_NIC_Driver@qlogic.com>,
	Jitendra Kalsaria <jitendra.kalsaria@qlogic.com>,
	<himanshu.madhani@qlogic.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-0016ce01.pphosted.com ([67.231.148.157]:16959 "EHLO
	mx0a-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752509Ab3JKTNA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Oct 2013 15:13:00 -0400
In-Reply-To: <cover.1381538863.git.himanshu.madhani@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jitendra Kalsaria <jitendra.kalsaria@qlogic.com>

Update ethtool standard pause parameter settings and display

Signed-off-by: Jitendra Kalsaria <jitendra.kalsaria@qlogic.com>
Signed-off-by: Himanshu Madhani <himanshu.madhani@qlogic.com>
---
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.c | 18 +++++++++++++++---
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.h |  3 +++
 2 files changed, 18 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.c
index c2df4ce..268fda6 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.c
@@ -3369,10 +3369,21 @@ void qlcnic_83xx_get_pauseparam(struct qlcnic_adapter *adapter,
 	}
 	config = ahw->port_config;
 	if (config & QLC_83XX_CFG_STD_PAUSE) {
-		if (config & QLC_83XX_CFG_STD_TX_PAUSE)
+		switch (MSW(config)) {
+		case QLC_83XX_TX_PAUSE:
+			pause->tx_pause = 1;
+			break;
+		case QLC_83XX_RX_PAUSE:
+			pause->rx_pause = 1;
+			break;
+		case QLC_83XX_TX_RX_PAUSE:
+		default:
+			/* Backward compatibility for existing
+			 * flash definitions
+			 */
 			pause->tx_pause = 1;
-		if (config & QLC_83XX_CFG_STD_RX_PAUSE)
 			pause->rx_pause = 1;
+		}
 	}
 
 	if (QLC_83XX_AUTONEG(config))
@@ -3415,7 +3426,8 @@ int qlcnic_83xx_set_pauseparam(struct qlcnic_adapter *adapter,
 		ahw->port_config &= ~QLC_83XX_CFG_STD_RX_PAUSE;
 		ahw->port_config |= QLC_83XX_CFG_STD_TX_PAUSE;
 	} else if (!pause->rx_pause && !pause->tx_pause) {
-		ahw->port_config &= ~QLC_83XX_CFG_STD_TX_RX_PAUSE;
+		ahw->port_config &= ~(QLC_83XX_CFG_STD_TX_RX_PAUSE |
+				      QLC_83XX_CFG_STD_PAUSE);
 	}
 	status = qlcnic_83xx_set_port_config(adapter);
 	if (status) {
diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.h b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.h
index 533e150..2883b57 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.h
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.h
@@ -363,6 +363,9 @@ enum qlcnic_83xx_states {
 #define QLC_83XX_LINK_EEE(data)		((data) & BIT_13)
 #define QLC_83XX_DCBX(data)			(((data) >> 28) & 7)
 #define QLC_83XX_AUTONEG(data)			((data) & BIT_15)
+#define QLC_83XX_TX_PAUSE			0x10
+#define QLC_83XX_RX_PAUSE			0x20
+#define QLC_83XX_TX_RX_PAUSE			0x30
 #define QLC_83XX_CFG_STD_PAUSE			(1 << 5)
 #define QLC_83XX_CFG_STD_TX_PAUSE		(1 << 20)
 #define QLC_83XX_CFG_STD_RX_PAUSE		(2 << 20)
-- 
1.8.1.4
