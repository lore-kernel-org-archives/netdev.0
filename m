From: Joe Perches <joe@perches.com>
Subject: [PATCH V2 -next] netfilter: Use LOGLEVEL_<FOO> defines
Date: Mon, 23 Mar 2015 11:50:10 -0700
Message-ID: <1427136610.16851.29.camel@perches.com>
References: <20150323140841.0b807b95@canb.auug.org.au>
	 <20150323124723.GA6740@salvia> <1427115331.16851.11.camel@perches.com>
	 <20150323130638.GA6857@salvia> <1427117031.16851.16.camel@perches.com>
	 <20150324003828.0eac53d9@canb.auug.org.au> <20150323135235.GA7595@salvia>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Stephen Rothwell <sfr@canb.auug.org.au>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Patrick McHardy <kaber@trash.net>,
	netfilter-devel <netfilter-devel@vger.kernel.org>
To: Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20150323135235.GA7595@salvia>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Use the #defines where appropriate.

Miscellanea:

Add explicit #include <linux/kernel.h> where it was not
previously used so that these #defines are a bit more
explicitly defined instead of indirectly included via:
	module.h->moduleparam.h->kernel.h

Signed-off-by: Joe Perches <joe@perches.com>
---

I really don't want to get into unwinding all the
various #include dependencies.  kernel.h is pretty
generic and effectively used throughout the tree
to centralize various #includes.

 net/ipv4/netfilter/nf_log_arp.c  | 4 +++-
 net/ipv4/netfilter/nf_log_ipv4.c | 4 +++-
 net/ipv6/netfilter/ip6_tables.c  | 5 ++++-
 net/ipv6/netfilter/nf_log_ipv6.c | 4 +++-
 net/netfilter/nf_tables_core.c   | 3 ++-
 net/netfilter/nft_log.c          | 2 +-
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
index 9a9e874..174e1f5 100644
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
