From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?= <yoshfuji@linux-ipv6.org>
Subject: [BK-PATCH 2.4] IPV6: ensure to evaluate checksum
Date: Thu, 20 May 2004 19:33:12 +0900 (JST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040520.193312.19702393.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, yoshfuji@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@redhat.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello.

Following changesets fixes checksum for rawv6 sockets.
 - don't receive packets with incorrect checksum

Please pull following csets from <bk://bk.skbuff.net:20426>.

Thanks in advance.

CHANGESET
---------
ChangeSet@1.1414, 2004-05-20 19:07:49+09:00, yoshfuji@linux-ipv6.org
  [IPV6] ensure to evaluate the checksum for sockets with the IPV6_CHECKSUM option.

diff -Nru a/net/ipv6/raw.c b/net/ipv6/raw.c
--- a/net/ipv6/raw.c	Thu May 20 19:08:48 2004
+++ b/net/ipv6/raw.c	Thu May 20 19:08:48 2004
@@ -279,8 +279,11 @@
 
 static inline int rawv6_rcv_skb(struct sock * sk, struct sk_buff * skb)
 {
+	if ((sk->tp_pinfo.tp_raw.checksum
 #if defined(CONFIG_FILTER)
-	if (sk->filter && skb->ip_summed != CHECKSUM_UNNECESSARY) {
+	    || sk->filter 
+#endif
+	    ) && skb->ip_summed != CHECKSUM_UNNECESSARY) {
 		if ((unsigned short)csum_fold(skb_checksum(skb, 0, skb->len, skb->csum))) {
 			IP6_INC_STATS_BH(Ip6InDiscards);
 			kfree_skb(skb);
@@ -288,7 +291,6 @@
 		}
 		skb->ip_summed = CHECKSUM_UNNECESSARY;
 	}
-#endif
 	/* Charge it to the socket. */
 	if (sock_queue_rcv_skb(sk,skb)<0) {
 		IP6_INC_STATS_BH(Ip6InDiscards);

-- 
Hideaki YOSHIFUJI @ USAGI Project <yoshfuji@linux-ipv6.org>
GPG FP: 9022 65EB 1ECF 3AD1 0BDF  80D8 4807 F894 E062 0EEA
