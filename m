From: Bart De Schuymer <bdschuym@pandora.be>
Subject: [PATCH] Fix loopback over bridge port (for 2.4)
Date: Sat, 27 Dec 2003 16:08:53 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200312271608.53991.bdschuym@pandora.be>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@osdl.org>, netdev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S.Miller" <davem@redhat.com>
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi Dave,

Here's the fix for 2.4.

cheers,
Bart

--- linux-2.4.23-bk16/net/core/dev.c.old	2003-12-27 16:00:34.000000000 +0100
+++ linux-2.4.23-bk16/net/core/dev.c	2003-12-27 16:03:09.000000000 +0100
@@ -1501,8 +1501,8 @@ int netif_receive_skb(struct sk_buff *sk
 #endif /* CONFIG_NET_DIVERT */
 			
 #if defined(CONFIG_BRIDGE) || defined(CONFIG_BRIDGE_MODULE)
-	if (skb->dev->br_port != NULL &&
-	    br_handle_frame_hook != NULL) {
+	if (skb->dev->br_port != NULL && br_handle_frame_hook != NULL &&
+	    skb->pkt_type != PACKET_LOOPBACK) {
 		return handle_bridge(skb, pt_prev);
 	}
 #endif
