From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 13/15] e1000e: Fix incorrect ASPM locking
Date: Wed,  5 Aug 2015 16:52:13 -0700
Message-ID: <1438818735-38115-14-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1438818735-38115-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Raanan Avargil <raanan.avargil@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([192.55.52.115]:11984 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753103AbbHEXwX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 5 Aug 2015 19:52:23 -0400
In-Reply-To: <1438818735-38115-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Raanan Avargil <raanan.avargil@intel.com>

This patch fixes wrong locking usage.
In the context of slot reset, we should use lock.
And during resume, there is no need of lock.

Reported-by: Bjorn Helgaas <bhelgaas@google.com>
Signed-off-by: Raanan Avargil <raanan.avargil@intel.com>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/e1000e/netdev.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/intel/e1000e/netdev.c b/drivers/net/ethernet/intel/e1000e/netdev.c
index b32bc48..24b7269 100644
--- a/drivers/net/ethernet/intel/e1000e/netdev.c
+++ b/drivers/net/ethernet/intel/e1000e/netdev.c
@@ -6493,7 +6493,7 @@ static int __e1000_resume(struct pci_dev *pdev)
 	if (adapter->flags2 & FLAG2_DISABLE_ASPM_L1)
 		aspm_disable_flag |= PCIE_LINK_STATE_L1;
 	if (aspm_disable_flag)
-		e1000e_disable_aspm_locked(pdev, aspm_disable_flag);
+		e1000e_disable_aspm(pdev, aspm_disable_flag);
 
 	pci_set_master(pdev);
 
@@ -6771,7 +6771,7 @@ static pci_ers_result_t e1000_io_slot_reset(struct pci_dev *pdev)
 	if (adapter->flags2 & FLAG2_DISABLE_ASPM_L1)
 		aspm_disable_flag |= PCIE_LINK_STATE_L1;
 	if (aspm_disable_flag)
-		e1000e_disable_aspm(pdev, aspm_disable_flag);
+		e1000e_disable_aspm_locked(pdev, aspm_disable_flag);
 
 	err = pci_enable_device_mem(pdev);
 	if (err) {
-- 
2.4.3
