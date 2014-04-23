From: Shahed Shaikh <shahed.shaikh@qlogic.com>
Subject: [PATCH net 1/2] qlcnic: Reset firmware API lock at driver load time
Date: Wed, 23 Apr 2014 09:59:55 -0400
Message-ID: <1398261596-7296-2-git-send-email-shahed.shaikh@qlogic.com>
References: <1398261596-7296-1-git-send-email-shahed.shaikh@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <Dept-HSGLinuxNICDev@qlogic.com>,
	Sony Chacko <sony.chacko@qlogic.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-0016ce01.pphosted.com ([67.231.156.153]:46333 "EHLO
	mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751620AbaDWOh5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Apr 2014 10:37:57 -0400
In-Reply-To: <1398261596-7296-1-git-send-email-shahed.shaikh@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sony Chacko <sony.chacko@qlogic.com>

Some firmware versions fails to reset the lock during
initialization. Force reset firmware API lock during driver
probe to ensure lock availability.

Signed-off-by: Sony Chacko <sony.chacko@qlogic.com>
Signed-off-by: Shahed Shaikh <shahed.shaikh@qlogic.com>
---
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c |    9 +++++++++
 1 files changed, 9 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
index dbf7539..0bc9148 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
@@ -2374,6 +2374,14 @@ void qlcnic_set_drv_version(struct qlcnic_adapter *adapter)
 		qlcnic_fw_cmd_set_drv_version(adapter, fw_cmd);
 }
 
+/* Reset firmware API lock */
+static void qlcnic_reset_api_lock(struct qlcnic_adapter *adapter)
+{
+	qlcnic_api_lock(adapter);
+	qlcnic_api_unlock(adapter);
+}
+
+
 static int
 qlcnic_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 {
@@ -2476,6 +2484,7 @@ qlcnic_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 	if (qlcnic_82xx_check(adapter)) {
 		qlcnic_check_vf(adapter, ent);
 		adapter->portnum = adapter->ahw->pci_func;
+		qlcnic_reset_api_lock(adapter);
 		err = qlcnic_start_firmware(adapter);
 		if (err) {
 			dev_err(&pdev->dev, "Loading fw failed.Please Reboot\n"
-- 
1.5.6
