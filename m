From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: [PATCH net-next 7/8] tg3: Report invalid link from
 tg3_get_settings()
Date: Thu, 14 Oct 2010 13:37:44 -0700
Message-ID: <1287088665-22135-8-git-send-email-mcarlson@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, andy@greyhouse.net, mcarlson@broadcom.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:2072 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756034Ab0JNUiG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 14 Oct 2010 16:38:06 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently the tg3 driver leaves the speed and duplex fields
uninitialized in tg3_get_settings() if the device is not up.  This can
lead to some strange deductions in certain versions of ethtool.  When
the device is up and the link is down, the driver reports SPEED_INVALID
and DUPLEX_INVALID for these fields.  This patch makes the presentation
consistent by returning SPEED_INVALID and DUPLEX_INVALID when the device
has not been brought up as well.

Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
Reviewed-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/tg3.c |    3 +++
 1 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index 17ca0a3..5d30e67 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -9807,6 +9807,9 @@ static int tg3_get_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 	if (netif_running(dev)) {
 		cmd->speed = tp->link_config.active_speed;
 		cmd->duplex = tp->link_config.active_duplex;
+	} else {
+		cmd->speed = SPEED_INVALID;
+		cmd->duplex = DUPLEX_INVALID;
 	}
 	cmd->phy_address = tp->phy_addr;
 	cmd->transceiver = XCVR_INTERNAL;
-- 
1.7.2.2


