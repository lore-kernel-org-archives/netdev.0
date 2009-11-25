From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 PATCH 2/4] ixgbe: Disable Flow Control for certain
	devices
Date: Tue, 24 Nov 2009 20:51:28 -0800
Message-ID: <20091125045127.23932.79040.stgit@localhost.localdomain>
References: <20091125045059.23932.10997.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta02.westchester.pa.mail.comcast.net ([76.96.62.24]:55720
	"EHLO QMTA02.westchester.pa.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S934501AbZKYEvk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Nov 2009 23:51:40 -0500
In-Reply-To: <20091125045059.23932.10997.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: PJ Waskiewicz <peter.p.waskiewicz.jr@intel.com>

Flow Control autoneg should be disabled for certain adapters
that don't support autonegotiation of Flow Control at 10 gigabit.
These interfaces are the 10GBASE-T devices, CX4, and SFP+, all
running at 10 gigabit only.  1 gigabit is fine.

Signed-off-by: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/ixgbe/ixgbe_common.c |   14 ++++++++++++++
 1 files changed, 14 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe_common.c b/drivers/net/ixgbe/ixgbe_common.c
index 40ff120..f42a954 100644
--- a/drivers/net/ixgbe/ixgbe_common.c
+++ b/drivers/net/ixgbe/ixgbe_common.c
@@ -1784,6 +1784,20 @@ s32 ixgbe_fc_autoneg(struct ixgbe_hw *hw)
 	}
 
 	/*
+	 * Bail out on
+	 * - copper or CX4 adapters
+	 * - fiber adapters running at 10gig
+	 */
+	if ((hw->phy.media_type == ixgbe_media_type_copper) ||
+	     (hw->phy.media_type == ixgbe_media_type_cx4) ||
+	     ((hw->phy.media_type == ixgbe_media_type_fiber) &&
+	     (speed == IXGBE_LINK_SPEED_10GB_FULL))) {
+		hw->fc.fc_was_autonegged = false;
+		hw->fc.current_mode = hw->fc.requested_mode;
+		goto out;
+	}
+
+	/*
 	 * Read the AN advertisement and LP ability registers and resolve
 	 * local flow control settings accordingly
 	 */

