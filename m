From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 08/10] igb: don't allow SR-IOV without MSI-X
Date: Wed, 26 Jun 2013 03:55:20 -0700
Message-ID: <1372244122-17664-9-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1372244122-17664-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Mitch A Williams <mitch.a.williams@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:61757 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751977Ab3FZKz3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 26 Jun 2013 06:55:29 -0400
In-Reply-To: <1372244122-17664-1-git-send-email-jeffrey.t.kirsher@intel.com>
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
index c74ad78..35d31c6 100644
--- a/drivers/net/ethernet/intel/igb/igb_main.c
+++ b/drivers/net/ethernet/intel/igb/igb_main.c
@@ -2438,6 +2438,11 @@ static int igb_enable_sriov(struct pci_dev *pdev, int num_vfs)
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
1.7.11.7
