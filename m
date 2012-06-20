From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net 1/3] igb: Fix incorrect RAR address entries for i210/i211 device.
Date: Wed, 20 Jun 2012 01:44:40 -0700
Message-ID: <1340181882-16333-2-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1340181882-16333-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Carolyn Wyborny <carolyn.wyborny@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:38315 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753557Ab2FTIoo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 20 Jun 2012 04:44:44 -0400
In-Reply-To: <1340181882-16333-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Carolyn Wyborny <carolyn.wyborny@intel.com>

i210/i211 device has only 16 RAR address filters like 82575, instead of
32 like i350.  This patch removes the entries for i210/i211 in the
get_invariants function which was setting them for 32. This ensures that
they will get the default value which is the correct one.

Signed-off-by: Carolyn Wyborny <carolyn.wyborny@intel.com>
Tested-by: Jeff Pieper <jeffrey.e.pieper@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/igb/e1000_82575.c |    2 --
 1 file changed, 2 deletions(-)

diff --git a/drivers/net/ethernet/intel/igb/e1000_82575.c b/drivers/net/ethernet/intel/igb/e1000_82575.c
index e650839..5e84eaa 100644
--- a/drivers/net/ethernet/intel/igb/e1000_82575.c
+++ b/drivers/net/ethernet/intel/igb/e1000_82575.c
@@ -206,8 +206,6 @@ static s32 igb_get_invariants_82575(struct e1000_hw *hw)
 		mac->rar_entry_count = E1000_RAR_ENTRIES_82580;
 		break;
 	case e1000_i350:
-	case e1000_i210:
-	case e1000_i211:
 		mac->rar_entry_count = E1000_RAR_ENTRIES_I350;
 		break;
 	default:
-- 
1.7.10.2
