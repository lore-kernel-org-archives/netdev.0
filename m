From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH 05/27] sfc: Remove boards.h, moving last remaining
	declaration to falcon.h
Date: Fri, 23 Oct 2009 19:29:51 +0100
Message-ID: <1256322591.2785.13.camel@achroite>
References: <1256322441.2785.3.camel@achroite>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:8576 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752809AbZJWS3u (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Oct 2009 14:29:50 -0400
In-Reply-To: <1256322441.2785.3.camel@achroite>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/sfc/boards.h        |   15 ---------------
 drivers/net/sfc/falcon.c        |    1 -
 drivers/net/sfc/falcon.h        |    2 ++
 drivers/net/sfc/falcon_boards.c |    1 -
 drivers/net/sfc/falcon_xmac.c   |    1 -
 drivers/net/sfc/mdio_10g.c      |    1 -
 drivers/net/sfc/mdio_10g.h      |    1 -
 drivers/net/sfc/selftest.c      |    1 -
 drivers/net/sfc/tenxpress.c     |    1 -
 9 files changed, 2 insertions(+), 22 deletions(-)
 delete mode 100644 drivers/net/sfc/boards.h

diff --git a/drivers/net/sfc/boards.h b/drivers/net/sfc/boards.h
deleted file mode 100644
index aaa72b0..0000000
--- a/drivers/net/sfc/boards.h
+++ /dev/null
@@ -1,15 +0,0 @@
-/****************************************************************************
- * Driver for Solarflare Solarstorm network controllers and boards
- * Copyright 2007-2008 Solarflare Communications Inc.
- *
- * This program is free software; you can redistribute it and/or modify it
- * under the terms of the GNU General Public License version 2 as published
- * by the Free Software Foundation, incorporated herein by reference.
- */
-
-#ifndef EFX_BOARDS_H
-#define EFX_BOARDS_H
-
-extern void falcon_probe_board(struct efx_nic *efx, u16 revision_info);
-
-#endif
diff --git a/drivers/net/sfc/falcon.c b/drivers/net/sfc/falcon.c
index abc6b63..eed8d1f 100644
--- a/drivers/net/sfc/falcon.c
+++ b/drivers/net/sfc/falcon.c
@@ -26,7 +26,6 @@
 #include "falcon_io.h"
 #include "mdio_10g.h"
 #include "phy.h"
-#include "boards.h"
 #include "workarounds.h"
 
 /* Falcon hardware control.
diff --git a/drivers/net/sfc/falcon.h b/drivers/net/sfc/falcon.h
index 77f2e0d..8d232bf 100644
--- a/drivers/net/sfc/falcon.h
+++ b/drivers/net/sfc/falcon.h
@@ -39,6 +39,8 @@ extern struct efx_nic_type falcon_b_nic_type;
  **************************************************************************
  */
 
+extern void falcon_probe_board(struct efx_nic *efx, u16 revision_info);
+
 /* TX data path */
 extern int falcon_probe_tx(struct efx_tx_queue *tx_queue);
 extern void falcon_init_tx(struct efx_tx_queue *tx_queue);
diff --git a/drivers/net/sfc/falcon_boards.c b/drivers/net/sfc/falcon_boards.c
index cae1656..ab94075 100644
--- a/drivers/net/sfc/falcon_boards.c
+++ b/drivers/net/sfc/falcon_boards.c
@@ -11,7 +11,6 @@
 
 #include "net_driver.h"
 #include "phy.h"
-#include "boards.h"
 #include "efx.h"
 #include "falcon.h"
 #include "falcon_hwdefs.h"
diff --git a/drivers/net/sfc/falcon_xmac.c b/drivers/net/sfc/falcon_xmac.c
index bec52ca..b486a2b 100644
--- a/drivers/net/sfc/falcon_xmac.c
+++ b/drivers/net/sfc/falcon_xmac.c
@@ -17,7 +17,6 @@
 #include "mac.h"
 #include "mdio_10g.h"
 #include "phy.h"
-#include "boards.h"
 #include "workarounds.h"
 
 /**************************************************************************
diff --git a/drivers/net/sfc/mdio_10g.c b/drivers/net/sfc/mdio_10g.c
index 6c33459..b355872 100644
--- a/drivers/net/sfc/mdio_10g.c
+++ b/drivers/net/sfc/mdio_10g.c
@@ -14,7 +14,6 @@
 #include <linux/delay.h>
 #include "net_driver.h"
 #include "mdio_10g.h"
-#include "boards.h"
 #include "workarounds.h"
 
 unsigned efx_mdio_id_oui(u32 id)
diff --git a/drivers/net/sfc/mdio_10g.h b/drivers/net/sfc/mdio_10g.h
index 6b14421..75b37f1 100644
--- a/drivers/net/sfc/mdio_10g.h
+++ b/drivers/net/sfc/mdio_10g.h
@@ -17,7 +17,6 @@
  */
 
 #include "efx.h"
-#include "boards.h"
 
 static inline unsigned efx_mdio_id_rev(u32 id) { return id & 0xf; }
 static inline unsigned efx_mdio_id_model(u32 id) { return (id >> 4) & 0x3f; }
diff --git a/drivers/net/sfc/selftest.c b/drivers/net/sfc/selftest.c
index 817c7ef..4a7be1c 100644
--- a/drivers/net/sfc/selftest.c
+++ b/drivers/net/sfc/selftest.c
@@ -24,7 +24,6 @@
 #include "efx.h"
 #include "falcon.h"
 #include "selftest.h"
-#include "boards.h"
 #include "workarounds.h"
 #include "spi.h"
 #include "falcon_io.h"
diff --git a/drivers/net/sfc/tenxpress.c b/drivers/net/sfc/tenxpress.c
index 352cc56..f5797a3 100644
--- a/drivers/net/sfc/tenxpress.c
+++ b/drivers/net/sfc/tenxpress.c
@@ -15,7 +15,6 @@
 #include "falcon.h"
 #include "phy.h"
 #include "falcon_hwdefs.h"
-#include "boards.h"
 #include "workarounds.h"
 #include "selftest.h"
 

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

