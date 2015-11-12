From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH net 6/6] net/mlx4_core: Avoid returning success in case of an error flow
Date: Thu, 12 Nov 2015 19:35:30 +0200
Message-ID: <1447349730-19832-7-git-send-email-ogerlitz@mellanox.com>
References: <1447349730-19832-1-git-send-email-ogerlitz@mellanox.com>
Cc: netdev@vger.kernel.org, Saeed Mahameed <saeedm@mellanox.com>,
	Noa Osherovich <noaos@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [193.47.165.129] ([193.47.165.129]:46750 "EHLO mellanox.co.il"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753238AbbKLRf7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 12 Nov 2015 12:35:59 -0500
In-Reply-To: <1447349730-19832-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Noa Osherovich <noaos@mellanox.com>

The err variable wasn't set with the correct error value in some cases.

Fixes: 47605df95398 ('mlx4: Modify proxy/tunnel QP mechanism [..]')
Signed-off-by: Noa Osherovich <noaos@mellanox.com>
Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx4/main.c | 8 +++++---
 1 file changed, 5 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/main.c b/drivers/net/ethernet/mellanox/mlx4/main.c
index 85f1b1e..31c491e 100644
--- a/drivers/net/ethernet/mellanox/mlx4/main.c
+++ b/drivers/net/ethernet/mellanox/mlx4/main.c
@@ -892,9 +892,10 @@ static int mlx4_slave_cap(struct mlx4_dev *dev)
 		dev->caps.qp1_proxy[i - 1] = func_cap.qp1_proxy_qpn;
 		dev->caps.port_mask[i] = dev->caps.port_type[i];
 		dev->caps.phys_port_id[i] = func_cap.phys_port_id;
-		if (mlx4_get_slave_pkey_gid_tbl_len(dev, i,
-						    &dev->caps.gid_table_len[i],
-						    &dev->caps.pkey_table_len[i]))
+		err = mlx4_get_slave_pkey_gid_tbl_len(dev, i,
+						      &dev->caps.gid_table_len[i],
+						      &dev->caps.pkey_table_len[i]);
+		if (err)
 			goto err_mem;
 	}
 
@@ -906,6 +907,7 @@ static int mlx4_slave_cap(struct mlx4_dev *dev)
 			 dev->caps.uar_page_size * dev->caps.num_uars,
 			 (unsigned long long)
 			 pci_resource_len(dev->persist->pdev, 2));
+		err = -ENOMEM;
 		goto err_mem;
 	}
 
-- 
2.3.7
