From: Mike McCormack <mikem@ring3k.org>
Subject: [PATCH 3/5] sky2: Reset tx train after interrupts disabled.
Date: Mon, 3 Aug 2009 20:08:47 +0900
Message-ID: <392fb48f0908030408g72b9de73g9444b27a08e761b8@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.157]:15179 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754280AbZHCLIr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Aug 2009 07:08:47 -0400
Received: by fg-out-1718.google.com with SMTP id e21so986022fga.17
        for <netdev@vger.kernel.org>; Mon, 03 Aug 2009 04:08:47 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Reseting the tx chain too soon results in invalid tx queue positions
being delivered in the status queue.  This also makes sure there's no
overlap between the cleanup done by sky2_tx_clean() and
sky2_tx_done().

Signed-off-by: Mike McCormack <mikem@ring3k.org>
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
