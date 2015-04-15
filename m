From: Vince Bridgers <vbridger@opensource.altera.com>
Subject: [PATCH net 1/5] stmmac: Add properties for transmit and receive fifo sizes
Date: Wed, 15 Apr 2015 11:17:38 -0500
Message-ID: <1429114662-1528-2-git-send-email-vbridger@opensource.altera.com>
References: <1429114662-1528-1-git-send-email-vbridger@opensource.altera.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <vbridger@opensource.altera.com>, <vbridger@altera.com>
To: <peppe.cavallaro@st.com>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bn1bon0084.outbound.protection.outlook.com ([157.56.111.84]:36999
	"EHLO na01-bn1-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1754958AbbDOUzz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 15 Apr 2015 16:55:55 -0400
In-Reply-To: <1429114662-1528-1-git-send-email-vbridger@opensource.altera.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The Synopsys stmmac fifo sizes are configurable, and need to be known
in order to configure certain controller features. This patch adds
tx-fifo-depth and rx-fifo-depth properties to the stmmac document
file.

Signed-off-by: Vince Bridgers <vbridger@opensource.altera.com>
---
 Documentation/devicetree/bindings/net/ethernet.txt | 6 ++++++
 Documentation/devicetree/bindings/net/stmmac.txt   | 4 ++++
 2 files changed, 10 insertions(+)

diff --git a/Documentation/devicetree/bindings/net/ethernet.txt b/Documentation/devicetree/bindings/net/ethernet.txt
index 3fc3605..41b3f3f 100644
--- a/Documentation/devicetree/bindings/net/ethernet.txt
+++ b/Documentation/devicetree/bindings/net/ethernet.txt
@@ -19,6 +19,12 @@ The following properties are common to the Ethernet controllers:
 - phy: the same as "phy-handle" property, not recommended for new bindings.
 - phy-device: the same as "phy-handle" property, not recommended for new
   bindings.
+- rx-fifo-depth: the size of the controller's receive fifo in bytes. This
+  is used for components that can have configurable receive fifo sizes,
+  and is useful for determining certain configuration settings such as
+  flow control thresholds.
+- tx-fifo-depth: the size of the controller's transmit fifo in bytes. This
+  is used for components that can have configurable fifo sizes.
 
 Child nodes of the Ethernet controller are typically the individual PHY devices
 connected via the MDIO bus (sometimes the MDIO bus controller is separate).
diff --git a/Documentation/devicetree/bindings/net/stmmac.txt b/Documentation/devicetree/bindings/net/stmmac.txt
index 8ca65ce..524c185 100644
--- a/Documentation/devicetree/bindings/net/stmmac.txt
+++ b/Documentation/devicetree/bindings/net/stmmac.txt
@@ -44,6 +44,8 @@ Optional properties:
   If not passed then the system clock will be used and this is fine on some
   platforms.
 - snps,burst_len: The AXI burst lenth value of the AXI BUS MODE register.
+- tx-fifo-depth: See ethernet.txt file in the same directory
+- rx-fifo-depth: See ethernet.txt file in the same directory
 
 Examples:
 
@@ -58,6 +60,8 @@ Examples:
 		phy-mode = "gmii";
 		snps,multicast-filter-bins = <256>;
 		snps,perfect-filter-entries = <128>;
+		rx-fifo-depth = <16384>;
+		tx-fifo-depth = <16384>;
 		clocks = <&clock>;
 		clock-names = "stmmaceth";
 	};
-- 
1.9.1
