From: Parthasarathy Bhuvaragan <parthasarathy.bhuvaragan@ericsson.com>
Subject: [PATCH net v1 1/1] tipc: use only positive error codes in messages
Date: Fri, 29 Sep 2017 10:02:54 +0200
Message-ID: <1506672174-26962-1-git-send-email-parthasarathy.bhuvaragan@ericsson.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <tipc-discussion@lists.sourceforge.net>,
        <jon.maloy@ericsson.com>, <maloy@donjonn.com>,
        <ying.xue@windriver.com>, <parthasarathy.bhuvaragan@gmail.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sesbmg23.ericsson.net ([193.180.251.37]:56852 "EHLO
        sesbmg23.ericsson.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751236AbdI2IC7 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 29 Sep 2017 04:02:59 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In commit e3a77561e7d32 ("tipc: split up function tipc_msg_eval()"),
we have updated the function tipc_msg_lookup_dest() to set the error
codes to negative values at destination lookup failures. Thus when
the function sets the error code to -TIPC_ERR_NO_NAME, its inserted
into the 4 bit error field of the message header as 0xf instead of
TIPC_ERR_NO_NAME (1). The value 0xf is an unknown error code.

In this commit, we set only positive error code.

Fixes: e3a77561e7d32 ("tipc: split up function tipc_msg_eval()")
Signed-off-by: Parthasarathy Bhuvaragan <parthasarathy.bhuvaragan@ericsson.com>
---
 net/tipc/msg.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/tipc/msg.c b/net/tipc/msg.c
index 6ef379f004ac..121e59a1d0e7 100644
--- a/net/tipc/msg.c
+++ b/net/tipc/msg.c
@@ -551,7 +551,7 @@ bool tipc_msg_lookup_dest(struct net *net, struct sk_buff *skb, int *err)
 		return false;
 	if (msg_errcode(msg))
 		return false;
-	*err = -TIPC_ERR_NO_NAME;
+	*err = TIPC_ERR_NO_NAME;
 	if (skb_linearize(skb))
 		return false;
 	msg = buf_msg(skb);
-- 
2.1.4
