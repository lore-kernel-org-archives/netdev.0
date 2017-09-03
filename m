From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 23/47] netfilter: constify nf_loginfo structures
Date: Mon,  4 Sep 2017 00:40:11 +0200
Message-ID: <1504478435-13160-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Julia Lawall <julia.lawall@lip6.fr>

The nf_loginfo structures are only passed as the seventh argument to
nf_log_trace, which is declared as const or stored in a local const
variable.  Thus the nf_loginfo structures themselves can be const.

Done with the help of Coccinelle.

// <smpl>
@r disable optional_qualifier@
identifier i;
position p;
@@
static struct nf_loginfo i@p = { ... };

@ok1@
identifier r.i;
expression list[6] es;
position p;
@@
 nf_log_trace(es,&i@p,...)

@ok2@
identifier r.i;
const struct nf_loginfo *e;
position p;
@@
 e = &i@p

@bad@
position p != {r.p,ok1.p,ok2.p};
identifier r.i;
struct nf_loginfo e;
@@
e@i@p

@depends on !bad disable optional_qualifier@
identifier r.i;
@@
static
+const
 struct nf_loginfo i = { ... };
// </smpl>

Signed-off-by: Julia Lawall <Julia.Lawall@lip6.fr>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/ipv4/netfilter/ip_tables.c   | 2 +-
 net/ipv4/netfilter/nf_log_arp.c  | 2 +-
 net/ipv4/netfilter/nf_log_ipv4.c | 2 +-
 net/ipv6/netfilter/ip6_tables.c  | 2 +-
 net/ipv6/netfilter/nf_log_ipv6.c | 2 +-
 net/netfilter/nf_tables_core.c   | 2 +-
 net/netfilter/nfnetlink_log.c    | 2 +-
 7 files changed, 7 insertions(+), 7 deletions(-)

diff --git a/net/ipv4/netfilter/ip_tables.c b/net/ipv4/netfilter/ip_tables.c
index f47e8dad5e95..2aea896f5708 100644
--- a/net/ipv4/netfilter/ip_tables.c
+++ b/net/ipv4/netfilter/ip_tables.c
@@ -151,7 +151,7 @@ static const char *const comments[] = {
 	[NF_IP_TRACE_COMMENT_POLICY]	= "policy",
 };
 
-static struct nf_loginfo trace_loginfo = {
+static const struct nf_loginfo trace_loginfo = {
 	.type = NF_LOG_TYPE_LOG,
 	.u = {
 		.log = {
diff --git a/net/ipv4/netfilter/nf_log_arp.c b/net/ipv4/netfilter/nf_log_arp.c
index 2f3895ddc275..df5c2a2061a4 100644
--- a/net/ipv4/netfilter/nf_log_arp.c
+++ b/net/ipv4/netfilter/nf_log_arp.c
@@ -25,7 +25,7 @@
 #include <linux/netfilter/xt_LOG.h>
 #include <net/netfilter/nf_log.h>
 
-static struct nf_loginfo default_loginfo = {
+static const struct nf_loginfo default_loginfo = {
 	.type	= NF_LOG_TYPE_LOG,
 	.u = {
 		.log = {
diff --git a/net/ipv4/netfilter/nf_log_ipv4.c b/net/ipv4/netfilter/nf_log_ipv4.c
index c83a9963269b..4388de0e5380 100644
--- a/net/ipv4/netfilter/nf_log_ipv4.c
+++ b/net/ipv4/netfilter/nf_log_ipv4.c
@@ -24,7 +24,7 @@
 #include <linux/netfilter/xt_LOG.h>
 #include <net/netfilter/nf_log.h>
 
-static struct nf_loginfo default_loginfo = {
+static const struct nf_loginfo default_loginfo = {
 	.type	= NF_LOG_TYPE_LOG,
 	.u = {
 		.log = {
diff --git a/net/ipv6/netfilter/ip6_tables.c b/net/ipv6/netfilter/ip6_tables.c
index 1f90644056ac..9f6644958e5e 100644
--- a/net/ipv6/netfilter/ip6_tables.c
+++ b/net/ipv6/netfilter/ip6_tables.c
@@ -176,7 +176,7 @@ static const char *const comments[] = {
 	[NF_IP6_TRACE_COMMENT_POLICY]	= "policy",
 };
 
-static struct nf_loginfo trace_loginfo = {
+static const struct nf_loginfo trace_loginfo = {
 	.type = NF_LOG_TYPE_LOG,
 	.u = {
 		.log = {
diff --git a/net/ipv6/netfilter/nf_log_ipv6.c b/net/ipv6/netfilter/nf_log_ipv6.c
index 97c724224da7..b397a8fe88b9 100644
--- a/net/ipv6/netfilter/nf_log_ipv6.c
+++ b/net/ipv6/netfilter/nf_log_ipv6.c
@@ -25,7 +25,7 @@
 #include <linux/netfilter/xt_LOG.h>
 #include <net/netfilter/nf_log.h>
 
-static struct nf_loginfo default_loginfo = {
+static const struct nf_loginfo default_loginfo = {
 	.type	= NF_LOG_TYPE_LOG,
 	.u = {
 		.log = {
diff --git a/net/netfilter/nf_tables_core.c b/net/netfilter/nf_tables_core.c
index c5bab08b0d73..dfd0bf3810d2 100644
--- a/net/netfilter/nf_tables_core.c
+++ b/net/netfilter/nf_tables_core.c
@@ -29,7 +29,7 @@ static const char *const comments[__NFT_TRACETYPE_MAX] = {
 	[NFT_TRACETYPE_RULE]	= "rule",
 };
 
-static struct nf_loginfo trace_loginfo = {
+static const struct nf_loginfo trace_loginfo = {
 	.type = NF_LOG_TYPE_LOG,
 	.u = {
 		.log = {
diff --git a/net/netfilter/nfnetlink_log.c b/net/netfilter/nfnetlink_log.c
index c684ba95dbb4..cad6498f10b0 100644
--- a/net/netfilter/nfnetlink_log.c
+++ b/net/netfilter/nfnetlink_log.c
@@ -606,7 +606,7 @@ __build_packet_message(struct nfnl_log_net *log,
 	return -1;
 }
 
-static struct nf_loginfo default_loginfo = {
+static const struct nf_loginfo default_loginfo = {
 	.type =		NF_LOG_TYPE_ULOG,
 	.u = {
 		.ulog = {
-- 
2.1.4


