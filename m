From: Kalle Pokki <kalle.pokki@eke.com>
Subject: [PATCH] bfin_mac: Make the MDIO polling faster
Date: Tue, 29 Jan 2008 14:28:51 +0200 (EET)
Message-ID: <Pine.LNX.4.64.0801291427300.7503@pc-213-140-179-32.aina.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
To: netdev@vger.kernel.org, Bryan Wu <bryan.wu@analog.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.aina.net ([81.16.64.154]:33093 "EHLO smtp1.aina.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752383AbYA2MiX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 29 Jan 2008 07:38:23 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The poll routine always got 10 ms penalty when called immediately
after starting the transfer. The MDIO transfer takes 25.6 us at the
nominal 2.5 MHz, so MAX_TIMEOUT_CNT being 500 is still big enough.
---
 drivers/net/bfin_mac.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/bfin_mac.c b/drivers/net/bfin_mac.c
index c199633..d2e6813 100644
--- a/drivers/net/bfin_mac.c
+++ b/drivers/net/bfin_mac.c
@@ -296,7 +296,7 @@ static void mdio_poll(void)
 
 	/* poll the STABUSY bit */
 	while ((bfin_read_EMAC_STAADD()) & STABUSY) {
-		mdelay(10);
+		udelay(1);
 		if (timeout_cnt-- < 0) {
 			printk(KERN_ERR DRV_NAME
 			": wait MDC/MDIO transaction to complete timeout\n");
-- 
1.4.4.2

