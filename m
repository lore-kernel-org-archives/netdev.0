From: Geert Uytterhoeven <geert@linux-m68k.org>
Subject: [PATCH] natsemi/macsonic: Remove superfluous interrupt disable/restore
Date: Tue, 21 Oct 2014 19:53:57 +0200
Message-ID: <1413914037-23693-1-git-send-email-geert@linux-m68k.org>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Geert Uytterhoeven <geert@linux-m68k.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

As of commit e4dc601bf99ccd1c ("m68k: Disable/restore interrupts in
hwreg_present()/hwreg_write()"), this is no longer needed.

Signed-off-by: Geert Uytterhoeven <geert@linux-m68k.org>
---
 drivers/net/ethernet/natsemi/macsonic.c | 4 ----
 1 file changed, 4 deletions(-)

diff --git a/drivers/net/ethernet/natsemi/macsonic.c b/drivers/net/ethernet/natsemi/macsonic.c
index 9e4ddbba70363b8f..66c2d50d5b8d12df 100644
--- a/drivers/net/ethernet/natsemi/macsonic.c
+++ b/drivers/net/ethernet/natsemi/macsonic.c
@@ -326,13 +326,9 @@ static int mac_onboard_sonic_probe(struct net_device *dev)
 	    macintosh_config->ident == MAC_MODEL_P588 ||
 	    macintosh_config->ident == MAC_MODEL_P575 ||
 	    macintosh_config->ident == MAC_MODEL_C610) {
-		unsigned long flags;
 		int card_present;
 
-		local_irq_save(flags);
 		card_present = hwreg_present((void*)ONBOARD_SONIC_REGISTERS);
-		local_irq_restore(flags);
-
 		if (!card_present) {
 			printk("none.\n");
 			return -ENODEV;
-- 
1.9.1
