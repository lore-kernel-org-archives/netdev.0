From: Richard Retanubun <rretanubun.work@gmail.com>
Subject: [PATCH v3] of: mdio: fixup of_phy_register_fixed_link parsing of new bindings
Date: Fri, 20 Jun 2014 10:11:07 -0400
Message-ID: <1403273467-16974-1-git-send-email-rretanubun.work@gmail.com>
References: <53A35763.4020904@cogentembedded.com>
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	devicetree@vger.kernel.org, robh+dt@kernel.org, pawel.moll@arm.com,
	mark.rutland@arm.com, ijc+devicetree@hellion.org.uk,
	galak@codeaurora.org, thomas.petazzoni@free-electrons.com
To: sergei.shtylyov@cogentembedded.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f170.google.com ([209.85.213.170]:53572 "EHLO
	mail-ig0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965829AbaFTOLN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Jun 2014 10:11:13 -0400
In-Reply-To: <53A35763.4020904@cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fixes commit 3be2a49e5c08 ("of: provide a binding for fixed link PHYs")

Fix the parsing of the new fixed link dts bindings for duplex,
pause, and asym_pause by using the correct device node pointer.

Signed-off-by: Richard Retanubun <rretanubun.work@gmail.com>
---
v3: New and improved code indent.

 drivers/of/of_mdio.c | 8 +++++---
 1 file changed, 5 insertions(+), 3 deletions(-)

diff --git a/drivers/of/of_mdio.c b/drivers/of/of_mdio.c
index 7700ddc..3812596 100644
--- a/drivers/of/of_mdio.c
+++ b/drivers/of/of_mdio.c
@@ -290,11 +290,13 @@ int of_phy_register_fixed_link(struct device_node *np)
 	fixed_link_node = of_get_child_by_name(np, "fixed-link");
 	if (fixed_link_node) {
 		status.link = 1;
-		status.duplex = of_property_read_bool(np, "full-duplex");
+		status.duplex = of_property_read_bool(fixed_link_node,
+						      "full-duplex");
 		if (of_property_read_u32(fixed_link_node, "speed", &status.speed))
 			return -EINVAL;
-		status.pause = of_property_read_bool(np, "pause");
-		status.asym_pause = of_property_read_bool(np, "asym-pause");
+		status.pause = of_property_read_bool(fixed_link_node, "pause");
+		status.asym_pause = of_property_read_bool(fixed_link_node,
+							  "asym-pause");
 		of_node_put(fixed_link_node);
 		return fixed_phy_register(PHY_POLL, &status, np);
 	}
-- 
1.8.5.1
