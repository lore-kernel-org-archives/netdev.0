From: Stefan Richter <stefanr@s5r6.in-berlin.de>
Subject: [PATCH linux1394-2.6.git 09/15] ieee1394: eth1394: omit useless
	set_mac_address callback
Date: Mon, 2 Apr 2007 02:19:48 +0200 (CEST)
Message-ID: <tkrat.79f8bc185088681f@s5r6.in-berlin.de>
References: <tkrat.7cdc7f6a1e6d9f28@s5r6.in-berlin.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: linux1394-devel@lists.sourceforge.net
Return-path: <linux1394-devel-bounces@lists.sourceforge.net>
In-Reply-To: <tkrat.7cdc7f6a1e6d9f28@s5r6.in-berlin.de>
Content-Disposition: INLINE
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/linux1394-devel>,
	<mailto:linux1394-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=linux1394-devel>
List-Post: <mailto:linux1394-devel@lists.sourceforge.net>
List-Help: <mailto:linux1394-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/linux1394-devel>,
	<mailto:linux1394-devel-request@lists.sourceforge.net?subject=subscribe>
Sender: linux1394-devel-bounces@lists.sourceforge.net
Errors-To: linux1394-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

We can't reconfigure the MAC address, hence we don't need the callback.

Signed-off-by: Stefan Richter <stefanr@s5r6.in-berlin.de>
---
 drivers/ieee1394/eth1394.c |   14 +-------------
 1 file changed, 1 insertion(+), 13 deletions(-)

Index: linux/drivers/ieee1394/eth1394.c
===================================================================
--- linux.orig/drivers/ieee1394/eth1394.c
+++ linux/drivers/ieee1394/eth1394.c
@@ -178,8 +178,6 @@ static int ether1394_header_cache(struct
 static void ether1394_header_cache_update(struct hh_cache *hh,
 					  struct net_device *dev,
 					  unsigned char *haddr);
-static int ether1394_mac_addr(struct net_device *dev, void *p);
-
 static int ether1394_tx(struct sk_buff *skb, struct net_device *dev);
 static void ether1394_iso(struct hpsb_iso *iso);
 
@@ -516,7 +514,7 @@ static void ether1394_init_dev(struct ne
 	dev->hard_header_cache	= ether1394_header_cache;
 	dev->header_cache_update= ether1394_header_cache_update;
 	dev->hard_header_parse	= ether1394_header_parse;
-	dev->set_mac_address	= ether1394_mac_addr;
+	dev->set_mac_address	= NULL;
 	SET_ETHTOOL_OPS(dev, &ethtool_ops);
 
 	/* Some constants */
@@ -758,16 +756,6 @@ static void ether1394_header_cache_updat
 	memcpy((u8 *)hh->hh_data + 16 - ETH1394_HLEN, haddr, dev->addr_len);
 }
 
-static int ether1394_mac_addr(struct net_device *dev, void *p)
-{
-	if (netif_running(dev))
-		return -EBUSY;
-
-	/* Not going to allow setting the MAC address, we really need to use
-	 * the real one supplied by the hardware */
-	 return -EINVAL;
-}
-
 /******************************************
  * Datagram reception code
  ******************************************/

-- 
Stefan Richter
-=====-=-=== -=-- ---=-
http://arcgraph.de/sr/


-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys-and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
