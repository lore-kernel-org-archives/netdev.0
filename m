From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 2/2 net-next] ixgbe: remove xmit length check
Date: Mon, 18 Jun 2012 11:55:58 -0700
Message-ID: <20120618115558.1ef26a48@nehalam.linuxnetplumber.net>
References: <20120618105816.5fdd0b90@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>
To: Bruce Allan <bruce.w.allan@intel.com>, Carolyn Wyborny
	<carolyn.wyborny@intel.com>, Don Skidmore <donald.c.skidmore@intel.com>,
	Greg Rose <gregory.v.rose@intel.com>, Peter P Waskiewicz Jr
	<peter.p.waskiewicz.jr@intel.com>, Alex Duyck <alexander.h.duyck@intel.com>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <20120618105816.5fdd0b90@nehalam.linuxnetplumber.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

The check here is bogus. Since len is unsigned, it can never
be negative. And it would be a bug in network stack to ever
send a zero length packet to device.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>


--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c	2012-06-18 10:53:13.742310994 -0700
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c	2012-06-18 10:53:15.962279249 -0700
@@ -6380,11 +6380,6 @@ static netdev_tx_t ixgbe_xmit_frame(stru
 	struct ixgbe_adapter *adapter = netdev_priv(netdev);
 	struct ixgbe_ring *tx_ring;
 
-	if (skb->len <= 0) {
-		dev_kfree_skb_any(skb);
-		return NETDEV_TX_OK;
-	}
-
 	/*
 	 * The minimum packet size for olinfo paylen is 17 so pad the skb
 	 * in order to meet this minimum size requirement.

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
