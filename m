From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 09/10] e1000e: restore call to pci_clear_master()
Date: Wed, 26 Jun 2013 03:55:21 -0700
Message-ID: <1372244122-17664-10-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1372244122-17664-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Dean Nelson <dnelson@redhat.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:33178 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751824Ab3FZKza (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 26 Jun 2013 06:55:30 -0400
In-Reply-To: <1372244122-17664-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dean Nelson <dnelson@redhat.com>

In attempting to resolve a minor merge conflict, commit e5f2ef7ab4690d2e8faa
(Merge git://git.kernel.org/pub/scm/linux/kernel/git/davem/net) accidently
dropped a call to pci_clear_master() that was intended to remain in place.

Commit 4e0855dff094b0d56d6b (e1000e: fix pci-device enable-counter balance)
replaced a call to pci_disable_device() by one to pci_clear_master(). And then
commit 66148babe728f3e00e13 (e1000e: fix runtime power management transitions)
deleted a number of lines starting two lines following that call.

This patch restores the call to pci_clear_master() in __e1000_shutdown().

v2: added summary lines (enclosed in parens) following commit IDs

Signed-off-by: Dean Nelson <dnelson@redhat.com>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Acked-by: Bruce Allan <bruce.w.allan@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/e1000e/netdev.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/drivers/net/ethernet/intel/e1000e/netdev.c b/drivers/net/ethernet/intel/e1000e/netdev.c
index 77f81cb..5475cf4 100644
--- a/drivers/net/ethernet/intel/e1000e/netdev.c
+++ b/drivers/net/ethernet/intel/e1000e/netdev.c
@@ -5995,6 +5995,8 @@ static int __e1000_shutdown(struct pci_dev *pdev, bool runtime)
 	 */
 	e1000e_release_hw_control(adapter);
 
+	pci_clear_master(pdev);
+
 	/* The pci-e switch on some quad port adapters will report a
 	 * correctable error when the MAC transitions from D0 to D3.  To
 	 * prevent this we need to mask off the correctable errors on the
-- 
1.7.11.7
