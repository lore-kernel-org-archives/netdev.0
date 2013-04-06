From: Nikolay Aleksandrov <nikolay@redhat.com>
Subject: [PATCH 1/2] Revert "bonding: remove sysfs before removing devices"
Date: Sat,  6 Apr 2013 12:54:37 +0200
Message-ID: <1365245678-4455-1-git-send-email-nikolay@redhat.com>
Cc: andy@greyhouse.net, fubar@us.ibm.com, davem@davemloft.net,
	vfalico@redhat.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:42182 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1163051Ab3DFK5a (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 6 Apr 2013 06:57:30 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This reverts commit 4de79c737b200492195ebc54a887075327e1ec1d.

This patch introduces a new bug which causes access to freed memory.
In bond_uninit: list_del(&bond->bond_list);
bond_list is linked in bond_net's dev_list which is freed by
unregister_pernet_subsys.

Signed-off-by: Nikolay Aleksandrov <nikolay@redhat.com>
---
 drivers/net/bonding/bond_main.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 171b10f..a51241b 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -4902,8 +4902,8 @@ static void __exit bonding_exit(void)
 
 	bond_destroy_debugfs();
 
-	unregister_pernet_subsys(&bond_net_ops);
 	rtnl_link_unregister(&bond_link_ops);
+	unregister_pernet_subsys(&bond_net_ops);
 
 #ifdef CONFIG_NET_POLL_CONTROLLER
 	/*
-- 
1.8.1.4
