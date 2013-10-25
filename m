From: Ben Boeckel <mathstuf@gmail.com>
Subject: [PATCH net-next 5/6] smc91c92_cs: replace printk with netdev_ calls
Date: Fri, 25 Oct 2013 02:27:01 -0400
Message-ID: <1382682422-22677-6-git-send-email-mathstuf@gmail.com>
References: <1382682422-22677-1-git-send-email-mathstuf@gmail.com>
Cc: Ben Boeckel <mathstuf@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f170.google.com ([209.85.216.170]:57702 "EHLO
	mail-qc0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751608Ab3JYG1X (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Oct 2013 02:27:23 -0400
Received: by mail-qc0-f170.google.com with SMTP id n9so2000350qcw.29
        for <netdev@vger.kernel.org>; Thu, 24 Oct 2013 23:27:23 -0700 (PDT)
In-Reply-To: <1382682422-22677-1-git-send-email-mathstuf@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Ben Boeckel <mathstuf@gmail.com>
---
 drivers/net/ethernet/smsc/smc91c92_cs.c | 5 ++---
 1 file changed, 2 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/smsc/smc91c92_cs.c b/drivers/net/ethernet/smsc/smc91c92_cs.c
index 656d2e2..eb48b1b 100644
--- a/drivers/net/ethernet/smsc/smc91c92_cs.c
+++ b/drivers/net/ethernet/smsc/smc91c92_cs.c
@@ -1036,7 +1036,7 @@ static void smc_dump(struct net_device *dev)
     save = inw(ioaddr + BANK_SELECT);
     for (w = 0; w < 4; w++) {
 	SMC_SELECT_BANK(w);
-	netdev_printk(KERN_DEBUG, dev, "bank %d: ", w);
+	netdev_dbg(dev, "bank %d: ", w);
 	for (i = 0; i < 14; i += 2)
 	    pr_cont(" %04x", inw(ioaddr + i));
 	pr_cont("\n");
@@ -1213,8 +1213,7 @@ static netdev_tx_t smc_start_xmit(struct sk_buff *skb,
     if (smc->saved_skb) {
 	/* THIS SHOULD NEVER HAPPEN. */
 	dev->stats.tx_aborted_errors++;
-	netdev_printk(KERN_DEBUG, dev,
-		      "Internal error -- sent packet while busy\n");
+	netdev_dbg(dev, "Internal error -- sent packet while busy\n");
 	return NETDEV_TX_BUSY;
     }
     smc->saved_skb = skb;
-- 
1.8.3.1
