From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net 1/2] ixgbe: Fix Tx Hang issue with lldpad on 82598EB
Date: Fri, 26 Jul 2013 05:46:35 -0700
Message-ID: <1374842796-28445-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jacob Keller <jacob.e.keller@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Stable <stable@vger.kernel.org>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <stable-owner@vger.kernel.org>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jacob Keller <jacob.e.keller@intel.com>

This patch fixes an issue with the 82598EB device, where lldpad is causing Tx
Hangs on the card as soon as it attempts to configure DCB for the device. The
adapter will continually Tx hang and reset in a loop.

Signed-off-by: Jacob Keller <jacob.e.keller@intel.com>
Cc: Stable <stable@vger.kernel.org>
Tested-by: Phil Schmitt <phillip.j.schmitt@intel.com>
Tested-by: Jack Morgan <jack.morgan@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_dcb_82598.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_dcb_82598.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_dcb_82598.c
index ac78077..7a77f37 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_dcb_82598.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_dcb_82598.c
@@ -108,9 +108,8 @@ s32 ixgbe_dcb_config_tx_desc_arbiter_82598(struct ixgbe_hw *hw,
 
 	/* Enable arbiter */
 	reg &= ~IXGBE_DPMCS_ARBDIS;
-	/* Enable DFP and Recycle mode */
-	reg |= (IXGBE_DPMCS_TDPAC | IXGBE_DPMCS_TRM);
 	reg |= IXGBE_DPMCS_TSOEF;
+
 	/* Configure Max TSO packet size 34KB including payload and headers */
 	reg |= (0x4 << IXGBE_DPMCS_MTSOS_SHIFT);
 
-- 
1.7.11.7
