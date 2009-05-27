From: Jiri Pirko <jpirko@redhat.com>
Subject: [PATCH] bonding: use bond_is_lb() when it's appropriate
Date: Wed, 27 May 2009 17:42:36 +0200
Message-ID: <20090527154235.GA17121@psychotron.englab.brq.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, fubar@us.ibm.com,
	bonding-devel@lists.sourceforge.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:54934 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756978AbZE0Pmk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 27 May 2009 11:42:40 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[PATCH] bonding: use bond_is_lb() when it's appropriate

Signed-off-by: Jiri Pirko <jpirko@redhat.com>

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 7482402..3ec7d52 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -2399,8 +2399,7 @@ static void bond_miimon_commit(struct bonding *bond)
 				bond_3ad_handle_link_change(slave,
 							    BOND_LINK_DOWN);
 
-			if (bond->params.mode == BOND_MODE_TLB ||
-			    bond->params.mode == BOND_MODE_ALB)
+			if (bond_is_lb(bond))
 				bond_alb_handle_link_change(bond, slave,
 							    BOND_LINK_DOWN);
 
diff --git a/drivers/net/bonding/bonding.h b/drivers/net/bonding/bonding.h
index ca849d2..41ceca1 100644
--- a/drivers/net/bonding/bonding.h
+++ b/drivers/net/bonding/bonding.h
@@ -286,8 +286,7 @@ static inline unsigned long slave_last_rx(struct bonding *bond,
 static inline void bond_set_slave_inactive_flags(struct slave *slave)
 {
 	struct bonding *bond = netdev_priv(slave->dev->master);
-	if (bond->params.mode != BOND_MODE_TLB &&
-	    bond->params.mode != BOND_MODE_ALB)
+	if (!bond_is_lb(bond))
 		slave->state = BOND_STATE_BACKUP;
 	slave->dev->priv_flags |= IFF_SLAVE_INACTIVE;
 	if (slave_do_arp_validate(bond, slave))
