From: Veaceslav Falico <vfalico@redhat.com>
Subject: [PATCH net-next 2/9] bonding: remove __get_first_port()
Date: Fri, 27 Sep 2013 16:11:58 +0200
Message-ID: <1380291125-5671-3-git-send-email-vfalico@redhat.com>
References: <1380291125-5671-1-git-send-email-vfalico@redhat.com>
Cc: nikolay@redhat.com, bhutchings@solarflare.com,
	Veaceslav Falico <vfalico@redhat.com>,
	Jay Vosburgh <fubar@us.ibm.com>,
	Andy Gospodarek <andy@greyhouse.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:8827 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752155Ab3I0OLt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 27 Sep 2013 10:11:49 -0400
In-Reply-To: <1380291125-5671-1-git-send-email-vfalico@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently we have only one user of it, so it's kind of useless and just
obfusicates things.

Remove it and move the logic to the only user -
bond_3ad_state_machine_handler().

CC: Jay Vosburgh <fubar@us.ibm.com>
CC: Andy Gospodarek <andy@greyhouse.net>
Signed-off-by: Veaceslav Falico <vfalico@redhat.com>
---
 drivers/net/bonding/bond_3ad.c | 18 ++++--------------
 1 file changed, 4 insertions(+), 14 deletions(-)

diff --git a/drivers/net/bonding/bond_3ad.c b/drivers/net/bonding/bond_3ad.c
index c1535f8..0f86d2b 100644
--- a/drivers/net/bonding/bond_3ad.c
+++ b/drivers/net/bonding/bond_3ad.c
@@ -136,19 +136,6 @@ static inline struct bonding *__get_bond_by_port(struct port *port)
 }
 
 /**
- * __get_first_port - get the first port in the bond
- * @bond: the bond we're looking at
- *
- * Return the port of the first slave in @bond, or %NULL if it can't be found.
- */
-static inline struct port *__get_first_port(struct bonding *bond)
-{
-	struct slave *first_slave = bond_first_slave(bond);
-
-	return first_slave ? &(SLAVE_AD_INFO(first_slave).port) : NULL;
-}
-
-/**
  * __get_first_agg - get the first aggregator in the bond
  * @bond: the bond we're looking at
  *
@@ -2104,8 +2091,11 @@ void bond_3ad_state_machine_handler(struct work_struct *work)
 
 	// check if agg_select_timer timer after initialize is timed out
 	if (BOND_AD_INFO(bond).agg_select_timer && !(--BOND_AD_INFO(bond).agg_select_timer)) {
+		slave = bond_first_slave(bond);
+		port = slave ? &(SLAVE_AD_INFO(slave).port) : NULL;
+
 		// select the active aggregator for the bond
-		if ((port = __get_first_port(bond))) {
+		if (port) {
 			if (!port->slave) {
 				pr_warning("%s: Warning: bond's first port is uninitialized\n",
 					   bond->dev->name);
-- 
1.8.4
