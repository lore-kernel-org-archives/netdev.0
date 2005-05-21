From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: [PATCH] netdevice.h: be'ify packet_type
Date: Sat, 21 May 2005 19:40:59 +0400
Message-ID: <200505211940.59240.adobriyan@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Everybody does

	struct packet_type foo_packet_type = {
		.type = __constant_htons(ETH_P_FOO);
	};

5 introduced warnings will be properly fixed later.

Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>

--- linux-20050521140543-000/include/linux/netdevice.h	2005-05-21 14:12:24.000000000 +0400
+++ linux-20050521140543-001/include/linux/netdevice.h	2005-05-21 17:14:26.000000000 +0400
@@ -503,7 +503,7 @@ static inline void *netdev_priv(struct n
 #define SET_NETDEV_DEV(net, pdev)	((net)->class_dev.dev = (pdev))
 
 struct packet_type {
-	unsigned short		type;	/* This is really htons(ether_type).	*/
+	__be16			type;	/* This is really htons(ether_type).	*/
 	struct net_device		*dev;	/* NULL is wildcarded here		*/
 	int			(*func) (struct sk_buff *, struct net_device *,
 					 struct packet_type *);
