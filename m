From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?= <yoshfuji@linux-ipv6.org>
Subject: [IPV6 2.4] UDPv6: checksum
Date: Wed, 16 Jun 2004 00:04:49 +0900 (JST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040616.000449.48351036.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, yoshfuji@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@redhat.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello.

We always need to check UDPv6 checksum because it is mandatory.
This patch is for 2.4.

Thanks.

===== net/ipv6/udp.c 1.14 vs edited =====
--- 1.14/net/ipv6/udp.c	2004-02-25 17:19:02 +09:00
+++ edited/net/ipv6/udp.c	2004-06-15 23:45:18 +09:00
@@ -521,8 +521,7 @@
 
 static inline int udpv6_queue_rcv_skb(struct sock * sk, struct sk_buff *skb)
 {
-#if defined(CONFIG_FILTER)
-	if (sk->filter && skb->ip_summed != CHECKSUM_UNNECESSARY) {
+	if (skb->ip_summed != CHECKSUM_UNNECESSARY) {
 		if ((unsigned short)csum_fold(skb_checksum(skb, 0, skb->len, skb->csum))) {
 			UDP6_INC_STATS_BH(UdpInErrors);
 			IP6_INC_STATS_BH(Ip6InDiscards);
@@ -531,7 +530,6 @@
 		}
 		skb->ip_summed = CHECKSUM_UNNECESSARY;
 	}
-#endif
 	if (sock_queue_rcv_skb(sk,skb)<0) {
 		UDP6_INC_STATS_BH(UdpInErrors);
 		IP6_INC_STATS_BH(Ip6InDiscards);

-- 
Hideaki YOSHIFUJI @ USAGI Project <yoshfuji@linux-ipv6.org>
GPG FP: 9022 65EB 1ECF 3AD1 0BDF  80D8 4807 F894 E062 0EEA
