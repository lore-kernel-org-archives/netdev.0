From: Frank Li <Frank.Li@freescale.com>
Subject: [PATCH net-next 2/7] net:fec: reorder ethtool ops to match order in struct declaration
Date: Tue, 29 Apr 2014 20:09:05 +0800
Message-ID: <1398773350-7293-2-git-send-email-Frank.Li@freescale.com>
References: <1398773350-7293-1-git-send-email-Frank.Li@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <linux-arm-kernel@lists.infradead.org>, <netdev@vger.kernel.org>,
	Frank Li <Frank.Li@freescale.com>
To: <lznuaa@gmail.com>, <shawn.guo@linaro.org>, <B38611@freescale.com>,
	<davem@davemloft.net>, <rmk+kernel@arm.linux.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bn1blp0186.outbound.protection.outlook.com ([207.46.163.186]:14309
	"EHLO na01-bn1-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1756960AbaD2NU2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 29 Apr 2014 09:20:28 -0400
In-Reply-To: <1398773350-7293-1-git-send-email-Frank.Li@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Russell King <rmk+kernel@arm.linux.org.uk>

This allows us to merge two separate preprocessor conditionals together.

Signed-off-by: Russell King <rmk+kernel@arm.linux.org.uk>
Signed-off-by: Frank Li <Frank.Li@freescale.com>
---
 drivers/net/ethernet/freescale/fec_main.c |   12 +++++-------
 1 files changed, 5 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/freescale/fec_main.c b/drivers/net/ethernet/freescale/fec_main.c
index b151eaf..875c0ca 100644
--- a/drivers/net/ethernet/freescale/fec_main.c
+++ b/drivers/net/ethernet/freescale/fec_main.c
@@ -1639,21 +1639,19 @@ static int fec_enet_nway_reset(struct net_device *dev)
 }
 
 static const struct ethtool_ops fec_enet_ethtool_ops = {
-#if !defined(CONFIG_M5272)
-	.get_pauseparam		= fec_enet_get_pauseparam,
-	.set_pauseparam		= fec_enet_set_pauseparam,
-#endif
 	.get_settings		= fec_enet_get_settings,
 	.set_settings		= fec_enet_set_settings,
 	.get_drvinfo		= fec_enet_get_drvinfo,
-	.get_link		= ethtool_op_get_link,
-	.get_ts_info		= fec_enet_get_ts_info,
 	.nway_reset		= fec_enet_nway_reset,
+	.get_link		= ethtool_op_get_link,
 #ifndef CONFIG_M5272
-	.get_ethtool_stats	= fec_enet_get_ethtool_stats,
+	.get_pauseparam		= fec_enet_get_pauseparam,
+	.set_pauseparam		= fec_enet_set_pauseparam,
 	.get_strings		= fec_enet_get_strings,
+	.get_ethtool_stats	= fec_enet_get_ethtool_stats,
 	.get_sset_count		= fec_enet_get_sset_count,
 #endif
+	.get_ts_info		= fec_enet_get_ts_info,
 };
 
 static int fec_enet_ioctl(struct net_device *ndev, struct ifreq *rq, int cmd)
-- 
1.7.8
