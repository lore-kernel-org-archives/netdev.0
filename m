From: Jay Vosburgh <fubar@us.ibm.com>
Subject: [PATCH 2/4] bonding: fix two compiler warnings
Date: Fri, 21 Mar 2008 22:29:34 -0700
Message-ID: <12061637773219-git-send-email-fubar@us.ibm.com>
References: <12061637763004-git-send-email-fubar@us.ibm.com>
 <1206163777364-git-send-email-fubar@us.ibm.com>
Cc: Jeff Garzik <jgarzik@pobox.com>, Jay Vosburgh <fubar@us.ibm.com>,
	Stephen Hemminger <shemminger@vyatta.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from e32.co.us.ibm.com ([32.97.110.150]:42513 "EHLO
	e32.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752948AbYCVF3t (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 22 Mar 2008 01:29:49 -0400
Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e32.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id m2M5SHPc009255
	for <netdev@vger.kernel.org>; Sat, 22 Mar 2008 01:28:17 -0400
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m2M5TcQw186966
	for <netdev@vger.kernel.org>; Fri, 21 Mar 2008 23:29:38 -0600
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m2M5TchD030468
	for <netdev@vger.kernel.org>; Fri, 21 Mar 2008 23:29:38 -0600
In-Reply-To: <1206163777364-git-send-email-fubar@us.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

	Fix two compiler warnings that are new with recent versions of gcc
(apparently 4.2 and up).  One is fixed by refactoring; this change was
supplied by Stephen Hemminger.  The other was fixed by labelling the
variable as uninitialized_var() after confirming via inspection that it
cannot actually be used uninitialized.

Signed-off-by: Jay Vosburgh <fubar@us.ibm.com>
Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

---
 drivers/net/bonding/bond_alb.c  |    6 +-----
 drivers/net/bonding/bond_main.c |    2 +-
 2 files changed, 2 insertions(+), 6 deletions(-)

diff --git a/drivers/net/bonding/bond_alb.c b/drivers/net/bonding/bond_alb.c
index b57bc94..3f58c3d 100644
--- a/drivers/net/bonding/bond_alb.c
+++ b/drivers/net/bonding/bond_alb.c
@@ -678,12 +678,8 @@ static struct slave *rlb_choose_channel(struct sk_buff *skb, struct bonding *bon
 		}
 
 		if (!list_empty(&bond->vlan_list)) {
-			unsigned short vlan_id;
-			int res = vlan_get_tag(skb, &vlan_id);
-			if (!res) {
+			if (!vlan_get_tag(skb, &client_info->vlan_id))
 				client_info->tag = 1;
-				client_info->vlan_id = vlan_id;
-			}
 		}
 
 		if (!client_info->assigned) {
diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 0942d82..2056a87 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -383,7 +383,7 @@ struct vlan_entry *bond_next_vlan(struct bonding *bond, struct vlan_entry *curr)
  */
 int bond_dev_queue_xmit(struct bonding *bond, struct sk_buff *skb, struct net_device *slave_dev)
 {
-	unsigned short vlan_id;
+	unsigned short uninitialized_var(vlan_id);
 
 	if (!list_empty(&bond->vlan_list) &&
 	    !(slave_dev->features & NETIF_F_HW_VLAN_TX) &&
-- 
1.5.2.4

