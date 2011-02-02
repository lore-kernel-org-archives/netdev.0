From: kaber@trash.net
Subject: [PATCH 3/4] netfilter: arpt_mangle: fix return values of checkentry
Date: Thu,  3 Feb 2011 00:45:29 +0100
Message-ID: <1296690330-9887-4-git-send-email-kaber@trash.net>
References: <1296690330-9887-1-git-send-email-kaber@trash.net>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1296690330-9887-1-git-send-email-kaber@trash.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Pablo Neira Ayuso <pablo@netfilter.org>

In 135367b "netfilter: xtables: change xt_target.checkentry return type",
the type returned by checkentry was changed from boolean to int, but the
return values where not adjusted.

arptables: Input/output error

This broke arptables with the mangle target since it returns true
under success, which is interpreted by xtables as >0, thus
returning EIO.

Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
Signed-off-by: Patrick McHardy <kaber@trash.net>
---
 net/ipv4/netfilter/arpt_mangle.c |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/net/ipv4/netfilter/arpt_mangle.c b/net/ipv4/netfilter/arpt_mangle.c
index b8ddcc4..a5e52a9 100644
--- a/net/ipv4/netfilter/arpt_mangle.c
+++ b/net/ipv4/netfilter/arpt_mangle.c
@@ -60,12 +60,12 @@ static int checkentry(const struct xt_tgchk_param *par)
 
 	if (mangle->flags & ~ARPT_MANGLE_MASK ||
 	    !(mangle->flags & ARPT_MANGLE_MASK))
-		return false;
+		return -EINVAL;
 
 	if (mangle->target != NF_DROP && mangle->target != NF_ACCEPT &&
 	   mangle->target != XT_CONTINUE)
-		return false;
-	return true;
+		return -EINVAL;
+	return 0;
 }
 
 static struct xt_target arpt_mangle_reg __read_mostly = {
-- 
1.7.2.3

