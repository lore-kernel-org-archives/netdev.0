From: Veaceslav Falico <vfalico@redhat.com>
Subject: [PATCH net-next 5/6] bonding: use last_arp_rx in bond_loadbalance_arp_mon()
Date: Thu, 16 Jan 2014 03:05:15 +0100
Message-ID: <1389837916-5377-6-git-send-email-vfalico@redhat.com>
References: <1389837916-5377-1-git-send-email-vfalico@redhat.com>
Cc: Veaceslav Falico <vfalico@redhat.com>,
	Jay Vosburgh <fubar@us.ibm.com>,
	Andy Gospodarek <andy@greyhouse.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:14919 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752583AbaAPCJk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 15 Jan 2014 21:09:40 -0500
In-Reply-To: <1389837916-5377-1-git-send-email-vfalico@redhat.com>
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
index 399e691..f5ac7e0 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -2406,7 +2406,7 @@ static void bond_loadbalance_arp_mon(struct work_struct *work)
 
 		if (slave->link != BOND_LINK_UP) {
 			if (bond_time_in_interval(bond, trans_start, 1) &&
-			    bond_time_in_interval(bond, slave->dev->last_rx, 1)) {
+			    bond_time_in_interval(bond, slave->last_arp_rx, 1)) {
 
 				slave->link  = BOND_LINK_UP;
 				bond_set_active_slave(slave);
@@ -2435,7 +2435,7 @@ static void bond_loadbalance_arp_mon(struct work_struct *work)
 			 * if we don't know our ip yet
 			 */
 			if (!bond_time_in_interval(bond, trans_start, 2) ||
-			    !bond_time_in_interval(bond, slave->dev->last_rx, 2)) {
+			    !bond_time_in_interval(bond, slave->last_arp_rx, 2)) {
 
 				slave->link  = BOND_LINK_DOWN;
 				bond_set_backup_slave(slave);
-- 
1.8.4
