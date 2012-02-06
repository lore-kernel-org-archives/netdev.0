From: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
Subject: [PATCH net 3/3] mlx4_core: use correct port for steering
Date: Mon, 6 Feb 2012 18:26:36 +0200
Message-ID: <4F2FFF3C.6050308@mellanox.co.il>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <yevgenyp@mellanox.co.il>,
	<eugenia@mellanox.co.il>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog113.obsmtp.com ([207.126.144.135]:49565 "HELO
	eu1sys200aog113.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1755079Ab2BFQeL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Feb 2012 11:34:11 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eugenia Emantayev <eugenia@mellanox.co.il>

Use port number for correct steering (list per port).
Before the fix all steering entries (for both physical ports)
were managed in first port structures, so we had leakage of resources
for port 2.

Signed-off-by: Eugenia Emantayev <eugenia@mellanox.co.il>
---
 drivers/net/ethernet/mellanox/mlx4/mcg.c |   12 ++++++------
 1 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/mcg.c b/drivers/net/ethernet/mellanox/mlx4/mcg.c
index 00794cb..ca574d8 100644
--- a/drivers/net/ethernet/mellanox/mlx4/mcg.c
+++ b/drivers/net/ethernet/mellanox/mlx4/mcg.c
@@ -136,7 +136,7 @@ static int new_steering_entry(struct mlx4_dev *dev, u8 port,
 	u32 prot;
 	int err;
 
-	s_steer = &mlx4_priv(dev)->steer[0];
+	s_steer = &mlx4_priv(dev)->steer[port - 1];
 	new_entry = kzalloc(sizeof *new_entry, GFP_KERNEL);
 	if (!new_entry)
 		return -ENOMEM;
@@ -220,7 +220,7 @@ static int existing_steering_entry(struct mlx4_dev *dev, u8 port,
 	struct mlx4_promisc_qp *pqp;
 	struct mlx4_promisc_qp *dqp;
 
-	s_steer = &mlx4_priv(dev)->steer[0];
+	s_steer = &mlx4_priv(dev)->steer[port - 1];
 
 	pqp = get_promisc_qp(dev, 0, steer, qpn);
 	if (!pqp)
@@ -265,7 +265,7 @@ static bool check_duplicate_entry(struct mlx4_dev *dev, u8 port,
 	struct mlx4_steer_index *tmp_entry, *entry = NULL;
 	struct mlx4_promisc_qp *dqp, *tmp_dqp;
 
-	s_steer = &mlx4_priv(dev)->steer[0];
+	s_steer = &mlx4_priv(dev)->steer[port - 1];
 
 	/* if qp is not promisc, it cannot be duplicated */
 	if (!get_promisc_qp(dev, 0, steer, qpn))
@@ -306,7 +306,7 @@ static bool can_remove_steering_entry(struct mlx4_dev *dev, u8 port,
 	bool ret = false;
 	int i;
 
-	s_steer = &mlx4_priv(dev)->steer[0];
+	s_steer = &mlx4_priv(dev)->steer[port - 1];
 
 	mailbox = mlx4_alloc_cmd_mailbox(dev);
 	if (IS_ERR(mailbox))
@@ -361,7 +361,7 @@ static int add_promisc_qp(struct mlx4_dev *dev, u8 port,
 	int err;
 	struct mlx4_priv *priv = mlx4_priv(dev);
 
-	s_steer = &mlx4_priv(dev)->steer[0];
+	s_steer = &mlx4_priv(dev)->steer[port - 1];
 
 	mutex_lock(&priv->mcg_table.mutex);
 
@@ -466,7 +466,7 @@ static int remove_promisc_qp(struct mlx4_dev *dev, u8 port,
 	int loc, i;
 	int err;
 
-	s_steer = &mlx4_priv(dev)->steer[0];
+	s_steer = &mlx4_priv(dev)->steer[port - 1];
 	mutex_lock(&priv->mcg_table.mutex);
 
 	pqp = get_promisc_qp(dev, 0, steer, qpn);
-- 
1.5.4.3
