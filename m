From: Wolfgang Grandegger <wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>
Subject: [PATCH net-next v2 3/3] powerpc/mpc5xxx: add OF platform binding doc
	for FSL MSCAN devices
Date: Tue,  5 Jan 2010 20:20:41 +0100
Message-ID: <1262719241-2422-4-git-send-email-wg@grandegger.com>
References: <1262719241-2422-1-git-send-email-wg@grandegger.com>
	<1262719241-2422-2-git-send-email-wg@grandegger.com>
	<1262719241-2422-3-git-send-email-wg@grandegger.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org, Devicetree-discuss-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org,
	Linuxppc-dev-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org, Wolfgang Grandegger <wg-ynQEQJNshbs@public.gmane.org>
To: Netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
In-Reply-To: <1262719241-2422-3-git-send-email-wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>
List-Unsubscribe: <https://lists.berlios.de/mailman/listinfo/socketcan-core>,
	<mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=unsubscribe>
List-Archive: <https://lists.berlios.de/pipermail/socketcan-core>
List-Post: <mailto:socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
List-Help: <mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=help>
List-Subscribe: <https://lists.berlios.de/mailman/listinfo/socketcan-core>,
	<mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=subscribe>
Sender: socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
Errors-To: socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Wolfgang Grandegger <wg-ynQEQJNshbs@public.gmane.org>

This patch adds documentation for the MSCAN OF device bindings for
the MPC512x and moves the one for the MPC5200 to the new common file
"Documentation/powerpc/dts-bindings/fsl/can.txt".

Signed-off-by: Wolfgang Grandegger <wg-ynQEQJNshbs@public.gmane.org>
Acked-by: Wolfram Sang <w.sang-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
---
 Documentation/powerpc/dts-bindings/fsl/can.txt     |   53 ++++++++++++++++++++
 Documentation/powerpc/dts-bindings/fsl/mpc5200.txt |    9 +---
 2 files changed, 54 insertions(+), 8 deletions(-)
 create mode 100644 Documentation/powerpc/dts-bindings/fsl/can.txt

diff --git a/Documentation/powerpc/dts-bindings/fsl/can.txt b/Documentation/powerpc/dts-bindings/fsl/can.txt
new file mode 100644
index 0000000..2fa4fcd
--- /dev/null
+++ b/Documentation/powerpc/dts-bindings/fsl/can.txt
@@ -0,0 +1,53 @@
+CAN Device Tree Bindings
+------------------------
+
+(c) 2006-2009 Secret Lab Technologies Ltd
+Grant Likely <grant.likely-s3s/WqlpOiPyB63q8FvJNQ@public.gmane.org>
+
+fsl,mpc5200-mscan nodes
+-----------------------
+In addition to the required compatible-, reg- and interrupt-properties, you can
+also specify which clock source shall be used for the controller:
+
+- fsl,mscan-clock-source : a string describing the clock source. Valid values
+			   are:	"ip" for ip bus clock
+				 "ref" for reference clock (XTAL)
+			   "ref" is default in case this property is not
+			   present.
+
+fsl,mpc5121-mscan nodes
+-----------------------
+In addition to the required compatible-, reg- and interrupt-properties, you can
+also specify which clock source and divider shall be used for the controller:
+
+- fsl,mscan-clock-source : a string describing the clock source. Valid values
+			   are:	"ip" for ip bus clock
+				"ref" for reference clock
+				"sys" for system clock
+			   If this property is not present, an optimal CAN
+			   clock source and frequency based on the system
+			   clock will be selected. If this is not possible,
+			   the reference clock will be used.
+
+- fsl,mscan-clock-divider: for the reference and system clock, an additional
+			   clock divider can be specified. By default, a
+			   value of 1 is used.
+
+Note that the MPC5121 Rev. 1 processor is not supported.
+
+Examples:
+	can@1300 {
+		compatible = "fsl,mpc5121-mscan";
+		interrupts = <12 0x8>;
+		interrupt-parent = <&ipic>;
+		reg = <0x1300 0x80>;
+	};
+
+	can@1380 {
+		compatible = "fsl,mpc5121-mscan";
+		interrupts = <13 0x8>;
+		interrupt-parent = <&ipic>;
+		reg = <0x1380 0x80>;
+		fsl,mscan-clock-source = "ref";
+		fsl,mscan-clock-divider = <3>;
+	};
diff --git a/Documentation/powerpc/dts-bindings/fsl/mpc5200.txt b/Documentation/powerpc/dts-bindings/fsl/mpc5200.txt
index cabc780..95accfa 100644
--- a/Documentation/powerpc/dts-bindings/fsl/mpc5200.txt
+++ b/Documentation/powerpc/dts-bindings/fsl/mpc5200.txt
@@ -180,11 +180,4 @@ External interrupts:
 
 fsl,mpc5200-mscan nodes
 -----------------------
-In addition to the required compatible-, reg- and interrupt-properites, you can
-also specify which clock source shall be used for the controller:
-
-- fsl,mscan-clock-source- a string describing the clock source. Valid values
-			  are:	"ip" for ip bus clock
-				"ref" for reference clock (XTAL)
-			  "ref" is default in case this property is not
-			  present.
+See file can.txt in this directory.
-- 
1.6.2.5
