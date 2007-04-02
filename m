From: Stefan Richter <stefanr@s5r6.in-berlin.de>
Subject: [PATCH linux1394-2.6.git 07/15] ieee1394: eth1394: make MTU
	configurable
Date: Mon, 2 Apr 2007 02:18:13 +0200 (CEST)
Message-ID: <tkrat.6cd13266811f2f6d@s5r6.in-berlin.de>
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

Signed-off-by: Stefan Richter <stefanr@s5r6.in-berlin.de>
---
 drivers/ieee1394/eth1394.c |   20 ++++++++++++++------
 1 file changed, 14 insertions(+), 6 deletions(-)

Index: linux/drivers/ieee1394/eth1394.c
===================================================================
--- linux.orig/drivers/ieee1394/eth1394.c
+++ linux/drivers/ieee1394/eth1394.c
@@ -136,9 +136,6 @@ static const int hdr_type_len[] = {
 	sizeof(struct eth1394_sf_hdr)
 };
 
-/* For now, this needs to be 1500, so that XP works with us */
-#define ETH1394_DATA_LEN	ETH_DATA_LEN
-
 static const u16 eth1394_speedto_maxpayload[] = {
 /*     S100, S200, S400, S800, S1600, S3200 */
 	512, 1024, 2048, 4096,  4096,  4096
@@ -158,8 +155,19 @@ static int max_partial_datagrams = 25;
 module_param(max_partial_datagrams, int, S_IRUGO | S_IWUSR);
 MODULE_PARM_DESC(max_partial_datagrams,
 		 "Maximum number of partially received fragmented datagrams "
-		 "(default = 25).");
+		 "(default = 25)");
 
+/*
+ * RFC 2734 says: "IP-capable nodes may operate with an MTU size larger than
+ * the default [1500 octets], but the means by which a larger MTU is configured
+ * are beyond the scope of this document."
+ *
+ * Leave it at the default 1500 for interoperability.
+ * Raise it for performance tuning.
+ */
+static int eth1394_data_len = 1500;
+module_param_named(mtu, eth1394_data_len, int, S_IRUGO | S_IWUSR);
+MODULE_PARM_DESC(mtu, "MTU (default = 1500)");
 
 static int ether1394_header(struct sk_buff *skb, struct net_device *dev,
 			    unsigned short type, void *daddr, void *saddr,
@@ -268,7 +276,7 @@ static int ether1394_change_mtu(struct n
 		((struct eth1394_priv *)netdev_priv(dev))->host->csr.max_rec;
 
 	if (new_mtu < 68 ||
-	    new_mtu > ETH1394_DATA_LEN ||
+	    new_mtu > eth1394_data_len ||
 	    new_mtu > (1 << (max_rec + 1)) - sizeof(union eth1394_hdr) -
 		      ETHER1394_GASP_OVERHEAD)
 		return -EINVAL;
@@ -480,7 +488,7 @@ static void ether1394_reset_priv(struct 
 	if (set_mtu) {
 		int max_payload = 1 << (host->csr.max_rec + 1);
 
-		dev->mtu = min(ETH1394_DATA_LEN,
+		dev->mtu = min(eth1394_data_len,
 			       (int)(max_payload - sizeof(union eth1394_hdr) -
 				     ETHER1394_GASP_OVERHEAD));
 

-- 
Stefan Richter
-=====-=-=== -=-- ---=-
http://arcgraph.de/sr/


-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys-and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
