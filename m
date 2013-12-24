From: Ethan Zhao <ethan.kernel@gmail.com>
Subject: [PATCH 1/2 v2] ixgbe: define IXGBE_MAX_VFS_DRV_LIMIT macro and cleanup const 63
Date: Wed, 25 Dec 2013 00:12:48 +0800
Message-ID: <1387901568-1762-1-git-send-email-ethan.kernel@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, Ethan Zhao <ethan.kernel@gmail.com>
To: jeffrey.t.kirsher@intel.com, jesse.brandeburg@intel.com,
	bruce.w.allan@intel.com, carolyn.wyborny@intel.com,
	davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Because ixgbe driver limit the max number of VF functions could be enab=
led
to 63, so define one macro IXGBE_MAX_VFS_DRV_LIMIT and cleanup the cons=
t 63
in code.

v2: fix a typo.

Signed-off-by: Ethan Zhao <ethan.kernel@gmail.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c  | 4 ++--
 drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c | 5 +++--
 drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.h | 5 +++++
 3 files changed, 10 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/ne=
t/ethernet/intel/ixgbe/ixgbe_main.c
index 0ade0cd..47e9b44 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -4818,7 +4818,7 @@ static int ixgbe_sw_init(struct ixgbe_adapter *ad=
apter)
 #ifdef CONFIG_PCI_IOV
 	/* assign number of SR-IOV VFs */
 	if (hw->mac.type !=3D ixgbe_mac_82598EB)
-		adapter->num_vfs =3D (max_vfs > 63) ? 0 : max_vfs;
+		adapter->num_vfs =3D (max_vfs > IXGBE_MAX_VFS_DRV_LIMIT) ? 0 : max_v=
fs;
=20
 #endif
 	/* enable itr by default in dynamic mode */
@@ -7640,7 +7640,7 @@ static int ixgbe_probe(struct pci_dev *pdev, cons=
t struct pci_device_id *ent)
 	ixgbe_init_mbx_params_pf(hw);
 	memcpy(&hw->mbx.ops, ii->mbx_ops, sizeof(hw->mbx.ops));
 	ixgbe_enable_sriov(adapter);
-	pci_sriov_set_totalvfs(pdev, 63);
+	pci_sriov_set_totalvfs(pdev, IXGBE_MAX_VFS_DRV_LIMIT);
 skip_sriov:
=20
 #endif
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c b/drivers/n=
et/ethernet/intel/ixgbe/ixgbe_sriov.c
index 276d7b1..6925979 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c
@@ -152,7 +152,8 @@ void ixgbe_enable_sriov(struct ixgbe_adapter *adapt=
er)
 		 * physical function.  If the user requests greater thn
 		 * 63 VFs then it is an error - reset to default of zero.
 		 */
-		adapter->num_vfs =3D min_t(unsigned int, adapter->num_vfs, 63);
+		adapter->num_vfs =3D min_t(unsigned int,
+					adapter->num_vfs, IXGBE_MAX_VFS_DRV_LIMIT);
=20
 		err =3D pci_enable_sriov(adapter->pdev, adapter->num_vfs);
 		if (err) {
@@ -259,7 +260,7 @@ static int ixgbe_pci_sriov_enable(struct pci_dev *d=
ev, int num_vfs)
 	 * PF.  The PCI bus driver already checks for other values out of
 	 * range.
 	 */
-	if (num_vfs > 63) {
+	if (num_vfs > IXGBE_MAX_VFS_DRV_LIMIT) {
 		err =3D -EPERM;
 		goto err_out;
 	}
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.h b/drivers/n=
et/ethernet/intel/ixgbe/ixgbe_sriov.h
index 4713f9f..2593666 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.h
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.h
@@ -28,6 +28,11 @@
 #ifndef _IXGBE_SRIOV_H_
 #define _IXGBE_SRIOV_H_
=20
+/*  ixgbe driver limit the max number of VFs could be enabled to
+ *  63 (IXGBE_MAX_VF_FUNCTIONS=EF=BC=8D1)
+ */
+#define IXGBE_MAX_VFS_DRV_LIMIT  (IXGBE_MAX_VF_FUNCTIONS=EF=BC=8D1)
+
 void ixgbe_restore_vf_multicasts(struct ixgbe_adapter *adapter);
 void ixgbe_msg_task(struct ixgbe_adapter *adapter);
 int ixgbe_vf_configuration(struct pci_dev *pdev, unsigned int event_ma=
sk);
--=20
1.8.3.4 (Apple Git-47)
