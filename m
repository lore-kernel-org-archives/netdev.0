From: Shahed Shaikh <shahed.shaikh@qlogic.com>
Subject: [PATCH net-next 10/12] qlcnic: qlcnic_get_board_name() function cleanup
Date: Fri, 24 May 2013 03:04:34 -0400
Message-ID: <1369379076-4718-11-git-send-email-shahed.shaikh@qlogic.com>
References: <1369379076-4718-1-git-send-email-shahed.shaikh@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <Dept_NX_Linux_NIC_Driver@qlogic.com>,
	Manish Chopra <manish.chopra@qlogic.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from co9ehsobe001.messaging.microsoft.com ([207.46.163.24]:14827
	"EHLO co9outboundpool.messaging.microsoft.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1759944Ab3EXHaI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 May 2013 03:30:08 -0400
In-Reply-To: <1369379076-4718-1-git-send-email-shahed.shaikh@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Manish Chopra <manish.chopra@qlogic.com>

Signed-off-by: Manish Chopra <manish.chopra@qlogic.com>
Signed-off-by: Shahed Shaikh <shahed.shaikh@qlogic.com>
---
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c |   37 ++++++++++++++++-----
 1 files changed, 28 insertions(+), 9 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
index bf78903..535c53f 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
@@ -867,6 +867,27 @@ static int qlcnic_setup_pci_map(struct pci_dev *pdev,
 	return 0;
 }
 
+static inline bool qlcnic_validate_subsystem_id(struct qlcnic_adapter *adapter,
+						int index)
+{
+	struct pci_dev *pdev = adapter->pdev;
+	unsigned short subsystem_vendor;
+	bool ret = true;
+
+	subsystem_vendor = pdev->subsystem_vendor;
+
+	if (pdev->device == PCI_DEVICE_ID_QLOGIC_QLE824X ||
+	    pdev->device == PCI_DEVICE_ID_QLOGIC_QLE834X) {
+		if (qlcnic_boards[index].sub_vendor == subsystem_vendor &&
+		    qlcnic_boards[index].sub_device == pdev->subsystem_device)
+			ret = true;
+		else
+			ret = false;
+	}
+
+	return ret;
+}
+
 static void qlcnic_get_board_name(struct qlcnic_adapter *adapter, char *name)
 {
 	struct pci_dev *pdev = adapter->pdev;
@@ -874,20 +895,18 @@ static void qlcnic_get_board_name(struct qlcnic_adapter *adapter, char *name)
 
 	for (i = 0; i < NUM_SUPPORTED_BOARDS; ++i) {
 		if (qlcnic_boards[i].vendor == pdev->vendor &&
-			qlcnic_boards[i].device == pdev->device &&
-			qlcnic_boards[i].sub_vendor == pdev->subsystem_vendor &&
-			qlcnic_boards[i].sub_device == pdev->subsystem_device) {
-				sprintf(name, "%pM: %s" ,
-					adapter->mac_addr,
-					qlcnic_boards[i].short_name);
-				found = 1;
-				break;
+		    qlcnic_boards[i].device == pdev->device &&
+		    qlcnic_validate_subsystem_id(adapter, i)) {
+			found = 1;
+			break;
 		}
-
 	}
 
 	if (!found)
 		sprintf(name, "%pM Gigabit Ethernet", adapter->mac_addr);
+	else
+		sprintf(name, "%pM: %s" , adapter->mac_addr,
+			qlcnic_boards[i].short_name);
 }
 
 static void
-- 
1.5.6
