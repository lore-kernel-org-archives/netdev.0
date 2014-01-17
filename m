From: Veaceslav Falico <vfalico@redhat.com>
Subject: [PATCH v2 net-next 05/12] bonding: extend arp_validate to be able to receive unvalidated arp-only traffic
Date: Fri, 17 Jan 2014 17:58:53 +0100
Message-ID: <1389977940-17084-6-git-send-email-vfalico@redhat.com>
References: <1389977940-17084-1-git-send-email-vfalico@redhat.com>
Cc: Veaceslav Falico <vfalico@redhat.com>,
	Jay Vosburgh <fubar@us.ibm.com>,
	Andy Gospodarek <andy@greyhouse.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:40324 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752657AbaAQRER (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 17 Jan 2014 12:04:17 -0500
In-Reply-To: <1389977940-17084-1-git-send-email-vfalico@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently we can either receive any traffic as a proff of slave being up,
or only *validated* arp traffic (i.e. with src/dst ip checked).

Add an option to be able to specify if we want to receive non-validated arp
traffic only.

CC: Jay Vosburgh <fubar@us.ibm.com>
CC: Andy Gospodarek <andy@greyhouse.net>
Signed-off-by: Veaceslav Falico <vfalico@redhat.com>
---
 drivers/net/bonding/bond_main.c |  3 +++
 drivers/net/bonding/bonding.h   | 11 +++++++++++
 2 files changed, 14 insertions(+)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 07ae82d..532a452 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -246,6 +246,9 @@ const struct bond_parm_tbl arp_validate_tbl[] = {
 {	"active",		BOND_ARP_VALIDATE_ACTIVE},
 {	"backup",		BOND_ARP_VALIDATE_BACKUP},
 {	"all",			BOND_ARP_VALIDATE_ALL},
+{	"arp",			BOND_ARP_VALIDATE_ARP},
+{	"active_arp",		BOND_ARP_VALIDATE_ACTIVE_ARP},
+{	"backup_arp",		BOND_ARP_VALIDATE_BACKUP_ARP},
 {	NULL,			-1},
 };
 
diff --git a/drivers/net/bonding/bonding.h b/drivers/net/bonding/bonding.h
index 955dc48..1fbbf04 100644
--- a/drivers/net/bonding/bonding.h
+++ b/drivers/net/bonding/bonding.h
@@ -318,6 +318,11 @@ static inline bool bond_is_active_slave(struct slave *slave)
 #define BOND_ARP_VALIDATE_BACKUP	(1 << BOND_STATE_BACKUP)
 #define BOND_ARP_VALIDATE_ALL		(BOND_ARP_VALIDATE_ACTIVE | \
 					 BOND_ARP_VALIDATE_BACKUP)
+#define BOND_ARP_VALIDATE_ARP		(BOND_ARP_VALIDATE_ALL + 1)
+#define BOND_ARP_VALIDATE_ACTIVE_ARP	(BOND_ARP_VALIDATE_ACTIVE | \
+					 BOND_ARP_VALIDATE_ARP)
+#define BOND_ARP_VALIDATE_BACKUP_ARP	(BOND_ARP_VALIDATE_BACKUP | \
+					 BOND_ARP_VALIDATE_ARP)
 
 static inline int slave_do_arp_validate(struct bonding *bond,
 					struct slave *slave)
@@ -325,6 +330,12 @@ static inline int slave_do_arp_validate(struct bonding *bond,
 	return bond->params.arp_validate & (1 << bond_slave_state(slave));
 }
 
+static inline int slave_do_arp_validate_only(struct bonding *bond,
+					     struct slave *slave)
+{
+	return bond->params.arp_validate & BOND_ARP_VALIDATE_ARP;
+}
+
 /* Get the oldest arp which we've received on this slave for bond's
  * arp_targets.
  */
-- 
1.8.4
