From: kaber@trash.net
Subject: [PATCH 35/72] netfilter: xtables: unify {ip,ip6,arp}t_error_target
Date: Thu, 21 Oct 2010 17:19:22 +0200
Message-ID: <1287674399-31455-36-git-send-email-kaber@trash.net>
References: <1287674399-31455-1-git-send-email-kaber@trash.net>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1287674399-31455-1-git-send-email-kaber@trash.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jan Engelhardt <jengelh@medozas.de>

Unification of struct *_error_target was forgotten in
v2.6.16-1689-g1e30a01.

Signed-off-by: Jan Engelhardt <jengelh@medozas.de>
---
 include/linux/netfilter/x_tables.h        |    5 +++++
 include/linux/netfilter_arp/arp_tables.h  |   10 +++-------
 include/linux/netfilter_ipv4/ip_tables.h  |   10 +++-------
 include/linux/netfilter_ipv6/ip6_tables.h |   10 +++-------
 4 files changed, 14 insertions(+), 21 deletions(-)

diff --git a/include/linux/netfilter/x_tables.h b/include/linux/netfilter/x_tables.h
index 24e5d01..742bec0 100644
--- a/include/linux/netfilter/x_tables.h
+++ b/include/linux/netfilter/x_tables.h
@@ -66,6 +66,11 @@ struct xt_standard_target {
 	int verdict;
 };
 
+struct xt_error_target {
+	struct xt_entry_target target;
+	char errorname[XT_FUNCTION_MAXNAMELEN];
+};
+
 /* The argument to IPT_SO_GET_REVISION_*.  Returns highest revision
  * kernel supports, if >= revision. */
 struct xt_get_revision {
diff --git a/include/linux/netfilter_arp/arp_tables.h b/include/linux/netfilter_arp/arp_tables.h
index 6e2341a..f02d574 100644
--- a/include/linux/netfilter_arp/arp_tables.h
+++ b/include/linux/netfilter_arp/arp_tables.h
@@ -26,6 +26,7 @@
 #define ARPT_TABLE_MAXNAMELEN XT_TABLE_MAXNAMELEN
 #define arpt_entry_target xt_entry_target
 #define arpt_standard_target xt_standard_target
+#define arpt_error_target xt_error_target
 #define ARPT_CONTINUE XT_CONTINUE
 #define ARPT_RETURN XT_RETURN
 #define arpt_counters_info xt_counters_info
@@ -216,14 +217,9 @@ struct arpt_standard {
 	struct xt_standard_target target;
 };
 
-struct arpt_error_target {
-	struct xt_entry_target target;
-	char errorname[XT_FUNCTION_MAXNAMELEN];
-};
-
 struct arpt_error {
 	struct arpt_entry entry;
-	struct arpt_error_target target;
+	struct xt_error_target target;
 };
 
 #define ARPT_ENTRY_INIT(__size)						       \
@@ -244,7 +240,7 @@ struct arpt_error {
 {									       \
 	.entry		= ARPT_ENTRY_INIT(sizeof(struct arpt_error)),	       \
 	.target		= XT_TARGET_INIT(XT_ERROR_TARGET,		       \
-					 sizeof(struct arpt_error_target)),    \
+					 sizeof(struct xt_error_target)),      \
 	.target.errorname = "ERROR",					       \
 }
 
diff --git a/include/linux/netfilter_ipv4/ip_tables.h b/include/linux/netfilter_ipv4/ip_tables.h
index ee54b3b..d0fef0a 100644
--- a/include/linux/netfilter_ipv4/ip_tables.h
+++ b/include/linux/netfilter_ipv4/ip_tables.h
@@ -37,6 +37,7 @@
 #define ipt_entry_match xt_entry_match
 #define ipt_entry_target xt_entry_target
 #define ipt_standard_target xt_standard_target
+#define ipt_error_target xt_error_target
 #define ipt_counters xt_counters
 #define IPT_CONTINUE XT_CONTINUE
 #define IPT_RETURN XT_RETURN
@@ -247,14 +248,9 @@ struct ipt_standard {
 	struct xt_standard_target target;
 };
 
-struct ipt_error_target {
-	struct xt_entry_target target;
-	char errorname[XT_FUNCTION_MAXNAMELEN];
-};
-
 struct ipt_error {
 	struct ipt_entry entry;
-	struct ipt_error_target target;
+	struct xt_error_target target;
 };
 
 #define IPT_ENTRY_INIT(__size)						       \
@@ -275,7 +271,7 @@ struct ipt_error {
 {									       \
 	.entry		= IPT_ENTRY_INIT(sizeof(struct ipt_error)),	       \
 	.target		= XT_TARGET_INIT(XT_ERROR_TARGET,		       \
-					 sizeof(struct ipt_error_target)),     \
+					 sizeof(struct xt_error_target)),      \
 	.target.errorname = "ERROR",					       \
 }
 
diff --git a/include/linux/netfilter_ipv6/ip6_tables.h b/include/linux/netfilter_ipv6/ip6_tables.h
index ac2b411..dca1118 100644
--- a/include/linux/netfilter_ipv6/ip6_tables.h
+++ b/include/linux/netfilter_ipv6/ip6_tables.h
@@ -37,6 +37,7 @@
 #define ip6t_entry_match xt_entry_match
 #define ip6t_entry_target xt_entry_target
 #define ip6t_standard_target xt_standard_target
+#define ip6t_error_target xt_error_target
 #define ip6t_counters xt_counters
 #define IP6T_CONTINUE XT_CONTINUE
 #define IP6T_RETURN XT_RETURN
@@ -137,14 +138,9 @@ struct ip6t_standard {
 	struct xt_standard_target target;
 };
 
-struct ip6t_error_target {
-	struct xt_entry_target target;
-	char errorname[XT_FUNCTION_MAXNAMELEN];
-};
-
 struct ip6t_error {
 	struct ip6t_entry entry;
-	struct ip6t_error_target target;
+	struct xt_error_target target;
 };
 
 #define IP6T_ENTRY_INIT(__size)						       \
@@ -165,7 +161,7 @@ struct ip6t_error {
 {									       \
 	.entry		= IP6T_ENTRY_INIT(sizeof(struct ip6t_error)),	       \
 	.target		= XT_TARGET_INIT(XT_ERROR_TARGET,		       \
-					 sizeof(struct ip6t_error_target)),    \
+					 sizeof(struct xt_error_target)),      \
 	.target.errorname = "ERROR",					       \
 }
 
-- 
1.7.1

