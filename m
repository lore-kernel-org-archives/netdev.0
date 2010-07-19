From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 PATCH 1/5] ixgbe: dcb, set DPF bit when PFC is enabled
Date: Mon, 19 Jul 2010 16:59:03 -0700
Message-ID: <20100719235831.14112.14175.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com, bphilips@novell.com,
	John Fastabend <john.r.fastabend@intel.com>,
	Don Skidmore <donald.c.skidmore@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta04.emeryville.ca.mail.comcast.net ([76.96.30.40]:43645 "EHLO
	qmta04.emeryville.ca.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1760911Ab0GSX7Z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Jul 2010 19:59:25 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: John Fastabend <john.r.fastabend@intel.com>

Set the DPF bit when PFC is enabled.  This will discard
PFC frames so they do not get passed up the stack.

The DPF bit is set for flow control, but not priority
flow control this brings pfc inline with fc.

Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
Signed-off-by: Don Skidmore <donald.c.skidmore@intel.com>
Tested-by: Ross Brattain <ross.b.brattain@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/ixgbe/ixgbe_dcb_82599.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe_dcb_82599.c b/drivers/net/ixgbe/ixgbe_dcb_82599.c
index 4f7a26a..25b02fb 100644
--- a/drivers/net/ixgbe/ixgbe_dcb_82599.c
+++ b/drivers/net/ixgbe/ixgbe_dcb_82599.c
@@ -346,7 +346,7 @@ s32 ixgbe_dcb_config_pfc_82599(struct ixgbe_hw *hw,
 	 */
 	reg = IXGBE_READ_REG(hw, IXGBE_MFLCN);
 	reg &= ~IXGBE_MFLCN_RFCE;
-	reg |= IXGBE_MFLCN_RPFCE;
+	reg |= IXGBE_MFLCN_RPFCE | IXGBE_MFLCN_DPF;
 	IXGBE_WRITE_REG(hw, IXGBE_MFLCN, reg);
 out:
 	return 0;

