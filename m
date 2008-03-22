From: Jay Vosburgh <fubar@us.ibm.com>
Subject: [PATCH 3/4] bonding: Fix sysfs attribute handling
Date: Fri, 21 Mar 2008 22:29:35 -0700
Message-ID: <12061637781447-git-send-email-fubar@us.ibm.com>
References: <12061637763004-git-send-email-fubar@us.ibm.com>
 <1206163777364-git-send-email-fubar@us.ibm.com>
 <12061637773219-git-send-email-fubar@us.ibm.com>
Cc: Jeff Garzik <jgarzik@pobox.com>, Jay Vosburgh <fubar@us.ibm.com>,
	Libor Pechacek <lpechacek@suse.cz>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from e36.co.us.ibm.com ([32.97.110.154]:34506 "EHLO
	e36.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752800AbYCVF3p (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 22 Mar 2008 01:29:45 -0400
Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e36.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id m2M5TdIu017220
	for <netdev@vger.kernel.org>; Sat, 22 Mar 2008 01:29:39 -0400
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m2M5Td0C178436
	for <netdev@vger.kernel.org>; Fri, 21 Mar 2008 23:29:39 -0600
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m2M5TcBd030486
	for <netdev@vger.kernel.org>; Fri, 21 Mar 2008 23:29:39 -0600
In-Reply-To: <12061637773219-git-send-email-fubar@us.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Libor Pechacek <lpechacek@suse.cz>

For bonding interfaces any attempt to read the sysfs directory contents after
module removal results in an oops.  The fix is to release sysfs attributes
for the interfaces upon module unload.

Signed-off-by: Libor Pechacek <lpechacek@suse.cz>
Acked-by: Jay Vosburgh <fubar@us.ibm.com>

--
 drivers/net/bonding/bond_main.c |    3 +--
 1 files changed, 1 insertions(+), 2 deletions(-)
---
 drivers/net/bonding/bond_main.c |    3 +--
 1 files changed, 1 insertions(+), 2 deletions(-)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 2056a87..0f06753 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -4528,8 +4528,7 @@ static void bond_free_all(void)
 		netif_tx_unlock_bh(bond_dev);
 		/* Release the bonded slaves */
 		bond_release_all(bond_dev);
-		bond_deinit(bond_dev);
-		unregister_netdevice(bond_dev);
+		bond_destroy(bond);
 	}
 
 #ifdef CONFIG_PROC_FS
-- 
1.5.2.4

