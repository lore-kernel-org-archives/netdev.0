From: Jitendra Kalsaria <jitendra.kalsaria@qlogic.com>
Subject: [PATCH net-next 3/7] qlcnic: Add eSwitch statistics support
Date: Wed, 24 Apr 2013 18:42:41 -0400
Message-ID: <1366843365-2787-4-git-send-email-jitendra.kalsaria@qlogic.com>
References: <1366843365-2787-1-git-send-email-jitendra.kalsaria@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <sony.chacko@qlogic.com>,
	<shahed.shaikh@qlogic.com>, <Dept_NX_Linux_NIC_Driver@qlogic.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ch1ehsobe005.messaging.microsoft.com ([216.32.181.185]:45836
	"EHLO ch1outboundpool.messaging.microsoft.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932166Ab3DXXHH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Apr 2013 19:07:07 -0400
In-Reply-To: <1366843365-2787-1-git-send-email-jitendra.kalsaria@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shahed Shaikh <shahed.shaikh@qlogic.com>

o Read eSwitch statistics from adapter and display them as part
  of ethtool statistics.

Signed-off-by: Shahed Shaikh <shahed.shaikh@qlogic.com>
Signed-off-by: Jitendra Kalsaria <jitendra.kalsaria@qlogic.com>
---
 .../net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.c    |    3 +++
 .../net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.h    |    2 +-
 .../net/ethernet/qlogic/qlcnic/qlcnic_ethtool.c    |    7 +++++++
 3 files changed, 11 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.c
index fd0829c..c40b077 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.c
@@ -2922,6 +2922,9 @@ static u64 *qlcnic_83xx_fill_stats(struct qlcnic_adapter *adapter,
 		/* fill in MAC rx frame stats */
 		for (k += 6; k < 80; k += 2)
 			data = qlcnic_83xx_copy_stats(cmd, data, k);
+		/* fill in eSwitch stats */
+		for (; k < total_regs; k += 2)
+			data = qlcnic_83xx_copy_stats(cmd, data, k);
 		break;
 	case QLC_83XX_STAT_RX:
 		for (k = 2; k < 8; k += 2)
diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.h b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.h
index 4be411c..1f1d85e 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.h
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.h
@@ -381,7 +381,7 @@ enum qlcnic_83xx_states {
 #define QLC_83XX_STAT_MAC	1
 #define QLC_83XX_TX_STAT_REGS	14
 #define QLC_83XX_RX_STAT_REGS	40
-#define QLC_83XX_MAC_STAT_REGS	80
+#define QLC_83XX_MAC_STAT_REGS	94
 
 #define QLC_83XX_GET_FUNC_PRIVILEGE(VAL, FN)	(0x3 & ((VAL) >> (FN * 2)))
 #define QLC_83XX_SET_FUNC_OPMODE(VAL, FN)	((VAL) << (FN * 2))
diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_ethtool.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_ethtool.c
index 59350c2..629d901 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_ethtool.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_ethtool.c
@@ -115,6 +115,13 @@ static const char qlcnic_83xx_mac_stats_strings[][ETH_GSTRING_LEN] = {
 	"mac_rx_dropped",
 	"mac_crc_error",
 	"mac_align_error",
+	"eswitch_frames",
+	"eswitch_bytes",
+	"eswitch_multicast_frames",
+	"eswitch_broadcast_frames",
+	"eswitch_unicast_frames",
+	"eswitch_error_free_frames",
+	"eswitch_error_free_bytes",
 };
 
 #define QLCNIC_STATS_LEN	ARRAY_SIZE(qlcnic_gstrings_stats)
-- 
1.7.6.rc1.1.g2c162b
