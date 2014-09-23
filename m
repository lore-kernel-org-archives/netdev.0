From: Daniel Borkmann <dborkman@redhat.com>
Subject: [PATCH net-next 3/3] ipv6: mld: remove duplicate code from mld_update_qri
Date: Tue, 23 Sep 2014 09:03:48 +0200
Message-ID: <1411455828-5196-4-git-send-email-dborkman@redhat.com>
References: <1411455828-5196-1-git-send-email-dborkman@redhat.com>
Cc: hannes@stressinduktion.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:32329 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753080AbaIWHD7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 23 Sep 2014 03:03:59 -0400
In-Reply-To: <1411455828-5196-1-git-send-email-dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The QRI (Query Response Interval) from RFC3810, section 9.3. is the same
as we calculate anyway earlier. Therefore, we can just remove that code
and simply reuse the value of max_delay.

Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
---
 net/ipv6/mcast.c | 17 ++++++-----------
 1 file changed, 6 insertions(+), 11 deletions(-)

diff --git a/net/ipv6/mcast.c b/net/ipv6/mcast.c
index 2a4d2b1..e4139e5 100644
--- a/net/ipv6/mcast.c
+++ b/net/ipv6/mcast.c
@@ -1226,16 +1226,6 @@ static void mld_update_qi(struct inet6_dev *idev,
 	idev->mc_qi = mc_qqi * HZ;
 }
 
-static void mld_update_qri(struct inet6_dev *idev,
-			   const struct mld2_query *mlh2)
-{
-	/* RFC3810, relevant sections:
-	 *  - 5.1.3. Maximum Response Code
-	 *  - 9.3. Query Response Interval
-	 */
-	idev->mc_qri = msecs_to_jiffies(mldv2_mrc(mlh2));
-}
-
 static int mld_process_v1(struct inet6_dev *idev, struct mld_msg *mld,
 			  unsigned long *max_delay)
 {
@@ -1272,7 +1262,12 @@ static int mld_process_v2(struct inet6_dev *idev, struct mld2_query *mld,
 
 	mld_update_qrv(idev, mld);
 	mld_update_qi(idev, mld);
-	mld_update_qri(idev, mld);
+
+	/* RFC3810, relevant sections:
+	 *  - 5.1.3. Maximum Response Code
+	 *  - 9.3. Query Response Interval
+	 */
+	idev->mc_qri = *max_delay;
 
 	return 0;
 }
-- 
1.7.11.7
