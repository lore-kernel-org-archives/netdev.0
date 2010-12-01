From: David Strand <dpstrand@gmail.com>
Subject: [PATCH] bonding: check for assigned mac before adopting the slaves
 mac address
Date: Wed, 1 Dec 2010 11:15:10 -0800
Message-ID: <AANLkTinXD6p25BoN0+JuvFM9v6K-oibOAFJebP08F29N@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Jay Vosburgh <fubar@us.ibm.com>, linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ey0-f174.google.com ([209.85.215.174]:51787 "EHLO
	mail-ey0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753899Ab0LATPL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Dec 2010 14:15:11 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Restore the check for an unassigned mac address before adopting the
first slaves as it's own. The change in behavior was introduced with
the following patch:
http://git.kernel.org/?p=linux/kernel/git/stable/linux-2.6.36.y.git;a=commit;h=c20811a79e671a6a1fe86a8c1afe04aca8a7f085

Signed-off-by: David Strand <dpstrand@gmail.com>
---
diff -uprN a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
--- a/drivers/net/bonding/bond_main.c	2010-11-24 11:36:58.125640000 -0800
+++ b/drivers/net/bonding/bond_main.c	2010-12-01 10:12:33.728640001 -0800
@@ -1576,7 +1576,7 @@ int bond_enslave(struct net_device *bond

 	/* If this is the first slave, then we need to set the master's hardware
 	 * address to be the same as the slave's. */
-	if (bond->slave_cnt == 0)
+	if (is_zero_ether_addr(bond->dev->dev_addr))
 		memcpy(bond->dev->dev_addr, slave_dev->dev_addr,
 		       slave_dev->addr_len);
