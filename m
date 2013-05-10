From: Simon Horman <horms+renesas@verge.net.au>
Subject: [RFC PATCH net-next] sh_eth: add support for r8a7790 SoC
Date: Fri, 10 May 2013 17:01:31 +0900
Message-ID: <1368172891-26381-1-git-send-email-horms+renesas@verge.net.au>
Cc: Magnus Damm <magnus.damm@gmail.com>,
	Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	Simon Horman <horms+renesas@verge.net.au>
To: netdev@vger.kernel.org, linux-sh@vger.kernel.org
Return-path: <linux-sh-owner@vger.kernel.org>
Sender: linux-sh-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Cc: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Signed-off-by: Simon Horman <horms+renesas@verge.net.au>
---
 drivers/net/ethernet/renesas/Kconfig  |  2 +-
 drivers/net/ethernet/renesas/sh_eth.c | 10 ++++++++--
 drivers/net/ethernet/renesas/sh_eth.h |  1 +
 3 files changed, 10 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/renesas/Kconfig b/drivers/net/ethernet/renesas/Kconfig
index bed9841..d664c0f 100644
--- a/drivers/net/ethernet/renesas/Kconfig
+++ b/drivers/net/ethernet/renesas/Kconfig
@@ -9,7 +9,7 @@ config SH_ETH
 		 CPU_SUBTYPE_SH7763 || CPU_SUBTYPE_SH7619 || \
 		 CPU_SUBTYPE_SH7724 || CPU_SUBTYPE_SH7734 || \
 		 CPU_SUBTYPE_SH7757 || ARCH_R8A7740 || \
-		 ARCH_R8A7778 || ARCH_R8A7779)
+		 ARCH_R8A7778 || ARCH_R8A7779 || ARCH_R8A7790)
 	select CRC32
 	select NET_CORE
 	select MII
diff --git a/drivers/net/ethernet/renesas/sh_eth.c b/drivers/net/ethernet/renesas/sh_eth.c
index 33dc6f2..1ec26bd 100644
--- a/drivers/net/ethernet/renesas/sh_eth.c
+++ b/drivers/net/ethernet/renesas/sh_eth.c
@@ -189,6 +189,7 @@ static const u16 sh_eth_offset_fast_rcar[SH_ETH_MAX_REGISTER_OFFSET] = {
 	[RMCR]		= 0x0258,
 	[TFUCR]		= 0x0264,
 	[RFOCR]		= 0x0268,
+	[RMIIMODE]      = 0x026c,
 	[FCFTR]		= 0x0270,
 	[TRIMD]		= 0x027c,
 };
@@ -342,7 +343,8 @@ static void sh_eth_select_mii(struct net_device *ndev)
 #endif
 
 /* There is CPU dependent code */
-#if defined(CONFIG_ARCH_R8A7778) || defined(CONFIG_ARCH_R8A7779)
+#if defined(CONFIG_ARCH_R8A7778) || defined(CONFIG_ARCH_R8A7779) || \
+	defined(CONFIG_ARCH_R8A7790)
 #define SH_ETH_RESET_DEFAULT	1
 static void sh_eth_set_duplex(struct net_device *ndev)
 {
@@ -370,7 +372,7 @@ static void sh_eth_set_rate(struct net_device *ndev)
 	}
 }
 
-/* R8A7778/9 */
+/* R8A7778, R8A7779, R8A7790 */
 static struct sh_eth_cpu_data sh_eth_my_cpu_data = {
 	.set_duplex	= sh_eth_set_duplex,
 	.set_rate	= sh_eth_set_rate,
@@ -1275,6 +1277,10 @@ static int sh_eth_dev_init(struct net_device *ndev, bool start)
 	if (ret)
 		goto out;
 
+#if defined(CONFIG_ARCH_R8A7790)
+	sh_eth_write(ndev, 0x1, RMIIMODE);
+#endif
+
 	/* Descriptor format */
 	sh_eth_ring_format(ndev);
 	if (mdp->cd->rpadir)
diff --git a/drivers/net/ethernet/renesas/sh_eth.h b/drivers/net/ethernet/renesas/sh_eth.h
index 1ddc9f2..b233a27 100644
--- a/drivers/net/ethernet/renesas/sh_eth.h
+++ b/drivers/net/ethernet/renesas/sh_eth.h
@@ -60,6 +60,7 @@ enum {
 	EDOCR,
 	TFUCR,
 	RFOCR,
+	RMIIMODE,
 	FCFTR,
 	RPADIR,
 	TRIMD,
-- 
1.8.2.1

