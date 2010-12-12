From: Tejun Heo <tj@kernel.org>
Subject: [PATCH 3/9] ehea: kill unused ehea_rereg_mr_task
Date: Sun, 12 Dec 2010 16:52:59 +0100
Message-ID: <1292169185-10579-4-git-send-email-tj@kernel.org>
References: <1292169185-10579-1-git-send-email-tj@kernel.org>
Cc: Tejun Heo <tj@kernel.org>, Breno Leitao <leitao@linux.vnet.ibm.com>
To: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1292169185-10579-1-git-send-email-tj@kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

ehea_rereg_mr_task is not used.  Remove it and drop @work parameter
from ehea_rereg_mrs().

Signed-off-by: Tejun Heo <tj@kernel.org>
Cc: Breno Leitao <leitao@linux.vnet.ibm.com>
Cc: netdev@vger.kernel.org
---
 drivers/net/ehea/ehea.h      |    2 --
 drivers/net/ehea/ehea_main.c |    9 +++------
 2 files changed, 3 insertions(+), 8 deletions(-)

diff --git a/drivers/net/ehea/ehea.h b/drivers/net/ehea/ehea.h
index 8e745e7..1f2a675 100644
--- a/drivers/net/ehea/ehea.h
+++ b/drivers/net/ehea/ehea.h
@@ -515,6 +515,4 @@ void ehea_set_ethtool_ops(struct net_device *netdev);
 int ehea_sense_port_attr(struct ehea_port *port);
 int ehea_set_portspeed(struct ehea_port *port, u32 port_speed);
 
-extern struct work_struct ehea_rereg_mr_task;
-
 #endif	/* __EHEA_H__ */
diff --git a/drivers/net/ehea/ehea_main.c b/drivers/net/ehea/ehea_main.c
index 69f6152..d51def1 100644
--- a/drivers/net/ehea/ehea_main.c
+++ b/drivers/net/ehea/ehea_main.c
@@ -101,7 +101,6 @@ MODULE_PARM_DESC(use_lro, " Large Receive Offload, 1: enable, 0: disable, "
 static int port_name_cnt;
 static LIST_HEAD(adapter_list);
 static unsigned long ehea_driver_flags;
-struct work_struct ehea_rereg_mr_task;
 static DEFINE_MUTEX(dlpar_mem_lock);
 struct ehea_fw_handle_array ehea_fw_handles;
 struct ehea_bcmc_reg_array ehea_bcmc_regs;
@@ -2984,7 +2983,7 @@ out:
 	mutex_unlock(&dlpar_mem_lock);
 }
 
-static void ehea_rereg_mrs(struct work_struct *work)
+static void ehea_rereg_mrs(void)
 {
 	int ret, i;
 	struct ehea_adapter *adapter;
@@ -3659,14 +3658,14 @@ static int ehea_mem_notifier(struct notifier_block *nb,
 		set_bit(__EHEA_STOP_XFER, &ehea_driver_flags);
 		if (ehea_add_sect_bmap(arg->start_pfn, arg->nr_pages))
 			goto out_unlock;
-		ehea_rereg_mrs(NULL);
+		ehea_rereg_mrs();
 		break;
 	case MEM_GOING_OFFLINE:
 		ehea_info("memory is going offline");
 		set_bit(__EHEA_STOP_XFER, &ehea_driver_flags);
 		if (ehea_rem_sect_bmap(arg->start_pfn, arg->nr_pages))
 			goto out_unlock;
-		ehea_rereg_mrs(NULL);
+		ehea_rereg_mrs();
 		break;
 	default:
 		break;
@@ -3742,8 +3741,6 @@ int __init ehea_module_init(void)
 	printk(KERN_INFO "IBM eHEA ethernet device driver (Release %s)\n",
 	       DRV_VERSION);
 
-
-	INIT_WORK(&ehea_rereg_mr_task, ehea_rereg_mrs);
 	memset(&ehea_fw_handles, 0, sizeof(ehea_fw_handles));
 	memset(&ehea_bcmc_regs, 0, sizeof(ehea_bcmc_regs));
 
-- 
1.7.1
