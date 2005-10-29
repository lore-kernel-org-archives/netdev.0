From: Eugene Surovegin <ebs@ebshome.net>
Subject: [PATCH 2/3] PPC 44x EMAC driver: add 440GR support
Date: Sat, 29 Oct 2005 12:45:31 -0700
Message-ID: <20051029194531.GC1865@gate.ebshome.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, sr@denx.de, linuxppc-embedded@ozlabs.org
Return-path: <linuxppc-embedded-bounces@ozlabs.org>
To: Jeff Garzik <jgarzik@pobox.com>
Content-Disposition: inline
List-Unsubscribe: <https://ozlabs.org/mailman/listinfo/linuxppc-embedded>,
	<mailto:linuxppc-embedded-request@ozlabs.org?subject=unsubscribe>
List-Archive: <http://ozlabs.org/pipermail/linuxppc-embedded>
List-Post: <mailto:linuxppc-embedded@ozlabs.org>
List-Help: <mailto:linuxppc-embedded-request@ozlabs.org?subject=help>
List-Subscribe: <https://ozlabs.org/mailman/listinfo/linuxppc-embedded>,
	<mailto:linuxppc-embedded-request@ozlabs.org?subject=subscribe>
Sender: linuxppc-embedded-bounces@ozlabs.org
Errors-To: linuxppc-embedded-bounces@ozlabs.org
List-Id: netdev.vger.kernel.org

Add PowerPC 440GR support

Signed-off-by: Stefan Roese <sr@denx.de>
Signed-off-by: Eugene Surovegin <ebs@ebshome.net>
---

 drivers/net/Kconfig                  |    2 +-
 drivers/net/ibm_emac/ibm_emac.h      |    3 ++-
 drivers/net/ibm_emac/ibm_emac_core.c |    7 ++++---
 drivers/net/ibm_emac/ibm_emac_mal.h  |    2 +-
 4 files changed, 8 insertions(+), 6 deletions(-)

diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
index 6d4f9ce..97760c1 100644
--- a/drivers/net/Kconfig
+++ b/drivers/net/Kconfig
@@ -1203,7 +1203,7 @@ config IBM_EMAC_RX_SKB_HEADROOM
 
 config IBM_EMAC_PHY_RX_CLK_FIX
 	bool "PHY Rx clock workaround"
-	depends on IBM_EMAC && (405EP || 440GX || 440EP)
+	depends on IBM_EMAC && (405EP || 440GX || 440EP || 440GR)
 	help
 	  Enable this if EMAC attached to a PHY which doesn't generate
 	  RX clock if there is no link, if this is the case, you will 
diff --git a/drivers/net/ibm_emac/ibm_emac.h b/drivers/net/ibm_emac/ibm_emac.h
index d3166da..644edbf 100644
--- a/drivers/net/ibm_emac/ibm_emac.h
+++ b/drivers/net/ibm_emac/ibm_emac.h
@@ -26,7 +26,8 @@
 /* This is a simple check to prevent use of this driver on non-tested SoCs */
 #if !defined(CONFIG_405GP) && !defined(CONFIG_405GPR) && !defined(CONFIG_405EP) && \
     !defined(CONFIG_440GP) && !defined(CONFIG_440GX) && !defined(CONFIG_440SP) && \
-    !defined(CONFIG_440EP) && !defined(CONFIG_NP405H) && !defined(CONFIG_440SPE)
+    !defined(CONFIG_440EP) && !defined(CONFIG_NP405H) && !defined(CONFIG_440SPE) && \
+    !defined(CONFIG_440GR)
 #error	"Unknown SoC. Please, check chip user manual and make sure EMAC defines are OK"
 #endif
 
diff --git a/drivers/net/ibm_emac/ibm_emac_core.c b/drivers/net/ibm_emac/ibm_emac_core.c
index 48239e1..eb7d694 100644
--- a/drivers/net/ibm_emac/ibm_emac_core.c
+++ b/drivers/net/ibm_emac/ibm_emac_core.c
@@ -87,10 +87,11 @@ MODULE_LICENSE("GPL");
  */
 static u32 busy_phy_map;
 
-#if defined(CONFIG_IBM_EMAC_PHY_RX_CLK_FIX) && (defined(CONFIG_405EP) || defined(CONFIG_440EP))
+#if defined(CONFIG_IBM_EMAC_PHY_RX_CLK_FIX) && \
+    (defined(CONFIG_405EP) || defined(CONFIG_440EP) || defined(CONFIG_440GR))
 /* 405EP has "EMAC to PHY Control Register" (CPC0_EPCTL) which can help us
  * with PHY RX clock problem.
- * 440EP has more sane SDR0_MFR register implementation than 440GX, which
+ * 440EP/440GR has more sane SDR0_MFR register implementation than 440GX, which
  * also allows controlling each EMAC clock
  */
 static inline void EMAC_RX_CLK_TX(int idx)
@@ -100,7 +101,7 @@ static inline void EMAC_RX_CLK_TX(int id
 
 #if defined(CONFIG_405EP)
 	mtdcr(0xf3, mfdcr(0xf3) | (1 << idx));
-#else /* CONFIG_440EP */
+#else /* CONFIG_440EP || CONFIG_440GR */
 	SDR_WRITE(DCRN_SDR_MFR, SDR_READ(DCRN_SDR_MFR) | (0x08000000 >> idx));
 #endif
 
diff --git a/drivers/net/ibm_emac/ibm_emac_mal.h b/drivers/net/ibm_emac/ibm_emac_mal.h
index fb6dfe1..2a2d3b2 100644
--- a/drivers/net/ibm_emac/ibm_emac_mal.h
+++ b/drivers/net/ibm_emac/ibm_emac_mal.h
@@ -32,7 +32,7 @@
  * reflect the fact that 40x and 44x have slightly different MALs. --ebs
  */
 #if defined(CONFIG_405GP) || defined(CONFIG_405GPR) || defined(CONFIG_405EP) || \
-    defined(CONFIG_440EP) || defined(CONFIG_NP405H)
+    defined(CONFIG_440EP) || defined(CONFIG_440GR) || defined(CONFIG_NP405H)
 #define MAL_VERSION		1
 #elif defined(CONFIG_440GP) || defined(CONFIG_440GX) || defined(CONFIG_440SP) || \
       defined(CONFIG_440SPE)
