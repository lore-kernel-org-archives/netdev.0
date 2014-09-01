From: Giuseppe Cavallaro <peppe.cavallaro@st.com>
Subject: [PATCH (net.git) 2/2] stmmac: only remove RXCSUM feature if no rx coe is available
Date: Mon, 1 Sep 2014 09:17:53 +0200
Message-ID: <1409555873-5478-2-git-send-email-peppe.cavallaro@st.com>
References: <1409555873-5478-1-git-send-email-peppe.cavallaro@st.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Giuseppe Cavallaro <peppe.cavallaro@st.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx07-00178001.pphosted.com ([62.209.51.94]:51095 "EHLO
	mx07-00178001.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752726AbaIAHSD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Sep 2014 03:18:03 -0400
Received: from pps.filterd (m0046668.ppops.net [127.0.0.1])
	by mx07-00178001.pphosted.com (8.14.5/8.14.5) with SMTP id s817DYTU004675
	for <netdev@vger.kernel.org>; Mon, 1 Sep 2014 09:18:00 +0200
Received: from beta.dmz-eu.st.com (beta.dmz-eu.st.com [164.129.1.35])
	by mx07-00178001.pphosted.com with ESMTP id 1p4dthhh54-1
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NOT)
	for <netdev@vger.kernel.org>; Mon, 01 Sep 2014 09:18:00 +0200
Received: from zeta.dmz-eu.st.com (zeta.dmz-eu.st.com [164.129.230.9])
	by beta.dmz-eu.st.com (STMicroelectronics) with ESMTP id AAD1638
	for <netdev@vger.kernel.org>; Mon,  1 Sep 2014 07:17:48 +0000 (GMT)
Received: from Webmail-eu.st.com (Safex1hubcas21.st.com [10.75.90.44])
	by zeta.dmz-eu.st.com (STMicroelectronics) with ESMTP id 07F4F2CA0C
	for <netdev@vger.kernel.org>; Mon,  1 Sep 2014 07:17:59 +0000 (GMT)
In-Reply-To: <1409555873-5478-1-git-send-email-peppe.cavallaro@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In case of the HW is not able to do the receive checksum offloading
the only feature to remove is NETIF_F_RXCSUM.

Signed-off-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>
---
 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c |    2 --
 1 files changed, 0 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
index 56e5c1b..8da95d56 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
@@ -2329,8 +2329,6 @@ static netdev_features_t stmmac_fix_features(struct net_device *dev,
 
 	if (priv->plat->rx_coe == STMMAC_RX_COE_NONE)
 		features &= ~NETIF_F_RXCSUM;
-	else if (priv->plat->rx_coe == STMMAC_RX_COE_TYPE1)
-		features &= ~NETIF_F_IPV6_CSUM;
 
 	if (!priv->plat->tx_coe)
 		features &= ~NETIF_F_ALL_CSUM;
-- 
1.7.4.4
