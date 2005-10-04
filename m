From: Ralf Baechle DL5RB <ralf@linux-mips.org>
Subject: [PATCH] AX.25: Fix packet socket crash
Date: Tue, 4 Oct 2005 20:48:03 +0100
Message-ID: <20051004194803.GA2724@linux-mips.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-hams@vger.kernel.org, netdev@vger.kernel.org
Return-path: <linux-hams-owner@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
Sender: linux-hams-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Since changeset 98a82febb6340466824c3a453738d4fbd05db81a AX.25 is passing
received IP and ARP packets to the stack through netif_rx() but we don't
set the skb->mac.raw to right value which may result in a crash with
applications that use a packet socket.

Signed-off-by: Ralf Baechle DL5RB <ralf@linux-mips.org>

 net/ax25/ax25_in.c  |    2 +-
 net/netrom/nr_dev.c |    2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

Index: linux-cvs/net/ax25/ax25_in.c
===================================================================
--- linux-cvs.orig/net/ax25/ax25_in.c
+++ linux-cvs/net/ax25/ax25_in.c
@@ -123,7 +123,7 @@ int ax25_rx_iframe(ax25_cb *ax25, struct
 		}
 
 		skb_pull(skb, 1);	/* Remove PID */
-		skb->h.raw    = skb->data;
+		skb->mac.raw  = skb->nh.raw;
 		skb->nh.raw   = skb->data;
 		skb->dev      = ax25->ax25_dev->dev;
 		skb->pkt_type = PACKET_HOST;
Index: linux-cvs/net/netrom/nr_dev.c
===================================================================
--- linux-cvs.orig/net/netrom/nr_dev.c
+++ linux-cvs/net/netrom/nr_dev.c
@@ -58,7 +58,7 @@ int nr_rx_ip(struct sk_buff *skb, struct
 
 	/* Spoof incoming device */
 	skb->dev      = dev;
-	skb->h.raw    = skb->data;
+	skb->mac.raw  = skb->nh.raw;
 	skb->nh.raw   = skb->data;
 	skb->pkt_type = PACKET_HOST;
 
