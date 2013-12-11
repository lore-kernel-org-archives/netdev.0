From: Wang Weidong <wangweidong1@huawei.com>
Subject: [PATCH net-next] sctp: remove redundant null check on asoc
Date: Wed, 11 Dec 2013 16:42:14 +0800
Message-ID: <52A82566.1050601@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-sctp@vger.kernel.org>
To: Vlad Yasevich <vyasevich@gmail.com>,
	Neil Horman <nhorman@tuxdriver.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga03-in.huawei.com ([119.145.14.66]:53161 "EHLO
	szxga03-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750791Ab3LKImx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Dec 2013 03:42:53 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In sctp_err_lookup, goto out while the asoc is not NULL, so remove the
check NULL. Also, in sctp_err_finish which called by sctp_v4_err and
sctp_v6_err, they pass asoc to sctp_err_finish while the asoc is not
NULL, so remove the check.

Signed-off-by: Wang Weidong <wangweidong1@huawei.com>
---
 net/sctp/input.c | 6 ++----
 1 file changed, 2 insertions(+), 4 deletions(-)

diff --git a/net/sctp/input.c b/net/sctp/input.c
index 6603853..2a192a7 100644
--- a/net/sctp/input.c
+++ b/net/sctp/input.c
@@ -536,8 +536,7 @@ struct sock *sctp_err_lookup(struct net *net, int family, struct sk_buff *skb,
 	return sk;
 
 out:
-	if (asoc)
-		sctp_association_put(asoc);
+	sctp_association_put(asoc);
 	return NULL;
 }
 
@@ -545,8 +544,7 @@ out:
 void sctp_err_finish(struct sock *sk, struct sctp_association *asoc)
 {
 	sctp_bh_unlock_sock(sk);
-	if (asoc)
-		sctp_association_put(asoc);
+	sctp_association_put(asoc);
 }
 
 /*
-- 
1.7.12
