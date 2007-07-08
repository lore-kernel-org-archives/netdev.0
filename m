From: Stefan Richter <stefanr@s5r6.in-berlin.de>
Subject: [PATCH] ieee1394: first minimal NUMA awareness
Date: Sun, 8 Jul 2007 13:34:21 +0200 (CEST)
Message-ID: <tkrat.a9c71958a0779a73@s5r6.in-berlin.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: linux1394-devel@lists.sourceforge.net
Return-path: <linux1394-devel-bounces@lists.sourceforge.net>
Content-Disposition: INLINE
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/linux1394-devel>,
	<mailto:linux1394-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=linux1394-devel>
List-Post: <mailto:linux1394-devel@lists.sourceforge.net>
List-Help: <mailto:linux1394-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/linux1394-devel>,
	<mailto:linux1394-devel-request@lists.sourceforge.net?subject=subscribe>
Sender: linux1394-devel-bounces@lists.sourceforge.net
Errors-To: linux1394-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

Association of a host device with a node on NUMA machines optimizes
allocations of skbs given from the networking stack to eth1394.

Signed-off-by: Stefan Richter <stefanr@s5r6.in-berlin.de>
---

Note, in Linux 2.6.20 and earlier and 2.6.23 and later, eth1394 calls
or will call SET_NETDEV_DEV(eth1394_netdev, &h->device).

 drivers/ieee1394/hosts.c |    1 +
 1 file changed, 1 insertion(+)

Index: linux-2.6.22-rc7/drivers/ieee1394/hosts.c
===================================================================
--- linux-2.6.22-rc7.orig/drivers/ieee1394/hosts.c
+++ linux-2.6.22-rc7/drivers/ieee1394/hosts.c
@@ -154,6 +154,7 @@ struct hpsb_host *hpsb_alloc_host(struct
 
 	memcpy(&h->device, &nodemgr_dev_template_host, sizeof(h->device));
 	h->device.parent = dev;
+	set_dev_node(&h->device, dev_to_node(dev));
 	snprintf(h->device.bus_id, BUS_ID_SIZE, "fw-host%d", h->id);
 
 	h->host_dev.parent = &h->device;

-- 
Stefan Richter
-=====-=-=== -=== -=---
http://arcgraph.de/sr/


-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
