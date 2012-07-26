From: Andy Cress <andycress@gmail.com>
Subject: [PATCH 1/3] pch_gbe: fix transmit watchdog timeout
Date: Thu, 26 Jul 2012 11:59:07 -0400
Message-ID: <20120726155907.GB10287@telcoserv5>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vb0-f46.google.com ([209.85.212.46]:64441 "EHLO
	mail-vb0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752863Ab2GZP5e (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Jul 2012 11:57:34 -0400
Received: by vbbff1 with SMTP id ff1so1794597vbb.19
        for <netdev@vger.kernel.org>; Thu, 26 Jul 2012 08:57:34 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


An extended ping test with 6 vlans resulted in a driver oops with a
netdev transmit timeout.
Fix WATCHDOG_TIMEOUT to be more like e1000e at 5 * HZ, to avoid 
unnecessary transmit timeouts.

Signed-off-by: Andy Cress <andy.cress@us.kontron.com>

diff --git a/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c b/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c
index 4c04843..a746064 100644
--- a/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c
+++ b/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c
@@ -35,7 +35,7 @@ const char pch_driver_version[] = DRV_VERSION;
 #define DSC_INIT16			0xC000
 #define PCH_GBE_DMA_ALIGN		0
 #define PCH_GBE_DMA_PADDING		2
-#define PCH_GBE_WATCHDOG_PERIOD		(1 * HZ)	/* watchdog time */
+#define PCH_GBE_WATCHDOG_PERIOD		(5 * HZ)	/* watchdog time */
 #define PCH_GBE_COPYBREAK_DEFAULT	256
 #define PCH_GBE_PCI_BAR			1
 #define PCH_GBE_RESERVE_MEMORY		0x200000	/* 2MB */
