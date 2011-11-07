From: Greg Rose <gregory.v.rose@intel.com>
Subject: [net-ext PATCH] ixgbe: Fix compile for kernel without CONFIG_PCI_IOV
	defined
Date: Mon, 07 Nov 2011 09:44:17 -0800
Message-ID: <20111107174417.8638.87569.stgit@gitlad.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:34247 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755812Ab1KGRoU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 7 Nov 2011 12:44:20 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fix compiler errors and warnings with CONFIG_PCI_IOV defined and not
defined.

Signed-off-by: Greg Rose <gregory.v.rose@intel.com>
---

 drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c |    2 ++
 drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.h |    4 ++--
 2 files changed, 4 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c
index db95731..00fcd39 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c
@@ -442,12 +442,14 @@ static int ixgbe_set_vf_macvlan(struct ixgbe_adapter *adapter,
 
 int ixgbe_check_vf_assignment(struct ixgbe_adapter *adapter)
 {
+#ifdef CONFIG_PCI_IOV
 	int i;
 	for (i = 0; i < adapter->num_vfs; i++) {
 		if (adapter->vfinfo[i].vfdev->dev_flags &
 				PCI_DEV_FLAGS_ASSIGNED)
 			return true;
 	}
+#endif
 	return false;
 }
 
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.h b/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.h
index 4a5d889..df04f1a 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.h
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.h
@@ -42,11 +42,11 @@ int ixgbe_ndo_set_vf_spoofchk(struct net_device *netdev, int vf, bool setting);
 int ixgbe_ndo_get_vf_config(struct net_device *netdev,
 			    int vf, struct ifla_vf_info *ivi);
 void ixgbe_check_vf_rate_limit(struct ixgbe_adapter *adapter);
-#ifdef CONFIG_PCI_IOV
 void ixgbe_disable_sriov(struct ixgbe_adapter *adapter);
+int ixgbe_check_vf_assignment(struct ixgbe_adapter *adapter);
+#ifdef CONFIG_PCI_IOV
 void ixgbe_enable_sriov(struct ixgbe_adapter *adapter,
 			const struct ixgbe_info *ii);
-int ixgbe_check_vf_assignment(struct ixgbe_adapter *adapter);
 #endif
 
 
