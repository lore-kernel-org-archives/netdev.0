From: "Shimoda, Yoshihiro" <yoshihiro.shimoda.uh@renesas.com>
Subject: [PATCH] net: sh_eth: fix endian check for architecture independent
Date: Fri, 30 Mar 2012 14:32:08 +0900
Message-ID: <4F754558.1070001@renesas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: SH-Linux <linux-sh@vger.kernel.org>
To: netdev <netdev@vger.kernel.org>
Return-path: <linux-sh-owner@vger.kernel.org>
Sender: linux-sh-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

SuperH has the "CONFIG_CPU_LITTLE_ENDIAN" and the "__LITTLE_ENDIAN__".
But, other architecture doesn't have them. So, this patch fixes it.

Signed-off-by: Yoshihiro Shimoda <yoshihiro.shimoda.uh@renesas.com>
---
 drivers/net/ethernet/renesas/sh_eth.c |    2 +-
 drivers/net/ethernet/renesas/sh_eth.h |    4 ++--
 2 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/renesas/sh_eth.c b/drivers/net/ethernet/renesas/sh_eth.c
index 8bdf070..d63e09b 100644
--- a/drivers/net/ethernet/renesas/sh_eth.c
+++ b/drivers/net/ethernet/renesas/sh_eth.c
@@ -804,7 +804,7 @@ static int sh_eth_dev_init(struct net_device *ndev)
 	/* all sh_eth int mask */
 	sh_eth_write(ndev, 0, EESIPR);

-#if defined(__LITTLE_ENDIAN__)
+#if defined(__LITTLE_ENDIAN)
 	if (mdp->cd->hw_swap)
 		sh_eth_write(ndev, EDMR_EL, EDMR);
 	else
diff --git a/drivers/net/ethernet/renesas/sh_eth.h b/drivers/net/ethernet/renesas/sh_eth.h
index e66de18..0fa14af 100644
--- a/drivers/net/ethernet/renesas/sh_eth.h
+++ b/drivers/net/ethernet/renesas/sh_eth.h
@@ -693,7 +693,7 @@ enum TSU_FWSLC_BIT {
  */
 struct sh_eth_txdesc {
 	u32 status;		/* TD0 */
-#if defined(CONFIG_CPU_LITTLE_ENDIAN)
+#if defined(__LITTLE_ENDIAN)
 	u16 pad0;		/* TD1 */
 	u16 buffer_length;	/* TD1 */
 #else
@@ -710,7 +710,7 @@ struct sh_eth_txdesc {
  */
 struct sh_eth_rxdesc {
 	u32 status;		/* RD0 */
-#if defined(CONFIG_CPU_LITTLE_ENDIAN)
+#if defined(__LITTLE_ENDIAN)
 	u16 frame_length;	/* RD1 */
 	u16 buffer_length;	/* RD1 */
 #else
-- 
1.7.1
