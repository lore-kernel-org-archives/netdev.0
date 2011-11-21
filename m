From: Mark Brown <broonie@opensource.wolfsonmicro.com>
Subject: [PATCH] dm9000: Fix check for disabled wake on LAN
Date: Mon, 21 Nov 2011 17:51:56 +0000
Message-ID: <1321897916-5030-1-git-send-email-broonie@opensource.wolfsonmicro.com>
Cc: netdev@vger.kernel.org, patches@opensource.wolfsonmicro.com,
	Mark Brown <broonie@opensource.wolfsonmicro.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from opensource.wolfsonmicro.com ([80.75.67.52]:46520 "EHLO
	opensource.wolfsonmicro.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751517Ab1KURwS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Nov 2011 12:52:18 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We're trying to check if any options are defined which isn't wha the
existing code does due to confusing & and &&.

Signed-off-by: Mark Brown <broonie@opensource.wolfsonmicro.com>
---
 drivers/net/ethernet/davicom/dm9000.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/davicom/dm9000.c b/drivers/net/ethernet/davicom/dm9000.c
index 26be1df..f801754 100644
--- a/drivers/net/ethernet/davicom/dm9000.c
+++ b/drivers/net/ethernet/davicom/dm9000.c
@@ -614,7 +614,7 @@ static int dm9000_set_wol(struct net_device *dev, struct ethtool_wolinfo *w)
 
 		if (!dm->wake_state)
 			irq_set_irq_wake(dm->irq_wake, 1);
-		else if (dm->wake_state & !opts)
+		else if (dm->wake_state && !opts)
 			irq_set_irq_wake(dm->irq_wake, 0);
 	}
 
-- 
1.7.7.3
