From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net 1/2] ixgbe: add missing rtnl_lock in PM resume path
Date: Tue, 17 Apr 2012 15:48:04 -0700
Message-ID: <1334702885-4411-2-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1334702885-4411-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Benjamin Poirier <bpoirier@suse.de>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:60035 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751489Ab2DQWsJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 17 Apr 2012 18:48:09 -0400
In-Reply-To: <1334702885-4411-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Benjamin Poirier <bpoirier@suse.de>

Upon resume from standby, ixgbe may trigger the ASSERT_RTNL() in
netif_set_real_num_tx_queues(). The call stack is:
	netif_set_real_num_tx_queues
	ixgbe_set_num_queues
	ixgbe_init_interrupt_scheme
	ixgbe_resume

Signed-off-by: Benjamin Poirier <bpoirier@suse.de>
Tested-by: Stephen Ko <stephen.s.ko@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index dac7c01..9e2be8c 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -4836,7 +4836,9 @@ static int ixgbe_resume(struct pci_dev *pdev)
 
 	pci_wake_from_d3(pdev, false);
 
+	rtnl_lock();
 	err = ixgbe_init_interrupt_scheme(adapter);
+	rtnl_unlock();
 	if (err) {
 		e_dev_err("Cannot initialize interrupts for device\n");
 		return err;
-- 
1.7.7.6
