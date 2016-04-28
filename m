From: "David Rivshin (Allworx)" <drivshin.allworx@gmail.com>
Subject: [PATCH net v3 4/5] dt: cpsw: phy-handle, phy_id, and fixed-link are mutually exclusive
Date: Wed, 27 Apr 2016 21:42:47 -0400
Message-ID: <1461807767-4563-1-git-send-email-drivshin.allworx@gmail.com>
References: <1461805808-4102-1-git-send-email-drivshin.allworx@gmail.com>
Cc: linux-arm-kernel@lists.infradead.org, devicetree@vger.kernel.org,
	linux-kernel@vger.kernel.org, David Miller <davem@davemloft.net>,
	Mugunthan V N <mugunthanvnm@ti.com>,
	Grygorii Strashko <grygorii.strashko@ti.com>,
	Andrew Goodbody <andrew.goodbody@cambrionix.com>,
	Markus Brunner <systemprogrammierung.brunner@gmail.com>,
	Nicolas Chauvet <kwizart@gmail.com>
To: netdev@vger.kernel.org, linux-omap@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f67.google.com ([209.85.192.67]:33294 "EHLO
	mail-qg0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751534AbcD1BnA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Apr 2016 21:43:00 -0400
In-Reply-To: <1461805808-4102-1-git-send-email-drivshin.allworx@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Rivshin <drivshin@allworx.com>

The phy-handle, phy_id, and fixed-link properties are mutually exclusive,
and only one need be specified. Make this clear in the binding doc.

Also mark the phy_id property as deprecated, as phy-handle should be
used instead.

Signed-off-by: David Rivshin <drivshin@allworx.com>
---

Changes since v2 [1]:
- split from previous patch 2
- marked the phy_id property as deprecated [3]
- removed Rob Herring's Acked-by due to above change

Changes since v1 [2]:
- Rebased (no conflicts)
- Added Tested-by from Nicolas Chauvet
- Added Acked-by from Rob Herring for the binding change

[1] http://patchwork.ozlabs.org/patch/613260/
[2] http://patchwork.ozlabs.org/patch/560324/
[3] https://lkml.org/lkml/2016/4/22/494


 Documentation/devicetree/bindings/net/cpsw.txt | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/Documentation/devicetree/bindings/net/cpsw.txt b/Documentation/devicetree/bindings/net/cpsw.txt
index 28a4781..0ae0649 100644
--- a/Documentation/devicetree/bindings/net/cpsw.txt
+++ b/Documentation/devicetree/bindings/net/cpsw.txt
@@ -41,21 +41,21 @@ Optional properties:
 Slave Properties:
 Required properties:
 - phy-mode		: See ethernet.txt file in the same directory
 
 Optional properties:
 - dual_emac_res_vlan	: Specifies VID to be used to segregate the ports
 - mac-address		: See ethernet.txt file in the same directory
-- phy_id		: Specifies slave phy id
+- phy_id		: Specifies slave phy id (deprecated, use phy-handle)
 - phy-handle		: See ethernet.txt file in the same directory
 
 Slave sub-nodes:
 - fixed-link		: See fixed-link.txt file in the same directory
-			  Either the property phy_id, or the sub-node
-			  fixed-link can be specified
+
+Note: Exactly one of phy_id, phy-handle, or fixed-link must be specified.
 
 Note: "ti,hwmods" field is used to fetch the base address and irq
 resources from TI, omap hwmod data base during device registration.
 Future plan is to migrate hwmod data base contents into device tree
 blob so that, all the required data will be used from device tree dts
 file.
 
-- 
2.5.5
