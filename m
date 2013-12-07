From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: [PATCH v2] sh_eth: add R8A7791 support
Date: Sun, 8 Dec 2013 02:59:18 +0300
Message-ID: <201312080259.19163.sergei.shtylyov@cogentembedded.com>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: linux-sh@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f44.google.com ([209.85.215.44]:35122 "EHLO
	mail-la0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753222Ab3LGW7T (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 7 Dec 2013 17:59:19 -0500
Received: by mail-la0-f44.google.com with SMTP id ep20so821642lab.17
        for <netdev@vger.kernel.org>; Sat, 07 Dec 2013 14:59:18 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add support for yet another ARM member of the R-Car family, R-Car M2, also known
as R8A7791 -- it will share the code and data with previously added R8A7790.
Despite the Ether devices in these SoCs are indistinguishable at least from the
driver's point of view, we do introduce a new platform device ID "r8a7791-ether"
unlike the wildcard ID used for R8A7778/9 SoCs, due to newly established policy
for the Renesas SoCs.

Signed-off-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>

---
This patch is atop of DaveM's 'net-next.git' repo.

Changes in version 2:
- added a new platform device ID for R8A7791 instead of changing the existing ID
  for R8A7790 to a R8A779x wildcard ID.

 drivers/net/ethernet/renesas/Kconfig  |    2 +-
 drivers/net/ethernet/renesas/sh_eth.c |    7 ++++---
 2 files changed, 5 insertions(+), 4 deletions(-)

Index: net-next/drivers/net/ethernet/renesas/Kconfig
===================================================================
--- net-next.orig/drivers/net/ethernet/renesas/Kconfig
+++ net-next/drivers/net/ethernet/renesas/Kconfig
@@ -13,4 +13,4 @@ config SH_ETH
 	  Renesas SuperH Ethernet device driver.
 	  This driver supporting CPUs are:
 		- SH7619, SH7710, SH7712, SH7724, SH7734, SH7763, SH7757,
-		  R8A7740, R8A777x and R8A7790.
+		  R8A7740, R8A777x and R8A779x.
Index: net-next/drivers/net/ethernet/renesas/sh_eth.c
===================================================================
--- net-next.orig/drivers/net/ethernet/renesas/sh_eth.c
+++ net-next/drivers/net/ethernet/renesas/sh_eth.c
@@ -395,8 +395,8 @@ static struct sh_eth_cpu_data r8a777x_da
 	.hw_swap	= 1,
 };
 
-/* R8A7790 */
-static struct sh_eth_cpu_data r8a7790_data = {
+/* R8A7790/1 */
+static struct sh_eth_cpu_data r8a779x_data = {
 	.set_duplex	= sh_eth_set_duplex,
 	.set_rate	= sh_eth_set_rate_r8a777x,
 
@@ -2807,7 +2807,8 @@ static struct platform_device_id sh_eth_
 	{ "sh7763-gether", (kernel_ulong_t)&sh7763_data },
 	{ "r8a7740-gether", (kernel_ulong_t)&r8a7740_data },
 	{ "r8a777x-ether", (kernel_ulong_t)&r8a777x_data },
-	{ "r8a7790-ether", (kernel_ulong_t)&r8a7790_data },
+	{ "r8a7790-ether", (kernel_ulong_t)&r8a779x_data },
+	{ "r8a7791-ether", (kernel_ulong_t)&r8a779x_data },
 	{ }
 };
 MODULE_DEVICE_TABLE(platform, sh_eth_id_table);
