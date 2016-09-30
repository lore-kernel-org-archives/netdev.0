From: "John W. Linville" <linville@tuxdriver.com>
Subject: [PATCH 7/7] ethtool: fix leakage of strings resources in get_feature_defs
Date: Fri, 30 Sep 2016 15:56:21 -0400
Message-ID: <1475265381-28937-8-git-send-email-linville@tuxdriver.com>
References: <1475265381-28937-1-git-send-email-linville@tuxdriver.com>
Cc: "John W. Linville" <linville@tuxdriver.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:38654 "EHLO
        smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750703AbcI3UAP (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 30 Sep 2016 16:00:15 -0400
In-Reply-To: <1475265381-28937-1-git-send-email-linville@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Coverity issue: 1363125
Fixes: 6042804cf6ec ("Change -k/-K options to use ETHTOOL_{G,S}FEATURES")

Signed-off-by: John W. Linville <linville@tuxdriver.com>
---
 ethtool.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/ethtool.c b/ethtool.c
index 406cfd2f95a5..5b83a0041a95 100644
--- a/ethtool.c
+++ b/ethtool.c
@@ -1715,8 +1715,10 @@ static struct feature_defs *get_feature_defs(struct cmd_context *ctx)
 	}
 
 	defs = malloc(sizeof(*defs) + sizeof(defs->def[0]) * n_features);
-	if (!defs)
+	if (!defs) {
+		free(names);
 		return NULL;
+	}
 
 	defs->n_features = n_features;
 	memset(defs->off_flag_matched, 0, sizeof(defs->off_flag_matched));
-- 
2.7.4
