From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 1/2 net-next] ixgbe: use skb_padto
Date: Mon, 18 Jun 2012 10:58:16 -0700
Message-ID: <20120618105816.5fdd0b90@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, Bruce Allan
	<bruce.w.allan@intel.com>, Carolyn Wyborny <carolyn.wyborny@intel.com>, Don
	Skidmore <donald.c.skidmore@intel.com>, Greg Rose
	<gregory.v.rose@intel.com>, Peter P Waskiewicz Jr
	<peter.p.waskiewicz.jr@intel.com>, Alex Duyck
	<alexander.h.duyck@intel.com>, "David S. Miller" <davem@davemloft.net>
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

The code to pad packets here is the same effective code as
the existing inline function skb_padto(). There is a minor
performance gain since skb_padto() also uses unlikely().

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>


--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c	2012-06-18 10:53:09.130376800 -0700
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c	2012-06-18 10:55:13.104540844 -0700
@@ -6389,11 +6389,8 @@ static netdev_tx_t ixgbe_xmit_frame(stru
 	 * The minimum packet size for olinfo paylen is 17 so pad the skb
 	 * in order to meet this minimum size requirement.
 	 */
-	if (skb->len < 17) {
-		if (skb_padto(skb, 17))
-			return NETDEV_TX_OK;
-		skb->len = 17;
-	}
+	if (skb_padto(skb, 17))
+		return NETDEV_TX_OK;
 
 	tx_ring = adapter->tx_ring[skb->queue_mapping];
 	return ixgbe_xmit_frame_ring(skb, adapter, tx_ring);

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
