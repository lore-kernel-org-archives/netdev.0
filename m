From: Arnaldo Carvalho de Melo <acme@redhat.com>
Subject: [PATCH]: net: Use hton[sl]() was Re: [PATCH 10/14] Phonet: Phonet
	datagram transport protocol
Date: Fri, 19 Sep 2008 12:24:48 -0300
Message-ID: <20080919152448.GB29403@ghostprotocols.net>
References: <200809161757.38571.remi.denis-courmont@nokia.com> <1221577694-4513-10-git-send-email-remi.denis-courmont@nokia.com> <20080916170644.GM8702@ghostprotocols.net> <200809190933.33638.remi.denis-courmont@nokia.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?iso-8859-1?Q?R=E9mi?= Denis-Courmont
	<remi.denis-courmont@nokia.com>, netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:41181 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751299AbYISPex (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 19 Sep 2008 11:34:53 -0400
Content-Disposition: inline
In-Reply-To: <200809190933.33638.remi.denis-courmont@nokia.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Em Fri, Sep 19, 2008 at 09:33:33AM +0300, R=E9mi Denis-Courmont escreve=
u:
> On Tuesday 16 September 2008 20:06:44 ext Arnaldo Carvalho de Melo, y=
ou wrote:
> > > +	ph->robj =3D pn_obj(dst);
> > > +	ph->sobj =3D pn_obj(src);
> > > +
> > > +	skb->protocol =3D __constant_htons(ETH_P_PHONET);
> >
> > No need for __constant_htons(CONSTANT), htons will do the right thi=
ng
> > and the code will be shorter, clearer.
>=20
> Ok. There are quite many of these in net/ though... is that reserved =
for=20
> switch/case only?

Nope, they should only be used when initializing static variables.

David, the following patch converts what is in net-next-2.6 net/ now:


commit 8e64a880d1f8a3df44648e0109f22a22322acc56
Author: Arnaldo Carvalho de Melo <acme@redhat.com>
Date:   Fri Sep 19 11:34:45 2008 -0300

    net: Use hton[sl]() instead of __constant_hton[sl]() where applicab=
le
   =20
    Signed-off-by: Arnaldo Carvalho de Melo <acme@redhat.com>

diff --git a/net/8021q/vlan_dev.c b/net/8021q/vlan_dev.c
index 97688cd..8883e9c 100644
--- a/net/8021q/vlan_dev.c
+++ b/net/8021q/vlan_dev.c
@@ -48,7 +48,7 @@ static int vlan_dev_rebuild_header(struct sk_buff *sk=
b)
=20
 	switch (veth->h_vlan_encapsulated_proto) {
 #ifdef CONFIG_INET
-	case __constant_htons(ETH_P_IP):
+	case htons(ETH_P_IP):
=20
 		/* TODO:  Confirm this will work with VLAN headers... */
 		return arp_find(veth->h_dest, skb);
diff --git a/net/atm/br2684.c b/net/atm/br2684.c
index 8d9a6f1..280de48 100644
--- a/net/atm/br2684.c
+++ b/net/atm/br2684.c
@@ -375,11 +375,11 @@ static void br2684_push(struct atm_vcc *atmvcc, s=
truct sk_buff *skb)
 			if (memcmp
 			    (skb->data + 6, ethertype_ipv6,
 			     sizeof(ethertype_ipv6)) =3D=3D 0)
-				skb->protocol =3D __constant_htons(ETH_P_IPV6);
+				skb->protocol =3D htons(ETH_P_IPV6);
 			else if (memcmp
 				 (skb->data + 6, ethertype_ipv4,
 				  sizeof(ethertype_ipv4)) =3D=3D 0)
-				skb->protocol =3D __constant_htons(ETH_P_IP);
+				skb->protocol =3D htons(ETH_P_IP);
 			else
 				goto error;
 			skb_pull(skb, sizeof(llc_oui_ipv4));
@@ -404,9 +404,9 @@ static void br2684_push(struct atm_vcc *atmvcc, str=
uct sk_buff *skb)
 			skb_reset_network_header(skb);
 			iph =3D ip_hdr(skb);
 			if (iph->version =3D=3D 4)
-				skb->protocol =3D __constant_htons(ETH_P_IP);
+				skb->protocol =3D htons(ETH_P_IP);
 			else if (iph->version =3D=3D 6)
-				skb->protocol =3D __constant_htons(ETH_P_IPV6);
+				skb->protocol =3D htons(ETH_P_IPV6);
 			else
 				goto error;
 			skb->pkt_type =3D PACKET_HOST;
diff --git a/net/core/dev.c b/net/core/dev.c
index f48d1b2..fdfc4b6 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -1675,13 +1675,13 @@ static u16 simple_tx_hash(struct net_device *de=
v, struct sk_buff *skb)
 	}
=20
 	switch (skb->protocol) {
-	case __constant_htons(ETH_P_IP):
+	case htons(ETH_P_IP):
 		ip_proto =3D ip_hdr(skb)->protocol;
 		addr1 =3D ip_hdr(skb)->saddr;
 		addr2 =3D ip_hdr(skb)->daddr;
 		ihl =3D ip_hdr(skb)->ihl;
 		break;
-	case __constant_htons(ETH_P_IPV6):
+	case htons(ETH_P_IPV6):
 		ip_proto =3D ipv6_hdr(skb)->nexthdr;
 		addr1 =3D ipv6_hdr(skb)->saddr.s6_addr32[3];
 		addr2 =3D ipv6_hdr(skb)->daddr.s6_addr32[3];
diff --git a/net/ethernet/eth.c b/net/ethernet/eth.c
index a80839b..647a9ed 100644
--- a/net/ethernet/eth.c
+++ b/net/ethernet/eth.c
@@ -129,7 +129,7 @@ int eth_rebuild_header(struct sk_buff *skb)
=20
 	switch (eth->h_proto) {
 #ifdef CONFIG_INET
-	case __constant_htons(ETH_P_IP):
+	case htons(ETH_P_IP):
 		return arp_find(eth->h_dest, skb);
 #endif
 	default:
diff --git a/net/ipv4/ipvs/ip_vs_core.c b/net/ipv4/ipvs/ip_vs_core.c
index ece748d..958abf3 100644
--- a/net/ipv4/ipvs/ip_vs_core.c
+++ b/net/ipv4/ipvs/ip_vs_core.c
@@ -938,7 +938,7 @@ ip_vs_out(unsigned int hooknum, struct sk_buff *skb=
,
=20
 	EnterFunction(11);
=20
-	af =3D (skb->protocol =3D=3D __constant_htons(ETH_P_IP)) ? AF_INET : =
AF_INET6;
+	af =3D (skb->protocol =3D=3D htons(ETH_P_IP)) ? AF_INET : AF_INET6;
=20
 	if (skb->ipvs_property)
 		return NF_ACCEPT;
@@ -1258,7 +1258,7 @@ ip_vs_in(unsigned int hooknum, struct sk_buff *sk=
b,
 	struct ip_vs_conn *cp;
 	int ret, restart, af;
=20
-	af =3D (skb->protocol =3D=3D __constant_htons(ETH_P_IP)) ? AF_INET : =
AF_INET6;
+	af =3D (skb->protocol =3D=3D htons(ETH_P_IP)) ? AF_INET : AF_INET6;
=20
 	ip_vs_fill_iphdr(af, skb_network_header(skb), &iph);
=20
diff --git a/net/ipv6/ip6_tunnel.c b/net/ipv6/ip6_tunnel.c
index 17c7b09..64ce3d3 100644
--- a/net/ipv6/ip6_tunnel.c
+++ b/net/ipv6/ip6_tunnel.c
@@ -1050,10 +1050,10 @@ ip6_tnl_xmit(struct sk_buff *skb, struct net_de=
vice *dev)
 	}
=20
 	switch (skb->protocol) {
-	case __constant_htons(ETH_P_IP):
+	case htons(ETH_P_IP):
 		ret =3D ip4ip6_tnl_xmit(skb, dev);
 		break;
-	case __constant_htons(ETH_P_IPV6):
+	case htons(ETH_P_IPV6):
 		ret =3D ip6ip6_tnl_xmit(skb, dev);
 		break;
 	default:
diff --git a/net/mac80211/wme.c b/net/mac80211/wme.c
index 7229e95..5966b9f 100644
--- a/net/mac80211/wme.c
+++ b/net/mac80211/wme.c
@@ -39,7 +39,7 @@ static unsigned int classify_1d(struct sk_buff *skb)
 		return skb->priority - 256;
=20
 	switch (skb->protocol) {
-	case __constant_htons(ETH_P_IP):
+	case htons(ETH_P_IP):
 		dscp =3D ip_hdr(skb)->tos & 0xfc;
 		break;
=20
diff --git a/net/sched/cls_flow.c b/net/sched/cls_flow.c
index 8f63a1a..0ebaff6 100644
--- a/net/sched/cls_flow.c
+++ b/net/sched/cls_flow.c
@@ -67,9 +67,9 @@ static inline u32 addr_fold(void *addr)
 static u32 flow_get_src(const struct sk_buff *skb)
 {
 	switch (skb->protocol) {
-	case __constant_htons(ETH_P_IP):
+	case htons(ETH_P_IP):
 		return ntohl(ip_hdr(skb)->saddr);
-	case __constant_htons(ETH_P_IPV6):
+	case htons(ETH_P_IPV6):
 		return ntohl(ipv6_hdr(skb)->saddr.s6_addr32[3]);
 	default:
 		return addr_fold(skb->sk);
@@ -79,9 +79,9 @@ static u32 flow_get_src(const struct sk_buff *skb)
 static u32 flow_get_dst(const struct sk_buff *skb)
 {
 	switch (skb->protocol) {
-	case __constant_htons(ETH_P_IP):
+	case htons(ETH_P_IP):
 		return ntohl(ip_hdr(skb)->daddr);
-	case __constant_htons(ETH_P_IPV6):
+	case htons(ETH_P_IPV6):
 		return ntohl(ipv6_hdr(skb)->daddr.s6_addr32[3]);
 	default:
 		return addr_fold(skb->dst) ^ (__force u16)skb->protocol;
@@ -91,9 +91,9 @@ static u32 flow_get_dst(const struct sk_buff *skb)
 static u32 flow_get_proto(const struct sk_buff *skb)
 {
 	switch (skb->protocol) {
-	case __constant_htons(ETH_P_IP):
+	case htons(ETH_P_IP):
 		return ip_hdr(skb)->protocol;
-	case __constant_htons(ETH_P_IPV6):
+	case htons(ETH_P_IPV6):
 		return ipv6_hdr(skb)->nexthdr;
 	default:
 		return 0;
@@ -120,7 +120,7 @@ static u32 flow_get_proto_src(const struct sk_buff =
*skb)
 	u32 res =3D 0;
=20
 	switch (skb->protocol) {
-	case __constant_htons(ETH_P_IP): {
+	case htons(ETH_P_IP): {
 		struct iphdr *iph =3D ip_hdr(skb);
=20
 		if (!(iph->frag_off&htons(IP_MF|IP_OFFSET)) &&
@@ -128,7 +128,7 @@ static u32 flow_get_proto_src(const struct sk_buff =
*skb)
 			res =3D ntohs(*(__be16 *)((void *)iph + iph->ihl * 4));
 		break;
 	}
-	case __constant_htons(ETH_P_IPV6): {
+	case htons(ETH_P_IPV6): {
 		struct ipv6hdr *iph =3D ipv6_hdr(skb);
=20
 		if (has_ports(iph->nexthdr))
@@ -147,7 +147,7 @@ static u32 flow_get_proto_dst(const struct sk_buff =
*skb)
 	u32 res =3D 0;
=20
 	switch (skb->protocol) {
-	case __constant_htons(ETH_P_IP): {
+	case htons(ETH_P_IP): {
 		struct iphdr *iph =3D ip_hdr(skb);
=20
 		if (!(iph->frag_off&htons(IP_MF|IP_OFFSET)) &&
@@ -155,7 +155,7 @@ static u32 flow_get_proto_dst(const struct sk_buff =
*skb)
 			res =3D ntohs(*(__be16 *)((void *)iph + iph->ihl * 4 + 2));
 		break;
 	}
-	case __constant_htons(ETH_P_IPV6): {
+	case htons(ETH_P_IPV6): {
 		struct ipv6hdr *iph =3D ipv6_hdr(skb);
=20
 		if (has_ports(iph->nexthdr))
@@ -213,9 +213,9 @@ static u32 flow_get_nfct(const struct sk_buff *skb)
 static u32 flow_get_nfct_src(const struct sk_buff *skb)
 {
 	switch (skb->protocol) {
-	case __constant_htons(ETH_P_IP):
+	case htons(ETH_P_IP):
 		return ntohl(CTTUPLE(skb, src.u3.ip));
-	case __constant_htons(ETH_P_IPV6):
+	case htons(ETH_P_IPV6):
 		return ntohl(CTTUPLE(skb, src.u3.ip6[3]));
 	}
 fallback:
@@ -225,9 +225,9 @@ fallback:
 static u32 flow_get_nfct_dst(const struct sk_buff *skb)
 {
 	switch (skb->protocol) {
-	case __constant_htons(ETH_P_IP):
+	case htons(ETH_P_IP):
 		return ntohl(CTTUPLE(skb, dst.u3.ip));
-	case __constant_htons(ETH_P_IPV6):
+	case htons(ETH_P_IPV6):
 		return ntohl(CTTUPLE(skb, dst.u3.ip6[3]));
 	}
 fallback:
diff --git a/net/sched/sch_dsmark.c b/net/sched/sch_dsmark.c
index edd1298..ba43aab 100644
--- a/net/sched/sch_dsmark.c
+++ b/net/sched/sch_dsmark.c
@@ -202,7 +202,7 @@ static int dsmark_enqueue(struct sk_buff *skb, stru=
ct Qdisc *sch)
=20
 	if (p->set_tc_index) {
 		switch (skb->protocol) {
-		case __constant_htons(ETH_P_IP):
+		case htons(ETH_P_IP):
 			if (skb_cow_head(skb, sizeof(struct iphdr)))
 				goto drop;
=20
@@ -210,7 +210,7 @@ static int dsmark_enqueue(struct sk_buff *skb, stru=
ct Qdisc *sch)
 				& ~INET_ECN_MASK;
 			break;
=20
-		case __constant_htons(ETH_P_IPV6):
+		case htons(ETH_P_IPV6):
 			if (skb_cow_head(skb, sizeof(struct ipv6hdr)))
 				goto drop;
=20
@@ -289,11 +289,11 @@ static struct sk_buff *dsmark_dequeue(struct Qdis=
c *sch)
 	pr_debug("index %d->%d\n", skb->tc_index, index);
=20
 	switch (skb->protocol) {
-	case __constant_htons(ETH_P_IP):
+	case htons(ETH_P_IP):
 		ipv4_change_dsfield(ip_hdr(skb), p->mask[index],
 				    p->value[index]);
 			break;
-	case __constant_htons(ETH_P_IPV6):
+	case htons(ETH_P_IPV6):
 		ipv6_change_dsfield(ipv6_hdr(skb), p->mask[index],
 				    p->value[index]);
 			break;
diff --git a/net/sched/sch_sfq.c b/net/sched/sch_sfq.c
index 6e041d1..fe1508e 100644
--- a/net/sched/sch_sfq.c
+++ b/net/sched/sch_sfq.c
@@ -119,7 +119,7 @@ static unsigned sfq_hash(struct sfq_sched_data *q, =
struct sk_buff *skb)
 	u32 h, h2;
=20
 	switch (skb->protocol) {
-	case __constant_htons(ETH_P_IP):
+	case htons(ETH_P_IP):
 	{
 		const struct iphdr *iph =3D ip_hdr(skb);
 		h =3D iph->daddr;
@@ -134,7 +134,7 @@ static unsigned sfq_hash(struct sfq_sched_data *q, =
struct sk_buff *skb)
 			h2 ^=3D *(((u32*)iph) + iph->ihl);
 		break;
 	}
-	case __constant_htons(ETH_P_IPV6):
+	case htons(ETH_P_IPV6):
 	{
 		struct ipv6hdr *iph =3D ipv6_hdr(skb);
 		h =3D iph->daddr.s6_addr32[3];
diff --git a/net/sunrpc/xprtrdma/rpc_rdma.c b/net/sunrpc/xprtrdma/rpc_r=
dma.c
index e55427f..5c1954d 100644
--- a/net/sunrpc/xprtrdma/rpc_rdma.c
+++ b/net/sunrpc/xprtrdma/rpc_rdma.c
@@ -769,7 +769,7 @@ repost:
 	/* check for expected message types */
 	/* The order of some of these tests is important. */
 	switch (headerp->rm_type) {
-	case __constant_htonl(RDMA_MSG):
+	case htonl(RDMA_MSG):
 		/* never expect read chunks */
 		/* never expect reply chunks (two ways to check) */
 		/* never expect write chunks without having offered RDMA */
@@ -802,7 +802,7 @@ repost:
 		rpcrdma_inline_fixup(rqst, (char *)iptr, rep->rr_len);
 		break;
=20
-	case __constant_htonl(RDMA_NOMSG):
+	case htonl(RDMA_NOMSG):
 		/* never expect read or write chunks, always reply chunks */
 		if (headerp->rm_body.rm_chunks[0] !=3D xdr_zero ||
 		    headerp->rm_body.rm_chunks[1] !=3D xdr_zero ||
