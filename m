From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] (1/3) Space.c -- alloc_divert_blk not needed here.
Date: Tue, 23 Sep 2003 10:11:16 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030923101116.5c5bea3b.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

No longer need to alloc_divert_blk in probe process because
the network probe code now calls register_netdevice which does it
if necessary.

diff -Nru a/drivers/net/Space.c b/drivers/net/Space.c
--- a/drivers/net/Space.c	Tue Sep 23 09:36:52 2003
+++ b/drivers/net/Space.c	Tue Sep 23 09:36:52 2003
@@ -125,22 +125,14 @@
 {
 	struct devprobe *p = plist;
 	unsigned long base_addr = dev->base_addr;
-	int ret;
 
 	while (p->probe != NULL) {
-		if (base_addr && p->probe(dev) == 0) {	/* probe given addr */
-			ret = alloc_divert_blk(dev);
-			if (ret)
-				return ret;
+		if (base_addr && p->probe(dev) == 0) 	/* probe given addr */
 			return 0;
-		} else if (p->status == 0) {		/* has autoprobe failed yet? */
+		else if (p->status == 0) {		/* has autoprobe failed yet? */
 			p->status = p->probe(dev);	/* no, try autoprobe */
-			if (p->status == 0) {
-				ret = alloc_divert_blk(dev);
-				if (ret)
-					return ret;
+			if (p->status == 0)
 				return 0;
-			}
 		}
 		p++;
 	}
