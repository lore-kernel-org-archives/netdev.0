From: Aviad Yehezkel <aviadye@mellanox.com>
Subject: [RFC TLS Offload Support 12/15] mlx/tls: Enable MLX5_CORE_QP_SIM mode for tls
Date: Tue, 28 Mar 2017 16:26:29 +0300
Message-ID: <1490707592-1430-13-git-send-email-aviadye@mellanox.com>
References: <1490707592-1430-1-git-send-email-aviadye@mellanox.com>
Cc: matanb@mellanox.com, liranl@mellanox.com, haggaie@mellanox.com,
        tom@herbertland.com, herbert@gondor.apana.org.au, nmav@gnults.org,
        fridolin.pokorny@gmail.com, ilant@mellanox.com,
        kliteyn@mellanox.com, linux-crypto@vger.kernel.org,
        saeedm@mellanox.com, aviadye@dev.mellanox.co.il
To: davem@davemloft.net, aviadye@mellanox.com, ilyal@mellanox.com,
        borisp@mellanox.com, davejwatson@fb.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:47805 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S932538AbdC1N1R (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 28 Mar 2017 09:27:17 -0400
In-Reply-To: <1490707592-1430-1-git-send-email-aviadye@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Aviad Yehezkel <aviadye@mellanox.com>
Signed-off-by: Ilya Lesokhin <ilyal@mellanox.com>
---
 drivers/net/ethernet/mellanox/accelerator/tls/tls.c       | 6 ++++++
 drivers/net/ethernet/mellanox/accelerator/tls/tls_sysfs.c | 2 ++
 drivers/net/ethernet/mellanox/accelerator/tls/tls_sysfs.h | 2 ++
 3 files changed, 10 insertions(+)

diff --git a/drivers/net/ethernet/mellanox/accelerator/tls/tls.c b/drivers/net/ethernet/mellanox/accelerator/tls/tls.c
index 07a4b67..3560f784 100644
--- a/drivers/net/ethernet/mellanox/accelerator/tls/tls.c
+++ b/drivers/net/ethernet/mellanox/accelerator/tls/tls.c
@@ -494,9 +494,11 @@ static struct sk_buff *mlx_tls_rx_handler(struct sk_buff *skb, u8 *rawpet,
 static void mlx_tls_free(struct mlx_tls_dev *dev)
 {
 	list_del(&dev->accel_dev_list);
+#if IS_ENABLED(CONFIG_MLX5_CORE_FPGA_QP_SIM)
 #ifdef MLX_TLS_SADB_RDMA
 	kobject_put(&dev->kobj);
 #endif
+#endif
 	dev_put(dev->netdev);
 	kfree(dev);
 }
@@ -592,6 +594,7 @@ int mlx_tls_add_one(struct mlx_accel_core_device *accel_device)
 		goto err_netdev;
 	}
 
+#if IS_ENABLED(CONFIG_MLX5_CORE_FPGA_QP_SIM)
 #ifdef MLX_TLS_SADB_RDMA
 	ret = tls_sysfs_init_and_add(&dev->kobj,
 				     mlx_accel_core_kobj(dev->accel_device),
@@ -603,6 +606,7 @@ int mlx_tls_add_one(struct mlx_accel_core_device *accel_device)
 		goto err_ops_register;
 	}
 #endif
+#endif
 
 	mutex_lock(&mlx_tls_mutex);
 	list_add(&dev->accel_dev_list, &mlx_tls_devs);
@@ -611,10 +615,12 @@ int mlx_tls_add_one(struct mlx_accel_core_device *accel_device)
 	dev->netdev->tlsdev_ops = &mlx_tls_ops;
 	goto out;
 
+#if IS_ENABLED(CONFIG_MLX5_CORE_FPGA_QP_SIM)
 #ifdef MLX_TLS_SADB_RDMA
 err_ops_register:
 	mlx_accel_core_client_ops_unregister(accel_device);
 #endif
+#endif
 err_netdev:
 	dev_put(netdev);
 err_conn:
diff --git a/drivers/net/ethernet/mellanox/accelerator/tls/tls_sysfs.c b/drivers/net/ethernet/mellanox/accelerator/tls/tls_sysfs.c
index 2860fc3..76ba784 100644
--- a/drivers/net/ethernet/mellanox/accelerator/tls/tls_sysfs.c
+++ b/drivers/net/ethernet/mellanox/accelerator/tls/tls_sysfs.c
@@ -36,6 +36,7 @@
 #include "tls_sysfs.h"
 #include "tls_cmds.h"
 
+#if IS_ENABLED(CONFIG_MLX5_CORE_FPGA_QP_SIM)
 #ifdef MLX_TLS_SADB_RDMA
 struct mlx_tls_attribute {
 	struct attribute attr;
@@ -192,3 +193,4 @@ int tls_sysfs_init_and_add(struct kobject *kobj, struct kobject *parent,
 			fmt, arg);
 }
 #endif
+#endif
diff --git a/drivers/net/ethernet/mellanox/accelerator/tls/tls_sysfs.h b/drivers/net/ethernet/mellanox/accelerator/tls/tls_sysfs.h
index bfaa857..d7c3185 100644
--- a/drivers/net/ethernet/mellanox/accelerator/tls/tls_sysfs.h
+++ b/drivers/net/ethernet/mellanox/accelerator/tls/tls_sysfs.h
@@ -37,9 +37,11 @@
 
 #include "tls.h"
 
+#if IS_ENABLED(CONFIG_MLX5_CORE_FPGA_QP_SIM)
 #ifdef MLX_TLS_SADB_RDMA
 int tls_sysfs_init_and_add(struct kobject *kobj, struct kobject *parent,
 			   const char *fmt, char *arg);
 #endif
+#endif
 
 #endif	/* __TLS_SYSFS_H__ */
-- 
2.7.4
