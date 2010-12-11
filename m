From: Hillf Danton <dhillf@gmail.com>
Subject: [PATCH] fix bug in Ethernet Channel Bonding Driver
Date: Sat, 11 Dec 2010 12:54:11 +0800
Message-ID: <AANLkTiksuf0ZDWyjH6ec9rSRoG+5ZdakA-Tha9MXLvy+@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:44732 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751738Ab0LKEyM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Dec 2010 23:54:12 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The returned slave is incorrect, if the net device under check is not
charged yet by the master.

Signed-off-by: Hillf Danton <dhillf@gmail.com>
---

--- a/drivers/net/bonding/bonding.h	2010-11-01 19:54:12.000000000 +0800
+++ b/drivers/net/bonding/bonding.h	2010-12-11 12:48:00.000000000 +0800
@@ -273,11 +273,11 @@ static inline struct slave *bond_get_sla

 	bond_for_each_slave(bond, slave, i) {
 		if (slave->dev == slave_dev) {
-			break;
+			return slave;
 		}
 	}

-	return slave;
+	return 0;
 }

 static inline struct bonding *bond_get_bond_by_slave(struct slave *slave)
