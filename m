From: Mike McCormack <mikem@ring3k.org>
Subject: [PATCH 2/2] sky2: Reset tx train after interrupts disabled
Date: Tue, 04 Aug 2009 18:26:24 +0900
Message-ID: <4A77FEC0.7050304@ring3k.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pz0-f196.google.com ([209.85.222.196]:42807 "EHLO
	mail-pz0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755320AbZHDJeX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Aug 2009 05:34:23 -0400
Received: by pzk34 with SMTP id 34so2857465pzk.4
        for <netdev@vger.kernel.org>; Tue, 04 Aug 2009 02:34:23 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Reseting the tx chain too soon results in invalid tx queue positions
being delivered in the status queue.  This also makes sure there's no
overlap between the cleanup done by sky2_tx_clean() and sky2_tx_done().

Signed-off-by: Mike McCormack <mikem@ring3k.org>
---
 drivers/net/sky2.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/sky2.c b/drivers/net/sky2.c
index cb3412a..e9cb1e7 100644
--- a/drivers/net/sky2.c
+++ b/drivers/net/sky2.c
@@ -1875,8 +1875,6 @@ static int sky2_down(struct net_device *dev)
 	      && port == 0 && hw->dev[1] && netif_running(hw->dev[1])))
 		sky2_write8(hw, SK_REG(port, GMAC_CTRL), GMC_RST_SET);
 
-	sky2_tx_reset(sky2);
-
 	sky2_write8(hw, SK_REG(port, RX_GMF_CTRL_T), GMF_RST_SET);
 
 	/* Force any delayed status interrrupt and NAPI */
@@ -1901,6 +1899,8 @@ static int sky2_down(struct net_device *dev)
 	/* turn off LED's */
 	sky2_write16(hw, B0_Y2LED, LED_STAT_OFF);
 
+	sky2_tx_reset(sky2);
+
 	sky2_tx_clean(dev);
 	sky2_rx_clean(sky2);
 
-- 
1.5.6.5

