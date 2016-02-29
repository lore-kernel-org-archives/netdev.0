From: Alexandre TORGUE <alexandre.torgue@st.com>
Subject: [PATCH v3 14/17] stmmac: fix phy init when attached to a phy
Date: Mon, 29 Feb 2016 14:27:40 +0100
Message-ID: <1456752463-27128-15-git-send-email-alexandre.torgue@st.com>
References: <1456752463-27128-1-git-send-email-alexandre.torgue@st.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <peppe.cavallaro@st.com>, <fabrice.gasnier@st.com>,
	<maxime.coquelin@st.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx08-00178001.pphosted.com ([91.207.212.93]:45934 "EHLO
	mx07-00178001.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1755389AbcB2N27 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Feb 2016 08:28:59 -0500
Received: from pps.filterd (m0046661.ppops.net [127.0.0.1])
	by mx08-00178001.pphosted.com (8.15.0.59/8.15.0.59) with SMTP id u1TDS8pd019736
	for <netdev@vger.kernel.org>; Mon, 29 Feb 2016 14:28:57 +0100
Received: from beta.dmz-ap.st.com (beta.dmz-ap.st.com [138.198.100.35])
	by mx08-00178001.pphosted.com with ESMTP id 21b3jgaqg0-1
	(version=TLSv1/SSLv3 cipher=ECDHE-RSA-AES256-SHA bits=256 verify=NOT)
	for <netdev@vger.kernel.org>; Mon, 29 Feb 2016 14:28:57 +0100
Received: from zeta.dmz-ap.st.com (ns6.st.com [138.198.234.13])
	by beta.dmz-ap.st.com (STMicroelectronics) with ESMTP id 6F63C22
	for <netdev@vger.kernel.org>; Mon, 29 Feb 2016 13:28:54 +0000 (GMT)
Received: from Webmail-ap.st.com (eapex1hubcas1.st.com [10.80.176.8])
	by zeta.dmz-ap.st.com (STMicroelectronics) with ESMTP id 17D72F7
	for <netdev@vger.kernel.org>; Mon, 29 Feb 2016 13:28:53 +0000 (GMT)
In-Reply-To: <1456752463-27128-1-git-send-email-alexandre.torgue@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Fabrice Gasnier <fabrice.gasnier@st.com>

phy_bus_name can be NULL when "fixed-link" property isn't used.
Then, since "stmmac: do not poll phy handler when attach a switch",
phy_bus_name ptr needs to be checked before strcmp is called.

Signed-off-by: Fabrice Gasnier <fabrice.gasnier@st.com>
Signed-off-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>
Signed-off-by: Alexandre TORGUE <alexandre.torgue@st.com>

diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
index eab7ac0..3cc1355 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
@@ -868,8 +868,9 @@ static int stmmac_init_phy(struct net_device *dev)
 	}
 
 	/* If attached to a switch, there is no reason to poll phy handler */
-	if (!strcmp(priv->plat->phy_bus_name, "fixed"))
-		phydev->irq = PHY_IGNORE_INTERRUPT;
+	if (priv->plat->phy_bus_name)
+		if (!strcmp(priv->plat->phy_bus_name, "fixed"))
+			phydev->irq = PHY_IGNORE_INTERRUPT;
 
 	pr_debug("stmmac_init_phy:  %s: attached to PHY (UID 0x%x)"
 		 " Link = %d\n", dev->name, phydev->phy_id, phydev->link);
-- 
1.9.1
