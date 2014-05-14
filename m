From: Veaceslav Falico <vfalico@gmail.com>
Subject: [PATCH net-next 2/5] bonding: rename {,BOND}_TX_QUEUE_OVERRIDE and make it accept bond struct
Date: Wed, 14 May 2014 14:54:21 +0200
Message-ID: <1400072064-26095-3-git-send-email-vfalico@gmail.com>
References: <1400072064-26095-1-git-send-email-vfalico@gmail.com>
Cc: Veaceslav Falico <vfalico@redhat.com>,
	Jay Vosburgh <j.vosburgh@gmail.com>,
	Andy Gospodarek <andy@greyhouse.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:52177 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755506AbaENM7A (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 14 May 2014 08:59:00 -0400
In-Reply-To: <1400072064-26095-1-git-send-email-vfalico@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Veaceslav Falico <vfalico@redhat.com>

CC: Jay Vosburgh <j.vosburgh@gmail.com>
CC: Andy Gospodarek <andy@greyhouse.net>
Signed-off-by: Veaceslav Falico <vfalico@redhat.com>
---
 drivers/net/bonding/bond_main.c | 2 +-
 drivers/net/bonding/bonding.h   | 6 +++---
 2 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index e6f1d02..4068c98 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -3758,7 +3758,7 @@ static netdev_tx_t __bond_start_xmit(struct sk_buff *skb, struct net_device *dev
 {
 	struct bonding *bond = netdev_priv(dev);
 
-	if (TX_QUEUE_OVERRIDE(bond->params.mode)) {
+	if (BOND_TX_QUEUE_OVERRIDE(bond)) {
 		if (!bond_slave_override(bond, skb))
 			return NETDEV_TX_OK;
 	}
diff --git a/drivers/net/bonding/bonding.h b/drivers/net/bonding/bonding.h
index 29ddce5..28c20c5 100644
--- a/drivers/net/bonding/bonding.h
+++ b/drivers/net/bonding/bonding.h
@@ -65,9 +65,9 @@
 		 ((mode) == BOND_MODE_TLB)	||	\
 		 ((mode) == BOND_MODE_ALB))
 
-#define TX_QUEUE_OVERRIDE(mode)				\
-			(((mode) == BOND_MODE_ACTIVEBACKUP) ||	\
-			 ((mode) == BOND_MODE_ROUNDROBIN))
+#define BOND_TX_QUEUE_OVERRIDE(bond)			\
+		(((bond->params.mode) == BOND_MODE_ACTIVEBACKUP) ||	\
+		 ((bond->params.mode) == BOND_MODE_ROUNDROBIN))
 
 #define BOND_IS_LB(bond)			\
 		(((bond->params.mode) == BOND_MODE_TLB) ||	\
-- 
1.8.4
