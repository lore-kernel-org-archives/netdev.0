From: Javier Martinez Canillas <javier@osg.samsung.com>
Subject: [PATCH 06/15] net/fsl_pq_mdio: use IS_ENABLED() instead of checking for built-in or module
Date: Mon, 12 Sep 2016 10:03:37 -0400
Message-ID: <1473689026-6983-7-git-send-email-javier@osg.samsung.com>
References: <1473689026-6983-1-git-send-email-javier@osg.samsung.com>
Cc: Javier Martinez Canillas <javier@osg.samsung.com>,
        Zhao Qiang <qiang.zhao@freescale.com>,
        Arnd Bergmann <arnd@arndb.de>, netdev@vger.kernel.org,
        Gerlando Falauto <gerlando.falauto@keymile.com>,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Andrew Lunn <andrew@lunn.ch>
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1473689026-6983-1-git-send-email-javier@osg.samsung.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The IS_ENABLED() macro checks if a Kconfig symbol has been enabled either
built-in or as a module, use that macro instead of open coding the same.

Using the macro makes the code more readable by helping abstract away some
of the Kconfig built-in and module enable details.

Signed-off-by: Javier Martinez Canillas <javier@osg.samsung.com>
---

 drivers/net/ethernet/freescale/fsl_pq_mdio.c | 8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/freescale/fsl_pq_mdio.c b/drivers/net/ethernet/freescale/fsl_pq_mdio.c
index f3c63dce1e30..446c7b374ff5 100644
--- a/drivers/net/ethernet/freescale/fsl_pq_mdio.c
+++ b/drivers/net/ethernet/freescale/fsl_pq_mdio.c
@@ -195,7 +195,7 @@ static int fsl_pq_mdio_reset(struct mii_bus *bus)
 	return 0;
 }
 
-#if defined(CONFIG_GIANFAR) || defined(CONFIG_GIANFAR_MODULE)
+#if IS_ENABLED(CONFIG_GIANFAR)
 /*
  * Return the TBIPA address, starting from the address
  * of the mapped GFAR MDIO registers (struct gfar)
@@ -228,7 +228,7 @@ static uint32_t __iomem *get_etsec_tbipa(void __iomem *p)
 }
 #endif
 
-#if defined(CONFIG_UCC_GETH) || defined(CONFIG_UCC_GETH_MODULE)
+#if IS_ENABLED(CONFIG_UCC_GETH)
 /*
  * Return the TBIPAR address for a QE MDIO node, starting from the address
  * of the mapped MII registers (struct fsl_pq_mii)
@@ -306,7 +306,7 @@ static void ucc_configure(phys_addr_t start, phys_addr_t end)
 #endif
 
 static const struct of_device_id fsl_pq_mdio_match[] = {
-#if defined(CONFIG_GIANFAR) || defined(CONFIG_GIANFAR_MODULE)
+#if IS_ENABLED(CONFIG_GIANFAR)
 	{
 		.compatible = "fsl,gianfar-tbi",
 		.data = &(struct fsl_pq_mdio_data) {
@@ -344,7 +344,7 @@ static const struct of_device_id fsl_pq_mdio_match[] = {
 		},
 	},
 #endif
-#if defined(CONFIG_UCC_GETH) || defined(CONFIG_UCC_GETH_MODULE)
+#if IS_ENABLED(CONFIG_UCC_GETH)
 	{
 		.compatible = "fsl,ucc-mdio",
 		.data = &(struct fsl_pq_mdio_data) {
-- 
2.7.4
