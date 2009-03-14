From: Dhananjay Phadke <dhananjay@netxen.com>
Subject: [patch next 1/6] netxen: fix endianness in serial number
Date: Fri, 13 Mar 2009 17:52:01 -0700
Message-ID: <1236991926-17892-2-git-send-email-dhananjay@netxen.com>
References: <1236991926-17892-1-git-send-email-dhananjay@netxen.com>
Cc: davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from nxgate.netxen.com ([38.99.60.130]:47272 "EHLO unm84.unmin.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1762940AbZCNAwO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 13 Mar 2009 20:52:14 -0400
In-Reply-To: <1236991926-17892-1-git-send-email-dhananjay@netxen.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Dhananjay Phadke <dhananjay@netxen.com>
---
 drivers/net/netxen/netxen_nic_hw.c |   10 ++++------
 1 files changed, 4 insertions(+), 6 deletions(-)

diff --git a/drivers/net/netxen/netxen_nic_hw.c b/drivers/net/netxen/netxen_nic_hw.c
index a93ab58..8db4ac3 100644
--- a/drivers/net/netxen/netxen_nic_hw.c
+++ b/drivers/net/netxen/netxen_nic_hw.c
@@ -2268,7 +2268,7 @@ void netxen_nic_get_firmware_info(struct netxen_adapter *adapter)
 	u32 fw_major, fw_minor, fw_build;
 	char brd_name[NETXEN_MAX_SHORT_NAME];
 	char serial_num[32];
-	int i, addr;
+	int i, addr, val;
 	int *ptr32;
 	struct pci_dev *pdev = adapter->pdev;
 
@@ -2278,14 +2278,12 @@ void netxen_nic_get_firmware_info(struct netxen_adapter *adapter)
 	addr = NETXEN_USER_START +
 	       offsetof(struct netxen_new_user_info, serial_num);
 	for (i = 0; i < 8; i++) {
-		if (netxen_rom_fast_read(adapter, addr, ptr32) == -1) {
-			printk("%s: ERROR reading %s board userarea.\n",
-			       netxen_nic_driver_name,
-			       netxen_nic_driver_name);
+		if (netxen_rom_fast_read(adapter, addr, &val) == -1) {
+			dev_err(&pdev->dev, "error reading board info\n");
 			adapter->driver_mismatch = 1;
 			return;
 		}
-		ptr32++;
+		ptr32[i] = cpu_to_le32(val);
 		addr += sizeof(u32);
 	}
 
-- 
1.6.0.2

