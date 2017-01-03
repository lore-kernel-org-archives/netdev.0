From: Nicolas Pitre <nicolas.pitre@linaro.org>
Subject: [PATCH] LiquidIO VF: s/select/imply/ for PTP_1588_CLOCK
Date: Tue, 3 Jan 2017 13:57:00 -0500 (EST)
Message-ID: <alpine.LFD.2.20.1701031331450.21662@knanqh.ubzr>
References: <20170103101105.GA24780@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: netdev@vger.kernel.org
To: Richard Cochran <richardcochran@gmail.com>,
        Raghu Vatsavayi <rvatsavayi@caviumnetworks.com>,
        "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f53.google.com ([209.85.214.53]:38744 "EHLO
        mail-it0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S965460AbdACS5U (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 3 Jan 2017 13:57:20 -0500
Received: by mail-it0-f53.google.com with SMTP id x2so304478733itf.1
        for <netdev@vger.kernel.org>; Tue, 03 Jan 2017 10:57:20 -0800 (PST)
In-Reply-To: <20170103101105.GA24780@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fix a minor fallout from the merge of the timers and the networking 
trees. The following error may result if the PTP_1588_CLOCK 
prerequisites are not available:

drivers/built-in.o: In function `ptp_clock_unregister':
(.text+0x40e0a5): undefined reference to `pps_unregister_source'
drivers/built-in.o: In function `ptp_clock_unregister':
(.text+0x40e0cc): undefined reference to `posix_clock_unregister'
drivers/built-in.o: In function `ptp_clock_event':
(.text+0x40e249): undefined reference to `pps_event'
drivers/built-in.o: In function `ptp_clock_register':
(.text+0x40e5e1): undefined reference to `pps_register_source'
drivers/built-in.o: In function `ptp_clock_register':
(.text+0x40e62c): undefined reference to `posix_clock_register'
drivers/built-in.o: In function `ptp_clock_register':
(.text+0x40e68d): undefined reference to `pps_unregister_source'

Signed-off-by: Nicolas Pitre <nico@linaro.org>

diff --git a/drivers/net/ethernet/cavium/Kconfig b/drivers/net/ethernet/cavium/Kconfig
index bbc8bd16cb..dcbce6cac6 100644
--- a/drivers/net/ethernet/cavium/Kconfig
+++ b/drivers/net/ethernet/cavium/Kconfig
@@ -77,7 +77,7 @@ config OCTEON_MGMT_ETHERNET
 config LIQUIDIO_VF
 	tristate "Cavium LiquidIO VF support"
 	depends on 64BIT && PCI_MSI
-	select PTP_1588_CLOCK
+	imply PTP_1588_CLOCK
 	---help---
 	  This driver supports Cavium LiquidIO Intelligent Server Adapter
 	  based on CN23XX chips.
