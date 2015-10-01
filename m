From: David Ahern <dsa@cumulusnetworks.com>
Subject: [PATCH net-next v2] net: Fix unused variable compile warning
Date: Thu,  1 Oct 2015 08:49:04 -0700
Message-ID: <1443714544-21595-1-git-send-email-dsa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: dsahern@gmail.com, David Ahern <dsa@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f48.google.com ([209.85.220.48]:33683 "EHLO
	mail-pa0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753223AbbJAPtK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Oct 2015 11:49:10 -0400
Received: by pacex6 with SMTP id ex6so78244308pac.0
        for <netdev@vger.kernel.org>; Thu, 01 Oct 2015 08:49:10 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

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
---
v2
- removed unrelated change from other work

 net/netfilter/ipvs/ip_vs_core.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_core.c b/net/netfilter/ipvs/ip_vs=
_core.c
index 37dd77a3d0fb..9897e6272015 100644
--- a/net/netfilter/ipvs/ip_vs_core.c
+++ b/net/netfilter/ipvs/ip_vs_core.c
@@ -1174,7 +1174,6 @@ handle_response(int af, struct sk_buff *skb, stru=
ct ip_vs_proto_data *pd,
 static unsigned int
 ip_vs_out(struct netns_ipvs *ipvs, unsigned int hooknum, struct sk_buf=
f *skb, int af)
 {
-	struct net *net =3D ipvs->net;
 	struct ip_vs_iphdr iph;
 	struct ip_vs_protocol *pp;
 	struct ip_vs_proto_data *pd;
@@ -1274,7 +1273,7 @@ ip_vs_out(struct netns_ipvs *ipvs, unsigned int h=
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
1.9.1
