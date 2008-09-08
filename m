From: Magnus Damm <magnus.damm@gmail.com>
Subject: [PATCH] smc91x: fix nowait printout
Date: Mon, 08 Sep 2008 14:02:56 +0900
Message-ID: <20080908050256.11555.34058.sendpatchset@rx1.opensource.se>
Cc: eric.miao@marvell.com, Magnus Damm <magnus.damm@gmail.com>,
	nico@cam.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rv-out-0506.google.com ([209.85.198.226]:6780 "EHLO
	rv-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751484AbYIHFED (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Sep 2008 01:04:03 -0400
Received: by rv-out-0506.google.com with SMTP id k40so1293962rvb.1
        for <netdev@vger.kernel.org>; Sun, 07 Sep 2008 22:04:03 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Magnus Damm <damm@igel.co.jp>

Commit c4f0e76747e80578a8f7fddd82fd0ce8127bd2f8 added nowait platform
data support. The printout code was however not updated, so the value
of SMC_NOWAIT is still used. This patch makes sure that nowait is printed
accordingly to platform data.

Signed-off-by: Magnus Damm <damm@igel.co.jp>
---

 drivers/net/smc91x.c |    3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

--- 0001/drivers/net/smc91x.c
+++ work/drivers/net/smc91x.c	2008-09-03 18:42:56.000000000 +0900
@@ -1961,7 +1961,8 @@ static int __init smc_probe(struct net_d
 		if (dev->dma != (unsigned char)-1)
 			printk(" DMA %d", dev->dma);
 
-		printk("%s%s\n", nowait ? " [nowait]" : "",
+		printk("%s%s\n",
+			lp->cfg.flags & SMC91X_NOWAIT ? " [nowait]" : "",
 			THROTTLE_TX_PKTS ? " [throttle_tx]" : "");
 
 		if (!is_valid_ether_addr(dev->dev_addr)) {
