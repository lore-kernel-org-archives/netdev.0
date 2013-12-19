From: Wang Weidong <wangweidong1@huawei.com>
Subject: [PATCH net-next v2] sctp: remove the never used 'return' and redundant
 'break'
Date: Thu, 19 Dec 2013 10:02:42 +0800
Message-ID: <52B253C2.8070407@huawei.com>
References: <52B168E0.1060108@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-sctp@vger.kernel.org>
To: David Miller <davem@davemloft.net>,
	Vlad Yasevich <vyasevich@gmail.com>,
	Neil Horman <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga02-in.huawei.com ([119.145.14.65]:30829 "EHLO
	szxga02-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751072Ab3LSCG0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Dec 2013 21:06:26 -0500
In-Reply-To: <52B168E0.1060108@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In switch() had do return, and never use the 'return NULL'. The
'break' after return or goto has no effect. Remove it.

v2: make it more readable as suggested by Neil.

Signed-off-by: Wang Weidong <wangweidong1@huawei.com>
---
 net/sctp/input.c | 13 ++-----------
 1 file changed, 2 insertions(+), 11 deletions(-)

diff --git a/net/sctp/input.c b/net/sctp/input.c
index 042ec6c..476bc8d 100644
--- a/net/sctp/input.c
+++ b/net/sctp/input.c
@@ -1119,19 +1119,10 @@ static struct sctp_association *__sctp_rcv_lookup_harder(struct net *net,
 		return NULL;
 
 	/* If this is INIT/INIT-ACK look inside the chunk too. */
-	switch (ch->type) {
-	case SCTP_CID_INIT:
-	case SCTP_CID_INIT_ACK:
+	if (ch->type == SCTP_CID_INIT || ch->type == SCTP_CID_INIT_ACK)
 		return __sctp_rcv_init_lookup(net, skb, laddr, transportp);
-		break;
 
-	default:
-		return __sctp_rcv_walk_lookup(net, skb, laddr, transportp);
-		break;
-	}
-
-
-	return NULL;
+	return __sctp_rcv_walk_lookup(net, skb, laddr, transportp);
 }
 
 /* Lookup an association for an inbound skb. */
-- 
1.7.12
