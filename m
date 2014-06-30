From: Vince Bridgers <vbridgers2013@gmail.com>
Subject: [PATCH net v2 1/3] dts: Add bindings for multicast hash bins and perfect filter entries
Date: Sun, 29 Jun 2014 20:35:08 -0500
Message-ID: <1404092110-18667-2-git-send-email-vbridgers2013@gmail.com>
References: <1404092110-18667-1-git-send-email-vbridgers2013@gmail.com>
Cc: dinguyen@altera.com, davem@davemloft.net, vbridgers2013@gmail.com,
	vbridger@altera.com
To: netdev@vger.kernel.org, devicetree@vger.kernel.org,
	peppe.cavallaro@st.com, pawel.moll@arm.com, mark.rutland@arm.com,
	ijc+devicetree@hellion.org.uk, galak@codeaurora.org,
	linux@arm.linux.org.uk, linux-arm-kernel@lists.infradead.org,
	robh+dt@kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f47.google.com ([209.85.219.47]:38427 "EHLO
	mail-oa0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753857AbaF3BjE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 29 Jun 2014 21:39:04 -0400
In-Reply-To: <1404092110-18667-1-git-send-email-vbridgers2013@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This change adds bindings for the number of multicast hash bins and perfect
filter entries supported by the Synopsys EMAC. The Synopsys EMAC core is
configurable at device creation time, and can be configured for a different
number of multicast hash bins and a different number of perfect filter
entries. The device does not provide a way to query these parameters,
therefore parameters are required. The Altera Cyclone V SOC has support for
256 multicast hash bins and 128 perfect filter entries, and is different
than what's currently provided in the stmmac driver.

Signed-off-by: Vince Bridgers <vbridgers2013@gmail.com>
Acked-by: Rob Herring <robh@kernel.org>
---
V2: None from last submission
---
 Documentation/devicetree/bindings/net/stmmac.txt |    6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/Documentation/devicetree/bindings/net/stmmac.txt b/Documentation/devicetree/bindings/net/stmmac.txt
index a2acd2b..9b03c57 100644
--- a/Documentation/devicetree/bindings/net/stmmac.txt
+++ b/Documentation/devicetree/bindings/net/stmmac.txt
@@ -25,6 +25,10 @@ Required properties:
 - snps,force_sf_dma_mode	Force DMA to use the Store and Forward
 				mode for both tx and rx. This flag is
 				ignored if force_thresh_dma_mode is set.
+- snps,multicast-filter-bins:	Number of multicast filter hash bins
+				supported by this device instance
+- snps,perfect-filter-entries:	Number of perfect filter entries supported
+				by this device instance
 
 Optional properties:
 - resets: Should contain a phandle to the STMMAC reset signal, if any
@@ -47,6 +51,8 @@ Examples:
 		mac-address = [000000000000]; /* Filled in by U-Boot */
 		max-frame-size = <3800>;
 		phy-mode = "gmii";
+		snps,multicast-filter-bins = <256>;
+		snps,perfect-filter-entries = <128>;
 		clocks = <&clock>;
 		clock-names = "stmmaceth">;
 	};
-- 
1.7.9.5
