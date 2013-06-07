From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: [PATCH 3/9] sh_eth: get SH7619 support out of #ifdef
Date: Sat, 8 Jun 2013 03:56:05 +0400
Message-ID: <201306080356.05904.sergei.shtylyov@cogentembedded.com>
References: <201306080351.39018.sergei.shtylyov@cogentembedded.com>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: nobuhiro.iwamatsu.yj@renesas.com, linux-sh@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f181.google.com ([209.85.217.181]:58263 "EHLO
	mail-lb0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756613Ab3FGXz7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Jun 2013 19:55:59 -0400
Received: by mail-lb0-f181.google.com with SMTP id w10so2041533lbi.26
        for <netdev@vger.kernel.org>; Fri, 07 Jun 2013 16:55:58 -0700 (PDT)
In-Reply-To: <201306080351.39018.sergei.shtylyov@cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Get  the SH7619 data in the driver out of #ifdef by adding "sh7619-ether" to the
platform driver's ID table. Change the Ether platform device's name  in  the SH
platform code accordingly.

Signed-off-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>

---
Note that in this case the driver's probe will crash anyway as the platform code
is hopelessly behind since it passes PHY ID instead of 'struct sh_eth_plat_data'
pointer as a platform data.

 arch/sh/kernel/cpu/sh2/setup-sh7619.c |    4 ++--
 drivers/net/ethernet/renesas/sh_eth.c |    6 +++---
 2 files changed, 5 insertions(+), 5 deletions(-)

Index: net-next/arch/sh/kernel/cpu/sh2/setup-sh7619.c
===================================================================
--- net-next.orig/arch/sh/kernel/cpu/sh2/setup-sh7619.c
+++ net-next/arch/sh/kernel/cpu/sh2/setup-sh7619.c
@@ -124,8 +124,8 @@ static struct resource eth_resources[] =
 };
 
 static struct platform_device eth_device = {
-	.name = "sh-eth",
-	.id	= -1,
+	.name = "sh7619-ether",
+	.id = -1,
 	.dev = {
 		.platform_data = (void *)1,
 	},
Index: net-next/drivers/net/ethernet/renesas/sh_eth.c
===================================================================
--- net-next.orig/drivers/net/ethernet/renesas/sh_eth.c
+++ net-next/drivers/net/ethernet/renesas/sh_eth.c
@@ -680,9 +680,9 @@ static struct sh_eth_cpu_data sh_eth_my_
 	.tsu		= 1,
 	.select_mii	= 1,
 };
+#endif
 
-#elif defined(CONFIG_CPU_SUBTYPE_SH7619)
-static struct sh_eth_cpu_data sh_eth_my_cpu_data = {
+static struct sh_eth_cpu_data sh7619_data = {
 	.eesipr_value	= DMAC_M_RFRMER | DMAC_M_ECI | 0x003fffff,
 
 	.apr		= 1,
@@ -690,7 +690,6 @@ static struct sh_eth_cpu_data sh_eth_my_
 	.tpauser	= 1,
 	.hw_swap	= 1,
 };
-#endif
 
 static struct sh_eth_cpu_data sh771x_data = {
 	.eesipr_value	= DMAC_M_RFRMER | DMAC_M_ECI | 0x003fffff,
@@ -2700,6 +2699,7 @@ static const struct dev_pm_ops sh_eth_de
 #endif
 
 static struct platform_device_id sh_eth_id_table[] = {
+	{ "sh7619-ether", (kernel_ulong_t)&sh7619_data },
 	{ "sh771x-ether", (kernel_ulong_t)&sh771x_data },
 	{ CARDNAME },
 	{ }
