From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] (4/11) netrom - reserve room for AX25 header in skb
Date: Wed, 13 Aug 2003 15:41:59 -0700
Sender: linux-hams-owner@vger.kernel.org
Message-ID: <20030813154159.3775dd90.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, linux-hams@vger.kernel.org
Return-path: <linux-hams-owner@vger.kernel.org>
To: "David S. Miller" <davem@redhat.com>,
	Jeroen Vreeken <pe1rxq@amsat.org>
List-Id: netdev.vger.kernel.org

From: Jeroen Vreeken <pe1rxq@amsat.org>

Reserve space in socket header for AX25 header.

diff -Nru a/net/netrom/nr_dev.c b/net/netrom/nr_dev.c
--- a/net/netrom/nr_dev.c	Wed Aug 13 12:22:13 2003
+++ b/net/netrom/nr_dev.c	Wed Aug 13 12:22:13 2003
@@ -204,7 +204,7 @@
 	dev->stop		= nr_close;
 
 	dev->hard_header	= nr_header;
-	dev->hard_header_len	= AX25_BPQ_HEADER_LEN + AX25_MAX_HEADER_LEN + NR_NETWORK_LEN + NR_TRANSPORT_LEN;
+	dev->hard_header_len	= NR_NETWORK_LEN + NR_TRANSPORT_LEN;
 	dev->addr_len		= AX25_ADDR_LEN;
 	dev->type		= ARPHRD_NETROM;
 	dev->rebuild_header	= nr_rebuild_header;
diff -Nru a/net/netrom/nr_subr.c b/net/netrom/nr_subr.c
--- a/net/netrom/nr_subr.c	Wed Aug 13 12:22:13 2003
+++ b/net/netrom/nr_subr.c	Wed Aug 13 12:22:13 2003
@@ -127,7 +127,7 @@
 	unsigned char  *dptr;
 	int len, timeout;
 
-	len = AX25_BPQ_HEADER_LEN + AX25_MAX_HEADER_LEN + NR_NETWORK_LEN + NR_TRANSPORT_LEN;
+	len = NR_NETWORK_LEN + NR_TRANSPORT_LEN;
 
 	switch (frametype & 0x0F) {
 	case NR_CONNREQ:
@@ -151,7 +151,7 @@
 	/*
 	 *	Space for AX.25 and NET/ROM network header
 	 */
-	skb_reserve(skb, AX25_BPQ_HEADER_LEN + AX25_MAX_HEADER_LEN + NR_NETWORK_LEN);
+	skb_reserve(skb, NR_NETWORK_LEN);
 
 	dptr = skb_put(skb, skb_tailroom(skb));
 
@@ -219,12 +219,12 @@
 	unsigned char *dptr;
 	int len;
 
-	len = AX25_BPQ_HEADER_LEN + AX25_MAX_HEADER_LEN + NR_NETWORK_LEN + NR_TRANSPORT_LEN + 1;
+	len = NR_NETWORK_LEN + NR_TRANSPORT_LEN + 1;
 
 	if ((skbn = alloc_skb(len, GFP_ATOMIC)) == NULL)
 		return;
 
-	skb_reserve(skbn, AX25_BPQ_HEADER_LEN + AX25_MAX_HEADER_LEN);
+	skb_reserve(skbn, 0);
 
 	dptr = skb_put(skbn, NR_NETWORK_LEN + NR_TRANSPORT_LEN);
 
