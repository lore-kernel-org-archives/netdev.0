From: Jay Vosburgh <fubar@us.ibm.com>
Subject: [PATCH 5/8] bonding: Remove unneeded list_empty checks.
Date: Sat, 17 May 2008 21:10:11 -0700
Message-ID: <1211083817934-git-send-email-fubar@us.ibm.com>
References: <12110838143907-git-send-email-fubar@us.ibm.com>
 <12110838151824-git-send-email-fubar@us.ibm.com>
 <12110838151104-git-send-email-fubar@us.ibm.com>
 <12110838162313-git-send-email-fubar@us.ibm.com>
 <1211083816660-git-send-email-fubar@us.ibm.com>
Cc: Jeff Garzik <jgarzik@pobox.com>, Pavel Emelyanov <xemul@openvz.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from e35.co.us.ibm.com ([32.97.110.153]:46288 "EHLO
	e35.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751447AbYEREKa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 18 May 2008 00:10:30 -0400
Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e35.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id m4I4ANpK024544
	for <netdev@vger.kernel.org>; Sun, 18 May 2008 00:10:23 -0400
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m4I4AI5I102782
	for <netdev@vger.kernel.org>; Sat, 17 May 2008 22:10:23 -0600
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m4I4AItf004619
	for <netdev@vger.kernel.org>; Sat, 17 May 2008 22:10:18 -0600
In-Reply-To: <1211083816660-git-send-email-fubar@us.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pavel Emelyanov <xemul@openvz.org>

Some places iterate over the checked list right after the check
itself, so even if the list is empty, the list_for_each_xxx
iterator will make everything right by himself.

Signed-off-by: Pavel Emelyanov <xemul@openvz.org>
Acked-by: Jay Vosburgh <fubar@us.ibm.com>
---
 drivers/net/bonding/bond_main.c |    6 ------
 1 files changed, 0 insertions(+), 6 deletions(-)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 5e3b942..2a0039f 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -2433,9 +2433,6 @@ static int bond_has_this_ip(struct bonding *bond, __be32 ip)
 	if (ip == bond->master_ip)
 		return 1;
 
-	if (list_empty(&bond->vlan_list))
-		return 0;
-
 	list_for_each_entry(vlan, &bond->vlan_list, vlan_list) {
 		if (ip == vlan->vlan_ip)
 			return 1;
@@ -3495,9 +3492,6 @@ static int bond_inetaddr_event(struct notifier_block *this, unsigned long event,
 			}
 		}
 
-		if (list_empty(&bond->vlan_list))
-			continue;
-
 		list_for_each_entry(vlan, &bond->vlan_list, vlan_list) {
 			vlan_dev = vlan_group_get_device(bond->vlgrp, vlan->vlan_id);
 			if (vlan_dev == event_dev) {
-- 
1.5.2.4

