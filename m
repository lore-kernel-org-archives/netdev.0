From: Jason Gerard DeRose <jason@system76.com>
Subject: [PATCH] ethernet/atheros/alx: add Killer E2400 device ID
Date: Tue, 17 Nov 2015 18:21:07 -0700
Message-ID: <1447809667-9454-1-git-send-email-jason@system76.com>
Cc: Ben Pope <benpope81@gmail.com>,
	Jason Gerard DeRose <jason@system76.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.system76.com ([38.75.196.72]:33306 "EHLO mail.system76.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751702AbbKRB3x (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 17 Nov 2015 20:29:53 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Pope <benpope81@gmail.com>

This patch adds the PCI device ID (0xe0a1) and alx_pci_tbl entry for the
Killer E2400 Ethernet controller, modeled after the Killer E2200
controller support (0xe091) already present in the alx driver.

This patch was originally authored by Ben Pope, but it got held up by
issues in the commit message, so I'm resubmitting it on his behalf.

I've extensively used a kernel with this patch on a System76 serw9
laptop and am quite confident it works well (at least on the hardware I
have available for testing).

Note that as a favor to System76, Ubuntu has been carrying this as a
sauce patch in their 4.2 based Wily kernel, which presumably has given
it real-world testing on other E2400 equipped hardware (I don't know of
any Ubuntu kernel bugs filed about it):

https://bugs.launchpad.net/ubuntu/+source/linux/+bug/1498633

Signed-off-by: Jason Gerard DeRose <jason@system76.com>
---
 drivers/net/ethernet/atheros/alx/main.c | 2 ++
 drivers/net/ethernet/atheros/alx/reg.h  | 1 +
 2 files changed, 3 insertions(+)

diff --git a/drivers/net/ethernet/atheros/alx/main.c b/drivers/net/ethernet/atheros/alx/main.c
index c8af3ce..bd377a6 100644
--- a/drivers/net/ethernet/atheros/alx/main.c
+++ b/drivers/net/ethernet/atheros/alx/main.c
@@ -1534,6 +1534,8 @@ static const struct pci_device_id alx_pci_tbl[] = {
 	  .driver_data = ALX_DEV_QUIRK_MSI_INTX_DISABLE_BUG },
 	{ PCI_VDEVICE(ATTANSIC, ALX_DEV_ID_E2200),
 	  .driver_data = ALX_DEV_QUIRK_MSI_INTX_DISABLE_BUG },
+	{ PCI_VDEVICE(ATTANSIC, ALX_DEV_ID_E2400),
+	  .driver_data = ALX_DEV_QUIRK_MSI_INTX_DISABLE_BUG },
 	{ PCI_VDEVICE(ATTANSIC, ALX_DEV_ID_AR8162),
 	  .driver_data = ALX_DEV_QUIRK_MSI_INTX_DISABLE_BUG },
 	{ PCI_VDEVICE(ATTANSIC, ALX_DEV_ID_AR8171) },
diff --git a/drivers/net/ethernet/atheros/alx/reg.h b/drivers/net/ethernet/atheros/alx/reg.h
index af006b4..0959e68 100644
--- a/drivers/net/ethernet/atheros/alx/reg.h
+++ b/drivers/net/ethernet/atheros/alx/reg.h
@@ -37,6 +37,7 @@
 
 #define ALX_DEV_ID_AR8161				0x1091
 #define ALX_DEV_ID_E2200				0xe091
+#define ALX_DEV_ID_E2400				0xe0a1
 #define ALX_DEV_ID_AR8162				0x1090
 #define ALX_DEV_ID_AR8171				0x10A1
 #define ALX_DEV_ID_AR8172				0x10A0
-- 
2.5.0
