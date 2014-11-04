From: Giuseppe Cavallaro <peppe.cavallaro@st.com>
Subject: [PATCH (net.git) 2/5] stmmac: release tx lock, in case of dma mapping error.
Date: Tue, 4 Nov 2014 17:08:06 +0100
Message-ID: <1415117289-7733-3-git-send-email-peppe.cavallaro@st.com>
References: <1415117289-7733-1-git-send-email-peppe.cavallaro@st.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Fabrice Gasnier <fabrice.gasnier@st.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx07-00178001.pphosted.com ([62.209.51.94]:33511 "EHLO
	mx07-00178001.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752847AbaKDQUA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Nov 2014 11:20:00 -0500
Received: from pps.filterd (m0046668.ppops.net [127.0.0.1])
	by mx07-00178001.pphosted.com (8.14.5/8.14.5) with SMTP id sA4GFRTr010272
	for <netdev@vger.kernel.org>; Tue, 4 Nov 2014 17:19:58 +0100
Received: from beta.dmz-eu.st.com (beta.dmz-eu.st.com [164.129.1.35])
	by mx07-00178001.pphosted.com with ESMTP id 1qeqj0309c-1
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NOT)
	for <netdev@vger.kernel.org>; Tue, 04 Nov 2014 17:19:58 +0100
Received: from zeta.dmz-eu.st.com (zeta.dmz-eu.st.com [164.129.230.9])
	by beta.dmz-eu.st.com (STMicroelectronics) with ESMTP id 52CE738
	for <netdev@vger.kernel.org>; Tue,  4 Nov 2014 16:19:30 +0000 (GMT)
Received: from Webmail-eu.st.com (Safex1hubcas21.st.com [10.75.90.44])
	by zeta.dmz-eu.st.com (STMicroelectronics) with ESMTP id 4E033ABD7
	for <netdev@vger.kernel.org>; Tue,  4 Nov 2014 16:19:55 +0000 (GMT)
In-Reply-To: <1415117289-7733-1-git-send-email-peppe.cavallaro@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Fabrice Gasnier <fabrice.gasnier@st.com>

Add missing spin_unlock when tx frames gets dropped.

Signed-off-by: Fabrice Gasnier <fabrice.gasnier@st.com>
Acked-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>
---
 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
index bcd8a34..ee07e7e 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
@@ -2026,6 +2026,7 @@ static netdev_tx_t stmmac_xmit(struct sk_buff *skb, struct net_device *dev)
 	return NETDEV_TX_OK;
 
 dma_map_err:
+	spin_unlock(&priv->tx_lock);
 	dev_err(priv->device, "Tx dma map failed\n");
 	dev_kfree_skb(skb);
 	priv->dev->stats.tx_dropped++;
-- 
1.7.4.4
