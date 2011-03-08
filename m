From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 09/14] ixgbe: Add x540 statistic counter definitions
Date: Mon,  7 Mar 2011 18:25:03 -0800
Message-ID: <1299551108-23663-10-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1299551108-23663-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Emil Tantilov <emil.s.tantilov@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, bphilips@novell.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:14586 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755968Ab1CHC0H (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 7 Mar 2011 21:26:07 -0500
In-Reply-To: <1299551108-23663-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Emil Tantilov <emil.s.tantilov@intel.com>

Add defines to accumulate and display x540 PHY statistic counters on
transmit/receive.

Signed-off-by: Emil Tantilov <emil.s.tantilov@intel.com>
Tested-by: Stephen Ko <stephen.s.ko@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ixgbe/ixgbe_common.c |    9 +++++++++
 drivers/net/ixgbe/ixgbe_type.h   |    5 +++++
 2 files changed, 14 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe_common.c b/drivers/net/ixgbe/ixgbe_common.c
index 85cc301..561f666 100644
--- a/drivers/net/ixgbe/ixgbe_common.c
+++ b/drivers/net/ixgbe/ixgbe_common.c
@@ -209,6 +209,15 @@ s32 ixgbe_clear_hw_cntrs_generic(struct ixgbe_hw *hw)
 		}
 	}
 
+	if (hw->mac.type == ixgbe_mac_X540) {
+		if (hw->phy.id == 0)
+			hw->phy.ops.identify(hw);
+		hw->phy.ops.read_reg(hw, 0x3, IXGBE_PCRC8ECL, &i);
+		hw->phy.ops.read_reg(hw, 0x3, IXGBE_PCRC8ECH, &i);
+		hw->phy.ops.read_reg(hw, 0x3, IXGBE_LDPCECL, &i);
+		hw->phy.ops.read_reg(hw, 0x3, IXGBE_LDPCECH, &i);
+	}
+
 	return 0;
 }
 
diff --git a/drivers/net/ixgbe/ixgbe_type.h b/drivers/net/ixgbe/ixgbe_type.h
index 13a45c7..76bf21b 100644
--- a/drivers/net/ixgbe/ixgbe_type.h
+++ b/drivers/net/ixgbe/ixgbe_type.h
@@ -671,6 +671,11 @@
 #define IXGBE_FCOEDWRC  0x0242C /* Number of FCoE DWords Received */
 #define IXGBE_FCOEPTC   0x08784 /* Number of FCoE Packets Transmitted */
 #define IXGBE_FCOEDWTC  0x08788 /* Number of FCoE DWords Transmitted */
+#define IXGBE_PCRC8ECL  0x0E810
+#define IXGBE_PCRC8ECH  0x0E811
+#define IXGBE_PCRC8ECH_MASK     0x1F
+#define IXGBE_LDPCECL   0x0E820
+#define IXGBE_LDPCECH   0x0E821
 
 /* Management */
 #define IXGBE_MAVTV(_i) (0x05010 + ((_i) * 4)) /* 8 of these (0-7) */
-- 
1.7.4

