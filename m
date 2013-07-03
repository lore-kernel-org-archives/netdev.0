From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: [patch -next] net/mlx4: fix small memory leak on error
Date: Wed, 3 Jul 2013 12:37:46 +0300
Message-ID: <20130703093746.GE1598@elgon.mountain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Or Gerlitz <ogerlitz@mellanox.com>,
	Roland Dreier <roland@purestorage.com>,
	Jack Morgenstein <jackm@dev.mellanox.co.il>,
	Rony Efraim <ronye@mellanox.com>, netdev@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:32111 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932285Ab3GCJhz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Jul 2013 05:37:55 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

"work" needs to be freed before returning on this error path.

Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

diff --git a/drivers/net/ethernet/mellanox/mlx4/cmd.c b/drivers/net/ethernet/mellanox/mlx4/cmd.c
index 707a7d0..299d018 100644
--- a/drivers/net/ethernet/mellanox/mlx4/cmd.c
+++ b/drivers/net/ethernet/mellanox/mlx4/cmd.c
@@ -1572,6 +1572,7 @@ int mlx4_master_immediate_activate_vlan_qos(struct mlx4_priv *priv,
 					   vp_admin->default_vlan,
 					   &admin_vlan_ix);
 		if (err) {
+			kfree(work);
 			mlx4_warn((&priv->dev),
 				  "No vlan resources slave %d, port %d\n",
 				  slave, port);
