From: David Strand <dpstrand@gmail.com>
Subject: [PATCH] bonding: check for assigned mac before adopting the slaves
 mac address
Date: Wed, 24 Nov 2010 15:12:14 -0800
Message-ID: <AANLkTinpO=FmoecfV8epubXU4OrhFsXJ7-Kc68yNhMEs@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Jay Vosburgh <fubar@us.ibm.com>, linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f46.google.com ([209.85.215.46]:56670 "EHLO
	mail-ew0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754905Ab0KXXMP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Nov 2010 18:12:15 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Restore the check for a missing mac address before adopting the first
slaves as it's own. This regression was introduced in:
http://git.kernel.org/?p=linux/kernel/git/stable/linux-2.6.36.y.git;a=commit;h=c20811a79e671a6a1fe86a8c1afe04aca8a7f085

Signed-off-by: David Strand dpstrand@gmail.com
---
diff -uprN a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
--- a/drivers/net/bonding/bond_main.c	2010-11-24 11:36:58.125640000 -0800
+++ b/drivers/net/bonding/bond_main.c	2010-11-24 11:40:58.175640000 -0800
@@ -1577,8 +1577,9 @@ int bond_enslave(struct net_device *bond
 	/* If this is the first slave, then we need to set the master's hardware
 	 * address to be the same as the slave's. */
 	if (bond->slave_cnt == 0)
-		memcpy(bond->dev->dev_addr, slave_dev->dev_addr,
-		       slave_dev->addr_len);
+		if (is_zero_ether_addr(bond->dev->dev_addr))
+			memcpy(bond->dev->dev_addr, slave_dev->dev_addr,
+			       slave_dev->addr_len);


 	new_slave = kzalloc(sizeof(struct slave), GFP_KERNEL);
