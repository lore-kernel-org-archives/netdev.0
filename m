From: Pavel Emelyanov <xemul@openvz.org>
Subject: [PATCH 7/8][BONDING]: Remove unneeded list_empty checks.
Date: Tue, 29 Apr 2008 19:06:54 +0400
Message-ID: <4817398E.7070806@openvz.org>
References: <481735F4.30909@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: bonding-devel@lists.sourceforge.net,
	Linux Netdev List <netdev@vger.kernel.org>
To: Jay Vosburgh <fubar@us.ibm.com>, David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sacred.ru ([62.205.161.221]:58839 "EHLO sacred.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751668AbYD2PLz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 29 Apr 2008 11:11:55 -0400
In-Reply-To: <481735F4.30909@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Some places iterate over the checked list right after the check 
itself, so even if the list is empty, the list_for_each_xxx
iterator will make everything right by himself.

Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

---
 drivers/net/bonding/bond_main.c |    9 ---------
 1 files changed, 0 insertions(+), 9 deletions(-)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 8623e47..4d852ab 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -2433,9 +2433,6 @@ static int bond_has_ip(struct bonding *bond)
 	if (bond->master_ip)
 		return 1;
 
-	if (list_empty(&bond->vlan_list))
-		return 0;
-
 	list_for_each_entry(vlan, &bond->vlan_list, vlan_list) {
 		if (vlan->vlan_ip)
 			return 1;
@@ -2451,9 +2448,6 @@ static int bond_has_this_ip(struct bonding *bond, __be32 ip)
 	if (ip == bond->master_ip)
 		return 1;
 
-	if (list_empty(&bond->vlan_list))
-		return 0;
-
 	list_for_each_entry(vlan, &bond->vlan_list, vlan_list) {
 		if (ip == vlan->vlan_ip)
 			return 1;
@@ -3520,9 +3514,6 @@ static int bond_inetaddr_event(struct notifier_block *this, unsigned long event,
 			}
 		}
 
-		if (list_empty(&bond->vlan_list))
-			continue;
-
 		list_for_each_entry(vlan, &bond->vlan_list, vlan_list) {
 			vlan_dev = vlan_group_get_device(bond->vlgrp, vlan->vlan_id);
 			if (vlan_dev == event_dev) {
-- 
1.5.3.4

