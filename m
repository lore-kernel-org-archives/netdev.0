From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] (4/4) usbnet -- use random_ether_addr
Date: Fri, 9 Apr 2004 11:47:27 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040409114727.0619405d@dell_ss3.pdx.osdl.net>
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

Same code to generate random_ether_address is in ether_device.h (patch1)
so use it for usbnet.

diff -Nru a/drivers/usb/net/usbnet.c b/drivers/usb/net/usbnet.c
--- a/drivers/usb/net/usbnet.c	Fri Apr  9 11:41:19 2004
+++ b/drivers/usb/net/usbnet.c	Fri Apr  9 11:41:19 2004
@@ -3414,9 +3414,7 @@
 			< sizeof (struct cdc_state)));
 #endif
 
-	get_random_bytes (node_id, sizeof node_id);
-	node_id [0] &= 0xfe;	// clear multicast bit
-	node_id [0] |= 0x02;    // set local assignment bit (IEEE802)
+	random_ether_addr(node_id);
 
  	return usb_register(&usbnet_driver);
 }
