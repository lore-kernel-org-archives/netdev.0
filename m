From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] dummy -- support hardware address
Date: Thu, 8 Apr 2004 11:08:34 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040408110834.2fd1bd25@dell_ss3.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Dummy device comes in handy for testing, but it always has address
of all zero's which isn't a valid ethernet address.  This generates
a simple fake address and allows changing the address.

diff -Nru a/drivers/net/dummy.c b/drivers/net/dummy.c
--- a/drivers/net/dummy.c	Thu Apr  8 11:03:02 2004
+++ b/drivers/net/dummy.c	Thu Apr  8 11:03:02 2004
@@ -86,6 +86,15 @@
 	return dev->priv;
 }
 
+
+static int dummy_set_address(struct net_device *dev, void *p)
+{
+	struct sockaddr *sa = p;
+
+	memcpy(dev->dev_addr, sa->sa_data, dev->addr_len);
+	return 0;
+}
+
 static struct net_device **dummies;
 
 /* Number of dummy devices to be set up by this module. */
@@ -101,6 +110,16 @@
 
 	if (!dev_dummy)
 		return -ENOMEM;
+
+	/* Generate intial fake hardware address */
+	dev_dummy->dev_addr[0] = 0x00;
+	dev_dummy->dev_addr[1] = 0xdd;
+	dev_dummy->dev_addr[2] = 0xdd;
+	dev_dummy->dev_addr[3] = index >> 16;
+	dev_dummy->dev_addr[4] = index >> 8;
+	dev_dummy->dev_addr[5] = index;
+
+	dev_dummy->set_mac_address = dummy_set_address;
 
 	if ((err = register_netdev(dev_dummy))) {
 		free_netdev(dev_dummy);
