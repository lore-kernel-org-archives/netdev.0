From: Babu Moger <babu.moger@oracle.com>
Subject: [PATCH v2] ixgbevf: Change the relaxed order settings in VF driver for sparc
Date: Thu, 21 Apr 2016 15:56:49 -0700
Message-ID: <1461279409-248697-1-git-send-email-babu.moger@oracle.com>
Cc: intel-wired-lan@lists.osuosl.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, babu.moger@oracle.com,
	sowmini.varadhan@oracle.com
To: jeffrey.t.kirsher@intel.com, jesse.brandeburg@intel.com,
	shannon.nelson@intel.com, carolyn.wyborny@intel.com,
	donald.c.skidmore@intel.com, bruce.w.allan@intel.com,
	john.ronciak@intel.com, mitch.a.williams@intel.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

We noticed performance issues with VF interface on sparc compared
to PF. Setting the RX to IXGBE_DCA_RXCTRL_DATA_WRO_EN brings it
on far with PF. Also this matches to the default sparc setting in
PF driver.

Signed-off-by: Babu Moger <babu.moger@oracle.com>
Acked-by: Sowmini Varadhan <sowmini.varadhan@oracle.com>
---
v2:
  Alexander had concerns about this negativily affecting other architectures.
  Added CONFIG_SPARC check so this should not affect other architectures.

 drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c |    6 ++++++
 1 files changed, 6 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c b/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
index 0ea14c0..3596e0b 100644
--- a/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
+++ b/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
@@ -1748,9 +1748,15 @@ static void ixgbevf_configure_rx_ring(struct ixgbevf_adapter *adapter,
 	IXGBE_WRITE_REG(hw, IXGBE_VFRDLEN(reg_idx),
 			ring->count * sizeof(union ixgbe_adv_rx_desc));
 
+#ifndef CONFIG_SPARC
 	/* enable relaxed ordering */
 	IXGBE_WRITE_REG(hw, IXGBE_VFDCA_RXCTRL(reg_idx),
 			IXGBE_DCA_RXCTRL_DESC_RRO_EN);
+#else
+	IXGBE_WRITE_REG(hw, IXGBE_VFDCA_RXCTRL(reg_idx),
+			IXGBE_DCA_RXCTRL_DESC_RRO_EN |
+			IXGBE_DCA_RXCTRL_DATA_WRO_EN);
+#endif
 
 	/* reset head and tail pointers */
 	IXGBE_WRITE_REG(hw, IXGBE_VFRDH(reg_idx), 0);
-- 
1.7.1
