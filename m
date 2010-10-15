From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH net-next] xfrm: make xfrm_bundle_ok local
Date: Fri, 15 Oct 2010 08:14:19 -0700
Message-ID: <20101015081419.79252990@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:43038 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755703Ab0JOPOV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 15 Oct 2010 11:14:21 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Only used in one place.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

--- a/include/net/xfrm.h	2010-10-05 23:27:43.971148720 +0900
+++ b/include/net/xfrm.h	2010-10-05 23:27:54.631127801 +0900
@@ -1466,8 +1466,6 @@ struct xfrm_state *xfrm_find_acq(struct 
 				 xfrm_address_t *saddr, int create,
 				 unsigned short family);
 extern int xfrm_sk_policy_insert(struct sock *sk, int dir, struct xfrm_policy *pol);
-extern int xfrm_bundle_ok(struct xfrm_policy *pol, struct xfrm_dst *xdst,
-			  struct flowi *fl, int family, int strict);
 
 #ifdef CONFIG_XFRM_MIGRATE
 extern int km_migrate(struct xfrm_selector *sel, u8 dir, u8 type,
--- a/net/xfrm/xfrm_policy.c	2010-10-05 23:27:43.995125930 +0900
+++ b/net/xfrm/xfrm_policy.c	2010-10-05 23:28:27.244135115 +0900
@@ -50,6 +50,9 @@ static struct xfrm_policy_afinfo *xfrm_p
 static void xfrm_policy_put_afinfo(struct xfrm_policy_afinfo *afinfo);
 static void xfrm_init_pmtu(struct dst_entry *dst);
 static int stale_bundle(struct dst_entry *dst);
+static int xfrm_bundle_ok(struct xfrm_policy *pol, struct xfrm_dst *xdst,
+			  struct flowi *fl, int family, int strict);
+
 
 static struct xfrm_policy *__xfrm_policy_unlink(struct xfrm_policy *pol,
 						int dir);
@@ -2276,7 +2279,7 @@ static void xfrm_init_pmtu(struct dst_en
  * still valid.
  */
 
-int xfrm_bundle_ok(struct xfrm_policy *pol, struct xfrm_dst *first,
+static int xfrm_bundle_ok(struct xfrm_policy *pol, struct xfrm_dst *first,
 		struct flowi *fl, int family, int strict)
 {
 	struct dst_entry *dst = &first->u.dst;
@@ -2358,8 +2361,6 @@ int xfrm_bundle_ok(struct xfrm_policy *p
 	return 1;
 }
 
-EXPORT_SYMBOL(xfrm_bundle_ok);
-
 int xfrm_policy_register_afinfo(struct xfrm_policy_afinfo *afinfo)
 {
 	struct net *net;
