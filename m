From: Nikolay Aleksandrov <nikolay@redhat.com>
Subject: [PATCH net-next] bonding: remove bond_resend_igmp_join_requests read_unlock leftover
Date: Sat, 27 Jul 2013 19:10:10 +0200
Message-ID: <1374945010-14667-1-git-send-email-nikolay@redhat.com>
Cc: andy@greyhouse.net, fubar@us.ibm.com, davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:10985 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752429Ab3G0RNr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 27 Jul 2013 13:13:47 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

After commit 4aa5dee4d9 ("net: convert resend IGMP to notifier event") we
have 1 read_unlock in bond_resend_igmp_join_requests which isn't paired
with a read_lock because it's removed by that commit.

Signed-off-by: Nikolay Aleksandrov <nikolay@redhat.com>
---
 drivers/net/bonding/bond_main.c | 1 -
 1 file changed, 1 deletion(-)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index f584352..da3af63 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -739,7 +739,6 @@ static void bond_resend_igmp_join_requests(struct bonding *bond)
 		queue_delayed_work(bond->wq, &bond->mcast_work, HZ/5);
 	}
 	write_unlock_bh(&bond->curr_slave_lock);
-	read_unlock(&bond->lock);
 }
 
 static void bond_resend_igmp_join_requests_delayed(struct work_struct *work)
-- 
1.8.1.4
