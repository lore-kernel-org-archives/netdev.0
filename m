From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [PATCH 2/8] igb: fix null pointer dereference seen with fiber NICs
Date: Fri, 01 Aug 2008 16:11:15 -0700
Message-ID: <20080801231115.393.275.stgit@localhost.localdomain>
References: <20080801231106.393.46174.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	akpm@linux-foundation.org,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:54771 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751813AbYHAXLQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 1 Aug 2008 19:11:16 -0400
In-Reply-To: <20080801231106.393.46174.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

With a fiber or serdes NIC installed the driver was causing a null pointer
dereference on driver unload.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/igb/igb_main.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/drivers/net/igb/igb_main.c b/drivers/net/igb/igb_main.c
index f23a048..cfed2b0 100644
--- a/drivers/net/igb/igb_main.c
+++ b/drivers/net/igb/igb_main.c
@@ -1372,7 +1372,8 @@ static void __devexit igb_remove(struct pci_dev *pdev)
 
 	unregister_netdev(netdev);
 
-	if (!igb_check_reset_block(&adapter->hw))
+	if (adapter->hw.phy.ops.reset_phy &&
+	    !igb_check_reset_block(&adapter->hw))
 		adapter->hw.phy.ops.reset_phy(&adapter->hw);
 
 	igb_remove_device(&adapter->hw);

