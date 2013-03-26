From: Veaceslav Falico <vfalico@redhat.com>
Subject: [PATCH] bonding: cleanup unneeded rcu_read_lock()
Date: Tue, 26 Mar 2013 15:10:02 +0100
Message-ID: <1364307002-11242-1-git-send-email-vfalico@redhat.com>
Cc: vfalico@redhat.com, andy@greyhouse.net, fubar@us.ibm.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:32052 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759792Ab3CZOLL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 26 Mar 2013 10:11:11 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

bond_resend_igmp_join_requests_delayed() calls _resend_igmp_join_requests()
under rcu_read_lock(), while it gets its own rcu_read_lock() for the whole
function. Remove the lock from the _delayed function.

Signed-off-by: Veaceslav Falico <vfalico@redhat.com>
---
 drivers/net/bonding/bond_main.c |    3 +--
 1 files changed, 1 insertions(+), 2 deletions(-)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 6bbd90e..11a8cb3 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -796,9 +796,8 @@ static void bond_resend_igmp_join_requests_delayed(struct work_struct *work)
 {
 	struct bonding *bond = container_of(work, struct bonding,
 					    mcast_work.work);
-	rcu_read_lock();
+
 	bond_resend_igmp_join_requests(bond);
-	rcu_read_unlock();
 }
 
 /*
-- 
1.7.1
