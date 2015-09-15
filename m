From: Ondrej Zary <linux@rainbow-software.org>
Subject: [PATCH 2/2] airo: Implement netif_carrier_on/off
Date: Tue, 15 Sep 2015 17:18:09 +0200
Message-ID: <1442330289-2907-2-git-send-email-linux@rainbow-software.org>
References: <1442330289-2907-1-git-send-email-linux@rainbow-software.org>
Cc: netdev@vger.kernel.org,
	Kernel development list <linux-kernel@vger.kernel.org>
To: Dan Williams <dcbw@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1442330289-2907-1-git-send-email-linux@rainbow-software.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add calls to netif_carrier_on and netif_carrier_off

Signed-off-by: Ondrej Zary <linux@rainbow-software.org>
---
 drivers/net/wireless/airo.c |    6 +++++-
 1 file changed, 5 insertions(+), 1 deletion(-)

diff --git a/drivers/net/wireless/airo.c b/drivers/net/wireless/airo.c
index a8f2767..629245c 100644
--- a/drivers/net/wireless/airo.c
+++ b/drivers/net/wireless/airo.c
@@ -3267,6 +3267,7 @@ static void airo_handle_link(struct airo_info *ai)
 			wake_up_interruptible(&ai->thr_wait);
 		} else
 			airo_send_event(ai->dev);
+		netif_carrier_on(ai->dev);
 	} else if (!scan_forceloss) {
 		if (auto_wep && !ai->expires) {
 			ai->expires = RUN_AT(3*HZ);
@@ -3277,7 +3278,9 @@ static void airo_handle_link(struct airo_info *ai)
 		eth_zero_addr(wrqu.ap_addr.sa_data);
 		wrqu.ap_addr.sa_family = ARPHRD_ETHER;
 		wireless_send_event(ai->dev, SIOCGIWAP, &wrqu, NULL);
-	}
+		netif_carrier_off(ai->dev);
+	} else
+		netif_carrier_off(ai->dev);
 }
 
 static void airo_handle_rx(struct airo_info *ai)
@@ -3613,6 +3616,7 @@ static void disable_MAC( struct airo_info *ai, int lock ) {
 		return;
 
 	if (test_bit(FLAG_ENABLED, &ai->flags)) {
+		netif_carrier_off(ai->dev);
 		memset(&cmd, 0, sizeof(cmd));
 		cmd.cmd = MAC_DISABLE; // disable in case already enabled
 		issuecommand(ai, &cmd, &rsp);
-- 
Ondrej Zary
