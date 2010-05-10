From: kaber@trash.net
Subject: [PATCH 47/84] netfilter: xtables: shorten up return clause
Date: Mon, 10 May 2010 22:18:18 +0200
Message-ID: <1273522735-24672-48-git-send-email-kaber@trash.net>
References: <1273522735-24672-1-git-send-email-kaber@trash.net>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:54526 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756849Ab0EJUTO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 May 2010 16:19:14 -0400
In-Reply-To: <1273522735-24672-1-git-send-email-kaber@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jan Engelhardt <jengelh@medozas.de>

The return value of nf_ct_l3proto_get can directly be returned even in
the case of success.

Signed-off-by: Jan Engelhardt <jengelh@medozas.de>
---
 net/ipv4/netfilter/ipt_CLUSTERIP.c |    7 ++-----
 net/netfilter/xt_CONNSECMARK.c     |    6 ++----
 net/netfilter/xt_connbytes.c       |    7 ++-----
 net/netfilter/xt_connmark.c        |   12 ++++--------
 net/netfilter/xt_conntrack.c       |    6 ++----
 net/netfilter/xt_state.c           |    6 ++----
 6 files changed, 14 insertions(+), 30 deletions(-)

diff --git a/net/ipv4/netfilter/ipt_CLUSTERIP.c b/net/ipv4/netfilter/ipt_CLUSTERIP.c
index 1faf5fa..5d70c43 100644
--- a/net/ipv4/netfilter/ipt_CLUSTERIP.c
+++ b/net/ipv4/netfilter/ipt_CLUSTERIP.c
@@ -403,13 +403,10 @@ static int clusterip_tg_check(const struct xt_tgchk_param *par)
 	cipinfo->config = config;
 
 	ret = nf_ct_l3proto_try_module_get(par->family);
-	if (ret < 0) {
+	if (ret < 0)
 		pr_info("cannot load conntrack support for proto=%u\n",
 			par->family);
-		return ret;
-	}
-
-	return 0;
+	return ret;
 }
 
 /* drop reference count of cluster config when rule is deleted */
diff --git a/net/netfilter/xt_CONNSECMARK.c b/net/netfilter/xt_CONNSECMARK.c
index 105a62e..e953e30 100644
--- a/net/netfilter/xt_CONNSECMARK.c
+++ b/net/netfilter/xt_CONNSECMARK.c
@@ -107,12 +107,10 @@ static int connsecmark_tg_check(const struct xt_tgchk_param *par)
 	}
 
 	ret = nf_ct_l3proto_try_module_get(par->family);
-	if (ret < 0) {
+	if (ret < 0)
 		pr_info("cannot load conntrack support for proto=%u\n",
 			par->family);
-		return ret;
-	}
-	return 0;
+	return ret;
 }
 
 static void connsecmark_tg_destroy(const struct xt_tgdtor_param *par)
diff --git a/net/netfilter/xt_connbytes.c b/net/netfilter/xt_connbytes.c
index 2ff332e..ff738a5 100644
--- a/net/netfilter/xt_connbytes.c
+++ b/net/netfilter/xt_connbytes.c
@@ -109,13 +109,10 @@ static int connbytes_mt_check(const struct xt_mtchk_param *par)
 		return -EINVAL;
 
 	ret = nf_ct_l3proto_try_module_get(par->family);
-	if (ret < 0) {
+	if (ret < 0)
 		pr_info("cannot load conntrack support for proto=%u\n",
 			par->family);
-		return ret;
-	}
-
-	return 0;
+	return ret;
 }
 
 static void connbytes_mt_destroy(const struct xt_mtdtor_param *par)
diff --git a/net/netfilter/xt_connmark.c b/net/netfilter/xt_connmark.c
index 71e38a1..ae10154 100644
--- a/net/netfilter/xt_connmark.c
+++ b/net/netfilter/xt_connmark.c
@@ -79,12 +79,10 @@ static int connmark_tg_check(const struct xt_tgchk_param *par)
 	int ret;
 
 	ret = nf_ct_l3proto_try_module_get(par->family);
-	if (ret < 0) {
+	if (ret < 0)
 		pr_info("cannot load conntrack support for proto=%u\n",
 			par->family);
-		return ret;
-	}
-	return 0;
+	return ret;
 }
 
 static void connmark_tg_destroy(const struct xt_tgdtor_param *par)
@@ -111,12 +109,10 @@ static int connmark_mt_check(const struct xt_mtchk_param *par)
 	int ret;
 
 	ret = nf_ct_l3proto_try_module_get(par->family);
-	if (ret < 0) {
+	if (ret < 0)
 		pr_info("cannot load conntrack support for proto=%u\n",
 			par->family);
-		return ret;
-	}
-	return 0;
+	return ret;
 }
 
 static void connmark_mt_destroy(const struct xt_mtdtor_param *par)
diff --git a/net/netfilter/xt_conntrack.c b/net/netfilter/xt_conntrack.c
index e0bcf8d..3348706 100644
--- a/net/netfilter/xt_conntrack.c
+++ b/net/netfilter/xt_conntrack.c
@@ -211,12 +211,10 @@ static int conntrack_mt_check(const struct xt_mtchk_param *par)
 	int ret;
 
 	ret = nf_ct_l3proto_try_module_get(par->family);
-	if (ret < 0) {
+	if (ret < 0)
 		pr_info("cannot load conntrack support for proto=%u\n",
 			par->family);
-		return ret;
-	}
-	return 0;
+	return ret;
 }
 
 static void conntrack_mt_destroy(const struct xt_mtdtor_param *par)
diff --git a/net/netfilter/xt_state.c b/net/netfilter/xt_state.c
index 2b75230..be00d7b 100644
--- a/net/netfilter/xt_state.c
+++ b/net/netfilter/xt_state.c
@@ -42,12 +42,10 @@ static int state_mt_check(const struct xt_mtchk_param *par)
 	int ret;
 
 	ret = nf_ct_l3proto_try_module_get(par->family);
-	if (ret < 0) {
+	if (ret < 0)
 		pr_info("cannot load conntrack support for proto=%u\n",
 			par->family);
-		return ret;
-	}
-	return 0;
+	return ret;
 }
 
 static void state_mt_destroy(const struct xt_mtdtor_param *par)
-- 
1.7.0.4

