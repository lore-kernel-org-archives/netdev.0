From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: [PATCH] DT: net: davinci_emac: "phy-handle" property is actually optional
Date: Fri, 17 Jan 2014 01:32:13 +0300
Message-ID: <201401170132.14479.sergei.shtylyov@cogentembedded.com>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: linux-doc@vger.kernel.org,
	davinci-linux-open-source@linux.davincidsp.com
To: netdev@vger.kernel.org, robh+dt@kernel.org, pawel.moll@arm.com,
	mark.rutland@arm.com, ijc+devicetree@hellion.org.uk,
	galak@codeaurora.org, rob@landley.net, devicetree@vger.kernel.org
Return-path: <linux-doc-owner@vger.kernel.org>
Sender: linux-doc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Though described as required, the "phy-handle" property for the DaVinci EMAC
binding is actually optional, as the driver will happily function without it,
assuming 100/FULL link; the property is not specified  either in the example
device node,  or in the actual EMAC device nodes for DA850 and AM3517 device
trees.

Signed-off-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>

---
The patch is against DaveM's 'net-next.git' repo.  Though being a fix, it does
not seem important enough for 'net.git' repo at this time. Not sure if it should
be considered for the stable kernels...

 Documentation/devicetree/bindings/net/davinci_emac.txt |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

Index: renesas/Documentation/devicetree/bindings/net/davinci_emac.txt
===================================================================
--- renesas.orig/Documentation/devicetree/bindings/net/davinci_emac.txt
+++ renesas/Documentation/devicetree/bindings/net/davinci_emac.txt
@@ -12,8 +12,6 @@ Required properties:
 - ti,davinci-ctrl-ram-size: size of control module ram
 - ti,davinci-rmii-en: use RMII
 - ti,davinci-no-bd-ram: has the emac controller BD RAM
-- phy-handle: Contains a phandle to an Ethernet PHY.
-              if not, davinci_emac driver defaults to 100/FULL
 - interrupts: interrupt mapping for the davinci emac interrupts sources:
               4 sources: <Receive Threshold Interrupt
 			  Receive Interrupt
@@ -21,6 +19,8 @@ Required properties:
 			  Miscellaneous Interrupt>
 
 Optional properties:
+- phy-handle: Contains a phandle to an Ethernet PHY.
+              If absent, davinci_emac driver defaults to 100/FULL.
 - local-mac-address : 6 bytes, mac address
 
 Example (enbw_cmc board):
