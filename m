From: Sathya Perla <sathya.perla@emulex.com>
Subject: [PATCH 4/4] qlcnic: remove pci_assigned_vfs() check while disabling VFs
Date: Mon, 10 Nov 2014 17:23:30 +0530
Message-ID: <1415620410-4937-5-git-send-email-sathya.perla@emulex.com>
References: <1415620410-4937-1-git-send-email-sathya.perla@emulex.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <ariel.elior@qlogic.com>, <linux.nics@intel.com>,
	<shahed.shaikh@qlogic.com>, <ddutile@redhat.com>
To: <linux-pci@vger.kernel.org>, <netdev@vger.kernel.org>
Return-path: <linux-pci-owner@vger.kernel.org>
In-Reply-To: <1415620410-4937-1-git-send-email-sathya.perla@emulex.com>
Sender: linux-pci-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Vasundhara Volam <vasundhara.volam@emulex.com>

The pci_assigned_vfs() check (while disabling VFs) is being moved to the
pci-sysfs.c file and will be done before invoking sriov_configure().

Signed-off-by: Vasundhara Volam <vasundhara.volam@emulex.com>
Signed-off-by: Sathya Perla <sathya.perla@emulex.com>
---
 .../net/ethernet/qlogic/qlcnic/qlcnic_sriov_pf.c   |   10 ----------
 1 files changed, 0 insertions(+), 10 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_sriov_pf.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_sriov_pf.c
index a29538b..9802914 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_sriov_pf.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_sriov_pf.c
@@ -465,16 +465,6 @@ static int qlcnic_pci_sriov_disable(struct qlcnic_adapter *adapter)
 {
 	struct net_device *netdev = adapter->netdev;
 
-	if (pci_vfs_assigned(adapter->pdev)) {
-		netdev_err(adapter->netdev,
-			   "SR-IOV VFs belonging to port %d are assigned to VMs. SR-IOV can not be disabled on this port\n",
-			   adapter->portnum);
-		netdev_info(adapter->netdev,
-			    "Please detach SR-IOV VFs belonging to port %d from VMs, and then try to disable SR-IOV on this port\n",
-			    adapter->portnum);
-		return -EPERM;
-	}
-
 	qlcnic_sriov_pf_disable(adapter);
 
 	rtnl_lock();
-- 
1.7.1
