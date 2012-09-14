From: Srinivas KANDAGATLA <srinivas.kandagatla@st.com>
Subject: [PATCH v2 5/7] dt/net/fsl_pq_mdio: Use of_get_child_by_name to get a named child.
Date: Fri, 14 Sep 2012 09:19:42 +0100
Message-ID: <1347610782-20265-1-git-send-email-srinivas.kandagatla@st.com>
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	devicetree-discuss@lists.ozlabs.org, robherring2@gmail.com,
	srinivas.kandagatla@st.com, grant.likely@secretlab.ca
To: afleming@freescale.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog103.obsmtp.com ([207.126.144.115]:42047 "EHLO
	eu1sys200aog103.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1759151Ab2INIWv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Sep 2012 04:22:51 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Srinivas Kandagatla <srinivas.kandagatla@st.com>

As follow-up to "dt: introduce of_get_child_by_name to get child node by
name." patch, This patch removes some of the code duplication in the
driver by replacing it with of_get_child_by_name instead.

Signed-off-by: Srinivas Kandagatla <srinivas.kandagatla@st.com>
---
 drivers/net/ethernet/freescale/fsl_pq_mdio.c |    5 +----
 1 files changed, 1 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/freescale/fsl_pq_mdio.c b/drivers/net/ethernet/freescale/fsl_pq_mdio.c
index 9527b28..e710c60 100644
--- a/drivers/net/ethernet/freescale/fsl_pq_mdio.c
+++ b/drivers/net/ethernet/freescale/fsl_pq_mdio.c
@@ -355,10 +355,7 @@ static int fsl_pq_mdio_probe(struct platform_device *ofdev)
 		goto err_free_irqs;
 	}
 
-	for_each_child_of_node(np, tbi) {
-		if (!strncmp(tbi->type, "tbi-phy", 8))
-			break;
-	}
+	tbi = of_get_child_by_name(np, "tbi-phy");
 
 	if (tbi) {
 		const u32 *prop = of_get_property(tbi, "reg", NULL);
-- 
1.7.0.4
