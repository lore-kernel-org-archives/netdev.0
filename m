From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH] tcp: fix build error if IPv6 is not enabled
Date: Sat, 18 Oct 2014 08:34:37 -0700
Message-ID: <1413646477.27176.31.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f176.google.com ([209.85.192.176]:48350 "EHLO
	mail-pd0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751151AbaJRPej (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 18 Oct 2014 11:34:39 -0400
Received: by mail-pd0-f176.google.com with SMTP id fp1so2415792pdb.35
        for <netdev@vger.kernel.org>; Sat, 18 Oct 2014 08:34:38 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Eric Dumazet <edumazet@google.com>

$ make M=3Dnet/ipv4
  CC      net/ipv4/route.o
In file included from net/ipv4/route.c:102:0:
include/net/tcp.h: In function =E2=80=98tcp_v6_iif=E2=80=99:
include/net/tcp.h:738:32: error: =E2=80=98union <anonymous>=E2=80=99 ha=
s no member named =E2=80=98h6=E2=80=99
  return TCP_SKB_CB(skb)->header.h6.iif;

Signed-off-by: Eric Dumazet <edumazet@google.com>
=46ixes: 870c3151382c ("ipv6: introduce tcp_v6_iif()")
---
 include/net/tcp.h |    2 ++
 1 file changed, 2 insertions(+)

diff --git a/include/net/tcp.h b/include/net/tcp.h
index c9766f89deba..4062b4f0d121 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -730,6 +730,7 @@ struct tcp_skb_cb {
 #define TCP_SKB_CB(__skb)	((struct tcp_skb_cb *)&((__skb)->cb[0]))
=20
=20
+#if IS_ENABLED(CONFIG_IPV6)
 /* This is the variant of inet6_iif() that must be used by TCP,
  * as TCP moves IP6CB into a different location in skb->cb[]
  */
@@ -737,6 +738,7 @@ static inline int tcp_v6_iif(const struct sk_buff *=
skb)
 {
 	return TCP_SKB_CB(skb)->header.h6.iif;
 }
+#endif
=20
 /* Due to TSO, an SKB can be composed of multiple actual
  * packets.  To keep these tracked properly, we use this.
