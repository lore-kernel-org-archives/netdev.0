From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 9/9] ixgbe: Drop unnecessary call to rcu_barrier
Date: Fri, 10 Apr 2015 00:53:18 -0700
Message-ID: <1428652398-10147-10-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1428652398-10147-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Alexander Duyck <alexander.h.duyck@redhat.com>,
	netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:9700 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932199AbbDJHxX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 10 Apr 2015 03:53:23 -0400
In-Reply-To: <1428652398-10147-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@redhat.com>

The ixgbe driver hasn't used call_rcu to free the rings for some time now.
Since that is the case the call to rcu_barrier can be dropped since calls
to kfree_rcu don't require it.

Signed-off-by: Alexander Duyck <alexander.h.duyck@redhat.com>
Tested-by: Phil Schmitt <phillip.j.schmitt@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c | 2 --
 1 file changed, 2 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index 0b38be8..a7acb2d 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -9038,8 +9038,6 @@ static void __exit ixgbe_exit_module(void)
 	pci_unregister_driver(&ixgbe_driver);
 
 	ixgbe_dbg_exit();
-
-	rcu_barrier(); /* Wait for completion of call_rcu()'s */
 }
 
 #ifdef CONFIG_IXGBE_DCA
-- 
1.9.3
