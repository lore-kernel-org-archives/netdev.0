From: Giuseppe Cavallaro <peppe.cavallaro@st.com>
Subject: [PATCH (net-next.git) 15/18] stmmac: fix phy init when attached to a phy
Date: Mon, 4 Jan 2016 14:07:00 +0100
Message-ID: <1451912823-5245-16-git-send-email-peppe.cavallaro@st.com>
References: <1451912823-5245-1-git-send-email-peppe.cavallaro@st.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <alexandre.torgue@st.com>,
	Fabrice Gasnier <fabrice.gasnier@st.com>,
	Giuseppe Cavallaro <peppe.cavallaro@st.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx08-00178001.pphosted.com ([91.207.212.93]:41557 "EHLO
	mx07-00178001.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1753657AbcADMy2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Jan 2016 07:54:28 -0500
Received: from pps.filterd (m0046660.ppops.net [127.0.0.1])
	by mx08-00178001.pphosted.com (8.14.5/8.14.5) with SMTP id u04CrXt7022871
	for <netdev@vger.kernel.org>; Mon, 4 Jan 2016 13:54:27 +0100
Received: from beta.dmz-eu.st.com (beta.dmz-eu.st.com [164.129.1.35])
	by mx08-00178001.pphosted.com with ESMTP id 2034vyx792-1
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NOT)
	for <netdev@vger.kernel.org>; Mon, 04 Jan 2016 13:54:27 +0100
Received: from zeta.dmz-eu.st.com (zeta.dmz-eu.st.com [164.129.230.9])
	by beta.dmz-eu.st.com (STMicroelectronics) with ESMTP id 9C3F834
	for <netdev@vger.kernel.org>; Mon,  4 Jan 2016 12:53:43 +0000 (GMT)
Received: from Webmail-eu.st.com (Safex1hubcas21.st.com [10.75.90.44])
	by zeta.dmz-eu.st.com (STMicroelectronics) with ESMTP id D741550F9
	for <netdev@vger.kernel.org>; Mon,  4 Jan 2016 12:54:25 +0000 (GMT)
In-Reply-To: <1451912823-5245-1-git-send-email-peppe.cavallaro@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Fabrice Gasnier <fabrice.gasnier@st.com>

phy_bus_name can be NULL when "fixed-link" property isn't used.
Then, since "stmmac: do not poll phy handler when attach a switch",
phy_bus_name ptr needs to be checked before strcmp is called.

Signed-off-by: Fabrice Gasnier <fabrice.gasnier@st.com>
Signed-off-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>
---
 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c |    5 +++--
 1 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
index 76ca54c..879cf77 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
@@ -883,8 +883,9 @@ static int stmmac_init_phy(struct net_device *dev)
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
1.7.4.4
