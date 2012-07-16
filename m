From: "Andy Cress" <andy.cress@us.kontron.com>
Subject: [PATCH 2/4] pch_gbe: fix transmit watchdog timeout
Date: Mon, 16 Jul 2012 13:04:05 -0700
Message-ID: <40680C535D6FE6498883F1640FACD44D011432D7@ka-exchange-1.kontronamerica.local>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.kontron.com ([209.118.138.70]:46053 "EHLO
	mail.us.kontron.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751699Ab2GPUEK convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Jul 2012 16:04:10 -0400
Received: from ka-exchange-1.kontronamerica.local ([10.100.2.39]) by mail.us.kontron.com with ESMTP id 9IhDSKbsrEWHppKm for <netdev@vger.kernel.org>; Mon, 16 Jul 2012 13:04:09 -0700 (PDT)
Content-class: urn:content-classes:message
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Author: Andy Cress <andy.cress@us.kontron.com>

An extended ping test with 6 vlans resulted in a driver oops with a
netdev transmit timeout.
Fix WATCHDOG_TIMEOUT to be more like e1000e at 5 * HZ, to avoid
unnecessary transmit timeouts.

Signed-off-by: Andy Cress <andy.cress@us.kontron.com>

diff --git a/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c
b/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c
index 4c04843..a746064 100644
--- a/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c
+++ b/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c
@@ -35,7 +35,7 @@ const char pch_driver_version[] = DRV_VERSION;
 #define DSC_INIT16			0xC000
 #define PCH_GBE_DMA_ALIGN		0
 #define PCH_GBE_DMA_PADDING		2
-#define PCH_GBE_WATCHDOG_PERIOD		(1 * HZ)	/*
watchdog time */
+#define PCH_GBE_WATCHDOG_PERIOD		(5 * HZ)	/*
watchdog time */
 #define PCH_GBE_COPYBREAK_DEFAULT	256
 #define PCH_GBE_PCI_BAR			1
 #define PCH_GBE_RESERVE_MEMORY		0x200000	/* 2MB */
