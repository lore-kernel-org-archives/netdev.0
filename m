From: akpm@linux-foundation.org
Subject: [patch 17/28] drivers/atm/iphase.c: mostly kmalloc + memset conversion to kzalloc
Date: Fri, 10 Aug 2007 14:12:01 -0700
Message-ID: <200708102112.l7ALC1UV009424@imap1.linux-foundation.org>
Cc: netdev@vger.kernel.org, akpm@linux-foundation.org,
	m.kozlowski@tuxland.pl
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:52940 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S942074AbXHJVMV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Aug 2007 17:12:21 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Mariusz Kozlowski <m.kozlowski@tuxland.pl>

 drivers/atm/iphase.c | 111508 -> 111431 (-77 bytes)
 drivers/atm/iphase.o | 254740 -> 254260 (-480 bytes)

Signed-off-by: Mariusz Kozlowski <m.kozlowski@tuxland.pl>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 drivers/atm/iphase.c |   12 ++++++------
 1 files changed, 6 insertions(+), 6 deletions(-)

diff -puN drivers/atm/iphase.c~drivers-atm-iphasec-mostly-kmalloc-memset-conversion-to-kzalloc drivers/atm/iphase.c
--- a/drivers/atm/iphase.c~drivers-atm-iphasec-mostly-kmalloc-memset-conversion-to-kzalloc
+++ a/drivers/atm/iphase.c
@@ -1601,14 +1601,14 @@ static int rx_init(struct atm_dev *dev) 
   
 	skb_queue_head_init(&iadev->rx_dma_q);  
 	iadev->rx_free_desc_qhead = NULL;   
-	iadev->rx_open = kmalloc(4*iadev->num_vc,GFP_KERNEL);
-	if (!iadev->rx_open)  
-	{  
+
+	iadev->rx_open = kzalloc(4 * iadev->num_vc, GFP_KERNEL);
+	if (!iadev->rx_open) {
 		printk(KERN_ERR DEV_LABEL "itf %d couldn't get free page\n",
 		dev->number);  
 		goto err_free_dle;
 	}  
-	memset(iadev->rx_open, 0, 4*iadev->num_vc);  
+
         iadev->rxing = 1;
         iadev->rx_pkt_cnt = 0;
 	/* Mode Register */  
@@ -3171,12 +3171,12 @@ static int __devinit ia_init_one(struct 
         unsigned long flags;
 	int ret;
 
-	iadev = kmalloc(sizeof(*iadev), GFP_KERNEL); 
+	iadev = kzalloc(sizeof(*iadev), GFP_KERNEL);
 	if (!iadev) {
 		ret = -ENOMEM;
 		goto err_out;
 	}
-	memset(iadev, 0, sizeof(*iadev));
+
 	iadev->pci = pdev;
 
 	IF_INIT(printk("ia detected at bus:%d dev: %d function:%d\n",
_
