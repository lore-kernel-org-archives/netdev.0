From: Mariusz Kozlowski <mk@lab.zgora.pl>
Subject: [PATCH] mlx4: fix kfree on error path in new_steering_entry()
Date: Sun,  3 Apr 2011 23:26:23 +0200
Message-ID: <1301865983-6584-1-git-send-email-mk@lab.zgora.pl>
Cc: Yevgeny Petrilin <yevgenyp@mellanox.co.il>,
	Roland Dreier <rolandd@cisco.com>,
	Aleksey Senin <alekseys@voltaire.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, Mariusz Kozlowski <mk@lab.zgora.pl>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On error path kfree() should get pointer to memory allocated by
kmalloc() not the address of variable holding it (which is on stack).

Signed-off-by: Mariusz Kozlowski <mk@lab.zgora.pl>
---
 drivers/net/mlx4/mcg.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/mlx4/mcg.c b/drivers/net/mlx4/mcg.c
index 37150b2..c6d336a 100644
--- a/drivers/net/mlx4/mcg.c
+++ b/drivers/net/mlx4/mcg.c
@@ -111,7 +111,7 @@ static int new_steering_entry(struct mlx4_dev *dev, u8 vep_num, u8 port,
 	u32 members_count;
 	struct mlx4_steer_index *new_entry;
 	struct mlx4_promisc_qp *pqp;
-	struct mlx4_promisc_qp *dqp;
+	struct mlx4_promisc_qp *dqp = NULL;
 	u32 prot;
 	int err;
 	u8 pf_num;
@@ -184,7 +184,7 @@ out_mailbox:
 out_alloc:
 	if (dqp) {
 		list_del(&dqp->list);
-		kfree(&dqp);
+		kfree(dqp);
 	}
 	list_del(&new_entry->list);
 	kfree(new_entry);
-- 
1.7.0.4
