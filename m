From: Julia Lawall <Julia.Lawall@lip6.fr>
Subject: [PATCH 1/2] ipv6: constify inet6_protocol structures
Date: Fri, 28 Jul 2017 22:18:57 +0200
Message-ID: <1501273138-22771-2-git-send-email-Julia.Lawall@lip6.fr>
References: <1501273138-22771-1-git-send-email-Julia.Lawall@lip6.fr>
Cc: kernel-janitors@vger.kernel.org, bhumirks@gmail.com,
        Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
        Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1501273138-22771-1-git-send-email-Julia.Lawall@lip6.fr>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The inet6_protocol structure is only passed as the first argument to
inet6_add_protocol or inet6_del_protocol, both of which are declared as
const.  Thus the inet6_protocol structure itself can be const.

Also drop __read_mostly where present on the newly const structures.

Done with the help of Coccinelle.

Signed-off-by: Julia Lawall <Julia.Lawall@lip6.fr>

---
 net/ipv6/ip6_gre.c  |    2 +-
 net/ipv6/tcp_ipv6.c |    2 +-
 net/ipv6/udp.c      |    2 +-
 3 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/net/ipv6/ip6_gre.c b/net/ipv6/ip6_gre.c
index 67ff2aa..33865d6 100644
--- a/net/ipv6/ip6_gre.c
+++ b/net/ipv6/ip6_gre.c
@@ -1080,7 +1080,7 @@ static void ip6gre_fb_tunnel_init(struct net_device *dev)
 }
 
 
-static struct inet6_protocol ip6gre_protocol __read_mostly = {
+static const struct inet6_protocol ip6gre_protocol = {
 	.handler     = gre_rcv,
 	.err_handler = ip6gre_err,
 	.flags       = INET6_PROTO_NOPOLICY|INET6_PROTO_FINAL,
diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index 90a3257..2968a33 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -1945,7 +1945,7 @@ struct proto tcpv6_prot = {
 	.diag_destroy		= tcp_abort,
 };
 
-static struct inet6_protocol tcpv6_protocol = {
+static const struct inet6_protocol tcpv6_protocol = {
 	.early_demux	=	tcp_v6_early_demux,
 	.early_demux_handler =  tcp_v6_early_demux,
 	.handler	=	tcp_v6_rcv,
diff --git a/net/ipv6/udp.c b/net/ipv6/udp.c
index 4a3e656..5f8b8d7 100644
--- a/net/ipv6/udp.c
+++ b/net/ipv6/udp.c
@@ -1448,7 +1448,7 @@ int compat_udpv6_getsockopt(struct sock *sk, int level, int optname,
 }
 #endif
 
-static struct inet6_protocol udpv6_protocol = {
+static const struct inet6_protocol udpv6_protocol = {
 	.early_demux	=	udp_v6_early_demux,
 	.early_demux_handler =  udp_v6_early_demux,
 	.handler	=	udpv6_rcv,
