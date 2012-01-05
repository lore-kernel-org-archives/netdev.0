From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 2/8] e1000: unmap ce4100_gbe_mdio_base_virt in e1000_remove
Date: Wed,  4 Jan 2012 22:23:34 -0800
Message-ID: <1325744620-5067-3-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1325744620-5067-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Florian Fainelli <ffainelli@freebox.fr>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:21235 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751686Ab2AEGXp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 5 Jan 2012 01:23:45 -0500
In-Reply-To: <1325744620-5067-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Fainelli <ffainelli@freebox.fr>

We are not unmapping ce4100_gbe_mdio_base_virt in exit path in case
we are running on a CE4100 adapter, fix that.

Signed-off-by: Florian Fainelli <ffainelli@freebox.fr>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/e1000/e1000_main.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/intel/e1000/e1000_main.c b/drivers/net/ethernet/intel/e1000/e1000_main.c
index 934d5aa..9cf07f6 100644
--- a/drivers/net/ethernet/intel/e1000/e1000_main.c
+++ b/drivers/net/ethernet/intel/e1000/e1000_main.c
@@ -1286,6 +1286,8 @@ static void __devexit e1000_remove(struct pci_dev *pdev)
 	kfree(adapter->tx_ring);
 	kfree(adapter->rx_ring);
 
+	if (hw->mac_type == e1000_ce4100)
+		iounmap(ce4100_gbe_mdio_base_virt);
 	iounmap(hw->hw_addr);
 	if (hw->flash_address)
 		iounmap(hw->flash_address);
-- 
1.7.7.5
