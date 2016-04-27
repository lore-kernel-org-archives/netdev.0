From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: [patch] tipc: remove an unnecessary NULL check
Date: Wed, 27 Apr 2016 11:05:28 +0300
Message-ID: <20160427080528.GA22469@mwanda>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ying Xue <ying.xue@windriver.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	tipc-discussion@lists.sourceforge.net,
	kernel-janitors@vger.kernel.org
To: Jon Maloy <jon.maloy@ericsson.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:44487 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753376AbcD0IGc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Apr 2016 04:06:32 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is never called with a NULL "buf" and anyway, we dereference 's' on
the lines before so it would Oops before we reach the check.

Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

diff --git a/net/tipc/subscr.c b/net/tipc/subscr.c
index 79de588..0dd0224 100644
--- a/net/tipc/subscr.c
+++ b/net/tipc/subscr.c
@@ -326,8 +326,7 @@ static void tipc_subscrb_rcv_cb(struct net *net, int conid,
 		return tipc_subscrp_cancel(s, subscriber);
 	}
 
-	if (s)
-		tipc_subscrp_subscribe(net, s, subscriber, swap);
+	tipc_subscrp_subscribe(net, s, subscriber, swap);
 }
 
 /* Handle one request to establish a new subscriber */
