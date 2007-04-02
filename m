From: Stefan Richter <stefanr@s5r6.in-berlin.de>
Subject: [PATCH linux1394-2.6.git 02/15] ieee1394: eth1394: .probe and .update
	may sleep
Date: Mon, 2 Apr 2007 02:13:51 +0200 (CEST)
Message-ID: <tkrat.ba9631ac06a9e664@s5r6.in-berlin.de>
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
 drivers/ieee1394/eth1394.c |   12 ++++--------
 1 file changed, 4 insertions(+), 8 deletions(-)

Index: linux/drivers/ieee1394/eth1394.c
===================================================================
--- linux.orig/drivers/ieee1394/eth1394.c
+++ linux/drivers/ieee1394/eth1394.c
@@ -354,13 +354,11 @@ static int eth1394_probe(struct device *
 	if (!hi)
 		return -ENOENT;
 
-	new_node = kmalloc(sizeof(*new_node),
-			   in_interrupt() ? GFP_ATOMIC : GFP_KERNEL);
+	new_node = kmalloc(sizeof(*new_node), GFP_KERNEL);
 	if (!new_node)
 		return -ENOMEM;
 
-	node_info = kmalloc(sizeof(*node_info),
-			    in_interrupt() ? GFP_ATOMIC : GFP_KERNEL);
+	node_info = kmalloc(sizeof(*node_info), GFP_KERNEL);
 	if (!node_info) {
 		kfree(new_node);
 		return -ENOMEM;
@@ -435,13 +433,11 @@ static int eth1394_update(struct unit_di
 	if (node)
 		return 0;
 
-	node = kmalloc(sizeof(*node),
-		       in_interrupt() ? GFP_ATOMIC : GFP_KERNEL);
+	node = kmalloc(sizeof(*node), GFP_KERNEL);
 	if (!node)
 		return -ENOMEM;
 
-	node_info = kmalloc(sizeof(*node_info),
-			    in_interrupt() ? GFP_ATOMIC : GFP_KERNEL);
+	node_info = kmalloc(sizeof(*node_info), GFP_KERNEL);
 	if (!node_info) {
 		kfree(node);
 		return -ENOMEM;

-- 
Stefan Richter
-=====-=-=== -=-- ---=-
http://arcgraph.de/sr/


-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys-and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
