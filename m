From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: [PATCH net-next 6/8] tg3: Show flowctrl settings through
 get_settings()
Date: Mon, 13 Jun 2011 16:39:00 -0700
Message-ID: <1308008342-21030-7-git-send-email-mcarlson@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mcarlson@broadcom.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:3155 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755366Ab1FMXiY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 13 Jun 2011 19:38:24 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds code to present the flow control advertisements through
the ethtool get_settings callback.

Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
Reviewed-by: Michael Chan <mchan@broadcom.com>
Reviewed-by: Benjamin Li <benli@broadcom.com>
---
 drivers/net/tg3.c |   12 ++++++++++++
 1 files changed, 12 insertions(+), 0 deletions(-)

diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index 7ce50e5..a7bea86 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -9934,6 +9934,18 @@ static int tg3_get_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 	}
 
 	cmd->advertising = tp->link_config.advertising;
+	if (tg3_flag(tp, PAUSE_AUTONEG)) {
+		if (tp->link_config.flowctrl & FLOW_CTRL_RX) {
+			if (tp->link_config.flowctrl & FLOW_CTRL_TX) {
+				cmd->advertising |= ADVERTISED_Pause;
+			} else {
+				cmd->advertising |= ADVERTISED_Pause |
+						    ADVERTISED_Asym_Pause;
+			}
+		} else if (tp->link_config.flowctrl & FLOW_CTRL_TX) {
+			cmd->advertising |= ADVERTISED_Asym_Pause;
+		}
+	}
 	if (netif_running(dev)) {
 		ethtool_cmd_speed_set(cmd, tp->link_config.active_speed);
 		cmd->duplex = tp->link_config.active_duplex;
-- 
1.7.3.4


