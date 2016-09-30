From: "John W. Linville" <linville@tuxdriver.com>
Subject: [PATCH 3/7] ethtool: plug resource leaks of defs and features in do_gfeatures
Date: Fri, 30 Sep 2016 15:56:17 -0400
Message-ID: <1475265381-28937-4-git-send-email-linville@tuxdriver.com>
References: <1475265381-28937-1-git-send-email-linville@tuxdriver.com>
Cc: "John W. Linville" <linville@tuxdriver.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:38655 "EHLO
        smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751027AbcI3UAQ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 30 Sep 2016 16:00:16 -0400
In-Reply-To: <1475265381-28937-1-git-send-email-linville@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Coverity issues: 1363120, 1363121
Fixes: 6042804cf6ec ("Change -k/-K options to use ETHTOOL_{G,S}FEATURES")

Signed-off-by: John W. Linville <linville@tuxdriver.com>
---
 ethtool.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/ethtool.c b/ethtool.c
index 0885a61097ad..09486615a5bb 100644
--- a/ethtool.c
+++ b/ethtool.c
@@ -2233,10 +2233,13 @@ static int do_gfeatures(struct cmd_context *ctx)
 	features = get_features(ctx, defs);
 	if (!features) {
 		fprintf(stdout, "no feature info available\n");
+		free(defs);
 		return 1;
 	}
 
 	dump_features(defs, features, NULL);
+	free(features);
+	free(defs);
 	return 0;
 }
 
-- 
2.7.4
