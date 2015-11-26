From: Giuseppe Cavallaro <peppe.cavallaro@st.com>
Subject: [PATCH (net.git) 1/5] stmmac: fix a filter problem after resuming.
Date: Thu, 26 Nov 2015 08:35:41 +0100
Message-ID: <1448523345-832-2-git-send-email-peppe.cavallaro@st.com>
References: <1448523345-832-1-git-send-email-peppe.cavallaro@st.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Giuseppe Cavallaro <peppe.cavallaro@st.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx07-00178001.pphosted.com ([62.209.51.94]:25169 "EHLO
	mx07-00178001.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751423AbbKZH2F (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Nov 2015 02:28:05 -0500
Received: from pps.filterd (m0046037.ppops.net [127.0.0.1])
	by m0046037.ppops.net (8.14.5/8.14.5) with SMTP id tAQ7S3T6011126
	for <netdev@vger.kernel.org>; Thu, 26 Nov 2015 08:28:03 +0100
Received: from beta.dmz-eu.st.com (beta.dmz-eu.st.com [164.129.1.35])
	by m0046037.ppops.net with ESMTP id 1ydn4asw5r-1
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NOT)
	for <netdev@vger.kernel.org>; Thu, 26 Nov 2015 08:28:03 +0100
Received: from zeta.dmz-eu.st.com (zeta.dmz-eu.st.com [164.129.230.9])
	by beta.dmz-eu.st.com (STMicroelectronics) with ESMTP id 7FAAE41
	for <netdev@vger.kernel.org>; Thu, 26 Nov 2015 07:27:29 +0000 (GMT)
Received: from Webmail-eu.st.com (Safex1hubcas24.st.com [10.75.90.94])
	by zeta.dmz-eu.st.com (STMicroelectronics) with ESMTP id 98D2013CD
	for <netdev@vger.kernel.org>; Thu, 26 Nov 2015 07:28:01 +0000 (GMT)
In-Reply-To: <1448523345-832-1-git-send-email-peppe.cavallaro@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When resume the HW is re-configured but some settings can be lost.
For example, the MAC Address_X High/Low Registers used for VLAN tagging..
So, while resuming, the set_filter callback needs to be invoked to
re-program perfect and hash-table registers.

Signed-off-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>
---
 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
index 64d8aa4..e3d96f2 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
@@ -3102,6 +3102,7 @@ int stmmac_resume(struct net_device *ndev)
 	init_dma_desc_rings(ndev, GFP_ATOMIC);
 	stmmac_hw_setup(ndev, false);
 	stmmac_init_tx_coalesce(priv);
+	stmmac_set_rx_mode(ndev);
 
 	napi_enable(&priv->napi);
 
-- 
1.7.4.4
