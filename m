From: Nikolay Aleksandrov <nikolay@redhat.com>
Subject: [PATCH 2/5] bonding: vlans don't get deleted on enslave failure
Date: Thu, 18 Apr 2013 16:34:54 +0200
Message-ID: <1366295697-31037-3-git-send-email-nikolay@redhat.com>
References: <1366295697-31037-1-git-send-email-nikolay@redhat.com>
Cc: andy@greyhouse.net, fubar@us.ibm.com, davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:6018 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965340Ab3DROiF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 18 Apr 2013 10:38:05 -0400
In-Reply-To: <1366295697-31037-1-git-send-email-nikolay@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The main problem is with vid refcount which only gets bumped up.
Delete the vlans after err_detach as that's the first error path
after the vlans are added.

Signed-off-by: Nikolay Aleksandrov <nikolay@redhat.com>
---
 drivers/net/bonding/bond_main.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index dc0153b..bf5a9df 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -1904,6 +1904,7 @@ err_detach:
 		bond_mc_list_flush(bond_dev, slave_dev);
 		netif_addr_unlock_bh(bond_dev);
 	}
+	bond_del_vlans_from_slave(bond, slave_dev);
 	write_lock_bh(&bond->lock);
 	bond_detach_slave(bond, new_slave);
 	write_unlock_bh(&bond->lock);
-- 
1.8.1.4
