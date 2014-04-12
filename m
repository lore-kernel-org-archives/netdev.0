From: Iyappan Subramanian <isubramanian@apm.com>
Subject: [PATCH v2 2/4] Documentation: dts: Add bindings for APM X-Gene SoC ethernet driver
Date: Fri, 11 Apr 2014 20:06:22 -0700
Message-ID: <1397271984-23405-3-git-send-email-isubramanian@apm.com>
References: <1397271984-23405-1-git-send-email-isubramanian@apm.com>
Cc: gregkh@linuxfoundation.org, linux-kernel@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org, jcm@redhat.com,
	patches@apm.com, Iyappan Subramanian <isubramanian@apm.com>,
	Ravi Patel <rapatel@apm.com>, Keyur Chudgar <kchudgar@apm.com>
To: davem@davemloft.net, netdev@vger.kernel.org,
	devicetree@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from exprod5og108.obsmtp.com ([64.18.0.186]:57256 "HELO
	exprod5og108.obsmtp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1756075AbaDLDG1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Apr 2014 23:06:27 -0400
Received: by mail-pd0-f174.google.com with SMTP id y13so5955805pdi.5
        for <netdev@vger.kernel.org>; Fri, 11 Apr 2014 20:06:26 -0700 (PDT)
In-Reply-To: <1397271984-23405-1-git-send-email-isubramanian@apm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds documentation for APM X-Gene SoC ethernet DTS binding.

Signed-off-by: Iyappan Subramanian <isubramanian@apm.com>
Signed-off-by: Ravi Patel <rapatel@apm.com>
Signed-off-by: Keyur Chudgar <kchudgar@apm.com>
---
 .../devicetree/bindings/net/apm-xgene-enet.txt     |   46 ++++++++++++++++++++
 1 file changed, 46 insertions(+)
 create mode 100644 Documentation/devicetree/bindings/net/apm-xgene-enet.txt

diff --git a/Documentation/devicetree/bindings/net/apm-xgene-enet.txt b/Documentation/devicetree/bindings/net/apm-xgene-enet.txt
new file mode 100644
index 0000000..0c983e8
--- /dev/null
+++ b/Documentation/devicetree/bindings/net/apm-xgene-enet.txt
@@ -0,0 +1,46 @@
+APM X-Gene SoC Ethernet nodes
+
+Ethernet nodes are defined to describe on-chip ethernet interfaces in
+APM X-Gene SoC.
+
+Required properties:
+- compatible		: Should be "apm,xgene-enet"
+- reg			: First resource is the ethernet base register set
+			  Second resource is the ring base register set
+			  Third resource is the ring command register set
+- interrupts		: Ethernet main interrupt
+- clocks		: Reference to the clock entry.
+- local-mac-address	: Ethernet MAC address.
+- phy-addr		: Ethernet MII phy address.
+- phy-mode		: Ethernet MII mode.
+
+Optional properties:
+- status		: Should be "ok" or "disabled" for enabled/disabled.
+			  Default is "ok".
+
+Example:
+	menetclk: menetclk {
+		compatible = "apm,xgene-device-clock";
+		clock-output-names = "menetclk";
+		status = "ok";
+	};
+
+	menet: ethernet@17020000 {
+		compatible = "apm,xgene-enet";
+		status = "disabled";
+		reg = <0x0 0x17020000 0x0 0xd100>,
+		      <0x0 0X17030000 0x0 0X400>,
+		      <0x0 0X10000000 0x0 0X200>;
+		interrupts = <0x0 0x3c 0x4>;
+		clocks = <&menetclk 0>;
+		local-mac-address = [00 01 73 00 00 01];
+		phy-addr = <3>;
+		phy-mode = "rgmii";
+	};
+
+
+/* Board-specific peripheral configurations */
+
+&menet {
+        status = "ok";
+};
-- 
1.7.9.5
