From: Pavel Emelyanov <xemul@openvz.org>
Subject: [PATCH 5/8][BONDING]: Lost semaphores unlock in one of bonding_store_bonds
 error paths.
Date: Tue, 29 Apr 2008 19:02:52 +0400
Message-ID: <4817389C.2090400@openvz.org>
References: <481735F4.30909@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: bonding-devel@lists.sourceforge.net,
	Linux Netdev List <netdev@vger.kernel.org>
To: Jay Vosburgh <fubar@us.ibm.com>, David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sacred.ru ([62.205.161.221]:58807 "EHLO sacred.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754561AbYD2PH4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 29 Apr 2008 11:07:56 -0400
In-Reply-To: <481735F4.30909@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The out: label just makes return. Wipe things up.

Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

---
 drivers/net/bonding/bond_sysfs.c |   10 +++++-----
 1 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/drivers/net/bonding/bond_sysfs.c b/drivers/net/bonding/bond_sysfs.c
index 88de27f..752e43b 100644
--- a/drivers/net/bonding/bond_sysfs.c
+++ b/drivers/net/bonding/bond_sysfs.c
@@ -146,12 +146,12 @@ static ssize_t bonding_store_bonds(struct class *cls, const char *buffer, size_t
 						": Unable remove bond %s due to open references.\n",
 						ifname);
 					res = -EPERM;
-					goto out;
+				} else {
+					printk(KERN_INFO DRV_NAME
+						": %s is being deleted...\n",
+						bond->dev->name);
+					bond_destroy(bond);
 				}
-				printk(KERN_INFO DRV_NAME
-					": %s is being deleted...\n",
-					bond->dev->name);
-				bond_destroy(bond);
 				up_write(&bonding_rwsem);
 				rtnl_unlock();
 				goto out;
-- 
1.5.3.4

