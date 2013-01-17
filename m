From: Nickolai Zeldovich <nickolai@csail.mit.edu>
Subject: [PATCH] 3c574_cs: fix operator precedence between << and &
Date: Thu, 17 Jan 2013 12:18:29 -0500
Message-ID: <1358443109-63402-1-git-send-email-nickolai@csail.mit.edu>
Cc: Nickolai Zeldovich <nickolai@csail.mit.edu>,
	linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The code to print the FIFO size in tc574_config computes it as:

  8 << config & Ram_size

which evaluates the '<<' first, but the actual intent is to evaluate the
'&' first.  Add parentheses to enforce desired evaluation order.

Signed-off-by: Nickolai Zeldovich <nickolai@csail.mit.edu>
---
 drivers/net/ethernet/3com/3c574_cs.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/3com/3c574_cs.c b/drivers/net/ethernet/3com/3c574_cs.c
index 66df936..ffd8de2 100644
--- a/drivers/net/ethernet/3com/3c574_cs.c
+++ b/drivers/net/ethernet/3com/3c574_cs.c
@@ -432,7 +432,7 @@ static int tc574_config(struct pcmcia_device *link)
 	netdev_info(dev, "%s at io %#3lx, irq %d, hw_addr %pM\n",
 		    cardname, dev->base_addr, dev->irq, dev->dev_addr);
 	netdev_info(dev, " %dK FIFO split %s Rx:Tx, %sMII interface.\n",
-		    8 << config & Ram_size,
+		    8 << (config & Ram_size),
 		    ram_split[(config & Ram_split) >> Ram_split_shift],
 		    config & Autoselect ? "autoselect " : "");
 
-- 
1.7.10.4
