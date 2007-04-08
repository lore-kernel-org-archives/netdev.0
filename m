From: Patrick McHardy <kaber@trash.net>
Subject: [XFRM]: esp: fix skb_tail_pointer conversion bug
Date: Sun, 08 Apr 2007 08:08:54 +0200
Message-ID: <461886F6.1010308@trash.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------070807020904050809040507"
Cc: Kernel Netdev Mailing List <netdev@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:40691 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752365AbXDHGI7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 8 Apr 2007 02:08:59 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------070807020904050809040507
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit


--------------070807020904050809040507
Content-Type: text/plain;
 name="x"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="x"

[XFRM]: esp: fix skb_tail_pointer conversion bug

Fix incorrect switch of "trailer" skb by "skb" during skb_tail_pointer
conversion:

-       *(u8*)(trailer->tail - 1) = top_iph->protocol;
+       *(skb_tail_pointer(skb) - 1) = top_iph->protocol;

-       *(u8 *)(trailer->tail - 1) = *skb_network_header(skb);
+       *(skb_tail_pointer(skb) - 1) = *skb_network_header(skb);


Signed-off-by: Patrick McHardy <kaber@trash.net>

---
commit c43f271709475c491e425086b8c4a166ae4f3478
tree d9a52c51bd4a03f7d7f7930a25d8fc38d96db8e5
parent 5b83c3481951802b1fa171718e022565d78185a7
author Patrick McHardy <kaber@trash.net> Sun, 08 Apr 2007 08:07:01 +0200
committer Patrick McHardy <kaber@trash.net> Sun, 08 Apr 2007 08:07:01 +0200

 net/ipv4/esp4.c |    2 +-
 net/ipv6/esp6.c |    2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/ipv4/esp4.c b/net/ipv4/esp4.c
index 7459251..47c95e8 100644
--- a/net/ipv4/esp4.c
+++ b/net/ipv4/esp4.c
@@ -64,7 +64,7 @@ static int esp_output(struct xfrm_state *x, struct sk_buff *skb)
 	esph = (struct ip_esp_hdr *)(skb_network_header(skb) +
 				     top_iph->ihl * 4);
 	top_iph->tot_len = htons(skb->len + alen);
-	*(skb_tail_pointer(skb) - 1) = top_iph->protocol;
+	*(skb_tail_pointer(trailer) - 1) = top_iph->protocol;
 
 	/* this is non-NULL only with UDP Encapsulation */
 	if (x->encap) {
diff --git a/net/ipv6/esp6.c b/net/ipv6/esp6.c
index 61af22d..7107bb7 100644
--- a/net/ipv6/esp6.c
+++ b/net/ipv6/esp6.c
@@ -91,7 +91,7 @@ static int esp6_output(struct xfrm_state *x, struct sk_buff *skb)
 	top_iph = (struct ipv6hdr *)__skb_push(skb, hdr_len);
 	esph = (struct ipv6_esp_hdr *)skb_transport_header(skb);
 	top_iph->payload_len = htons(skb->len + alen - sizeof(*top_iph));
-	*(skb_tail_pointer(skb) - 1) = *skb_network_header(skb);
+	*(skb_tail_pointer(trailer) - 1) = *skb_network_header(skb);
 	*skb_network_header(skb) = IPPROTO_ESP;
 
 	esph->spi = x->id.spi;

--------------070807020904050809040507--
