From: Julia Lawall <Julia.Lawall@lip6.fr>
Subject: [PATCH 1/2] ipv4: constify net_protocol structures
Date: Sat, 29 Jul 2017 08:16:55 +0200
Message-ID: <1501309016-16059-2-git-send-email-Julia.Lawall@lip6.fr>
References: <1501309016-16059-1-git-send-email-Julia.Lawall@lip6.fr>
Cc: bhumirks@gmail.com, kernel-janitors@vger.kernel.org,
        Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
        Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1501309016-16059-1-git-send-email-Julia.Lawall@lip6.fr>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The net_protocol structures are only passed as the first argument to
inet_add_protocol, which is declared as const.  Thus the net_protocol
structures themselves can be const.

Done with the help of Coccinelle.

// <smpl>
@r disable optional_qualifier@
identifier i;
position p;
@@
static struct net_protocol i@p = { ... };

@ok1@
identifier r.i;
expression e1;
position p;
@@
 inet_add_protocol(&i@p,...)

@bad@
position p != {r.p,ok1.p};
identifier r.i;
struct net_protocol e;
@@
e@i@p

@depends on !bad disable optional_qualifier@
identifier r.i;
@@
static
+const
 struct net_protocol i = { ... };
// </smpl>

Signed-off-by: Julia Lawall <Julia.Lawall@lip6.fr>

---
 net/ipv4/af_inet.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/ipv4/af_inet.c b/net/ipv4/af_inet.c
index 5ce44fb..2e38624 100644
--- a/net/ipv4/af_inet.c
+++ b/net/ipv4/af_inet.c
@@ -1594,7 +1594,7 @@ u64 snmp_fold_field64(void __percpu *mib, int offt, size_t syncp_offset)
 };
 #endif
 
-static struct net_protocol tcp_protocol = {
+static const struct net_protocol tcp_protocol = {
 	.early_demux	=	tcp_v4_early_demux,
 	.early_demux_handler =  tcp_v4_early_demux,
 	.handler	=	tcp_v4_rcv,
@@ -1604,7 +1604,7 @@ u64 snmp_fold_field64(void __percpu *mib, int offt, size_t syncp_offset)
 	.icmp_strict_tag_validation = 1,
 };
 
-static struct net_protocol udp_protocol = {
+static const struct net_protocol udp_protocol = {
 	.early_demux =	udp_v4_early_demux,
 	.early_demux_handler =	udp_v4_early_demux,
 	.handler =	udp_rcv,
