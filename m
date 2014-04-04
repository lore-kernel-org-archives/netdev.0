From: Vlad Yasevich <vyasevic@redhat.com>
Subject: [PATCH net] e1000e: Correctly include VLAN_HLEN when
	changing interface MTU
Date: Fri,  4 Apr 2014 16:48:48 -0400
Message-ID: <1396644528-32430-1-git-send-email-vyasevic@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Vlad Yasevich <vyasevic@redhat.com>, e1000-devel@lists.sourceforge.net
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

When changing the interface mtu, the driver starts with a value
that doesn't include VLAN_HLEN.  Later tests in the driver
set the rx_buffer_len based on the mtu.  As a result, when
the user increases the mtu to 1504 (to support 802.1AD for example),
the driver rx_buffer_len does not change and frames longer
the 1522 bytes are rejected as too long.

Include VLAN_HLEN from the start so that an user mtu greater then
1500 bytes is correctly reflected in the driver rx_buffer_len.

CC: e1000-devel@lists.sourceforge.net
CC: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Signed-off-by: Vlad Yasevich <vyasevic@redhat.com>
---
 drivers/net/ethernet/intel/e1000e/netdev.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/e1000e/netdev.c b/drivers/net/ethernet/intel/e1000e/netdev.c
index 6d91933..492a136 100644
--- a/drivers/net/ethernet/intel/e1000e/netdev.c
+++ b/drivers/net/ethernet/intel/e1000e/netdev.c
@@ -5654,7 +5654,7 @@ struct rtnl_link_stats64 *e1000e_get_stats64(struct net_device *netdev,
 static int e1000_change_mtu(struct net_device *netdev, int new_mtu)
 {
 	struct e1000_adapter *adapter = netdev_priv(netdev);
-	int max_frame = new_mtu + ETH_HLEN + ETH_FCS_LEN;
+	int max_frame = new_mtu + VLAN_HLEN + ETH_HLEN + ETH_FCS_LEN;
 
 	/* Jumbo frame support */
 	if ((max_frame > ETH_FRAME_LEN + ETH_FCS_LEN) &&
-- 
1.8.5.3


------------------------------------------------------------------------------
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired
