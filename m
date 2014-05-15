From: Veaceslav Falico <vfalico@gmail.com>
Subject: [PATCH v3 net-next 3/9] bonding: make BOND_NO_USES_ARP an inline function
Date: Thu, 15 May 2014 21:39:53 +0200
Message-ID: <1400182799-22737-4-git-send-email-vfalico@gmail.com>
References: <1400182799-22737-1-git-send-email-vfalico@gmail.com>
Cc: Veaceslav Falico <vfalico@gmail.com>,
	Jay Vosburgh <j.vosburgh@gmail.com>,
	Andy Gospodarek <andy@greyhouse.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:33839 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751191AbaEOTok (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 15 May 2014 15:44:40 -0400
In-Reply-To: <1400182799-22737-1-git-send-email-vfalico@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Also, change its name to better reflect its scope, and skip the "no"
part.

CC: Jay Vosburgh <j.vosburgh@gmail.com>
CC: Andy Gospodarek <andy@greyhouse.net>
Signed-off-by: Veaceslav Falico <vfalico@gmail.com>
---
 drivers/net/bonding/bond_main.c    |  2 +-
 drivers/net/bonding/bond_options.c |  2 +-
 drivers/net/bonding/bonding.h      | 11 ++++++-----
 3 files changed, 8 insertions(+), 7 deletions(-)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 5c88c11..2448e28 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -4113,7 +4113,7 @@ static int bond_check_params(struct bond_params *params)
 	}
 
 	/* reset values for 802.3ad/TLB/ALB */
-	if (BOND_NO_USES_ARP(bond_mode)) {
+	if (!bond_mode_uses_arp(bond_mode)) {
 		if (!miimon) {
 			pr_warn("Warning: miimon must be specified, otherwise bonding will not detect link failure, speed and duplex which are essential for 802.3ad operation\n");
 			pr_warn("Forcing miimon to 100msec\n");
diff --git a/drivers/net/bonding/bond_options.c b/drivers/net/bonding/bond_options.c
index 6dc49da..98c8801 100644
--- a/drivers/net/bonding/bond_options.c
+++ b/drivers/net/bonding/bond_options.c
@@ -672,7 +672,7 @@ const struct bond_option *bond_opt_get(unsigned int option)
 
 int bond_option_mode_set(struct bonding *bond, const struct bond_opt_value *newval)
 {
-	if (BOND_NO_USES_ARP(newval->value) && bond->params.arp_interval) {
+	if (!bond_mode_uses_arp(newval->value) && bond->params.arp_interval) {
 		pr_info("%s: %s mode is incompatible with arp monitoring, start mii monitoring\n",
 			bond->dev->name, newval->string);
 		/* disable arp monitoring */
diff --git a/drivers/net/bonding/bonding.h b/drivers/net/bonding/bonding.h
index dca3dfd..105c552 100644
--- a/drivers/net/bonding/bonding.h
+++ b/drivers/net/bonding/bonding.h
@@ -60,11 +60,6 @@
 		 ((mode) == BOND_MODE_TLB)          ||	\
 		 ((mode) == BOND_MODE_ALB))
 
-#define BOND_NO_USES_ARP(mode)				\
-		(((mode) == BOND_MODE_8023AD)	||	\
-		 ((mode) == BOND_MODE_TLB)	||	\
-		 ((mode) == BOND_MODE_ALB))
-
 #define IS_IP_TARGET_UNUSABLE_ADDRESS(a)	\
 	((htonl(INADDR_BROADCAST) == a) ||	\
 	 ipv4_is_zeronet(a))
@@ -292,6 +287,12 @@ static inline bool bond_is_lb(const struct bonding *bond)
 	       bond->params.mode == BOND_MODE_ALB;
 }
 
+static inline bool bond_mode_uses_arp(int mode)
+{
+	return mode != BOND_MODE_8023AD && mode != BOND_MODE_TLB &&
+	       mode != BOND_MODE_ALB;
+}
+
 static inline void bond_set_active_slave(struct slave *slave)
 {
 	if (slave->backup) {
-- 
1.8.4
