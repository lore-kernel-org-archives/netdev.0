From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: [PATCH] sh_eth: add R8A7743/5 support
Date: Tue, 27 Sep 2016 01:07:01 +0300
Message-ID: <1707101.iYqqKafBon@wasted.cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
To: netdev@vger.kernel.org, linux-renesas-soc@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f42.google.com ([209.85.215.42]:35929 "EHLO
        mail-lf0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751972AbcIZWHJ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 26 Sep 2016 18:07:09 -0400
Received: by mail-lf0-f42.google.com with SMTP id g62so160462348lfe.3
        for <netdev@vger.kernel.org>; Mon, 26 Sep 2016 15:07:08 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add support for the first two members of the Renesas RZ/G family, RZ/G1M/E
(also known as  R8A7743/5). The Ether core is the same as in the R-Car gen2
SoCs, so will share the code/data with them...

Signed-off-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>

---
The patch is against the DaveM's 'net-next.git' repo.

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
