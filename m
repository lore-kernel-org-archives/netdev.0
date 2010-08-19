From: Amit Kumar Salecha <amit.salecha@qlogic.com>
Subject: [PATCH NEXT 02/12] qlcnic: remove unused code
Date: Thu, 19 Aug 2010 08:08:23 -0700
Message-ID: <1282230513-25286-3-git-send-email-amit.salecha@qlogic.com>
References: <1282230513-25286-1-git-send-email-amit.salecha@qlogic.com>
Cc: netdev@vger.kernel.org, ameen.rahman@qlogic.com,
	anirban.chakraborty@qlogic.com,
	Sony Chacko <sony.chacko@qlogic.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mvnat01.qlogic.com ([198.186.3.73]:32530 "HELO unm84.unmin.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with SMTP
	id S1752814Ab0HSPIe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 19 Aug 2010 11:08:34 -0400
In-Reply-To: <1282230513-25286-1-git-send-email-amit.salecha@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sony Chacko <sony.chacko@qlogic.com>

Serial number references are not used in driver.

Signed-off-by: Sony Chacko <sony.chacko@qlogic.com>
---
 drivers/net/qlcnic/qlcnic.h      |    1 -
 drivers/net/qlcnic/qlcnic_main.c |   19 -------------------
 2 files changed, 0 insertions(+), 20 deletions(-)

diff --git a/drivers/net/qlcnic/qlcnic.h b/drivers/net/qlcnic/qlcnic.h
index f6b887d..5c549c5 100644
--- a/drivers/net/qlcnic/qlcnic.h
+++ b/drivers/net/qlcnic/qlcnic.h
@@ -933,7 +933,6 @@ struct qlcnic_adapter {
 
 	u8 max_rds_rings;
 	u8 max_sds_rings;
-	u8 driver_mismatch;
 	u8 msix_supported;
 	u8 rx_csum;
 	u8 portnum;
diff --git a/drivers/net/qlcnic/qlcnic_main.c b/drivers/net/qlcnic/qlcnic_main.c
index 384cc52..beadf2e 100644
--- a/drivers/net/qlcnic/qlcnic_main.c
+++ b/drivers/net/qlcnic/qlcnic_main.c
@@ -709,24 +709,8 @@ qlcnic_check_options(struct qlcnic_adapter *adapter)
 {
 	u32 fw_major, fw_minor, fw_build;
 	char brd_name[QLCNIC_MAX_BOARD_NAME_LEN];
-	char serial_num[32];
-	int i, offset, val;
-	int *ptr32;
 	struct pci_dev *pdev = adapter->pdev;
 	struct qlcnic_info nic_info;
-	adapter->driver_mismatch = 0;
-
-	ptr32 = (int *)&serial_num;
-	offset = QLCNIC_FW_SERIAL_NUM_OFFSET;
-	for (i = 0; i < 8; i++) {
-		if (qlcnic_rom_fast_read(adapter, offset, &val) == -1) {
-			dev_err(&pdev->dev, "error reading board info\n");
-			adapter->driver_mismatch = 1;
-			return;
-		}
-		ptr32[i] = cpu_to_le32(val);
-		offset += sizeof(u32);
-	}
 
 	fw_major = QLCRD32(adapter, QLCNIC_FW_VERSION_MAJOR);
 	fw_minor = QLCRD32(adapter, QLCNIC_FW_VERSION_MINOR);
@@ -1584,9 +1568,6 @@ static int qlcnic_open(struct net_device *netdev)
 	struct qlcnic_adapter *adapter = netdev_priv(netdev);
 	int err;
 
-	if (adapter->driver_mismatch)
-		return -EIO;
-
 	err = qlcnic_attach(adapter);
 	if (err)
 		return err;
-- 
1.6.0.2

