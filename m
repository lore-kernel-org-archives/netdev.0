From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: [PATCH 43/53] netns xfrm: KM reporting in netns
Date: Tue, 25 Nov 2008 20:27:15 +0300
Message-ID: <1227634045-27534-43-git-send-email-adobriyan@gmail.com>
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
Cc: herbert@gondor.apana.org.au, kuznet@ms2.inr.ac.ru,
	netdev@vger.kernel.org, containers@lists.linux-foundation.org,
	Alexey Dobriyan <adobriyan@gmail.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from ik-out-1112.google.com ([66.249.90.179]:36183 "EHLO
	ik-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754225AbYKYRZ0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Nov 2008 12:25:26 -0500
Received: by ik-out-1112.google.com with SMTP id c29so47752ika.5
        for <netdev@vger.kernel.org>; Tue, 25 Nov 2008 09:25:24 -0800 (PST)
In-Reply-To: <1227634045-27534-42-git-send-email-adobriyan@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>
---
 include/net/xfrm.h    |    4 ++--
 net/ipv6/mip6.c       |    3 ++-
 net/xfrm/xfrm_state.c |    4 ++--
 net/xfrm/xfrm_user.c  |    5 ++---
 4 files changed, 8 insertions(+), 8 deletions(-)

diff --git a/include/net/xfrm.h b/include/net/xfrm.h
index 52e784f..f3ea160 100644
--- a/include/net/xfrm.h
+++ b/include/net/xfrm.h
@@ -552,7 +552,7 @@ struct xfrm_mgr
 	struct xfrm_policy	*(*compile_policy)(struct sock *sk, int opt, u8 *data, int len, int *dir);
 	int			(*new_mapping)(struct xfrm_state *x, xfrm_address_t *ipaddr, __be16 sport);
 	int			(*notify_policy)(struct xfrm_policy *x, int dir, struct km_event *c);
-	int			(*report)(u8 proto, struct xfrm_selector *sel, xfrm_address_t *addr);
+	int			(*report)(struct net *net, u8 proto, struct xfrm_selector *sel, xfrm_address_t *addr);
 	int			(*migrate)(struct xfrm_selector *sel, u8 dir, u8 type, struct xfrm_migrate *m, int num_bundles, struct xfrm_kmaddress *k);
 };
 
@@ -1471,7 +1471,7 @@ extern int xfrm_migrate(struct xfrm_selector *sel, u8 dir, u8 type,
 
 extern int km_new_mapping(struct xfrm_state *x, xfrm_address_t *ipaddr, __be16 sport);
 extern void km_policy_expired(struct xfrm_policy *pol, int dir, int hard, u32 pid);
-extern int km_report(u8 proto, struct xfrm_selector *sel, xfrm_address_t *addr);
+extern int km_report(struct net *net, u8 proto, struct xfrm_selector *sel, xfrm_address_t *addr);
 
 extern void xfrm_input_init(void);
 extern int xfrm_parse_spi(struct sk_buff *skb, u8 nexthdr, __be32 *spi, __be32 *seq);
diff --git a/net/ipv6/mip6.c b/net/ipv6/mip6.c
index 31295c8..f995e19 100644
--- a/net/ipv6/mip6.c
+++ b/net/ipv6/mip6.c
@@ -205,6 +205,7 @@ static inline int mip6_report_rl_allow(struct timeval *stamp,
 
 static int mip6_destopt_reject(struct xfrm_state *x, struct sk_buff *skb, struct flowi *fl)
 {
+	struct net *net = xs_net(x);
 	struct inet6_skb_parm *opt = (struct inet6_skb_parm *)skb->cb;
 	struct ipv6_destopt_hao *hao = NULL;
 	struct xfrm_selector sel;
@@ -247,7 +248,7 @@ static int mip6_destopt_reject(struct xfrm_state *x, struct sk_buff *skb, struct
 		sel.sport_mask = htons(~0);
 	sel.ifindex = fl->oif;
 
-	err = km_report(IPPROTO_DSTOPTS, &sel,
+	err = km_report(net, IPPROTO_DSTOPTS, &sel,
 			(hao ? (xfrm_address_t *)&hao->addr : NULL));
 
  out:
diff --git a/net/xfrm/xfrm_state.c b/net/xfrm/xfrm_state.c
index 21db37a..d594b5a 100644
--- a/net/xfrm/xfrm_state.c
+++ b/net/xfrm/xfrm_state.c
@@ -1833,7 +1833,7 @@ int km_migrate(struct xfrm_selector *sel, u8 dir, u8 type,
 EXPORT_SYMBOL(km_migrate);
 #endif
 
-int km_report(u8 proto, struct xfrm_selector *sel, xfrm_address_t *addr)
+int km_report(struct net *net, u8 proto, struct xfrm_selector *sel, xfrm_address_t *addr)
 {
 	int err = -EINVAL;
 	int ret;
@@ -1842,7 +1842,7 @@ int km_report(u8 proto, struct xfrm_selector *sel, xfrm_address_t *addr)
 	read_lock(&xfrm_km_lock);
 	list_for_each_entry(km, &xfrm_km_list, list) {
 		if (km->report) {
-			ret = km->report(proto, sel, addr);
+			ret = km->report(net, proto, sel, addr);
 			if (!ret)
 				err = ret;
 		}
diff --git a/net/xfrm/xfrm_user.c b/net/xfrm/xfrm_user.c
index 3e32ec2..b7240d5 100644
--- a/net/xfrm/xfrm_user.c
+++ b/net/xfrm/xfrm_user.c
@@ -2520,10 +2520,9 @@ nla_put_failure:
 	return -EMSGSIZE;
 }
 
-static int xfrm_send_report(u8 proto, struct xfrm_selector *sel,
-			    xfrm_address_t *addr)
+static int xfrm_send_report(struct net *net, u8 proto,
+			    struct xfrm_selector *sel, xfrm_address_t *addr)
 {
-	struct net *net = &init_net;
 	struct sk_buff *skb;
 
 	skb = nlmsg_new(xfrm_report_msgsize(), GFP_ATOMIC);
-- 
1.5.6.5

