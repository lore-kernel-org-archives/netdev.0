From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-2.6 PATCH] ixgbe: Fix compiler warning about variable being used
	uninitialized
Date: Wed, 06 Jan 2010 19:50:29 -0800
Message-ID: <20100107035001.28341.55395.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta01.westchester.pa.mail.comcast.net ([76.96.62.16]:41692
	"EHLO QMTA01.westchester.pa.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755903Ab0AGDus (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Jan 2010 22:50:48 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: PJ Waskiewicz <peter.p.waskiewicz.jr@intel.com>

tc is still throwing a warning that is could be used
uninitialized.  This fixes it, and properly formats the device ID
checks for the use of this variable.

Signed-off-by: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/ixgbe/ixgbe_main.c |    9 +++++++--
 1 files changed, 7 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
index 1a2ea62..2ad754c 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -262,10 +262,12 @@ static inline bool ixgbe_tx_is_paused(struct ixgbe_adapter *adapter,
 		int reg_idx = tx_ring->reg_idx;
 		int dcb_i = adapter->ring_feature[RING_F_DCB].indices;
 
-		if (adapter->hw.mac.type == ixgbe_mac_82598EB) {
+		switch (adapter->hw.mac.type) {
+		case ixgbe_mac_82598EB:
 			tc = reg_idx >> 2;
 			txoff = IXGBE_TFCS_TXOFF0;
-		} else if (adapter->hw.mac.type == ixgbe_mac_82599EB) {
+			break;
+		case ixgbe_mac_82599EB:
 			tc = 0;
 			txoff = IXGBE_TFCS_TXOFF;
 			if (dcb_i == 8) {
@@ -284,6 +286,9 @@ static inline bool ixgbe_tx_is_paused(struct ixgbe_adapter *adapter,
 						tc += (reg_idx - 96) >> 4;
 				}
 			}
+			break;
+		default:
+			tc = 0;
 		}
 		txoff <<= tc;
 	}

