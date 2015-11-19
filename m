From: Tony Lindgren <tony@atomide.com>
Subject: [PATCH] net: cpsw: Fix ethernet regression for dm814x
Date: Wed, 18 Nov 2015 17:27:25 -0800
Message-ID: <1447896445-6120-1-git-send-email-tony@atomide.com>
Cc: netdev@vger.kernel.org, linux-omap@vger.kernel.org,
	Mugunthan V N <mugunthanvnm@ti.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from muru.com ([72.249.23.125]:47630 "EHLO muru.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757540AbbKSB1a (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 18 Nov 2015 20:27:30 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit b6745f6e4e63 ("drivers: net: cpsw: davinci_emac: move reading mac
id to common file") started using of_machine_is_compatible for detecting
type but missed at dm8148 causing Ethernet to stop working.

Let's fix the issue by adding handling for dm814x.

Cc: Mugunthan V N <mugunthanvnm@ti.com>
Signed-off-by: Tony Lindgren <tony@atomide.com>
---
 drivers/net/ethernet/ti/cpsw-common.c | 3 +++
 1 file changed, 3 insertions(+)

--- a/drivers/net/ethernet/ti/cpsw-common.c
+++ b/drivers/net/ethernet/ti/cpsw-common.c
@@ -78,6 +78,9 @@ static int cpsw_am33xx_cm_get_macid(struct device *dev, u16 offset, int slave,
 
 int ti_cm_get_macid(struct device *dev, int slave, u8 *mac_addr)
 {
+	if (of_machine_is_compatible("ti,dm8148"))
+		return cpsw_am33xx_cm_get_macid(dev, 0x630, slave, mac_addr);
+
 	if (of_machine_is_compatible("ti,am33xx"))
 		return cpsw_am33xx_cm_get_macid(dev, 0x630, slave, mac_addr);
 
-- 
2.6.2
