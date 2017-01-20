From: Geliang Tang <geliangtang@gmail.com>
Subject: [PATCH] net/mlx4: use rb_entry()
Date: Fri, 20 Jan 2017 22:36:57 +0800
Message-ID: <6c1c772de8f70113580dade04f89a377174d8c88.1484817025.git.geliangtang@gmail.com>
References: <c6a809ea5820242a4ae126b03cdcd910a36e5cae.1484817152.git.geliangtang@gmail.com>
Cc: Geliang Tang <geliangtang@gmail.com>, netdev@vger.kernel.org,
        linux-rdma@vger.kernel.org, linux-kernel@vger.kernel.org
To: Yishai Hadas <yishaih@mellanox.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <c6a809ea5820242a4ae126b03cdcd910a36e5cae.1484817152.git.geliangtang@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

To make the code clearer, use rb_entry() instead of container_of() to
deal with rbtree.

Signed-off-by: Geliang Tang <geliangtang@gmail.com>
---
 drivers/net/ethernet/mellanox/mlx4/resource_tracker.c | 8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/resource_tracker.c b/drivers/net/ethernet/mellanox/mlx4/resource_tracker.c
index 1822382..6da6e01 100644
--- a/drivers/net/ethernet/mellanox/mlx4/resource_tracker.c
+++ b/drivers/net/ethernet/mellanox/mlx4/resource_tracker.c
@@ -236,8 +236,8 @@ static void *res_tracker_lookup(struct rb_root *root, u64 res_id)
 	struct rb_node *node = root->rb_node;
 
 	while (node) {
-		struct res_common *res = container_of(node, struct res_common,
-						      node);
+		struct res_common *res = rb_entry(node, struct res_common,
+						  node);
 
 		if (res_id < res->res_id)
 			node = node->rb_left;
@@ -255,8 +255,8 @@ static int res_tracker_insert(struct rb_root *root, struct res_common *res)
 
 	/* Figure out where to put new node */
 	while (*new) {
-		struct res_common *this = container_of(*new, struct res_common,
-						       node);
+		struct res_common *this = rb_entry(*new, struct res_common,
+						   node);
 
 		parent = *new;
 		if (res->res_id < this->res_id)
-- 
2.9.3
