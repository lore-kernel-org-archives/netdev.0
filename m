From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-2.6 PATCH 1/2] ixgbe: Fix ixgbe_tx_map error path
Date: Wed, 03 Feb 2010 15:12:51 -0800
Message-ID: <20100203231224.15352.27988.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Anton Blanchard <anton@samba.org>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta14.emeryville.ca.mail.comcast.net ([76.96.27.212]:57324
	"EHLO qmta14.emeryville.ca.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755606Ab0BCXNJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Feb 2010 18:13:09 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Anton Blanchard <anton@samba.org>

Commit e5a43549f7a58509a91b299a51337d386697b92c (ixgbe: remove
skb_dma_map/unmap calls from driver) looks to have introduced a bug in
ixgbe_tx_map. If we get an error from a PCI DMA call, we loop backwards
through count until it becomes -1 and return that.

The caller of ixgbe_tx_map expects 0 on error, so return that instead.

Signed-off-by: Anton Blanchard <anton@samba.org>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/ixgbe/ixgbe_main.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
index b5f64ad..37e2af0 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -5179,7 +5179,7 @@ dma_error:
 		ixgbe_unmap_and_free_tx_resource(adapter, tx_buffer_info);
 	}
 
-	return count;
+	return 0;
 }
 
 static void ixgbe_tx_queue(struct ixgbe_adapter *adapter,

