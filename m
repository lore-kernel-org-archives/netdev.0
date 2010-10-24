From: David Dillow <dave@thedillows.org>
Subject: [PATCH 1/2] typhoon: wait for RX mode commands to finish
Date: Sun, 24 Oct 2010 16:20:20 -0400
Message-ID: <1287951621-25170-1-git-send-email-dave@thedillows.org>
Cc: davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from amavis-smtp.knology.net ([75.76.199.6]:45085 "EHLO
	amavis-smtp.knology.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759152Ab0JXUU2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 24 Oct 2010 16:20:28 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When adding VLAN devices, we can get several calls to
typhoon_set_rx_mode() in quick succession. Because we didn't wait for
the commands to complete, we could run out of command descriptors and
fail to set the RX mode.

Signed-off-by: David Dillow <dave@thedillows.org>
---
 drivers/net/typhoon.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/typhoon.c b/drivers/net/typhoon.c
index 1cc6713..5957d4e 100644
--- a/drivers/net/typhoon.c
+++ b/drivers/net/typhoon.c
@@ -936,7 +936,7 @@ typhoon_set_rx_mode(struct net_device *dev)
 		filter |= TYPHOON_RX_FILTER_MCAST_HASH;
 	}
 
-	INIT_COMMAND_NO_RESPONSE(&xp_cmd, TYPHOON_CMD_SET_RX_FILTER);
+	INIT_COMMAND_WITH_RESPONSE(&xp_cmd, TYPHOON_CMD_SET_RX_FILTER);
 	xp_cmd.parm1 = filter;
 	typhoon_issue_command(tp, 1, &xp_cmd, 0, NULL);
 }
-- 
1.7.2.3

