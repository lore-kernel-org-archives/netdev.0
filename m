From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 PATCH 2/4] ixgbe: Make sure boolean assignments from
	bitwise operations done correctly
Date: Thu, 16 Jul 2009 18:50:32 -0700
Message-ID: <20090717015032.24074.41324.stgit@localhost.localdomain>
References: <20090717014951.24074.75893.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta02.westchester.pa.mail.comcast.net ([76.96.62.24]:48511
	"EHLO QMTA02.westchester.pa.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S933959AbZGQBuu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Jul 2009 21:50:50 -0400
In-Reply-To: <20090717014951.24074.75893.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>

When the link comes up, the driver detects which flow control settings are
active.  This is done using bitwise operations directly from the hardware
registers, and assumes the proper boolean assignment.  Make this an
explicit boolean value before assignment to the bool.

Signed-off-by: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/ixgbe/ixgbe_main.c |    8 ++++----
 1 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
index e3442f4..09394c1 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -4643,13 +4643,13 @@ static void ixgbe_watchdog_task(struct work_struct *work)
 			if (hw->mac.type == ixgbe_mac_82599EB) {
 				u32 mflcn = IXGBE_READ_REG(hw, IXGBE_MFLCN);
 				u32 fccfg = IXGBE_READ_REG(hw, IXGBE_FCCFG);
-				flow_rx = (mflcn & IXGBE_MFLCN_RFCE);
-				flow_tx = (fccfg & IXGBE_FCCFG_TFCE_802_3X);
+				flow_rx = !!(mflcn & IXGBE_MFLCN_RFCE);
+				flow_tx = !!(fccfg & IXGBE_FCCFG_TFCE_802_3X);
 			} else {
 				u32 frctl = IXGBE_READ_REG(hw, IXGBE_FCTRL);
 				u32 rmcs = IXGBE_READ_REG(hw, IXGBE_RMCS);
-				flow_rx = (frctl & IXGBE_FCTRL_RFCE);
-				flow_tx = (rmcs & IXGBE_RMCS_TFCE_802_3X);
+				flow_rx = !!(frctl & IXGBE_FCTRL_RFCE);
+				flow_tx = !!(rmcs & IXGBE_RMCS_TFCE_802_3X);
 			}
 
 			printk(KERN_INFO "ixgbe: %s NIC Link is Up %s, "

