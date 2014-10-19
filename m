From: Manfred Schlaegl <manfred.schlaegl@gmx.at>
Subject: [PATCH] ipv6: tcp_v6_iff: fix compilation error on CONFIG_IPV6=n
Date: Sun, 19 Oct 2014 20:04:55 +0200
Message-ID: <5443FD47.7040003@gmx.at>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Manfred Schlaegl <manfred.schlaegl@ginzinger.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

If CONFIG_IPV6=3Dn, then h6 in struct tcp_skb_cb.header is missing whic=
h
leads to compilation-errors on tcp_v6_iff like:

In file included from net/core/sock.c:140:0:
include/net/tcp.h: In function =E2=80=98tcp_v6_iif=E2=80=99:
include/net/tcp.h:738:32: error: =E2=80=98union <anonymous>=E2=80=99 ha=
s no member named
=E2=80=98h6=E2=80=99

This fix solves the problem by removing tcp_v6_iif, in case of
CONFIG_IPV6=3Dn.

Signed-off-by: Manfred Schlaegl <manfred.schlaegl@gmx.at>
---
 include/net/tcp.h |    2 ++
 1 file changed, 2 insertions(+)

diff --git a/include/net/tcp.h b/include/net/tcp.h
index c9766f8..4062b4f 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -730,6 +730,7 @@ struct tcp_skb_cb {
 #define TCP_SKB_CB(__skb)      ((struct tcp_skb_cb *)&((__skb)->cb[0])=
)


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

 /* Due to TSO, an SKB can be composed of multiple actual
  * packets.  To keep these tracked properly, we use this.
--=20
1.7.10.4
