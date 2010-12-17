From: Amit Kumar Salecha <amit.salecha@qlogic.com>
Subject: [PATCH NEXT 3/3] qlcnic: reset pci function unconditionally during probe
Date: Fri, 17 Dec 2010 00:59:02 -0800
Message-ID: <1292576342-1359-4-git-send-email-amit.salecha@qlogic.com>
References: <1292576342-1359-1-git-send-email-amit.salecha@qlogic.com>
Cc: netdev@vger.kernel.org, ameen.rahman@qlogic.com,
	anirban.chakraborty@qlogic.com,
	Rajesh Borundia <rajesh.borundia@qlogic.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mvnat01.qlogic.com ([198.186.3.73]:23667 "EHLO unm84.unminc.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751842Ab0LQI72 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 17 Dec 2010 03:59:28 -0500
In-Reply-To: <1292576342-1359-1-git-send-email-amit.salecha@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Rajesh Borundia <rajesh.borundia@qlogic.com>

Some boot code drivers dont have cleanup routine, so pci function
remains in unknown state prior to driver load. So during driver load
issue FLR unconditionally.

Update driver version to 5.0.14.

Signed-off-by: Rajesh Borundia <rajesh.borundia@qlogic.com>
Signed-off-by: Amit Kumar Salecha <amit.salecha@qlogic.com>
---
 drivers/net/qlcnic/qlcnic.h      |    4 ++--
 drivers/net/qlcnic/qlcnic_main.c |    5 +----
 2 files changed, 3 insertions(+), 6 deletions(-)

diff --git a/drivers/net/qlcnic/qlcnic.h b/drivers/net/qlcnic/qlcnic.h
index 4028d0c..9c2a02d 100644
--- a/drivers/net/qlcnic/qlcnic.h
+++ b/drivers/net/qlcnic/qlcnic.h
@@ -34,8 +34,8 @@
 
 #define _QLCNIC_LINUX_MAJOR 5
 #define _QLCNIC_LINUX_MINOR 0
-#define _QLCNIC_LINUX_SUBVERSION 13
-#define QLCNIC_LINUX_VERSIONID  "5.0.13"
+#define _QLCNIC_LINUX_SUBVERSION 14
+#define QLCNIC_LINUX_VERSIONID  "5.0.14"
 #define QLCNIC_DRV_IDC_VER  0x01
 #define QLCNIC_DRIVER_VERSION  ((_QLCNIC_LINUX_MAJOR << 16) |\
 		 (_QLCNIC_LINUX_MINOR << 8) | (_QLCNIC_LINUX_SUBVERSION))
diff --git a/drivers/net/qlcnic/qlcnic_main.c b/drivers/net/qlcnic/qlcnic_main.c
index 788850e..11e3a46 100644
--- a/drivers/net/qlcnic/qlcnic_main.c
+++ b/drivers/net/qlcnic/qlcnic_main.c
@@ -1468,7 +1468,6 @@ qlcnic_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 	uint8_t revision_id;
 	uint8_t pci_using_dac;
 	char brd_name[QLCNIC_MAX_BOARD_NAME_LEN];
-	u32 val;
 
 	err = pci_enable_device(pdev);
 	if (err)
@@ -1530,9 +1529,7 @@ qlcnic_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 	if (err)
 		goto err_out_iounmap;
 
-	val = QLCRD32(adapter, QLCNIC_CRB_DRV_ACTIVE);
-	if (QLC_DEV_CHECK_ACTIVE(val, adapter->portnum))
-		adapter->flags |= QLCNIC_NEED_FLR;
+	adapter->flags |= QLCNIC_NEED_FLR;
 
 	err = adapter->nic_ops->start_firmware(adapter);
 	if (err) {
-- 
1.7.3.2

