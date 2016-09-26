From: Sergei Shtylyov <sergei.shtylyov-M4DtvfQ/ZS1MRgGoP+s0PdBPR1lH4CV8@public.gmane.org>
Subject: [PATCH resend] sh_eth: add R8A7743/5 support
Date: Tue, 27 Sep 2016 01:23:26 +0300
Message-ID: <1654835.SEcvPVx4OQ@wasted.cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-renesas-soc-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, mark.rutland-5wv7dgnIgG8@public.gmane.org,
        devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Add support for the first two members of the Renesas RZ/G family, RZ/G1M/E
(also known as  R8A7743/5). The Ether core is the same as in the R-Car gen2
SoCs, so will share the code/data with them...

Signed-off-by: Sergei Shtylyov <sergei.shtylyov-M4DtvfQ/ZS1MRgGoP+s0PdBPR1lH4CV8@public.gmane.org>

---
The patch is against the DaveM's 'net-next.git' repo.

Re-sending with the DT maintainers/list included this time...

 Documentation/devicetree/bindings/net/sh_eth.txt |    2 ++
 drivers/net/ethernet/renesas/Kconfig             |    2 +-
 drivers/net/ethernet/renesas/sh_eth.c            |    2 ++
 3 files changed, 5 insertions(+), 1 deletion(-)

Index: net-next/Documentation/devicetree/bindings/net/sh_eth.txt
===================================================================
--- net-next.orig/Documentation/devicetree/bindings/net/sh_eth.txt
+++ net-next/Documentation/devicetree/bindings/net/sh_eth.txt
@@ -5,6 +5,8 @@ interface contains.
 
 Required properties:
 - compatible: "renesas,gether-r8a7740" if the device is a part of R8A7740 SoC.
+	      "renesas,ether-r8a7743"  if the device is a part of R8A7743 SoC.
+	      "renesas,ether-r8a7745"  if the device is a part of R8A7745 SoC.
 	      "renesas,ether-r8a7778"  if the device is a part of R8A7778 SoC.
 	      "renesas,ether-r8a7779"  if the device is a part of R8A7779 SoC.
 	      "renesas,ether-r8a7790"  if the device is a part of R8A7790 SoC.
Index: net-next/drivers/net/ethernet/renesas/Kconfig
===================================================================
--- net-next.orig/drivers/net/ethernet/renesas/Kconfig
+++ net-next/drivers/net/ethernet/renesas/Kconfig
@@ -27,7 +27,7 @@ config SH_ETH
 	  Renesas SuperH Ethernet device driver.
 	  This driver supporting CPUs are:
 		- SH7619, SH7710, SH7712, SH7724, SH7734, SH7763, SH7757,
-		  R8A7740, R8A777x and R8A779x.
+		  R8A7740, R8A774x, R8A777x and R8A779x.
 
 config RAVB
 	tristate "Renesas Ethernet AVB support"
Index: net-next/drivers/net/ethernet/renesas/sh_eth.c
===================================================================
--- net-next.orig/drivers/net/ethernet/renesas/sh_eth.c
+++ net-next/drivers/net/ethernet/renesas/sh_eth.c
@@ -2959,6 +2959,8 @@ static struct sh_eth_plat_data *sh_eth_p
 
 static const struct of_device_id sh_eth_match_table[] = {
 	{ .compatible = "renesas,gether-r8a7740", .data = &r8a7740_data },
+	{ .compatible = "renesas,ether-r8a7743", .data = &r8a779x_data },
+	{ .compatible = "renesas,ether-r8a7745", .data = &r8a779x_data },
 	{ .compatible = "renesas,ether-r8a7778", .data = &r8a777x_data },
 	{ .compatible = "renesas,ether-r8a7779", .data = &r8a777x_data },
 	{ .compatible = "renesas,ether-r8a7790", .data = &r8a779x_data },

--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
