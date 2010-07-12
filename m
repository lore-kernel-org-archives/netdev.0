From: Shirley Ma <mashirle@us.ibm.com>
Subject: [PATCH net-next-2.6]  macvtap: Return error when macvlan drops the
 packet
Date: Mon, 12 Jul 2010 01:47:54 -0700
Message-ID: <1278924474.7719.14.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net
To: Arnd Bergmann <arnd@arndb.de>, sri@us.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from e34.co.us.ibm.com ([32.97.110.152]:36194 "EHLO
	e34.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752317Ab0GLIsA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Jul 2010 04:48:00 -0400
Received: from d03relay01.boulder.ibm.com (d03relay01.boulder.ibm.com [9.17.195.226])
	by e34.co.us.ibm.com (8.14.4/8.13.1) with ESMTP id o6C8dgrt022968
	for <netdev@vger.kernel.org>; Mon, 12 Jul 2010 02:39:42 -0600
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by d03relay01.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o6C8lvev106688
	for <netdev@vger.kernel.org>; Mon, 12 Jul 2010 02:47:57 -0600
Received: from d03av03.boulder.ibm.com (loopback [127.0.0.1])
	by d03av03.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id o6C8luVG023546
	for <netdev@vger.kernel.org>; Mon, 12 Jul 2010 02:47:57 -0600
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Return err when macvlan dropps the packet.

Signed-off-by: Shirley Ma <xma@us.ibm.com>
---
 drivers/net/macvtap.c |    8 +++++---
 1 files changed, 5 insertions(+), 3 deletions(-)

diff --git a/drivers/net/macvtap.c b/drivers/net/macvtap.c
index 2b4d59b..36d52b5 100644
--- a/drivers/net/macvtap.c
+++ b/drivers/net/macvtap.c
@@ -492,9 +492,11 @@ static ssize_t macvtap_get_user(struct
macvtap_queue *q,
 
 	rcu_read_lock_bh();
 	vlan = rcu_dereference(q->vlan);
-	if (vlan)
-		macvlan_start_xmit(skb, vlan->dev);
-	else
+	if (vlan) {
+		err = macvlan_start_xmit(skb, vlan->dev);
+		if (err)
+			count = err;
+	} else
 		kfree_skb(skb);
 	rcu_read_unlock_bh();
 


