From: Changli Gao <xiaosuo@gmail.com>
Subject: [PATCH] net_sched: act_csum: coding style cleanup
Date: Mon, 23 Aug 2010 21:27:58 +0800
Message-ID: <1282570078-29512-1-git-send-email-xiaosuo@gmail.com>
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Changli Gao <xiaosuo@gmail.com>
To: Jamal Hadi Salim <hadi@cyberus.ca>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-px0-f174.google.com ([209.85.212.174]:39149 "EHLO
	mail-px0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751631Ab0HWN2m (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Aug 2010 09:28:42 -0400
Received: by pxi10 with SMTP id 10so2247511pxi.19
        for <netdev@vger.kernel.org>; Mon, 23 Aug 2010 06:28:41 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Changli Gao <xiaosuo@gmail.com>
---
 net/sched/act_csum.c |   77 +++++++++++++++++++++++++--------------------------
 1 file changed, 38 insertions(+), 39 deletions(-)
diff --git a/net/sched/act_csum.c b/net/sched/act_csum.c
index be41f1c..67dc7ce 100644
--- a/net/sched/act_csum.c
+++ b/net/sched/act_csum.c
@@ -42,9 +42,9 @@ static u32 csum_idx_gen;
 static DEFINE_RWLOCK(csum_lock);
 
 static struct tcf_hashinfo csum_hash_info = {
-	.htab	=	tcf_csum_ht,
-	.hmask	=	CSUM_TAB_MASK,
-	.lock	=	&csum_lock,
+	.htab	= tcf_csum_ht,
+	.hmask	= CSUM_TAB_MASK,
+	.lock	= &csum_lock,
 };
 
 static const struct nla_policy csum_policy[TCA_CSUM_MAX + 1] = {
@@ -73,7 +73,8 @@ static int tcf_csum_init(struct nlattr *nla, struct nlattr *est,
 
 	pc = tcf_hash_check(parm->index, a, bind, &csum_hash_info);
 	if (!pc) {
-		pc = tcf_hash_create(parm->index, est, a, sizeof(*p), bind, &csum_idx_gen, &csum_hash_info);
+		pc = tcf_hash_create(parm->index, est, a, sizeof(*p), bind,
+				     &csum_idx_gen, &csum_hash_info);
 		if (IS_ERR(pc))
 			return PTR_ERR(pc);
 		p = to_tcf_csum(pc);
@@ -230,8 +231,9 @@ static int tcf_csum_ipv4_udp(struct sk_buff *skb, struct iphdr *iph,
 	struct udphdr *udph;
 	u16 ul;
 
-	/* Support both UDP and UDPLITE checksum algorithms,
-	 * Don't use udph->len to get the real length without any protocol check,
+	/*
+	 * Support both UDP and UDPLITE checksum algorithms, Don't use
+	 * udph->len to get the real length without any protocol check,
 	 * UDPLITE uses udph->len for another thing,
 	 * Use iph->tot_len, or just ipl.
 	 */
@@ -249,10 +251,8 @@ static int tcf_csum_ipv4_udp(struct sk_buff *skb, struct iphdr *iph,
 		if (udplite) {
 			if (ul == 0)
 				skb->csum = csum_partial(udph, ipl - ihl, 0);
-
 			else if ((ul >= sizeof(*udph)) && (ul <= ipl - ihl))
 				skb->csum = csum_partial(udph, ul, 0);
-
 			else
 				goto ignore_obscure_skb;
 		} else {
@@ -282,8 +282,9 @@ static int tcf_csum_ipv6_udp(struct sk_buff *skb, struct ipv6hdr *ip6h,
 	struct udphdr *udph;
 	u16 ul;
 
-	/* Support both UDP and UDPLITE checksum algorithms,
-	 * Don't use udph->len to get the real length without any protocol check,
+	/*
+	 * Support both UDP and UDPLITE checksum algorithms, Don't use
+	 * udph->len to get the real length without any protocol check,
 	 * UDPLITE uses udph->len for another thing,
 	 * Use ip6h->payload_len + sizeof(*ip6h) ... , or just ipl.
 	 */
@@ -340,32 +341,32 @@ static int tcf_csum_ipv4(struct sk_buff *skb, u32 update_flags)
 	switch (iph->frag_off & htons(IP_OFFSET) ? 0 : iph->protocol) {
 	case IPPROTO_ICMP:
 		if (update_flags & TCA_CSUM_UPDATE_FLAG_ICMP)
-			if (!tcf_csum_ipv4_icmp(skb,
-						iph->ihl * 4, ntohs(iph->tot_len)))
+			if (!tcf_csum_ipv4_icmp(skb, iph->ihl * 4,
+						ntohs(iph->tot_len)))
 				goto fail;
 		break;
 	case IPPROTO_IGMP:
 		if (update_flags & TCA_CSUM_UPDATE_FLAG_IGMP)
-			if (!tcf_csum_ipv4_igmp(skb,
-						iph->ihl * 4, ntohs(iph->tot_len)))
+			if (!tcf_csum_ipv4_igmp(skb, iph->ihl * 4,
+						ntohs(iph->tot_len)))
 				goto fail;
 		break;
 	case IPPROTO_TCP:
 		if (update_flags & TCA_CSUM_UPDATE_FLAG_TCP)
-			if (!tcf_csum_ipv4_tcp(skb, iph,
-					       iph->ihl * 4, ntohs(iph->tot_len)))
+			if (!tcf_csum_ipv4_tcp(skb, iph, iph->ihl * 4,
+					       ntohs(iph->tot_len)))
 				goto fail;
 		break;
 	case IPPROTO_UDP:
 		if (update_flags & TCA_CSUM_UPDATE_FLAG_UDP)
-			if (!tcf_csum_ipv4_udp(skb, iph,
-					       iph->ihl * 4, ntohs(iph->tot_len), 0))
+			if (!tcf_csum_ipv4_udp(skb, iph, iph->ihl * 4,
+					       ntohs(iph->tot_len), 0))
 				goto fail;
 		break;
 	case IPPROTO_UDPLITE:
 		if (update_flags & TCA_CSUM_UPDATE_FLAG_UDPLITE)
-			if (!tcf_csum_ipv4_udp(skb, iph,
-					       iph->ihl * 4, ntohs(iph->tot_len), 1))
+			if (!tcf_csum_ipv4_udp(skb, iph, iph->ihl * 4,
+					       ntohs(iph->tot_len), 1))
 				goto fail;
 		break;
 	}
@@ -386,7 +387,7 @@ fail:
 }
 
 static int tcf_csum_ipv6_hopopts(struct ipv6_opt_hdr *ip6xh,
-				  unsigned int ixhl, unsigned int *pl)
+				 unsigned int ixhl, unsigned int *pl)
 {
 	int off, len, optlen;
 	unsigned char *xh = (void *)ip6xh;
@@ -395,8 +396,7 @@ static int tcf_csum_ipv6_hopopts(struct ipv6_opt_hdr *ip6xh,
 	len = ixhl - off;
 
 	while (len > 1) {
-		switch (xh[off])
-		{
+		switch (xh[off]) {
 		case IPV6_TLV_PAD0:
 			optlen = 1;
 			break;
@@ -476,14 +476,14 @@ static int tcf_csum_ipv6(struct sk_buff *skb, u32 update_flags)
 			goto done;
 		case IPPROTO_UDP:
 			if (update_flags & TCA_CSUM_UPDATE_FLAG_UDP)
-				if (!tcf_csum_ipv6_udp(skb, ip6h,
-						       hl, pl + sizeof(*ip6h), 0))
+				if (!tcf_csum_ipv6_udp(skb, ip6h, hl,
+						       pl + sizeof(*ip6h), 0))
 					goto fail;
 			goto done;
 		case IPPROTO_UDPLITE:
 			if (update_flags & TCA_CSUM_UPDATE_FLAG_UDPLITE)
-				if (!tcf_csum_ipv6_udp(skb, ip6h,
-						       hl, pl + sizeof(*ip6h), 1))
+				if (!tcf_csum_ipv6_udp(skb, ip6h, hl,
+						       pl + sizeof(*ip6h), 1))
 					goto fail;
 			goto done;
 		default:
@@ -544,7 +544,6 @@ static int tcf_csum_dump(struct sk_buff *skb,
 	struct tcf_csum *p = a->priv;
 	struct tc_csum opt = {
 		.update_flags = p->update_flags,
-
 		.index   = p->tcf_index,
 		.action  = p->tcf_action,
 		.refcnt  = p->tcf_refcnt - ref,
@@ -566,17 +565,17 @@ nla_put_failure:
 }
 
 static struct tc_action_ops act_csum_ops = {
-	.kind		=	"csum",
-	.hinfo		=	&csum_hash_info,
-	.type		=	TCA_ACT_CSUM,
-	.capab		=	TCA_CAP_NONE,
-	.owner		=	THIS_MODULE,
-	.act		=	tcf_csum,
-	.dump		=	tcf_csum_dump,
-	.cleanup	=	tcf_csum_cleanup,
-	.lookup		=	tcf_hash_search,
-	.init		=	tcf_csum_init,
-	.walk		=	tcf_generic_walker
+	.kind		= "csum",
+	.hinfo		= &csum_hash_info,
+	.type		= TCA_ACT_CSUM,
+	.capab		= TCA_CAP_NONE,
+	.owner		= THIS_MODULE,
+	.act		= tcf_csum,
+	.dump		= tcf_csum_dump,
+	.cleanup	= tcf_csum_cleanup,
+	.lookup		= tcf_hash_search,
+	.init		= tcf_csum_init,
+	.walk		= tcf_generic_walker
 };
 
 MODULE_DESCRIPTION("Checksum updating actions");
