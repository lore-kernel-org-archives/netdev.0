From: Anish Bhatt <anish@chelsio.com>
Subject: [PATCH net v2] libcxgbi/cxgb4i : Fix ipv6 build failure caught with  randconfig
Date: Tue, 12 Aug 2014 22:38:26 -0700
Message-ID: <1407908306-10790-1-git-send-email-anish@chelsio.com>
Cc: davem@davemloft.net, hch@infradead.org, kxie@chelsio.com,
	manojmalviya@chelsio.com, jim.epost@gmail.com,
	sfr@canb.auug.org.au, Anish Bhatt <anish@chelsio.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 99-65-72-227.uvs.sntcca.sbcglobal.net ([99.65.72.227]:46116
	"EHLO stargate3.asicdesigners.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1750740AbaHMFjX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Aug 2014 01:39:23 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Previous guard of IS_ENABLED(CONFIG_IPV6) is not sufficient when cxgbi drivers
are built into kernel but ipv6 is not.

v2: Use Kconfig to disable compiling cxgbi built into kernel when ipv6 is
compiled as a module

Fixes: e81fbf6cd652 ("libcxgbi:cxgb4i Guard ipv6 code with a config check")
Fixes: fc8d0590d914 ("libcxgbi: Add ipv6 api to driver")
Signed-off-by: Anish Bhatt <anish@chelsio.com>
---
 drivers/scsi/cxgbi/cxgb3i/Kconfig | 2 +-
 drivers/scsi/cxgbi/cxgb4i/Kconfig | 2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/scsi/cxgbi/cxgb3i/Kconfig b/drivers/scsi/cxgbi/cxgb3i/Kconfig
index 6bbc36f..e460398 100644
--- a/drivers/scsi/cxgbi/cxgb3i/Kconfig
+++ b/drivers/scsi/cxgbi/cxgb3i/Kconfig
@@ -1,6 +1,6 @@
 config SCSI_CXGB3_ISCSI
 	tristate "Chelsio T3 iSCSI support"
-	depends on PCI && INET
+	depends on PCI && INET && (IPV6 || IPV6=n)
 	select NETDEVICES
 	select ETHERNET
 	select NET_VENDOR_CHELSIO
diff --git a/drivers/scsi/cxgbi/cxgb4i/Kconfig b/drivers/scsi/cxgbi/cxgb4i/Kconfig
index 16b2c7d..8c4e423 100644
--- a/drivers/scsi/cxgbi/cxgb4i/Kconfig
+++ b/drivers/scsi/cxgbi/cxgb4i/Kconfig
@@ -1,6 +1,6 @@
 config SCSI_CXGB4_ISCSI
 	tristate "Chelsio T4 iSCSI support"
-	depends on PCI && INET
+	depends on PCI && INET && (IPV6 || IPV6=n)
 	select NETDEVICES
 	select ETHERNET
 	select NET_VENDOR_CHELSIO
-- 
2.0.4
