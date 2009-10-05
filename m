From: Thomas Chou <thomas@wytron.com.tw>
Subject: [PATCH 1/4] ethoc: fix typo to compute number of tx descriptors
Date: Mon,  5 Oct 2009 17:33:17 +0800
Message-ID: <1254735200-2718-1-git-send-email-thomas@wytron.com.tw>
Cc: netdev@vger.kernel.org, Thomas Chou <thomas@wytron.com.tw>
To: unlisted-recipients:; (no To-header on input)
Return-path: <netdev-owner@vger.kernel.org>
Received: from msr33.hinet.net ([168.95.4.133]:57909 "EHLO msr33.hinet.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758315AbZJEKCA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 5 Oct 2009 06:02:00 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

It should be max() instead of min(). Use 1/4 of available
descriptors for tx, and there should be at least 2 tx
descriptors.

Signed-off-by: Thomas Chou <thomas@wytron.com.tw>
---
 drivers/net/ethoc.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethoc.c b/drivers/net/ethoc.c
index b7311bc..7475620 100644
--- a/drivers/net/ethoc.c
+++ b/drivers/net/ethoc.c
@@ -655,7 +655,7 @@ static int ethoc_open(struct net_device *dev)
 
 	/* calculate the number of TX/RX buffers */
 	num_bd = (dev->mem_end - dev->mem_start + 1) / ETHOC_BUFSIZ;
-	priv->num_tx = min(min_tx, num_bd / 4);
+	priv->num_tx = max(min_tx, num_bd / 4);
 	priv->num_rx = num_bd - priv->num_tx;
 	ethoc_write(priv, TX_BD_NUM, priv->num_tx);
 
-- 
1.6.2.5

