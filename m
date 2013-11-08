From: Wang Weidong <wangweidong1@huawei.com>
Subject: [PATCH net-next 4/5] sctp: convert sctp_peer_needs_update to boolean
Date: Fri, 8 Nov 2013 10:55:09 +0800
Message-ID: <1383879310-22792-5-git-send-email-wangweidong1@huawei.com>
References: <1383879310-22792-1-git-send-email-wangweidong1@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <dingtianhong@huawei.com>, <davem@davemloft.net>,
	<linux-sctp@vger.kernel.org>, <netdev@vger.kernel.org>
To: <vyasevich@gmail.com>, <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga02-in.huawei.com ([119.145.14.65]:32094 "EHLO
	szxga02-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754473Ab3KHCzv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Nov 2013 21:55:51 -0500
In-Reply-To: <1383879310-22792-1-git-send-email-wangweidong1@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

sctp_peer_needs_update only return 0 or 1.

Signed-off-by: Wang Weidong <wangweidong1@huawei.com>
---
 net/sctp/associola.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/net/sctp/associola.c b/net/sctp/associola.c
index bca1ad1..c6cfff6 100644
--- a/net/sctp/associola.c
+++ b/net/sctp/associola.c
@@ -1355,7 +1355,7 @@ void sctp_assoc_sync_pmtu(struct sock *sk, struct sctp_association *asoc)
 }
 
 /* Should we send a SACK to update our peer? */
-static inline int sctp_peer_needs_update(struct sctp_association *asoc)
+static inline bool sctp_peer_needs_update(struct sctp_association *asoc)
 {
 	struct net *net = sock_net(asoc->base.sk);
 	switch (asoc->state) {
@@ -1367,12 +1367,12 @@ static inline int sctp_peer_needs_update(struct sctp_association *asoc)
 		    ((asoc->rwnd - asoc->a_rwnd) >= max_t(__u32,
 			   (asoc->base.sk->sk_rcvbuf >> net->sctp.rwnd_upd_shift),
 			   asoc->pathmtu)))
-			return 1;
+			return true;
 		break;
 	default:
 		break;
 	}
-	return 0;
+	return false;
 }
 
 /* Increase asoc's rwnd by len and send any window update SACK if needed. */
-- 
1.7.12
