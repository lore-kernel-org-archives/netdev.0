From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: [PATCH net-next v2 5/6] tg3: Return flowctrl config through
 ethtool
Date: Thu, 8 Dec 2011 16:40:17 -0800
Message-ID: <1323391218-32241-6-git-send-email-mcarlson@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mcarlson@broadcom.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:2696 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752298Ab1LIAjz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 8 Dec 2011 19:39:55 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch changes the driver to return the flow control configuration
rather than the flow control status through the ETHTOOL_GPAUSEPARAM
ioctl.

Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
Reviewed-by: Michael Chan <mchan@broadcom.com>
Reviewed-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/ethernet/broadcom/tg3.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/tg3.c b/drivers/net/ethernet/broadcom/tg3.c
index 924dce5..28a959d 100644
--- a/drivers/net/ethernet/broadcom/tg3.c
+++ b/drivers/net/ethernet/broadcom/tg3.c
@@ -10596,12 +10596,12 @@ static void tg3_get_pauseparam(struct net_device *dev, struct ethtool_pauseparam
 
 	epause->autoneg = !!tg3_flag(tp, PAUSE_AUTONEG);
 
-	if (tp->link_config.active_flowctrl & FLOW_CTRL_RX)
+	if (tp->link_config.flowctrl & FLOW_CTRL_RX)
 		epause->rx_pause = 1;
 	else
 		epause->rx_pause = 0;
 
-	if (tp->link_config.active_flowctrl & FLOW_CTRL_TX)
+	if (tp->link_config.flowctrl & FLOW_CTRL_TX)
 		epause->tx_pause = 1;
 	else
 		epause->tx_pause = 0;
-- 
1.7.3.4
