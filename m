From: kaber@trash.net
Subject: [PATCH 1/8] netfilter: xt_rateest: fix xt_rateest_mt_checkentry()
Date: Tue, 30 Aug 2011 16:41:14 +0200
Message-ID: <1314715281-26233-2-git-send-email-kaber@trash.net>
References: <1314715281-26233-1-git-send-email-kaber@trash.net>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1314715281-26233-1-git-send-email-kaber@trash.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Eric Dumazet <eric.dumazet@gmail.com>

commit 4a5a5c73b7cfee (slightly better error reporting) added some
useless code in xt_rateest_mt_checkentry().

Fix this so that different error codes can really be returned.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
CC: Jan Engelhardt <jengelh@medozas.de>
Signed-off-by: Patrick McHardy <kaber@trash.net>
---
 net/netfilter/xt_rateest.c |    9 ++++-----
 1 files changed, 4 insertions(+), 5 deletions(-)

diff --git a/net/netfilter/xt_rateest.c b/net/netfilter/xt_rateest.c
index 76a0831..ed0db15 100644
--- a/net/netfilter/xt_rateest.c
+++ b/net/netfilter/xt_rateest.c
@@ -78,7 +78,7 @@ static int xt_rateest_mt_checkentry(const struct xt_mtchk_param *par)
 {
 	struct xt_rateest_match_info *info = par->matchinfo;
 	struct xt_rateest *est1, *est2;
-	int ret = false;
+	int ret = -EINVAL;
 
 	if (hweight32(info->flags & (XT_RATEEST_MATCH_ABS |
 				     XT_RATEEST_MATCH_REL)) != 1)
@@ -101,13 +101,12 @@ static int xt_rateest_mt_checkentry(const struct xt_mtchk_param *par)
 	if (!est1)
 		goto err1;
 
+	est2 = NULL;
 	if (info->flags & XT_RATEEST_MATCH_REL) {
 		est2 = xt_rateest_lookup(info->name2);
 		if (!est2)
 			goto err2;
-	} else
-		est2 = NULL;
-
+	}
 
 	info->est1 = est1;
 	info->est2 = est2;
@@ -116,7 +115,7 @@ static int xt_rateest_mt_checkentry(const struct xt_mtchk_param *par)
 err2:
 	xt_rateest_put(est1);
 err1:
-	return -EINVAL;
+	return ret;
 }
 
 static void xt_rateest_mt_destroy(const struct xt_mtdtor_param *par)
-- 
1.7.2.3

