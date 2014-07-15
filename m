From: David Decotigny <decot@googlers.com>
Subject: [PATCH v1] e1000e: honor pause autoneg flag
Date: Tue, 15 Jul 2014 15:09:06 -0700
Message-ID: <98ea4a6a8e42ffa454d5d42749262e8df02c0167.1405462125.git.decot@googlers.com>
References: <cover.1405462125.git.decot@googlers.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: David Decotigny <decot@googlers.com>
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Bruce Allan <bruce.w.allan@intel.com>,
	Carolyn Wyborny <carolyn.wyborny@intel.com>,
	Don Skidmore <donald.c.skidmore@intel.com>,
	Greg Rose <gregory.v.rose@intel.com>,
	Alex Duyck <alexander.h.duyck@intel.com>,
	John Ronciak <john.ronciak@intel.com>,
	Mitch Williams <mitch.a.williams@intel.com>,
	Linux NICS <linux.nics@intel.com>, e1000-devel@lists.sourceforge.net,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <cover.1405462125.git.decot@googlers.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

Before:
  ifup eth0
  ethtool -A eth0 autoneg off rx on
  ethtool -a eth0  # rx on, as expected
  ifconfig eth0 up
  sleep 5
  ethtool -a eth0  # rx off, not expected

After:
  rx on with iface up, as expected

Signed-off-by: David Decotigny <decot@googlers.com>
---
 drivers/net/ethernet/intel/e1000e/mac.c | 5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/intel/e1000e/mac.c b/drivers/net/ethernet/intel/e1000e/mac.c
index 8c386f3a..ef014ae 100644
--- a/drivers/net/ethernet/intel/e1000e/mac.c
+++ b/drivers/net/ethernet/intel/e1000e/mac.c
@@ -1048,7 +1048,8 @@ s32 e1000e_config_fc_after_link_up(struct e1000_hw *hw)
 	 * has completed, and if so, how the PHY and link partner has
 	 * flow control configured.
 	 */
-	if ((hw->phy.media_type == e1000_media_type_copper) && mac->autoneg) {
+	if ((hw->phy.media_type == e1000_media_type_copper) && mac->autoneg &&
+	    hw->adapter->fc_autoneg) {
 		/* Read the MII Status Register and check to see if AutoNeg
 		 * has completed.  We read this twice because this reg has
 		 * some "sticky" (latched) bits.
@@ -1191,7 +1192,7 @@ s32 e1000e_config_fc_after_link_up(struct e1000_hw *hw)
 	 * flow control configured.
 	 */
 	if ((hw->phy.media_type == e1000_media_type_internal_serdes) &&
-	    mac->autoneg) {
+	    mac->autoneg && hw->adapter->fc_autoneg) {
 		/* Read the PCS_LSTS and check to see if AutoNeg
 		 * has completed.
 		 */
-- 
2.0.0.526.g5318336


------------------------------------------------------------------------------
Want fast and easy access to all the code in your enterprise? Index and
search up to 200,000 lines of code with a free copy of Black Duck
Code Sight - the same software that powers the world's largest code
search on Ohloh, the Black Duck Open Hub! Try it now.
http://p.sf.net/sfu/bds
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired
