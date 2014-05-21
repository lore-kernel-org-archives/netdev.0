From: Veaceslav Falico <vfalico@gmail.com>
Subject: [PATCH net-next 2/2] bonding: remove NULL verification from bond_get_bond_by_slave()
Date: Wed, 21 May 2014 17:42:01 +0200
Message-ID: <1400686921-5698-3-git-send-email-vfalico@gmail.com>
References: <1400686921-5698-1-git-send-email-vfalico@gmail.com>
Cc: Veaceslav Falico <vfalico@gmail.com>,
	Jay Vosburgh <j.vosburgh@gmail.com>,
	Andy Gospodarek <andy@greyhouse.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:48517 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752480AbaEUPqs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 21 May 2014 11:46:48 -0400
In-Reply-To: <1400686921-5698-1-git-send-email-vfalico@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Every caller relies on the result being the actual bond, so this
verification just masks the real problem.

CC: Jay Vosburgh <j.vosburgh@gmail.com>
CC: Andy Gospodarek <andy@greyhouse.net>
Signed-off-by: Veaceslav Falico <vfalico@gmail.com>
---
 drivers/net/bonding/bonding.h | 2 --
 1 file changed, 2 deletions(-)

diff --git a/drivers/net/bonding/bonding.h b/drivers/net/bonding/bonding.h
index 44334b3d..dfc3779 100644
--- a/drivers/net/bonding/bonding.h
+++ b/drivers/net/bonding/bonding.h
@@ -249,8 +249,6 @@ static inline struct slave *bond_get_slave_by_dev(struct bonding *bond,
 
 static inline struct bonding *bond_get_bond_by_slave(struct slave *slave)
 {
-	if (!slave || !slave->bond)
-		return NULL;
 	return slave->bond;
 }
 
-- 
1.8.4
