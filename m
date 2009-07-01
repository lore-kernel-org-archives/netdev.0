From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-2.6 PATCH 1/6] e1000e: PHY loopback broken on 82578
Date: Wed, 01 Jul 2009 16:27:31 -0700
Message-ID: <20090701232731.20555.63487.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Bruce Allan <bruce.w.allan@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta05.emeryville.ca.mail.comcast.net ([76.96.30.48]:54020 "EHLO
	QMTA05.emeryville.ca.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752504AbZGAX1u (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Jul 2009 19:27:50 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Bruce Allan <bruce.w.allan@intel.com>

PHY loopback on 82578 fails to work as a result of flushing the packets
in the FIFO buffer in the link stall workaround.  Don't perform the
workaround if in PHY loopback mode.


Signed-off-by: Bruce Allan <bruce.w.allan@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/e1000e/defines.h |    2 ++
 drivers/net/e1000e/phy.c     |    5 +++++
 2 files changed, 7 insertions(+), 0 deletions(-)

diff --git a/drivers/net/e1000e/defines.h b/drivers/net/e1000e/defines.h
index 8890c97..4329ec3 100644
--- a/drivers/net/e1000e/defines.h
+++ b/drivers/net/e1000e/defines.h
@@ -575,6 +575,8 @@
 #define PHY_1000T_STATUS 0x0A /* 1000Base-T Status Reg */
 #define PHY_EXT_STATUS   0x0F /* Extended Status Reg */
 
+#define PHY_CONTROL_LB   0x4000 /* PHY Loopback bit */
+
 /* NVM Control */
 #define E1000_EECD_SK        0x00000001 /* NVM Clock */
 #define E1000_EECD_CS        0x00000002 /* NVM Chip Select */
diff --git a/drivers/net/e1000e/phy.c b/drivers/net/e1000e/phy.c
index e23459c..d845394 100644
--- a/drivers/net/e1000e/phy.c
+++ b/drivers/net/e1000e/phy.c
@@ -2737,6 +2737,11 @@ s32 e1000_link_stall_workaround_hv(struct e1000_hw *hw)
 	if (hw->phy.type != e1000_phy_82578)
 		goto out;
 
+	/* Do not apply workaround if in PHY loopback bit 14 set */
+	hw->phy.ops.read_phy_reg(hw, PHY_CONTROL, &data);
+	if (data & PHY_CONTROL_LB)
+		goto out;
+
 	/* check if link is up and at 1Gbps */
 	ret_val = hw->phy.ops.read_phy_reg(hw, BM_CS_STATUS, &data);
 	if (ret_val)

