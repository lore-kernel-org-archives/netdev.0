From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next v2 04/15] igb: don't allow SR-IOV without MSI-X
Date: Thu, 22 Aug 2013 02:49:40 -0700
Message-ID: <1377164991-27988-5-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1377164991-27988-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Mitch A Williams <mitch.a.williams@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:54375 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752807Ab3HVJt5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 22 Aug 2013 05:49:57 -0400
In-Reply-To: <1377164991-27988-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mitch A Williams <mitch.a.williams@intel.com>

MSI-X interrupts are required for SR-IOV operation. Check to make sure
they're enabled before allowing the user to turn on VFs.

Signed-off-by: Mitch Williams <mitch.a.williams@intel.com>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/igb/igb_main.c | 5 +++++
 1 file changed, 5 insertions(+)

diff --git a/drivers/net/ethernet/intel/igb/igb_main.c b/drivers/net/ethernet/intel/igb/igb_main.c
index 8e7c1b8..94295a0 100644
--- a/drivers/net/ethernet/intel/igb/igb_main.c
+++ b/drivers/net/ethernet/intel/igb/igb_main.c
@@ -2436,6 +2436,11 @@ static int igb_enable_sriov(struct pci_dev *pdev, int num_vfs)
 	int err = 0;
 	int i;
 
+	if (!adapter->msix_entries) {
+		err = -EPERM;
+		goto out;
+	}
+
 	if (!num_vfs)
 		goto out;
 	else if (old_vfs && old_vfs == num_vfs)
-- 
1.8.3.1
