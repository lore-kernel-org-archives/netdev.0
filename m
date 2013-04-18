From: Nikolay Aleksandrov <nikolay@redhat.com>
Subject: [PATCH 4/5] bonding: disable netpoll on enslave failure
Date: Thu, 18 Apr 2013 16:34:56 +0200
Message-ID: <1366295697-31037-5-git-send-email-nikolay@redhat.com>
References: <1366295697-31037-1-git-send-email-nikolay@redhat.com>
Cc: andy@greyhouse.net, fubar@us.ibm.com, davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:52856 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965906Ab3DRPBw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 18 Apr 2013 11:01:52 -0400
In-Reply-To: <1366295697-31037-1-git-send-email-nikolay@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

slave_disable_netpoll() is not called upon enslave failure which would
lead to a memory leak. Call slave_disable_netpoll() after err_detach as
that's the first error path after enabling netpoll on that slave.

Signed-off-by: Nikolay Aleksandrov <nikolay@redhat.com>
---
 drivers/net/bonding/bond_main.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index a04a018..62bfde7 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -1918,6 +1918,7 @@ err_detach:
 		write_unlock_bh(&bond->curr_slave_lock);
 		read_unlock(&bond->lock);
 	}
+	slave_disable_netpoll(new_slave);
 
 err_close:
 	slave_dev->priv_flags &= ~IFF_BONDING;
-- 
1.8.1.4
