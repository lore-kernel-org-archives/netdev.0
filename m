From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 11/13] INTEL-IGB: Convert iounmap to pci_iounmap
Date: Mon, 31 Mar 2014 16:34:57 -0700
Message-ID: <1396308899-20926-12-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1396308899-20926-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Peter Senna Tschudin <peter.senna@gmail.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:6652 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751729AbaCaXga (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 31 Mar 2014 19:36:30 -0400
In-Reply-To: <1396308899-20926-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Peter Senna Tschudin <peter.senna@gmail.com>

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
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/igb/igb_main.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/intel/igb/igb_main.c b/drivers/net/ethernet/intel/igb/igb_main.c
index 55fc559..3019818 100644
--- a/drivers/net/ethernet/intel/igb/igb_main.c
+++ b/drivers/net/ethernet/intel/igb/igb_main.c
@@ -2652,7 +2652,7 @@ err_eeprom:
 		iounmap(hw->flash_address);
 err_sw_init:
 	igb_clear_interrupt_scheme(adapter);
-	iounmap(hw->hw_addr);
+	pci_iounmap(pdev, hw->hw_addr);
 err_ioremap:
 	free_netdev(netdev);
 err_alloc_etherdev:
@@ -2819,7 +2819,7 @@ static void igb_remove(struct pci_dev *pdev)
 	igb_disable_sriov(pdev);
 #endif
 
-	iounmap(hw->hw_addr);
+	pci_iounmap(pdev, hw->hw_addr);
 	if (hw->flash_address)
 		iounmap(hw->flash_address);
 	pci_release_selected_regions(pdev,
-- 
1.9.0
