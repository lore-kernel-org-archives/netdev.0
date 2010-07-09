From: Kulikov Vasiliy <segooon@gmail.com>
Subject: [PATCH] at1700: fix double free_irq
Date: Fri,  9 Jul 2010 16:31:26 +0400
Message-ID: <1278678686-7215-1-git-send-email-segooon@gmail.com>
Cc: "David S. Miller" <davem@davemloft.net>,
	Jiri Pirko <jpirko@redhat.com>, Joe Perches <joe@perches.com>,
	Stephen Hemminger <shemminger@vyatta.com>,
	Eric Dumazet <eric.dumazet@gmail.com>, netdev@vger.kernel.org
To: kernel-janitors@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ey0-f174.google.com ([209.85.215.174]:61480 "EHLO
	mail-ey0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755733Ab0GIMby (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Jul 2010 08:31:54 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

free_irq() is called both in net_close() and cleanup_card().  Since it
is requested in at1700_probe1(), leave free_irq() only in cleanup_card()
for balance.

Signed-off-by: Kulikov Vasiliy <segooon@gmail.com>
---
 drivers/net/at1700.c |    4 +---
 1 files changed, 1 insertions(+), 3 deletions(-)

diff --git a/drivers/net/at1700.c b/drivers/net/at1700.c
index 93185f5..8987689 100644
--- a/drivers/net/at1700.c
+++ b/drivers/net/at1700.c
@@ -811,10 +811,8 @@ static int net_close(struct net_device *dev)
 	/* No statistic counters on the chip to update. */
 
 	/* Disable the IRQ on boards of fmv18x where it is feasible. */
-	if (lp->jumpered) {
+	if (lp->jumpered)
 		outb(0x00, ioaddr + IOCONFIG1);
-		free_irq(dev->irq, dev);
-	}
 
 	/* Power-down the chip.  Green, green, green! */
 	outb(0x00, ioaddr + CONFIG_1);
-- 
1.7.0.4

