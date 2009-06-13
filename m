From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 8/9] bonding: use is_zero_ether_addr
Date: Fri, 12 Jun 2009 22:02:51 -0700
Message-ID: <20090613050422.202722960@vyatta.com>
References: <20090613050243.100086546@vyatta.com>
Cc: netdev@vger.kernel.org, bonding-devel@lists.sourceforge.net
To: Jay Vosburg <fubar@us.ibm.com>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:49229 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750742AbZFMFGO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 13 Jun 2009 01:06:14 -0400
Content-Disposition: inline; filename=bond-zeroaddr.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Remove bogus non-portable possibly unaligned way of testing
for zero addres..

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>


--- a/drivers/net/bonding/bond_sysfs.c	2009-06-12 21:46:35.171609407 -0700
+++ b/drivers/net/bonding/bond_sysfs.c	2009-06-12 21:46:36.103625198 -0700
@@ -33,6 +33,7 @@
 #include <linux/ctype.h>
 #include <linux/inet.h>
 #include <linux/rtnetlink.h>
+#include <linux/etherdevice.h>
 #include <net/net_namespace.h>
 
 #include "bonding.h"
@@ -275,10 +276,9 @@ static ssize_t bonding_store_slaves(stru
 		/* If this is the first slave, then we need to set
 		   the master's hardware address to be the same as the
 		   slave's. */
-		if (!(*((u32 *) & (bond->dev->dev_addr[0])))) {
+		if (is_zero_ether_addr(bond->dev->dev_addr))
 			memcpy(bond->dev->dev_addr, dev->dev_addr,
 			       dev->addr_len);
-		}
 
 		/* Set the slave's MTU to match the bond */
 		original_mtu = dev->mtu;

-- 

