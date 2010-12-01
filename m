From: Jay Vosburgh <fubar@us.ibm.com>
Subject: Re: [PATCH] bonding: check for assigned mac before adopting the slaves mac address
Date: Wed, 01 Dec 2010 11:21:08 -0800
Message-ID: <27001.1291231268@death>
References: <AANLkTinXD6p25BoN0+JuvFM9v6K-oibOAFJebP08F29N@mail.gmail.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>
To: David Strand <dpstrand@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-reply-to: <AANLkTinXD6p25BoN0+JuvFM9v6K-oibOAFJebP08F29N@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


From: David Strand <dpstrand@gmail.com>

Restore the check for an unassigned mac address before adopting the
first slaves as it's own. The change in behavior was introduced by:

commit c20811a79e671a6a1fe86a8c1afe04aca8a7f085
Author: Jiri Pirko <jpirko@redhat.com>

    bonding: move dev_addr cpy to bond_enslave


Signed-off-by: David Strand <dpstrand@gmail.com>
Signed-off-by: Jay Vosburgh <fubar@us.ibm.com>

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
