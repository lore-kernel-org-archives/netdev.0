From: Shahed Shaikh <shahed.shaikh@qlogic.com>
Subject: [PATCH net-next 2/9] qlcnic: Remove inline keyword
Date: Fri, 30 Aug 2013 13:51:17 -0400
Message-ID: <1377885084-6441-3-git-send-email-shahed.shaikh@qlogic.com>
References: <1377885084-6441-1-git-send-email-shahed.shaikh@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <Dept-HSGLinuxNICDev@qlogic.com>,
	Manish Chopra <manish.chopra@qlogic.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-0016ce01.pphosted.com ([67.231.148.157]:5299 "EHLO
	mx0a-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756827Ab3H3SUU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Aug 2013 14:20:20 -0400
In-Reply-To: <1377885084-6441-1-git-send-email-shahed.shaikh@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Manish Chopra <manish.chopra@qlogic.com>

o Remove inline keyword from function prototypes wherever it is not appropriate.

Signed-off-by: Manish Chopra <manish.chopra@qlogic.com>
---
 .../net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.c    |   23 +++++++++----------
 .../net/ethernet/qlogic/qlcnic/qlcnic_83xx_init.c  |    4 +-
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c   |    4 +-
 .../net/ethernet/qlogic/qlcnic/qlcnic_sriov_pf.c   |    4 +-
 4 files changed, 17 insertions(+), 18 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.c
index 8fce1d3..36223a9 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.c
@@ -723,9 +723,8 @@ void qlcnic_dump_mbx(struct qlcnic_adapter *adapter,
 	pr_info("\n");
 }
 
-static inline void
-qlcnic_83xx_poll_for_mbx_completion(struct qlcnic_adapter *adapter,
-				    struct qlcnic_cmd_args *cmd)
+static void qlcnic_83xx_poll_for_mbx_completion(struct qlcnic_adapter *adapter,
+						struct qlcnic_cmd_args *cmd)
 {
 	struct qlcnic_hardware_context *ahw = adapter->ahw;
 	int opcode = LSW(cmd->req.arg[0]);
@@ -3544,7 +3543,7 @@ qlcnic_83xx_notify_cmd_completion(struct qlcnic_adapter *adapter,
 	complete(&cmd->completion);
 }
 
-static inline void qlcnic_83xx_flush_mbx_queue(struct qlcnic_adapter *adapter)
+static void qlcnic_83xx_flush_mbx_queue(struct qlcnic_adapter *adapter)
 {
 	struct qlcnic_mailbox *mbx = adapter->ahw->mailbox;
 	struct list_head *head = &mbx->cmd_q;
@@ -3564,7 +3563,7 @@ static inline void qlcnic_83xx_flush_mbx_queue(struct qlcnic_adapter *adapter)
 	spin_unlock(&mbx->queue_lock);
 }
 
-static inline int qlcnic_83xx_check_mbx_status(struct qlcnic_adapter *adapter)
+static int qlcnic_83xx_check_mbx_status(struct qlcnic_adapter *adapter)
 {
 	struct qlcnic_hardware_context *ahw = adapter->ahw;
 	struct qlcnic_mailbox *mbx = ahw->mailbox;
@@ -3592,8 +3591,8 @@ static inline void qlcnic_83xx_signal_mbx_cmd(struct qlcnic_adapter *adapter,
 		QLCWRX(adapter->ahw, QLCNIC_FW_MBX_CTRL, QLCNIC_CLR_OWNER);
 }
 
-static inline void qlcnic_83xx_dequeue_mbx_cmd(struct qlcnic_adapter *adapter,
-					       struct qlcnic_cmd_args *cmd)
+static void qlcnic_83xx_dequeue_mbx_cmd(struct qlcnic_adapter *adapter,
+					struct qlcnic_cmd_args *cmd)
 {
 	struct qlcnic_mailbox *mbx = adapter->ahw->mailbox;
 
@@ -3653,9 +3652,9 @@ void qlcnic_83xx_detach_mailbox_work(struct qlcnic_adapter *adapter)
 	qlcnic_83xx_flush_mbx_queue(adapter);
 }
 
-static inline int qlcnic_83xx_enqueue_mbx_cmd(struct qlcnic_adapter *adapter,
-					      struct qlcnic_cmd_args *cmd,
-					      unsigned long *timeout)
+static int qlcnic_83xx_enqueue_mbx_cmd(struct qlcnic_adapter *adapter,
+				       struct qlcnic_cmd_args *cmd,
+				       unsigned long *timeout)
 {
 	struct qlcnic_mailbox *mbx = adapter->ahw->mailbox;
 
@@ -3680,8 +3679,8 @@ static inline int qlcnic_83xx_enqueue_mbx_cmd(struct qlcnic_adapter *adapter,
 	return -EBUSY;
 }
 
-static inline int qlcnic_83xx_check_mac_rcode(struct qlcnic_adapter *adapter,
-					      struct qlcnic_cmd_args *cmd)
+static int qlcnic_83xx_check_mac_rcode(struct qlcnic_adapter *adapter,
+				       struct qlcnic_cmd_args *cmd)
 {
 	u8 mac_cmd_rcode;
 	u32 fw_data;
diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_init.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_init.c
index a969ac2..6fac393 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_init.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_init.c
@@ -1950,8 +1950,8 @@ static void qlcnic_83xx_init_hw(struct qlcnic_adapter *p_dev)
 		dev_err(&p_dev->pdev->dev, "%s: failed\n", __func__);
 }
 
-static inline void qlcnic_83xx_get_fw_file_name(struct qlcnic_adapter *adapter,
-						char *file_name)
+static void qlcnic_83xx_get_fw_file_name(struct qlcnic_adapter *adapter,
+					 char *file_name)
 {
 	struct pci_dev *pdev = adapter->pdev;
 
diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
index df96f66..c99cee8 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
@@ -969,8 +969,8 @@ static int qlcnic_setup_pci_map(struct pci_dev *pdev,
 	return 0;
 }
 
-static inline bool qlcnic_validate_subsystem_id(struct qlcnic_adapter *adapter,
-						int index)
+static bool qlcnic_validate_subsystem_id(struct qlcnic_adapter *adapter,
+					 int index)
 {
 	struct pci_dev *pdev = adapter->pdev;
 	unsigned short subsystem_vendor;
diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_sriov_pf.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_sriov_pf.c
index 95b7710..a9bc651 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_sriov_pf.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_sriov_pf.c
@@ -1781,8 +1781,8 @@ int qlcnic_sriov_set_vf_vlan(struct net_device *netdev, int vf,
 	return 0;
 }
 
-static inline __u32 qlcnic_sriov_get_vf_vlan(struct qlcnic_adapter *adapter,
-					     struct qlcnic_vport *vp, int vf)
+static __u32 qlcnic_sriov_get_vf_vlan(struct qlcnic_adapter *adapter,
+				      struct qlcnic_vport *vp, int vf)
 {
 	__u32 vlan = 0;
 
-- 
1.5.6
