From: Patrick McHardy <kaber@trash.net>
Subject: [NET_SCHED 01/04]: Constify struct tcf_ext_map
Date: Thu, 31 Jan 2008 18:58:03 +0100 (MET)
Message-ID: <20080131175759.25151.63480.sendpatchset@localhost.localdomain>
References: <20080131175758.25151.20370.sendpatchset@localhost.localdomain>
Cc: netdev@vger.kernel.org, shemminger@vyatta.com,
	Patrick McHardy <kaber@trash.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:55144 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757261AbYAaR6F (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 31 Jan 2008 12:58:05 -0500
In-Reply-To: <20080131175758.25151.20370.sendpatchset@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[NET_SCHED]: Constify struct tcf_ext_map

Signed-off-by: Patrick McHardy <kaber@trash.net>

---
commit 12e33ddf57910b685501df10bd92223ea9b98fd6
tree 1ce47c7b6b6b968940f3dc28f9d7839e78c85089
parent 8af03e782cae1e0a0f530ddd22301cdd12cf9dc0
author Patrick McHardy <kaber@trash.net> Wed, 30 Jan 2008 21:59:26 +0100
committer Patrick McHardy <kaber@trash.net> Thu, 31 Jan 2008 18:52:55 +0100

 include/net/pkt_cls.h   |    6 +++---
 net/sched/cls_api.c     |    6 +++---
 net/sched/cls_basic.c   |    2 +-
 net/sched/cls_fw.c      |    2 +-
 net/sched/cls_route.c   |    2 +-
 net/sched/cls_tcindex.c |    2 +-
 net/sched/cls_u32.c     |    2 +-
 7 files changed, 11 insertions(+), 11 deletions(-)

diff --git a/include/net/pkt_cls.h b/include/net/pkt_cls.h
index 8716eb7..d349c66 100644
--- a/include/net/pkt_cls.h
+++ b/include/net/pkt_cls.h
@@ -131,14 +131,14 @@ tcf_exts_exec(struct sk_buff *skb, struct tcf_exts *exts,
 
 extern int tcf_exts_validate(struct tcf_proto *tp, struct nlattr **tb,
 	                     struct nlattr *rate_tlv, struct tcf_exts *exts,
-	                     struct tcf_ext_map *map);
+	                     const struct tcf_ext_map *map);
 extern void tcf_exts_destroy(struct tcf_proto *tp, struct tcf_exts *exts);
 extern void tcf_exts_change(struct tcf_proto *tp, struct tcf_exts *dst,
 	                     struct tcf_exts *src);
 extern int tcf_exts_dump(struct sk_buff *skb, struct tcf_exts *exts,
-	                 struct tcf_ext_map *map);
+	                 const struct tcf_ext_map *map);
 extern int tcf_exts_dump_stats(struct sk_buff *skb, struct tcf_exts *exts,
-	                       struct tcf_ext_map *map);
+	                       const struct tcf_ext_map *map);
 
 /**
  * struct tcf_pkt_info - packet information
diff --git a/net/sched/cls_api.c b/net/sched/cls_api.c
index 3377ca0..0fbedca 100644
--- a/net/sched/cls_api.c
+++ b/net/sched/cls_api.c
@@ -482,7 +482,7 @@ EXPORT_SYMBOL(tcf_exts_destroy);
 
 int tcf_exts_validate(struct tcf_proto *tp, struct nlattr **tb,
 		  struct nlattr *rate_tlv, struct tcf_exts *exts,
-		  struct tcf_ext_map *map)
+		  const struct tcf_ext_map *map)
 {
 	memset(exts, 0, sizeof(*exts));
 
@@ -535,7 +535,7 @@ void tcf_exts_change(struct tcf_proto *tp, struct tcf_exts *dst,
 EXPORT_SYMBOL(tcf_exts_change);
 
 int tcf_exts_dump(struct sk_buff *skb, struct tcf_exts *exts,
-	      struct tcf_ext_map *map)
+		  const struct tcf_ext_map *map)
 {
 #ifdef CONFIG_NET_CLS_ACT
 	if (map->action && exts->action) {
@@ -571,7 +571,7 @@ EXPORT_SYMBOL(tcf_exts_dump);
 
 
 int tcf_exts_dump_stats(struct sk_buff *skb, struct tcf_exts *exts,
-			struct tcf_ext_map *map)
+			const struct tcf_ext_map *map)
 {
 #ifdef CONFIG_NET_CLS_ACT
 	if (exts->action)
diff --git a/net/sched/cls_basic.c b/net/sched/cls_basic.c
index bfb4342..956915c 100644
--- a/net/sched/cls_basic.c
+++ b/net/sched/cls_basic.c
@@ -35,7 +35,7 @@ struct basic_filter
 	struct list_head	link;
 };
 
-static struct tcf_ext_map basic_ext_map = {
+static const struct tcf_ext_map basic_ext_map = {
 	.action = TCA_BASIC_ACT,
 	.police = TCA_BASIC_POLICE
 };
diff --git a/net/sched/cls_fw.c b/net/sched/cls_fw.c
index 436a6e7..b0f90e5 100644
--- a/net/sched/cls_fw.c
+++ b/net/sched/cls_fw.c
@@ -47,7 +47,7 @@ struct fw_filter
 	struct tcf_exts		exts;
 };
 
-static struct tcf_ext_map fw_ext_map = {
+static const struct tcf_ext_map fw_ext_map = {
 	.action = TCA_FW_ACT,
 	.police = TCA_FW_POLICE
 };
diff --git a/net/sched/cls_route.c b/net/sched/cls_route.c
index f7e7d39..784dcb8 100644
--- a/net/sched/cls_route.c
+++ b/net/sched/cls_route.c
@@ -62,7 +62,7 @@ struct route4_filter
 
 #define ROUTE4_FAILURE ((struct route4_filter*)(-1L))
 
-static struct tcf_ext_map route_ext_map = {
+static const struct tcf_ext_map route_ext_map = {
 	.police = TCA_ROUTE4_POLICE,
 	.action = TCA_ROUTE4_ACT
 };
diff --git a/net/sched/cls_tcindex.c b/net/sched/cls_tcindex.c
index ee60b2d..7a7bff5 100644
--- a/net/sched/cls_tcindex.c
+++ b/net/sched/cls_tcindex.c
@@ -55,7 +55,7 @@ struct tcindex_data {
 	int fall_through;	/* 0: only classify if explicit match */
 };
 
-static struct tcf_ext_map tcindex_ext_map = {
+static const struct tcf_ext_map tcindex_ext_map = {
 	.police = TCA_TCINDEX_POLICE,
 	.action = TCA_TCINDEX_ACT
 };
diff --git a/net/sched/cls_u32.c b/net/sched/cls_u32.c
index e8a7756..b18fa95 100644
--- a/net/sched/cls_u32.c
+++ b/net/sched/cls_u32.c
@@ -82,7 +82,7 @@ struct tc_u_common
 	u32			hgenerator;
 };
 
-static struct tcf_ext_map u32_ext_map = {
+static const struct tcf_ext_map u32_ext_map = {
 	.action = TCA_U32_ACT,
 	.police = TCA_U32_POLICE
 };
