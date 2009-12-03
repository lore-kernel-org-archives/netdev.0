From: Marcel Holtmann <marcel@holtmann.org>
Subject: [PATCH 03/18] Bluetooth: Remove unused global minor variable
Date: Thu,  3 Dec 2009 19:45:40 +0100
Message-ID: <329ab1b3e6ceac3f77ab400206a97cc402624259.1259865280.git.marcel@holtmann.org>
References: <cover.1259865279.git.marcel@holtmann.org>
 <b3cf652afb5404685e3d7ed6780a8d1fa10e21da.1259865280.git.marcel@holtmann.org>
 <5990108cfcd3eb2d365c9ea6f82318be80c4e9d3.1259865280.git.marcel@holtmann.org>
Cc: netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from senator.holtmann.net ([87.106.208.187]:37647 "EHLO
	mail.holtmann.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756505AbZLCSpz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Dec 2009 13:45:55 -0500
In-Reply-To: <5990108cfcd3eb2d365c9ea6f82318be80c4e9d3.1259865280.git.marcel@holtmann.org>
In-Reply-To: <cover.1259865279.git.marcel@holtmann.org>
References: <cover.1259865279.git.marcel@holtmann.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

After the removal of the module parameter for setting the minor number,
this variable became unused. So just remove it.

Signed-off-by: Marcel Holtmann <marcel@holtmann.org>
---
 drivers/bluetooth/hci_vhci.c |   12 ++----------
 1 files changed, 2 insertions(+), 10 deletions(-)

diff --git a/drivers/bluetooth/hci_vhci.c b/drivers/bluetooth/hci_vhci.c
index ff02e90..c1d389f 100644
--- a/drivers/bluetooth/hci_vhci.c
+++ b/drivers/bluetooth/hci_vhci.c
@@ -41,8 +41,6 @@
 
 #define VERSION "1.3"
 
-static int minor = MISC_DYNAMIC_MINOR;
-
 struct vhci_data {
 	struct hci_dev *hdev;
 
@@ -295,18 +293,12 @@ static int __init vhci_init(void)
 {
 	BT_INFO("Virtual HCI driver ver %s", VERSION);
 
-	if (misc_register(&vhci_miscdev) < 0) {
-		BT_ERR("Can't register misc device with minor %d", minor);
-		return -EIO;
-	}
-
-	return 0;
+	return misc_register(&vhci_miscdev);
 }
 
 static void __exit vhci_exit(void)
 {
-	if (misc_deregister(&vhci_miscdev) < 0)
-		BT_ERR("Can't unregister misc device with minor %d", minor);
+	misc_deregister(&vhci_miscdev);
 }
 
 module_init(vhci_init);
-- 
1.6.5.2

