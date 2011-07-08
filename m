From: stufever@gmail.com
Subject: [PATCH] ATM: Delete no use FILL_RX_POOLS_IN_BH marco
Date: Fri,  8 Jul 2011 21:01:43 +0800
Message-ID: <1310130103-4847-1-git-send-email-wangshaoyan.pt@taobao.com>
Cc: Wang Shaoyan <wangshaoyan.pt@taobao.com>,
	Chas Williams <chas@cmf.nrl.navy.mil>,
	linux-atm-general@lists.sourceforge.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iw0-f174.google.com ([209.85.214.174]:37985 "EHLO
	mail-iw0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751971Ab1GHM5d (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Jul 2011 08:57:33 -0400
Received: by iwn6 with SMTP id 6so1727961iwn.19
        for <netdev@vger.kernel.org>; Fri, 08 Jul 2011 05:57:33 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wang Shaoyan <wangshaoyan.pt@taobao.com>

The macro FILL_RX_POOLS_IN_BH is never been used, in order to avoid 
the compiler reports error because of the usage of function INIT_WORK,
we just delete the marco.

Cc: Chas Williams <chas@cmf.nrl.navy.mil>
Cc: linux-atm-general@lists.sourceforge.net
Signed-off-by: Wang Shaoyan <wangshaoyan.pt@taobao.com>
---
 drivers/atm/ambassador.c |   11 +----------
 drivers/atm/ambassador.h |    4 ----
 2 files changed, 1 insertions(+), 14 deletions(-)

diff --git a/drivers/atm/ambassador.c b/drivers/atm/ambassador.c
index a5fcb1e..bb3b016 100644
--- a/drivers/atm/ambassador.c
+++ b/drivers/atm/ambassador.c
@@ -813,7 +813,7 @@ static void fill_rx_pool (amb_dev * dev, unsigned char pool,
   return;
 }
 
-// top up all RX pools (can also be called as a bottom half)
+// top up all RX pools
 static void fill_rx_pools (amb_dev * dev) {
   unsigned char pool;
   
@@ -872,11 +872,7 @@ static irqreturn_t interrupt_handler(int irq, void *dev_id) {
       ++irq_work;
   
     if (irq_work) {
-#ifdef FILL_RX_POOLS_IN_BH
-      schedule_work (&dev->bh);
-#else
       fill_rx_pools (dev);
-#endif
 
       PRINTD (DBG_IRQ, "work done: %u", irq_work);
     } else {
@@ -2154,11 +2150,6 @@ static void setup_dev(amb_dev *dev, struct pci_dev *pci_dev)
       dev->tx_avail = ATM_OC3_PCR;
       dev->rx_avail = ATM_OC3_PCR;
       
-#ifdef FILL_RX_POOLS_IN_BH
-      // initialise bottom half
-      INIT_WORK(&dev->bh, (void (*)(void *)) fill_rx_pools, dev);
-#endif
-      
       // semaphore for txer/rxer modifications - we cannot use a
       // spinlock as the critical region needs to switch processes
       mutex_init(&dev->vcc_sf);
diff --git a/drivers/atm/ambassador.h b/drivers/atm/ambassador.h
index bd1c46a..aa97105 100644
--- a/drivers/atm/ambassador.h
+++ b/drivers/atm/ambassador.h
@@ -630,10 +630,6 @@ struct amb_dev {
   u32              iobase;
   u32 *            membase;
 
-#ifdef FILL_RX_POOLS_IN_BH
-  struct work_struct bh;
-#endif
-  
   amb_cq           cq;
   amb_txq          txq;
   amb_rxq          rxq[NUM_RX_POOLS];
-- 
1.7.4.1

