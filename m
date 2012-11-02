From: Richard Cochran <richardcochran@gmail.com>
Subject: [PATCH net-next] ptp: fixup Kconfig for two PHC drivers.
Date: Fri,  2 Nov 2012 10:57:38 +0100
Message-ID: <1351850258-5072-1-git-send-email-richardcochran@gmail.com>
Cc: David Miller <davem@davemloft.net>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ea0-f174.google.com ([209.85.215.174]:36247 "EHLO
	mail-ea0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965850Ab2KBJ5t (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Nov 2012 05:57:49 -0400
Received: by mail-ea0-f174.google.com with SMTP id c13so1307182eaa.19
        for <netdev@vger.kernel.org>; Fri, 02 Nov 2012 02:57:48 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ben Hutchings recently came up with a better way to handle the kconfig
dependencies for the PTP hardware clocks. This patch converts one new and
one older driver to the new scheme.

Signed-off-by: Richard Cochran <richardcochran@gmail.com>
---
 drivers/net/ethernet/adi/Kconfig |    2 +-
 drivers/net/ethernet/ti/Kconfig  |    2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/adi/Kconfig b/drivers/net/ethernet/adi/Kconfig
index 175c38c..e49c0ef 100644
--- a/drivers/net/ethernet/adi/Kconfig
+++ b/drivers/net/ethernet/adi/Kconfig
@@ -61,7 +61,7 @@ config BFIN_RX_DESC_NUM
 
 config BFIN_MAC_USE_HWSTAMP
 	bool "Use IEEE 1588 hwstamp"
-	depends on BFIN_MAC && BF518 && PTP_1588_CLOCK && !(BFIN_MAC=y && PTP_1588_CLOCK=m)
+	select PTP_1588_CLOCK
 	default y
 	---help---
 	  To support the IEEE 1588 Precision Time Protocol (PTP), select y here
diff --git a/drivers/net/ethernet/ti/Kconfig b/drivers/net/ethernet/ti/Kconfig
index cbc3905..14297ff 100644
--- a/drivers/net/ethernet/ti/Kconfig
+++ b/drivers/net/ethernet/ti/Kconfig
@@ -62,7 +62,7 @@ config TI_CPSW
 
 config TI_CPTS
 	boolean "TI Common Platform Time Sync (CPTS) Support"
-	depends on TI_CPSW && PTP_1588_CLOCK && !(TI_CPSW=y && PTP_1588_CLOCK=m)
+	select PTP_1588_CLOCK
 	---help---
 	  This driver supports the Common Platform Time Sync unit of
 	  the CPSW Ethernet Switch. The unit can time stamp PTP UDP/IPv4
-- 
1.7.2.5
