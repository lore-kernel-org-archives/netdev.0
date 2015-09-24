From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 15/18] ixgbe: Only clear adapter_stopped if ixgbe_setup_fc succeeded
Date: Wed, 23 Sep 2015 23:59:38 -0700
Message-ID: <1443077981-55791-16-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1443077981-55791-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Mark Rustad <mark.d.rustad@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:48624 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932717AbbIXG75 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 24 Sep 2015 02:59:57 -0400
In-Reply-To: <1443077981-55791-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mark Rustad <mark.d.rustad@intel.com>

A logic error here results in the adapter_stopped flag only being
cleared when ixgbe_setup_fc returns an error. Correct the logic.

Signed-off-by: Mark Rustad <mark.d.rustad@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_common.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_common.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_common.c
index b620d7a..98e1ddd 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_common.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_common.c
@@ -297,13 +297,13 @@ s32 ixgbe_start_hw_generic(struct ixgbe_hw *hw)
 
 	/* Setup flow control */
 	ret_val = ixgbe_setup_fc(hw);
-	if (!ret_val)
-		return 0;
+	if (ret_val)
+		return ret_val;
 
 	/* Clear adapter stopped flag */
 	hw->adapter_stopped = false;
 
-	return ret_val;
+	return 0;
 }
 
 /**
-- 
2.4.3
