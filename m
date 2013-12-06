From: Wang Weidong <wangweidong1@huawei.com>
Subject: [PATCH v3 net-next 3/4] sctp: convert sctp_peer_needs_update to boolean
Date: Fri, 6 Dec 2013 09:36:29 +0800
Message-ID: <1386293790-19956-4-git-send-email-wangweidong1@huawei.com>
References: <1386293790-19956-1-git-send-email-wangweidong1@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <linux-sctp@vger.kernel.org>
To: <nhorman@tuxdriver.com>, <vyasevich@gmail.com>,
	<davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga03-in.huawei.com ([119.145.14.66]:52252 "EHLO
	szxga03-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750970Ab3LFBg5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Dec 2013 20:36:57 -0500
In-Reply-To: <1386293790-19956-1-git-send-email-wangweidong1@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

sctp_peer_needs_update only return 0 or 1.

Acked-by: Neil Horman <nhorman@tuxdriver.com>
Signed-off-by: Wang Weidong <wangweidong1@huawei.com>
---
 net/sctp/associola.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/net/sctp/associola.c b/net/sctp/associola.c
index ccc7a58..bf61fe7 100644
--- a/net/sctp/associola.c
+++ b/net/sctp/associola.c
@@ -1351,7 +1351,7 @@ void sctp_assoc_sync_pmtu(struct sock *sk, struct sctp_association *asoc)
 }
 
 /* Should we send a SACK to update our peer? */
-static inline int sctp_peer_needs_update(struct sctp_association *asoc)
+static inline bool sctp_peer_needs_update(struct sctp_association *asoc)
 {
 	struct net *net = sock_net(asoc->base.sk);
 	switch (asoc->state) {
@@ -1363,12 +1363,12 @@ static inline int sctp_peer_needs_update(struct sctp_association *asoc)
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
