From: Jiri Pirko <jpirko@redhat.com>
Subject: [PATCH net-next-2.6] bonding: remove unused original_flags struct
 slave member
Date: Wed, 19 May 2010 13:17:41 +0200
Message-ID: <20100519111740.GB2788@psychotron.lab.eng.brq.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, fubar@us.ibm.com,
	bonding-devel@lists.sourceforge.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:25168 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755618Ab0ESLRx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 19 May 2010 07:17:53 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is stored but never restored. So remove this as it is useless.

Signed-off-by: Jiri Pirko <jpirko@redhat.com>
---
 drivers/net/bonding/bond_main.c |    5 -----
 drivers/net/bonding/bonding.h   |    1 -
 2 files changed, 0 insertions(+), 6 deletions(-)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 4e7473e..ef60244 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -1535,11 +1535,6 @@ int bond_enslave(struct net_device *bond_dev, struct net_device *slave_dev)
 		goto err_undo_flags;
 	}
 
-	/* save slave's original flags before calling
-	 * netdev_set_master and dev_open
-	 */
-	new_slave->original_flags = slave_dev->flags;
-
 	/* Save slave's original mtu and then set it to match the bond */
 	new_slave->original_mtu = slave_dev->mtu;
 	res = dev_set_mtu(slave_dev, bond->dev->mtu);
diff --git a/drivers/net/bonding/bonding.h b/drivers/net/bonding/bonding.h
index 2aa3367..da80964 100644
--- a/drivers/net/bonding/bonding.h
+++ b/drivers/net/bonding/bonding.h
@@ -159,7 +159,6 @@ struct slave {
 	s8     link;    /* one of BOND_LINK_XXXX */
 	s8     new_link;
 	s8     state;   /* one of BOND_STATE_XXXX */
-	u32    original_flags;
 	u32    original_mtu;
 	u32    link_failure_count;
 	u8     perm_hwaddr[ETH_ALEN];
-- 
1.6.6.1

