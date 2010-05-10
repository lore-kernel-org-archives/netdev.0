From: kaber@trash.net
Subject: [PATCH 41/84] netfilter: xtables: untangle spaghetti if clauses in checkentry
Date: Mon, 10 May 2010 22:18:12 +0200
Message-ID: <1273522735-24672-42-git-send-email-kaber@trash.net>
References: <1273522735-24672-1-git-send-email-kaber@trash.net>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1273522735-24672-1-git-send-email-kaber@trash.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jan Engelhardt <jengelh@medozas.de>

As I'm changing the return values soon, I want to have a clear visual
path.

Signed-off-by: Jan Engelhardt <jengelh@medozas.de>
---
 net/netfilter/xt_dccp.c |   10 +++++++---
 net/netfilter/xt_sctp.c |   20 ++++++++++++--------
 2 files changed, 19 insertions(+), 11 deletions(-)

diff --git a/net/netfilter/xt_dccp.c b/net/netfilter/xt_dccp.c
index 0989f29..8f6014f 100644
--- a/net/netfilter/xt_dccp.c
+++ b/net/netfilter/xt_dccp.c
@@ -127,9 +127,13 @@ static bool dccp_mt_check(const struct xt_mtchk_param *par)
 {
 	const struct xt_dccp_info *info = par->matchinfo;
 
-	return !(info->flags & ~XT_DCCP_VALID_FLAGS)
-		&& !(info->invflags & ~XT_DCCP_VALID_FLAGS)
-		&& !(info->invflags & ~info->flags);
+	if (info->flags & ~XT_DCCP_VALID_FLAGS)
+		return false;
+	if (info->invflags & ~XT_DCCP_VALID_FLAGS)
+		return false;
+	if (info->invflags & ~info->flags)
+		return false;
+	return true;
 }
 
 static struct xt_match dccp_mt_reg[] __read_mostly = {
diff --git a/net/netfilter/xt_sctp.c b/net/netfilter/xt_sctp.c
index 43c7e1d..977b182 100644
--- a/net/netfilter/xt_sctp.c
+++ b/net/netfilter/xt_sctp.c
@@ -148,14 +148,18 @@ static bool sctp_mt_check(const struct xt_mtchk_param *par)
 {
 	const struct xt_sctp_info *info = par->matchinfo;
 
-	return !(info->flags & ~XT_SCTP_VALID_FLAGS)
-		&& !(info->invflags & ~XT_SCTP_VALID_FLAGS)
-		&& !(info->invflags & ~info->flags)
-		&& ((!(info->flags & XT_SCTP_CHUNK_TYPES)) ||
-			(info->chunk_match_type &
-				(SCTP_CHUNK_MATCH_ALL
-				| SCTP_CHUNK_MATCH_ANY
-				| SCTP_CHUNK_MATCH_ONLY)));
+	if (info->flags & ~XT_SCTP_VALID_FLAGS)
+		return false;
+	if (info->invflags & ~XT_SCTP_VALID_FLAGS)
+		return false;
+	if (info->invflags & ~info->flags)
+		return false;
+	if (!(info->flags & XT_SCTP_CHUNK_TYPES))
+		return true;
+	if (info->chunk_match_type & (SCTP_CHUNK_MATCH_ALL |
+	    SCTP_CHUNK_MATCH_ANY | SCTP_CHUNK_MATCH_ONLY))
+		return true;
+	return false;
 }
 
 static struct xt_match sctp_mt_reg[] __read_mostly = {
-- 
1.7.0.4

