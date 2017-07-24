From: Franklin S Cooper Jr <fcooper-l0cyMroinI0@public.gmane.org>
Subject: [PATCH v2 2/4] can: fixed-transceiver: Add documentation for CAN fixed transceiver bindings
Date: Mon, 24 Jul 2017 18:05:19 -0500
Message-ID: <20170724230521.1436-3-fcooper@ti.com>
References: <20170724230521.1436-1-fcooper@ti.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Franklin S Cooper Jr <fcooper-l0cyMroinI0@public.gmane.org>
To: <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <linux-can-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        <wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>, <mkl-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>, <robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
        <quentin.schulz-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org>,
        <dev.kurt-yI9piX4KPfawT/RRk36CISFp6vIno51x@public.gmane.org>, <andrew-g2DYL2Zd6BY@public.gmane.org>,
        <sergei.shtylyov-M4DtvfQ/ZS1MRgGoP+s0PdBPR1lH4CV8@public.gmane.org>, <socketcan-fJ+pQTUTwRTk1uMJSBkQmQ@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20170724230521.1436-1-fcooper-l0cyMroinI0@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Add documentation to describe usage of the new fixed transceiver binding.
This new binding is applicable for any CAN device therefore it exists as
its own document.

Signed-off-by: Franklin S Cooper Jr <fcooper-l0cyMroinI0@public.gmane.org>
---
Version 2:
Tweak commit message working
Tweak wording for properties
Drop unit addressing
Give example if CAN-FD isn't supported

 .../bindings/net/can/fixed-transceiver.txt         | 42 ++++++++++++++++++++++
 1 file changed, 42 insertions(+)
 create mode 100644 Documentation/devicetree/bindings/net/can/fixed-transceiver.txt

diff --git a/Documentation/devicetree/bindings/net/can/fixed-transceiver.txt b/Documentation/devicetree/bindings/net/can/fixed-transceiver.txt
new file mode 100644
index 0000000..dc7e3eb
--- /dev/null
+++ b/Documentation/devicetree/bindings/net/can/fixed-transceiver.txt
@@ -0,0 +1,42 @@
+Fixed transceiver Device Tree binding
+------------------------------
+
+CAN transceiver typically limits the max speed in standard CAN and CAN FD
+modes. Typically these limitations are static and the transceivers themselves
+provide no way to detect this limitation at runtime. For this situation,
+the "fixed-transceiver" node can be used.
+
+Properties:
+
+Optional:
+ max-arbitration-speed: a positive non 0 value that determines the max
+			speed that CAN can run in non CAN-FD mode or during the
+			arbitration phase in CAN-FD mode.
+
+ max-data-speed:	a positive non 0 value that determines the max data rate
+			that can be used in CAN-FD mode. A value of -1 implies
+			CAN-FD is not supported by the transceiver.
+
+Examples:
+
+Based on Texas Instrument's TCAN1042HGV CAN Transceiver
+
+m_can0 {
+	....
+	fixed-transceiver {
+		max-arbitration-speed = <1000000>;
+		max-data-speed = <5000000>;
+	};
+	...
+};
+
+Based on a CAN Transceiver that doesn't support CAN-FD. Only needed if the
+CAN IP supports CAN-FD but is using a transceiver that doesn't.
+
+m_can0 {
+	....
+	fixed-transceiver {
+		max-data-speed = <(-1)>;
+	};
+	...
+};
-- 
2.10.0

--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
