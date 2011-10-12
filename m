From: Joe Perches <joe@perches.com>
Subject: [PATCH net-next 5/5] igb: Convert bare printk to pr_notice
Date: Wed, 12 Oct 2011 09:18:10 -0700
Message-ID: <1b72526330e273e78649e92f606b7779c3db7533.1318436085.git.joe@perches.com>
References: <cover.1318436085.git.joe@perches.com>
Cc: netdev@vger.kernel.org,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Bruce Allan <bruce.w.allan@intel.com>,
	Carolyn Wyborny <carolyn.wyborny@intel.com>,
	Don Skidmore <donald.c.skidmore@intel.com>,
	Greg Rose <gregory.v.rose@intel.com>,
	Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>,
	Alex Duyck <alexander.h.duyck@intel.com>,
	John Ronciak <john.ronciak@intel.com>,
	e1000-devel@lists.sourceforge.net
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1318436085.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

printks should use KERN_ levels.

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/ethernet/intel/igb/e1000_82575.c |    5 +++--
 1 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/intel/igb/e1000_82575.c b/drivers/net/ethernet/intel/igb/e1000_82575.c
index c0857bd..e0acfff 100644
--- a/drivers/net/ethernet/intel/igb/e1000_82575.c
+++ b/drivers/net/ethernet/intel/igb/e1000_82575.c
@@ -29,6 +29,8 @@
  * e1000_82576
  */
 
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
+
 #include <linux/types.h>
 #include <linux/if_ether.h>
 
@@ -248,8 +250,7 @@ static s32 igb_get_invariants_82575(struct e1000_hw *hw)
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
1.7.6.405.gc1be0
