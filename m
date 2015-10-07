From: Geert Uytterhoeven <geert+renesas@glider.be>
Subject: [PATCH v2 4/4] sh_eth: Remove obsolete r8a777x-ether platform_device_id entry
Date: Wed,  7 Oct 2015 10:14:17 +0200
Message-ID: <1444205657-25314-5-git-send-email-geert+renesas@glider.be>
References: <1444205657-25314-1-git-send-email-geert+renesas@glider.be>
Cc: netdev@vger.kernel.org, linux-sh@vger.kernel.org,
	Geert Uytterhoeven <geert+renesas@glider.be>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [195.130.132.53] ([195.130.132.53]:39984 "EHLO
	andre.telenet-ops.be" rhost-flags-FAIL-FAIL-OK-OK) by vger.kernel.org
	with ESMTP id S1752296AbbJGKWn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Oct 2015 06:22:43 -0400
In-Reply-To: <1444205657-25314-1-git-send-email-geert+renesas@glider.be>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Since commit 3d7608e4c169af03 ("ARM: shmobile: bockw: remove legacy
board file and config"), R-Car Gen1 SoCs are only supported in generic
DT-only ARM multi-platform builds.  The driver doesn't need to match
platform devices by name anymore, hence remove the corresponding
platform_device_id entry.

Protect sh_eth_set_rate_r8a777x() and r8a777x_data by #ifdef CONFIG_OF,
as they're now referenced on DT platforms only.

Signed-off-by: Geert Uytterhoeven <geert+renesas@glider.be>
---
Commit 3d7608e4c169af03 is now in arm-soc/for-next.

v2:
  - New.
---
 drivers/net/ethernet/renesas/sh_eth.c | 3 ---
 1 file changed, 3 deletions(-)

diff --git a/drivers/net/ethernet/renesas/sh_eth.c b/drivers/net/ethernet/renesas/sh_eth.c
index 6395d2fc2bd8..48a3192f4af2 100644
--- a/drivers/net/ethernet/renesas/sh_eth.c
+++ b/drivers/net/ethernet/renesas/sh_eth.c
@@ -551,7 +551,6 @@ static struct sh_eth_cpu_data r8a7740_data = {
 	.select_mii	= 1,
 	.shift_rd0	= 1,
 };
-#endif /* CONFIG_OF */
 
 /* There is CPU dependent code */
 static void sh_eth_set_rate_r8a777x(struct net_device *ndev)
@@ -593,7 +592,6 @@ static struct sh_eth_cpu_data r8a777x_data = {
 	.hw_swap	= 1,
 };
 
-#ifdef CONFIG_OF
 /* R8A7790/1 */
 static struct sh_eth_cpu_data r8a779x_data = {
 	.set_duplex	= sh_eth_set_duplex,
@@ -3305,7 +3303,6 @@ static struct platform_device_id sh_eth_id_table[] = {
 	{ "sh7757-ether", (kernel_ulong_t)&sh7757_data },
 	{ "sh7757-gether", (kernel_ulong_t)&sh7757_data_giga },
 	{ "sh7763-gether", (kernel_ulong_t)&sh7763_data },
-	{ "r8a777x-ether", (kernel_ulong_t)&r8a777x_data },
 	{ }
 };
 MODULE_DEVICE_TABLE(platform, sh_eth_id_table);
-- 
1.9.1
