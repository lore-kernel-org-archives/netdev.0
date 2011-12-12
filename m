From: igorm@etf.rs
Subject: [PATCH 3/4 net-next] net:netfilter: use IS_ENABLED
Date: Mon, 12 Dec 2011 04:58:24 -0800
Message-ID: <1323694705-2793-3-git-send-email-igorm@etf.rs>
References: <igorm@etf.rs>
 <1323694705-2793-1-git-send-email-igorm@etf.rs>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, =?UTF-8?q?Igor=20Maravi=C4=87?= <igorm@etf.rs>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.etf.rs ([147.91.14.169]:47693 "EHLO mx1.etf.bg.ac.rs"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753027Ab1LLM7B convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Dec 2011 07:59:01 -0500
In-Reply-To: <1323694705-2793-1-git-send-email-igorm@etf.rs>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Igor Maravi=C4=87 <igorm@etf.rs>

Use IS_ENABLED(CONFIG_FOO)
instead of defined(CONFIG_FOO) || defined (CONFIG_FOO_MODULE)

Signed-off-by: Igor Maravi=C4=87 <igorm@etf.rs>
---
 net/netfilter/core.c                       |    2 +-
 net/netfilter/ipset/ip_set_getport.c       |    2 +-
 net/netfilter/ipvs/ip_vs_xmit.c            |    8 ++++----
 net/netfilter/nf_conntrack_core.c          |    2 +-
 net/netfilter/nf_conntrack_h323_main.c     |    3 +--
 net/netfilter/nf_conntrack_proto_dccp.c    |    6 +++---
 net/netfilter/nf_conntrack_proto_gre.c     |    2 +-
 net/netfilter/nf_conntrack_proto_sctp.c    |    6 +++---
 net/netfilter/nf_conntrack_proto_tcp.c     |    6 +++---
 net/netfilter/nf_conntrack_proto_udp.c     |    4 ++--
 net/netfilter/nf_conntrack_proto_udplite.c |    4 ++--
 net/netfilter/xt_NFQUEUE.c                 |    4 ++--
 net/netfilter/xt_TCPMSS.c                  |    6 +++---
 net/netfilter/xt_TCPOPTSTRIP.c             |    4 ++--
 net/netfilter/xt_TEE.c                     |    2 +-
 net/netfilter/xt_TPROXY.c                  |    2 +-
 net/netfilter/xt_addrtype.c                |    8 ++++----
 net/netfilter/xt_hashlimit.c               |   16 ++++++++--------
 net/netfilter/xt_socket.c                  |    4 ++--
 19 files changed, 45 insertions(+), 46 deletions(-)

diff --git a/net/netfilter/core.c b/net/netfilter/core.c
index 4aa0f4b..b4e8ff0 100644
--- a/net/netfilter/core.c
+++ b/net/netfilter/core.c
@@ -229,7 +229,7 @@ int skb_make_writable(struct sk_buff *skb, unsigned=
 int writable_len)
 }
 EXPORT_SYMBOL(skb_make_writable);
=20
-#if defined(CONFIG_NF_CONNTRACK) || defined(CONFIG_NF_CONNTRACK_MODULE=
)
+#if IS_ENABLED(CONFIG_NF_CONNTRACK)
 /* This does not belong here, but locally generated errors need it if =
connection
    tracking in use: without this, connection may not be in hash table,=
 and hence
    manufactured ICMP or RST packets will not be associated with it. */
diff --git a/net/netfilter/ipset/ip_set_getport.c b/net/netfilter/ipset=
/ip_set_getport.c
index b71a6e7..1f03556 100644
--- a/net/netfilter/ipset/ip_set_getport.c
+++ b/net/netfilter/ipset/ip_set_getport.c
@@ -109,7 +109,7 @@ ip_set_get_ip4_port(const struct sk_buff *skb, bool=
 src,
 }
 EXPORT_SYMBOL_GPL(ip_set_get_ip4_port);
=20
-#if defined(CONFIG_IP6_NF_IPTABLES) || defined(CONFIG_IP6_NF_IPTABLES_=
MODULE)
+#if IS_ENABLED(CONFIG_IP6_NF_IPTABLES)
 bool
 ip_set_get_ip6_port(const struct sk_buff *skb, bool src,
 		    __be16 *port, u8 *proto)
diff --git a/net/netfilter/ipvs/ip_vs_xmit.c b/net/netfilter/ipvs/ip_vs=
_xmit.c
index 38a576d..72b82b8 100644
--- a/net/netfilter/ipvs/ip_vs_xmit.c
+++ b/net/netfilter/ipvs/ip_vs_xmit.c
@@ -541,7 +541,7 @@ ip_vs_nat_xmit(struct sk_buff *skb, struct ip_vs_co=
nn *cp,
 	 * Avoid duplicate tuple in reply direction for NAT traffic
 	 * to local address when connection is sync-ed
 	 */
-#if defined(CONFIG_NF_CONNTRACK) || defined(CONFIG_NF_CONNTRACK_MODULE=
)
+#if IS_ENABLED(CONFIG_NF_CONNTRACK)
 	if (cp->flags & IP_VS_CONN_F_SYNC && local) {
 		enum ip_conntrack_info ctinfo;
 		struct nf_conn *ct =3D ct =3D nf_ct_get(skb, &ctinfo);
@@ -658,7 +658,7 @@ ip_vs_nat_xmit_v6(struct sk_buff *skb, struct ip_vs=
_conn *cp,
 	 * Avoid duplicate tuple in reply direction for NAT traffic
 	 * to local address when connection is sync-ed
 	 */
-#if defined(CONFIG_NF_CONNTRACK) || defined(CONFIG_NF_CONNTRACK_MODULE=
)
+#if IS_ENABLED(CONFIG_NF_CONNTRACK)
 	if (cp->flags & IP_VS_CONN_F_SYNC && local) {
 		enum ip_conntrack_info ctinfo;
 		struct nf_conn *ct =3D ct =3D nf_ct_get(skb, &ctinfo);
@@ -1173,7 +1173,7 @@ ip_vs_icmp_xmit(struct sk_buff *skb, struct ip_vs=
_conn *cp,
 	 * Avoid duplicate tuple in reply direction for NAT traffic
 	 * to local address when connection is sync-ed
 	 */
-#if defined(CONFIG_NF_CONNTRACK) || defined(CONFIG_NF_CONNTRACK_MODULE=
)
+#if IS_ENABLED(CONFIG_NF_CONNTRACK)
 	if (cp->flags & IP_VS_CONN_F_SYNC && local) {
 		enum ip_conntrack_info ctinfo;
 		struct nf_conn *ct =3D ct =3D nf_ct_get(skb, &ctinfo);
@@ -1293,7 +1293,7 @@ ip_vs_icmp_xmit_v6(struct sk_buff *skb, struct ip=
_vs_conn *cp,
 	 * Avoid duplicate tuple in reply direction for NAT traffic
 	 * to local address when connection is sync-ed
 	 */
-#if defined(CONFIG_NF_CONNTRACK) || defined(CONFIG_NF_CONNTRACK_MODULE=
)
+#if IS_ENABLED(CONFIG_NF_CONNTRACK)
 	if (cp->flags & IP_VS_CONN_F_SYNC && local) {
 		enum ip_conntrack_info ctinfo;
 		struct nf_conn *ct =3D ct =3D nf_ct_get(skb, &ctinfo);
diff --git a/net/netfilter/nf_conntrack_core.c b/net/netfilter/nf_connt=
rack_core.c
index 7202b06..32279dc 100644
--- a/net/netfilter/nf_conntrack_core.c
+++ b/net/netfilter/nf_conntrack_core.c
@@ -1087,7 +1087,7 @@ static struct nf_ct_ext_type nf_ct_zone_extend __=
read_mostly =3D {
 };
 #endif
=20
-#if defined(CONFIG_NF_CT_NETLINK) || defined(CONFIG_NF_CT_NETLINK_MODU=
LE)
+#if IS_ENABLED(CONFIG_NF_CT_NETLINK)
=20
 #include <linux/netfilter/nfnetlink.h>
 #include <linux/netfilter/nfnetlink_conntrack.h>
diff --git a/net/netfilter/nf_conntrack_h323_main.c b/net/netfilter/nf_=
conntrack_h323_main.c
index f9368f3..813ad39 100644
--- a/net/netfilter/nf_conntrack_h323_main.c
+++ b/net/netfilter/nf_conntrack_h323_main.c
@@ -743,8 +743,7 @@ static int callforward_do_filter(const union nf_ine=
t_addr *src,
 		}
 		break;
 	}
-#if defined(CONFIG_NF_CONNTRACK_IPV6) || \
-    defined(CONFIG_NF_CONNTRACK_IPV6_MODULE)
+#if IS_ENABLED(CONFIG_NF_CONNTRACK_IPV6)
 	case AF_INET6: {
 		struct flowi6 fl1, fl2;
 		struct rt6_info *rt1, *rt2;
diff --git a/net/netfilter/nf_conntrack_proto_dccp.c b/net/netfilter/nf=
_conntrack_proto_dccp.c
index 2e664a6..d6dde6d 100644
--- a/net/netfilter/nf_conntrack_proto_dccp.c
+++ b/net/netfilter/nf_conntrack_proto_dccp.c
@@ -629,7 +629,7 @@ static int dccp_print_conntrack(struct seq_file *s,=
 struct nf_conn *ct)
 	return seq_printf(s, "%s ", dccp_state_names[ct->proto.dccp.state]);
 }
=20
-#if defined(CONFIG_NF_CT_NETLINK) || defined(CONFIG_NF_CT_NETLINK_MODU=
LE)
+#if IS_ENABLED(CONFIG_NF_CT_NETLINK)
 static int dccp_to_nlattr(struct sk_buff *skb, struct nlattr *nla,
 			  struct nf_conn *ct)
 {
@@ -770,7 +770,7 @@ static struct nf_conntrack_l4proto dccp_proto4 __re=
ad_mostly =3D {
 	.error			=3D dccp_error,
 	.print_tuple		=3D dccp_print_tuple,
 	.print_conntrack	=3D dccp_print_conntrack,
-#if defined(CONFIG_NF_CT_NETLINK) || defined(CONFIG_NF_CT_NETLINK_MODU=
LE)
+#if IS_ENABLED(CONFIG_NF_CT_NETLINK)
 	.to_nlattr		=3D dccp_to_nlattr,
 	.nlattr_size		=3D dccp_nlattr_size,
 	.from_nlattr		=3D nlattr_to_dccp,
@@ -792,7 +792,7 @@ static struct nf_conntrack_l4proto dccp_proto6 __re=
ad_mostly =3D {
 	.error			=3D dccp_error,
 	.print_tuple		=3D dccp_print_tuple,
 	.print_conntrack	=3D dccp_print_conntrack,
-#if defined(CONFIG_NF_CT_NETLINK) || defined(CONFIG_NF_CT_NETLINK_MODU=
LE)
+#if IS_ENABLED(CONFIG_NF_CT_NETLINK)
 	.to_nlattr		=3D dccp_to_nlattr,
 	.nlattr_size		=3D dccp_nlattr_size,
 	.from_nlattr		=3D nlattr_to_dccp,
diff --git a/net/netfilter/nf_conntrack_proto_gre.c b/net/netfilter/nf_=
conntrack_proto_gre.c
index d69facd..f033879 100644
--- a/net/netfilter/nf_conntrack_proto_gre.c
+++ b/net/netfilter/nf_conntrack_proto_gre.c
@@ -291,7 +291,7 @@ static struct nf_conntrack_l4proto nf_conntrack_l4p=
roto_gre4 __read_mostly =3D {
 	.new		 =3D gre_new,
 	.destroy	 =3D gre_destroy,
 	.me 		 =3D THIS_MODULE,
-#if defined(CONFIG_NF_CT_NETLINK) || defined(CONFIG_NF_CT_NETLINK_MODU=
LE)
+#if IS_ENABLED(CONFIG_NF_CT_NETLINK)
 	.tuple_to_nlattr =3D nf_ct_port_tuple_to_nlattr,
 	.nlattr_tuple_size =3D nf_ct_port_nlattr_tuple_size,
 	.nlattr_to_tuple =3D nf_ct_port_nlattr_to_tuple,
diff --git a/net/netfilter/nf_conntrack_proto_sctp.c b/net/netfilter/nf=
_conntrack_proto_sctp.c
index 6772b11..afa6913 100644
--- a/net/netfilter/nf_conntrack_proto_sctp.c
+++ b/net/netfilter/nf_conntrack_proto_sctp.c
@@ -461,7 +461,7 @@ static bool sctp_new(struct nf_conn *ct, const stru=
ct sk_buff *skb,
 	return true;
 }
=20
-#if defined(CONFIG_NF_CT_NETLINK) || defined(CONFIG_NF_CT_NETLINK_MODU=
LE)
+#if IS_ENABLED(CONFIG_NF_CT_NETLINK)
=20
 #include <linux/netfilter/nfnetlink.h>
 #include <linux/netfilter/nfnetlink_conntrack.h>
@@ -666,7 +666,7 @@ static struct nf_conntrack_l4proto nf_conntrack_l4p=
roto_sctp4 __read_mostly =3D {
 	.packet 		=3D sctp_packet,
 	.new 			=3D sctp_new,
 	.me 			=3D THIS_MODULE,
-#if defined(CONFIG_NF_CT_NETLINK) || defined(CONFIG_NF_CT_NETLINK_MODU=
LE)
+#if IS_ENABLED(CONFIG_NF_CT_NETLINK)
 	.to_nlattr		=3D sctp_to_nlattr,
 	.nlattr_size		=3D sctp_nlattr_size,
 	.from_nlattr		=3D nlattr_to_sctp,
@@ -696,7 +696,7 @@ static struct nf_conntrack_l4proto nf_conntrack_l4p=
roto_sctp6 __read_mostly =3D {
 	.packet 		=3D sctp_packet,
 	.new 			=3D sctp_new,
 	.me 			=3D THIS_MODULE,
-#if defined(CONFIG_NF_CT_NETLINK) || defined(CONFIG_NF_CT_NETLINK_MODU=
LE)
+#if IS_ENABLED(CONFIG_NF_CT_NETLINK)
 	.to_nlattr		=3D sctp_to_nlattr,
 	.nlattr_size		=3D sctp_nlattr_size,
 	.from_nlattr		=3D nlattr_to_sctp,
diff --git a/net/netfilter/nf_conntrack_proto_tcp.c b/net/netfilter/nf_=
conntrack_proto_tcp.c
index 8235b86..97b9f3e 100644
--- a/net/netfilter/nf_conntrack_proto_tcp.c
+++ b/net/netfilter/nf_conntrack_proto_tcp.c
@@ -1126,7 +1126,7 @@ static bool tcp_new(struct nf_conn *ct, const str=
uct sk_buff *skb,
 	return true;
 }
=20
-#if defined(CONFIG_NF_CT_NETLINK) || defined(CONFIG_NF_CT_NETLINK_MODU=
LE)
+#if IS_ENABLED(CONFIG_NF_CT_NETLINK)
=20
 #include <linux/netfilter/nfnetlink.h>
 #include <linux/netfilter/nfnetlink_conntrack.h>
@@ -1447,7 +1447,7 @@ struct nf_conntrack_l4proto nf_conntrack_l4proto_=
tcp4 __read_mostly =3D
 	.packet 		=3D tcp_packet,
 	.new 			=3D tcp_new,
 	.error			=3D tcp_error,
-#if defined(CONFIG_NF_CT_NETLINK) || defined(CONFIG_NF_CT_NETLINK_MODU=
LE)
+#if IS_ENABLED(CONFIG_NF_CT_NETLINK)
 	.to_nlattr		=3D tcp_to_nlattr,
 	.nlattr_size		=3D tcp_nlattr_size,
 	.from_nlattr		=3D nlattr_to_tcp,
@@ -1479,7 +1479,7 @@ struct nf_conntrack_l4proto nf_conntrack_l4proto_=
tcp6 __read_mostly =3D
 	.packet 		=3D tcp_packet,
 	.new 			=3D tcp_new,
 	.error			=3D tcp_error,
-#if defined(CONFIG_NF_CT_NETLINK) || defined(CONFIG_NF_CT_NETLINK_MODU=
LE)
+#if IS_ENABLED(CONFIG_NF_CT_NETLINK)
 	.to_nlattr		=3D tcp_to_nlattr,
 	.nlattr_size		=3D tcp_nlattr_size,
 	.from_nlattr		=3D nlattr_to_tcp,
diff --git a/net/netfilter/nf_conntrack_proto_udp.c b/net/netfilter/nf_=
conntrack_proto_udp.c
index 8289088..5f35757 100644
--- a/net/netfilter/nf_conntrack_proto_udp.c
+++ b/net/netfilter/nf_conntrack_proto_udp.c
@@ -188,7 +188,7 @@ struct nf_conntrack_l4proto nf_conntrack_l4proto_ud=
p4 __read_mostly =3D
 	.packet			=3D udp_packet,
 	.new			=3D udp_new,
 	.error			=3D udp_error,
-#if defined(CONFIG_NF_CT_NETLINK) || defined(CONFIG_NF_CT_NETLINK_MODU=
LE)
+#if IS_ENABLED(CONFIG_NF_CT_NETLINK)
 	.tuple_to_nlattr	=3D nf_ct_port_tuple_to_nlattr,
 	.nlattr_to_tuple	=3D nf_ct_port_nlattr_to_tuple,
 	.nlattr_tuple_size	=3D nf_ct_port_nlattr_tuple_size,
@@ -216,7 +216,7 @@ struct nf_conntrack_l4proto nf_conntrack_l4proto_ud=
p6 __read_mostly =3D
 	.packet			=3D udp_packet,
 	.new			=3D udp_new,
 	.error			=3D udp_error,
-#if defined(CONFIG_NF_CT_NETLINK) || defined(CONFIG_NF_CT_NETLINK_MODU=
LE)
+#if IS_ENABLED(CONFIG_NF_CT_NETLINK)
 	.tuple_to_nlattr	=3D nf_ct_port_tuple_to_nlattr,
 	.nlattr_to_tuple	=3D nf_ct_port_nlattr_to_tuple,
 	.nlattr_tuple_size	=3D nf_ct_port_nlattr_tuple_size,
diff --git a/net/netfilter/nf_conntrack_proto_udplite.c b/net/netfilter=
/nf_conntrack_proto_udplite.c
index 263b5a7..f52ca11 100644
--- a/net/netfilter/nf_conntrack_proto_udplite.c
+++ b/net/netfilter/nf_conntrack_proto_udplite.c
@@ -174,7 +174,7 @@ static struct nf_conntrack_l4proto nf_conntrack_l4p=
roto_udplite4 __read_mostly =3D
 	.packet			=3D udplite_packet,
 	.new			=3D udplite_new,
 	.error			=3D udplite_error,
-#if defined(CONFIG_NF_CT_NETLINK) || defined(CONFIG_NF_CT_NETLINK_MODU=
LE)
+#if IS_ENABLED(CONFIG_NF_CT_NETLINK)
 	.tuple_to_nlattr	=3D nf_ct_port_tuple_to_nlattr,
 	.nlattr_tuple_size	=3D nf_ct_port_nlattr_tuple_size,
 	.nlattr_to_tuple	=3D nf_ct_port_nlattr_to_tuple,
@@ -198,7 +198,7 @@ static struct nf_conntrack_l4proto nf_conntrack_l4p=
roto_udplite6 __read_mostly =3D
 	.packet			=3D udplite_packet,
 	.new			=3D udplite_new,
 	.error			=3D udplite_error,
-#if defined(CONFIG_NF_CT_NETLINK) || defined(CONFIG_NF_CT_NETLINK_MODU=
LE)
+#if IS_ENABLED(CONFIG_NF_CT_NETLINK)
 	.tuple_to_nlattr	=3D nf_ct_port_tuple_to_nlattr,
 	.nlattr_tuple_size	=3D nf_ct_port_nlattr_tuple_size,
 	.nlattr_to_tuple	=3D nf_ct_port_nlattr_to_tuple,
diff --git a/net/netfilter/xt_NFQUEUE.c b/net/netfilter/xt_NFQUEUE.c
index d4f4b5d..95237c8 100644
--- a/net/netfilter/xt_NFQUEUE.c
+++ b/net/netfilter/xt_NFQUEUE.c
@@ -49,7 +49,7 @@ static u32 hash_v4(const struct sk_buff *skb)
 	return jhash_2words((__force u32)ipaddr, iph->protocol, jhash_initval=
);
 }
=20
-#if defined(CONFIG_IP6_NF_IPTABLES) || defined(CONFIG_IP6_NF_IPTABLES_=
MODULE)
+#if IS_ENABLED(CONFIG_IP6_NF_IPTABLES)
 static u32 hash_v6(const struct sk_buff *skb)
 {
 	const struct ipv6hdr *ip6h =3D ipv6_hdr(skb);
@@ -74,7 +74,7 @@ nfqueue_tg_v1(struct sk_buff *skb, const struct xt_ac=
tion_param *par)
 		if (par->family =3D=3D NFPROTO_IPV4)
 			queue =3D (((u64) hash_v4(skb) * info->queues_total) >>
 				 32) + queue;
-#if defined(CONFIG_IP6_NF_IPTABLES) || defined(CONFIG_IP6_NF_IPTABLES_=
MODULE)
+#if IS_ENABLED(CONFIG_IP6_NF_IPTABLES)
 		else if (par->family =3D=3D NFPROTO_IPV6)
 			queue =3D (((u64) hash_v6(skb) * info->queues_total) >>
 				 32) + queue;
diff --git a/net/netfilter/xt_TCPMSS.c b/net/netfilter/xt_TCPMSS.c
index ba72262..190ad37 100644
--- a/net/netfilter/xt_TCPMSS.c
+++ b/net/netfilter/xt_TCPMSS.c
@@ -198,7 +198,7 @@ tcpmss_tg4(struct sk_buff *skb, const struct xt_act=
ion_param *par)
 	return XT_CONTINUE;
 }
=20
-#if defined(CONFIG_IP6_NF_IPTABLES) || defined(CONFIG_IP6_NF_IPTABLES_=
MODULE)
+#if IS_ENABLED(CONFIG_IP6_NF_IPTABLES)
 static unsigned int
 tcpmss_tg6(struct sk_buff *skb, const struct xt_action_param *par)
 {
@@ -260,7 +260,7 @@ static int tcpmss_tg4_check(const struct xt_tgchk_p=
aram *par)
 	return -EINVAL;
 }
=20
-#if defined(CONFIG_IP6_NF_IPTABLES) || defined(CONFIG_IP6_NF_IPTABLES_=
MODULE)
+#if IS_ENABLED(CONFIG_IP6_NF_IPTABLES)
 static int tcpmss_tg6_check(const struct xt_tgchk_param *par)
 {
 	const struct xt_tcpmss_info *info =3D par->targinfo;
@@ -293,7 +293,7 @@ static struct xt_target tcpmss_tg_reg[] __read_most=
ly =3D {
 		.proto		=3D IPPROTO_TCP,
 		.me		=3D THIS_MODULE,
 	},
-#if defined(CONFIG_IP6_NF_IPTABLES) || defined(CONFIG_IP6_NF_IPTABLES_=
MODULE)
+#if IS_ENABLED(CONFIG_IP6_NF_IPTABLES)
 	{
 		.family		=3D NFPROTO_IPV6,
 		.name		=3D "TCPMSS",
diff --git a/net/netfilter/xt_TCPOPTSTRIP.c b/net/netfilter/xt_TCPOPTST=
RIP.c
index 3a295cc..25fd1c4 100644
--- a/net/netfilter/xt_TCPOPTSTRIP.c
+++ b/net/netfilter/xt_TCPOPTSTRIP.c
@@ -80,7 +80,7 @@ tcpoptstrip_tg4(struct sk_buff *skb, const struct xt_=
action_param *par)
 	       sizeof(struct iphdr) + sizeof(struct tcphdr));
 }
=20
-#if defined(CONFIG_IP6_NF_MANGLE) || defined(CONFIG_IP6_NF_MANGLE_MODU=
LE)
+#if IS_ENABLED(CONFIG_IP6_NF_MANGLE)
 static unsigned int
 tcpoptstrip_tg6(struct sk_buff *skb, const struct xt_action_param *par=
)
 {
@@ -109,7 +109,7 @@ static struct xt_target tcpoptstrip_tg_reg[] __read=
_mostly =3D {
 		.targetsize =3D sizeof(struct xt_tcpoptstrip_target_info),
 		.me         =3D THIS_MODULE,
 	},
-#if defined(CONFIG_IP6_NF_MANGLE) || defined(CONFIG_IP6_NF_MANGLE_MODU=
LE)
+#if IS_ENABLED(CONFIG_IP6_NF_MANGLE)
 	{
 		.name       =3D "TCPOPTSTRIP",
 		.family     =3D NFPROTO_IPV6,
diff --git a/net/netfilter/xt_TEE.c b/net/netfilter/xt_TEE.c
index 68349c3..3aae66f 100644
--- a/net/netfilter/xt_TEE.c
+++ b/net/netfilter/xt_TEE.c
@@ -25,7 +25,7 @@
 #include <linux/netfilter/x_tables.h>
 #include <linux/netfilter/xt_TEE.h>
=20
-#if defined(CONFIG_NF_CONNTRACK) || defined(CONFIG_NF_CONNTRACK_MODULE=
)
+#if IS_ENABLED(CONFIG_NF_CONNTRACK)
 #	define WITH_CONNTRACK 1
 #	include <net/netfilter/nf_conntrack.h>
 #endif
diff --git a/net/netfilter/xt_TPROXY.c b/net/netfilter/xt_TPROXY.c
index dcfd57e..35a959a 100644
--- a/net/netfilter/xt_TPROXY.c
+++ b/net/netfilter/xt_TPROXY.c
@@ -22,7 +22,7 @@
=20
 #include <net/netfilter/ipv4/nf_defrag_ipv4.h>
=20
-#if defined(CONFIG_IP6_NF_IPTABLES) || defined(CONFIG_IP6_NF_IPTABLES_=
MODULE)
+#if IS_ENABLED(CONFIG_IP6_NF_IPTABLES)
 #define XT_TPROXY_HAVE_IPV6 1
 #include <net/if_inet6.h>
 #include <net/addrconf.h>
diff --git a/net/netfilter/xt_addrtype.c b/net/netfilter/xt_addrtype.c
index c047de2..49c5ff7 100644
--- a/net/netfilter/xt_addrtype.c
+++ b/net/netfilter/xt_addrtype.c
@@ -16,7 +16,7 @@
 #include <linux/ip.h>
 #include <net/route.h>
=20
-#if defined(CONFIG_IP6_NF_IPTABLES) || defined(CONFIG_IP6_NF_IPTABLES_=
MODULE)
+#if IS_ENABLED(CONFIG_IP6_NF_IPTABLES)
 #include <net/ipv6.h>
 #include <net/ip6_route.h>
 #include <net/ip6_fib.h>
@@ -31,7 +31,7 @@ MODULE_DESCRIPTION("Xtables: address type match");
 MODULE_ALIAS("ipt_addrtype");
 MODULE_ALIAS("ip6t_addrtype");
=20
-#if defined(CONFIG_IP6_NF_IPTABLES) || defined(CONFIG_IP6_NF_IPTABLES_=
MODULE)
+#if IS_ENABLED(CONFIG_IP6_NF_IPTABLES)
 static u32 match_lookup_rt6(struct net *net, const struct net_device *=
dev,
 			    const struct in6_addr *addr)
 {
@@ -149,7 +149,7 @@ addrtype_mt_v1(const struct sk_buff *skb, struct xt=
_action_param *par)
 	else if (info->flags & XT_ADDRTYPE_LIMIT_IFACE_OUT)
 		dev =3D par->out;
=20
-#if defined(CONFIG_IP6_NF_IPTABLES) || defined(CONFIG_IP6_NF_IPTABLES_=
MODULE)
+#if IS_ENABLED(CONFIG_IP6_NF_IPTABLES)
 	if (par->family =3D=3D NFPROTO_IPV6)
 		return addrtype_mt6(net, dev, skb, info);
 #endif
@@ -190,7 +190,7 @@ static int addrtype_mt_checkentry_v1(const struct x=
t_mtchk_param *par)
 		return -EINVAL;
 	}
=20
-#if defined(CONFIG_IP6_NF_IPTABLES) || defined(CONFIG_IP6_NF_IPTABLES_=
MODULE)
+#if IS_ENABLED(CONFIG_IP6_NF_IPTABLES)
 	if (par->family =3D=3D NFPROTO_IPV6) {
 		if ((info->source | info->dest) & XT_ADDRTYPE_BLACKHOLE) {
 			pr_err("ipv6 BLACKHOLE matching not supported\n");
diff --git a/net/netfilter/xt_hashlimit.c b/net/netfilter/xt_hashlimit.=
c
index 068698f..8e49921 100644
--- a/net/netfilter/xt_hashlimit.c
+++ b/net/netfilter/xt_hashlimit.c
@@ -21,7 +21,7 @@
 #include <linux/mm.h>
 #include <linux/in.h>
 #include <linux/ip.h>
-#if defined(CONFIG_IP6_NF_IPTABLES) || defined(CONFIG_IP6_NF_IPTABLES_=
MODULE)
+#if IS_ENABLED(CONFIG_IP6_NF_IPTABLES)
 #include <linux/ipv6.h>
 #include <net/ipv6.h>
 #endif
@@ -64,7 +64,7 @@ struct dsthash_dst {
 			__be32 src;
 			__be32 dst;
 		} ip;
-#if defined(CONFIG_IP6_NF_IPTABLES) || defined(CONFIG_IP6_NF_IPTABLES_=
MODULE)
+#if IS_ENABLED(CONFIG_IP6_NF_IPTABLES)
 		struct {
 			__be32 src[4];
 			__be32 dst[4];
@@ -413,7 +413,7 @@ static inline __be32 maskl(__be32 a, unsigned int l=
)
 	return l ? htonl(ntohl(a) & ~0 << (32 - l)) : 0;
 }
=20
-#if defined(CONFIG_IP6_NF_IPTABLES) || defined(CONFIG_IP6_NF_IPTABLES_=
MODULE)
+#if IS_ENABLED(CONFIG_IP6_NF_IPTABLES)
 static void hashlimit_ipv6_mask(__be32 *i, unsigned int p)
 {
 	switch (p) {
@@ -464,7 +464,7 @@ hashlimit_init_dst(const struct xt_hashlimit_htable=
 *hinfo,
 			return 0;
 		nexthdr =3D ip_hdr(skb)->protocol;
 		break;
-#if defined(CONFIG_IP6_NF_IPTABLES) || defined(CONFIG_IP6_NF_IPTABLES_=
MODULE)
+#if IS_ENABLED(CONFIG_IP6_NF_IPTABLES)
 	case NFPROTO_IPV6:
 		if (hinfo->cfg.mode & XT_HASHLIMIT_HASH_DIP) {
 			memcpy(&dst->ip6.dst, &ipv6_hdr(skb)->daddr,
@@ -616,7 +616,7 @@ static struct xt_match hashlimit_mt_reg[] __read_mo=
stly =3D {
 		.destroy        =3D hashlimit_mt_destroy,
 		.me             =3D THIS_MODULE,
 	},
-#if defined(CONFIG_IP6_NF_IPTABLES) || defined(CONFIG_IP6_NF_IPTABLES_=
MODULE)
+#if IS_ENABLED(CONFIG_IP6_NF_IPTABLES)
 	{
 		.name           =3D "hashlimit",
 		.revision       =3D 1,
@@ -693,7 +693,7 @@ static int dl_seq_real_show(struct dsthash_ent *ent=
, u_int8_t family,
 				 ent->rateinfo.credit, ent->rateinfo.credit_cap,
 				 ent->rateinfo.cost);
 		break;
-#if defined(CONFIG_IP6_NF_IPTABLES) || defined(CONFIG_IP6_NF_IPTABLES_=
MODULE)
+#if IS_ENABLED(CONFIG_IP6_NF_IPTABLES)
 	case NFPROTO_IPV6:
 		res =3D seq_printf(s, "%ld %pI6:%u->%pI6:%u %u %u %u\n",
 				 (long)(ent->expires - jiffies)/HZ,
@@ -761,7 +761,7 @@ static int __net_init hashlimit_proc_net_init(struc=
t net *net)
 	hashlimit_net->ipt_hashlimit =3D proc_mkdir("ipt_hashlimit", net->pro=
c_net);
 	if (!hashlimit_net->ipt_hashlimit)
 		return -ENOMEM;
-#if defined(CONFIG_IP6_NF_IPTABLES) || defined(CONFIG_IP6_NF_IPTABLES_=
MODULE)
+#if IS_ENABLED(CONFIG_IP6_NF_IPTABLES)
 	hashlimit_net->ip6t_hashlimit =3D proc_mkdir("ip6t_hashlimit", net->p=
roc_net);
 	if (!hashlimit_net->ip6t_hashlimit) {
 		proc_net_remove(net, "ipt_hashlimit");
@@ -774,7 +774,7 @@ static int __net_init hashlimit_proc_net_init(struc=
t net *net)
 static void __net_exit hashlimit_proc_net_exit(struct net *net)
 {
 	proc_net_remove(net, "ipt_hashlimit");
-#if defined(CONFIG_IP6_NF_IPTABLES) || defined(CONFIG_IP6_NF_IPTABLES_=
MODULE)
+#if IS_ENABLED(CONFIG_IP6_NF_IPTABLES)
 	proc_net_remove(net, "ip6t_hashlimit");
 #endif
 }
diff --git a/net/netfilter/xt_socket.c b/net/netfilter/xt_socket.c
index c302e30..72bb07f 100644
--- a/net/netfilter/xt_socket.c
+++ b/net/netfilter/xt_socket.c
@@ -22,7 +22,7 @@
 #include <net/netfilter/nf_tproxy_core.h>
 #include <net/netfilter/ipv4/nf_defrag_ipv4.h>
=20
-#if defined(CONFIG_IP6_NF_IPTABLES) || defined(CONFIG_IP6_NF_IPTABLES_=
MODULE)
+#if IS_ENABLED(CONFIG_IP6_NF_IPTABLES)
 #define XT_SOCKET_HAVE_IPV6 1
 #include <linux/netfilter_ipv6/ip6_tables.h>
 #include <net/netfilter/ipv6/nf_defrag_ipv6.h>
@@ -30,7 +30,7 @@
=20
 #include <linux/netfilter/xt_socket.h>
=20
-#if defined(CONFIG_NF_CONNTRACK) || defined(CONFIG_NF_CONNTRACK_MODULE=
)
+#if IS_ENABLED(CONFIG_NF_CONNTRACK)
 #define XT_SOCKET_HAVE_CONNTRACK 1
 #include <net/netfilter/nf_conntrack.h>
 #endif
--=20
1.7.5.4
