From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] (2/9) freenetdev - update documentation
Date: Tue, 19 Aug 2003 12:18:12 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030819121812.2a27f0a7.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>, Jeff Garzik <jgarzik@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

diff -Nru a/Documentation/networking/netdevices.txt b/Documentation/networking/netdevices.txt
--- a/Documentation/networking/netdevices.txt	Tue Aug  5 09:41:12 2003
+++ b/Documentation/networking/netdevices.txt	Tue Aug  5 09:41:12 2003
@@ -7,6 +7,18 @@
 The following is a random collection of documentation regarding
 network devices.
 
+struct net_device allocation rules
+==================================
+Network device structures need to persist even after module is unloaded and
+must be allocated with kmalloc.  If device has registered successfully,
+it will be freed on last use by free_netdev.  This is required to handle the
+pathologic case cleanly (example: rmmod mydriver </sys/class/net/myeth/mtu )
+
+There are routines in net_init.c to handle the common cases of
+alloc_etherdev, alloc_netdev.  These reserve extra space for driver
+private data which gets freed when the network device is freed. If
+separately allocated data is attached to the network device
+(dev->priv) then it is up to the module exit handler to free that.
 
 
 struct net_device synchronization rules
