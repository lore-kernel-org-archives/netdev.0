From: Stefan Richter <stefanr@s5r6.in-berlin.de>
Subject: [PATCH linux1394-2.6.git 08/15] eth1394: CONFIG_INET is always defined
Date: Mon, 2 Apr 2007 02:19:02 +0200 (CEST)
Message-ID: <tkrat.be2ddb1e91e2f590@s5r6.in-berlin.de>
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

because CONFIG_IEEE1394_ETH1394 depends on it.

Signed-off-by: Stefan Richter <stefanr@s5r6.in-berlin.de>
---
 drivers/ieee1394/eth1394.c |   16 ++++------------
 1 file changed, 4 insertions(+), 12 deletions(-)

Index: linux/drivers/ieee1394/eth1394.c
===================================================================
--- linux.orig/drivers/ieee1394/eth1394.c
+++ linux/drivers/ieee1394/eth1394.c
@@ -715,21 +715,13 @@ static int ether1394_header(struct sk_bu
 static int ether1394_rebuild_header(struct sk_buff *skb)
 {
 	struct eth1394hdr *eth = (struct eth1394hdr *)skb->data;
-	struct net_device *dev = skb->dev;
-
-	switch (eth->h_proto) {
 
-#ifdef CONFIG_INET
-	case __constant_htons(ETH_P_IP):
+	if (eth->h_proto == htons(ETH_P_IP))
  		return arp_find((unsigned char *)&eth->h_dest, skb);
-#endif
-	default:
-		ETH1394_PRINT(KERN_DEBUG, dev->name,
-			      "unable to resolve type %04x addresses.\n",
-			      ntohs(eth->h_proto));
-		break;
-	}
 
+	ETH1394_PRINT(KERN_DEBUG, skb->dev->name,
+		      "unable to resolve type %04x addresses\n",
+		      ntohs(eth->h_proto));
 	return 0;
 }
 

-- 
Stefan Richter
-=====-=-=== -=-- ---=-
http://arcgraph.de/sr/


-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys-and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
