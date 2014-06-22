From: Ondrej Zary <linux@rainbow-software.org>
Subject: [PATCH] tulip: Poll link status more frequently for Comet chips
Date: Sun, 22 Jun 2014 12:01:12 +0200
Message-ID: <1403431272-2569-1-git-send-email-linux@rainbow-software.org>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Grant Grundler <grundler@parisc-linux.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

It now takes up to 60 seconds to detect cable (un)plug on ADMtek Comet chips.
That's too slow and might cause people to think that it doesn't work at all.

Poll link status every 2 seconds instead of 60 for ADMtek Comet chips.
That should be fast enough while not stressing the system too much.

Tested with ADMtek AN983B.

Signed-off-by: Ondrej Zary <linux@rainbow-software.org>
---
 drivers/net/ethernet/dec/tulip/timer.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/dec/tulip/timer.c b/drivers/net/ethernet/dec/tulip/timer.c
index 768379b..523d9dd 100644
--- a/drivers/net/ethernet/dec/tulip/timer.c
+++ b/drivers/net/ethernet/dec/tulip/timer.c
@@ -158,7 +158,7 @@ void comet_timer(unsigned long data)
 {
 	struct net_device *dev = (struct net_device *)data;
 	struct tulip_private *tp = netdev_priv(dev);
-	int next_tick = 60*HZ;
+	int next_tick = 2*HZ;
 
 	if (tulip_debug > 1)
 		netdev_dbg(dev, "Comet link status %04x partner capability %04x\n",
-- 
Ondrej Zary
