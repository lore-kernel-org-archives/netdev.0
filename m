From: Thadeu Lima de Souza Cascardo <cascardo@linux.vnet.ibm.com>
Subject: [PATCH] ehea: make some functions and variables static
Date: Fri, 13 Jan 2012 16:06:32 -0200
Message-ID: <1326477992-16229-1-git-send-email-cascardo@linux.vnet.ibm.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Thadeu Lima de Souza Cascardo <cascardo@linux.vnet.ibm.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e24smtp03.br.ibm.com ([32.104.18.24]:58402 "EHLO
	e24smtp03.br.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753224Ab2AMSGv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Jan 2012 13:06:51 -0500
Received: from /spool/local
	by e24smtp03.br.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <cascardo@linux.vnet.ibm.com>;
	Fri, 13 Jan 2012 16:06:45 -0200
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Some functions and variables in ehea are only used in their own file, so
they should be static. One particular function had a very generic name,
print_error_data.

Signed-off-by: Thadeu Lima de Souza Cascardo <cascardo@linux.vnet.ibm.com>
---
 drivers/net/ethernet/ibm/ehea/ehea_ethtool.c |    2 +-
 drivers/net/ethernet/ibm/ehea/ehea_main.c    |   32 +++++++++++++-------------
 drivers/net/ethernet/ibm/ehea/ehea_qmr.c     |   14 +++++------
 3 files changed, 23 insertions(+), 25 deletions(-)

diff --git a/drivers/net/ethernet/ibm/ehea/ehea_ethtool.c b/drivers/net/ethernet/ibm/ehea/ehea_ethtool.c
index 05b7359..6bdd8e3 100644
--- a/drivers/net/ethernet/ibm/ehea/ehea_ethtool.c
+++ b/drivers/net/ethernet/ibm/ehea/ehea_ethtool.c
@@ -263,7 +263,7 @@ static void ehea_get_ethtool_stats(struct net_device *dev,
 		data[i++] = atomic_read(&port->port_res[k].swqe_avail);
 }
 
-const struct ethtool_ops ehea_ethtool_ops = {
+static const struct ethtool_ops ehea_ethtool_ops = {
 	.get_settings = ehea_get_settings,
 	.get_drvinfo = ehea_get_drvinfo,
 	.get_msglevel = ehea_get_msglevel,
diff --git a/drivers/net/ethernet/ibm/ehea/ehea_main.c b/drivers/net/ethernet/ibm/ehea/ehea_main.c
index 3554414..5d5fb26 100644
--- a/drivers/net/ethernet/ibm/ehea/ehea_main.c
+++ b/drivers/net/ethernet/ibm/ehea/ehea_main.c
@@ -94,8 +94,8 @@ static int port_name_cnt;
 static LIST_HEAD(adapter_list);
 static unsigned long ehea_driver_flags;
 static DEFINE_MUTEX(dlpar_mem_lock);
-struct ehea_fw_handle_array ehea_fw_handles;
-struct ehea_bcmc_reg_array ehea_bcmc_regs;
+static struct ehea_fw_handle_array ehea_fw_handles;
+static struct ehea_bcmc_reg_array ehea_bcmc_regs;
 
 
 static int __devinit ehea_probe_adapter(struct platform_device *dev,
@@ -133,7 +133,7 @@ void ehea_dump(void *adr, int len, char *msg)
 	}
 }
 
-void ehea_schedule_port_reset(struct ehea_port *port)
+static void ehea_schedule_port_reset(struct ehea_port *port)
 {
 	if (!test_bit(__EHEA_DISABLE_PORT_RESET, &port->flags))
 		schedule_work(&port->reset_task);
@@ -1404,7 +1404,7 @@ out:
 	return ret;
 }
 
-int ehea_gen_smrs(struct ehea_port_res *pr)
+static int ehea_gen_smrs(struct ehea_port_res *pr)
 {
 	int ret;
 	struct ehea_adapter *adapter = pr->port->adapter;
@@ -1426,7 +1426,7 @@ out:
 	return -EIO;
 }
 
-int ehea_rem_smrs(struct ehea_port_res *pr)
+static int ehea_rem_smrs(struct ehea_port_res *pr)
 {
 	if ((ehea_rem_mr(&pr->send_mr)) ||
 	    (ehea_rem_mr(&pr->recv_mr)))
@@ -2190,7 +2190,7 @@ out:
 	return err;
 }
 
-int ehea_activate_qp(struct ehea_adapter *adapter, struct ehea_qp *qp)
+static int ehea_activate_qp(struct ehea_adapter *adapter, struct ehea_qp *qp)
 {
 	int ret = -EIO;
 	u64 hret;
@@ -2531,7 +2531,7 @@ static void ehea_flush_sq(struct ehea_port *port)
 	}
 }
 
-int ehea_stop_qps(struct net_device *dev)
+static int ehea_stop_qps(struct net_device *dev)
 {
 	struct ehea_port *port = netdev_priv(dev);
 	struct ehea_adapter *adapter = port->adapter;
@@ -2600,7 +2600,7 @@ out:
 	return ret;
 }
 
-void ehea_update_rqs(struct ehea_qp *orig_qp, struct ehea_port_res *pr)
+static void ehea_update_rqs(struct ehea_qp *orig_qp, struct ehea_port_res *pr)
 {
 	struct ehea_qp qp = *orig_qp;
 	struct ehea_qp_init_attr *init_attr = &qp.init_attr;
@@ -2633,7 +2633,7 @@ void ehea_update_rqs(struct ehea_qp *orig_qp, struct ehea_port_res *pr)
 	}
 }
 
-int ehea_restart_qps(struct net_device *dev)
+static int ehea_restart_qps(struct net_device *dev)
 {
 	struct ehea_port *port = netdev_priv(dev);
 	struct ehea_adapter *adapter = port->adapter;
@@ -2824,7 +2824,7 @@ static void ehea_tx_watchdog(struct net_device *dev)
 		ehea_schedule_port_reset(port);
 }
 
-int ehea_sense_adapter_attr(struct ehea_adapter *adapter)
+static int ehea_sense_adapter_attr(struct ehea_adapter *adapter)
 {
 	struct hcp_query_ehea *cb;
 	u64 hret;
@@ -2852,7 +2852,7 @@ out:
 	return ret;
 }
 
-int ehea_get_jumboframe_status(struct ehea_port *port, int *jumbo)
+static int ehea_get_jumboframe_status(struct ehea_port *port, int *jumbo)
 {
 	struct hcp_ehea_port_cb4 *cb4;
 	u64 hret;
@@ -2966,7 +2966,7 @@ static const struct net_device_ops ehea_netdev_ops = {
 	.ndo_tx_timeout		= ehea_tx_watchdog,
 };
 
-struct ehea_port *ehea_setup_single_port(struct ehea_adapter *adapter,
+static struct ehea_port *ehea_setup_single_port(struct ehea_adapter *adapter,
 					 u32 logical_port_id,
 					 struct device_node *dn)
 {
@@ -3237,7 +3237,7 @@ static ssize_t ehea_remove_port(struct device *dev,
 static DEVICE_ATTR(probe_port, S_IWUSR, NULL, ehea_probe_port);
 static DEVICE_ATTR(remove_port, S_IWUSR, NULL, ehea_remove_port);
 
-int ehea_create_device_sysfs(struct platform_device *dev)
+static int ehea_create_device_sysfs(struct platform_device *dev)
 {
 	int ret = device_create_file(&dev->dev, &dev_attr_probe_port);
 	if (ret)
@@ -3248,7 +3248,7 @@ out:
 	return ret;
 }
 
-void ehea_remove_device_sysfs(struct platform_device *dev)
+static void ehea_remove_device_sysfs(struct platform_device *dev)
 {
 	device_remove_file(&dev->dev, &dev_attr_probe_port);
 	device_remove_file(&dev->dev, &dev_attr_remove_port);
@@ -3379,7 +3379,7 @@ static int __devexit ehea_remove(struct platform_device *dev)
 	return 0;
 }
 
-void ehea_crash_handler(void)
+static void ehea_crash_handler(void)
 {
 	int i;
 
@@ -3491,7 +3491,7 @@ static ssize_t ehea_show_capabilities(struct device_driver *drv,
 static DRIVER_ATTR(capabilities, S_IRUSR | S_IRGRP | S_IROTH,
 		   ehea_show_capabilities, NULL);
 
-int __init ehea_module_init(void)
+static int __init ehea_module_init(void)
 {
 	int ret;
 
diff --git a/drivers/net/ethernet/ibm/ehea/ehea_qmr.c b/drivers/net/ethernet/ibm/ehea/ehea_qmr.c
index 95b9f4f..c25b05b 100644
--- a/drivers/net/ethernet/ibm/ehea/ehea_qmr.c
+++ b/drivers/net/ethernet/ibm/ehea/ehea_qmr.c
@@ -34,9 +34,7 @@
 #include "ehea_phyp.h"
 #include "ehea_qmr.h"
 
-struct ehea_bmap *ehea_bmap = NULL;
-
-
+static struct ehea_bmap *ehea_bmap;
 
 static void *hw_qpageit_get_inc(struct hw_queue *queue)
 {
@@ -212,7 +210,7 @@ out_nomem:
 	return NULL;
 }
 
-u64 ehea_destroy_cq_res(struct ehea_cq *cq, u64 force)
+static u64 ehea_destroy_cq_res(struct ehea_cq *cq, u64 force)
 {
 	u64 hret;
 	u64 adapter_handle = cq->adapter->handle;
@@ -337,7 +335,7 @@ struct ehea_eqe *ehea_poll_eq(struct ehea_eq *eq)
 	return eqe;
 }
 
-u64 ehea_destroy_eq_res(struct ehea_eq *eq, u64 force)
+static u64 ehea_destroy_eq_res(struct ehea_eq *eq, u64 force)
 {
 	u64 hret;
 	unsigned long flags;
@@ -381,7 +379,7 @@ int ehea_destroy_eq(struct ehea_eq *eq)
 /**
  * allocates memory for a queue and registers pages in phyp
  */
-int ehea_qp_alloc_register(struct ehea_qp *qp, struct hw_queue *hw_queue,
+static int ehea_qp_alloc_register(struct ehea_qp *qp, struct hw_queue *hw_queue,
 			   int nr_pages, int wqe_size, int act_nr_sges,
 			   struct ehea_adapter *adapter, int h_call_q_selector)
 {
@@ -516,7 +514,7 @@ out_freemem:
 	return NULL;
 }
 
-u64 ehea_destroy_qp_res(struct ehea_qp *qp, u64 force)
+static u64 ehea_destroy_qp_res(struct ehea_qp *qp, u64 force)
 {
 	u64 hret;
 	struct ehea_qp_init_attr *qp_attr = &qp->init_attr;
@@ -976,7 +974,7 @@ int ehea_gen_smr(struct ehea_adapter *adapter, struct ehea_mr *old_mr,
 	return 0;
 }
 
-void print_error_data(u64 *data)
+static void print_error_data(u64 *data)
 {
 	int length;
 	u64 type = EHEA_BMASK_GET(ERROR_DATA_TYPE, data[2]);
-- 
1.7.4.4
