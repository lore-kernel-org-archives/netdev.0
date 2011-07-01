From: Joe Perches <joe@perches.com>
Subject: [PATCH 05/12] netfilter: Reduce switch/case indent
Date: Fri,  1 Jul 2011 12:43:06 -0700
Message-ID: <2066c42e04b33d3a2870c1d3e93f974d9085887c.1309549244.git.joe@perches.com>
References: <cover.1309549243.git.joe@perches.com>
Cc: "David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	"Pekka Savola (ipv6)" <pekkas@netcore.fi>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	netfilter-devel@vger.kernel.org, netfilter@vger.kernel.org,
	coreteam@netfilter.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1309549243.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Make the case labels the same indent as the switch.

git diff -w shows miscellaneous 80 column wrapping,
comment reflowing and a comment for a useless gcc
warning for an otherwise unused default: case.

Signed-off-by: Joe Perches <joe@perches.com>
---
 net/ipv4/netfilter/ipt_CLUSTERIP.c     |   26 ++--
 net/ipv4/netfilter/nf_nat_snmp_basic.c |  210 ++++++++++++++++----------------
 net/netfilter/xt_HL.c                  |   64 +++++-----
 net/netfilter/xt_hl.c                  |   32 +++---
 4 files changed, 165 insertions(+), 167 deletions(-)

diff --git a/net/ipv4/netfilter/ipt_CLUSTERIP.c b/net/ipv4/netfilter/ipt_CLUSTERIP.c
index 5c9e97c..db8d22d 100644
--- a/net/ipv4/netfilter/ipt_CLUSTERIP.c
+++ b/net/ipv4/netfilter/ipt_CLUSTERIP.c
@@ -317,19 +317,19 @@ clusterip_tg(struct sk_buff *skb, const struct xt_action_param *par)
 	hash = clusterip_hashfn(skb, cipinfo->config);
 
 	switch (ctinfo) {
-		case IP_CT_NEW:
-			ct->mark = hash;
-			break;
-		case IP_CT_RELATED:
-		case IP_CT_RELATED_REPLY:
-			/* FIXME: we don't handle expectations at the
-			 * moment.  they can arrive on a different node than
-			 * the master connection (e.g. FTP passive mode) */
-		case IP_CT_ESTABLISHED:
-		case IP_CT_ESTABLISHED_REPLY:
-			break;
-		default:
-			break;
+	case IP_CT_NEW:
+		ct->mark = hash;
+		break;
+	case IP_CT_RELATED:
+	case IP_CT_RELATED_REPLY:
+		/* FIXME: we don't handle expectations at the moment.
+		 * They can arrive on a different node than
+		 * the master connection (e.g. FTP passive mode) */
+	case IP_CT_ESTABLISHED:
+	case IP_CT_ESTABLISHED_REPLY:
+		break;
+	default:			/* Prevent gcc warnings */
+		break;
 	}
 
 #ifdef DEBUG
diff --git a/net/ipv4/netfilter/nf_nat_snmp_basic.c b/net/ipv4/netfilter/nf_nat_snmp_basic.c
index 8812a02..076b7c8 100644
--- a/net/ipv4/netfilter/nf_nat_snmp_basic.c
+++ b/net/ipv4/netfilter/nf_nat_snmp_basic.c
@@ -719,117 +719,115 @@ static unsigned char snmp_object_decode(struct asn1_ctx *ctx,
 
 	l = 0;
 	switch (type) {
-		case SNMP_INTEGER:
-			len = sizeof(long);
-			if (!asn1_long_decode(ctx, end, &l)) {
-				kfree(id);
-				return 0;
-			}
-			*obj = kmalloc(sizeof(struct snmp_object) + len,
-				       GFP_ATOMIC);
-			if (*obj == NULL) {
-				kfree(id);
-				if (net_ratelimit())
-					pr_notice("OOM in bsalg (%d)\n", __LINE__);
-				return 0;
-			}
-			(*obj)->syntax.l[0] = l;
-			break;
-		case SNMP_OCTETSTR:
-		case SNMP_OPAQUE:
-			if (!asn1_octets_decode(ctx, end, &p, &len)) {
-				kfree(id);
-				return 0;
-			}
-			*obj = kmalloc(sizeof(struct snmp_object) + len,
-				       GFP_ATOMIC);
-			if (*obj == NULL) {
-				kfree(p);
-				kfree(id);
-				if (net_ratelimit())
-					pr_notice("OOM in bsalg (%d)\n", __LINE__);
-				return 0;
-			}
-			memcpy((*obj)->syntax.c, p, len);
+	case SNMP_INTEGER:
+		len = sizeof(long);
+		if (!asn1_long_decode(ctx, end, &l)) {
+			kfree(id);
+			return 0;
+		}
+		*obj = kmalloc(sizeof(struct snmp_object) + len, GFP_ATOMIC);
+		if (*obj == NULL) {
+			kfree(id);
+			if (net_ratelimit())
+				pr_notice("OOM in bsalg (%d)\n", __LINE__);
+			return 0;
+		}
+		(*obj)->syntax.l[0] = l;
+		break;
+	case SNMP_OCTETSTR:
+	case SNMP_OPAQUE:
+		if (!asn1_octets_decode(ctx, end, &p, &len)) {
+			kfree(id);
+			return 0;
+		}
+		*obj = kmalloc(sizeof(struct snmp_object) + len, GFP_ATOMIC);
+		if (*obj == NULL) {
 			kfree(p);
-			break;
-		case SNMP_NULL:
-		case SNMP_NOSUCHOBJECT:
-		case SNMP_NOSUCHINSTANCE:
-		case SNMP_ENDOFMIBVIEW:
-			len = 0;
-			*obj = kmalloc(sizeof(struct snmp_object), GFP_ATOMIC);
-			if (*obj == NULL) {
-				kfree(id);
-				if (net_ratelimit())
-					pr_notice("OOM in bsalg (%d)\n", __LINE__);
-				return 0;
-			}
-			if (!asn1_null_decode(ctx, end)) {
-				kfree(id);
-				kfree(*obj);
-				*obj = NULL;
-				return 0;
-			}
-			break;
-		case SNMP_OBJECTID:
-			if (!asn1_oid_decode(ctx, end, (unsigned long **)&lp, &len)) {
-				kfree(id);
-				return 0;
-			}
-			len *= sizeof(unsigned long);
-			*obj = kmalloc(sizeof(struct snmp_object) + len, GFP_ATOMIC);
-			if (*obj == NULL) {
-				kfree(lp);
-				kfree(id);
-				if (net_ratelimit())
-					pr_notice("OOM in bsalg (%d)\n", __LINE__);
-				return 0;
-			}
-			memcpy((*obj)->syntax.ul, lp, len);
+			kfree(id);
+			if (net_ratelimit())
+				pr_notice("OOM in bsalg (%d)\n", __LINE__);
+			return 0;
+		}
+		memcpy((*obj)->syntax.c, p, len);
+		kfree(p);
+		break;
+	case SNMP_NULL:
+	case SNMP_NOSUCHOBJECT:
+	case SNMP_NOSUCHINSTANCE:
+	case SNMP_ENDOFMIBVIEW:
+		len = 0;
+		*obj = kmalloc(sizeof(struct snmp_object), GFP_ATOMIC);
+		if (*obj == NULL) {
+			kfree(id);
+			if (net_ratelimit())
+				pr_notice("OOM in bsalg (%d)\n", __LINE__);
+			return 0;
+		}
+		if (!asn1_null_decode(ctx, end)) {
+			kfree(id);
+			kfree(*obj);
+			*obj = NULL;
+			return 0;
+		}
+		break;
+	case SNMP_OBJECTID:
+		if (!asn1_oid_decode(ctx, end, (unsigned long **)&lp, &len)) {
+			kfree(id);
+			return 0;
+		}
+		len *= sizeof(unsigned long);
+		*obj = kmalloc(sizeof(struct snmp_object) + len, GFP_ATOMIC);
+		if (*obj == NULL) {
 			kfree(lp);
-			break;
-		case SNMP_IPADDR:
-			if (!asn1_octets_decode(ctx, end, &p, &len)) {
-				kfree(id);
-				return 0;
-			}
-			if (len != 4) {
-				kfree(p);
-				kfree(id);
-				return 0;
-			}
-			*obj = kmalloc(sizeof(struct snmp_object) + len, GFP_ATOMIC);
-			if (*obj == NULL) {
-				kfree(p);
-				kfree(id);
-				if (net_ratelimit())
-					pr_notice("OOM in bsalg (%d)\n", __LINE__);
-				return 0;
-			}
-			memcpy((*obj)->syntax.uc, p, len);
+			kfree(id);
+			if (net_ratelimit())
+				pr_notice("OOM in bsalg (%d)\n", __LINE__);
+			return 0;
+		}
+		memcpy((*obj)->syntax.ul, lp, len);
+		kfree(lp);
+		break;
+	case SNMP_IPADDR:
+		if (!asn1_octets_decode(ctx, end, &p, &len)) {
+			kfree(id);
+			return 0;
+		}
+		if (len != 4) {
 			kfree(p);
-			break;
-		case SNMP_COUNTER:
-		case SNMP_GAUGE:
-		case SNMP_TIMETICKS:
-			len = sizeof(unsigned long);
-			if (!asn1_ulong_decode(ctx, end, &ul)) {
-				kfree(id);
-				return 0;
-			}
-			*obj = kmalloc(sizeof(struct snmp_object) + len, GFP_ATOMIC);
-			if (*obj == NULL) {
-				kfree(id);
-				if (net_ratelimit())
-					pr_notice("OOM in bsalg (%d)\n", __LINE__);
-				return 0;
-			}
-			(*obj)->syntax.ul[0] = ul;
-			break;
-		default:
 			kfree(id);
 			return 0;
+		}
+		*obj = kmalloc(sizeof(struct snmp_object) + len, GFP_ATOMIC);
+		if (*obj == NULL) {
+			kfree(p);
+			kfree(id);
+			if (net_ratelimit())
+				pr_notice("OOM in bsalg (%d)\n", __LINE__);
+			return 0;
+		}
+		memcpy((*obj)->syntax.uc, p, len);
+		kfree(p);
+		break;
+	case SNMP_COUNTER:
+	case SNMP_GAUGE:
+	case SNMP_TIMETICKS:
+		len = sizeof(unsigned long);
+		if (!asn1_ulong_decode(ctx, end, &ul)) {
+			kfree(id);
+			return 0;
+		}
+		*obj = kmalloc(sizeof(struct snmp_object) + len, GFP_ATOMIC);
+		if (*obj == NULL) {
+			kfree(id);
+			if (net_ratelimit())
+				pr_notice("OOM in bsalg (%d)\n", __LINE__);
+			return 0;
+		}
+		(*obj)->syntax.ul[0] = ul;
+		break;
+	default:
+		kfree(id);
+		return 0;
 	}
 
 	(*obj)->syntax_len = len;
diff --git a/net/netfilter/xt_HL.c b/net/netfilter/xt_HL.c
index 95b08480..1535e87 100644
--- a/net/netfilter/xt_HL.c
+++ b/net/netfilter/xt_HL.c
@@ -38,22 +38,22 @@ ttl_tg(struct sk_buff *skb, const struct xt_action_param *par)
 	iph = ip_hdr(skb);
 
 	switch (info->mode) {
-		case IPT_TTL_SET:
-			new_ttl = info->ttl;
-			break;
-		case IPT_TTL_INC:
-			new_ttl = iph->ttl + info->ttl;
-			if (new_ttl > 255)
-				new_ttl = 255;
-			break;
-		case IPT_TTL_DEC:
-			new_ttl = iph->ttl - info->ttl;
-			if (new_ttl < 0)
-				new_ttl = 0;
-			break;
-		default:
-			new_ttl = iph->ttl;
-			break;
+	case IPT_TTL_SET:
+		new_ttl = info->ttl;
+		break;
+	case IPT_TTL_INC:
+		new_ttl = iph->ttl + info->ttl;
+		if (new_ttl > 255)
+			new_ttl = 255;
+		break;
+	case IPT_TTL_DEC:
+		new_ttl = iph->ttl - info->ttl;
+		if (new_ttl < 0)
+			new_ttl = 0;
+		break;
+	default:
+		new_ttl = iph->ttl;
+		break;
 	}
 
 	if (new_ttl != iph->ttl) {
@@ -78,22 +78,22 @@ hl_tg6(struct sk_buff *skb, const struct xt_action_param *par)
 	ip6h = ipv6_hdr(skb);
 
 	switch (info->mode) {
-		case IP6T_HL_SET:
-			new_hl = info->hop_limit;
-			break;
-		case IP6T_HL_INC:
-			new_hl = ip6h->hop_limit + info->hop_limit;
-			if (new_hl > 255)
-				new_hl = 255;
-			break;
-		case IP6T_HL_DEC:
-			new_hl = ip6h->hop_limit - info->hop_limit;
-			if (new_hl < 0)
-				new_hl = 0;
-			break;
-		default:
-			new_hl = ip6h->hop_limit;
-			break;
+	case IP6T_HL_SET:
+		new_hl = info->hop_limit;
+		break;
+	case IP6T_HL_INC:
+		new_hl = ip6h->hop_limit + info->hop_limit;
+		if (new_hl > 255)
+			new_hl = 255;
+		break;
+	case IP6T_HL_DEC:
+		new_hl = ip6h->hop_limit - info->hop_limit;
+		if (new_hl < 0)
+			new_hl = 0;
+		break;
+	default:
+		new_hl = ip6h->hop_limit;
+		break;
 	}
 
 	ip6h->hop_limit = new_hl;
diff --git a/net/netfilter/xt_hl.c b/net/netfilter/xt_hl.c
index 7d12221..0039511 100644
--- a/net/netfilter/xt_hl.c
+++ b/net/netfilter/xt_hl.c
@@ -31,14 +31,14 @@ static bool ttl_mt(const struct sk_buff *skb, struct xt_action_param *par)
 	const u8 ttl = ip_hdr(skb)->ttl;
 
 	switch (info->mode) {
-		case IPT_TTL_EQ:
-			return ttl == info->ttl;
-		case IPT_TTL_NE:
-			return ttl != info->ttl;
-		case IPT_TTL_LT:
-			return ttl < info->ttl;
-		case IPT_TTL_GT:
-			return ttl > info->ttl;
+	case IPT_TTL_EQ:
+		return ttl == info->ttl;
+	case IPT_TTL_NE:
+		return ttl != info->ttl;
+	case IPT_TTL_LT:
+		return ttl < info->ttl;
+	case IPT_TTL_GT:
+		return ttl > info->ttl;
 	}
 
 	return false;
@@ -50,14 +50,14 @@ static bool hl_mt6(const struct sk_buff *skb, struct xt_action_param *par)
 	const struct ipv6hdr *ip6h = ipv6_hdr(skb);
 
 	switch (info->mode) {
-		case IP6T_HL_EQ:
-			return ip6h->hop_limit == info->hop_limit;
-		case IP6T_HL_NE:
-			return ip6h->hop_limit != info->hop_limit;
-		case IP6T_HL_LT:
-			return ip6h->hop_limit < info->hop_limit;
-		case IP6T_HL_GT:
-			return ip6h->hop_limit > info->hop_limit;
+	case IP6T_HL_EQ:
+		return ip6h->hop_limit == info->hop_limit;
+	case IP6T_HL_NE:
+		return ip6h->hop_limit != info->hop_limit;
+	case IP6T_HL_LT:
+		return ip6h->hop_limit < info->hop_limit;
+	case IP6T_HL_GT:
+		return ip6h->hop_limit > info->hop_limit;
 	}
 
 	return false;
-- 
1.7.6.rc1
