From: Wang Weidong <wangweidong1@huawei.com>
Subject: [PATCH net-next v2 2/4] sctp: remove the else path
Date: Fri, 8 Nov 2013 14:17:49 +0800
Message-ID: <1383891471-20892-3-git-send-email-wangweidong1@huawei.com>
References: <1383891471-20892-1-git-send-email-wangweidong1@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <davem@davemloft.net>, <dingtianhong@huawei.com>,
	<linux-sctp@vger.kernel.org>, <netdev@vger.kernel.org>
To: <vyasevich@gmail.com>, <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga03-in.huawei.com ([119.145.14.66]:61501 "EHLO
	szxga03-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750786Ab3KHGSh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Nov 2013 01:18:37 -0500
In-Reply-To: <1383891471-20892-1-git-send-email-wangweidong1@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Make the code more simplification.

Signed-off-by: Wang Weidong <wangweidong1@huawei.com>
---
 net/sctp/associola.c | 10 +++-------
 1 file changed, 3 insertions(+), 7 deletions(-)

diff --git a/net/sctp/associola.c b/net/sctp/associola.c
index 667f984..98acb47 100644
--- a/net/sctp/associola.c
+++ b/net/sctp/associola.c
@@ -954,17 +954,13 @@ int sctp_cmp_addr_exact(const union sctp_addr *ss1,
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
