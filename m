From: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
Subject: [PATCH 4/9 V2] mlx4_en: Verify number of RX rings doesn't exceed
 MAX_RX_RINGS
Date: Mon, 29 Dec 2008 11:56:47 +0200
Message-ID: <49589EDF.9040803@mellanox.co.il>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: jeff@garzik.org, rdreier@cisco.com, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.mellanox.co.il ([194.90.237.43]:58518 "EHLO mellanox.co.il"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753803AbYL2J6B (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 29 Dec 2008 04:58:01 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Required in cases were dev->caps.num_comp_vectors > MAX_RX_RINGS.
For current values this would happen on machines that have more
then 16 cores.

Signed-off-by: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
---
 drivers/net/mlx4/en_main.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/drivers/net/mlx4/en_main.c b/drivers/net/mlx4/en_main.c
index c1c0585..34f3a19 100644
--- a/drivers/net/mlx4/en_main.c
+++ b/drivers/net/mlx4/en_main.c
@@ -170,7 +170,8 @@ static void *mlx4_en_add(struct mlx4_dev *dev)
 		mlx4_info(mdev, "Using %d tx rings for port:%d\n",
 			  mdev->profile.prof[i].tx_ring_num, i);
 		if (!mdev->profile.prof[i].rx_ring_num) {
-			mdev->profile.prof[i].rx_ring_num = dev->caps.num_comp_vectors;
+			mdev->profile.prof[i].rx_ring_num =
+				min_t(int, dev->caps.num_comp_vectors, MAX_RX_RINGS);
 			mlx4_info(mdev, "Defaulting to %d rx rings for port:%d\n",
 				  mdev->profile.prof[i].rx_ring_num, i);
 		} else
-- 
1.5.4

