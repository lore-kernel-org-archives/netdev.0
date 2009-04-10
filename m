From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [PATCH 05/10] ixgbe: Don't return error in flow control configuration
	if FC is off
Date: Fri, 10 Apr 2009 01:27:39 -0700
Message-ID: <20090410082739.14372.71625.stgit@localhost.localdomain>
References: <20090410082618.14372.86091.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta05.emeryville.ca.mail.comcast.net ([76.96.30.48]:36231 "EHLO
	QMTA05.emeryville.ca.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S938332AbZDJQ4H (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Apr 2009 12:56:07 -0400
In-Reply-To: <20090410082618.14372.86091.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: PJ Waskiewicz <peter.p.waskiewicz.jr@intel.com>

When flow control is disabled, an invalid low/high watermark configuration
should not matter.

Signed-off-by: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/ixgbe/ixgbe_82598.c  |    8 +++++---
 drivers/net/ixgbe/ixgbe_common.c |    8 +++++---
 2 files changed, 10 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe_82598.c b/drivers/net/ixgbe/ixgbe_82598.c
index 982783c..6e2a837 100644
--- a/drivers/net/ixgbe/ixgbe_82598.c
+++ b/drivers/net/ixgbe/ixgbe_82598.c
@@ -381,9 +381,11 @@ static s32 ixgbe_setup_fc_82598(struct ixgbe_hw *hw, s32 packetbuf_num)
 	 * because it causes the controller to just blast out fc packets.
 	 */
 	if (!hw->fc.low_water || !hw->fc.high_water || !hw->fc.pause_time) {
-		hw_dbg(hw, "Invalid water mark configuration\n");
-		ret_val = IXGBE_ERR_INVALID_LINK_SETTINGS;
-		goto out;
+		if (hw->fc.requested_mode != ixgbe_fc_none) {
+			hw_dbg(hw, "Invalid water mark configuration\n");
+			ret_val = IXGBE_ERR_INVALID_LINK_SETTINGS;
+			goto out;
+		}
 	}
 
 	/*
diff --git a/drivers/net/ixgbe/ixgbe_common.c b/drivers/net/ixgbe/ixgbe_common.c
index c1b9045..5f2ee34 100644
--- a/drivers/net/ixgbe/ixgbe_common.c
+++ b/drivers/net/ixgbe/ixgbe_common.c
@@ -1907,9 +1907,11 @@ s32 ixgbe_setup_fc_generic(struct ixgbe_hw *hw, s32 packetbuf_num)
 	 * because it causes the controller to just blast out fc packets.
 	 */
 	if (!hw->fc.low_water || !hw->fc.high_water || !hw->fc.pause_time) {
-		hw_dbg(hw, "Invalid water mark configuration\n");
-		ret_val = IXGBE_ERR_INVALID_LINK_SETTINGS;
-		goto out;
+		if (hw->fc.requested_mode != ixgbe_fc_none) {
+			hw_dbg(hw, "Invalid water mark configuration\n");
+			ret_val = IXGBE_ERR_INVALID_LINK_SETTINGS;
+			goto out;
+		}
 	}
 
 	/*

