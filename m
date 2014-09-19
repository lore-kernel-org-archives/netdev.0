From: Randy Dunlap <rdunlap@infradead.org>
Subject: [PATCH] scsi: fix SCSI_BNX2X_FCOE dependencies and build errors
Date: Fri, 19 Sep 2014 15:38:13 -0700
Message-ID: <541CB055.6000504@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: LKML <linux-kernel@vger.kernel.org>,
	Anish Bhatt <anish@chelsio.com>,
	James Bottomley <jbottomley@parallels.com>
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Randy Dunlap <rdunlap@infradead.org>

Don't enable NETDEVICES when NET is not enabled. That causes
build warnings and errors.

warning: (SCSI_CXGB3_ISCSI && SCSI_CXGB4_ISCSI && SCSI_BNX2X_FCOE) selects NETDEVICES which has unmet direct dependencies (NET)
warning: (SCSI_CXGB3_ISCSI && SCSI_CXGB4_ISCSI && SCSI_BNX2_ISCSI && SCSI_BNX2X_FCOE) selects ETHERNET which has unmet direct dependencies (NETDEVICES && NET)
warning: (SCSI_BNX2X_FCOE && LIBFCOE && TCM_QLA2XXX) selects LIBFC which has unmet direct dependencies (SCSI_LOWLEVEL && SCSI && SCSI_FC_ATTRS)

../drivers/net/ethernet/cisco/enic/enic_main.c: In function 'enic_rq_indicate_buf':
../drivers/net/ethernet/cisco/enic/enic_main.c:1077:3: error: implicit declaration of function 'skb_mark_napi_id' [-Werror=implicit-function-declaration]
../drivers/net/ethernet/cisco/enic/enic_main.c:1078:3: error: implicit declaration of function 'enic_poll_busy_polling' [-Werror=implicit-function-declaration]

Signed-off-by: Randy Dunlap <rdunlap@infradead.org>
---
 drivers/scsi/bnx2fc/Kconfig |    3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

--- linux-next-20140918.orig/drivers/scsi/bnx2fc/Kconfig
+++ linux-next-20140918/drivers/scsi/bnx2fc/Kconfig
@@ -1,7 +1,8 @@
 config SCSI_BNX2X_FCOE
 	tristate "QLogic NetXtreme II FCoE support"
-	depends on PCI
+	depends on PCI && NET
 	depends on (IPV6 || IPV6=n)
+	depends on SCSI_FC_ATTRS
 	select NETDEVICES
 	select ETHERNET
 	select NET_VENDOR_BROADCOM
