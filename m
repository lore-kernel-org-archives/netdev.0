From: Stefan Richter <stefanr@s5r6.in-berlin.de>
Subject: [PATCH linux1394-2.6.git 12/15] ieee1394: eth1394: some conditions
	are unlikely
Date: Mon, 2 Apr 2007 02:22:21 +0200 (CEST)
Message-ID: <tkrat.90438d05dbadd99d@s5r6.in-berlin.de>
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
 drivers/ieee1394/eth1394.c |    8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

Index: linux/drivers/ieee1394/eth1394.c
===================================================================
--- linux.orig/drivers/ieee1394/eth1394.c
+++ linux/drivers/ieee1394/eth1394.c
@@ -1027,7 +1027,7 @@ static int ether1394_data_handler(struct
 	if (!ud) {
 		struct eth1394_node_ref *node;
 		node = eth1394_find_node_nodeid(&priv->ip_node_list, srcid);
-		if (!node) {
+		if (unlikely(!node)) {
 			HPSB_PRINT(KERN_ERR, "ether1394 rx: sender nodeid "
 				   "lookup failure: " NODE_BUS_FMT,
 				   NODE_BUS_ARGS(priv->host, srcid));
@@ -1052,7 +1052,7 @@ static int ether1394_data_handler(struct
 		 * high level network layer. */
 
 		skb = dev_alloc_skb(len + dev->hard_header_len + 15);
-		if (!skb) {
+		if (unlikely(!skb)) {
 			ETH1394_PRINT_G(KERN_ERR, "Out of memory\n");
 			priv->stats.rx_dropped++;
 			return -1;
@@ -1207,7 +1207,7 @@ static int ether1394_write(struct hpsb_h
 	struct eth1394_host_info *hi;
 
 	hi = hpsb_get_hostinfo(&eth1394_highlevel, host);
-	if (hi == NULL) {
+	if (unlikely(!hi)) {
 		ETH1394_PRINT_G(KERN_ERR, "No net device at fw-host%d\n",
 				host->id);
 		return RCODE_ADDRESS_ERROR;
@@ -1233,7 +1233,7 @@ static void ether1394_iso(struct hpsb_is
 	int nready;
 
 	hi = hpsb_get_hostinfo(&eth1394_highlevel, iso->host);
-	if (hi == NULL) {
+	if (unlikely(!hi)) {
 		ETH1394_PRINT_G(KERN_ERR, "No net device at fw-host%d\n",
 				iso->host->id);
 		return;

-- 
Stefan Richter
-=====-=-=== -=-- ---=-
http://arcgraph.de/sr/


-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys-and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
