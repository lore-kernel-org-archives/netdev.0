From: Geert Uytterhoeven <geert+renesas@glider.be>
Subject: [PATCH v3 2/4] sh_eth: Remove obsolete r8a779x-ether platform_device_id entries
Date: Tue, 24 Nov 2015 15:40:58 +0100
Message-ID: <1448376060-7803-3-git-send-email-geert+renesas@glider.be>
References: <1448376060-7803-1-git-send-email-geert+renesas@glider.be>
Cc: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	netdev@vger.kernel.org, linux-sh@vger.kernel.org,
	Geert Uytterhoeven <geert+renesas@glider.be>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from laurent.telenet-ops.be ([195.130.137.89]:49353 "EHLO
	laurent.telenet-ops.be" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754126AbbKXOk4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Nov 2015 09:40:56 -0500
In-Reply-To: <1448376060-7803-1-git-send-email-geert+renesas@glider.be>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Since commit a483dcbfa21f919c ("ARM: shmobile: lager: Remove legacy
board support"), R-Car Gen2 SoCs are only supported in generic DT-only
ARM multi-platform builds.  The driver doesn't need to match platform
devices by name anymore, hence remove the corresponding
platform_device_id entry.

Protect r8a779x_data by #ifdef CONFIG_OF as it's now referenced on DT
platforms only.

Signed-off-by: Geert Uytterhoeven <geert+renesas@glider.be>
Acked-by: Simon Horman <horms+renesas@verge.net.au>
---
v3:
  - No changes,

v2:
  - Add Acked-by,
  - Protect r8a779x_data by #ifdef CONFIG_OF to silence a compiler
    warning on SH.
---
 drivers/net/ethernet/renesas/sh_eth.c | 6 ++----
 1 file changed, 2 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/renesas/sh_eth.c b/drivers/net/ethernet/renesas/sh_eth.c
index fca688fbefc1c49d..1af07f9de243d613 100644
--- a/drivers/net/ethernet/renesas/sh_eth.c
+++ b/drivers/net/ethernet/renesas/sh_eth.c
@@ -531,6 +531,7 @@ static struct sh_eth_cpu_data r8a777x_data = {
 	.hw_swap	= 1,
 };
 
+#ifdef CONFIG_OF
 /* R8A7790/1 */
 static struct sh_eth_cpu_data r8a779x_data = {
 	.set_duplex	= sh_eth_set_duplex,
@@ -556,6 +557,7 @@ static struct sh_eth_cpu_data r8a779x_data = {
 	.hw_swap	= 1,
 	.rmiimode	= 1,
 };
+#endif /* CONFIG_OF */
 
 static void sh_eth_set_rate_sh7724(struct net_device *ndev)
 {
@@ -3281,10 +3283,6 @@ static struct platform_device_id sh_eth_id_table[] = {
 	{ "sh7763-gether", (kernel_ulong_t)&sh7763_data },
 	{ "r8a7740-gether", (kernel_ulong_t)&r8a7740_data },
 	{ "r8a777x-ether", (kernel_ulong_t)&r8a777x_data },
-	{ "r8a7790-ether", (kernel_ulong_t)&r8a779x_data },
-	{ "r8a7791-ether", (kernel_ulong_t)&r8a779x_data },
-	{ "r8a7793-ether", (kernel_ulong_t)&r8a779x_data },
-	{ "r8a7794-ether", (kernel_ulong_t)&r8a779x_data },
 	{ }
 };
 MODULE_DEVICE_TABLE(platform, sh_eth_id_table);
-- 
1.9.1
