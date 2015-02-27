From: <erik.hugne@ericsson.com>
Subject: [PATCH net-next v2 3/5] tipc: purge links when bearer is disabled
Date: Fri, 27 Feb 2015 08:56:56 +0100
Message-ID: <1425023818-12880-4-git-send-email-erik.hugne@ericsson.com>
References: <1425023818-12880-1-git-send-email-erik.hugne@ericsson.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <tipc-discussion@lists.sourceforge.net>, <jon.maloy@ericsson.com>,
	<richard.alpe@ericsson.com>, <ying.xue@windriver.com>,
	Erik Hugne <erik.hugne@ericsson.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sessmg23.ericsson.net ([193.180.251.45]:55321 "EHLO
	sessmg23.ericsson.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753539AbbB0IBM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Feb 2015 03:01:12 -0500
In-Reply-To: <1425023818-12880-1-git-send-email-erik.hugne@ericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Erik Hugne <erik.hugne@ericsson.com>

If a bearer is disabled by manual intervention, all links over that
bearer should be purged, indicated with the 'shutting_down' flag.
Otherwise tipc will get confused if a new bearer is enabled using
a different media type.

Signed-off-by: Erik Hugne <erik.hugne@ericsson.com>
---
 net/tipc/bearer.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/tipc/bearer.c b/net/tipc/bearer.c
index 48852c2..af6deeb 100644
--- a/net/tipc/bearer.c
+++ b/net/tipc/bearer.c
@@ -742,7 +742,7 @@ int tipc_nl_bearer_disable(struct sk_buff *skb, struct genl_info *info)
 		return -EINVAL;
 	}
 
-	bearer_disable(net, bearer, false);
+	bearer_disable(net, bearer, true);
 	rtnl_unlock();
 
 	return 0;
-- 
2.1.4
