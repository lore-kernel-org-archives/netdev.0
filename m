From: Tom Herbert <therbert@google.com>
Subject: [PATCH 2/2] mlx4: Call alloc_etherdev to allocate RX and TX queues
Date: Sun, 9 Jan 2011 21:36:36 -0800 (PST)
Message-ID: <alpine.DEB.2.00.1101092123370.3126@pokey.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([74.125.121.67]:58791 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751011Ab1AJFgl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Jan 2011 00:36:41 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Changed driver to call alloc_etherdev_mqs so that the number of TX
and RX queues can be set to correct values in the netdev device.

Signed-off-by: Tom Herbert <therbert@google.com>
---
 drivers/net/mlx4/en_netdev.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/drivers/net/mlx4/en_netdev.c b/drivers/net/mlx4/en_netdev.c
index 6d6806b..897f576 100644
--- a/drivers/net/mlx4/en_netdev.c
+++ b/drivers/net/mlx4/en_netdev.c
@@ -972,7 +972,8 @@ int mlx4_en_init_netdev(struct mlx4_en_dev *mdev, int port,
 	int i;
 	int err;
 
-	dev = alloc_etherdev_mq(sizeof(struct mlx4_en_priv), prof->tx_ring_num);
+	dev = alloc_etherdev_mqs(sizeof(struct mlx4_en_priv),
+	    prof->tx_ring_num, prof->rx_ring_num);
 	if (dev == NULL) {
 		mlx4_err(mdev, "Net device allocation failed\n");
 		return -ENOMEM;
-- 
1.7.3.1

