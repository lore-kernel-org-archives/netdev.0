From: Veaceslav Falico <vfalico@redhat.com>
Subject: [PATCH net-next v3 09/13] bonding: use vlan_uses_dev() in __bond_release_one()
Date: Wed, 28 Aug 2013 18:03:58 +0200
Message-ID: <1377705842-8276-10-git-send-email-vfalico@redhat.com>
References: <1377705842-8276-1-git-send-email-vfalico@redhat.com>
Cc: Veaceslav Falico <vfalico@redhat.com>,
	Jay Vosburgh <fubar@us.ibm.com>,
	Andy Gospodarek <andy@greyhouse.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:47204 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754324Ab3H1QFr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 28 Aug 2013 12:05:47 -0400
In-Reply-To: <1377705842-8276-1-git-send-email-vfalico@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We always hold the rtnl_lock() in __bond_release_one(), so use
vlan_uses_dev() instead of bond_vlan_used().

v1: no change
v2: no change
v3: no change

CC: Jay Vosburgh <fubar@us.ibm.com>
CC: Andy Gospodarek <andy@greyhouse.net>
Signed-off-by: Veaceslav Falico <vfalico@redhat.com>
---
 drivers/net/bonding/bond_main.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 0fb3122..d61f80a 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -1954,7 +1954,7 @@ static int __bond_release_one(struct net_device *bond_dev,
 		bond_set_carrier(bond);
 		eth_hw_addr_random(bond_dev);
 
-		if (bond_vlan_used(bond)) {
+		if (vlan_uses_dev(bond_dev)) {
 			pr_warning("%s: Warning: clearing HW address of %s while it still has VLANs.\n",
 				   bond_dev->name, bond_dev->name);
 			pr_warning("%s: When re-adding slaves, make sure the bond's HW address matches its VLANs'.\n",
-- 
1.7.1
