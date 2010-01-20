From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-2.6 PATCH] e1000/e1000e/igb/igbvf/ixgb/ixgbe: Fix tests of
	unsigned in *_tx_map()
Date: Tue, 19 Jan 2010 16:21:45 -0800
Message-ID: <20100120002126.25572.29661.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Roel Kluin <roel.kluin@gmail.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta13.emeryville.ca.mail.comcast.net ([76.96.27.243]:60710
	"EHLO qmta13.emeryville.ca.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751460Ab0ATAWN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Jan 2010 19:22:13 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roel Kluin <roel.kluin@gmail.com>

The variable count and i are unsigned so the (<|>=)0 tests do not work.

Signed-off-by: Roel Kluin <roel.kluin@gmail.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/e1000/e1000_main.c |   10 +++++-----
 drivers/net/e1000e/netdev.c    |   10 +++++-----
 drivers/net/igbvf/netdev.c     |   10 +++++-----
 drivers/net/ixgb/ixgb_main.c   |   10 +++++-----
 drivers/net/ixgbe/ixgbe_main.c |   10 +++++-----
 5 files changed, 25 insertions(+), 25 deletions(-)

diff --git a/drivers/net/e1000/e1000_main.c b/drivers/net/e1000/e1000_main.c
index 9bc9fcd..a53a201 100644
--- a/drivers/net/e1000/e1000_main.c
+++ b/drivers/net/e1000/e1000_main.c
@@ -2802,13 +2802,13 @@ static int e1000_tx_map(struct e1000_adapter *adapter,
 dma_error:
 	dev_err(&pdev->dev, "TX DMA map failed\n");
 	buffer_info->dma = 0;
-	count--;
-
-	while (count >= 0) {
+	if (count)
 		count--;
-		i--;
-		if (i < 0)
+
+	while (count--) {
+		if (i==0)
 			i += tx_ring->count;
+		i--;
 		buffer_info = &tx_ring->buffer_info[i];
 		e1000_unmap_and_free_tx_resource(adapter, buffer_info);
 	}
diff --git a/drivers/net/e1000e/netdev.c b/drivers/net/e1000e/netdev.c
index da5838e..1ea395b 100644
--- a/drivers/net/e1000e/netdev.c
+++ b/drivers/net/e1000e/netdev.c
@@ -3979,13 +3979,13 @@ static int e1000_tx_map(struct e1000_adapter *adapter,
 dma_error:
 	dev_err(&pdev->dev, "TX DMA map failed\n");
 	buffer_info->dma = 0;
-	count--;
-
-	while (count >= 0) {
+	if (count)
 		count--;
-		i--;
-		if (i < 0)
+
+	while (count--) {
+		if (i==0)
 			i += tx_ring->count;
+		i--;
 		buffer_info = &tx_ring->buffer_info[i];
 		e1000_put_txbuf(adapter, buffer_info);;
 	}
diff --git a/drivers/net/igbvf/netdev.c b/drivers/net/igbvf/netdev.c
index 0dbd032..10e038a 100644
--- a/drivers/net/igbvf/netdev.c
+++ b/drivers/net/igbvf/netdev.c
@@ -2163,14 +2163,14 @@ dma_error:
 	buffer_info->length = 0;
 	buffer_info->next_to_watch = 0;
 	buffer_info->mapped_as_page = false;
-	count--;
+	if (count)
+		count--;
 
 	/* clear timestamp and dma mappings for remaining portion of packet */
-	while (count >= 0) {
-		count--;
-		i--;
-		if (i < 0)
+	while (count--) {
+		if (i==0)
 			i += tx_ring->count;
+		i--;
 		buffer_info = &tx_ring->buffer_info[i];
 		igbvf_put_txbuf(adapter, buffer_info);
 	}
diff --git a/drivers/net/ixgb/ixgb_main.c b/drivers/net/ixgb/ixgb_main.c
index bcd0f01..593d1a4 100644
--- a/drivers/net/ixgb/ixgb_main.c
+++ b/drivers/net/ixgb/ixgb_main.c
@@ -1363,13 +1363,13 @@ ixgb_tx_map(struct ixgb_adapter *adapter, struct sk_buff *skb,
 dma_error:
 	dev_err(&pdev->dev, "TX DMA map failed\n");
 	buffer_info->dma = 0;
-	count--;
-
-	while (count >= 0) {
+	if (count)
 		count--;
-		i--;
-		if (i < 0)
+
+	while (count--) {
+		if (i==0)
 			i += tx_ring->count;
+		i--;
 		buffer_info = &tx_ring->buffer_info[i];
 		ixgb_unmap_and_free_tx_resource(adapter, buffer_info);
 	}
diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
index 9c9202f..6d61add 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -5167,14 +5167,14 @@ dma_error:
 	tx_buffer_info->dma = 0;
 	tx_buffer_info->time_stamp = 0;
 	tx_buffer_info->next_to_watch = 0;
-	count--;
+	if (count)
+		count--;
 
 	/* clear timestamp and dma mappings for remaining portion of packet */
-	while (count >= 0) {
-		count--;
-		i--;
-		if (i < 0)
+	while (count--) {
+		if (i==0)
 			i += tx_ring->count;
+		i--;
 		tx_buffer_info = &tx_ring->tx_buffer_info[i];
 		ixgbe_unmap_and_free_tx_resource(adapter, tx_buffer_info);
 	}

