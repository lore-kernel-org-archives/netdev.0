From: Stefan Richter <stefanr@s5r6.in-berlin.de>
Subject: [PATCH linux1394-2.6.git 06/15] ieee1394: eth1394: contain host reset
Date: Mon, 2 Apr 2007 02:16:40 +0200 (CEST)
Message-ID: <tkrat.8131c55ab793b082@s5r6.in-berlin.de>
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

Call only eth1394's own host reset handler from .tx_timeout, not the
reset hooks of all other IEEE 1394 drivers.

A minor drawback of this patch is that ether1394_host_reset by timeout
is not serialized against ether1394_host_reset by bus reset.

Signed-off-by: Stefan Richter <stefanr@s5r6.in-berlin.de>
---
 drivers/ieee1394/eth1394.c |    6 ++----
 1 file changed, 2 insertions(+), 4 deletions(-)

Index: linux/drivers/ieee1394/eth1394.c
===================================================================
--- linux.orig/drivers/ieee1394/eth1394.c
+++ linux/drivers/ieee1394/eth1394.c
@@ -258,10 +258,8 @@ static void ether1394_tx_timeout(struct 
 	struct hpsb_host *host =
 			((struct eth1394_priv *)netdev_priv(dev))->host;
 
-	ETH1394_PRINT(KERN_ERR, dev->name, "Timeout, resetting host %s\n",
-		      host->driver->name);
-	highlevel_host_reset(host);
-	netif_wake_queue(dev);
+	ETH1394_PRINT(KERN_ERR, dev->name, "Timeout, resetting host\n");
+	ether1394_host_reset(host);
 }
 
 static int ether1394_change_mtu(struct net_device *dev, int new_mtu)

-- 
Stefan Richter
-=====-=-=== -=-- ---=-
http://arcgraph.de/sr/


-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys-and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
