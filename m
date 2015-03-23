From: Joe Perches <joe@perches.com>
Subject: [PATCH -next] netfilter: Use LOGLEVEL_<FOO> defines
Date: Mon, 23 Mar 2015 06:23:51 -0700
Message-ID: <1427117031.16851.16.camel@perches.com>
References: <20150323140841.0b807b95@canb.auug.org.au>
	 <20150323124723.GA6740@salvia> <1427115331.16851.11.camel@perches.com>
	 <20150323130638.GA6857@salvia>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Stephen Rothwell <sfr@canb.auug.org.au>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Patrick McHardy <kaber@trash.net>
To: Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20150323130638.GA6857@salvia>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Use the #defines where appropriate.

Signed-off-by: Joe Perches <joe@perches.com>
---
> > Perhaps all the .level = 4 uses should be LOGLEVEL_WARNING
> > and .level = 5 should be LOGLEVEL_NOTICE
> 
> Yes, we can push a follow up patch to net-next changing all these
> spots in the netfilter tree. Would you send a patch for this?

There are indirect includes of kern_levels.h but there are a
lot of indirect includes of kernel.h in netfilter

 net/ipv4/netfilter/nf_log_arp.c  | 2 +-
 net/ipv4/netfilter/nf_log_ipv4.c | 2 +-
 net/ipv6/netfilter/ip6_tables.c  | 2 +-
 net/ipv6/netfilter/nf_log_ipv6.c | 2 +-
 net/netfilter/nf_tables_core.c   | 2 +-
 net/netfilter/nft_log.c          | 2 +-
 6 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/net/ipv4/netfilter/nf_log_arp.c b/net/ipv4/netfilter/nf_log_arp.c
index d059182..1fe8d62 100644
--- a/net/ipv4/netfilter/nf_log_arp.c
+++ b/net/ipv4/netfilter/nf_log_arp.c
@@ -27,7 +27,7 @@ static struct nf_loginfo default_loginfo = {
 	.type	= NF_LOG_TYPE_LOG,
 	.u = {
 		.log = {
-			.level	  = 5,
+			.level	  = LOGLEVEL_NOTICE,
 			.logflags = NF_LOG_MASK,
 		},
 	},
diff --git a/net/ipv4/netfilter/nf_log_ipv4.c b/net/ipv4/netfilter/nf_log_ipv4.c
index 7510198..1e0ad92 100644
--- a/net/ipv4/netfilter/nf_log_ipv4.c
+++ b/net/ipv4/netfilter/nf_log_ipv4.c
@@ -26,7 +26,7 @@ static struct nf_loginfo default_loginfo = {
 	.type	= NF_LOG_TYPE_LOG,
 	.u = {
 		.log = {
-			.level	  = 5,
+			.level	  = LOGLEVEL_NOTICE,
 			.logflags = NF_LOG_MASK,
 		},
 	},
diff --git a/net/ipv6/netfilter/ip6_tables.c b/net/ipv6/netfilter/ip6_tables.c
index bb00c6f..0784cec 100644
--- a/net/ipv6/netfilter/ip6_tables.c
+++ b/net/ipv6/netfilter/ip6_tables.c
@@ -234,7 +234,7 @@ static struct nf_loginfo trace_loginfo = {
 	.type = NF_LOG_TYPE_LOG,
 	.u = {
 		.log = {
-			.level = 4,
+			.level = LOGLEVEL_WARNING,
 			.logflags = NF_LOG_MASK,
 		},
 	},
diff --git a/net/ipv6/netfilter/nf_log_ipv6.c b/net/ipv6/netfilter/nf_log_ipv6.c
index ddf07e6..b57a784 100644
--- a/net/ipv6/netfilter/nf_log_ipv6.c
+++ b/net/ipv6/netfilter/nf_log_ipv6.c
@@ -27,7 +27,7 @@ static struct nf_loginfo default_loginfo = {
 	.type	= NF_LOG_TYPE_LOG,
 	.u = {
 		.log = {
-			.level	  = 5,
+			.level	  = LOGLEVEL_NOTICE,
 			.logflags = NF_LOG_MASK,
 		},
 	},
diff --git a/net/netfilter/nf_tables_core.c b/net/netfilter/nf_tables_core.c
index 9a9e874..0a45e6b 100644
--- a/net/netfilter/nf_tables_core.c
+++ b/net/netfilter/nf_tables_core.c
@@ -37,7 +37,7 @@ static struct nf_loginfo trace_loginfo = {
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
