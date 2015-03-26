From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 02/15] netfilter: Use LOGLEVEL_<FOO> defines
Date: Thu, 26 Mar 2015 13:06:49 +0100
Message-ID: <1427371622-4466-3-git-send-email-pablo@netfilter.org>
References: <1427371622-4466-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1427371622-4466-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Joe Perches <joe@perches.com>

Use the #defines where appropriate.

Miscellanea:

Add explicit #include <linux/kernel.h> where it was not
previously used so that these #defines are a bit more
explicitly defined instead of indirectly included via:
	module.h->moduleparam.h->kernel.h

Signed-off-by: Joe Perches <joe@perches.com>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/ipv4/netfilter/nf_log_arp.c  |    4 +++-
 net/ipv4/netfilter/nf_log_ipv4.c |    4 +++-
 net/ipv6/netfilter/ip6_tables.c  |    5 ++++-
 net/ipv6/netfilter/nf_log_ipv6.c |    4 +++-
 net/netfilter/nf_tables_core.c   |    3 ++-
 net/netfilter/nft_log.c          |    2 +-
 6 files changed, 16 insertions(+), 6 deletions(-)

diff --git a/net/ipv4/netfilter/nf_log_arp.c b/net/ipv4/netfilter/nf_log_arp.c
index d059182..e7ad950 100644
--- a/net/ipv4/netfilter/nf_log_arp.c
+++ b/net/ipv4/netfilter/nf_log_arp.c
@@ -10,8 +10,10 @@
  * it under the terms of the GNU General Public License version 2 as
  * published by the Free Software Foundation.
  */
+
 #define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
 
+#include <linux/kernel.h>
 #include <linux/module.h>
 #include <linux/spinlock.h>
 #include <linux/skbuff.h>
@@ -27,7 +29,7 @@ static struct nf_loginfo default_loginfo = {
 	.type	= NF_LOG_TYPE_LOG,
 	.u = {
 		.log = {
-			.level	  = 5,
+			.level	  = LOGLEVEL_NOTICE,
 			.logflags = NF_LOG_MASK,
 		},
 	},
diff --git a/net/ipv4/netfilter/nf_log_ipv4.c b/net/ipv4/netfilter/nf_log_ipv4.c
index 7510198..076aadd 100644
--- a/net/ipv4/netfilter/nf_log_ipv4.c
+++ b/net/ipv4/netfilter/nf_log_ipv4.c
@@ -5,8 +5,10 @@
  * it under the terms of the GNU General Public License version 2 as
  * published by the Free Software Foundation.
  */
+
 #define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
 
+#include <linux/kernel.h>
 #include <linux/module.h>
 #include <linux/spinlock.h>
 #include <linux/skbuff.h>
@@ -26,7 +28,7 @@ static struct nf_loginfo default_loginfo = {
 	.type	= NF_LOG_TYPE_LOG,
 	.u = {
 		.log = {
-			.level	  = 5,
+			.level	  = LOGLEVEL_NOTICE,
 			.logflags = NF_LOG_MASK,
 		},
 	},
diff --git a/net/ipv6/netfilter/ip6_tables.c b/net/ipv6/netfilter/ip6_tables.c
index bb00c6f..83f59dc 100644
--- a/net/ipv6/netfilter/ip6_tables.c
+++ b/net/ipv6/netfilter/ip6_tables.c
@@ -9,7 +9,10 @@
  * it under the terms of the GNU General Public License version 2 as
  * published by the Free Software Foundation.
  */
+
 #define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
+
+#include <linux/kernel.h>
 #include <linux/capability.h>
 #include <linux/in.h>
 #include <linux/skbuff.h>
@@ -234,7 +237,7 @@ static struct nf_loginfo trace_loginfo = {
 	.type = NF_LOG_TYPE_LOG,
 	.u = {
 		.log = {
-			.level = 4,
+			.level = LOGLEVEL_WARNING,
 			.logflags = NF_LOG_MASK,
 		},
 	},
diff --git a/net/ipv6/netfilter/nf_log_ipv6.c b/net/ipv6/netfilter/nf_log_ipv6.c
index ddf07e6..8dd8696 100644
--- a/net/ipv6/netfilter/nf_log_ipv6.c
+++ b/net/ipv6/netfilter/nf_log_ipv6.c
@@ -5,8 +5,10 @@
  * it under the terms of the GNU General Public License version 2 as
  * published by the Free Software Foundation.
  */
+
 #define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
 
+#include <linux/kernel.h>
 #include <linux/module.h>
 #include <linux/spinlock.h>
 #include <linux/skbuff.h>
@@ -27,7 +29,7 @@ static struct nf_loginfo default_loginfo = {
 	.type	= NF_LOG_TYPE_LOG,
 	.u = {
 		.log = {
-			.level	  = 5,
+			.level	  = LOGLEVEL_NOTICE,
 			.logflags = NF_LOG_MASK,
 		},
 	},
diff --git a/net/netfilter/nf_tables_core.c b/net/netfilter/nf_tables_core.c
index 4c921a3..763a9d8 100644
--- a/net/netfilter/nf_tables_core.c
+++ b/net/netfilter/nf_tables_core.c
@@ -8,6 +8,7 @@
  * Development of this code funded by Astaro AG (http://www.astaro.com/)
  */
 
+#include <linux/kernel.h>
 #include <linux/module.h>
 #include <linux/init.h>
 #include <linux/list.h>
@@ -37,7 +38,7 @@ static struct nf_loginfo trace_loginfo = {
 	.type = NF_LOG_TYPE_LOG,
 	.u = {
 		.log = {
-			.level = 4,
+			.level = LOGLEVEL_WARNING,
 			.logflags = NF_LOG_MASK,
 	        },
 	},
diff --git a/net/netfilter/nft_log.c b/net/netfilter/nft_log.c
index bde05f28..e18af9db 100644
--- a/net/netfilter/nft_log.c
+++ b/net/netfilter/nft_log.c
@@ -78,7 +78,7 @@ static int nft_log_init(const struct nft_ctx *ctx,
 			li->u.log.level =
 				ntohl(nla_get_be32(tb[NFTA_LOG_LEVEL]));
 		} else {
-			li->u.log.level = 4;
+			li->u.log.level = LOGLEVEL_WARNING;
 		}
 		if (tb[NFTA_LOG_FLAGS] != NULL) {
 			li->u.log.logflags =
-- 
1.7.10.4

