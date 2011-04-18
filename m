From: David Miller <davem@davemloft.net>
Subject: [PATCH 10/42] bonding: Fix set-but-unused variable.
Date: Sun, 17 Apr 2011 17:33:01 -0700 (PDT)
Message-ID: <20110417.173301.48502390.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:40551
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753511Ab1DRAdg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 17 Apr 2011 20:33:36 -0400
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id EEF6624C089
	for <netdev@vger.kernel.org>; Sun, 17 Apr 2011 17:33:01 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


The variable 'vlan_dev' is set but unused in
bond_send_gratuitous_arp().  Just kill it off.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 drivers/net/bonding/bond_main.c |    2 --
 1 files changed, 0 insertions(+), 2 deletions(-)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index ca902ae..fdf9215 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -2763,7 +2763,6 @@ static void bond_send_gratuitous_arp(struct bonding *bond)
 {
 	struct slave *slave = bond->curr_active_slave;
 	struct vlan_entry *vlan;
-	struct net_device *vlan_dev;
 
 	pr_debug("bond_send_grat_arp: bond %s slave %s\n",
 		 bond->dev->name, slave ? slave->dev->name : "NULL");
@@ -2783,7 +2782,6 @@ static void bond_send_gratuitous_arp(struct bonding *bond)
 		return;
 
 	list_for_each_entry(vlan, &bond->vlan_list, vlan_list) {
-		vlan_dev = vlan_group_get_device(bond->vlgrp, vlan->vlan_id);
 		if (vlan->vlan_ip) {
 			bond_arp_send(slave->dev, ARPOP_REPLY, vlan->vlan_ip,
 				      vlan->vlan_ip, vlan->vlan_id);
-- 
1.7.4.3

