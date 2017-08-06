From: SF Markus Elfring <elfring@users.sourceforge.net>
Subject: [PATCH 2/3] ATM-iphase: Delete five error messages for a failed
 memory allocation
Date: Sun, 6 Aug 2017 08:28:19 +0200
Message-ID: <ddae6055-5d63-17bf-4bce-0cfa346b3515@users.sourceforge.net>
References: <c30df8dd-a6e9-23c1-842b-afa8696e10d4@users.sourceforge.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: LKML <linux-kernel@vger.kernel.org>,
        kernel-janitors@vger.kernel.org
To: linux-atm-general@lists.sourceforge.net, netdev@vger.kernel.org,
        Chas Williams <3chas3@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <c30df8dd-a6e9-23c1-842b-afa8696e10d4@users.sourceforge.net>
Content-Language: en-GB
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Markus Elfring <elfring@users.sourceforge.net>
Date: Sat, 5 Aug 2017 22:10:41 +0200

Omit extra messages for a memory allocation failure in these functions.

This issue was detected by using the Coccinelle software.

Link: http://events.linuxfoundation.org/sites/events/files/slides/LCJ16-Refactor_Strings-WSang_0.pdf
Signed-off-by: Markus Elfring <elfring@users.sourceforge.net>
---
 drivers/atm/iphase.c | 30 +++++++++++-------------------
 1 file changed, 11 insertions(+), 19 deletions(-)

diff --git a/drivers/atm/iphase.c b/drivers/atm/iphase.c
index 472762f70921..ad4c1b41ba98 100644
--- a/drivers/atm/iphase.c
+++ b/drivers/atm/iphase.c
@@ -1623,11 +1623,8 @@ static int rx_init(struct atm_dev *dev)
 	iadev->rx_free_desc_qhead = NULL;   
 
 	iadev->rx_open = kzalloc(4 * iadev->num_vc, GFP_KERNEL);
-	if (!iadev->rx_open) {
-		printk(KERN_ERR DEV_LABEL "itf %d couldn't get free page\n",
-		dev->number);  
+	if (!iadev->rx_open)
 		goto err_free_dle;
-	}  
 
         iadev->rxing = 1;
         iadev->rx_pkt_cnt = 0;
@@ -1982,19 +1979,17 @@ static int tx_init(struct atm_dev *dev)
 	iadev->tx_buf = kmalloc_array(iadev->num_tx_desc,
 				      sizeof(*iadev->tx_buf),
 				      GFP_KERNEL);
-        if (!iadev->tx_buf) {
-            printk(KERN_ERR DEV_LABEL " couldn't get mem\n");
-	    goto err_free_dle;
-        }
+	if (!iadev->tx_buf)
+		goto err_free_dle;
+
        	for (i= 0; i< iadev->num_tx_desc; i++)
        	{
 	    struct cpcs_trailer *cpcs;
  
        	    cpcs = kmalloc(sizeof(*cpcs), GFP_KERNEL|GFP_DMA);
-            if(!cpcs) {                
-		printk(KERN_ERR DEV_LABEL " couldn't get freepage\n"); 
-		goto err_free_tx_bufs;
-            }
+		if (!cpcs)
+			goto err_free_tx_bufs;
+
 	    iadev->tx_buf[i].cpcs = cpcs;
 	    iadev->tx_buf[i].dma_addr = dma_map_single(&iadev->pci->dev,
 						       cpcs,
@@ -2004,10 +1999,8 @@ static int tx_init(struct atm_dev *dev)
 	iadev->desc_tbl = kmalloc_array(iadev->num_tx_desc,
 					sizeof(*iadev->desc_tbl),
 					GFP_KERNEL);
-	if (!iadev->desc_tbl) {
-		printk(KERN_ERR DEV_LABEL " couldn't get mem\n");
+	if (!iadev->desc_tbl)
 		goto err_free_all_tx_bufs;
-	}
   
 	/* Communication Queues base address */  
         i = TX_COMP_Q * iadev->memSize;
@@ -2134,10 +2127,9 @@ static int tx_init(struct atm_dev *dev)
 	iadev->testTable = kmalloc_array(iadev->num_vc,
 					 sizeof(*iadev->testTable),
 					 GFP_KERNEL);
-        if (!iadev->testTable) {
-           printk("Get freepage  failed\n");
-	   goto err_free_desc_tbl;
-        }
+	if (!iadev->testTable)
+		goto err_free_desc_tbl;
+
 	for(i=0; i<iadev->num_vc; i++)  
 	{  
 		memset((caddr_t)vc, 0, sizeof(*vc));  
-- 
2.13.4
