From: Geert Uytterhoeven <geert@linux-m68k.org>
Subject: [PATCH] cirrus/mac89x0: Remove superfluous interrupt disable/restore
Date: Tue, 21 Oct 2014 19:53:11 +0200
Message-ID: <1413913991-23634-1-git-send-email-geert@linux-m68k.org>
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
 drivers/net/ethernet/cirrus/mac89x0.c | 8 ++------
 1 file changed, 2 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/cirrus/mac89x0.c b/drivers/net/ethernet/cirrus/mac89x0.c
index e285f384b0966dfe..07719676c305fc0b 100644
--- a/drivers/net/ethernet/cirrus/mac89x0.c
+++ b/drivers/net/ethernet/cirrus/mac89x0.c
@@ -216,14 +216,10 @@ struct net_device * __init mac89x0_probe(int unit)
 	ioaddr = (unsigned long)
 		nubus_slot_addr(slot) | (((slot&0xf) << 20) + DEFAULTIOBASE);
 	{
-		unsigned long flags;
 		int card_present;
 
-		local_irq_save(flags);
-		card_present = (hwreg_present((void*) ioaddr+4) &&
-				hwreg_present((void*) ioaddr + DATA_PORT));
-		local_irq_restore(flags);
-
+		card_present = (hwreg_present((void *)ioaddr + 4) &&
+				hwreg_present((void *)ioaddr + DATA_PORT));
 		if (!card_present)
 			goto out;
 	}
-- 
1.9.1
