From: Tobias Regnery <tobias.regnery@gmail.com>
Subject: [PATCH net-next 4/4] alx: add module parameter to enable msi-x support
Date: Fri,  9 Sep 2016 12:19:55 +0200
Message-ID: <238fe274d7fa76aefe08850a9bfba4478807ab6a.1473404402.git.tobias.regnery@gmail.com>
References: <cover.1473404399.git.tobias.regnery@gmail.com>
Cc: davem@davemloft.net, feng.tang@intel.com, jarod@redhat.com,
        Tobias Regnery <tobias.regnery@gmail.com>
To: netdev@vger.kernel.org, jcliburn@gmail.com, chris.snook@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f68.google.com ([74.125.82.68]:32800 "EHLO
        mail-wm0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753994AbcIIKUX (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 9 Sep 2016 06:20:23 -0400
Received: by mail-wm0-f68.google.com with SMTP id b187so2058377wme.0
        for <netdev@vger.kernel.org>; Fri, 09 Sep 2016 03:20:23 -0700 (PDT)
In-Reply-To: <cover.1473404399.git.tobias.regnery@gmail.com>
In-Reply-To: <cover.1473404399.git.tobias.regnery@gmail.com>
References: <cover.1473404399.git.tobias.regnery@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

msi-x support is default disabled in the alx driver. In order to test msi-x
interrupts for regressions add a module parameter to the driver.

Signed-off-by: Tobias Regnery <tobias.regnery@gmail.com>
---
 drivers/net/ethernet/atheros/alx/main.c | 5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/atheros/alx/main.c b/drivers/net/ethernet/atheros/alx/main.c
index a4f74d4a976c..9887cee434dd 100644
--- a/drivers/net/ethernet/atheros/alx/main.c
+++ b/drivers/net/ethernet/atheros/alx/main.c
@@ -51,6 +51,9 @@
 
 const char alx_drv_name[] = "alx";
 
+static bool msix = false;
+module_param(msix, bool, 0);
+MODULE_PARM_DESC(msix, "Enable msi-x interrupt support");
 
 static void alx_free_txbuf(struct alx_priv *alx, int entry)
 {
@@ -1018,7 +1021,7 @@ static int __alx_open(struct alx_priv *alx, bool resume)
 {
 	int err;
 
-	alx_init_intr(alx, false);
+	alx_init_intr(alx, msix);
 
 	if (!resume)
 		netif_carrier_off(alx->dev);
-- 
2.7.4
