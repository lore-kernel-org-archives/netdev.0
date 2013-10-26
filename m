From: Wang Weidong <wangweidong1@huawei.com>
Subject: [PATCH v2 3/3] sctp: merge two if statements to one
Date: Sat, 26 Oct 2013 16:06:32 +0800
Message-ID: <1382774792-13440-4-git-send-email-wangweidong1@huawei.com>
References: <1382774792-13440-1-git-send-email-wangweidong1@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <davem@davemloft.net>, <dingtianhong@huawei.com>,
	<linux-sctp@vger.kernel.org>, <netdev@vger.kernel.org>
To: <nhorman@tuxdriver.com>, <vyasevich@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga01-in.huawei.com ([119.145.14.64]:25269 "EHLO
	szxga01-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751649Ab3JZIHJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 26 Oct 2013 04:07:09 -0400
In-Reply-To: <1382774792-13440-1-git-send-email-wangweidong1@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Two if statements do the same work, we can merge them to
one. And fix some typos. There is just code simplification,
no functional changes.

Signed-off-by: Wang Weidong <wangweidong1@huawei.com>
---
 net/sctp/auth.c | 14 +++++---------
 1 file changed, 5 insertions(+), 9 deletions(-)

diff --git a/net/sctp/auth.c b/net/sctp/auth.c
index 8c4fa5d..46b5977 100644
--- a/net/sctp/auth.c
+++ b/net/sctp/auth.c
@@ -539,18 +539,14 @@ struct sctp_hmac *sctp_auth_asoc_get_hmac(const struct sctp_association *asoc)
 	for (i = 0; i < n_elt; i++) {
 		id = ntohs(hmacs->hmac_ids[i]);
 
-		/* Check the id is in the supported range */
-		if (id > SCTP_AUTH_HMAC_ID_MAX) {
-			id = 0;
-			continue;
-		}
-
-		/* See is we support the id.  Supported IDs have name and
-		 * length fields set, so that we can allocated and use
+		/* Check the id is in the supported range. And
+		 * see if we support the id.  Supported IDs have name and
+		 * length fields set, so that we can allocate and use
 		 * them.  We can safely just check for name, for without the
 		 * name, we can't allocate the TFM.
 		 */
-		if (!sctp_hmac_list[id].hmac_name) {
+		if (id > SCTP_AUTH_HMAC_ID_MAX ||
+		    !sctp_hmac_list[id].hmac_name) {
 			id = 0;
 			continue;
 		}
-- 
1.7.12
