From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 PATCH 12/20] ixgbe: remove redundant configuration of
	vmolr, rename generic variable
Date: Thu, 19 Aug 2010 16:37:48 -0700
Message-ID: <20100819233745.10335.58155.stgit@localhost.localdomain>
References: <20100819233052.10335.13176.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com, bphilips@novell.com,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta11.westchester.pa.mail.comcast.net ([76.96.59.211]:60179
	"EHLO QMTA11.westchester.pa.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752336Ab0HSXiI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Aug 2010 19:38:08 -0400
In-Reply-To: <20100819233052.10335.13176.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

The vmolr is configured already in ixgbe_set_rx_mode for the PF so there is
no need to set it again in ixgbe_configure_rx.

Instead of using the variable name reg, it is easier to just rename it to
gcr_ext to reflect the register contents that the variable holds.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/ixgbe/ixgbe_main.c |   11 ++++-------
 1 files changed, 4 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
index b755364..520b95f 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -2709,7 +2709,7 @@ static void ixgbe_configure_rx(struct ixgbe_adapter *adapter)
 	int max_frame = netdev->mtu + ETH_HLEN + ETH_FCS_LEN;
 	int i;
 	u32 rxctrl;
-	u32 hlreg0;
+	u32 hlreg0, gcr_ext;
 	u32 rdrxctl;
 	int rx_buf_len;
 
@@ -2813,24 +2813,21 @@ static void ixgbe_configure_rx(struct ixgbe_adapter *adapter)
 		IXGBE_WRITE_REG(hw, IXGBE_VFRE(reg_offset), (1 << vf_shift));
 		IXGBE_WRITE_REG(hw, IXGBE_VFTE(reg_offset), (1 << vf_shift));
 		IXGBE_WRITE_REG(hw, IXGBE_PFDTXGSWC, IXGBE_PFDTXGSWC_VT_LBEN);
-		ixgbe_set_vmolr(hw, adapter->num_vfs, true);
 	}
 
 	/* Program MRQC for the distribution of queues */
 	ixgbe_setup_mrqc(adapter);
 
 	if (adapter->num_vfs) {
-		u32 reg;
-
 		/* Map PF MAC address in RAR Entry 0 to first pool
 		 * following VFs */
 		hw->mac.ops.set_vmdq(hw, 0, adapter->num_vfs);
 
 		/* Set up VF register offsets for selected VT Mode, i.e.
 		 * 64 VFs for SR-IOV */
-		reg = IXGBE_READ_REG(hw, IXGBE_GCR_EXT);
-		reg |= IXGBE_GCR_EXT_SRIOV;
-		IXGBE_WRITE_REG(hw, IXGBE_GCR_EXT, reg);
+		gcr_ext = IXGBE_READ_REG(hw, IXGBE_GCR_EXT);
+		gcr_ext |= IXGBE_GCR_EXT_SRIOV;
+		IXGBE_WRITE_REG(hw, IXGBE_GCR_EXT, gcr_ext);
 	}
 
 	if (hw->mac.type == ixgbe_mac_82599EB) {

