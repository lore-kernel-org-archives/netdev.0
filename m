From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [PATCH net] bonding: fix enslavement slave link notifications
Date: Tue,  5 Jul 2016 12:09:47 +0300
Message-ID: <1467709787-30993-1-git-send-email-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Jay Vosburgh <j.vosburgh@gmail.com>,
	Veaceslav Falico <vfalico@gmail.com>,
	Andy Gospodarek <gospo@cumulusnetworks.com>,
	Jiri Pirko <jiri@mellanox.com>,
	Aviv Heller <avivh@mellanox.com>,
	Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [193.47.165.129] ([193.47.165.129]:53992 "EHLO mellanox.co.il"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751248AbcGEJPZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 5 Jul 2016 05:15:25 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Aviv Heller <avivh@mellanox.com>

Currently, link notifications are not sent by
bond_set_slave_link_state() upon enslavement if
the slave is enslaved when up.

This happens because slave->link default init value
is 0, which is the same as BOND_LINK_UP, resulting
in bond_set_slave_link_state() ignoring this transition.

This patch sets the default value of slave->link to
BOND_LINK_NOCHANGE, assuring it will count as a state
transition and thus trigger notification logic.

Signed-off-by: Aviv Heller <avivh@mellanox.com>
Reviewed-by: Jiri Pirko <jiri@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/net/bonding/bond_main.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 941ec99..a2afa3b 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -1584,6 +1584,7 @@ int bond_enslave(struct net_device *bond_dev, struct net_device *slave_dev)
 	}
 
 	/* check for initial state */
+	new_slave->link = BOND_LINK_NOCHANGE;
 	if (bond->params.miimon) {
 		if (bond_check_dev_link(bond, slave_dev, 0) == BMSR_LSTATUS) {
 			if (bond->params.updelay) {
-- 
2.8.0
