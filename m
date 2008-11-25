From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: [PATCH 44/53] netns xfrm: ->dst_lookup in netns
Date: Tue, 25 Nov 2008 20:27:16 +0300
Message-ID: <1227634045-27534-44-git-send-email-adobriyan@gmail.com>
References: <1227634045-27534-1-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-2-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-3-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-4-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-5-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-6-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-7-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-8-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-9-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-10-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-11-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-12-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-13-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-14-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-15-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-16-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-17-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-18-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-19-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-20-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-21-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-22-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-23-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-24-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-25-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-26-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-27-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-28-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-29-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-30-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-31-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-32-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-33-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-34-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-35-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-36-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-37-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-38-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-39-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-40-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-41-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-42-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-43-git-send-email-adobriyan@gmail.com>
Cc: herbert@gondor.apana.org.au, kuznet@ms2.inr.ac.ru,
	netdev@vger.kernel.org, containers@lists.linux-foundation.org,
	Alexey Dobriyan <adobriyan@gmail.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from ey-out-2122.google.com ([74.125.78.24]:41393 "EHLO
	ey-out-2122.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754053AbYKYRZ2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Nov 2008 12:25:28 -0500
Received: by ey-out-2122.google.com with SMTP id 6so23517eyi.37
        for <netdev@vger.kernel.org>; Tue, 25 Nov 2008 09:25:27 -0800 (PST)
In-Reply-To: <1227634045-27534-43-git-send-email-adobriyan@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>
---
 include/net/xfrm.h      |    3 ++-
 net/ipv4/xfrm4_policy.c |    7 ++++---
 net/ipv6/xfrm6_policy.c |    7 ++++---
 net/xfrm/xfrm_policy.c  |    7 ++++---
 4 files changed, 14 insertions(+), 10 deletions(-)

diff --git a/include/net/xfrm.h b/include/net/xfrm.h
index f3ea160..b16d4c0 100644
--- a/include/net/xfrm.h
+++ b/include/net/xfrm.h
@@ -266,7 +266,8 @@ struct xfrm_policy_afinfo {
 	unsigned short		family;
 	struct dst_ops		*dst_ops;
 	void			(*garbage_collect)(struct net *net);
-	struct dst_entry	*(*dst_lookup)(int tos, xfrm_address_t *saddr,
+	struct dst_entry	*(*dst_lookup)(struct net *net, int tos,
+					       xfrm_address_t *saddr,
 					       xfrm_address_t *daddr);
 	int			(*get_saddr)(xfrm_address_t *saddr, xfrm_address_t *daddr);
 	struct dst_entry	*(*find_bundle)(struct flowi *fl, struct xfrm_policy *policy);
diff --git a/net/ipv4/xfrm4_policy.c b/net/ipv4/xfrm4_policy.c
index a881ca3..e1cf9ed 100644
--- a/net/ipv4/xfrm4_policy.c
+++ b/net/ipv4/xfrm4_policy.c
@@ -18,7 +18,8 @@
 static struct dst_ops xfrm4_dst_ops;
 static struct xfrm_policy_afinfo xfrm4_policy_afinfo;
 
-static struct dst_entry *xfrm4_dst_lookup(int tos, xfrm_address_t *saddr,
+static struct dst_entry *xfrm4_dst_lookup(struct net *net, int tos,
+					  xfrm_address_t *saddr,
 					  xfrm_address_t *daddr)
 {
 	struct flowi fl = {
@@ -36,7 +37,7 @@ static struct dst_entry *xfrm4_dst_lookup(int tos, xfrm_address_t *saddr,
 	if (saddr)
 		fl.fl4_src = saddr->a4;
 
-	err = __ip_route_output_key(&init_net, &rt, &fl);
+	err = __ip_route_output_key(net, &rt, &fl);
 	dst = &rt->u.dst;
 	if (err)
 		dst = ERR_PTR(err);
@@ -48,7 +49,7 @@ static int xfrm4_get_saddr(xfrm_address_t *saddr, xfrm_address_t *daddr)
 	struct dst_entry *dst;
 	struct rtable *rt;
 
-	dst = xfrm4_dst_lookup(0, NULL, daddr);
+	dst = xfrm4_dst_lookup(&init_net, 0, NULL, daddr);
 	if (IS_ERR(dst))
 		return -EHOSTUNREACH;
 
diff --git a/net/ipv6/xfrm6_policy.c b/net/ipv6/xfrm6_policy.c
index 2df8a78..d7a5b8b 100644
--- a/net/ipv6/xfrm6_policy.c
+++ b/net/ipv6/xfrm6_policy.c
@@ -27,7 +27,8 @@
 static struct dst_ops xfrm6_dst_ops;
 static struct xfrm_policy_afinfo xfrm6_policy_afinfo;
 
-static struct dst_entry *xfrm6_dst_lookup(int tos, xfrm_address_t *saddr,
+static struct dst_entry *xfrm6_dst_lookup(struct net *net, int tos,
+					  xfrm_address_t *saddr,
 					  xfrm_address_t *daddr)
 {
 	struct flowi fl = {};
@@ -38,7 +39,7 @@ static struct dst_entry *xfrm6_dst_lookup(int tos, xfrm_address_t *saddr,
 	if (saddr)
 		memcpy(&fl.fl6_src, saddr, sizeof(fl.fl6_src));
 
-	dst = ip6_route_output(&init_net, NULL, &fl);
+	dst = ip6_route_output(net, NULL, &fl);
 
 	err = dst->error;
 	if (dst->error) {
@@ -54,7 +55,7 @@ static int xfrm6_get_saddr(xfrm_address_t *saddr, xfrm_address_t *daddr)
 	struct dst_entry *dst;
 	struct net_device *dev;
 
-	dst = xfrm6_dst_lookup(0, NULL, daddr);
+	dst = xfrm6_dst_lookup(&init_net, 0, NULL, daddr);
 	if (IS_ERR(dst))
 		return -EHOSTUNREACH;
 
diff --git a/net/xfrm/xfrm_policy.c b/net/xfrm/xfrm_policy.c
index 7ebbdd6..2b0a80b 100644
--- a/net/xfrm/xfrm_policy.c
+++ b/net/xfrm/xfrm_policy.c
@@ -92,7 +92,7 @@ int xfrm_selector_match(struct xfrm_selector *sel, struct flowi *fl,
 	return 0;
 }
 
-static inline struct dst_entry *__xfrm_dst_lookup(int tos,
+static inline struct dst_entry *__xfrm_dst_lookup(struct net *net, int tos,
 						  xfrm_address_t *saddr,
 						  xfrm_address_t *daddr,
 						  int family)
@@ -104,7 +104,7 @@ static inline struct dst_entry *__xfrm_dst_lookup(int tos,
 	if (unlikely(afinfo == NULL))
 		return ERR_PTR(-EAFNOSUPPORT);
 
-	dst = afinfo->dst_lookup(tos, saddr, daddr);
+	dst = afinfo->dst_lookup(net, tos, saddr, daddr);
 
 	xfrm_policy_put_afinfo(afinfo);
 
@@ -116,6 +116,7 @@ static inline struct dst_entry *xfrm_dst_lookup(struct xfrm_state *x, int tos,
 						xfrm_address_t *prev_daddr,
 						int family)
 {
+	struct net *net = xs_net(x);
 	xfrm_address_t *saddr = &x->props.saddr;
 	xfrm_address_t *daddr = &x->id.daddr;
 	struct dst_entry *dst;
@@ -129,7 +130,7 @@ static inline struct dst_entry *xfrm_dst_lookup(struct xfrm_state *x, int tos,
 		daddr = x->coaddr;
 	}
 
-	dst = __xfrm_dst_lookup(tos, saddr, daddr, family);
+	dst = __xfrm_dst_lookup(net, tos, saddr, daddr, family);
 
 	if (!IS_ERR(dst)) {
 		if (prev_saddr != saddr)
-- 
1.5.6.5

