From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: [PATCH net] net: rtnl_register in net_ns_init need rtnl_lock
Date: Thu, 22 Sep 2016 13:03:29 +0200
Message-ID: <1474542209-28409-1-git-send-email-hannes@stressinduktion.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from out2-smtp.messagingengine.com ([66.111.4.26]:60412 "EHLO
        out2-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751546AbcIVLEZ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 22 Sep 2016 07:04:25 -0400
Received: from compute6.internal (compute6.nyi.internal [10.202.2.46])
        by mailout.nyi.internal (Postfix) with ESMTP id 7B0B620673
        for <netdev@vger.kernel.org>; Thu, 22 Sep 2016 07:03:37 -0400 (EDT)
Received: from z.com (unknown [213.55.184.216])
        by mail.messagingengine.com (Postfix) with ESMTPA id D34A8F2C38
        for <netdev@vger.kernel.org>; Thu, 22 Sep 2016 07:03:36 -0400 (EDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
---
 net/core/net_namespace.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/net/core/net_namespace.c b/net/core/net_namespace.c
index 2c2eb1b629b11d..a2ace299f28355 100644
--- a/net/core/net_namespace.c
+++ b/net/core/net_namespace.c
@@ -758,9 +758,11 @@ static int __init net_ns_init(void)
 
 	register_pernet_subsys(&net_ns_ops);
 
+	rtnl_lock();
 	rtnl_register(PF_UNSPEC, RTM_NEWNSID, rtnl_net_newid, NULL, NULL);
 	rtnl_register(PF_UNSPEC, RTM_GETNSID, rtnl_net_getid, rtnl_net_dumpid,
 		      NULL);
+	rtnl_unlock();
 
 	return 0;
 }
-- 
2.7.4
