From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] multiple eth0 mixed PCI/ISA init
Date: Mon, 5 Jan 2004 11:10:59 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040105111059.4a451146.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This patch for 2.6 fixes the problem found by Zoltan Farkas 
with mixed PCI/ISA and a non-modular config.  The problem is the old_netdev
ISA probing isn't skipping "eth0" which already got assigned by the PCI
initialization.


diff -Nru a/drivers/net/Space.c b/drivers/net/Space.c
--- a/drivers/net/Space.c	Fri Dec 19 15:10:50 2003
+++ b/drivers/net/Space.c	Fri Dec 19 15:10:50 2003
@@ -350,7 +350,7 @@
 	 * Backwards compatibility - historically an I/O base of 1 was 
 	 * used to indicate not to probe for this ethN interface 
 	 */
-	if (dev->base_addr == 1) {
+	if (__dev_get_by_name(dev->name) || dev->base_addr == 1) {
 		free_netdev(dev);
 		return -ENXIO;
 	}
