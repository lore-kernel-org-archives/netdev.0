From: "John W. Linville" <linville@tuxdriver.com>
Subject: [PATCH 5/7] ethtool: fix leakage of efeatures resources in do_sfeatures
Date: Fri, 30 Sep 2016 15:56:19 -0400
Message-ID: <1475265381-28937-6-git-send-email-linville@tuxdriver.com>
References: <1475265381-28937-1-git-send-email-linville@tuxdriver.com>
Cc: "John W. Linville" <linville@tuxdriver.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:38656 "EHLO
        smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750703AbcI3UAR (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 30 Sep 2016 16:00:17 -0400
In-Reply-To: <1475265381-28937-1-git-send-email-linville@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Coverity issue: 1363122
Fixes: 6042804cf6ecc ("Change -k/-K options to use ETHTOOL_{G,S}FEATURES")

Signed-off-by: John W. Linville <linville@tuxdriver.com>
---
 ethtool.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/ethtool.c b/ethtool.c
index 2fd3393ca5f6..840a5da157a9 100644
--- a/ethtool.c
+++ b/ethtool.c
@@ -2430,6 +2430,8 @@ static int do_sfeatures(struct cmd_context *ctx)
 
 err:
 	free(defs);
+	if (efeatures)
+		free(efeatures);
 	return rc;
 }
 
-- 
2.7.4
