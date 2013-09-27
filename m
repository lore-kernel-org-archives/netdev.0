From: Veaceslav Falico <vfalico@redhat.com>
Subject: [PATCH net-next 7/9] bonding: remove unused __get_next_agg()
Date: Fri, 27 Sep 2013 16:12:03 +0200
Message-ID: <1380291125-5671-8-git-send-email-vfalico@redhat.com>
References: <1380291125-5671-1-git-send-email-vfalico@redhat.com>
Cc: nikolay@redhat.com, bhutchings@solarflare.com,
	Veaceslav Falico <vfalico@redhat.com>,
	Jay Vosburgh <fubar@us.ibm.com>,
	Andy Gospodarek <andy@greyhouse.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:42113 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752643Ab3I0OL7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 27 Sep 2013 10:11:59 -0400
In-Reply-To: <1380291125-5671-1-git-send-email-vfalico@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

It has no users, so it's safe to remove it completely.

CC: Jay Vosburgh <fubar@us.ibm.com>
CC: Andy Gospodarek <andy@greyhouse.net>
Signed-off-by: Veaceslav Falico <vfalico@redhat.com>
---
 drivers/net/bonding/bond_3ad.c | 22 ----------------------
 1 file changed, 22 deletions(-)

diff --git a/drivers/net/bonding/bond_3ad.c b/drivers/net/bonding/bond_3ad.c
index 6dbb84d..c62606a 100644
--- a/drivers/net/bonding/bond_3ad.c
+++ b/drivers/net/bonding/bond_3ad.c
@@ -155,28 +155,6 @@ static inline struct aggregator *__get_first_agg(struct port *port)
 	return first_slave ? &(SLAVE_AD_INFO(first_slave).aggregator) : NULL;
 }
 
-/**
- * __get_next_agg - get the next aggregator in the bond
- * @aggregator: the aggregator we're looking at
- *
- * Return the aggregator of the slave that is next in line of @aggregator's
- * slave in the bond, or %NULL if it can't be found.
- */
-static inline struct aggregator *__get_next_agg(struct aggregator *aggregator)
-{
-	struct slave *slave = aggregator->slave, *slave_next;
-	struct bonding *bond = bond_get_bond_by_slave(slave);
-
-	// If there's no bond for this aggregator, or this is the last slave
-	if (bond == NULL)
-		return NULL;
-	slave_next = bond_next_slave(bond, slave);
-	if (!slave_next || bond_is_first_slave(bond, slave_next))
-		return NULL;
-
-	return &(SLAVE_AD_INFO(slave_next).aggregator);
-}
-
 /*
  * __agg_has_partner
  *
-- 
1.8.4
