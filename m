From: <zyjzyj2000@gmail.com>
Subject: [PATCH 3/3] ixgbe: synchronize the link_speed and link_up of a slave interface
Date: Wed, 30 Dec 2015 17:16:35 +0800
Message-ID: <1451466995-19015-4-git-send-email-zyjzyj2000@gmail.com>
References: <53C6554C-8692-4EF3-BF5D-7217D2C9FDA0@intel.com>
 <1451466995-19015-1-git-send-email-zyjzyj2000@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <venkat.viswanathan@windriver.com>,
	<Boris.Shteinbock@windriver.com>, <Vincent.Bourg@windriver.com>
To: <jeffrey.t.kirsher@intel.com>, <jesse.brandeburg@intel.com>,
	<shannon.nelson@intel.com>, <carolyn.wyborny@intel.com>,
	<donald.c.skidmore@intel.com>, <bruce.w.allan@intel.com>,
	<john.ronciak@intel.com>, <mitch.a.williams@intel.com>,
	<intel-wired-lan@lists.osuosl.org>, <netdev@vger.kernel.org>,
	<e1000-devel@lists.sourceforge.net>, <mark.d.rustad@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail5.windriver.com ([192.103.53.11]:52801 "EHLO mail5.wrs.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754389AbbL3JQs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 30 Dec 2015 04:16:48 -0500
In-Reply-To: <1451466995-19015-1-git-send-email-zyjzyj2000@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Zhu Yanjun <yanjun.zhu@windriver.com>

According to the suggestion from Rustad, Mark D, this behavior perhaps
is more related to the copper phy. But to make fiber phy more robust,
to all the interfaces as a slave interface, the link_speed and link_up
is synchronized.

Signed-off-by: Zhu Yanjun <yanjun.zhu@windriver.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c |    8 +++++---
 1 file changed, 5 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index 1bb6056..ce47639 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -6441,10 +6441,12 @@ static void ixgbe_watchdog_link_is_up(struct ixgbe_adapter *adapter)
 	 * a bonding driver in 802.3ad mode. When X540 NIC acts as an
 	 * independent interface, it is not necessary to synchronize link_up
 	 * and link_speed.
-	 * In the end, not continue if (X540 NIC && SLAVE && link_speed UNKNOWN)
+	 * According to the suggestion from Rustad, Mark D, this behavior
+	 * perhaps is related to the copper phy. To make fiber phy more robust,
+	 * To all the interfaces as a slave, the link_speed is checked.
+	 * In the end, not continue if (SLAVE && link_speed UNKNOWN)
 	 */
-	if ((hw->mac.type == ixgbe_mac_X540) &&
-	    (netdev->flags & IFF_SLAVE))
+	if (netdev->flags & IFF_SLAVE)
 		if (link_speed == IXGBE_LINK_SPEED_UNKNOWN)
 			return;
 
-- 
1.7.9.5
