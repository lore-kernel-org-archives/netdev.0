From: Giuseppe Cavallaro <peppe.cavallaro@st.com>
Subject: [PATCH (net.git) 2/2] stmmac: set ptp_clock to NULL while unregister
Date: Mon, 25 Aug 2014 14:56:19 +0200
Message-ID: <1408971379-14871-2-git-send-email-peppe.cavallaro@st.com>
References: <1408971379-14871-1-git-send-email-peppe.cavallaro@st.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Giuseppe Cavallaro <peppe.cavallaro@st.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx08-00178001.pphosted.com ([91.207.212.93]:45292 "EHLO
	mx08-00178001.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755532AbaHYM41 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Aug 2014 08:56:27 -0400
Received: from pps.filterd (m0046661.ppops.net [127.0.0.1])
	by mx08-00178001.pphosted.com (8.14.5/8.14.5) with SMTP id s7PCsIC4020096
	for <netdev@vger.kernel.org>; Mon, 25 Aug 2014 14:56:25 +0200
Received: from beta.dmz-eu.st.com (beta.dmz-eu.st.com [164.129.1.35])
	by mx08-00178001.pphosted.com with ESMTP id 1nxm67usth-1
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NOT)
	for <netdev@vger.kernel.org>; Mon, 25 Aug 2014 14:56:25 +0200
Received: from zeta.dmz-eu.st.com (zeta.dmz-eu.st.com [164.129.230.9])
	by beta.dmz-eu.st.com (STMicroelectronics) with ESMTP id 4881C38
	for <netdev@vger.kernel.org>; Mon, 25 Aug 2014 12:56:15 +0000 (GMT)
Received: from Webmail-eu.st.com (Safex1hubcas21.st.com [10.75.90.44])
	by zeta.dmz-eu.st.com (STMicroelectronics) with ESMTP id 9B21859F09
	for <netdev@vger.kernel.org>; Mon, 25 Aug 2014 12:56:23 +0000 (GMT)
In-Reply-To: <1408971379-14871-1-git-send-email-peppe.cavallaro@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is to properly put to NULL the ptp_clock while un-register the PTP support.

Signed-off-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>
---
 drivers/net/ethernet/stmicro/stmmac/stmmac_ptp.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_ptp.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_ptp.c
index b7ad356..c5ee79d 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_ptp.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_ptp.c
@@ -206,6 +206,7 @@ void stmmac_ptp_unregister(struct stmmac_priv *priv)
 {
 	if (priv->ptp_clock) {
 		ptp_clock_unregister(priv->ptp_clock);
+		priv->ptp_clock = NULL;
 		pr_debug("Removed PTP HW clock successfully on %s\n",
 			 priv->dev->name);
 	}
-- 
1.7.4.4
