From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 2/7] igb: Fix stats output on i210/i211 parts.
Date: Sat, 22 Sep 2012 03:30:31 -0700
Message-ID: <1348309836-7107-3-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1348309836-7107-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Carolyn Wyborny <carolyn.wyborny@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:39138 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755258Ab2IVKas (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 22 Sep 2012 06:30:48 -0400
In-Reply-To: <1348309836-7107-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Carolyn Wyborny <carolyn.wyborny@intel.com>

Due to a hardware issue, on i210 and i211 parts, the TNCRS statistic
provides an invalid value.  This patch changes the update stats function
to increment the stat only for non-i210/i211 parts.

Signed-off-by: Carolyn Wyborny <carolyn.wyborny@intel.com>
Tested-by: Jeff Pieper <jeffrey.e.pieper@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/igb/igb_main.c | 6 +++++-
 1 file changed, 5 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/igb/igb_main.c b/drivers/net/ethernet/intel/igb/igb_main.c
index 0730096..60cf3eb 100644
--- a/drivers/net/ethernet/intel/igb/igb_main.c
+++ b/drivers/net/ethernet/intel/igb/igb_main.c
@@ -4776,7 +4776,11 @@ void igb_update_stats(struct igb_adapter *adapter,
 	reg = rd32(E1000_CTRL_EXT);
 	if (!(reg & E1000_CTRL_EXT_LINK_MODE_MASK)) {
 		adapter->stats.rxerrc += rd32(E1000_RXERRC);
-		adapter->stats.tncrs += rd32(E1000_TNCRS);
+
+		/* this stat has invalid values on i210/i211 */
+		if ((hw->mac.type != e1000_i210) &&
+		    (hw->mac.type != e1000_i211))
+			adapter->stats.tncrs += rd32(E1000_TNCRS);
 	}
 
 	adapter->stats.tsctc += rd32(E1000_TSCTC);
-- 
1.7.11.4
