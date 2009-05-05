From: Alexander Beregalov <a.beregalov@gmail.com>
Subject: [PATCH] lasi_82596: fix printk format warning
Date: Tue,  5 May 2009 15:03:32 +0400
Message-ID: <1241521412-16190-1-git-send-email-a.beregalov@gmail.com>
Cc: Alexander Beregalov <a.beregalov@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rv-out-0506.google.com ([209.85.198.226]:27154 "EHLO
	rv-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755044AbZEELDi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 May 2009 07:03:38 -0400
Received: by rv-out-0506.google.com with SMTP id f9so3428910rvb.1
        for <netdev@vger.kernel.org>; Tue, 05 May 2009 04:03:38 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

drivers/net/lasi_82596.c:164: warning: format '%lx' expects type
	'long unsigned int', but argument 3 has type 'resource_size_t'
drivers/net/lasi_82596.c:169: warning: format '%lx' expects type
	'long unsigned int', but argument 2 has type 'resource_size_t'

Signed-off-by: Alexander Beregalov <a.beregalov@gmail.com>
---
 drivers/net/lasi_82596.c |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/lasi_82596.c b/drivers/net/lasi_82596.c
index efbae4b..a0c5785 100644
--- a/drivers/net/lasi_82596.c
+++ b/drivers/net/lasi_82596.c
@@ -161,12 +161,12 @@ lan_init_chip(struct parisc_device *dev)
 
 	if (!dev->irq) {
 		printk(KERN_ERR "%s: IRQ not found for i82596 at 0x%lx\n",
-			__FILE__, dev->hpa.start);
+			__FILE__, (unsigned long)dev->hpa.start);
 		return -ENODEV;
 	}
 
-	printk(KERN_INFO "Found i82596 at 0x%lx, IRQ %d\n", dev->hpa.start,
-			dev->irq);
+	printk(KERN_INFO "Found i82596 at 0x%lx, IRQ %d\n",
+			(unsigned long)dev->hpa.start, dev->irq);
 
 	netdevice = alloc_etherdev(sizeof(struct i596_private));
 	if (!netdevice)
-- 
1.6.2.3

