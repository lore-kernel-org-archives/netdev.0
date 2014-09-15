From: Anish Bhatt <anish@chelsio.com>
Subject: [PATCH net 2/2] bnx2i/bnx2fc : fix randconfig error in next-20140909
Date: Mon, 15 Sep 2014 13:45:21 -0700
Message-ID: <1410813921-24400-3-git-send-email-anish@chelsio.com>
References: <1410813921-24400-1-git-send-email-anish@chelsio.com>
Cc: linux-scsi@vger.kernel.org, davem@davemloft.net,
	JBottomley@parallels.com, mchan@broadcom.com,
	eddie.wai@broadcom.com, rdunlap@infradead.org, jim.epost@gmail.com,
	Anish Bhatt <anish@chelsio.com>
To: netdev@vger.kernel.org
Return-path: <linux-scsi-owner@vger.kernel.org>
In-Reply-To: <1410813921-24400-1-git-send-email-anish@chelsio.com>
Sender: linux-scsi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Just like CNIC, tristate of these two modules is also dependent on IPV6.
These need to be handled separately as they select CNIC, which can override
tristate for CNIC from 'm' to 'y', which can cause build failures when ipv6 is
 compiled as a module even if CNIC's Kconfig will only 'm' or 'n' when ipv6 is
compiled as a module.

Fixes: c99d667e8527 ("cnic : Cleanup CONFIG_IPV6 & VLAN check")
Signed-off-by: Anish Bhatt <anish@chelsio.com>

---
 drivers/scsi/bnx2fc/Kconfig | 1 +
 drivers/scsi/bnx2i/Kconfig  | 1 +
 2 files changed, 2 insertions(+)

diff --git a/drivers/scsi/bnx2fc/Kconfig b/drivers/scsi/bnx2fc/Kconfig
index f245d54..02b0ba8 100644
--- a/drivers/scsi/bnx2fc/Kconfig
+++ b/drivers/scsi/bnx2fc/Kconfig
@@ -1,6 +1,7 @@
 config SCSI_BNX2X_FCOE
 	tristate "QLogic NetXtreme II FCoE support"
 	depends on PCI
+	depends on (IPV6 || IPV6=n)
 	select NETDEVICES
 	select ETHERNET
 	select NET_VENDOR_BROADCOM
diff --git a/drivers/scsi/bnx2i/Kconfig b/drivers/scsi/bnx2i/Kconfig
index 44ce54e..ba30ff8 100644
--- a/drivers/scsi/bnx2i/Kconfig
+++ b/drivers/scsi/bnx2i/Kconfig
@@ -2,6 +2,7 @@ config SCSI_BNX2_ISCSI
 	tristate "QLogic NetXtreme II iSCSI support"
 	depends on NET
 	depends on PCI
+	depends on (IPV6 || IPV6=n)
 	select SCSI_ISCSI_ATTRS
 	select NETDEVICES
 	select ETHERNET
-- 
2.1.0

