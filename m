From: Sonic Zhang <sonic.adi@gmail.com>
Subject: [PATCH] driver:stmmac: Adjust time stamp increase for 0.465 ns accurate only when Time stamp binary rollover is set.
Date: Tue, 3 Sep 2013 13:55:07 +0800
Message-ID: <1378187707-17928-1-git-send-email-sonic.adi@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <adi-buildroot-devel@lists.sourceforge.net>,
	Sonic Zhang <sonic.zhang@analog.com>
To: Giuseppe Cavallaro <peppe.cavallaro@st.com>,
	<netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-db8lp0188.outbound.messaging.microsoft.com ([213.199.154.188]:33169
	"EHLO db8outboundpool.messaging.microsoft.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1759592Ab3ICFrt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Sep 2013 01:47:49 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sonic Zhang <sonic.zhang@analog.com>

The synopsys spec says When TSCRLSSR is cleard, the rollover value of
sub-second register is 0x7FFFFFFF(0.465 ns per clock).

Signed-off-by: Sonic Zhang <sonic.zhang@analog.com>
---
 drivers/net/ethernet/stmicro/stmmac/stmmac_hwtstamp.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_hwtstamp.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_hwtstamp.c
index def7e75..76ad214 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_hwtstamp.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_hwtstamp.c
@@ -45,8 +45,8 @@ static void stmmac_config_sub_second_increment(void __iomem *ioaddr)
 	data = (1000000000ULL / 50000000);
 
 	/* 0.465ns accuracy */
-	if (value & PTP_TCR_TSCTRLSSR)
-		data = (data * 100) / 465;
+	if (!(value & PTP_TCR_TSCTRLSSR))
+		data = (data * 1000) / 465;
 
 	writel(data, ioaddr + PTP_SSIR);
 }
-- 
1.8.2.3
