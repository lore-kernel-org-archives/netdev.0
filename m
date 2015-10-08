From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH net 1/5] net/mlx4_core: Avoid failing the interrupts test
Date: Thu,  8 Oct 2015 15:26:15 +0300
Message-ID: <1444307179-16105-2-git-send-email-ogerlitz@mellanox.com>
References: <1444307179-16105-1-git-send-email-ogerlitz@mellanox.com>
Cc: netdev@vger.kernel.org, Achiad Shochat <achiad@mellanox.com>,
	Amir Vadai <amirv@mellanox.com>,
	Carol L Soto <clsoto@linux.vnet.ibm.com>,
	Or Gerlitz <ogerlitz@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [193.47.165.129] ([193.47.165.129]:57447 "EHLO mellanox.co.il"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1754387AbbJHM0r (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 8 Oct 2015 08:26:47 -0400
In-Reply-To: <1444307179-16105-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Carol L Soto <clsoto@linux.vnet.ibm.com>

Test interrupts fails if not all completion vectors called
request_irq. This case happens if only mlx4_en is loaded and
we have more completion vectors than rx rings.

Fixes: c66fa19c405a ('net/mlx4: Add EQ pool')
Signed-off-by: Carol L Soto <clsoto@linux.vnet.ibm.com>
Acked-by: Matan Barak <matanb@mellanox.com>
Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx4/eq.c | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/drivers/net/ethernet/mellanox/mlx4/eq.c b/drivers/net/ethernet/mellanox/mlx4/eq.c
index 8e81e53..c344884 100644
--- a/drivers/net/ethernet/mellanox/mlx4/eq.c
+++ b/drivers/net/ethernet/mellanox/mlx4/eq.c
@@ -1364,6 +1364,10 @@ int mlx4_test_interrupts(struct mlx4_dev *dev)
 	 * and performing a NOP command
 	 */
 	for(i = 0; !err && (i < dev->caps.num_comp_vectors); ++i) {
+		/* Make sure request_irq was called */
+		if (!priv->eq_table.eq[i].have_irq)
+			continue;
+
 		/* Temporary use polling for command completions */
 		mlx4_cmd_use_polling(dev);
 
-- 
2.3.7
