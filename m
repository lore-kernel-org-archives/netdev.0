From: kaber@trash.net
Subject: [PATCH 03/37] netfilter: x_tables: return -ENOENT for non-existant matches/targets
Date: Tue, 15 Mar 2011 20:43:43 +0100
Message-ID: <1300218257-26953-4-git-send-email-kaber@trash.net>
References: <1300218257-26953-1-git-send-email-kaber@trash.net>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1300218257-26953-1-git-send-email-kaber@trash.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Patrick McHardy <kaber@trash.net>

As Stephen correctly points out, we need to return -ENOENT in
xt_find_match()/xt_find_target() after the patch "netfilter: x_tables:
misuse of try_then_request_module" in order to properly indicate
a non-existant module to the caller.

Signed-off-by: Patrick McHardy <kaber@trash.net>
---
 net/netfilter/x_tables.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/netfilter/x_tables.c b/net/netfilter/x_tables.c
index 271eed3..a9adf4c 100644
--- a/net/netfilter/x_tables.c
+++ b/net/netfilter/x_tables.c
@@ -190,7 +190,7 @@ EXPORT_SYMBOL(xt_unregister_matches);
 struct xt_match *xt_find_match(u8 af, const char *name, u8 revision)
 {
 	struct xt_match *m;
-	int err = 0;
+	int err = -ENOENT;
 
 	if (mutex_lock_interruptible(&xt[af].mutex) != 0)
 		return ERR_PTR(-EINTR);
@@ -235,7 +235,7 @@ EXPORT_SYMBOL_GPL(xt_request_find_match);
 struct xt_target *xt_find_target(u8 af, const char *name, u8 revision)
 {
 	struct xt_target *t;
-	int err = 0;
+	int err = -ENOENT;
 
 	if (mutex_lock_interruptible(&xt[af].mutex) != 0)
 		return ERR_PTR(-EINTR);
-- 
1.7.2.3

