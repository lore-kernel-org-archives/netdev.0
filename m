From: Amit Kumar Salecha <amit.salecha@qlogic.com>
Subject: [PATCH NEXT 2/7] qlcnic: change adapter name display
Date: Mon, 17 May 2010 04:22:09 -0700
Message-ID: <1274095334-32362-3-git-send-email-amit.salecha@qlogic.com>
References: <1274095334-32362-1-git-send-email-amit.salecha@qlogic.com>
Cc: netdev@vger.kernel.org, ameen.rahman@qlogic.com,
	Sucheta Chakraborty <sucheta.chakraborty@qlogic.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mvnat01.qlogic.com ([198.186.3.73]:52816 "EHLO
	dut4145.unminc.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753304Ab0EQKVv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 May 2010 06:21:51 -0400
In-Reply-To: <1274095334-32362-1-git-send-email-amit.salecha@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sucheta Chakraborty <sucheta.chakraborty@qlogic.com>

Append mac address to adapter name.

Signed-off-by: Sucheta Chakraborty <sucheta.chakraborty@qlogic.com>
Signed-off-by: Amit Kumar Salecha <amit.salecha@qlogic.com>
---
 drivers/net/qlcnic/qlcnic_main.c |    7 ++++++-
 1 files changed, 6 insertions(+), 1 deletions(-)

diff --git a/drivers/net/qlcnic/qlcnic_main.c b/drivers/net/qlcnic/qlcnic_main.c
index f1949c9..db05635 100644
--- a/drivers/net/qlcnic/qlcnic_main.c
+++ b/drivers/net/qlcnic/qlcnic_main.c
@@ -495,7 +495,9 @@ static void get_brd_name(struct qlcnic_adapter *adapter, char *name)
 			qlcnic_boards[i].device == pdev->device &&
 			qlcnic_boards[i].sub_vendor == pdev->subsystem_vendor &&
 			qlcnic_boards[i].sub_device == pdev->subsystem_device) {
-				strcpy(name, qlcnic_boards[i].short_name);
+				sprintf(name, "%pM: %s" ,
+					adapter->mac_addr,
+					qlcnic_boards[i].short_name);
 				found = 1;
 				break;
 		}
@@ -1083,6 +1085,9 @@ qlcnic_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 		goto err_out_iounmap;
 	}
 
+	if (qlcnic_read_mac_addr(adapter))
+		dev_warn(&pdev->dev, "failed to read mac addr\n");
+
 	if (qlcnic_setup_idc_param(adapter))
 		goto err_out_iounmap;
 
-- 
1.5.6.1

