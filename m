From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH 2.4] clear hw checksum flags when bridging
Date: Mon, 8 Sep 2003 09:36:44 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030908093644.290c2f8e.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: bridge@osdl.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

The hardware checksumming flags need to be cleared when forwarding packets.
Bridging just needs to forward what ever checksum is in the existing skbuff,
it doesn't want or need the packet to be resummed.

Without this fix, forwarding between smart/dumb interfaces causes an oops.

diff -Nru a/net/bridge/br_forward.c b/net/bridge/br_forward.c
--- a/net/bridge/br_forward.c	Mon Sep  8 09:29:44 2003
+++ b/net/bridge/br_forward.c	Mon Sep  8 09:29:44 2003
@@ -59,6 +59,7 @@
 
 	indev = skb->dev;
 	skb->dev = to->dev;
+	skb->ip_summed = CHECKSUM_NONE;
 
 	NF_HOOK(PF_BRIDGE, NF_BR_FORWARD, skb, indev, skb->dev,
 			__br_forward_finish);
