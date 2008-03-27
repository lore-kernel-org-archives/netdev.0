From: akpm@linux-foundation.org
Subject: [patch for 2.6.25? 1/1] bonding: fix sysfs attribute handling
Date: Thu, 27 Mar 2008 00:47:30 -0700
Message-ID: <200803270747.m2R7lUkT024210@imap1.linux-foundation.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	akpm@linux-foundation.org, lpechacek@suse.cz, fubar@us.ibm.com,
	stable@kernel.org
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:37183 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755103AbYC0HsJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Mar 2008 03:48:09 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Libor Pechacek <lpechacek@suse.cz>

For bonding interfaces any attempt to read the sysfs directory contents after
module removal results in an oops.  The fix is to release sysfs attributes for
the interfaces upon module unload.

Signed-off-by: Libor Pechacek <lpechacek@suse.cz>
Acked-by: Jay Vosburgh <fubar@us.ibm.com>
Cc: "David S. Miller" <davem@davemloft.net>
Cc: <stable@kernel.org>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 drivers/net/bonding/bond_main.c |    3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff -puN drivers/net/bonding/bond_main.c~bonding-fix-sysfs-attribute-handling drivers/net/bonding/bond_main.c
--- a/drivers/net/bonding/bond_main.c~bonding-fix-sysfs-attribute-handling
+++ a/drivers/net/bonding/bond_main.c
@@ -4528,8 +4528,7 @@ static void bond_free_all(void)
 		netif_tx_unlock_bh(bond_dev);
 		/* Release the bonded slaves */
 		bond_release_all(bond_dev);
-		bond_deinit(bond_dev);
-		unregister_netdevice(bond_dev);
+		bond_destroy(bond);
 	}
 
 #ifdef CONFIG_PROC_FS
_
