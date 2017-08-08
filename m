From: Florian Westphal <fw@strlen.de>
Subject: [PATCH net-next 7/7] net: call newid/getid without rtnl mutex held
Date: Tue,  8 Aug 2017 18:02:36 +0200
Message-ID: <20170808160236.28562-8-fw@strlen.de>
References: <20170808160236.28562-1-fw@strlen.de>
Cc: Florian Westphal <fw@strlen.de>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([146.0.238.67]:35546 "EHLO
        Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1752253AbdHHQCm (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 8 Aug 2017 12:02:42 -0400
In-Reply-To: <20170808160236.28562-1-fw@strlen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Both functions take nsid_lock and don't reply on rtnl lock.

Signed-off-by: Florian Westphal <fw@strlen.de>
Reviewed-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
---
 net/core/net_namespace.c | 5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/net/core/net_namespace.c b/net/core/net_namespace.c
index a7f06d706aa0..6cfdc7c84c48 100644
--- a/net/core/net_namespace.c
+++ b/net/core/net_namespace.c
@@ -855,9 +855,10 @@ static int __init net_ns_init(void)
 
 	register_pernet_subsys(&net_ns_ops);
 
-	rtnl_register(PF_UNSPEC, RTM_NEWNSID, rtnl_net_newid, NULL, 0);
+	rtnl_register(PF_UNSPEC, RTM_NEWNSID, rtnl_net_newid, NULL,
+		      RTNL_FLAG_DOIT_UNLOCKED);
 	rtnl_register(PF_UNSPEC, RTM_GETNSID, rtnl_net_getid, rtnl_net_dumpid,
-		      0);
+		      RTNL_FLAG_DOIT_UNLOCKED);
 
 	return 0;
 }
-- 
2.13.0
