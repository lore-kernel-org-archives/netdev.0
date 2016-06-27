From: Amitoj Kaur Chawla <amitoj1606@gmail.com>
Subject: [PATCH] net: ethernet: tundra: Correct argument for
 pci_free_consistent
Date: Mon, 27 Jun 2016 14:34:50 +0530
Message-ID: <20160627090450.GA19412@amitoj-Inspiron-3542>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: julia.lawall@lip6.fr
To: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

pci_free_consistent's argument 'struct pci_dev' should be NULL not 0.

The Coccinelle semantic patch used to make this change is as follows:
@@
@@

pci_free_consistent(
- 0
+ NULL
  , ...)

Signed-off-by: Amitoj Kaur Chawla <amitoj1606@gmail.com>
---
 drivers/net/ethernet/tundra/tsi108_eth.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/tundra/tsi108_eth.c b/drivers/net/ethernet/tundra/tsi108_eth.c
index 520cf50..01a7714 100644
--- a/drivers/net/ethernet/tundra/tsi108_eth.c
+++ b/drivers/net/ethernet/tundra/tsi108_eth.c
@@ -1314,7 +1314,8 @@ static int tsi108_open(struct net_device *dev)
 	data->txring = dma_zalloc_coherent(NULL, txring_size, &data->txdma,
 					   GFP_KERNEL);
 	if (!data->txring) {
-		pci_free_consistent(0, rxring_size, data->rxring, data->rxdma);
+		pci_free_consistent(NULL, rxring_size, data->rxring,
+				    data->rxdma);
 		return -ENOMEM;
 	}
 
-- 
1.9.1
