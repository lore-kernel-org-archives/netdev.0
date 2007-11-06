From: Jay Vosburgh <fubar@us.ibm.com>
Subject: [PATCH 2/2] bonding: don't validate address at device open
Date: Tue,  6 Nov 2007 13:33:29 -0800
Message-ID: <11943848132609-git-send-email-fubar@us.ibm.com>
References: <11943848091427-git-send-email-fubar@us.ibm.com>
 <11943848132752-git-send-email-fubar@us.ibm.com>
Cc: jgarzik@pobox.com, Jay Vosburgh <fubar@us.ibm.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from e33.co.us.ibm.com ([32.97.110.151]:52553 "EHLO
	e33.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754741AbXKFVdn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Nov 2007 16:33:43 -0500
Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e33.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id lA6LXa5W014912
	for <netdev@vger.kernel.org>; Tue, 6 Nov 2007 16:33:36 -0500
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v8.5) with ESMTP id lA6LXYwI094884
	for <netdev@vger.kernel.org>; Tue, 6 Nov 2007 14:33:35 -0700
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id lA6LXYBT004279
	for <netdev@vger.kernel.org>; Tue, 6 Nov 2007 14:33:34 -0700
In-Reply-To: <11943848132752-git-send-email-fubar@us.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The standard validate_addr handler refuses to accept the all zeroes address
as valid.  However, it's common historical practice for the bonding
master to be configured up prior to having any slaves, at which time the
master will have a MAC address of all zeroes.

Resolved by setting the dev->validate_addr to NULL.  The master still can't
end up with an invalid address, as the set_mac_address function tests
for validity.

Signed-off-by: Jay Vosburgh <fubar@us.ibm.com>

---
 drivers/net/bonding/bond_main.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 6937ef0..a198404 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -4405,6 +4405,7 @@ static int bond_init(struct net_device *bond_dev, struct bond_params *params)
 	bond_dev->set_multicast_list = bond_set_multicast_list;
 	bond_dev->change_mtu = bond_change_mtu;
 	bond_dev->set_mac_address = bond_set_mac_address;
+	bond_dev->validate_addr = NULL;
 
 	bond_set_mode_ops(bond, bond->params.mode);
 
-- 
1.5.3.4.206.g58ba4-dirty

