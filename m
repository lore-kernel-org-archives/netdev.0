From: dan.streetman@canonical.com
Subject: [PATCH] ixgbe: Wait for 1ms, not 1us, after RST
Date: Mon, 26 Oct 2015 20:16:11 -0400
Message-ID: <1445904971-9442-1-git-send-email-dan.streetman@canonical.com>
Cc: Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Shannon Nelson <shannon.nelson@intel.com>,
	Carolyn Wyborny <carolyn.wyborny@intel.com>,
	Don Skidmore <donald.c.skidmore@intel.com>,
	Matthew Vick <matthew.vick@intel.com>,
	John Ronciak <john.ronciak@intel.com>,
	Mitch Williams <mitch.a.williams@intel.com>,
	intel-wired-lan@lists.osuosl.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Dan Streetman <dan.streetman@canonical.com>,
	Dan Streetman <ddstreet@ieee.org>
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Dan Streetman <dan.streetman@canonical.com>

The driver currently waits 1us after issuing a RST, but the spec
requires it to wait 1ms.

Signed-off-by: Dan Streetman <dan.streetman@canonical.com>
Signed-off-by: Dan Streetman <ddstreet@ieee.org>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_x540.c | 7 ++++++-
 1 file changed, 6 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_x540.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_x540.c
index 4e75843..147bc65 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_x540.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_x540.c
@@ -113,7 +113,12 @@ mac_reset_top:
 
 	/* Poll for reset bit to self-clear indicating reset is complete */
 	for (i = 0; i < 10; i++) {
-		udelay(1);
+		/* sec 8.2.4.1.1 :
+		 * programmers must wait approximately 1 ms after setting before
+		 * attempting to check if the bit has cleared or to access (read
+		 * or write) any other device register.
+		 */
+		mdelay(1);
 		ctrl = IXGBE_READ_REG(hw, IXGBE_CTRL);
 		if (!(ctrl & IXGBE_CTRL_RST_MASK))
 			break;
-- 
2.5.0
