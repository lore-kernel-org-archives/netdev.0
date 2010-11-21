From: Joe Perches <joe@perches.com>
Subject: [PATCH 49/62] wd: Use static const
Date: Sat, 20 Nov 2010 18:38:50 -0800
Message-ID: <c8b8437301d681f57a21d6f227867b87c4daecea.1290305776.git.joe@perches.com>
References: <cover.1290305773.git.joe@perches.com>
Cc: linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.perches.com ([173.55.12.10]:1719 "EHLO mail.perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757002Ab0KUCk3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 20 Nov 2010 21:40:29 -0500
In-Reply-To: <cover.1290305773.git.joe@perches.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Using static const generally increases object text and decreases data size.
It also generally decreases overall object size.

   text	   data	    bss	    dec	    hex	filename
   5252	     76	   1152	   6480	   1950	drivers/net/wd.o.old
   5199	     76	   1152	   6427	   191b	drivers/net/wd.o.new

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/wd.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/wd.c b/drivers/net/wd.c
index f1549ff..8831a33 100644
--- a/drivers/net/wd.c
+++ b/drivers/net/wd.c
@@ -275,7 +275,7 @@ static int __init wd_probe1(struct net_device *dev, int ioaddr)
 	dev->base_addr = ioaddr+WD_NIC_OFFSET;
 
 	if (dev->irq < 2) {
-		int irqmap[] = {9,3,5,7,10,11,15,4};
+		static const int irqmap[] = {9, 3, 5, 7, 10, 11, 15, 4};
 		int reg1 = inb(ioaddr+1);
 		int reg4 = inb(ioaddr+4);
 		if (ancient || reg1 == 0xff) {	/* Ack!! No way to read the IRQ! */
-- 
1.7.3.2.245.g03276.dirty

