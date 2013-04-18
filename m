From: Nikolay Aleksandrov <nikolay@redhat.com>
Subject: [PATCHv2 4/5] bonding: disable netpoll on enslave failure
Date: Thu, 18 Apr 2013 19:33:37 +0200
Message-ID: <1366306418-3661-5-git-send-email-nikolay@redhat.com>
References: <1366306418-3661-1-git-send-email-nikolay@redhat.com>
Cc: andy@greyhouse.net, fubar@us.ibm.com, davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:20369 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S967377Ab3DRRgg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 18 Apr 2013 13:36:36 -0400
In-Reply-To: <1366306418-3661-1-git-send-email-nikolay@redhat.com>
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
index c56e132..1f3b1cc 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -1920,6 +1920,7 @@ err_detach:
 		write_unlock_bh(&bond->curr_slave_lock);
 		read_unlock(&bond->lock);
 	}
+	slave_disable_netpoll(new_slave);
 
 err_close:
 	slave_dev->priv_flags &= ~IFF_BONDING;
-- 
1.8.1.4
