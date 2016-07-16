From: Richard Stearn <richard@rns-stearn.demon.co.uk>
Subject: [PATCH 3/6]NET:AX25:ROSE Traps calls to rose_route_frame with a
 NULL ax25 callback
Date: Sat, 16 Jul 2016 10:43:59 +0100
Message-ID: <201607160943.u6G9hx4i014901@ux4.g1sog>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org, linux-hams@vger.kernel.org
Return-path: <linux-hams-owner@vger.kernel.org>
Sender: linux-hams-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Subject: [PATCH 3/6]NET:AX25:ROSE Traps calls to rose_route_frame with a NULL ax25 callback
Traps calls to rose_route_frame with a NULL ax25 callback to
prevent a kernel crash.

Calling rose_route_frame with a NULL ax25 callback parameter indicates a
locally generated frame.  The existing code does not handle the NULL value
and the kernel hard crashes in an interrupt, resulting in the system stopping
processing.

Signed-off-by: Richard Stearn <richard@rns-stearn.demon.co.uk>
---
 net/rose/rose_route.c |    5 +++++
 1 file changed, 5 insertions(+)

diff --git a/net/rose/rose_route.c b/net/rose/rose_route.c
index 23e0fbd..96ed06c 100644
--- a/net/rose/rose_route.c
+++ b/net/rose/rose_route.c
@@ -877,6 +877,11 @@ int rose_route_frame(struct sk_buff *skb, ax25_cb *ax25)
 	src_addr  = (rose_address *)(skb->data + ROSE_CALL_REQ_SRC_ADDR_OFF);
 	dest_addr = (rose_address *)(skb->data + ROSE_CALL_REQ_DEST_ADDR_OFF);
 
+	if (ax25 == NULL) {
+		printk(KERN_ERR "rose_route_frame : called with ax25 callback == NULL\n");
+		return res;
+	}
+
 	spin_lock_bh(&rose_neigh_list_lock);
 	spin_lock_bh(&rose_route_list_lock);
 
