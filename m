From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: [PATCH net-next] tipc: checking for NULL instead of IS_ERR()
Date: Wed, 18 Oct 2017 10:48:25 +0300
Message-ID: <20171018074825.2bi42vewrqhdbte3@mwanda>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ying Xue <ying.xue@windriver.com>,
        "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
        tipc-discussion@lists.sourceforge.net,
        kernel-janitors@vger.kernel.org
To: Jon Maloy <jon.maloy@ericsson.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:42168 "EHLO
        userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932533AbdJRHst (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 18 Oct 2017 03:48:49 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The tipc_alloc_conn() function never returns NULL, it returns error
pointers, so I have fixed the check.

Fixes: 14c04493cb77 ("tipc: add ability to order and receive topology events in driver")
Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

diff --git a/net/tipc/server.c b/net/tipc/server.c
index 713077536d0c..acaef80fb88c 100644
--- a/net/tipc/server.c
+++ b/net/tipc/server.c
@@ -504,7 +504,7 @@ bool tipc_topsrv_kern_subscr(struct net *net, u32 port, u32 type,
 	*(u32 *)&sub.usr_handle = port;
 
 	con = tipc_alloc_conn(tipc_topsrv(net));
-	if (!con)
+	if (IS_ERR(con))
 		return false;
 
 	*conid = con->conid;
