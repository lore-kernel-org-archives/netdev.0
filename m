From: Joe Perches <joe@perches.com>
Subject: [PATCH 3/4] igbvf: Use ETH_ALEN
Date: Sun, 18 Mar 2012 20:37:58 -0700
Message-ID: <49b440b7f5a9fa85ed5278e2663541283e32cad8.1332128181.git.joe@perches.com>
References: <cover.1332128181.git.joe@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: e1000-devel@lists.sourceforge.net, Bruce Allan <bruce.w.allan@intel.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	John Ronciak <john.ronciak@intel.com>, netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <cover.1332128181.git.joe@perches.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

Remove an unnecessary #define and use memcpy
instead of a loop to copy an ethernet address.

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/ethernet/intel/igbvf/defines.h |    4 ----
 drivers/net/ethernet/intel/igbvf/vf.c      |    7 ++-----
 2 files changed, 2 insertions(+), 9 deletions(-)

diff --git a/drivers/net/ethernet/intel/igbvf/defines.h b/drivers/net/ethernet/intel/igbvf/defines.h
index 33f40d3..3e18045 100644
--- a/drivers/net/ethernet/intel/igbvf/defines.h
+++ b/drivers/net/ethernet/intel/igbvf/defines.h
@@ -97,10 +97,6 @@
 #define E1000_ERR_MAC_INIT 5
 #define E1000_ERR_MBX      15
 
-#ifndef ETH_ADDR_LEN
-#define ETH_ADDR_LEN                 6
-#endif
-
 /* SRRCTL bit definitions */
 #define E1000_SRRCTL_BSIZEPKT_SHIFT                     10 /* Shift _right_ */
 #define E1000_SRRCTL_BSIZEHDRSIZE_MASK                  0x00000F00
diff --git a/drivers/net/ethernet/intel/igbvf/vf.c b/drivers/net/ethernet/intel/igbvf/vf.c
index 1955197..30a6cc4 100644
--- a/drivers/net/ethernet/intel/igbvf/vf.c
+++ b/drivers/net/ethernet/intel/igbvf/vf.c
@@ -246,7 +246,7 @@ static void e1000_update_mc_addr_list_vf(struct e1000_hw *hw,
 	for (i = 0; i < cnt; i++) {
 		hash_value = e1000_hash_mc_addr_vf(hw, mc_addr_list);
 		hash_list[i] = hash_value & 0x0FFFF;
-		mc_addr_list += ETH_ADDR_LEN;
+		mc_addr_list += ETH_ALEN;
 	}
 
 	mbx->ops.write_posted(hw, msgbuf, E1000_VFMAILBOX_SIZE);
@@ -333,10 +333,7 @@ static void e1000_rar_set_vf(struct e1000_hw *hw, u8 * addr, u32 index)
  **/
 static s32 e1000_read_mac_addr_vf(struct e1000_hw *hw)
 {
-	int i;
-
-	for (i = 0; i < ETH_ADDR_LEN; i++)
-		hw->mac.addr[i] = hw->mac.perm_addr[i];
+	memcpy(hw->mac.addr, hw->mac.perm_addr, ETH_ALEN);
 
 	return E1000_SUCCESS;
 }
-- 
1.7.8.111.gad25c.dirty


------------------------------------------------------------------------------
This SF email is sponsosred by:
Try Windows Azure free for 90 days Click Here 
http://p.sf.net/sfu/sfd2d-msazure
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired
