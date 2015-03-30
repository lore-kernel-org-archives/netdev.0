From: Alexander Duyck <alexander.h.duyck@redhat.com>
Subject: [net-next PATCH] ixgbe: Drop unnecessary call to rcu_barrier
Date: Mon, 30 Mar 2015 09:41:38 -0700
Message-ID: <20150330164138.1335.47547.stgit@ahduyck-vm-fedora22>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: jeffrey.t.kirsher@intel.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:51037 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752828AbbC3Qlk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 30 Mar 2015 12:41:40 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The ixgbe driver hasn't used call_rcu to free the rings for some time now.
Since that is the case the call to rcu_barrier can be dropped since calls
to kfree_rcu don't require it.

Signed-off-by: Alexander Duyck <alexander.h.duyck@redhat.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c |    2 --
 1 file changed, 2 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index 395dc6bb5d82..d628c0173e29 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -8977,8 +8977,6 @@ static void __exit ixgbe_exit_module(void)
 	pci_unregister_driver(&ixgbe_driver);
 
 	ixgbe_dbg_exit();
-
-	rcu_barrier(); /* Wait for completion of call_rcu()'s */
 }
 
 #ifdef CONFIG_IXGBE_DCA
