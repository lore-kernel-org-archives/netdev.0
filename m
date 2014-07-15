From: Veaceslav Falico <vfalico@gmail.com>
Subject: [PATCH net-next 2/2] bonding: make hard-coded defines configurable at build
Date: Tue, 15 Jul 2014 12:15:41 +0200
Message-ID: <1405419341-31510-3-git-send-email-vfalico@gmail.com>
References: <1405419341-31510-1-git-send-email-vfalico@gmail.com>
Cc: Veaceslav Falico <vfalico@gmail.com>,
	Jay Vosburgh <j.vosburgh@gmail.com>,
	Andy Gospodarek <andy@greyhouse.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:30198 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758107AbaGOKUH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 15 Jul 2014 06:20:07 -0400
In-Reply-To: <1405419341-31510-1-git-send-email-vfalico@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

CC: Jay Vosburgh <j.vosburgh@gmail.com>
CC: Andy Gospodarek <andy@greyhouse.net>
Signed-off-by: Veaceslav Falico <vfalico@gmail.com>
---
 drivers/net/bonding/Kconfig   | 16 ++++++++++++++++
 drivers/net/bonding/bonding.h |  6 +++---
 2 files changed, 19 insertions(+), 3 deletions(-)

diff --git a/drivers/net/bonding/Kconfig b/drivers/net/bonding/Kconfig
index 7b1a0fa..28fb3af 100644
--- a/drivers/net/bonding/Kconfig
+++ b/drivers/net/bonding/Kconfig
@@ -15,3 +15,19 @@ menuconfig BONDING
 
 	  To compile this driver as a module, choose M here: the module
 	  will be called bonding.
+
+if BONDING
+
+config BOND_MAX_VLAN_ENCAP
+	int "Maximum number of stacked vlans on top of bonding"
+	default "2"
+
+config BOND_MAX_ARP_TARGETS
+	int "Maximum number of ip targets arp monitor supports"
+	default "16"
+
+config BOND_DEFAULT_MIIMON
+	int "Default miimon monitoring frequency in milliseconds"
+	default "100"
+
+endif
diff --git a/drivers/net/bonding/bonding.h b/drivers/net/bonding/bonding.h
index 0b4d9cd..119ce68 100644
--- a/drivers/net/bonding/bonding.h
+++ b/drivers/net/bonding/bonding.h
@@ -36,10 +36,10 @@
 
 #define bond_version DRV_DESCRIPTION ": v" DRV_VERSION " (" DRV_RELDATE ")\n"
 
-#define BOND_MAX_VLAN_ENCAP	2
-#define BOND_MAX_ARP_TARGETS	16
+#define BOND_MAX_VLAN_ENCAP	CONFIG_BOND_MAX_VLAN_ENCAP
+#define BOND_MAX_ARP_TARGETS	CONFIG_BOND_MAX_ARP_TARGETS
 
-#define BOND_DEFAULT_MIIMON	100
+#define BOND_DEFAULT_MIIMON	CONFIG_BOND_DEFAULT_MIIMON
 
 /*
  * Less bad way to call ioctl from within the kernel; this needs to be
-- 
1.8.4
