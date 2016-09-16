From: Giuseppe Cavallaro <peppe.cavallaro@st.com>
Subject: [PATCH (net.git)] stmmac: fix PWRDWN into the PMT register for global unicast.
Date: Fri, 16 Sep 2016 10:50:13 +0200
Message-ID: <1474015813-5400-1-git-send-email-peppe.cavallaro@st.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Giuseppe Cavallaro <peppe.cavallaro@st.com>,
        Alexandre TORGUE <alexandre.torgue@st.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx07-00178001.pphosted.com ([62.209.51.94]:31931 "EHLO
        mx07-00178001.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1754118AbcIPJKh (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 16 Sep 2016 05:10:37 -0400
Received: from pps.filterd (m0046668.ppops.net [127.0.0.1])
        by mx07-00178001.pphosted.com (8.16.0.11/8.16.0.11) with SMTP id u8G92fI5007693
        for <netdev@vger.kernel.org>; Fri, 16 Sep 2016 11:10:35 +0200
Received: from beta.dmz-eu.st.com (beta.dmz-eu.st.com [164.129.1.35])
        by mx07-.pphosted.com with ESMTP id 25gd3y0a0s-1
        (version=TLSv1 cipher=ECDHE-RSA-AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Fri, 16 Sep 2016 11:10:35 +0200
Received: from zeta.dmz-eu.st.com (zeta.dmz-eu.st.com [164.129.230.9])
        by beta.dmz-eu.st.com (STMicroelectronics) with ESMTP id 7936434
        for <netdev@vger.kernel.org>; Fri, 16 Sep 2016 09:10:34 +0000 (GMT)
Received: from Webmail-eu.st.com (Safex1hubcas22.st.com [10.75.90.92])
        by zeta.dmz-eu.st.com (STMicroelectronics) with ESMTP id 67C8612A8
        for <netdev@vger.kernel.org>; Fri, 16 Sep 2016 09:10:34 +0000 (GMT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

MAC devices use the RWKPKTEN and MGKPKTEN bits of the PMT Control/Status
register to generate power management events.
So this patch is to properly set the RWKPKTEN [BIT(2)] inside the
PMT register (needed in case of global unicast).

Reported-by: Aditi SHARMA <aditi-hed.sharma@st.com>
Signed-off-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>
Cc: Alexandre TORGUE <alexandre.torgue@st.com>
---
 drivers/net/ethernet/stmicro/stmmac/dwmac1000_core.c | 2 +-
 drivers/net/ethernet/stmicro/stmmac/dwmac4_core.c    | 2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac1000_core.c b/drivers/net/ethernet/stmicro/stmmac/dwmac1000_core.c
index cbefe9e..885a5e6 100644
--- a/drivers/net/ethernet/stmicro/stmmac/dwmac1000_core.c
+++ b/drivers/net/ethernet/stmicro/stmmac/dwmac1000_core.c
@@ -261,7 +261,7 @@ static void dwmac1000_pmt(struct mac_device_info *hw, unsigned long mode)
 	}
 	if (mode & WAKE_UCAST) {
 		pr_debug("GMAC: WOL on global unicast\n");
-		pmt |= global_unicast;
+		pmt |= power_down | global_unicast | wake_up_frame_en;
 	}
 
 	writel(pmt, ioaddr + GMAC_PMT);
diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac4_core.c b/drivers/net/ethernet/stmicro/stmmac/dwmac4_core.c
index df5580d..51019b7 100644
--- a/drivers/net/ethernet/stmicro/stmmac/dwmac4_core.c
+++ b/drivers/net/ethernet/stmicro/stmmac/dwmac4_core.c
@@ -102,7 +102,7 @@ static void dwmac4_pmt(struct mac_device_info *hw, unsigned long mode)
 	}
 	if (mode & WAKE_UCAST) {
 		pr_debug("GMAC: WOL on global unicast\n");
-		pmt |= global_unicast;
+		pmt |= power_down | global_unicast | wake_up_frame_en;
 	}
 
 	writel(pmt, ioaddr + GMAC_PMT);
-- 
2.7.4
