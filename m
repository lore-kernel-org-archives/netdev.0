From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?= <yoshfuji@linux-ipv6.org>
Subject: [IPV6] UDPv6: checksum
Date: Wed, 16 Jun 2004 00:00:10 +0900 (JST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040616.000010.111901629.yoshfuji@linux-ipv6.org>
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

Thanks.

===== net/ipv6/udp.c 1.64 vs edited =====
--- 1.64/net/ipv6/udp.c	2004-06-10 05:39:26 +09:00
+++ edited/net/ipv6/udp.c	2004-06-15 23:43:42 +09:00
@@ -507,7 +507,7 @@
 		return -1;
 	}
 
-	if (sk->sk_filter && skb->ip_summed != CHECKSUM_UNNECESSARY) {
+	if (skb->ip_summed != CHECKSUM_UNNECESSARY) {
 		if ((unsigned short)csum_fold(skb_checksum(skb, 0, skb->len, skb->csum))) {
 			UDP6_INC_STATS_BH(UdpInErrors);
 			kfree_skb(skb);


-- 
Hideaki YOSHIFUJI @ USAGI Project <yoshfuji@linux-ipv6.org>
GPG FP: 9022 65EB 1ECF 3AD1 0BDF  80D8 4807 F894 E062 0EEA
