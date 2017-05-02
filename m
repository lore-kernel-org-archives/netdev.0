From: jake Briggs <nexussix@gmail.com>
Subject: [PATCH] Fix for new version of realtek r8153
Date: Wed,  3 May 2017 11:20:48 +1200
Message-ID: <20170502232048.9153-1-nexussix@gmail.com>
Cc: jake <jake@rabidtech.co.nz>
To: hayeswang@realtek.com, mario_limonciello@dell.com,
        linux-usb@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: jake <jake@rabidtech.co.nz>

Fix for new version of realtek r8153 not being recognised by the r8152
driver. The new version of the device with idVendor=0bda, idProduct=8153 is 6010 and treating it as if it was a 5c30 allow it to work.

Error log:

Apr 19 09:55:13 devotron kernel: [  330.167074] usb 2-2.2: New USB
device found, idVendor=0bda, idProduct=8153
Apr 19 09:55:13 devotron kernel: [  330.167078] usb 2-2.2: New USB
device strings: Mfr=1, Product=2, SerialNumber=6
Apr 19 09:55:13 devotron kernel: [  330.167080] usb 2-2.2: Product: USB
10/100/1000 LAN
Apr 19 09:55:13 devotron kernel: [  330.167081] usb 2-2.2: Manufacturer:
Realtek
Apr 19 09:55:13 devotron kernel: [  330.167083] usb 2-2.2: SerialNumber:
001000001
Apr 19 09:55:13 devotron kernel: [  330.258781] usb 2-2.2: reset
SuperSpeed USB device number 5 using xhci_hcd
Apr 19 09:55:13 devotron kernel: [  330.279430] r8152 2-2.2:1.0 (unnamed
net_device) (uninitialized): Unknown version 0x6010
Apr 19 09:55:13 devotron kernel: [  330.279434] r8152 2-2.2:1.0 (unnamed
net_device) (uninitialized): Unknown Device

Signed-off-by: jake <jake@rabidtech.co.nz>
---
 drivers/net/usb/r8152.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/usb/r8152.c b/drivers/net/usb/r8152.c
index 07f788c49d57..2a55459fdfac 100644
--- a/drivers/net/usb/r8152.c
+++ b/drivers/net/usb/r8152.c
@@ -4277,6 +4277,7 @@ static void r8152b_get_version(struct r8152 *tp)
 		tp->mii.supports_gmii = 1;
 		break;
 	case 0x5c30:
+	case 0x6010:	
 		tp->version = RTL_VER_06;
 		tp->mii.supports_gmii = 1;
 		break;
-- 
2.11.0
