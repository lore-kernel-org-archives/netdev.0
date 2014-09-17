From: David Miller <davem@davemloft.net>
Subject: Re: linux-next: build failure after merge of the net tree
Date: Tue, 16 Sep 2014 21:48:59 -0400 (EDT)
Message-ID: <20140916.214859.1906368469534009374.davem@davemloft.net>
References: <20140917110454.399a7841@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-next@vger.kernel.org,
	linux-kernel@vger.kernel.org, anish@chelsio.com
To: sfr@canb.auug.org.au
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <20140917110454.399a7841@canb.auug.org.au>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stephen Rothwell <sfr@canb.auug.org.au>
Date: Wed, 17 Sep 2014 11:04:54 +1000

> This is a bit different to yesterday's failure but I assume it is still
> related to commit 5d6be6a5d486 ("scsi_netlink : Make SCSI_NETLINK
> dependent on NET instead of selecting NET").
> 
> I used the net tree from next-20140915 again today.

Should be fixed by:

commit 6a38792ca8a5da28f65dc42eeb73d9a431f8d0fd
Author: Randy Dunlap <rdunlap@infradead.org>
Date:   Tue Sep 16 13:47:41 2014 -0700

    scsi: use 'depends' instead of 'select' for SCSI_FC_ATTRS
    
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
    Signed-off-by: David S. Miller <davem@davemloft.net>

diff --git a/drivers/message/fusion/Kconfig b/drivers/message/fusion/Kconfig
index a34a11d..63ca984 100644
--- a/drivers/message/fusion/Kconfig
+++ b/drivers/message/fusion/Kconfig
@@ -29,7 +29,7 @@ config FUSION_SPI
 config FUSION_FC
 	tristate "Fusion MPT ScsiHost drivers for FC"
 	depends on PCI && SCSI
-	select SCSI_FC_ATTRS
+	depends on SCSI_FC_ATTRS
 	---help---
 	  SCSI HOST support for a Fiber Channel host adapters.
 
diff --git a/drivers/scsi/Kconfig b/drivers/scsi/Kconfig
index 1d7e513..b745012 100644
--- a/drivers/scsi/Kconfig
+++ b/drivers/scsi/Kconfig
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
 
diff --git a/drivers/scsi/csiostor/Kconfig b/drivers/scsi/csiostor/Kconfig
index 4d03b03..7c7e508 100644
--- a/drivers/scsi/csiostor/Kconfig
+++ b/drivers/scsi/csiostor/Kconfig
@@ -1,7 +1,7 @@
 config SCSI_CHELSIO_FCOE
 	tristate "Chelsio Communications FCoE support"
 	depends on PCI && SCSI
-	select SCSI_FC_ATTRS
+	depends on SCSI_FC_ATTRS
 	select FW_LOADER
 	help
 	  This driver supports FCoE Offload functionality over
diff --git a/drivers/scsi/qla2xxx/Kconfig b/drivers/scsi/qla2xxx/Kconfig
index 23d6072..7d65776 100644
--- a/drivers/scsi/qla2xxx/Kconfig
+++ b/drivers/scsi/qla2xxx/Kconfig
@@ -1,7 +1,7 @@
 config SCSI_QLA_FC
 	tristate "QLogic QLA2XXX Fibre Channel Support"
 	depends on PCI && SCSI
-	select SCSI_FC_ATTRS
+	depends on SCSI_FC_ATTRS
 	select FW_LOADER
 	---help---
 	This qla2xxx driver supports all QLogic Fibre Channel
