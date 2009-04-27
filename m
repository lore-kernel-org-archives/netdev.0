From: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
Subject: [PATCH 1/2] mlx4_en: Fix cleanup flow on cq activation
Date: Mon, 27 Apr 2009 09:41:34 +0300
Message-ID: <49F5539E.6030308@mellanox.co.il>
References: <49EC859C.700@mellanox.co.il>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	tziporet@mellanox.co.il
To: unlisted-recipients:; (no To-header on input)
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.mellanox.co.il ([194.90.237.43]:50140 "EHLO mellanox.co.il"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751893AbZD0Gmh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 27 Apr 2009 02:42:37 -0400
In-Reply-To: <49EC859C.700@mellanox.co.il>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In case of mlx4_en_activate_cq() failure, the cleanup
code would go to rx_err and try to disable unactivated rings.

Signed-off-by: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
---
 drivers/net/mlx4/en_netdev.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/mlx4/en_netdev.c b/drivers/net/mlx4/en_netdev.c
index 438678a..7bcc49d 100644
--- a/drivers/net/mlx4/en_netdev.c
+++ b/drivers/net/mlx4/en_netdev.c
@@ -583,7 +583,7 @@ int mlx4_en_start_port(struct net_device *dev)
 		err = mlx4_en_activate_cq(priv, cq);
 		if (err) {
 			mlx4_err(mdev, "Failed activating Rx CQ\n");
-			goto rx_err;
+			goto cq_err;
 		}
 		for (j = 0; j < cq->size; j++)
 			cq->buf[j].owner_sr_opcode = MLX4_CQE_OWNER_MASK;
--


