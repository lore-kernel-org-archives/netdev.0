From: Arnaldo Carvalho de Melo <acme@conectiva.com.br>
Subject: PATCH: [SKBUFF] remove some ethernet header related magic numbers
Date: Tue, 05 Oct 2004 15:53:05 -0300
Sender: netdev-bounce@oss.sgi.com
Message-ID: <4162ED91.20605@conectiva.com.br>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------030406070407000204070009"
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------030406070407000204070009
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Hi David,

	Plesase consider pulling from:

bk://kernel.bkbits.net/acme/sk_buff-2.6

	Now there are twelve outstanding changesets in this
tree.

Best Regards,

- Arnaldo

--------------030406070407000204070009
Content-Type: text/plain;
 name="ethhdr_magic_numbers.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="ethhdr_magic_numbers.patch"

===================================================================


ChangeSet@1.2041, 2004-10-05 15:45:31-03:00, acme@conectiva.com.br
  [SKBUFF] remove some ethernet header related magic numbers
  
  Signed-off-by: Arnaldo Carvalho de Melo <acme@conectiva.com.br>
  Signed-off-by: David S. Miller <davem@redhat.com>


 drivers/net/loopback.c |    2 +-
 net/core/pktgen.c      |    4 ++--
 2 files changed, 3 insertions(+), 3 deletions(-)


diff -Nru a/drivers/net/loopback.c b/drivers/net/loopback.c
--- a/drivers/net/loopback.c	2004-10-05 15:50:11 -03:00
+++ b/drivers/net/loopback.c	2004-10-05 15:50:11 -03:00
@@ -85,7 +85,7 @@
 		if (!nskb)
 			break;
 		skb_reserve(nskb, 32);
-		nskb->mac.raw = nskb->data - 14;
+		nskb->mac.raw = nskb->data - ETH_HLEN;
 		nskb->nh.raw = nskb->data;
 		iph = nskb->nh.iph;
 		memcpy(nskb->data, skb->nh.raw, doffset);
diff -Nru a/net/core/pktgen.c b/net/core/pktgen.c
--- a/net/core/pktgen.c	2004-10-05 15:50:11 -03:00
+++ b/net/core/pktgen.c	2004-10-05 15:50:11 -03:00
@@ -515,8 +515,8 @@
 	iph->tot_len = htons(iplen);
 	iph->check = 0;
 	iph->check = ip_fast_csum((void *) iph, iph->ihl);
-	skb->protocol = __constant_htons(ETH_P_IP);
-	skb->mac.raw = ((u8 *)iph) - 14;
+	skb->protocol = htons(ETH_P_IP);
+	skb->mac.raw = ((u8 *)iph) - ETH_ALEN;
 	skb->dev = odev;
 	skb->pkt_type = PACKET_HOST;
 

===================================================================

--------------030406070407000204070009--
