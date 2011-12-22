From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: BUG: unable to handle kernel NULL pointer dereference in
 ipv6_select_ident
Date: Thu, 22 Dec 2011 15:15:53 +0100
Message-ID: <1324563353.2153.27.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
References: <4EF200BB.7000209@bootc.net>
	   <1324484956.2301.24.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	   <4EF2117F.6000803@bootc.net>
	   <1324488984.2301.45.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	   <1324490401.2301.46.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	   <4EF23BF2.4000601@bootc.net> <1324499332.2621.7.camel@edumazet-laptop>
	  <1324500775.2621.9.camel@edumazet-laptop> <4EF2568C.6040006@bootc.net>
	  <AEC29013-98F3-4A16-A88B-AD31C9E88EB8@bootc.net>
	 <1324528656.2621.19.camel@edumazet-laptop> <4EF300B2.3050903@bootc.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: lkml <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>,
	Steffen Klassert <steffen.klassert@secunet.com>
To: Chris Boot <bootc@bootc.net>, David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f174.google.com ([74.125.82.174]:39635 "EHLO
	mail-we0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750958Ab1LVOP6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Dec 2011 09:15:58 -0500
In-Reply-To: <4EF300B2.3050903@bootc.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 22 d=C3=A9cembre 2011 =C3=A0 10:04 +0000, Chris Boot a =C3=A9c=
rit :

> Eric,
>=20
> So far so good. I've had this running for several hours this morning=20
> with more of the prodding that would normally have crashed it, both I=
Pv4=20
> and IPv6, and it's holding up well.
>=20

Thanks for testing.

Here is the official patch then (the .mtu() bit belongs to a separate
patch)

[PATCH] net: introduce DST_NOPEER dst flag

Chris Boot reported crashes occurring in ipv6_select_ident().

[  461.457562] RIP: 0010:[<ffffffff812dde61>]  [<ffffffff812dde61>]=20
ipv6_select_ident+0x31/0xa7

[  461.578229] Call Trace:
[  461.580742] <IRQ>
[  461.582870]  [<ffffffff812efa7f>] ? udp6_ufo_fragment+0x124/0x1a2
[  461.589054]  [<ffffffff812dbfe0>] ? ipv6_gso_segment+0xc0/0x155
[  461.595140]  [<ffffffff812700c6>] ? skb_gso_segment+0x208/0x28b
[  461.601198]  [<ffffffffa03f236b>] ? ipv6_confirm+0x146/0x15e=20
[nf_conntrack_ipv6]
[  461.608786]  [<ffffffff81291c4d>] ? nf_iterate+0x41/0x77
[  461.614227]  [<ffffffff81271d64>] ? dev_hard_start_xmit+0x357/0x543
[  461.620659]  [<ffffffff81291cf6>] ? nf_hook_slow+0x73/0x111
[  461.626440]  [<ffffffffa0379745>] ? br_parse_ip_options+0x19a/0x19a=20
[bridge]
[  461.633581]  [<ffffffff812722ff>] ? dev_queue_xmit+0x3af/0x459
[  461.639577]  [<ffffffffa03747d2>] ? br_dev_queue_push_xmit+0x72/0x76=
=20
[bridge]
[  461.646887]  [<ffffffffa03791e3>] ? br_nf_post_routing+0x17d/0x18f=20
[bridge]
[  461.653997]  [<ffffffff81291c4d>] ? nf_iterate+0x41/0x77
[  461.659473]  [<ffffffffa0374760>] ? br_flood+0xfa/0xfa [bridge]
[  461.665485]  [<ffffffff81291cf6>] ? nf_hook_slow+0x73/0x111
[  461.671234]  [<ffffffffa0374760>] ? br_flood+0xfa/0xfa [bridge]
[  461.677299]  [<ffffffffa0379215>] ?=20
nf_bridge_update_protocol+0x20/0x20 [bridge]
[  461.684891]  [<ffffffffa03bb0e5>] ? nf_ct_zone+0xa/0x17 [nf_conntrac=
k]
[  461.691520]  [<ffffffffa0374760>] ? br_flood+0xfa/0xfa [bridge]
[  461.697572]  [<ffffffffa0374812>] ? NF_HOOK.constprop.8+0x3c/0x56=20
[bridge]
[  461.704616]  [<ffffffffa0379031>] ?=20
nf_bridge_push_encap_header+0x1c/0x26 [bridge]
[  461.712329]  [<ffffffffa037929f>] ? br_nf_forward_finish+0x8a/0x95=20
[bridge]
[  461.719490]  [<ffffffffa037900a>] ?=20
nf_bridge_pull_encap_header+0x1c/0x27 [bridge]
[  461.727223]  [<ffffffffa0379974>] ? br_nf_forward_ip+0x1c0/0x1d4 [br=
idge]
[  461.734292]  [<ffffffff81291c4d>] ? nf_iterate+0x41/0x77
[  461.739758]  [<ffffffffa03748cc>] ? __br_deliver+0xa0/0xa0 [bridge]
[  461.746203]  [<ffffffff81291cf6>] ? nf_hook_slow+0x73/0x111
[  461.751950]  [<ffffffffa03748cc>] ? __br_deliver+0xa0/0xa0 [bridge]
[  461.758378]  [<ffffffffa037533a>] ? NF_HOOK.constprop.4+0x56/0x56=20
[bridge]

This is caused by bridge netfilter special dst_entry (fake_rtable), a
special shared entry, where attaching an inetpeer makes no sense.

Problem is present since commit 87c48fa3b46 (ipv6: make fragment
identifications less predictable)

Introduce DST_NOPEER dst flag and make sure ipv6_select_ident() and
__ip_select_ident() fallback to the 'no peer attached' handling.

Reported-by: Chris Boot <bootc@bootc.net>
Tested-by: Chris Boot <bootc@bootc.net>
Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 include/net/dst.h         |    1 +
 net/bridge/br_netfilter.c |    2 +-
 net/ipv4/route.c          |    4 ++--
 net/ipv6/ip6_output.c     |    2 +-
 4 files changed, 5 insertions(+), 4 deletions(-)

diff --git a/include/net/dst.h b/include/net/dst.h
index 6faec1a..75766b4 100644
--- a/include/net/dst.h
+++ b/include/net/dst.h
@@ -53,6 +53,7 @@ struct dst_entry {
 #define DST_NOHASH		0x0008
 #define DST_NOCACHE		0x0010
 #define DST_NOCOUNT		0x0020
+#define DST_NOPEER		0x0040
=20
 	short			error;
 	short			obsolete;
diff --git a/net/bridge/br_netfilter.c b/net/bridge/br_netfilter.c
index d6ec372..5693e5f 100644
--- a/net/bridge/br_netfilter.c
+++ b/net/bridge/br_netfilter.c
@@ -141,7 +141,7 @@ void br_netfilter_rtable_init(struct net_bridge *br=
)
 	rt->dst.dev =3D br->dev;
 	rt->dst.path =3D &rt->dst;
 	dst_init_metrics(&rt->dst, br_dst_default_metrics, true);
-	rt->dst.flags	=3D DST_NOXFRM;
+	rt->dst.flags	=3D DST_NOXFRM | DST_NOPEER;
 	rt->dst.ops =3D &fake_dst_ops;
 }
=20
diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index 252c512..a5004f1 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -1366,7 +1366,7 @@ void __ip_select_ident(struct iphdr *iph, struct =
dst_entry *dst, int more)
 {
 	struct rtable *rt =3D (struct rtable *) dst;
=20
-	if (rt) {
+	if (rt && !(rt->dst.flags & DST_NOPEER)) {
 		if (rt->peer =3D=3D NULL)
 			rt_bind_peer(rt, rt->rt_dst, 1);
=20
@@ -1377,7 +1377,7 @@ void __ip_select_ident(struct iphdr *iph, struct =
dst_entry *dst, int more)
 			iph->id =3D htons(inet_getid(rt->peer, more));
 			return;
 		}
-	} else
+	} else if (!rt)
 		printk(KERN_DEBUG "rt_bind_peer(0) @%p\n",
 		       __builtin_return_address(0));
=20
diff --git a/net/ipv6/ip6_output.c b/net/ipv6/ip6_output.c
index 84d0bd5..ec56271 100644
--- a/net/ipv6/ip6_output.c
+++ b/net/ipv6/ip6_output.c
@@ -603,7 +603,7 @@ void ipv6_select_ident(struct frag_hdr *fhdr, struc=
t rt6_info *rt)
 	static atomic_t ipv6_fragmentation_id;
 	int old, new;
=20
-	if (rt) {
+	if (rt && !(rt->dst.flags & DST_NOPEER)) {
 		struct inet_peer *peer;
=20
 		if (!rt->rt6i_peer)
