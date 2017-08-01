From: Julia Lawall <Julia.Lawall@lip6.fr>
Subject: [PATCH 1/2] Revert "ipv6: constify inet6_protocol structures"
Date: Tue,  1 Aug 2017 18:27:28 +0200
Message-ID: <1501604849-19443-2-git-send-email-Julia.Lawall@lip6.fr>
References: <1501604849-19443-1-git-send-email-Julia.Lawall@lip6.fr>
Cc: kernel-janitors@vger.kernel.org, bhumirks@gmail.com,
        Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
        Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>,
        Eric Dumazet <eric.dumazet@gmail.com>,
        David Ahern <dsahern@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1501604849-19443-1-git-send-email-Julia.Lawall@lip6.fr>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This reverts commit 3a3a4e3054137c5ff5d4d306ec834f6d25d7f95b.

inet6_add_protocol and inet6_del_protocol include casts that remove the
effect of the const annotation on their parameter, leading to possible
runtime crashes.

Reported-by: Eric Dumazet <eric.dumazet@gmail.com>
Signed-off-by: Julia Lawall <Julia.Lawall@lip6.fr>

---

 net/ipv6/ip6_gre.c  |    2 +-
 net/ipv6/tcp_ipv6.c |    2 +-
 net/ipv6/udp.c      |    2 +-
 3 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/net/ipv6/ip6_gre.c b/net/ipv6/ip6_gre.c
index 33865d6..67ff2aa 100644
--- a/net/ipv6/ip6_gre.c
+++ b/net/ipv6/ip6_gre.c
@@ -1080,7 +1080,7 @@ static void ip6gre_fb_tunnel_init(struct net_device *dev)
 }
 
 
-static const struct inet6_protocol ip6gre_protocol = {
+static struct inet6_protocol ip6gre_protocol __read_mostly = {
 	.handler     = gre_rcv,
 	.err_handler = ip6gre_err,
 	.flags       = INET6_PROTO_NOPOLICY|INET6_PROTO_FINAL,
diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index 39ee8e7..ced5dcf 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -1944,7 +1944,7 @@ struct proto tcpv6_prot = {
 	.diag_destroy		= tcp_abort,
 };
 
-static const struct inet6_protocol tcpv6_protocol = {
+static struct inet6_protocol tcpv6_protocol = {
 	.early_demux	=	tcp_v6_early_demux,
 	.early_demux_handler =  tcp_v6_early_demux,
 	.handler	=	tcp_v6_rcv,
diff --git a/net/ipv6/udp.c b/net/ipv6/udp.c
index 7e6d7f5..98fe456 100644
--- a/net/ipv6/udp.c
+++ b/net/ipv6/udp.c
@@ -1457,7 +1457,7 @@ int compat_udpv6_getsockopt(struct sock *sk, int level, int optname,
 }
 #endif
 
-static const struct inet6_protocol udpv6_protocol = {
+static struct inet6_protocol udpv6_protocol = {
 	.early_demux	=	udp_v6_early_demux,
 	.early_demux_handler =  udp_v6_early_demux,
 	.handler	=	udpv6_rcv,
