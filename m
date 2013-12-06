From: Wang Weidong <wangweidong1@huawei.com>
Subject: [PATCH v3 net-next 2/4] sctp: remove the else path
Date: Fri, 6 Dec 2013 09:36:28 +0800
Message-ID: <1386293790-19956-3-git-send-email-wangweidong1@huawei.com>
References: <1386293790-19956-1-git-send-email-wangweidong1@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <linux-sctp@vger.kernel.org>
To: <nhorman@tuxdriver.com>, <vyasevich@gmail.com>,
	<davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga02-in.huawei.com ([119.145.14.65]:17458 "EHLO
	szxga02-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752624Ab3LFBhN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Dec 2013 20:37:13 -0500
In-Reply-To: <1386293790-19956-1-git-send-email-wangweidong1@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Make the code more simplification.

Acked-by: Neil Horman <nhorman@tuxdriver.com>
Suggested-by: Joe Perches <joe@perches.com>
Signed-off-by: Wang Weidong <wangweidong1@huawei.com>
---
 net/sctp/associola.c | 10 +++-------
 1 file changed, 3 insertions(+), 7 deletions(-)

diff --git a/net/sctp/associola.c b/net/sctp/associola.c
index 06534fa..ccc7a58 100644
--- a/net/sctp/associola.c
+++ b/net/sctp/associola.c
@@ -956,17 +956,13 @@ int sctp_cmp_addr_exact(const union sctp_addr *ss1,
  */
 struct sctp_chunk *sctp_get_ecne_prepend(struct sctp_association *asoc)
 {
-	struct sctp_chunk *chunk;
+	if (!asoc->need_ecne)
+		return NULL;
 
 	/* Send ECNE if needed.
 	 * Not being able to allocate a chunk here is not deadly.
 	 */
-	if (asoc->need_ecne)
-		chunk = sctp_make_ecne(asoc, asoc->last_ecne_tsn);
-	else
-		chunk = NULL;
-
-	return chunk;
+	return sctp_make_ecne(asoc, asoc->last_ecne_tsn);
 }
 
 /*
-- 
1.7.12
