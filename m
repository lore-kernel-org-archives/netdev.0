From: akpm@linux-foundation.org
Subject: [patch 06/11] atm: fix direct casts of pointers to u32 in the InterPhase driver
Date: Wed, 30 Jul 2008 12:37:38 -0700
Message-ID: <200807301937.m6UJbc12012442@imap1.linux-foundation.org>
Cc: netdev@vger.kernel.org, akpm@linux-foundation.org,
	dhowells@redhat.com, chas@cmf.nrl.navy.mil
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:44169 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754500AbYG3Tic (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Jul 2008 15:38:32 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Howells <dhowells@redhat.com>

Fix direct casts of pointers to u32 in the InterPhase ATM driver.  These are
all arguments being passed to printk() calls.  So drop the cast and change the
%x to a %p.

Signed-off-by: David Howells <dhowells@redhat.com>
Acked-by: Chas Williams <chas@cmf.nrl.navy.mil>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 drivers/atm/iphase.c |   40 ++++++++++++++++++++--------------------
 1 file changed, 20 insertions(+), 20 deletions(-)

diff -puN drivers/atm/iphase.c~atm-fix-direct-casts-of-pointers-to-u32-in-the-interphase-driver drivers/atm/iphase.c
--- a/drivers/atm/iphase.c~atm-fix-direct-casts-of-pointers-to-u32-in-the-interphase-driver
+++ a/drivers/atm/iphase.c
@@ -156,8 +156,8 @@ static void ia_hack_tcq(IADEV *dev) {
         }
         iavcc_r->vc_desc_cnt--;
         dev->desc_tbl[desc1 -1].timestamp = 0;
-        IF_EVENT(printk("ia_hack: return_q skb = 0x%x desc = %d\n", 
-                                   (u32)dev->desc_tbl[desc1 -1].txskb, desc1);)
+        IF_EVENT(printk("ia_hack: return_q skb = 0x%p desc = %d\n",
+                                   dev->desc_tbl[desc1 -1].txskb, desc1);)
         if (iavcc_r->pcr < dev->rate_limit) {
            IA_SKB_STATE (dev->desc_tbl[desc1-1].txskb) |= IA_TX_DONE;
            if (ia_enque_rtn_q(&dev->tx_return_q, dev->desc_tbl[desc1 -1]) < 0)
@@ -527,8 +527,8 @@ static int ia_cbr_setup (IADEV *dev, str
       inc = 0;
       testSlot = idealSlot;
       TstSchedTbl = (u16*)(SchedTbl+testSlot);  //set index and read in value
-      IF_CBR(printk("CBR Testslot 0x%x AT Location 0x%x, NumToAssign=%d\n",
-                                testSlot, (u32)TstSchedTbl,toBeAssigned);) 
+      IF_CBR(printk("CBR Testslot 0x%x AT Location 0x%p, NumToAssign=%d\n",
+                                testSlot, TstSchedTbl,toBeAssigned);)
       memcpy((caddr_t)&cbrVC,(caddr_t)TstSchedTbl,sizeof(cbrVC));
       while (cbrVC)  // If another VC at this location, we have to keep looking
       {
@@ -536,8 +536,8 @@ static int ia_cbr_setup (IADEV *dev, str
           testSlot = idealSlot - inc;
           if (testSlot < 0) { // Wrap if necessary
              testSlot += dev->CbrTotEntries;
-             IF_CBR(printk("Testslot Wrap. STable Start=0x%x,Testslot=%d\n",
-                                                       (u32)SchedTbl,testSlot);)
+             IF_CBR(printk("Testslot Wrap. STable Start=0x%p,Testslot=%d\n",
+                                                       SchedTbl,testSlot);)
           }
           TstSchedTbl = (u16 *)(SchedTbl + testSlot);  // set table index
           memcpy((caddr_t)&cbrVC,(caddr_t)TstSchedTbl,sizeof(cbrVC)); 
@@ -552,8 +552,8 @@ static int ia_cbr_setup (IADEV *dev, str
           } 
           // set table index and read in value
           TstSchedTbl = (u16*)(SchedTbl + testSlot);
-          IF_CBR(printk("Reading CBR Tbl from 0x%x, CbrVal=0x%x Iteration %d\n",
-                          (u32)TstSchedTbl,cbrVC,inc);) 
+          IF_CBR(printk("Reading CBR Tbl from 0x%p, CbrVal=0x%x Iteration %d\n",
+                          TstSchedTbl,cbrVC,inc);)
           memcpy((caddr_t)&cbrVC,(caddr_t)TstSchedTbl,sizeof(cbrVC));
        } /* while */
        // Move this VCI number into this location of the CBR Sched table.
@@ -1427,11 +1427,11 @@ static int rx_init(struct atm_dev *dev) 
 	/* We know this is 32bit bus addressed so the following is safe */
 	writel(iadev->rx_dle_dma & 0xfffff000,
 	       iadev->dma + IPHASE5575_RX_LIST_ADDR);  
-	IF_INIT(printk("Tx Dle list addr: 0x%08x value: 0x%0x\n", 
-                      (u32)(iadev->dma+IPHASE5575_TX_LIST_ADDR), 
+	IF_INIT(printk("Tx Dle list addr: 0x%p value: 0x%0x\n",
+                      iadev->dma+IPHASE5575_TX_LIST_ADDR,
                       *(u32*)(iadev->dma+IPHASE5575_TX_LIST_ADDR));  
-	printk("Rx Dle list addr: 0x%08x value: 0x%0x\n", 
-                      (u32)(iadev->dma+IPHASE5575_RX_LIST_ADDR), 
+	printk("Rx Dle list addr: 0x%p value: 0x%0x\n",
+                      iadev->dma+IPHASE5575_RX_LIST_ADDR,
                       *(u32*)(iadev->dma+IPHASE5575_RX_LIST_ADDR));)  
   
 	writew(0xffff, iadev->reass_reg+REASS_MASK_REG);  
@@ -1470,7 +1470,7 @@ static int rx_init(struct atm_dev *dev) 
 		buf_desc_ptr++;		  
 		rx_pkt_start += iadev->rx_buf_sz;  
 	}  
-	IF_INIT(printk("Rx Buffer desc ptr: 0x%0x\n", (u32)(buf_desc_ptr));)  
+	IF_INIT(printk("Rx Buffer desc ptr: 0x%p\n", buf_desc_ptr);)
         i = FREE_BUF_DESC_Q*iadev->memSize; 
 	writew(i >> 16,  iadev->reass_reg+REASS_QUEUE_BASE); 
         writew(i, iadev->reass_reg+FREEQ_ST_ADR);
@@ -1487,7 +1487,7 @@ static int rx_init(struct atm_dev *dev) 
 		*freeq_start = (u_short)i;  
 		freeq_start++;  
 	}  
-	IF_INIT(printk("freeq_start: 0x%0x\n", (u32)freeq_start);)  
+	IF_INIT(printk("freeq_start: 0x%p\n", freeq_start);)
         /* Packet Complete Queue */
         i = (PKT_COMP_Q * iadev->memSize) & 0xffff;
         writew(i, iadev->reass_reg+PCQ_ST_ADR);
@@ -1713,7 +1713,7 @@ static void tx_dle_intr(struct atm_dev *
                IA_SKB_STATE(skb) |= IA_DLED;
                skb_queue_tail(&iavcc->txing_skb, skb);
             }
-            IF_EVENT(printk("tx_dle_intr: enque skb = 0x%x \n", (u32)skb);)
+            IF_EVENT(printk("tx_dle_intr: enque skb = 0x%p \n", skb);)
             if (++dle == iadev->tx_dle_q.end)
                  dle = iadev->tx_dle_q.start;
         }
@@ -2044,8 +2044,8 @@ static int tx_init(struct atm_dev *dev) 
         writew(tmp16, iadev->seg_reg+CBR_TAB_END+1); // CBR_PTR;
         tmp16 = (CBR_SCHED_TABLE*iadev->memSize + iadev->num_vc*6 - 2) >> 1;
         writew(tmp16, iadev->seg_reg+CBR_TAB_END);
-        IF_INIT(printk("iadev->seg_reg = 0x%x CBR_PTR_BASE = 0x%x\n",
-               (u32)iadev->seg_reg, readw(iadev->seg_reg+CBR_PTR_BASE));)
+        IF_INIT(printk("iadev->seg_reg = 0x%p CBR_PTR_BASE = 0x%x\n",
+               iadev->seg_reg, readw(iadev->seg_reg+CBR_PTR_BASE));)
         IF_INIT(printk("CBR_TAB_BEG = 0x%x, CBR_TAB_END = 0x%x, CBR_PTR = 0x%x\n",
           readw(iadev->seg_reg+CBR_TAB_BEG), readw(iadev->seg_reg+CBR_TAB_END),
           readw(iadev->seg_reg+CBR_TAB_END+1));)
@@ -2963,8 +2963,8 @@ static int ia_pkt_tx (struct atm_vcc *vc
  
 	/* Put the packet in a tx buffer */   
 	trailer = iadev->tx_buf[desc-1].cpcs;
-        IF_TX(printk("Sent: skb = 0x%x skb->data: 0x%x len: %d, desc: %d\n",
-                  (u32)skb, (u32)skb->data, skb->len, desc);)
+        IF_TX(printk("Sent: skb = 0x%p skb->data: 0x%p len: %d, desc: %d\n",
+                  skb, skb->data, skb->len, desc);)
 	trailer->control = 0; 
         /*big endian*/ 
 	trailer->length = ((skb->len & 0xff) << 8) | ((skb->len & 0xff00) >> 8);
@@ -3181,7 +3181,7 @@ static int __devinit ia_init_one(struct 
 	}
 	dev->dev_data = iadev;
 	IF_INIT(printk(DEV_LABEL "registered at (itf :%d)\n", dev->number);)
-	IF_INIT(printk("dev_id = 0x%x iadev->LineRate = %d \n", (u32)dev,
+	IF_INIT(printk("dev_id = 0x%p iadev->LineRate = %d \n", dev,
 		iadev->LineRate);)
 
 	pci_set_drvdata(pdev, dev);
_
