From: David Miller <davem@davemloft.net>
Subject: [PATCH] pch_gbe: Fix PTP dependencies.
Date: Tue, 02 Oct 2012 22:35:04 -0400 (EDT)
Message-ID: <20121002.223504.1130795240955330652.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53101 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751264Ab2JCCfF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Oct 2012 22:35:05 -0400
Received: from localhost (cpe-66-108-116-58.nyc.res.rr.com [66.108.116.58])
	by shards.monkeyblade.net (Postfix) with ESMTPSA id CB66558865F
	for <netdev@vger.kernel.org>; Tue,  2 Oct 2012 19:35:07 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


The config combination:

        CONFIG_PCH_GBE=y
        CONFIG_PCH_PTP=y
        CONFIG_PTP_1588_CLOCK=m

doesn't work, because then you have a built-in kernel
object (the PCH_PTP code) referring to symbols in a
module (PTP_1588_CLOCK).

Fix this like IXGBE, by using "select PTP_1588_CLOCK"
instead of a "depends on".

Reported-by: Haicheng Li <haicheng.li@linux.intel.com>
Signed-off-by: David S. Miller <davem@davemloft.net>
---
 drivers/net/ethernet/oki-semi/pch_gbe/Kconfig | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/oki-semi/pch_gbe/Kconfig b/drivers/net/ethernet/oki-semi/pch_gbe/Kconfig
index bce0164..9730241 100644
--- a/drivers/net/ethernet/oki-semi/pch_gbe/Kconfig
+++ b/drivers/net/ethernet/oki-semi/pch_gbe/Kconfig
@@ -26,7 +26,7 @@ if PCH_GBE
 config PCH_PTP
 	bool "PCH PTP clock support"
 	default n
-	depends on PTP_1588_CLOCK_PCH
+	select PTP_1588_CLOCK_PCH
 	---help---
 	  Say Y here if you want to use Precision Time Protocol (PTP) in the
 	  driver. PTP is a method to precisely synchronize distributed clocks
-- 
1.7.11.4
