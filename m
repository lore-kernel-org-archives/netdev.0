From: Randy Dunlap <rdunlap@infradead.org>
Subject: [PATCH -net] scsi: fix users of SCSI_FC_ATTRS to depend on NET
Date: Mon, 15 Sep 2014 23:35:21 -0700
Message-ID: <5417DA29.4060205@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Fengguang Wu <fengguang.wu@intel.com>
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	linux-scsi <linux-scsi@vger.kernel.org>,
	James Bottomley <jbottomley@parallels.com>,
	David Miller <davem@davemloft.net>
Return-path: <linux-scsi-owner@vger.kernel.org>
Sender: linux-scsi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Randy Dunlap <rdunlap@infradead.org>

There are other kconfig symbols which select SCSI_FC_ATTRS,
so they also need to depend on NET to fix kconfig warnings and
build errors:

warning: (LIBFC && SCSI_IBMVFC && SCSI_QLA_FC && SCSI_LPFC && ZFCP && SCSI_BFA_FC && SCSI_CHELSIO_FCOE && FUSION_FC) selects SCSI_FC_ATTRS which has unmet direct dependencies (SCSI && NET)
drivers/scsi/scsi_transport_fc.c: In function 'fc_host_post_event':
drivers/scsi/scsi_transport_fc.c:543:7: error: 'scsi_nl_sock' undeclared (first use in this function)
drivers/scsi/scsi_transport_fc.c: In function 'fc_host_post_vendor_event':
drivers/scsi/scsi_transport_fc.c:611:7: error: 'scsi_nl_sock' undeclared (first use in this function)

Reported-by: Fengguang Wu <fengguang.wu@intel.com> [0-day test robot]
Signed-off-by: Randy Dunlap <rdunlap@infradead.org>
---
 drivers/message/fusion/Kconfig |    2 +-
 drivers/scsi/Kconfig           |    9 +++++----
 drivers/scsi/csiostor/Kconfig  |    2 +-
 drivers/scsi/qla2xxx/Kconfig   |    2 +-
 4 files changed, 8 insertions(+), 7 deletions(-)

--- lnx-317-rc5.orig/drivers/message/fusion/Kconfig
+++ lnx-317-rc5/drivers/message/fusion/Kconfig
@@ -28,7 +28,7 @@ config FUSION_SPI
 
 config FUSION_FC
 	tristate "Fusion MPT ScsiHost drivers for FC"
-	depends on PCI && SCSI
+	depends on PCI && SCSI && NET
 	select SCSI_FC_ATTRS
 	---help---
 	  SCSI HOST support for a Fiber Channel host adapters.
--- lnx-317-rc5.orig/drivers/scsi/Kconfig
+++ lnx-317-rc5/drivers/scsi/Kconfig
@@ -585,6 +585,7 @@ config HYPERV_STORAGE
 
 config LIBFC
 	tristate "LibFC module"
+	depends on NET
 	select SCSI_FC_ATTRS
 	select CRC32
 	---help---
@@ -815,7 +816,7 @@ config SCSI_IBMVSCSI
 
 config SCSI_IBMVFC
 	tristate "IBM Virtual FC support"
-	depends on PPC_PSERIES && SCSI
+	depends on PPC_PSERIES && SCSI && NET
 	select SCSI_FC_ATTRS
 	help
 	  This is the IBM POWER Virtual FC Client
@@ -1265,7 +1266,7 @@ source "drivers/scsi/qla4xxx/Kconfig"
 
 config SCSI_LPFC
 	tristate "Emulex LightPulse Fibre Channel Support"
-	depends on PCI && SCSI
+	depends on PCI && SCSI && NET
 	select SCSI_FC_ATTRS
 	select CRC_T10DIF
 	help
@@ -1675,7 +1676,7 @@ config SCSI_SUNESP
 
 config ZFCP
 	tristate "FCP host bus adapter driver for IBM eServer zSeries"
-	depends on S390 && QDIO && SCSI
+	depends on S390 && QDIO && SCSI && NET
 	select SCSI_FC_ATTRS
 	help
           If you want to access SCSI devices attached to your IBM eServer
@@ -1703,7 +1704,7 @@ config SCSI_PM8001
 
 config SCSI_BFA_FC
 	tristate "Brocade BFA Fibre Channel Support"
-	depends on PCI && SCSI
+	depends on PCI && SCSI && NET
 	select SCSI_FC_ATTRS
 	help
 	  This bfa driver supports all Brocade PCIe FC/FCOE host adapters.
--- lnx-317-rc5.orig/drivers/scsi/csiostor/Kconfig
+++ lnx-317-rc5/drivers/scsi/csiostor/Kconfig
@@ -1,6 +1,6 @@
 config SCSI_CHELSIO_FCOE
 	tristate "Chelsio Communications FCoE support"
-	depends on PCI && SCSI
+	depends on PCI && SCSI && NET
 	select SCSI_FC_ATTRS
 	select FW_LOADER
 	help
--- lnx-317-rc5.orig/drivers/scsi/qla2xxx/Kconfig
+++ lnx-317-rc5/drivers/scsi/qla2xxx/Kconfig
@@ -1,6 +1,6 @@
 config SCSI_QLA_FC
 	tristate "QLogic QLA2XXX Fibre Channel Support"
-	depends on PCI && SCSI
+	depends on PCI && SCSI && NET
 	select SCSI_FC_ATTRS
 	select FW_LOADER
 	---help---
