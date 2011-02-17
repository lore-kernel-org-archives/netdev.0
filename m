From: "Jan Beulich" <JBeulich@novell.com>
Subject: [PATCH] cxgb{3,4}: streamline Kconfig options
Date: Thu, 17 Feb 2011 13:29:30 +0000
Message-ID: <4D5D30CA020000780003263A@vpn.id2.novell.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 8BIT
Cc: <linux-kbuild@vger.kernel.org>, <netdev@vger.kernel.org>
To: <divy@chelsio.com>, <dm@chelsio.com>
Return-path: <linux-kbuild-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kbuild-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The CHELSIO_T{3,4}_DEPENDS options are really awkward, and can be
easily dropped if the reverse dependencies of SCSI_CXGB{3,4}_ISCSI on
the former get converted to normal (forward) ones referring to
CHELSIO_T{3,4}.

Signed-off-by: Jan Beulich <jbeulich@novell.com>

---
 drivers/net/Kconfig               |   14 ++------------
 drivers/scsi/cxgbi/cxgb3i/Kconfig |    3 +--
 drivers/scsi/cxgbi/cxgb4i/Kconfig |    3 +--
 3 files changed, 4 insertions(+), 16 deletions(-)

--- 2.6.38-rc5/drivers/net/Kconfig
+++ 2.6.38-rc5-kconfig-chelsio/drivers/net/Kconfig
@@ -2594,14 +2594,9 @@ config CHELSIO_T1_1G
 	  Enables support for Chelsio's gigabit Ethernet PCI cards.  If you
 	  are using only 10G cards say 'N' here.
 
-config CHELSIO_T3_DEPENDS
-	tristate
-	depends on PCI && INET
-	default y
-
 config CHELSIO_T3
 	tristate "Chelsio Communications T3 10Gb Ethernet support"
-	depends on CHELSIO_T3_DEPENDS
+	depends on PCI && INET
 	select FW_LOADER
 	select MDIO
 	help
@@ -2619,14 +2614,9 @@ config CHELSIO_T3
 	  To compile this driver as a module, choose M here: the module
 	  will be called cxgb3.
 
-config CHELSIO_T4_DEPENDS
-	tristate
-	depends on PCI && INET
-	default y
-
 config CHELSIO_T4
 	tristate "Chelsio Communications T4 Ethernet support"
-	depends on CHELSIO_T4_DEPENDS
+	depends on PCI && INET
 	select FW_LOADER
 	select MDIO
 	help
--- 2.6.38-rc5/drivers/scsi/cxgbi/cxgb3i/Kconfig
+++ 2.6.38-rc5-kconfig-chelsio/drivers/scsi/cxgbi/cxgb3i/Kconfig
@@ -1,7 +1,6 @@
 config SCSI_CXGB3_ISCSI
 	tristate "Chelsio T3 iSCSI support"
-	depends on CHELSIO_T3_DEPENDS
-	select CHELSIO_T3
+	depends on CHELSIO_T3
 	select SCSI_ISCSI_ATTRS
 	---help---
 	  This driver supports iSCSI offload for the Chelsio T3 devices.
--- 2.6.38-rc5/drivers/scsi/cxgbi/cxgb4i/Kconfig
+++ 2.6.38-rc5-kconfig-chelsio/drivers/scsi/cxgbi/cxgb4i/Kconfig
@@ -1,7 +1,6 @@
 config SCSI_CXGB4_ISCSI
 	tristate "Chelsio T4 iSCSI support"
-	depends on CHELSIO_T4_DEPENDS
-	select CHELSIO_T4
+	depends on CHELSIO_T4
 	select SCSI_ISCSI_ATTRS
 	---help---
 	  This driver supports iSCSI offload for the Chelsio T4 devices.



