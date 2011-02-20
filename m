From: Henry Nestler <henry.nestler@gmail.com>
Subject: [PATCH 1/2] DM9000B: Fix reg_save after spin_lock in dm9000_timeout
Date: Sun, 20 Feb 2011 22:44:58 +0100
Message-ID: <4D618B5A.4020009@henry.nestler.mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: trivial@kernel.org, akpm@linux-foundation.org, tori@unhappy.mine.nu
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f52.google.com ([209.85.214.52]:50014 "EHLO
	mail-bw0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754981Ab1BTVpA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 20 Feb 2011 16:45:00 -0500
Received: by bwz4 with SMTP id 4so5100439bwz.11
        for <netdev@vger.kernel.org>; Sun, 20 Feb 2011 13:44:59 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The spin_lock should hold before reading register.
---
Kernel version 2.6.38-rc5

 drivers/net/dm9000.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/dm9000.c b/drivers/net/dm9000.c
index 2d4c4fc..2bbd496 100644
--- a/drivers/net/dm9000.c
+++ b/drivers/net/dm9000.c
@@ -852,8 +852,8 @@ static void dm9000_timeout(struct net_device *dev)
 	unsigned long flags;
 
 	/* Save previous register address */
-	reg_save = readb(db->io_addr);
 	spin_lock_irqsave(&db->lock, flags);
+	reg_save = readb(db->io_addr);
 
 	netif_stop_queue(dev);
 	dm9000_reset(db);

