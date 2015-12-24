From: Hariprasad Shenai <hariprasad@chelsio.com>
Subject: [PATCH net-next] cxgb4: Remove deprecated module parameters
Date: Thu, 24 Dec 2015 16:24:53 +0530
Message-ID: <1450954493-2165-1-git-send-email-hariprasad@chelsio.com>
Cc: davem@davemloft.net, leedom@chelsio.com, nirranjan@chelsio.com,
	Hariprasad Shenai <hariprasad@chelsio.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([12.32.117.8]:36740 "EHLO
	stargate3.asicdesigners.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S932639AbbLXKxf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Dec 2015 05:53:35 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Remove deprecated module parameters, and mark one parameter as
deprecated.

Signed-off-by: Hariprasad Shenai <hariprasad@chelsio.com>
---
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c | 54 +------------------------
 1 file changed, 2 insertions(+), 52 deletions(-)

diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
index bfe50aa..b8a5fb0 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
@@ -162,19 +162,8 @@ MODULE_FIRMWARE(FW6_FNAME);
 static uint force_init;
 
 module_param(force_init, uint, 0644);
-MODULE_PARM_DESC(force_init, "Forcibly become Master PF and initialize adapter");
-
-/*
- * Normally if the firmware we connect to has Configuration File support, we
- * use that and only fall back to the old Driver-based initialization if the
- * Configuration File fails for some reason.  If force_old_init is set, then
- * we'll always use the old Driver-based initialization sequence.
- */
-static uint force_old_init;
-
-module_param(force_old_init, uint, 0644);
-MODULE_PARM_DESC(force_old_init, "Force old initialization sequence, deprecated"
-		 " parameter");
+MODULE_PARM_DESC(force_init, "Forcibly become Master PF and initialize adapter,"
+		 "deprecated parameter");
 
 static int dflt_msg_enable = DFLT_MSG_ENABLE;
 
@@ -196,23 +185,6 @@ module_param(msi, int, 0644);
 MODULE_PARM_DESC(msi, "whether to use INTx (0), MSI (1) or MSI-X (2)");
 
 /*
- * Queue interrupt hold-off timer values.  Queues default to the first of these
- * upon creation.
- */
-static unsigned int intr_holdoff[SGE_NTIMERS - 1] = { 5, 10, 20, 50, 100 };
-
-module_param_array(intr_holdoff, uint, NULL, 0644);
-MODULE_PARM_DESC(intr_holdoff, "values for queue interrupt hold-off timers "
-		 "0..4 in microseconds, deprecated parameter");
-
-static unsigned int intr_cnt[SGE_NCOUNTERS - 1] = { 4, 8, 16 };
-
-module_param_array(intr_cnt, uint, NULL, 0644);
-MODULE_PARM_DESC(intr_cnt,
-		 "thresholds 1..3 for queue interrupt packet counters, "
-		 "deprecated parameter");
-
-/*
  * Normally we tell the chip to deliver Ingress Packets into our DMA buffers
  * offset by 2 bytes in order to have the IP headers line up on 4-byte
  * boundaries.  This is a requirement for many architectures which will throw
@@ -226,13 +198,7 @@ MODULE_PARM_DESC(intr_cnt,
  */
 static int rx_dma_offset = 2;
 
-static bool vf_acls;
-
 #ifdef CONFIG_PCI_IOV
-module_param(vf_acls, bool, 0644);
-MODULE_PARM_DESC(vf_acls, "if set enable virtualization L2 ACL enforcement, "
-		 "deprecated parameter");
-
 /* Configure the number of PCI-E Virtual Function which are to be instantiated
  * on SR-IOV Capable Physical Functions.
  */
@@ -253,12 +219,6 @@ module_param(select_queue, int, 0644);
 MODULE_PARM_DESC(select_queue,
 		 "Select between kernel provided method of selecting or driver method of selecting TX queue. Default is kernel method.");
 
-static unsigned int tp_vlan_pri_map = HW_TPL_FR_MT_PR_IV_P_FC;
-
-module_param(tp_vlan_pri_map, uint, 0644);
-MODULE_PARM_DESC(tp_vlan_pri_map, "global compressed filter configuration, "
-		 "deprecated parameter");
-
 static struct dentry *cxgb4_debugfs_root;
 
 static LIST_HEAD(adapter_list);
@@ -3141,16 +3101,6 @@ static int adap_init1(struct adapter *adap, struct fw_caps_config_cmd *c)
 	if (ret < 0)
 		return ret;
 
-	/* select capabilities we'll be using */
-	if (c->niccaps & htons(FW_CAPS_CONFIG_NIC_VM)) {
-		if (!vf_acls)
-			c->niccaps ^= htons(FW_CAPS_CONFIG_NIC_VM);
-		else
-			c->niccaps = htons(FW_CAPS_CONFIG_NIC_VM);
-	} else if (vf_acls) {
-		dev_err(adap->pdev_dev, "virtualization ACLs not supported");
-		return ret;
-	}
 	c->op_to_write = htonl(FW_CMD_OP_V(FW_CAPS_CONFIG_CMD) |
 			       FW_CMD_REQUEST_F | FW_CMD_WRITE_F);
 	ret = t4_wr_mbox(adap, adap->mbox, c, sizeof(*c), NULL);
-- 
2.3.4
