From: Veaceslav Falico <vfalico@gmail.com>
Subject: [PATCH v2 net-next 1/9] bonding: remove BOND_MODE_IS_LB macro
Date: Thu, 15 May 2014 14:29:19 +0200
Message-ID: <1400156967-8231-2-git-send-email-vfalico@gmail.com>
References: <1400156967-8231-1-git-send-email-vfalico@gmail.com>
Cc: Veaceslav Falico <vfalico@gmail.com>,
	Jay Vosburgh <j.vosburgh@gmail.com>,
	Andy Gospodarek <andy@greyhouse.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:56429 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751361AbaEOMeF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 15 May 2014 08:34:05 -0400
In-Reply-To: <1400156967-8231-1-git-send-email-vfalico@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

It's used only in an inline function and is useless.

CC: Jay Vosburgh <j.vosburgh@gmail.com>
CC: Andy Gospodarek <andy@greyhouse.net>
Signed-off-by: Veaceslav Falico <vfalico@gmail.com>
---
 drivers/net/bonding/bonding.h | 7 ++-----
 1 file changed, 2 insertions(+), 5 deletions(-)

diff --git a/drivers/net/bonding/bonding.h b/drivers/net/bonding/bonding.h
index c51c433..16e57a1 100644
--- a/drivers/net/bonding/bonding.h
+++ b/drivers/net/bonding/bonding.h
@@ -69,10 +69,6 @@
 			(((mode) == BOND_MODE_ACTIVEBACKUP) ||	\
 			 ((mode) == BOND_MODE_ROUNDROBIN))
 
-#define BOND_MODE_IS_LB(mode)			\
-		(((mode) == BOND_MODE_TLB) ||	\
-		 ((mode) == BOND_MODE_ALB))
-
 #define IS_IP_TARGET_UNUSABLE_ADDRESS(a)	\
 	((htonl(INADDR_BROADCAST) == a) ||	\
 	 ipv4_is_zeronet(a))
@@ -290,7 +286,8 @@ static inline struct bonding *bond_get_bond_by_slave(struct slave *slave)
 
 static inline bool bond_is_lb(const struct bonding *bond)
 {
-	return BOND_MODE_IS_LB(bond->params.mode);
+	return bond->params.mode == BOND_MODE_TLB ||
+	       bond->params.mode == BOND_MODE_ALB;
 }
 
 static inline void bond_set_active_slave(struct slave *slave)
-- 
1.8.4
