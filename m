From: Arnaldo Carvalho de Melo <acme@conectiva.com.br>
Subject: PATCH: [SKBUFF] introduce skb_link_header_data_offset(skb)
Date: Tue, 05 Oct 2004 17:54:50 -0300
Sender: netdev-bounce@oss.sgi.com
Message-ID: <41630A1A.5040808@conectiva.com.br>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------050307020301000802030106"
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: dav@conectiva.com.br
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------050307020301000802030106
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Hi David,

	Please consider pulling from:

bk://kernel.bkbits.net/acme/sk_buff-2.6

	Now there are 15 outstanding changesets in this tree.

Regards,

- Arnaldo

--------------050307020301000802030106
Content-Type: text/plain;
 name="skb_link_header_data_offset.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="skb_link_header_data_offset.patch"

===================================================================


ChangeSet@1.2044, 2004-10-05 17:51:20-03:00, acme@conectiva.com.br
  [SKBUFF] introduce skb_link_header_data_offset(skb)
  
  Signed-off-by: Arnaldo Carvalho de Melo <acme@conectiva.com.br>
  Signed-off-by: David S. Miller <davem@redhat.com>


 include/linux/skbuff.h |    5 +++++
 net/ax25/af_ax25.c     |    4 +++-
 net/packet/af_packet.c |    6 +++---
 3 files changed, 11 insertions(+), 4 deletions(-)


diff -Nru a/include/linux/skbuff.h b/include/linux/skbuff.h
--- a/include/linux/skbuff.h	2004-10-05 17:52:24 -03:00
+++ b/include/linux/skbuff.h	2004-10-05 17:52:24 -03:00
@@ -313,6 +313,11 @@
 	return skb->nh.raw - skb->mac.raw;
 }
 
+static inline int skb_link_header_data_offset(const struct sk_buff *skb)
+{
+	return skb->data - skb->mac.raw;
+}
+
 extern void	       __kfree_skb(struct sk_buff *skb);
 extern struct sk_buff *alloc_skb(unsigned int size, int priority);
 extern void	       kfree_skbmem(struct sk_buff *skb);
diff -Nru a/net/ax25/af_ax25.c b/net/ax25/af_ax25.c
--- a/net/ax25/af_ax25.c	2004-10-05 17:52:24 -03:00
+++ b/net/ax25/af_ax25.c	2004-10-05 17:52:24 -03:00
@@ -1632,7 +1632,9 @@
 		ax25_digi digi;
 		ax25_address src;
 
-		ax25_addr_parse(skb->mac.raw+1, skb->data-skb->mac.raw-1, &src, NULL, &digi, NULL, NULL);
+		ax25_addr_parse(skb->mac.raw + 1,
+				skb_link_header_data_offset(skb) - 1,
+				&src, NULL, &digi, NULL, NULL);
 
 		sax->sax25_family = AF_AX25;
 		/* We set this correctly, even though we may not let the
diff -Nru a/net/packet/af_packet.c b/net/packet/af_packet.c
--- a/net/packet/af_packet.c	2004-10-05 17:52:24 -03:00
+++ b/net/packet/af_packet.c	2004-10-05 17:52:24 -03:00
@@ -274,7 +274,7 @@
 
 	spkt = (struct sockaddr_pkt*)skb->cb;
 
-	skb_push(skb, skb->data-skb->mac.raw);
+	skb_push(skb, skb_link_header_data_offset(skb));
 
 	/*
 	 *	The SOCK_PACKET socket receives _all_ frames.
@@ -462,7 +462,7 @@
 		   never delivered to user.
 		 */
 		if (sk->sk_type != SOCK_DGRAM)
-			skb_push(skb, skb->data - skb->mac.raw);
+			skb_push(skb, skb_link_header_data_offset(skb));
 		else if (skb->pkt_type == PACKET_OUTGOING) {
 			/* Special case: outgoing packets have ll header at head */
 			skb_pull(skb, skb->nh.raw - skb->data);
@@ -559,7 +559,7 @@
 
 	if (dev->hard_header) {
 		if (sk->sk_type != SOCK_DGRAM)
-			skb_push(skb, skb->data - skb->mac.raw);
+			skb_push(skb, skb_link_header_data_offset(skb));
 		else if (skb->pkt_type == PACKET_OUTGOING) {
 			/* Special case: outgoing packets have ll header at head */
 			skb_pull(skb, skb->nh.raw - skb->data);


--------------050307020301000802030106--
