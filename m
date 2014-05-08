From: Johan Hovold <jhovold@gmail.com>
Subject: [PATCH 5/5] net: cpsw: add missing of_node_put
Date: Thu,  8 May 2014 09:37:19 +0200
Message-ID: <1399534639-4947-6-git-send-email-jhovold@gmail.com>
References: <1399534639-4947-1-git-send-email-jhovold@gmail.com>
Cc: devicetree@vger.kernel.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, Mugunthan V N <mugunthanvnm@ti.com>,
	Johan Hovold <jhovold@gmail.com>
To: "David S. Miller" <davem@davemloft.net>,
	Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f170.google.com ([209.85.217.170]:51649 "EHLO
	mail-lb0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753164AbaEHHkv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 May 2014 03:40:51 -0400
In-Reply-To: <1399534639-4947-1-git-send-email-jhovold@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add missing of_node_put to avoid kref leak.

Signed-off-by: Johan Hovold <jhovold@gmail.com>
---
 drivers/net/ethernet/ti/cpsw.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/ethernet/ti/cpsw.c b/drivers/net/ethernet/ti/cpsw.c
index db9360cd861c..c331b7ebc812 100644
--- a/drivers/net/ethernet/ti/cpsw.c
+++ b/drivers/net/ethernet/ti/cpsw.c
@@ -1871,6 +1871,7 @@ static int cpsw_probe_dt(struct cpsw_platform_data *data,
 		mdio_node = of_find_node_by_phandle(be32_to_cpup(parp));
 		phyid = be32_to_cpup(parp+1);
 		mdio = of_find_device_by_node(mdio_node);
+		of_node_put(mdio_node);
 		if (!mdio) {
 			pr_err("Missing mdio platform device\n");
 			return -EINVAL;
-- 
1.8.3.2
