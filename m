From: Arnaldo Carvalho de Melo <acme@conectiva.com.br>
Subject: PATCH: [SKBUFF] Introduce skb_set_link_header_offset(skb, offset)
Date: Tue, 05 Oct 2004 17:09:08 -0300
Sender: netdev-bounce@oss.sgi.com
Message-ID: <4162FF64.4050108@conectiva.com.br>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------090101030603080600010900"
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------090101030603080600010900
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Hi David,

	Please consider pulling from:

bk://kernel.bkbits.net/acme/sk_buff-2.4

	Now there are 14 outstanding changesets in this tree.

Regards,

- Arnaldo

--------------090101030603080600010900
Content-Type: text/plain;
 name="skb_set_link_header_offset.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="skb_set_link_header_offset.patch"

===================================================================


ChangeSet@1.2043, 2004-10-05 17:05:20-03:00, acme@conectiva.com.br
  [SKBUFF] Introduce skb_set_link_header_offset(skb, offset)
  
  Signed-off-by: Arnaldo Carvalho de Melo <acme@conectiva.com.br>
  Signed-off-by: David S. Miller <davem@redhat.com>


 drivers/net/loopback.c       |    2 +-
 drivers/net/myri_sbus.c      |    2 +-
 drivers/s390/net/qeth_main.c |    2 +-
 include/linux/skbuff.h       |    6 ++++++
 net/atm/br2684.c             |    2 +-
 5 files changed, 10 insertions(+), 4 deletions(-)


diff -Nru a/drivers/net/loopback.c b/drivers/net/loopback.c
--- a/drivers/net/loopback.c	2004-10-05 17:06:15 -03:00
+++ b/drivers/net/loopback.c	2004-10-05 17:06:15 -03:00
@@ -85,7 +85,7 @@
 		if (!nskb)
 			break;
 		skb_reserve(nskb, 32);
-		nskb->mac.raw = nskb->data - ETH_HLEN;
+		skb_set_link_header_offset(nskb, -ETH_HLEN);
 		nskb->nh.raw = nskb->data;
 		iph = nskb->nh.iph;
 		memcpy(nskb->data, skb->nh.raw, doffset);
diff -Nru a/drivers/net/myri_sbus.c b/drivers/net/myri_sbus.c
--- a/drivers/net/myri_sbus.c	2004-10-05 17:06:15 -03:00
+++ b/drivers/net/myri_sbus.c	2004-10-05 17:06:15 -03:00
@@ -374,7 +374,7 @@
 	struct ethhdr *eth;
 	unsigned char *rawp;
 	
-	skb->mac.raw = (((unsigned char *)skb->data) + MYRI_PAD_LEN);
+	skb_set_link_header_offset(skb, MYRI_PAD_LEN);
 	skb_pull(skb, dev->hard_header_len);
 	eth = eth_hdr(skb);
 	
diff -Nru a/drivers/s390/net/qeth_main.c b/drivers/s390/net/qeth_main.c
--- a/drivers/s390/net/qeth_main.c	2004-10-05 17:06:15 -03:00
+++ b/drivers/s390/net/qeth_main.c	2004-10-05 17:06:15 -03:00
@@ -2173,7 +2173,7 @@
 	struct iphdr *ip_hdr;
 
 	QETH_DBF_TEXT(trace,5,"skbfake");
-	skb->mac.raw = skb->data - QETH_FAKE_LL_LEN;
+	skb_set_link_header_offset(skb, -QETH_FAKE_LL_LEN);
 	/* this is a fake ethernet header */
 	fake_hdr = eth_hdr(skb);
 
diff -Nru a/include/linux/skbuff.h b/include/linux/skbuff.h
--- a/include/linux/skbuff.h	2004-10-05 17:06:15 -03:00
+++ b/include/linux/skbuff.h	2004-10-05 17:06:15 -03:00
@@ -295,6 +295,12 @@
 	skb->mac.raw = skb->data;
 }
 
+static inline void skb_set_link_header_offset(struct sk_buff *skb,
+					      const int offset)
+{
+	skb->mac.raw = skb->data + offset;
+}
+
 static inline int skb_valid_link_header(const struct sk_buff *skb,
 					const int hdrlen)
 {
diff -Nru a/net/atm/br2684.c b/net/atm/br2684.c
--- a/net/atm/br2684.c	2004-10-05 17:06:15 -03:00
+++ b/net/atm/br2684.c	2004-10-05 17:06:15 -03:00
@@ -460,7 +460,7 @@
 	/* FIXME: tcpdump shows that pointer to mac header is 2 bytes earlier,
 	   than should be. What else should I set? */
 	skb_pull(skb, plen);
-	skb->mac.raw = ((char *) (skb->data)) - ETH_HLEN;
+	skb_set_link_header_offset(skb, -ETH_HLEN);
 	skb->pkt_type = PACKET_HOST;
 #ifdef CONFIG_BR2684_FAST_TRANS
 	skb->protocol = ((u16 *) skb->data)[-1];


--------------090101030603080600010900--
