From: Veaceslav Falico <vfalico@gmail.com>
Subject: [PATCH net-next] bonding: use rtnl_deref in bond_change_rx_flags()
Date: Wed, 16 Jul 2014 09:24:27 +0200
Message-ID: <1405495467-16187-1-git-send-email-vfalico@gmail.com>
Cc: Veaceslav Falico <vfalico@gmail.com>,
	Jay Vosburgh <j.vosburgh@gmail.com>,
	Andy Gospodarek <andy@greyhouse.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:18336 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S934121AbaGPH26 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 16 Jul 2014 03:28:58 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

As it's always called with RTNL held, via dev_set_allmulti/promiscuity.

CC: Jay Vosburgh <j.vosburgh@gmail.com>
CC: Andy Gospodarek <andy@greyhouse.net>
Signed-off-by: Veaceslav Falico <vfalico@gmail.com>
---
 drivers/net/bonding/bond_main.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index d643807..2998710 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -498,7 +498,7 @@ static int bond_set_promiscuity(struct bonding *bond, int inc)
 	int err = 0;
 
 	if (bond_uses_primary(bond)) {
-		struct slave *curr_active = bond_deref_active_protected(bond);
+		struct slave *curr_active = rtnl_dereference(bond->curr_active_slave);
 
 		/* write lock already acquired */
 		if (curr_active)
@@ -524,7 +524,7 @@ static int bond_set_allmulti(struct bonding *bond, int inc)
 	int err = 0;
 
 	if (bond_uses_primary(bond)) {
-		struct slave *curr_active = bond_deref_active_protected(bond);
+		struct slave *curr_active = rtnl_dereference(bond->curr_active_slave);
 
 		/* write lock already acquired */
 		if (curr_active)
-- 
1.8.4
