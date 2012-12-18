From: Vlad Yasevich <vyasevic@redhat.com>
Subject: [PATCH] bridge:  Do not unregister PF_BRIDGE rtnl operations
Date: Tue, 18 Dec 2012 16:43:44 -0500
Message-ID: <1355867024-12165-1-git-send-email-vyasevic@redhat.com>
Cc: davem@davemloft.net, shemminger@vyatta.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:32080 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752337Ab2LRVnr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 18 Dec 2012 16:43:47 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Now that bridge rtnl ops are in core, do not undergister
all PF_BRIDGE ops when bridge module is unloaded.  It makes
it so that after reload, none of the messages work.

Signed-off-by: Vlad Yasevich <vyasevic@redhat.com>
---
 net/bridge/br_netlink.c |    1 -
 1 files changed, 0 insertions(+), 1 deletions(-)

diff --git a/net/bridge/br_netlink.c b/net/bridge/br_netlink.c
index dead9df..97ba018 100644
--- a/net/bridge/br_netlink.c
+++ b/net/bridge/br_netlink.c
@@ -305,5 +305,4 @@ int __init br_netlink_init(void)
 void __exit br_netlink_fini(void)
 {
 	rtnl_link_unregister(&br_link_ops);
-	rtnl_unregister_all(PF_BRIDGE);
 }
-- 
1.7.7.6
