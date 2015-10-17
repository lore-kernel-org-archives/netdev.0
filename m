From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 10/35] ipvs: Remove possibly unused variable from ip_vs_out
Date: Sat, 17 Oct 2015 13:32:45 +0200
Message-ID: <1445081590-2924-11-git-send-email-pablo@netfilter.org>
References: <1445081590-2924-1-git-send-email-pablo@netfilter.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:48357 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752610AbbJQL0S (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 17 Oct 2015 07:26:18 -0400
In-Reply-To: <1445081590-2924-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: David Ahern <dsa@cumulusnetworks.com>

Eric's net namespace changes in 1b75097dd7a26 leaves net unreferenced i=
f
CONFIG_IP_VS_IPV6 is not enabled:

=2E./net/netfilter/ipvs/ip_vs_core.c: In function =E2=80=98ip_vs_out=E2=
=80=99:
=2E./net/netfilter/ipvs/ip_vs_core.c:1177:14: warning: unused variable =
=E2=80=98net=E2=80=99 [-Wunused-variable]

After the net refactoring there is only 1 user; push the reference to t=
he
1 user. While the line length slightly exceeds 80 it seems to be the
best change.

=46ixes: 1b75097dd7a26("ipvs: Pass ipvs into ip_vs_out")
Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
Acked-by: Julian Anastasov <ja@ssi.bg>
[horms: updated subject]
Signed-off-by: Simon Horman <horms@verge.net.au>
---
 net/netfilter/ipvs/ip_vs_core.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_core.c b/net/netfilter/ipvs/ip_vs=
_core.c
index d08df43..3773154 100644
--- a/net/netfilter/ipvs/ip_vs_core.c
+++ b/net/netfilter/ipvs/ip_vs_core.c
@@ -1172,7 +1172,6 @@ drop:
 static unsigned int
 ip_vs_out(struct netns_ipvs *ipvs, unsigned int hooknum, struct sk_buf=
f *skb, int af)
 {
-	struct net *net =3D ipvs->net;
 	struct ip_vs_iphdr iph;
 	struct ip_vs_protocol *pp;
 	struct ip_vs_proto_data *pd;
@@ -1272,7 +1271,7 @@ ip_vs_out(struct netns_ipvs *ipvs, unsigned int h=
ooknum, struct sk_buff *skb, in
 #ifdef CONFIG_IP_VS_IPV6
 				if (af =3D=3D AF_INET6) {
 					if (!skb->dev)
-						skb->dev =3D net->loopback_dev;
+						skb->dev =3D ipvs->net->loopback_dev;
 					icmpv6_send(skb,
 						    ICMPV6_DEST_UNREACH,
 						    ICMPV6_PORT_UNREACH,
--=20
2.1.4
