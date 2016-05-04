From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 11/14] ixgbevf: Change the relaxed order settings in VF driver for sparc
Date: Wed,  4 May 2016 09:26:45 -0700
Message-ID: <1462379208-3997-12-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1462379208-3997-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Babu Moger <babu.moger@oracle.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:42556 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753547AbcEDQ1P (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 4 May 2016 12:27:15 -0400
In-Reply-To: <1462379208-3997-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Babu Moger <babu.moger@oracle.com>

We noticed performance issues with VF interface on sparc compared
to PF. Setting the RX to IXGBE_DCA_RXCTRL_DATA_WRO_EN brings it
on far with PF. Also this matches to the default sparc setting in
PF driver.

Signed-off-by: Babu Moger <babu.moger@oracle.com>
Acked-by: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c | 6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c b/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
index f39c8cb..14d4729 100644
--- a/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
+++ b/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
@@ -1760,9 +1760,15 @@ static void ixgbevf_configure_rx_ring(struct ixgbevf_adapter *adapter,
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
2.5.5
