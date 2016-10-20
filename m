From: Giuseppe Cavallaro <peppe.cavallaro@st.com>
Subject: [PATCH (net.git)] stmmac: display the descriptors if DES0 = 0
Date: Thu, 20 Oct 2016 10:01:28 +0200
Message-ID: <1476950488-24923-1-git-send-email-peppe.cavallaro@st.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Giuseppe Cavallaro <peppe.cavallaro@st.com>,
        Alexandre TORGUE <alexandre.torgue@st.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx08-00178001.pphosted.com ([91.207.212.93]:56074 "EHLO
        mx07-00178001.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1750912AbcJTIHH (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 20 Oct 2016 04:07:07 -0400
Received: from pps.filterd (m0046661.ppops.net [127.0.0.1])
        by mx08-00178001.pphosted.com (8.16.0.11/8.16.0.11) with SMTP id u9K83ox9017159
        for <netdev@vger.kernel.org>; Thu, 20 Oct 2016 10:07:06 +0200
Received: from beta.dmz-eu.st.com (beta.dmz-eu.st.com [164.129.1.35])
        by mx08-.pphosted.com with ESMTP id 263bbdw002-1
        (version=TLSv1 cipher=ECDHE-RSA-AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Thu, 20 Oct 2016 10:07:06 +0200
Received: from zeta.dmz-eu.st.com (zeta.dmz-eu.st.com [164.129.230.9])
        by beta.dmz-eu.st.com (STMicroelectronics) with ESMTP id AE41531
        for <netdev@vger.kernel.org>; Thu, 20 Oct 2016 08:07:05 +0000 (GMT)
Received: from Webmail-eu.st.com (Safex1hubcas23.st.com [10.75.90.46])
        by zeta.dmz-eu.st.com (STMicroelectronics) with ESMTP id 86B9418D8
        for <netdev@vger.kernel.org>; Thu, 20 Oct 2016 08:07:05 +0000 (GMT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

It makes sense to display the descriptors even if 
DES0 is zero. This helps for example in case of it
is needed to dump rx write-back descriptors to get
timestamp status.

Signed-off-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>
Cc: Alexandre TORGUE <alexandre.torgue@st.com>
---
 drivers/net/ethernet/stmicro/stmmac/dwmac4_descs.c | 7 +++----
 1 file changed, 3 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac4_descs.c b/drivers/net/ethernet/stmicro/stmmac/dwmac4_descs.c
index 4ec7397..a1b17cd 100644
--- a/drivers/net/ethernet/stmicro/stmmac/dwmac4_descs.c
+++ b/drivers/net/ethernet/stmicro/stmmac/dwmac4_descs.c
@@ -347,10 +347,9 @@ static void dwmac4_display_ring(void *head, unsigned int size, bool rx)
 	pr_info("%s descriptor ring:\n", rx ? "RX" : "TX");
 
 	for (i = 0; i < size; i++) {
-		if (p->des0)
-			pr_info("%d [0x%x]: 0x%x 0x%x 0x%x 0x%x\n",
-				i, (unsigned int)virt_to_phys(p),
-				p->des0, p->des1, p->des2, p->des3);
+		pr_info("%d [0x%x]: 0x%x 0x%x 0x%x 0x%x\n",
+			i, (unsigned int)virt_to_phys(p),
+			p->des0, p->des1, p->des2, p->des3);
 		p++;
 	}
 }
-- 
2.7.4
