From: Ravi Patel <rapatel@apm.com>
Subject: [PATCH V3 2/4] Documentation: devicetree: bindings for APM X-Gene SoC QMTM
Date: Fri, 14 Feb 2014 18:22:00 -0800
Message-ID: <1392430922-24643-3-git-send-email-rapatel@apm.com>
References: <1392430922-24643-1-git-send-email-rapatel@apm.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	devicetree@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	jcm@redhat.com, patches@apm.com, Ravi Patel <rapatel@apm.com>,
	Keyur Chudgar <kchudgar@apm.com>
To: arnd@arndb.de, gregkh@linuxfoundation.org, davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1392430922-24643-1-git-send-email-rapatel@apm.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch adds devicetree bindings documentation for APM X-Gene SoC Queue
Manager/Traffic Manager.

Signed-off-by: Ravi Patel <rapatel@apm.com>
Signed-off-by: Keyur Chudgar <kchudgar@apm.com>
---
 .../devicetree/bindings/mailbox/apm-xgene-qmtm.txt |   53 ++++++++++++++++++++
 1 file changed, 53 insertions(+)
 create mode 100644 Documentation/devicetree/bindings/mailbox/apm-xgene-qmtm.txt

diff --git a/Documentation/devicetree/bindings/mailbox/apm-xgene-qmtm.txt b/Documentation/devicetree/bindings/mailbox/apm-xgene-qmtm.txt
new file mode 100644
index 0000000..cb17d5f
--- /dev/null
+++ b/Documentation/devicetree/bindings/mailbox/apm-xgene-qmtm.txt
@@ -0,0 +1,53 @@
+* APM X-Gene SoC Queue Manager/Traffic Manager mailbox nodes
+
+Mailbox nodes are defined to describe on-chip Queue Managers in APM X-Gene SoC.
+APM X-Gene SoC Ethernet, PktDMA (XOR Engine), and Security Engine subsystems
+communicate with a central Queue Manager using messages which include
+information about the work to be performed and the location of the associated
+data buffers. There are multiple instances of QMTM. Each QMTM instance has its
+own node. Its corresponding clock nodes are shown below.
+
+Required properties:
+- compatible		: Shall be "apm,xgene-qmtm"
+- reg			: First memory resource shall be the QMTM register
+			  memory resource.
+			  Second memory resource shall be the QMTM IO-Fabric
+			  memory resource.
+- #mailbox-cells	: Shall be 4 as it expects following arguments
+			  First cell for 64-bit mailbox bus address MSB.
+			  Second cell for 64-bit mailbox bus address LSB.
+			  Third cell for 32-bit mailbox size.
+			  Fourth cell for 32-bit mailbox signal/id value.
+- interrupts		: First interrupt resource shall be the QMTM Error
+			  interrupt.
+			  Remaining interrupt resources shall be the Ingress
+			  work message interrupt mapping for receiver,
+			  receiving work messages for the QMTM.
+- clocks		: Reference to the clock entry.
+
+Optional properties:
+- status		: Shall be "ok" if enabled or "disabled" if disabled.
+			  Default is "ok".
+
+Example:
+		qmlclk: qmlclk {
+			compatible = "apm,xgene-device-clock";
+			#clock-cells = <1>;
+			clock-names = "socplldiv2";
+			status = "ok";
+			csr-offset = <0x0>;
+			csr-mask = <0x3>;
+			enable-offset = <0x8>;
+			enable-mask = <0x3>;
+		};
+
+		qmlite: mailbox@17030000 {
+			compatible = "apm,xgene-qmtm";
+			#mailbox-cells = <4>;
+			status = "ok";
+			reg = <0x0 0x17030000 0x0 0x10000>,
+			      <0x0 0x10000000 0x0 0x400000>;
+			interrupts = <0x0 0x40 0x4>,
+				     <0x0 0x3c 0x4>;
+			clocks = <&qmlclk 0>;
+		};
-- 
1.7.9.5
