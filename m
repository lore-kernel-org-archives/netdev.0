From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 4/8] sky2: Reset tx train after interrupts disabled.
Date: Thu, 06 Aug 2009 09:12:17 -0700
Message-ID: <20090806161232.765129242@vyatta.com>
References: <20090806161213.148382653@vyatta.com>
Cc: netdev@vger.kernel.org, Mike McCormack <mikem@ring3k.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:38262 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756205AbZHFQoq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 6 Aug 2009 12:44:46 -0400
Content-Disposition: inline; filename=sky2-tx3.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Reseting the tx chain too soon results in invalid tx queue positions
being delivered in the status queue.  This also makes sure there's no
overlap between the cleanup done by sky2_tx_clean() and
sky2_tx_done().

Signed-off-by: Mike McCormack <mikem@ring3k.org>
Acked-by: Stephen Hemminger <shemminger@vyatta.com>
---
 drivers/net/sky2.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/sky2.c b/drivers/net/sky2.c
index a9bb3fa..ac303cb 100644
--- a/drivers/net/sky2.c
+++ b/drivers/net/sky2.c
@@ -1866,8 +1866,6 @@ static int sky2_down(struct net_device *dev)
 	      && port == 0 && hw->dev[1] && netif_running(hw->dev[1])))
 		sky2_write8(hw, SK_REG(port, GMAC_CTRL), GMC_RST_SET);

-	sky2_tx_reset(sky2);
-
 	sky2_write8(hw, SK_REG(port, RX_GMF_CTRL_T), GMF_RST_SET);

 	/* Force any delayed status interrrupt and NAPI */
@@ -1892,6 +1890,8 @@ static int sky2_down(struct net_device *dev)
 	/* turn off LED's */
 	sky2_write16(hw, B0_Y2LED, LED_STAT_OFF);

+	sky2_tx_reset(sky2);
+
 	sky2_tx_clean(dev);
 	sky2_rx_clean(sky2);

-- 
1.5.6.5

-- 

