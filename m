From: Bjorn Andersson <bjorn@kryo.se>
Subject: [PATCH 4/4] dt: binding: Add Qualcomm wcn36xx WiFi binding
Date: Sun, 27 Dec 2015 17:34:27 -0800
Message-ID: <1451266467-15377-5-git-send-email-bjorn.andersson@sonymobile.com>
References: <1451266467-15377-1-git-send-email-bjorn.andersson@sonymobile.com>
Cc: devicetree@vger.kernel.org, fengwei.yin@linaro.org,
	linux-arm-msm@vger.kernel.org, linux-kernel@vger.kernel.org,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	wcn36xx@lists.infradead.org
To: Eugene Krasnikov <k.eugene.e@gmail.com>,
	Ian Campbell <ijc+devicetree@hellion.org.uk>,
	Kalle Valo <kvalo@codeaurora.org>,
	Mark Rutland <mark.rutland@arm.com>,
	Pawel Moll <pawel.moll@arm.com>,
	Rob Herring <robh+dt@kernel.org>
Return-path: <linux-arm-msm-owner@vger.kernel.org>
In-Reply-To: <1451266467-15377-1-git-send-email-bjorn.andersson@sonymobile.com>
Sender: linux-arm-msm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add binding representing the Qualcomm wcn3620/60/80 WiFi block.

Signed-off-by: Bjorn Andersson <bjorn.andersson@sonymobile.com>
---
 .../bindings/net/wireless/qcom,wcn36xx-wifi.txt    | 76 ++++++++++++++++++++++
 1 file changed, 76 insertions(+)
 create mode 100644 Documentation/devicetree/bindings/net/wireless/qcom,wcn36xx-wifi.txt

diff --git a/Documentation/devicetree/bindings/net/wireless/qcom,wcn36xx-wifi.txt b/Documentation/devicetree/bindings/net/wireless/qcom,wcn36xx-wifi.txt
new file mode 100644
index 000000000000..7b314b9f30af
--- /dev/null
+++ b/Documentation/devicetree/bindings/net/wireless/qcom,wcn36xx-wifi.txt
@@ -0,0 +1,76 @@
+Qualcomm WCN36xx WiFi Binding
+
+This binding describes the Qualcomm WCN36xx WiFi hardware. The hardware block
+is part of the Qualcomm WCNSS core, a WiFi/BT/FM combo chip, found in a variety
+of Qualcomm platforms.
+
+- compatible:
+	Usage: required
+	Value type: <string>
+	Definition: must be one of:
+		    "qcom,wcn3620-wlan",
+		    "qcom,wcn3660-wlan",
+		    "qcom,wcn3680-wlan"
+
+- qcom,smd-channel:
+	Usage: required
+	Value type: <string>
+	Definition: standard SMD property specifying the SMD channel used for
+		    communication with the WiFi firmware
+
+- interrupts:
+	Usage: required
+	Value type: <prop-encoded-array>
+	Definition: should specify the two IRQs for tx and rx respectively
+
+- qcom,wcnss-mmio:
+	Usage: required
+	Value type: <prop-encoed-array>
+	Definition: should specify base address and size of the WiFi related
+		    registers of WCNSS
+
+- qcom,state:
+	Usage: required
+	Value type: <prop-encoded-array>
+	Definition: should specify the tx-enable and tx-ring-empty state
+		    references
+
+- qcom,state-names:
+	Usage: required
+	Value type: <stringlist>
+	Definition: name of the states, must be "tx-enable", "tx-rings-empty";
+
+- local-mac-address:
+	Usage: optional
+	Value type: <prop-encoded-array> encoded as array of hex numbers
+	Definition: specifies MAC address that was assigned to the network
+		    device described by the node containing this property.
+
+= EXAMPLE
+The following example represents a SMD node, with one edge representing the
+"pronto" subsystem, with the wcn3680 WiFi device described; as found on the
+8974 platform.
+
+smd {
+	compatible = "qcom,smd";
+
+	pronto {
+		interrupts = <0 142 1>;
+
+		qcom,ipc = <&apcs 8 17>;
+		qcom,smd-edge = <6>;
+
+		wifi {
+			compatible = "qcom,wcn3680-wlan";
+			qcom,smd-channels = "WLAN_CTRL";
+
+			interrupts = <0 145 0>, <0 146 0>;
+			interrupt-names = "tx", "rx";
+
+			qcom,wcnss-mmio = <0xfb000000 0x21b000>;
+
+			qcom,state = <&apps_smsm 10>, <&apps_smsm 9>;
+			qcom,state-names = "tx-enable", "tx-rings-empty";
+		};
+	};
+};
-- 
2.5.0
