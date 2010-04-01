From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Subject: [PATCH] stmmac: fix kconfig for crc32 build error
Date: Thu,  1 Apr 2010 09:44:03 +0200
Message-ID: <1270107844-23457-1-git-send-email-peppe.cavallaro@st.com>
Cc: Carmelo AMOROSO <carmelo.amoroso@st.com>,
	Giuseppe Cavallaro <peppe.cavallaro@st.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog116.obsmtp.com ([207.126.144.141]:42191 "EHLO
	eu1sys200aog116.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752522Ab0DAHoJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Apr 2010 03:44:09 -0400
Received: from zeta.dmz-eu.st.com (ns2.st.com [164.129.230.9])
	by beta.dmz-eu.st.com (STMicroelectronics) with ESMTP id 6B20EEC
	for <netdev@vger.kernel.org>; Thu,  1 Apr 2010 07:44:04 +0000 (GMT)
Received: from mail3.ctn.st.com (mail3.ctn.st.com [164.130.116.150])
	by zeta.dmz-eu.st.com (STMicroelectronics) with ESMTP id 52ED51095
	for <netdev@vger.kernel.org>; Thu,  1 Apr 2010 07:44:04 +0000 (GMT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Carmelo AMOROSO <carmelo.amoroso@st.com>

stmmac uses crc32 functions so it needs to select CRC32.

Fixes build error:
drivers/built-in.o: In function `dwmac1000_set_filter':
dwmac1000_core.c:(.text+0x3c380): undefined reference to `crc32_le'
dwmac1000_core.c:(.text+0x3c384): undefined reference to `bitrev32'

Signed-off-by: Carmelo Amoroso <carmelo.amoroso@st.com>
Signed-off-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>
---
 drivers/net/stmmac/Kconfig |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/drivers/net/stmmac/Kconfig b/drivers/net/stmmac/Kconfig
index fb28764..eb63d44 100644
--- a/drivers/net/stmmac/Kconfig
+++ b/drivers/net/stmmac/Kconfig
@@ -2,6 +2,7 @@ config STMMAC_ETH
 	tristate "STMicroelectronics 10/100/1000 Ethernet driver"
 	select MII
 	select PHYLIB
+	select CRC32
 	depends on NETDEVICES && CPU_SUBTYPE_ST40
 	help
 	  This is the driver for the Ethernet IPs are built around a
-- 
1.6.0.4

