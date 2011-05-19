From: David Miller <davem@davemloft.net>
Subject: [PATCH] irda: Fix error propagation in
 ircomm_lmp_connect_response()
Date: Thu, 19 May 2011 18:59:00 -0400 (EDT)
Message-ID: <20110519.185900.1606056689038504958.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:34829 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752506Ab1ESW7C (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 May 2011 18:59:02 -0400
Received: from localhost (nat-pool-rdu.redhat.com [66.187.233.202])
	(authenticated bits=0)
	by shards.monkeyblade.net (8.14.4/8.14.4) with ESMTP id p4JMx0cR030534
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Thu, 19 May 2011 15:59:01 -0700
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


The variable 'ret' is set but unused, and this pointed out that
errors from irlmp_connect_response() are not propagated to the
caller.

Note that this is currently academic since irlmp_connect_response()
always returns 0. :-)

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 net/irda/ircomm/ircomm_lmp.c |    5 +----
 1 files changed, 1 insertions(+), 4 deletions(-)

diff --git a/net/irda/ircomm/ircomm_lmp.c b/net/irda/ircomm/ircomm_lmp.c
index 08fb54d..3b8095c 100644
--- a/net/irda/ircomm/ircomm_lmp.c
+++ b/net/irda/ircomm/ircomm_lmp.c
@@ -75,7 +75,6 @@ static int ircomm_lmp_connect_response(struct ircomm_cb *self,
 				       struct sk_buff *userdata)
 {
 	struct sk_buff *tx_skb;
-	int ret;
 
 	IRDA_DEBUG(0, "%s()\n", __func__ );
 
@@ -100,9 +99,7 @@ static int ircomm_lmp_connect_response(struct ircomm_cb *self,
 		tx_skb = userdata;
 	}
 
-	ret = irlmp_connect_response(self->lsap, tx_skb);
-
-	return 0;
+	return irlmp_connect_response(self->lsap, tx_skb);
 }
 
 static int ircomm_lmp_disconnect_request(struct ircomm_cb *self,
-- 
1.7.4.4

