From: Jay Vosburgh <fubar@us.ibm.com>
Subject: [PATCH] bonding: Fix resource use after free
Date: Mon, 12 Nov 2007 18:15:36 -0800
Message-ID: <1194920136881-git-send-email-fubar@us.ibm.com>
Cc: davem@davemloft.net, jgarzik@pobox.com, monis@voltaire.com,
	Jay Vosburgh <fubar@us.ibm.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from e32.co.us.ibm.com ([32.97.110.150]:36265 "EHLO
	e32.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751384AbXKMCPl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Nov 2007 21:15:41 -0500
Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e32.co.us.ibm.com (8.12.11.20060308/8.13.8) with ESMTP id lAD1Euad011808
	for <netdev@vger.kernel.org>; Mon, 12 Nov 2007 20:14:56 -0500
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v8.5) with ESMTP id lAD2FeMV123868
	for <netdev@vger.kernel.org>; Mon, 12 Nov 2007 19:15:40 -0700
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id lAD2FdiD030117
	for <netdev@vger.kernel.org>; Mon, 12 Nov 2007 19:15:39 -0700
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

	Fix bond_destroy and bond_free_all to not reference the
struct net_device after calling unregister_netdevice.

	Bug and offending change reported by Moni Shoua <monis@voltaire.com>

Signed-off-by: Jay Vosburgh <fubar@us.ibm.com>

---

	Copying DaveM since Jeff is out this week; please apply for 2.6.24.

	-J

 drivers/net/bonding/bond_main.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index a198404..423298c 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -1847,9 +1847,9 @@ int bond_release(struct net_device *bond_dev, struct net_device *slave_dev)
 */
 void bond_destroy(struct bonding *bond)
 {
-	unregister_netdevice(bond->dev);
 	bond_deinit(bond->dev);
 	bond_destroy_sysfs_entry(bond);
+	unregister_netdevice(bond->dev);
 }
 
 /*
@@ -4475,8 +4475,8 @@ static void bond_free_all(void)
 		bond_mc_list_destroy(bond);
 		/* Release the bonded slaves */
 		bond_release_all(bond_dev);
-		unregister_netdevice(bond_dev);
 		bond_deinit(bond_dev);
+		unregister_netdevice(bond_dev);
 	}
 
 #ifdef CONFIG_PROC_FS
-- 
1.5.3.1

