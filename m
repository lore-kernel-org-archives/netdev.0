From: Randy Dunlap <randy.dunlap@oracle.com>
Subject: [PATCH linux-next 3rd time] 9p: restrict RDMA usage
Date: Wed, 12 Nov 2008 13:05:17 -0800
Message-ID: <20081112130517.73c3e13a.randy.dunlap@oracle.com>
References: <20081112182818.6e259488.sfr@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-next@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>,
	v9fs-developer@lists.sourceforge.net,
	netdev <netdev@vger.kernel.org>
To: Stephen Rothwell <sfr@canb.auug.org.au>, ericvh@gmail.com,
	akpm <akpm@linux-foundation.org>
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <20081112182818.6e259488.sfr@canb.auug.org.au>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Randy Dunlap <randy.dunlap@oracle.com>

linux-next:

Make 9p's RDMA option depend on INET since it uses Infiniband rdma_*
functions and that code depends on INET.  Otherwise 9p can try to
use symbols which don't exist.

ERROR: "rdma_destroy_id" [net/9p/9pnet_rdma.ko] undefined!
ERROR: "rdma_connect" [net/9p/9pnet_rdma.ko] undefined!
ERROR: "rdma_create_id" [net/9p/9pnet_rdma.ko] undefined!
ERROR: "rdma_create_qp" [net/9p/9pnet_rdma.ko] undefined!
ERROR: "rdma_resolve_route" [net/9p/9pnet_rdma.ko] undefined!
ERROR: "rdma_disconnect" [net/9p/9pnet_rdma.ko] undefined!
ERROR: "rdma_resolve_addr" [net/9p/9pnet_rdma.ko] undefined!

I used an if/endif block so that the menu items would remain
presented together.

Also correct an article adjective.

Signed-off-by: Randy Dunlap <randy.dunlap@oracle.com>
---
 net/9p/Kconfig |   10 ++++++----
 1 file changed, 6 insertions(+), 4 deletions(-)

--- linux-next-20081103.orig/net/9p/Kconfig
+++ linux-next-20081103/net/9p/Kconfig
@@ -13,22 +13,24 @@ menuconfig NET_9P
 
 	  If unsure, say N.
 
+if NET_9P
+
 config NET_9P_VIRTIO
-	depends on NET_9P && EXPERIMENTAL && VIRTIO
+	depends on EXPERIMENTAL && VIRTIO
 	tristate "9P Virtio Transport (Experimental)"
 	help
 	  This builds support for a transports between
 	  guest partitions and a host partition.
 
 config NET_9P_RDMA
-	depends on NET_9P && INFINIBAND && EXPERIMENTAL
+	depends on INET && INFINIBAND && EXPERIMENTAL
 	tristate "9P RDMA Transport (Experimental)"
 	help
-	  This builds support for a RDMA transport.
+	  This builds support for an RDMA transport.
 
 config NET_9P_DEBUG
 	bool "Debug information"
-	depends on NET_9P
 	help
 	  Say Y if you want the 9P subsystem to log debug information.
 
+endif
