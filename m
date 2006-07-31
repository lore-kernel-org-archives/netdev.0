From: Wei Yongjun <yjwei@nanjing-fnst.com>
Subject: [PATCH] Fix UDP filter condition when do checksum
Date: Mon, 31 Jul 2006 06:33:42 -0400
Message-ID: <1154342022.3959.10.camel@LINE>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [221.6.14.228] ([221.6.14.228]:34706 "EHLO
	localmail.nanjing-fnst.com") by vger.kernel.org with ESMTP
	id S1751495AbWGaJcL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 31 Jul 2006 05:32:11 -0400
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In udp_queue_rcv_skb(), checksum condition is error. When UDP filter is
set, checksum is be done, but if UDP filter is not set, checksum will
not be done. So I think this is a BUG. Following is my patch:

--- a/net/ipv4/udp.c	2006-07-31 09:33:45.392479344 -0400
+++ b/net/ipv4/udp.c	2006-07-31 17:10:41.271632200 -0400
@@ -1018,7 +1018,7 @@ static int udp_queue_rcv_skb(struct sock
 		/* FALLTHROUGH -- it's a UDP Packet */
 	}
=20
-	if (sk->sk_filter && skb->ip_summed !=3D CHECKSUM_UNNECESSARY) {
+	if (!sk->sk_filter && skb->ip_summed !=3D CHECKSUM_UNNECESSARY) {
 		if (__udp_checksum_complete(skb)) {
 			UDP_INC_STATS_BH(UDP_MIB_INERRORS);
 			kfree_skb(skb);


Signed-off-by: Wei Yongjun <yjwei@nanjing-fnst.com>=11
`=DF'	=19



'	c link




>


