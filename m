From: Veaceslav Falico <vfalico@redhat.com>
Subject: [PATCH v3 net-next 09/12] bonding: use last_arp_rx in bond_loadbalance_arp_mon()
Date: Mon, 17 Feb 2014 14:39:18 +0100
Message-ID: <1392644361-8510-10-git-send-email-vfalico@redhat.com>
References: <1392644361-8510-1-git-send-email-vfalico@redhat.com>
Cc: Veaceslav Falico <vfalico@redhat.com>,
	Jay Vosburgh <fubar@us.ibm.com>,
	Andy Gospodarek <andy@greyhouse.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:65510 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753287AbaBQNod (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 17 Feb 2014 08:44:33 -0500
In-Reply-To: <1392644361-8510-1-git-send-email-vfalico@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Now that last_arp_rx correctly show the last time we've received an ARP, we
can use it safely instead of slave->dev->last_rx.

CC: Jay Vosburgh <fubar@us.ibm.com>
CC: Andy Gospodarek <andy@greyhouse.net>
Signed-off-by: Veaceslav Falico <vfalico@redhat.com>
---
 drivers/net/bonding/bond_main.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 3fe81cd..e7aab9a 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -2372,7 +2372,7 @@ static void bond_loadbalance_arp_mon(struct work_struct *work)
 
 		if (slave->link != BOND_LINK_UP) {
 			if (bond_time_in_interval(bond, trans_start, 1) &&
-			    bond_time_in_interval(bond, slave->dev->last_rx, 1)) {
+			    bond_time_in_interval(bond, slave->last_arp_rx, 1)) {
 
 				slave->link  = BOND_LINK_UP;
 				slave_state_changed = 1;
@@ -2401,7 +2401,7 @@ static void bond_loadbalance_arp_mon(struct work_struct *work)
 			 * if we don't know our ip yet
 			 */
 			if (!bond_time_in_interval(bond, trans_start, 2) ||
-			    !bond_time_in_interval(bond, slave->dev->last_rx, 2)) {
+			    !bond_time_in_interval(bond, slave->last_arp_rx, 2)) {
 
 				slave->link  = BOND_LINK_DOWN;
 				slave_state_changed = 1;
-- 
1.8.4
