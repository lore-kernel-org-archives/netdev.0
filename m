From: Luiz Fernando Capitulino <lcapitulino@mandriva.com.br>
Subject: [PATCH] Fix sparse warning in e100 driver.
Date: Mon, 7 Nov 2005 18:14:12 -0200
Message-ID: <20051107181412.084467d6.lcapitulino__7701.89832333035$1131394878$gmane$org@mandriva.com.br>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux.nics@intel.com, linux-kernel@vger.kernel.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: akpm@osdl.org
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi,

The patch below fixes the following sparse warnings:

drivers/net/e100.c:1481:13: warning: Using plain integer as NULL pointer
drivers/net/e100.c:1481:13: warning: Using plain integer as NULL pointer
drivers/net/e100.c:1767:27: warning: Using plain integer as NULL pointer
drivers/net/e100.c:1847:27: warning: Using plain integer as NULL pointer

Signed-off-by: Luiz Capitulino <lcapitulino@mandriva.com.br>

 drivers/net/e100.c |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/e100.c b/drivers/net/e100.c
--- a/drivers/net/e100.c
+++ b/drivers/net/e100.c
@@ -1478,7 +1478,7 @@ static inline int e100_rx_alloc_skb(stru
 
 	if(pci_dma_mapping_error(rx->dma_addr)) {
 		dev_kfree_skb_any(rx->skb);
-		rx->skb = 0;
+		rx->skb = NULL;
 		rx->dma_addr = 0;
 		return -ENOMEM;
 	}
@@ -1764,7 +1764,7 @@ static int e100_up(struct nic *nic)
 	if((err = e100_hw_init(nic)))
 		goto err_clean_cbs;
 	e100_set_multicast_list(nic->netdev);
-	e100_start_receiver(nic, 0);
+	e100_start_receiver(nic, NULL);
 	mod_timer(&nic->watchdog, jiffies);
 	if((err = request_irq(nic->pdev->irq, e100_intr, SA_SHIRQ,
 		nic->netdev->name, nic->netdev)))
@@ -1844,7 +1844,7 @@ static int e100_loopback_test(struct nic
 		mdio_write(nic->netdev, nic->mii.phy_id, MII_BMCR,
 			BMCR_LOOPBACK);
 
-	e100_start_receiver(nic, 0);
+	e100_start_receiver(nic, NULL);
 
 	if(!(skb = dev_alloc_skb(ETH_DATA_LEN))) {
 		err = -ENOMEM;


-- 
Luiz Fernando N. Capitulino
