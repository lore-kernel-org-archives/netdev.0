From: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
Subject: [PATCH 2/4] net/mlx4_en: loopbacked packets are dropped when SMAC=DMAC
Date: Thu,  2 Aug 2012 18:30:54 +0300
Message-ID: <1343921456-19180-3-git-send-email-yevgenyp@mellanox.co.il>
References: <1343921456-19180-1-git-send-email-yevgenyp@mellanox.co.il>
Cc: netdev@vger.kernel.org, Amir Vadai <amirv@mellanox.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog103.obsmtp.com ([207.126.144.115]:35419 "HELO
	eu1sys200aog103.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1752447Ab2HBPbH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Aug 2012 11:31:07 -0400
In-Reply-To: <1343921456-19180-1-git-send-email-yevgenyp@mellanox.co.il>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Amir Vadai <amirv@mellanox.com>

Should NOT check SMAC=DMAC when:
1. loopback is turned on
2. validate_loopback is true.

Fixed it accordingly.

Signed-off-by: Amir Vadai <amirv@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx4/en_rx.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/en_rx.c b/drivers/net/ethernet/mellanox/mlx4/en_rx.c
index f32e703..5aba5ec 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_rx.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_rx.c
@@ -614,8 +614,8 @@ int mlx4_en_process_rx_cq(struct net_device *dev, struct mlx4_en_cq *cq, int bud
 		/* If source MAC is equal to our own MAC and not performing
 		 * the selftest or flb disabled - drop the packet */
 		if (s_mac == priv->mac &&
-			(!(dev->features & NETIF_F_LOOPBACK) ||
-			 !priv->validate_loopback))
+		    !((dev->features & NETIF_F_LOOPBACK) ||
+		      priv->validate_loopback))
 			goto next;
 
 		/*
-- 
1.7.7
