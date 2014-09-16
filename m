From: Randy Dunlap <rdunlap@infradead.org>
Subject: [PATCH v2] scsi: use 'depends' instead of 'select' for SCSI_FC_ATTRS
Date: Tue, 16 Sep 2014 13:47:41 -0700
Message-ID: <5418A1ED.3010302@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	linux-scsi <linux-scsi@vger.kernel.org>
To: David Miller <davem@davemloft.net>,
	James Bottomley <jbottomley@parallels.com>
Return-path: <linux-scsi-owner@vger.kernel.org>
Sender: linux-scsi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Randy Dunlap <rdunlap@infradead.org>

There are other kconfig symbols which use SCSI_FC_ATTRS.
In order to maintain sanity and prevent kconfig warnings, change
all of these from using 'select' to using 'depends on' so that
proper symbol dependencies will be honored and circular depends
problems will be avoided.
This fixes kconfig warnings and build errors:

warning: (LIBFC && SCSI_IBMVFC && SCSI_QLA_FC && SCSI_LPFC && ZFCP && SCSI_BFA_FC && SCSI_CHELSIO_FCOE && FUSION_FC) selects SCSI_FC_ATTRS which has unmet direct dependencies (SCSI && NET)
drivers/scsi/scsi_transport_fc.c: In function 'fc_host_post_event':
drivers/scsi/scsi_transport_fc.c:543:7: error: 'scsi_nl_sock' undeclared (first use in this function)
drivers/scsi/scsi_transport_fc.c: In function 'fc_host_post_vendor_event':
drivers/scsi/scsi_transport_fc.c:611:7: error: 'scsi_nl_sock' undeclared (first use in this function)

Reported-by: Fengguang Wu <fengguang.wu@intel.com> [0-day test robot]
Signed-off-by: Randy Dunlap <rdunlap@infradead.org>
---
 drivers/message/fusion/Kconfig |    2 +-
 drivers/scsi/Kconfig           |   10 +++++-----
 drivers/scsi/csiostor/Kconfig  |    2 +-
 drivers/scsi/qla2xxx/Kconfig   |    2 +-
 4 files changed, 8 insertions(+), 8 deletions(-)

--- lnx-317-rc5.orig/drivers/message/fusion/Kconfig
+++ lnx-317-rc5/drivers/message/fusion/Kconfig
@@ -29,7 +29,7 @@ config FUSION_SPI
 config FUSION_FC
 	tristate "Fusion MPT ScsiHost drivers for FC"
 	depends on PCI && SCSI
-	select SCSI_FC_ATTRS
+	depends on SCSI_FC_ATTRS
 	---help---
 	  SCSI HOST support for a Fiber Channel host adapters.
 
--- lnx-317-rc5.orig/drivers/scsi/Kconfig
+++ lnx-317-rc5/drivers/scsi/Kconfig
@@ -585,7 +585,7 @@ config HYPERV_STORAGE
 
 config LIBFC
 	tristate "LibFC module"
-	select SCSI_FC_ATTRS
+	depends on SCSI_FC_ATTRS
 	select CRC32
 	---help---
 	  Fibre Channel library module
@@ -816,7 +816,7 @@ config SCSI_IBMVSCSI
 config SCSI_IBMVFC
 	tristate "IBM Virtual FC support"
 	depends on PPC_PSERIES && SCSI
-	select SCSI_FC_ATTRS
+	depends on SCSI_FC_ATTRS
 	help
 	  This is the IBM POWER Virtual FC Client
 
@@ -1266,7 +1266,7 @@ source "drivers/scsi/qla4xxx/Kconfig"
 config SCSI_LPFC
 	tristate "Emulex LightPulse Fibre Channel Support"
 	depends on PCI && SCSI
-	select SCSI_FC_ATTRS
+	depends on SCSI_FC_ATTRS
 	select CRC_T10DIF
 	help
           This lpfc driver supports the Emulex LightPulse
@@ -1676,7 +1676,7 @@ config SCSI_SUNESP
 config ZFCP
 	tristate "FCP host bus adapter driver for IBM eServer zSeries"
 	depends on S390 && QDIO && SCSI
-	select SCSI_FC_ATTRS
+	depends on SCSI_FC_ATTRS
 	help
           If you want to access SCSI devices attached to your IBM eServer
           zSeries by means of Fibre Channel interfaces say Y.
@@ -1704,7 +1704,7 @@ config SCSI_PM8001
 config SCSI_BFA_FC
 	tristate "Brocade BFA Fibre Channel Support"
 	depends on PCI && SCSI
-	select SCSI_FC_ATTRS
+	depends on SCSI_FC_ATTRS
 	help
 	  This bfa driver supports all Brocade PCIe FC/FCOE host adapters.
 
--- lnx-317-rc5.orig/drivers/scsi/csiostor/Kconfig
+++ lnx-317-rc5/drivers/scsi/csiostor/Kconfig
@@ -1,7 +1,7 @@
 config SCSI_CHELSIO_FCOE
 	tristate "Chelsio Communications FCoE support"
 	depends on PCI && SCSI
-	select SCSI_FC_ATTRS
+	depends on SCSI_FC_ATTRS
 	select FW_LOADER
 	help
 	  This driver supports FCoE Offload functionality over
--- lnx-317-rc5.orig/drivers/scsi/qla2xxx/Kconfig
+++ lnx-317-rc5/drivers/scsi/qla2xxx/Kconfig
@@ -1,7 +1,7 @@
 config SCSI_QLA_FC
 	tristate "QLogic QLA2XXX Fibre Channel Support"
 	depends on PCI && SCSI
-	select SCSI_FC_ATTRS
+	depends on SCSI_FC_ATTRS
 	select FW_LOADER
 	---help---
 	This qla2xxx driver supports all QLogic Fibre Channel
