From: Cong Wang <amwang@redhat.com>
Subject: [PATCH 03/15] netconsole: do not release spin_lock when calling __netpoll_cleanup
Date: Fri, 10 Aug 2012 19:24:39 +0800
Message-ID: <1344597891-32242-4-git-send-email-amwang@redhat.com>
References: <1344597891-32242-1-git-send-email-amwang@redhat.com>
Cc: Cong Wang <amwang@redhat.com>,
	"David S. Miller" <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:62476 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752254Ab2HJLZa (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 10 Aug 2012 07:25:30 -0400
In-Reply-To: <1344597891-32242-1-git-send-email-amwang@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

With the previous patch applied, __netpoll_cleanup() is non-block now,
so we don't need to release the spin_lock before calling it.

Cc: "David S. Miller" <davem@davemloft.net>
Signed-off-by: Cong Wang <amwang@redhat.com>
---
 drivers/net/netconsole.c |    5 -----
 1 files changed, 0 insertions(+), 5 deletions(-)

diff --git a/drivers/net/netconsole.c b/drivers/net/netconsole.c
index f9347ea..f0ad56c 100644
--- a/drivers/net/netconsole.c
+++ b/drivers/net/netconsole.c
@@ -640,12 +640,7 @@ static int netconsole_netdev_event(struct notifier_block *this,
 				 * rtnl_lock already held
 				 */
 				if (nt->np.dev) {
-					spin_unlock_irqrestore(
-							      &target_list_lock,
-							      flags);
 					__netpoll_cleanup(&nt->np);
-					spin_lock_irqsave(&target_list_lock,
-							  flags);
 					dev_put(nt->np.dev);
 					nt->np.dev = NULL;
 					netconsole_target_put(nt);
-- 
1.7.7.6
