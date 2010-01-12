From: Anton Blanchard <anton@samba.org>
Subject: [PATCH] ixgbe: Fix ixgbe_tx_map error path
Date: Tue, 12 Jan 2010 22:01:35 +1100
Message-ID: <20100112110135.GK12666@kryten>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Bruce Allan <bruce.w.allan@intel.com>,
	PJ Waskiewicz <peter.p.waskiewicz.jr@intel.com>,
	Joh
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([203.10.76.45]:56436 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754033Ab0ALLET (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 12 Jan 2010 06:04:19 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Commit e5a43549f7a58509a91b299a51337d386697b92c (ixgbe: remove
skb_dma_map/unmap calls from driver) looks to have introduced a bug in
ixgbe_tx_map. If we get an error from a PCI DMA call, we loop backwards
through count until it becomes -1 and return that.

The caller of ixgbe_tx_map expects 0 on error, so return that instead.

---

diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
index 1a2ea62..af660ba 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -5174,7 +5174,7 @@ dma_error:
 		ixgbe_unmap_and_free_tx_resource(adapter, tx_buffer_info);
 	}
 
-	return count;
+	return 0;
 }
 
 static void ixgbe_tx_queue(struct ixgbe_adapter *adapter,
