From: Veaceslav Falico <vfalico@gmail.com>
Subject: [PATCH net-next 3/5] bonding: rename {BOND_NO,MODE_NOT}_USES_ARP to better reflect its meaning
Date: Wed, 14 May 2014 14:54:22 +0200
Message-ID: <1400072064-26095-4-git-send-email-vfalico@gmail.com>
References: <1400072064-26095-1-git-send-email-vfalico@gmail.com>
Cc: Veaceslav Falico <vfalico@redhat.com>,
	Jay Vosburgh <j.vosburgh@gmail.com>,
	Andy Gospodarek <andy@greyhouse.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:24717 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755536AbaENM7H (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 14 May 2014 08:59:07 -0400
In-Reply-To: <1400072064-26095-1-git-send-email-vfalico@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Veaceslav Falico <vfalico@redhat.com>

CC: Jay Vosburgh <j.vosburgh@gmail.com>
CC: Andy Gospodarek <andy@greyhouse.net>
Signed-off-by: Veaceslav Falico <vfalico@redhat.com>
---
 drivers/net/bonding/bond_main.c    | 2 +-
 drivers/net/bonding/bond_options.c | 2 +-
 drivers/net/bonding/bonding.h      | 2 +-
 3 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 4068c98..6d18876 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -4084,7 +4084,7 @@ static int bond_check_params(struct bond_params *params)
 	}
 
 	/* reset values for 802.3ad/TLB/ALB */
-	if (BOND_NO_USES_ARP(bond_mode)) {
+	if (MODE_NOT_USES_ARP(bond_mode)) {
 		if (!miimon) {
 			pr_warn("Warning: miimon must be specified, otherwise bonding will not detect link failure, speed and duplex which are essential for 802.3ad operation\n");
 			pr_warn("Forcing miimon to 100msec\n");
diff --git a/drivers/net/bonding/bond_options.c b/drivers/net/bonding/bond_options.c
index 6dc49da..7219ce3 100644
--- a/drivers/net/bonding/bond_options.c
+++ b/drivers/net/bonding/bond_options.c
@@ -672,7 +672,7 @@ const struct bond_option *bond_opt_get(unsigned int option)
 
 int bond_option_mode_set(struct bonding *bond, const struct bond_opt_value *newval)
 {
-	if (BOND_NO_USES_ARP(newval->value) && bond->params.arp_interval) {
+	if (MODE_NOT_USES_ARP(newval->value) && bond->params.arp_interval) {
 		pr_info("%s: %s mode is incompatible with arp monitoring, start mii monitoring\n",
 			bond->dev->name, newval->string);
 		/* disable arp monitoring */
diff --git a/drivers/net/bonding/bonding.h b/drivers/net/bonding/bonding.h
index 28c20c5..cd057f0 100644
--- a/drivers/net/bonding/bonding.h
+++ b/drivers/net/bonding/bonding.h
@@ -60,7 +60,7 @@
 		 ((mode) == BOND_MODE_TLB)          ||	\
 		 ((mode) == BOND_MODE_ALB))
 
-#define BOND_NO_USES_ARP(mode)				\
+#define MODE_NOT_USES_ARP(mode)				\
 		(((mode) == BOND_MODE_8023AD)	||	\
 		 ((mode) == BOND_MODE_TLB)	||	\
 		 ((mode) == BOND_MODE_ALB))
-- 
1.8.4
