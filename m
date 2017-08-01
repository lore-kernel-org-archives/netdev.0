From: Julia Lawall <Julia.Lawall@lip6.fr>
Subject: [PATCH nf-next] netfilter: constify nf_loginfo structures
Date: Tue,  1 Aug 2017 12:48:03 +0200
Message-ID: <1501584483-999-1-git-send-email-Julia.Lawall@lip6.fr>
Cc: kernel-janitors@vger.kernel.org, linux-kernel@vger.kernel.org,
        netdev@vger.kernel.org, coreteam@netfilter.org,
        netfilter-devel@vger.kernel.org, Florian Westphal <fw@strlen.de>,
        Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>,
        Pablo Neira Ayuso <pablo@netfilter.org>,
        Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
        Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

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

---
 net/ipv4/netfilter/ip_tables.c   |    2 +-
 net/ipv4/netfilter/nf_log_arp.c  |    2 +-
 net/ipv4/netfilter/nf_log_ipv4.c |    2 +-
 net/ipv6/netfilter/ip6_tables.c  |    2 +-
 net/ipv6/netfilter/nf_log_ipv6.c |    2 +-
 net/netfilter/nf_tables_core.c   |    2 +-
 net/netfilter/nfnetlink_log.c    |    2 +-
 7 files changed, 7 insertions(+), 7 deletions(-)

diff --git a/net/netfilter/nf_tables_core.c b/net/netfilter/nf_tables_core.c
index c5bab08..dfd0bf3 100644
--- a/net/netfilter/nf_tables_core.c
+++ b/net/netfilter/nf_tables_core.c
@@ -29,7 +29,7 @@
 	[NFT_TRACETYPE_RULE]	= "rule",
 };
 
-static struct nf_loginfo trace_loginfo = {
+static const struct nf_loginfo trace_loginfo = {
 	.type = NF_LOG_TYPE_LOG,
 	.u = {
 		.log = {
diff --git a/net/netfilter/nfnetlink_log.c b/net/netfilter/nfnetlink_log.c
index c684ba9..cad6498 100644
--- a/net/netfilter/nfnetlink_log.c
+++ b/net/netfilter/nfnetlink_log.c
@@ -606,7 +606,7 @@ static void nfulnl_instance_free_rcu(struct rcu_head *head)
 	return -1;
 }
 
-static struct nf_loginfo default_loginfo = {
+static const struct nf_loginfo default_loginfo = {
 	.type =		NF_LOG_TYPE_ULOG,
 	.u = {
 		.ulog = {
diff --git a/net/ipv4/netfilter/ip_tables.c b/net/ipv4/netfilter/ip_tables.c
index 2a55a40..96a289c 100644
--- a/net/ipv4/netfilter/ip_tables.c
+++ b/net/ipv4/netfilter/ip_tables.c
@@ -151,7 +151,7 @@ enum nf_ip_trace_comments {
 	[NF_IP_TRACE_COMMENT_POLICY]	= "policy",
 };
 
-static struct nf_loginfo trace_loginfo = {
+static const struct nf_loginfo trace_loginfo = {
 	.type = NF_LOG_TYPE_LOG,
 	.u = {
 		.log = {
diff --git a/net/ipv4/netfilter/nf_log_arp.c b/net/ipv4/netfilter/nf_log_arp.c
index 2f3895d..df5c2a2 100644
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
index c83a996..4388de0 100644
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
index 1f90644..9f66449 100644
--- a/net/ipv6/netfilter/ip6_tables.c
+++ b/net/ipv6/netfilter/ip6_tables.c
@@ -176,7 +176,7 @@ enum nf_ip_trace_comments {
 	[NF_IP6_TRACE_COMMENT_POLICY]	= "policy",
 };
 
-static struct nf_loginfo trace_loginfo = {
+static const struct nf_loginfo trace_loginfo = {
 	.type = NF_LOG_TYPE_LOG,
 	.u = {
 		.log = {
diff --git a/net/ipv6/netfilter/nf_log_ipv6.c b/net/ipv6/netfilter/nf_log_ipv6.c
index 97c7242..b397a8f 100644
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
