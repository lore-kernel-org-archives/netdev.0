From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net 1/3] e1000e: fix pci-device enable-counter balance
Date: Thu,  7 Mar 2013 03:15:23 -0800
Message-ID: <1362654925-26088-2-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1362654925-26088-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Konstantin Khlebnikov <khlebnikov@openvz.org>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Bruce Allan <bruce.w.allan@intel.com>,
	Stable <stable@kernel.org>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:5166 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756218Ab3CGLPh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 7 Mar 2013 06:15:37 -0500
In-Reply-To: <1362654925-26088-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Konstantin Khlebnikov <khlebnikov@openvz.org>

This patch removes redundant and unbalanced pci_disable_device() from
__e1000_shutdown(). pci_clear_master() is enough, device can go into
suspended state with elevated enable_cnt.

Bug was introduced in commit 23606cf5d1192c2b17912cb2ef6e62f9b11de133
("e1000e / PCI / PM: Add basic runtime PM support (rev. 4)") in v2.6.35

Cc: Bruce Allan <bruce.w.allan@intel.com>
CC: Stable <stable@kernel.org>
Signed-off-by: Konstantin Khlebnikov <khlebnikov@openvz.org>
Acked-by: Rafael J. Wysocki <rafael.j.wysocki@intel.com>
Tested-by: Borislav Petkov <bp@suse.de>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/e1000e/netdev.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/e1000e/netdev.c b/drivers/net/ethernet/intel/e1000e/netdev.c
index a177b8b..1799021 100644
--- a/drivers/net/ethernet/intel/e1000e/netdev.c
+++ b/drivers/net/ethernet/intel/e1000e/netdev.c
@@ -5986,7 +5986,7 @@ static int __e1000_shutdown(struct pci_dev *pdev, bool *enable_wake,
 	 */
 	e1000e_release_hw_control(adapter);
 
-	pci_disable_device(pdev);
+	pci_clear_master(pdev);
 
 	return 0;
 }
-- 
1.7.11.7
