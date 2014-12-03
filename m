From: Giuseppe Cavallaro <peppe.cavallaro@st.com>
Subject: [PATCH (net.git)] stmmac: fix max coal timer parameter
Date: Wed, 3 Dec 2014 12:32:58 +0100
Message-ID: <1417606378-8179-1-git-send-email-peppe.cavallaro@st.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Giuseppe Cavallaro <peppe.cavallaro@st.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx07-00178001.pphosted.com ([62.209.51.94]:58462 "EHLO
	mx07-00178001.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752664AbaLCLyY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Dec 2014 06:54:24 -0500
Received: from pps.filterd (m0046670.ppops.net [127.0.0.1])
	by mx07-00178001.pphosted.com (8.14.5/8.14.5) with SMTP id sB3Bq1eu032179
	for <netdev@vger.kernel.org>; Wed, 3 Dec 2014 12:54:22 +0100
Received: from beta.dmz-eu.st.com (beta.dmz-eu.st.com [164.129.1.35])
	by mx07-00178001.pphosted.com with ESMTP id 1r0qb6b68a-1
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NOT)
	for <netdev@vger.kernel.org>; Wed, 03 Dec 2014 12:54:22 +0100
Received: from zeta.dmz-eu.st.com (zeta.dmz-eu.st.com [164.129.230.9])
	by beta.dmz-eu.st.com (STMicroelectronics) with ESMTP id 4CE8B3A
	for <netdev@vger.kernel.org>; Wed,  3 Dec 2014 11:53:45 +0000 (GMT)
Received: from Webmail-eu.st.com (Safex1hubcas21.st.com [10.75.90.44])
	by zeta.dmz-eu.st.com (STMicroelectronics) with ESMTP id 63A665A596
	for <netdev@vger.kernel.org>; Wed,  3 Dec 2014 11:54:19 +0000 (GMT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch is to fix the max coalesce timer setting that can be provided
by ethtool.
The default value (STMMAC_COAL_TX_TIMER) was used in the set_coalesce helper
instead of the max one (STMMAC_MAX_COAL_TX_TICK, so defined but not used).

Signed-off-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>
---
 .../net/ethernet/stmicro/stmmac/stmmac_ethtool.c   |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_ethtool.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_ethtool.c
index 3a08a1f..771cda2 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_ethtool.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_ethtool.c
@@ -696,7 +696,7 @@ static int stmmac_set_coalesce(struct net_device *dev,
 	    (ec->tx_max_coalesced_frames == 0))
 		return -EINVAL;
 
-	if ((ec->tx_coalesce_usecs > STMMAC_COAL_TX_TIMER) ||
+	if ((ec->tx_coalesce_usecs > STMMAC_MAX_COAL_TX_TICK) ||
 	    (ec->tx_max_coalesced_frames > STMMAC_TX_MAX_FRAMES))
 		return -EINVAL;
 
-- 
1.7.4.4
