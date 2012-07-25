From: Jesper Juhl <jj@chaosbits.net>
Subject: [PATCH] igb: don't break user visible strings over
 multiple lines in igb_ethtool.c
Date: Wed, 25 Jul 2012 21:19:58 +0200 (CEST)
Message-ID: <alpine.LNX.2.00.1207252115321.11754@swampdragon.chaosbits.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	Rick Jones <rick.jones2@hp.com>, Bruce Allan <bruce.w.allan@intel.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	"David S. Miller" <davem@davemloft.net>
To: linux-kernel@vger.kernel.org
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

Even when they go beyond 80 characters, user visible strings should be
on one line to make them easy to grep for.

Signed-off-by: Jesper Juhl <jj@chaosbits.net>
---
 drivers/net/ethernet/intel/igb/igb_ethtool.c | 23 +++++++++++------------
 1 file changed, 11 insertions(+), 12 deletions(-)

 This patch was generated on top of another patch I submitted a few minutes ago:
  Subject: [PATCH] igb: correct hardware type (i210/i211) check in igb_loopback_test()
  Message-ID: <alpine.LNX.2.00.1207252059320.11754@swampdragon.chaosbits.net>

diff --git a/drivers/net/ethernet/intel/igb/igb_ethtool.c b/drivers/net/ethernet/intel/igb/igb_ethtool.c
index ad489b7..90550f5 100644
--- a/drivers/net/ethernet/intel/igb/igb_ethtool.c
+++ b/drivers/net/ethernet/intel/igb/igb_ethtool.c
@@ -209,8 +209,8 @@ static int igb_set_settings(struct net_device *netdev, struct ethtool_cmd *ecmd)
 	/* When SoL/IDER sessions are active, autoneg/speed/duplex
 	 * cannot be changed */
 	if (igb_check_reset_block(hw)) {
-		dev_err(&adapter->pdev->dev, "Cannot change link "
-			"characteristics when SoL/IDER is active.\n");
+		dev_err(&adapter->pdev->dev,
+			"Cannot change link characteristics when SoL/IDER is active.\n");
 		return -EINVAL;
 	}
 
@@ -1089,8 +1089,8 @@ static bool reg_pattern_test(struct igb_adapter *adapter, u64 *data,
 		wr32(reg, (_test[pat] & write));
 		val = rd32(reg) & mask;
 		if (val != (_test[pat] & write & mask)) {
-			dev_err(&adapter->pdev->dev, "pattern test reg %04X "
-				"failed: got 0x%08X expected 0x%08X\n",
+			dev_err(&adapter->pdev->dev,
+				"pattern test reg %04X failed: got 0x%08X expected 0x%08X\n",
 				reg, val, (_test[pat] & write & mask));
 			*data = reg;
 			return 1;
@@ -1108,8 +1108,8 @@ static bool reg_set_and_check(struct igb_adapter *adapter, u64 *data,
 	wr32(reg, write & mask);
 	val = rd32(reg);
 	if ((write & mask) != (val & mask)) {
-		dev_err(&adapter->pdev->dev, "set/check reg %04X test failed:"
-			" got 0x%08X expected 0x%08X\n", reg,
+		dev_err(&adapter->pdev->dev,
+			"set/check reg %04X test failed: got 0x%08X expected 0x%08X\n", reg,
 			(val & mask), (write & mask));
 		*data = reg;
 		return 1;
@@ -1171,8 +1171,9 @@ static int igb_reg_test(struct igb_adapter *adapter, u64 *data)
 	wr32(E1000_STATUS, toggle);
 	after = rd32(E1000_STATUS) & toggle;
 	if (value != after) {
-		dev_err(&adapter->pdev->dev, "failed STATUS register test "
-			"got: 0x%08X expected: 0x%08X\n", after, value);
+		dev_err(&adapter->pdev->dev,
+			"failed STATUS register test got: 0x%08X expected: 0x%08X\n",
+			after, value);
 		*data = 1;
 		return 1;
 	}
@@ -1777,16 +1778,14 @@ static int igb_loopback_test(struct igb_adapter *adapter, u64 *data)
 	 * sessions are active */
 	if (igb_check_reset_block(&adapter->hw)) {
 		dev_err(&adapter->pdev->dev,
-			"Cannot do PHY loopback test "
-			"when SoL/IDER is active.\n");
+			"Cannot do PHY loopback test when SoL/IDER is active.\n");
 		*data = 0;
 		goto out;
 	}
 	if ((adapter->hw.mac.type == e1000_i210)
 		|| (adapter->hw.mac.type == e1000_i211)) {
 		dev_err(&adapter->pdev->dev,
-			"Loopback test not supported "
-			"on this part at this time.\n");
+			"Loopback test not supported on this part at this time.\n");
 		*data = 0;
 		goto out;
 	}
-- 
1.7.11.3



-- 
Jesper Juhl <jj@chaosbits.net>       http://www.chaosbits.net/
Don't top-post http://www.catb.org/jargon/html/T/top-post.html
Plain text mails only, please.


------------------------------------------------------------------------------
Live Security Virtual Conference
Exclusive live event will cover all the ways today's security and 
threat landscape has changed and how IT managers can respond. Discussions 
will include endpoint security, mobile security and the latest in malware 
threats. http://www.accelacomm.com/jaw/sfrnl04242012/114/50122263/
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired
