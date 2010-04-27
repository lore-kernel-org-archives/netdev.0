From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 PATCH] ixgbevf: Fix link speed display
Date: Tue, 27 Apr 2010 14:31:45 -0700
Message-ID: <20100427213143.25913.83381.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Greg Rose <gregory.v.rose@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta07.emeryville.ca.mail.comcast.net ([76.96.30.64]:52588 "EHLO
	qmta07.emeryville.ca.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757159Ab0D0VcE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Apr 2010 17:32:04 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Greg Rose <gregory.v.rose@intel.com>

The ixgbevf driver would always report 10Gig speeds even when the link
speed is downshifted to 1Gig.  This patch fixes that problem.

Signed-off-by: Greg Rose <gregory.v.rose@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/ixgbevf/defines.h |   12 +++++++-----
 drivers/net/ixgbevf/vf.c      |    3 ++-
 2 files changed, 9 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ixgbevf/defines.h b/drivers/net/ixgbevf/defines.h
index c44fdb0..ca2c81f 100644
--- a/drivers/net/ixgbevf/defines.h
+++ b/drivers/net/ixgbevf/defines.h
@@ -41,11 +41,13 @@ typedef u32 ixgbe_link_speed;
 #define IXGBE_LINK_SPEED_1GB_FULL       0x0020
 #define IXGBE_LINK_SPEED_10GB_FULL      0x0080
 
-#define IXGBE_CTRL_RST          0x04000000 /* Reset (SW) */
-#define IXGBE_RXDCTL_ENABLE     0x02000000 /* Enable specific Rx Queue */
-#define IXGBE_TXDCTL_ENABLE     0x02000000 /* Enable specific Tx Queue */
-#define IXGBE_LINKS_UP          0x40000000
-#define IXGBE_LINKS_SPEED       0x20000000
+#define IXGBE_CTRL_RST              0x04000000 /* Reset (SW) */
+#define IXGBE_RXDCTL_ENABLE         0x02000000 /* Enable specific Rx Queue */
+#define IXGBE_TXDCTL_ENABLE         0x02000000 /* Enable specific Tx Queue */
+#define IXGBE_LINKS_UP              0x40000000
+#define IXGBE_LINKS_SPEED_82599     0x30000000
+#define IXGBE_LINKS_SPEED_10G_82599 0x30000000
+#define IXGBE_LINKS_SPEED_1G_82599  0x20000000
 
 /* Number of Transmit and Receive Descriptors must be a multiple of 8 */
 #define IXGBE_REQ_TX_DESCRIPTOR_MULTIPLE  8
diff --git a/drivers/net/ixgbevf/vf.c b/drivers/net/ixgbevf/vf.c
index 852e9c4..f6f9299 100644
--- a/drivers/net/ixgbevf/vf.c
+++ b/drivers/net/ixgbevf/vf.c
@@ -359,7 +359,8 @@ static s32 ixgbevf_check_mac_link_vf(struct ixgbe_hw *hw,
 	else
 		*link_up = false;
 
-	if (links_reg & IXGBE_LINKS_SPEED)
+	if ((links_reg & IXGBE_LINKS_SPEED_82599) ==
+	    IXGBE_LINKS_SPEED_10G_82599)
 		*speed = IXGBE_LINK_SPEED_10GB_FULL;
 	else
 		*speed = IXGBE_LINK_SPEED_1GB_FULL;

