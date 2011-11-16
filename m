From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 7/8] igb: Convert bare printk to pr_notice
Date: Wed, 16 Nov 2011 04:51:31 -0800
Message-ID: <1321447892-14381-8-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1321447892-14381-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Joe Perches <joe@perches.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:24675 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756626Ab1KPMvk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 16 Nov 2011 07:51:40 -0500
In-Reply-To: <1321447892-14381-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Joe Perches <joe@perches.com>

printks should use KERN_ levels.

Signed-off-by: Joe Perches <joe@perches.com>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/igb/e1000_82575.c |    5 +++--
 1 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/intel/igb/e1000_82575.c b/drivers/net/ethernet/intel/igb/e1000_82575.c
index 7881fb9..b8e20f0 100644
--- a/drivers/net/ethernet/intel/igb/e1000_82575.c
+++ b/drivers/net/ethernet/intel/igb/e1000_82575.c
@@ -29,6 +29,8 @@
  * e1000_82576
  */
 
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
+
 #include <linux/types.h>
 #include <linux/if_ether.h>
 
@@ -244,8 +246,7 @@ static s32 igb_get_invariants_82575(struct e1000_hw *hw)
 	 * Check for invalid size
 	 */
 	if ((hw->mac.type == e1000_82576) && (size > 15)) {
-		printk("igb: The NVM size is not valid, "
-			"defaulting to 32K.\n");
+		pr_notice("The NVM size is not valid, defaulting to 32K\n");
 		size = 15;
 	}
 	nvm->word_size = 1 << size;
-- 
1.7.6.4
