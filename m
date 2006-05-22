From: "Michael Chan" <mchan@broadcom.com>
Subject: [PATCH 2.6.17] tg3: Add some missing rx error counters
Date: Mon, 22 May 2006 09:54:36 -0700
Message-ID: <1148316876.4780.110.camel@rh4>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:27405 "EHLO
	MMS3.broadcom.com") by vger.kernel.org with ESMTP id S1751007AbWEVSed
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 22 May 2006 14:34:33 -0400
To: davem@davemloft.net
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add some missing rx error counters for 5705 and newer chips.

Update version to 3.58.

Signed-off-by: Michael Chan <mchan@broadcom.com>


diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index e1b33a2..49ad60b 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -69,8 +69,8 @@
 
 #define DRV_MODULE_NAME		"tg3"
 #define PFX DRV_MODULE_NAME	": "
-#define DRV_MODULE_VERSION	"3.57"
-#define DRV_MODULE_RELDATE	"Apr 28, 2006"
+#define DRV_MODULE_VERSION	"3.58"
+#define DRV_MODULE_RELDATE	"May 22, 2006"
 
 #define TG3_DEF_MAC_MODE	0
 #define TG3_DEF_RX_MODE		0
@@ -6488,6 +6488,10 @@ static void tg3_periodic_fetch_stats(str
 	TG3_STAT_ADD32(&sp->rx_frame_too_long_errors, MAC_RX_STATS_FRAME_TOO_LONG);
 	TG3_STAT_ADD32(&sp->rx_jabbers, MAC_RX_STATS_JABBERS);
 	TG3_STAT_ADD32(&sp->rx_undersize_packets, MAC_RX_STATS_UNDERSIZE);
+
+	TG3_STAT_ADD32(&sp->rxbds_empty, RCVLPC_NO_RCV_BD_CNT);
+	TG3_STAT_ADD32(&sp->rx_discards, RCVLPC_IN_DISCARDS_CNT);
+	TG3_STAT_ADD32(&sp->rx_errors, RCVLPC_IN_ERRORS_CNT);
 }
 
 static void tg3_timer(unsigned long __opaque)


