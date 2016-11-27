From: Tariq Toukan <tariqt@mellanox.com>
Subject: [PATCH net-next 02/10] net/mlx4: Replace ENOSYS with better fitting error codes
Date: Sun, 27 Nov 2016 17:51:09 +0200
Message-ID: <1480261877-19720-3-git-send-email-tariqt@mellanox.com>
References: <1480261877-19720-1-git-send-email-tariqt@mellanox.com>
Cc: netdev@vger.kernel.org, Eran Ben Elisha <eranbe@mellanox.com>,
        Tariq Toukan <tariqt@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:50468 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1753233AbcK0Pvp (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 27 Nov 2016 10:51:45 -0500
In-Reply-To: <1480261877-19720-1-git-send-email-tariqt@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Conform the following warning:
WARNING: ENOSYS means 'invalid syscall nr' and nothing else.

Signed-off-by: Tariq Toukan <tariqt@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx4/en_ethtool.c       | 2 +-
 drivers/net/ethernet/mellanox/mlx4/fw.c               | 2 +-
 drivers/net/ethernet/mellanox/mlx4/main.c             | 6 +++---
 drivers/net/ethernet/mellanox/mlx4/resource_tracker.c | 2 +-
 4 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/en_ethtool.c b/drivers/net/ethernet/mellanox/mlx4/en_ethtool.c
index 487a58f9c192..7e6d0425394d 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_ethtool.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_ethtool.c
@@ -1983,7 +1983,7 @@ static int mlx4_en_get_module_info(struct net_device *dev,
 		modinfo->eeprom_len = ETH_MODULE_SFF_8472_LEN;
 		break;
 	default:
-		return -ENOSYS;
+		return -EINVAL;
 	}
 
 	return 0;
diff --git a/drivers/net/ethernet/mellanox/mlx4/fw.c b/drivers/net/ethernet/mellanox/mlx4/fw.c
index b03b473a7b07..c2ba16e23169 100644
--- a/drivers/net/ethernet/mellanox/mlx4/fw.c
+++ b/drivers/net/ethernet/mellanox/mlx4/fw.c
@@ -672,7 +672,7 @@ int mlx4_QUERY_FUNC_CAP(struct mlx4_dev *dev, u8 gen_or_port,
 	MLX4_GET(field, outbox, QUERY_FUNC_CAP_PHYS_PORT_OFFSET);
 	func_cap->physical_port = field;
 	if (func_cap->physical_port != gen_or_port) {
-		err = -ENOSYS;
+		err = -EINVAL;
 		goto out;
 	}
 
diff --git a/drivers/net/ethernet/mellanox/mlx4/main.c b/drivers/net/ethernet/mellanox/mlx4/main.c
index 7cd1fb566f5a..41cd05f37b20 100644
--- a/drivers/net/ethernet/mellanox/mlx4/main.c
+++ b/drivers/net/ethernet/mellanox/mlx4/main.c
@@ -820,7 +820,7 @@ static int mlx4_slave_cap(struct mlx4_dev *dev)
 	 */
 	if (hca_param.global_caps) {
 		mlx4_err(dev, "Unknown hca global capabilities\n");
-		return -ENOSYS;
+		return -EINVAL;
 	}
 
 	mlx4_log_num_mgm_entry_size = hca_param.log_mc_entry_sz;
@@ -878,7 +878,7 @@ static int mlx4_slave_cap(struct mlx4_dev *dev)
 	    PF_CONTEXT_BEHAVIOUR_MASK) {
 		mlx4_err(dev, "Unknown pf context behaviour %x known flags %x\n",
 			 func_cap.pf_context_behaviour, PF_CONTEXT_BEHAVIOUR_MASK);
-		return -ENOSYS;
+		return -EINVAL;
 	}
 
 	dev->caps.num_ports		= func_cap.num_ports;
@@ -3476,7 +3476,7 @@ static int mlx4_load_one(struct pci_dev *pdev, int pci_dev_data,
 	mlx4_enable_msi_x(dev);
 	if ((mlx4_is_mfunc(dev)) &&
 	    !(dev->flags & MLX4_FLAG_MSI_X)) {
-		err = -ENOSYS;
+		err = -ENOTSUPP;
 		mlx4_err(dev, "INTx is not supported in multi-function mode, aborting\n");
 		goto err_free_eq;
 	}
diff --git a/drivers/net/ethernet/mellanox/mlx4/resource_tracker.c b/drivers/net/ethernet/mellanox/mlx4/resource_tracker.c
index ba7b70630d5d..05ba270c4862 100644
--- a/drivers/net/ethernet/mellanox/mlx4/resource_tracker.c
+++ b/drivers/net/ethernet/mellanox/mlx4/resource_tracker.c
@@ -1396,7 +1396,7 @@ static int remove_ok(struct res_common *res, enum mlx4_resource type, int extra)
 	case RES_MTT:
 		return remove_mtt_ok((struct res_mtt *)res, extra);
 	case RES_MAC:
-		return -ENOSYS;
+		return -ENOTSUPP;
 	case RES_EQ:
 		return remove_eq_ok((struct res_eq *)res);
 	case RES_COUNTER:
-- 
1.8.3.1
