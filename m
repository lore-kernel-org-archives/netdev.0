From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: [PATCH 1/4] tcpv[46]: fix md5 pseudoheader address field ordering
Date: Thu,  9 Oct 2008 12:35:34 +0300
Message-ID: <1223544937-12595-1-git-send-email-ilpo.jarvinen@helsinki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org,
	"=?utf-8?q?Ilpo=20J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:44998 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755340AbYJIJfl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Oct 2008 05:35:41 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Maybe it's just me but I guess those md5 people made a mess
out of it by having *_md5_hash_* to use daddr, saddr order
instead of the one that is natural (and equal to what csum
functions use). For the segment were sending, the original
addresses are reversed so buff's saddr =3D=3D skb's daddr and
vice-versa.

Maybe I can finally proceed with unification of some code
after fixing it first... :-)

Signed-off-by: Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi>
---
 net/ipv4/tcp_ipv4.c |    4 ++--
 net/ipv6/tcp_ipv6.c |    4 ++--
 2 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index ba46769..5c8fa7f 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -583,8 +583,8 @@ static void tcp_v4_send_reset(struct sock *sk, stru=
ct sk_buff *skb)
 		rep.th.doff =3D arg.iov[0].iov_len / 4;
=20
 		tcp_v4_md5_hash_hdr((__u8 *) &rep.opt[1],
-				     key, ip_hdr(skb)->daddr,
-				     ip_hdr(skb)->saddr, &rep.th);
+				     key, ip_hdr(skb)->saddr,
+				     ip_hdr(skb)->daddr, &rep.th);
 	}
 #endif
 	arg.csum =3D csum_tcpudp_nofold(ip_hdr(skb)->daddr,
diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index 9c9ecf4..2084f5a 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -1006,8 +1006,8 @@ static void tcp_v6_send_reset(struct sock *sk, st=
ruct sk_buff *skb)
 			       (TCPOPT_MD5SIG << 8) |
 			       TCPOLEN_MD5SIG);
 		tcp_v6_md5_hash_hdr((__u8 *)&opt[1], key,
-				    &ipv6_hdr(skb)->daddr,
-				    &ipv6_hdr(skb)->saddr, t1);
+				    &ipv6_hdr(skb)->saddr,
+				    &ipv6_hdr(skb)->daddr, t1);
 	}
 #endif
=20
--=20
1.5.2.2

