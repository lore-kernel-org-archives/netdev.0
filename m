From: Amir Vadai <amirv@mellanox.com>
Subject: [PATCH net-next 2/2] net/mlx4_core: Replace pr_warning() with pr_warn()
Date: Mon, 19 May 2014 11:37:42 +0300
Message-ID: <1400488662-5657-3-git-send-email-amirv@mellanox.com>
References: <1400488662-5657-1-git-send-email-amirv@mellanox.com>
Cc: netdev@vger.kernel.org, Amir Vadai <amirv@mellanox.com>,
	Yevgeny Petrilin <yevgenyp@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailp.voltaire.com ([193.47.165.129]:36342 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753696AbaESIiE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 19 May 2014 04:38:04 -0400
In-Reply-To: <1400488662-5657-1-git-send-email-amirv@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

As checkpatch suggests. Also changed some printk's into pr_*

Signed-off-by: Amir Vadai <amirv@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx4/cmd.c              |  6 +++---
 drivers/net/ethernet/mellanox/mlx4/main.c             | 13 +++++++------
 drivers/net/ethernet/mellanox/mlx4/mr.c               |  6 ++----
 drivers/net/ethernet/mellanox/mlx4/resource_tracker.c | 10 +++++-----
 4 files changed, 17 insertions(+), 18 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/cmd.c b/drivers/net/ethernet/mellanox/mlx4/cmd.c
index 357dcb0..59c7fd4 100644
--- a/drivers/net/ethernet/mellanox/mlx4/cmd.c
+++ b/drivers/net/ethernet/mellanox/mlx4/cmd.c
@@ -1887,9 +1887,9 @@ void mlx4_master_comm_channel(struct work_struct *work)
 			if (toggle != slt) {
 				if (master->slave_state[slave].comm_toggle
 				    != slt) {
-					printk(KERN_INFO "slave %d out of sync. read toggle %d, state toggle %d. Resynching.\n",
-					       slave, slt,
-					       master->slave_state[slave].comm_toggle);
+					pr_info("slave %d out of sync. read toggle %d, state toggle %d. Resynching.\n",
+						slave, slt,
+						master->slave_state[slave].comm_toggle);
 					master->slave_state[slave].comm_toggle =
 						slt;
 				}
diff --git a/drivers/net/ethernet/mellanox/mlx4/main.c b/drivers/net/ethernet/mellanox/mlx4/main.c
index 08ff5dd..38e9a4c 100644
--- a/drivers/net/ethernet/mellanox/mlx4/main.c
+++ b/drivers/net/ethernet/mellanox/mlx4/main.c
@@ -2593,7 +2593,7 @@ static void __mlx4_remove_one(struct pci_dev *pdev)
 	/* in SRIOV it is not allowed to unload the pf's
 	 * driver while there are alive vf's */
 	if (mlx4_is_master(dev) && mlx4_how_many_lives_vf(dev))
-		printk(KERN_ERR "Removing PF when there are assigned VF's !!!\n");
+		pr_warn("Removing PF when there are assigned VF's !!!\n");
 	mlx4_stop_sense(dev);
 	mlx4_unregister_device(dev);
 
@@ -2764,25 +2764,26 @@ static struct pci_driver mlx4_driver = {
 static int __init mlx4_verify_params(void)
 {
 	if ((log_num_mac < 0) || (log_num_mac > 7)) {
-		pr_warning("mlx4_core: bad num_mac: %d\n", log_num_mac);
+		pr_warn("mlx4_core: bad num_mac: %d\n", log_num_mac);
 		return -1;
 	}
 
 	if (log_num_vlan != 0)
-		pr_warning("mlx4_core: log_num_vlan - obsolete module param, using %d\n",
-			   MLX4_LOG_NUM_VLANS);
+		pr_warn("mlx4_core: log_num_vlan - obsolete module param, using %d\n",
+			MLX4_LOG_NUM_VLANS);
 
 	if (use_prio != 0)
 		pr_warn("mlx4_core: use_prio - obsolete module param, ignored\n");
 
 	if ((log_mtts_per_seg < 1) || (log_mtts_per_seg > 7)) {
-		pr_warning("mlx4_core: bad log_mtts_per_seg: %d\n", log_mtts_per_seg);
+		pr_warn("mlx4_core: bad log_mtts_per_seg: %d\n",
+			log_mtts_per_seg);
 		return -1;
 	}
 
 	/* Check if module param for ports type has legal combination */
 	if (port_type_array[0] == false && port_type_array[1] == true) {
-		printk(KERN_WARNING "Module parameter configuration ETH/IB is not supported. Switching to default configuration IB/IB\n");
+		pr_warn("Module parameter configuration ETH/IB is not supported. Switching to default configuration IB/IB\n");
 		port_type_array[0] = true;
 	}
 
diff --git a/drivers/net/ethernet/mellanox/mlx4/mr.c b/drivers/net/ethernet/mellanox/mlx4/mr.c
index 64fb3e6..3e04ea1 100644
--- a/drivers/net/ethernet/mellanox/mlx4/mr.c
+++ b/drivers/net/ethernet/mellanox/mlx4/mr.c
@@ -954,8 +954,7 @@ void mlx4_fmr_unmap(struct mlx4_dev *dev, struct mlx4_fmr *fmr,
 	mailbox = mlx4_alloc_cmd_mailbox(dev);
 	if (IS_ERR(mailbox)) {
 		err = PTR_ERR(mailbox);
-		printk(KERN_WARNING "mlx4_ib: mlx4_alloc_cmd_mailbox failed (%d)\n",
-		       err);
+		pr_warn("mlx4_ib: mlx4_alloc_cmd_mailbox failed (%d)\n", err);
 		return;
 	}
 
@@ -964,8 +963,7 @@ void mlx4_fmr_unmap(struct mlx4_dev *dev, struct mlx4_fmr *fmr,
 			     (dev->caps.num_mpts - 1));
 	mlx4_free_cmd_mailbox(dev, mailbox);
 	if (err) {
-		printk(KERN_WARNING "mlx4_ib: mlx4_HW2SW_MPT failed (%d)\n",
-		       err);
+		pr_warn("mlx4_ib: mlx4_HW2SW_MPT failed (%d)\n", err);
 		return;
 	}
 	fmr->mr.enabled = MLX4_MPT_EN_SW;
diff --git a/drivers/net/ethernet/mellanox/mlx4/resource_tracker.c b/drivers/net/ethernet/mellanox/mlx4/resource_tracker.c
index a95df9d..4094e11 100644
--- a/drivers/net/ethernet/mellanox/mlx4/resource_tracker.c
+++ b/drivers/net/ethernet/mellanox/mlx4/resource_tracker.c
@@ -962,7 +962,7 @@ static struct res_common *alloc_tr(u64 id, enum mlx4_resource type, int slave,
 		ret = alloc_srq_tr(id);
 		break;
 	case RES_MAC:
-		printk(KERN_ERR "implementation missing\n");
+		pr_err("implementation missing\n");
 		return NULL;
 	case RES_COUNTER:
 		ret = alloc_counter_tr(id);
@@ -1056,10 +1056,10 @@ static int remove_mtt_ok(struct res_mtt *res, int order)
 {
 	if (res->com.state == RES_MTT_BUSY ||
 	    atomic_read(&res->ref_count)) {
-		printk(KERN_DEBUG "%s-%d: state %s, ref_count %d\n",
-		       __func__, __LINE__,
-		       mtt_states_str(res->com.state),
-		       atomic_read(&res->ref_count));
+		pr_devel("%s-%d: state %s, ref_count %d\n",
+			 __func__, __LINE__,
+			 mtt_states_str(res->com.state),
+			 atomic_read(&res->ref_count));
 		return -EBUSY;
 	} else if (res->com.state != RES_MTT_ALLOCATED)
 		return -EPERM;
-- 
1.8.3.4
