From: Yuval Mintz <Yuval.Mintz@qlogic.com>
Subject: [PATCH net-next] bnx2x: Fix compilation when CONFIG_BNX2X_SRIOV is not set
Date: Thu, 30 Jul 2015 14:30:29 +0300
Message-ID: <1438255829-27326-1-git-send-email-Yuval.Mintz@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <fengguang.wu@intel.com>, Yuval Mintz <Yuval.Mintz@qlogic.com>,
	Ariel Elior <Ariel.Elior@qlogic.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-0016ce01.pphosted.com ([67.231.148.157]:14250 "EHLO
	mx0a-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750877AbbG3Lax (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Jul 2015 07:30:53 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit 05cc5a39ddb7 ("bnx2x: add vlan filtering offload") has broken
compilation when CONFIG_BNX2X_SRIOV is not set.

Signed-off-by: Yuval Mintz <Yuval.Mintz@qlogic.com>
Signed-off-by: Ariel Elior <Ariel.Elior@qlogic.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c  | 2 ++
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.h | 5 +++++
 2 files changed, 7 insertions(+)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
index 96ad9ec..31c63aa 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
@@ -13091,8 +13091,10 @@ static int bnx2x_init_dev(struct bnx2x *bp, struct pci_dev *pdev,
 			bp->accept_any_vlan = true;
 		else
 			dev->hw_features |= NETIF_F_HW_VLAN_CTAG_FILTER;
+#ifdef CONFIG_BNX2X_SRIOV
 	} else if (bp->acquire_resp.pfdev_info.pf_cap & PFVF_CAP_VLAN_FILTER) {
 		dev->hw_features |= NETIF_F_HW_VLAN_CTAG_FILTER;
+#endif
 	}
 
 	dev->features |= dev->hw_features | NETIF_F_HW_VLAN_CTAG_RX;
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.h b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.h
index 01f3643..670a581 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.h
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.h
@@ -551,6 +551,11 @@ int bnx2x_set_vf_link_state(struct net_device *dev, int vf, int link_state);
 int bnx2x_vfpf_update_vlan(struct bnx2x *bp, u16 vid, u8 vf_qid, bool add);
 #else /* CONFIG_BNX2X_SRIOV */
 
+#define GET_NUM_VFS_PER_PATH(bp)	0
+#define GET_NUM_VFS_PER_PF(bp)		0
+#define VF_MAC_CREDIT_CNT		0
+#define VF_VLAN_CREDIT_CNT		0
+
 static inline void bnx2x_iov_set_queue_sp_obj(struct bnx2x *bp, int vf_cid,
 				struct bnx2x_queue_sp_obj **q_obj) {}
 static inline void bnx2x_vf_handle_flr_event(struct bnx2x *bp) {}
-- 
1.9.3
