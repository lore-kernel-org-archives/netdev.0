From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] (3/4) usb gadget -- use random_ether_addr
Date: Fri, 9 Apr 2004 11:45:50 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040409114550.444abe30@dell_ss3.pdx.osdl.net>
References: <20040408110834.2fd1bd25@dell_ss3.pdx.osdl.net>
	<20040408145403.34382c96.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, linux-usb-devel@lists.sourceforge.net
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
In-Reply-To: <20040408145403.34382c96.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Use new common code in ether_device.h for random_ether_addr.
Same exact code just in one common place.

diff -Nru a/drivers/usb/gadget/ether.c b/drivers/usb/gadget/ether.c
--- a/drivers/usb/gadget/ether.c	Fri Apr  9 11:39:51 2004
+++ b/drivers/usb/gadget/ether.c	Fri Apr  9 11:39:51 2004
@@ -1804,17 +1804,13 @@
 	/* one random address for the gadget device ... both of these could
 	 * reasonably come from an id prom or a module parameter.
 	 */
-	get_random_bytes (net->dev_addr, ETH_ALEN);
-	net->dev_addr [0] &= 0xfe;	// clear multicast bit
-	net->dev_addr [0] |= 0x02;	// set local assignment bit (IEEE802)
+	random_ether_addr(net->dev_addr);
 
 #ifdef	DEV_CONFIG_CDC
 	/* ... another address for the host, on the other end of the
 	 * link, gets exported through CDC (see CDC spec table 41)
 	 */
-	get_random_bytes (node_id, sizeof node_id);
-	node_id [0] &= 0xfe;	// clear multicast bit
-	node_id [0] |= 0x02;    // set local assignment bit (IEEE802)
+	random_ether_addr(node_id);
 	snprintf (ethaddr, sizeof ethaddr, "%02X%02X%02X%02X%02X%02X",
 		node_id [0], node_id [1], node_id [2],
 		node_id [3], node_id [4], node_id [5]);
