From: Ravi Patel <rapatel@apm.com>
Subject: [PATCH 1/4] Documentation: Add documentation for APM X-Gene SoC Queue
 Manager/Traffic Manager DTS binding
Date: Thu, 19 Dec 2013 18:45:00 -0800
Message-ID: <1387507503-7565-2-git-send-email-rapatel@apm.com>
References: <1387507503-7565-1-git-send-email-rapatel@apm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: devicetree@vger.kernel.org, netdev@vger.kernel.org, patches@apm.com,
 linux-kernel@vger.kernel.org, jcm@redhat.com, Keyur Chudgar <kchudgar@apm.com>,
 linux-arm-kernel@lists.infradead.org, Ravi Patel <rapatel@apm.com>
To: arnd@arndb.de,
	gregkh@linuxfoundation.org,
	davem@davemloft.net
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <1387507503-7565-1-git-send-email-rapatel@apm.com>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: "linux-arm-kernel" <linux-arm-kernel-bounces@lists.infradead.org>
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

This patch adds device tree binding documentation for APM X-Gene SoC
 Queue Manager/Traffic Manager.

Signed-off-by: Ravi Patel <rapatel@apm.com>
Signed-off-by: Keyur Chudgar <kchudgar@apm.com>
---
 .../devicetree/bindings/misc/apm-xgene-qmtm.txt    |   51 ++++++++++++++++++++
 1 file changed, 51 insertions(+)
 create mode 100644 Documentation/devicetree/bindings/misc/apm-xgene-qmtm.txt

diff --git a/Documentation/devicetree/bindings/misc/apm-xgene-qmtm.txt b/Documentation/devicetree/bindings/misc/apm-xgene-qmtm.txt
new file mode 100644
index 0000000..f3234d5
--- /dev/null
+++ b/Documentation/devicetree/bindings/misc/apm-xgene-qmtm.txt
@@ -0,0 +1,51 @@
+* APM X-Gene SOC Queue Manager/Traffic Manager nodes
+
+QMTM nodes are defined to describe on-chip Queue Managers in APM X-Gene SOC.
+APM X-Gene SOC Ethernet, PktDMA, and Security Engine subsystems communicate
+with a central Queue Manager using messages which include information about
+the work to be performed and the location of the associated data buffers.
+There are multiple instances of QMTM. Each QMTM instance has its own node.
+Its corresponding clock nodes are shown below.
+
+Required properties:
+- compatible		: Shall be "apm,xgene-qmtm-lite" for QMLite instance
+- reg			: First memory resource shall be the QMTM CSR memory
+			  resource.
+			  Second memory resource shall be the QMTM IO-Fabric
+			  memory resource.
+- slave-name		: Shall be "CPU_QMTM3" which is receiver for ingress
+			  work messages for the QMTM. Here receiver is CPU.
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
+			clock-names = "qmlclk";
+			status = "ok";
+			csr-offset = <0x0>;
+			csr-mask = <0x3>;
+			enable-offset = <0x8>;
+			enable-mask = <0x3>;
+		};
+
+		qmlite: qmtm@17030000 {
+			compatible = "apm,xgene-qmtm-lite";
+			reg = <0x0 0x17030000 0x0 0x10000>,
+			      <0x0 0x10000000 0x0 0x400000>;
+			slave-name = "CPU_QMTM3";
+			interrupts = <0x0 0x40 0x4>,
+				     <0x0 0x3c 0x4>;
+			status = "ok";
+			#clock-cells = <1>;
+			clocks = <&qmlclk 0>;
+		};
-- 
1.7.9.5

CONFIDENTIALITY NOTICE: This e-mail message, including any attachments, 
is for the sole use of the intended recipient(s) and contains information
that is confidential and proprietary to Applied Micro Circuits Corporation or its subsidiaries. 
It is to be used solely for the purpose of furthering the parties' business relationship. 
All unauthorized review, use, disclosure or distribution is prohibited. 
If you are not the intended recipient, please contact the sender by reply e-mail 
and destroy all copies of the original message.
