From: Namhyung Kim <namhyung@gmail.com>
Subject: [PATCH] 3c59x: fix build failure on !CONFIG_PCI
Date: Wed, 17 Nov 2010 00:27:51 +0900
Message-ID: <1289921271-15295-1-git-send-email-namhyung@gmail.com>
Cc: linux-kernel@vger.kernel.org
To: Steffen Klassert <klassert@mathematik.tu-chemnitz.de>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pv0-f174.google.com ([74.125.83.174]:64638 "EHLO
	mail-pv0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751079Ab0KPP1y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Nov 2010 10:27:54 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

VORTEX_PCI() could return NULL so it needs to be casted before
accessing any member of struct pci_dev. This fixes following
build failure. Likewise VORTEX_EISA() was changed also.

  CC [M]  drivers/net/3c59x.o
drivers/net/3c59x.c: In function 'acpi_set_WOL':
drivers/net/3c59x.c:3211:39: warning: dereferencing 'void *' pointer
drivers/net/3c59x.c:3211:39: error: request for member 'current_state' in something not a structure or union
make[3]: *** [drivers/net/3c59x.o] Error 1
make[2]: *** [drivers/net/3c59x.o] Error 2
make[1]: *** [sub-make] Error 2
make: *** [all] Error 2

Signed-off-by: Namhyung Kim <namhyung@gmail.com>
---
 drivers/net/3c59x.c |    6 ++++--
 1 files changed, 4 insertions(+), 2 deletions(-)

diff --git a/drivers/net/3c59x.c b/drivers/net/3c59x.c
index e1da258..0a92436 100644
--- a/drivers/net/3c59x.c
+++ b/drivers/net/3c59x.c
@@ -699,7 +699,8 @@ DEFINE_WINDOW_IO(32)
 #define DEVICE_PCI(dev) NULL
 #endif
 
-#define VORTEX_PCI(vp) (((vp)->gendev) ? DEVICE_PCI((vp)->gendev) : NULL)
+#define VORTEX_PCI(vp)							\
+	((struct pci_dev *) (((vp)->gendev) ? DEVICE_PCI((vp)->gendev) : NULL))
 
 #ifdef CONFIG_EISA
 #define DEVICE_EISA(dev) (((dev)->bus == &eisa_bus_type) ? to_eisa_device((dev)) : NULL)
@@ -707,7 +708,8 @@ DEFINE_WINDOW_IO(32)
 #define DEVICE_EISA(dev) NULL
 #endif
 
-#define VORTEX_EISA(vp) (((vp)->gendev) ? DEVICE_EISA((vp)->gendev) : NULL)
+#define VORTEX_EISA(vp)							\
+	((struct eisa_device *) (((vp)->gendev) ? DEVICE_EISA((vp)->gendev) : NULL))
 
 /* The action to take with a media selection timer tick.
    Note that we deviate from the 3Com order by checking 10base2 before AUI.
-- 
1.7.0.4

