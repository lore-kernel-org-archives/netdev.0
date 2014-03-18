From: Peter Senna Tschudin <peter.senna@gmail.com>
Subject: [PATCH 1/2] ATHEROS-ATL1E: Convert iounmap to pci_iounmap
Date: Tue, 18 Mar 2014 17:11:24 +0100
Message-ID: <1395159085-11691-1-git-send-email-peter.senna@gmail.com>
Cc: Peter Senna Tschudin <peter.senna@gmail.com>
To: jcliburn@gmail.com, chris.snook@gmail.com, davem@davemloft.net,
	hannes@stressinduktion.org, nhorman@tuxdriver.com, kaber@trash.net,
	sd@queasysnail.net, PeterHuewe@gmx.de, andrea.merello@gmail.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	kernel-janitors@vger.kernel.org
Return-path: <kernel-janitors-owner@vger.kernel.org>
Sender: kernel-janitors-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Use pci_iounmap instead of iounmap when the virtual mapping was done
with pci_iomap. A simplified version of the semantic patch that finds this
issue is as follows: (http://coccinelle.lip6.fr/)
    
// <smpl>
@r@
expression addr;
@@
addr = pci_iomap(...)

@rr@
expression r.addr;
@@
* iounmap(addr)
// </smpl>

Signed-off-by: Peter Senna Tschudin <peter.senna@gmail.com>
---
 Tested by compilation only.

 drivers/net/ethernet/atheros/atl1e/atl1e_main.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/atheros/atl1e/atl1e_main.c b/drivers/net/ethernet/atheros/atl1e/atl1e_main.c
index d5c2d3e..422aab2 100644
--- a/drivers/net/ethernet/atheros/atl1e/atl1e_main.c
+++ b/drivers/net/ethernet/atheros/atl1e/atl1e_main.c
@@ -2436,7 +2436,7 @@ err_reset:
 err_register:
 err_sw_init:
 err_eeprom:
-	iounmap(adapter->hw.hw_addr);
+	pci_iounmap(pdev, adapter->hw.hw_addr);
 err_init_netdev:
 err_ioremap:
 	free_netdev(netdev);
@@ -2474,7 +2474,7 @@ static void atl1e_remove(struct pci_dev *pdev)
 	unregister_netdev(netdev);
 	atl1e_free_ring_resources(adapter);
 	atl1e_force_ps(&adapter->hw);
-	iounmap(adapter->hw.hw_addr);
+	pci_iounmap(pdev, adapter->hw.hw_addr);
 	pci_release_regions(pdev);
 	free_netdev(netdev);
 	pci_disable_device(pdev);
-- 
1.8.3.1

