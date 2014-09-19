From: Randy Dunlap <rdunlap@infradead.org>
Subject: [PATCH] scsi: fix kconfig dependency warnings for SCSI_FC_ATTRS
Date: Fri, 19 Sep 2014 16:50:59 -0700
Message-ID: <541CC163.3080709@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: James Bottomley <jbottomley@parallels.com>,
	Anish Bhatt <anish@chelsio.com>
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	linux-scsi <linux-scsi@vger.kernel.org>
Return-path: <linux-scsi-owner@vger.kernel.org>
Sender: linux-scsi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Randy Dunlap <rdunlap@infradead.org>

Fix kconfig dependency warnings which can lead to build errors:

warning: (SCSI_BNX2X_FCOE && LIBFCOE && TCM_QLA2XXX) selects LIBFC which has unmet direct dependencies (SCSI_LOWLEVEL && SCSI && SCSI_FC_ATTRS)

warning: (FCOE && FCOE_FNIC) selects LIBFCOE which has unmet direct dependencies (SCSI_LOWLEVEL && SCSI && SCSI_FC_ATTRS)

Signed-off-by: Randy Dunlap <rdunlap@infradead.org>
---
 drivers/scsi/Kconfig         |    3 +++
 drivers/scsi/qla2xxx/Kconfig |    2 +-
 2 files changed, 4 insertions(+), 1 deletion(-)

--- linux-next-20140918.orig/drivers/scsi/Kconfig
+++ linux-next-20140918/drivers/scsi/Kconfig
@@ -601,6 +601,7 @@ config LIBFC
 
 config LIBFCOE
 	tristate "LibFCoE module"
+	depends on SCSI_FC_ATTRS
 	select LIBFC
 	---help---
 	  Library for Fibre Channel over Ethernet module
@@ -608,6 +609,7 @@ config LIBFCOE
 config FCOE
 	tristate "FCoE module"
 	depends on PCI
+	depends on SCSI_FC_ATTRS
 	select LIBFCOE
 	---help---
 	  Fibre Channel over Ethernet module
@@ -615,6 +617,7 @@ config FCOE
 config FCOE_FNIC
 	tristate "Cisco FNIC Driver"
 	depends on PCI && X86
+	depends on SCSI_FC_ATTRS
 	select LIBFCOE
 	help
 	  This is support for the Cisco PCI-Express FCoE HBA.
--- linux-next-20140918.orig/drivers/scsi/qla2xxx/Kconfig
+++ linux-next-20140918/drivers/scsi/qla2xxx/Kconfig
@@ -30,7 +30,7 @@ config SCSI_QLA_FC
 
 config TCM_QLA2XXX
 	tristate "TCM_QLA2XXX fabric module for Qlogic 2xxx series target mode HBAs"
-	depends on SCSI_QLA_FC && TARGET_CORE
+	depends on SCSI_QLA_FC && TARGET_CORE && SCSI_FC_ATTRS
 	select LIBFC
 	select BTREE
 	default n
