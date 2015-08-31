From: Ondrej Zary <linux@rainbow-software.org>
Subject: [PATCH 2/2] airo: Implement netif_carrier_on/off
Date: Mon, 31 Aug 2015 21:19:54 +0200
Message-ID: <1441048794-31237-2-git-send-email-linux@rainbow-software.org>
References: <1441048794-31237-1-git-send-email-linux@rainbow-software.org>
Cc: Kernel development list <linux-kernel@vger.kernel.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns.gsystem.sk ([62.176.172.50]:46041 "EHLO gsystem.sk"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754000AbbHaTUH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 31 Aug 2015 15:20:07 -0400
In-Reply-To: <1441048794-31237-1-git-send-email-linux@rainbow-software.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add calls to netif_carrier_on and netif_carrier_off

Signed-off-by: Ondrej Zary <linux@rainbow-software.org>
---
 drivers/net/wireless/airo.c |    6 +++++-
 1 file changed, 5 insertions(+), 1 deletion(-)

diff --git a/drivers/net/wireless/airo.c b/drivers/net/wireless/airo.c
index 2066a1f..1a9ddcd 100644
--- a/drivers/net/wireless/airo.c
+++ b/drivers/net/wireless/airo.c
@@ -3266,6 +3266,7 @@ static void airo_handle_link(struct airo_info *ai)
 			wake_up_interruptible(&ai->thr_wait);
 		} else
 			airo_send_event(ai->dev);
+		netif_carrier_on(ai->dev);
 	} else if (!scan_forceloss) {
 		if (auto_wep && !ai->expires) {
 			ai->expires = RUN_AT(3*HZ);
@@ -3276,7 +3277,9 @@ static void airo_handle_link(struct airo_info *ai)
 		eth_zero_addr(wrqu.ap_addr.sa_data);
 		wrqu.ap_addr.sa_family = ARPHRD_ETHER;
 		wireless_send_event(ai->dev, SIOCGIWAP, &wrqu, NULL);
-	}
+		netif_carrier_off(ai->dev);
+	} else
+		netif_carrier_off(ai->dev);
 }
 
 static void airo_handle_rx(struct airo_info *ai)
@@ -3612,6 +3615,7 @@ static void disable_MAC( struct airo_info *ai, int lock ) {
 		return;
 
 	if (test_bit(FLAG_ENABLED, &ai->flags)) {
+		netif_carrier_off(ai->dev);
 		memset(&cmd, 0, sizeof(cmd));
 		cmd.cmd = MAC_DISABLE; // disable in case already enabled
 		issuecommand(ai, &cmd, &rsp);
-- 
Ondrej Zary
