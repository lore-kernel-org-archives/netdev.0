From: Asbjoern Sloth Toennesen <asbjorn@asbjorn.biz>
Subject: [PATCH 6/7] e1000e: cleanup: swap arguments to avoid checkpatch errors
Date: Thu,  9 Dec 2010 02:40:56 +0000
Message-ID: <1291862457-16671-7-git-send-email-asbjorn__6403.35979774154$1291863040$gmane$org@asbjorn.biz>
References: <1291862457-16671-1-git-send-email-asbjorn@asbjorn.biz>
Cc: e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.asbjorn.biz ([217.195.185.3]:55185 "EHLO mail.asbjorn.biz"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756826Ab0LICu1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 8 Dec 2010 21:50:27 -0500
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
In-Reply-To: <1291862457-16671-1-git-send-email-asbjorn@asbjorn.biz>
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Swap argument order in order to avoid checkpatch treating it as an
unary operation, instead of an binary one, and obtain consistency
with the 3 other similar assignments in netdev.c (tdlen & rdlen).

This patch fixes 3 checkpatch errors.

Signed-off-by: Asbjoern Sloth Toennesen <asbjorn@asbjorn.biz>
---
 drivers/net/e1000e/netdev.c |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/e1000e/netdev.c b/drivers/net/e1000e/netdev.c
index bb6a1f5..bdd3774 100644
--- a/drivers/net/e1000e/netdev.c
+++ b/drivers/net/e1000e/netdev.c
@@ -2059,7 +2059,7 @@ int e1000e_setup_tx_resources(struct e1000_adapter *adapter)
 	struct e1000_ring *tx_ring = adapter->tx_ring;
 	int err = -ENOMEM, size;
 
-	size = sizeof(struct e1000_buffer) * tx_ring->count;
+	size = tx_ring->count * sizeof(struct e1000_buffer);
 	tx_ring->buffer_info = vzalloc(size);
 	if (!tx_ring->buffer_info)
 		goto err;
@@ -2094,7 +2094,7 @@ int e1000e_setup_rx_resources(struct e1000_adapter *adapter)
 	struct e1000_buffer *buffer_info;
 	int i, size, desc_len, err = -ENOMEM;
 
-	size = sizeof(struct e1000_buffer) * rx_ring->count;
+	size = rx_ring->count * sizeof(struct e1000_buffer);
 	rx_ring->buffer_info = vzalloc(size);
 	if (!rx_ring->buffer_info)
 		goto err;
@@ -2151,7 +2151,7 @@ static void e1000_clean_tx_ring(struct e1000_adapter *adapter)
 		e1000_put_txbuf(adapter, buffer_info);
 	}
 
-	size = sizeof(struct e1000_buffer) * tx_ring->count;
+	size = tx_ring->count * sizeof(struct e1000_buffer);
 	memset(tx_ring->buffer_info, 0, size);
 
 	memset(tx_ring->desc, 0, tx_ring->size);
-- 
1.7.2.3

