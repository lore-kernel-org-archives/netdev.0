From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
 <yoshfuji@linux-ipv6.org>
Subject: [PATCH] IPV6: Fix large packet length check
Date: Tue, 24 Jun 2003 12:40:30 +0900 (JST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030624.124030.123761150.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, yoshfuji@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@redhat.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello.

There were two errors in length check in the output path.
We could not send large packet (65535bytes).

This patch fixes the problem.
Patch against [PATCH] IPV6: use macro for maximum payload length patch.

Thanks.

--- linux-2.5+advmss+magic/net/ipv6/ip6_output.c.orig	Tue Jun 24 12:34:12 2003
+++ linux-2.5+advmss+magic/net/ipv6/ip6_output.c	Tue Jun 24 12:32:34 2003
@@ -1265,7 +1265,7 @@
 	maxfraglen = ((mtu - fragheaderlen) & ~7) + fragheaderlen - sizeof(struct frag_hdr);
 
 	if (mtu <= sizeof(struct ipv6hdr) + IPV6_MAXPLEN) {
-		if (inet->cork.length + length > IPV6_MAXPLEN - fragheaderlen) {
+		if (inet->cork.length + length > sizeof(struct ipv6hdr) + IPV6_MAXPLEN - fragheaderlen) {
 			ipv6_local_error(sk, EMSGSIZE, fl, mtu-exthdrlen);
 			return -EMSGSIZE;
 		}
@@ -1461,7 +1461,7 @@
 	
 	*(u32*)hdr = fl->fl6_flowlabel | htonl(0x60000000);
 
-	if (skb->len <= IPV6_MAXPLEN)
+	if (skb->len <= sizeof(struct ipv6hdr) + IPV6_MAXPLEN)
 		hdr->payload_len = htons(skb->len - sizeof(struct ipv6hdr));
 	else
 		hdr->payload_len = 0;

-- 
Hideaki YOSHIFUJI @ USAGI Project <yoshfuji@linux-ipv6.org>
GPG FP: 9022 65EB 1ECF 3AD1 0BDF  80D8 4807 F894 E062 0EEA
