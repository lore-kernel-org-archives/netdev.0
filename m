From: David Miller <davem@davemloft.net>
Subject: [PATCH] rxrpc: Kill set but unused variable 'local' in
 rxrpc_UDP_error_handler()
Date: Thu, 19 May 2011 18:37:35 -0400 (EDT)
Message-ID: <20110519.183735.1079977464494561471.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:34548 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932344Ab1ESWhh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 May 2011 18:37:37 -0400
Received: from localhost (nat-pool-rdu.redhat.com [66.187.233.202])
	(authenticated bits=0)
	by shards.monkeyblade.net (8.14.4/8.14.4) with ESMTP id p4JMbZkS028572
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Thu, 19 May 2011 15:37:36 -0700
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: David S. Miller <davem@davemloft.net>
---
 net/rxrpc/ar-error.c |    5 +----
 1 files changed, 1 insertions(+), 4 deletions(-)

diff --git a/net/rxrpc/ar-error.c b/net/rxrpc/ar-error.c
index d4d1ae2..5d6b572 100644
--- a/net/rxrpc/ar-error.c
+++ b/net/rxrpc/ar-error.c
@@ -139,7 +139,7 @@ void rxrpc_UDP_error_handler(struct work_struct *work)
 	struct rxrpc_transport *trans =
 		container_of(work, struct rxrpc_transport, error_handler);
 	struct sk_buff *skb;
-	int local, err;
+	int err;
 
 	_enter("");
 
@@ -157,7 +157,6 @@ void rxrpc_UDP_error_handler(struct work_struct *work)
 
 	switch (ee->ee_origin) {
 	case SO_EE_ORIGIN_ICMP:
-		local = 0;
 		switch (ee->ee_type) {
 		case ICMP_DEST_UNREACH:
 			switch (ee->ee_code) {
@@ -207,7 +206,6 @@ void rxrpc_UDP_error_handler(struct work_struct *work)
 	case SO_EE_ORIGIN_LOCAL:
 		_proto("Rx Received local error { error=%d }",
 		       ee->ee_errno);
-		local = 1;
 		break;
 
 	case SO_EE_ORIGIN_NONE:
@@ -215,7 +213,6 @@ void rxrpc_UDP_error_handler(struct work_struct *work)
 	default:
 		_proto("Rx Received error report { orig=%u }",
 		       ee->ee_origin);
-		local = 0;
 		break;
 	}
 
-- 
1.7.4.4

