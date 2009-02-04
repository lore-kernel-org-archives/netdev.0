From: Andy Fleming <afleming@freescale.com>
Subject: [PATCH v2.6.29 1/2] gianfar: Fix BD_LENGTH_MASK definition
Date: Tue,  3 Feb 2009 19:16:59 -0600
Message-ID: <1233710223-17808-1-git-send-email-afleming@freescale.com>
Cc: netdev@vger.kernel.org, Andy Fleming <afleming@freescale.com>
To: davem@davemloft.net, jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from az33egw02.freescale.net ([192.88.158.103]:57434 "EHLO
	az33egw02.freescale.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751572AbZBDBRW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Feb 2009 20:17:22 -0500
Received: from az33smr01.freescale.net (az33smr01.freescale.net [10.64.34.199])
	by az33egw02.freescale.net (8.14.3/az33egw02) with ESMTP id n141H4vd004692
	for <netdev@vger.kernel.org>; Tue, 3 Feb 2009 18:17:05 -0700 (MST)
Received: from ld0175-tx32.am.freescale.net (ld0175-tx32.am.freescale.net [10.82.19.125])
	by az33smr01.freescale.net (8.13.1/8.13.0) with ESMTP id n141H4EE019268
	for <netdev@vger.kernel.org>; Tue, 3 Feb 2009 19:17:04 -0600 (CST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

BD_LENGTH_MASK is supposed to catch the low 16-bits of the status field, not
the low byte.  The old way, we would never be able to clean up tx packets with
sizes divisible by 256.

Signed-off-by: Andy Fleming <afleming@freescale.com>
---
 drivers/net/gianfar.h |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/gianfar.h b/drivers/net/gianfar.h
index b1a8334..eaa8689 100644
--- a/drivers/net/gianfar.h
+++ b/drivers/net/gianfar.h
@@ -312,7 +312,7 @@ extern const char gfar_driver_version[];
 #define ATTRELI_EI(x) (x)
 
 #define BD_LFLAG(flags) ((flags) << 16)
-#define BD_LENGTH_MASK		0x00ff
+#define BD_LENGTH_MASK		0x0000ffff
 
 /* TxBD status field bits */
 #define TXBD_READY		0x8000
-- 
1.5.4.GIT

