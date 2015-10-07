From: Geert Uytterhoeven <geert+renesas@glider.be>
Subject: [PATCH v2 2/4] sh_eth: Remove obsolete r8a779x-ether platform_device_id entries
Date: Wed,  7 Oct 2015 10:14:15 +0200
Message-ID: <1444205657-25314-3-git-send-email-geert+renesas@glider.be>
References: <1444205657-25314-1-git-send-email-geert+renesas@glider.be>
Cc: netdev@vger.kernel.org, linux-sh@vger.kernel.org,
	Geert Uytterhoeven <geert+renesas@glider.be>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-sh-owner@vger.kernel.org>
In-Reply-To: <1444205657-25314-1-git-send-email-geert+renesas@glider.be>
Sender: linux-sh-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

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
v2:
  - Add Acked-by,
  - Protect r8a779x_data by #ifdef CONFIG_OF to silence a compiler
    warning on SH.
---
 drivers/net/ethernet/renesas/sh_eth.c | 6 ++----
 1 file changed, 2 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/renesas/sh_eth.c b/drivers/net/ethernet/renesas/sh_eth.c
index 1bff9e21d920..029ea449f901 100644
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
@@ -3305,10 +3307,6 @@ static struct platform_device_id sh_eth_id_table[] = {
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

