From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [PATCH 3/8] igb: fixes 82576 serdes init to correctly support manual
	flow control changes
Date: Fri, 01 Aug 2008 16:11:20 -0700
Message-ID: <20080801231120.393.85939.stgit@localhost.localdomain>
References: <20080801231106.393.46174.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	akpm@linux-foundation.org,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:54771 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751819AbYHAXLV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 1 Aug 2008 19:11:21 -0400
In-Reply-To: <20080801231106.393.46174.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

This patch changes the PCS configuration for serdes so that the flow
control options change be set via the ethtool -A option.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/igb/e1000_82575.c   |    6 ++++++
 drivers/net/igb/e1000_defines.h |    1 +
 2 files changed, 7 insertions(+), 0 deletions(-)

diff --git a/drivers/net/igb/e1000_82575.c b/drivers/net/igb/e1000_82575.c
index f3d7be0..cd75a2b 100644
--- a/drivers/net/igb/e1000_82575.c
+++ b/drivers/net/igb/e1000_82575.c
@@ -1136,6 +1136,12 @@ static s32 igb_setup_fiber_serdes_link_82575(struct e1000_hw *hw)
 		       E1000_PCS_LCTL_FORCE_LINK;     /* Force Link */
 		hw_dbg("Configuring Forced Link; PCS_LCTL = 0x%08X\n", reg);
 	}
+
+	if (hw->mac.type == e1000_82576) {
+		reg |= E1000_PCS_LCTL_FORCE_FCTRL;
+		igb_force_mac_fc(hw);
+	}
+
 	wr32(E1000_PCS_LCTL, reg);
 
 	return 0;
diff --git a/drivers/net/igb/e1000_defines.h b/drivers/net/igb/e1000_defines.h
index afdba3c..ce70068 100644
--- a/drivers/net/igb/e1000_defines.h
+++ b/drivers/net/igb/e1000_defines.h
@@ -257,6 +257,7 @@
 #define E1000_PCS_LCTL_FDV_FULL          8
 #define E1000_PCS_LCTL_FSD               0x10
 #define E1000_PCS_LCTL_FORCE_LINK        0x20
+#define E1000_PCS_LCTL_FORCE_FCTRL       0x80
 #define E1000_PCS_LCTL_AN_ENABLE         0x10000
 #define E1000_PCS_LCTL_AN_RESTART        0x20000
 #define E1000_PCS_LCTL_AN_TIMEOUT        0x40000

