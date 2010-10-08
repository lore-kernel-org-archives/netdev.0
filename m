From: Nicolas Kaiser <nikai@nikai.net>
Subject: [PATCH] net/tg3: simplify conditional
Date: Fri, 8 Oct 2010 11:29:27 +0200
Message-ID: <20101008112927.0ca949cf@absol.kitzblitz>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Michael Chan <mchan@broadcom.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Matt Carlson <mcarlson@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webhosting01.bon.m2soft.com ([195.38.20.32]:60693 "EHLO
	webhosting01.bon.m2soft.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754804Ab0JHJcH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Oct 2010 05:32:07 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Simplify: ((a && !b) || (!a && b)) => (a != b)

Signed-off-by: Nicolas Kaiser <nikai@nikai.net>
---
 drivers/net/tg3.c |    3 +--
 1 files changed, 1 insertions(+), 2 deletions(-)

diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index 16e1a95..714f0fb 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -9967,8 +9967,7 @@ static int tg3_set_pauseparam(struct net_device *dev, struct ethtool_pauseparam
 
 		if (!(phydev->supported & SUPPORTED_Pause) ||
 		    (!(phydev->supported & SUPPORTED_Asym_Pause) &&
-		     ((epause->rx_pause && !epause->tx_pause) ||
-		      (!epause->rx_pause && epause->tx_pause))))
+		     (epause->rx_pause != epause->tx_pause)))
 			return -EINVAL;
 
 		tp->link_config.flowctrl = 0;
-- 
1.7.2.2
