From: Koki Sanagi <sanagi.koki@jp.fujitsu.com>
Subject: [PATCH net-next v2] igb: reset PHY after recovering
 from PHY power down
Date: Mon, 19 Dec 2011 10:24:24 +0900
Message-ID: <4EEE9248.8020009@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: e1000-devel@lists.sourceforge.net, bruce.w.allan@intel.com,
	jesse.brandeburg@intel.com, john.ronciak@intel.com, davem@davemloft.net
To: netdev@vger.kernel.org
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

According to 82576_Datasheet.pdf, PHY setting is lost after PHY power down.
So resetting PHY is needed when recovering from PHY power down to set a default
setting to PHY register.
Owing to this lack, NIC doesn't link up in some rare situation.

Signed-off-by: Koki Sanagi <sanagi.koki@jp.fujitsu.com>
---
diff --git a/drivers/net/ethernet/intel/igb/igb_main.c b/drivers/net/ethernet/intel/igb/igb_main.c
index 89d576c..9b923b0 100644
--- a/drivers/net/ethernet/intel/igb/igb_main.c
+++ b/drivers/net/ethernet/intel/igb/igb_main.c
@@ -1498,6 +1498,7 @@ void igb_power_up_link(struct igb_adapter *adapter)
 		igb_power_up_phy_copper(&adapter->hw);
 	else
 		igb_power_up_serdes_link_82575(&adapter->hw);
+	igb_reset_phy(&adapter->hw);
 }
 
 /**


------------------------------------------------------------------------------
Learn Windows Azure Live!  Tuesday, Dec 13, 2011
Microsoft is holding a special Learn Windows Azure training event for 
developers. It will provide a great way to learn Windows Azure and what it 
provides. You can attend the event by watching it streamed LIVE online.  
Learn more at http://p.sf.net/sfu/ms-windowsazure
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired
