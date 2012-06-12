From: "Shimoda, Yoshihiro" <yoshihiro.shimoda.uh@renesas.com>
Subject: [PATCH net-next 2/5] net: sh_eth: remove unnecessary
 members/definitions
Date: Tue, 12 Jun 2012 14:19:08 +0900
Message-ID: <4FD6D14C.3070104@renesas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: SH-Linux <linux-sh@vger.kernel.org>
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relmlor1.renesas.com ([210.160.252.171]:64637 "EHLO
	relmlor1.renesas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751137Ab2FLFTJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Jun 2012 01:19:09 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch removes unnecessary members in sh_th_private.
This patch also removes unnecessary definitions in sh_eth.h

Signed-off-by: Yoshihiro Shimoda <yoshihiro.shimoda.uh@renesas.com>
---
 drivers/net/ethernet/renesas/sh_eth.c |    7 +---
 drivers/net/ethernet/renesas/sh_eth.h |   69 ---------------------------------
 2 files changed, 1 insertions(+), 75 deletions(-)

diff --git a/drivers/net/ethernet/renesas/sh_eth.c b/drivers/net/ethernet/renesas/sh_eth.c
index 4ccfd0f..906e410 100644
--- a/drivers/net/ethernet/renesas/sh_eth.c
+++ b/drivers/net/ethernet/renesas/sh_eth.c
@@ -898,7 +898,6 @@ static int sh_eth_dev_init(struct net_device *ndev)
 {
 	int ret = 0;
 	struct sh_eth_private *mdp = netdev_priv(ndev);
-	u_int32_t rx_int_var, tx_int_var;
 	u32 val;

 	/* Soft Reset */
@@ -926,9 +925,7 @@ static int sh_eth_dev_init(struct net_device *ndev)
 	/* Frame recv control */
 	sh_eth_write(ndev, mdp->cd->rmcr_value, RMCR);

-	rx_int_var = mdp->rx_int_var = DESC_I_RINT8 | DESC_I_RINT5;
-	tx_int_var = mdp->tx_int_var = DESC_I_TINT2;
-	sh_eth_write(ndev, rx_int_var | tx_int_var, TRSCER);
+	sh_eth_write(ndev, DESC_I_RINT8 | DESC_I_RINT5 | DESC_I_TINT2, TRSCER);

 	if (mdp->cd->bculr)
 		sh_eth_write(ndev, 0x800, BCULR);	/* Burst sycle set */
@@ -2288,8 +2285,6 @@ static int sh_eth_drv_probe(struct platform_device *pdev)

 	/* debug message level */
 	mdp->msg_enable = SH_ETH_DEF_MSG_ENABLE;
-	mdp->post_rx = POST_RX >> (devno << 1);
-	mdp->post_fw = POST_FW >> (devno << 1);

 	/* read and set MAC address */
 	read_mac_address(ndev, pd->mac_addr);
diff --git a/drivers/net/ethernet/renesas/sh_eth.h b/drivers/net/ethernet/renesas/sh_eth.h
index 9e8e4d5..9525199 100644
--- a/drivers/net/ethernet/renesas/sh_eth.h
+++ b/drivers/net/ethernet/renesas/sh_eth.h
@@ -585,71 +585,6 @@ enum RPADIR_BIT {
 /* FDR */
 #define DEFAULT_FDR_INIT	0x00000707

-enum phy_offsets {
-	PHY_CTRL = 0, PHY_STAT = 1, PHY_IDT1 = 2, PHY_IDT2 = 3,
-	PHY_ANA = 4, PHY_ANL = 5, PHY_ANE = 6,
-	PHY_16 = 16,
-};
-
-/* PHY_CTRL */
-enum PHY_CTRL_BIT {
-	PHY_C_RESET = 0x8000, PHY_C_LOOPBK = 0x4000, PHY_C_SPEEDSL = 0x2000,
-	PHY_C_ANEGEN = 0x1000, PHY_C_PWRDN = 0x0800, PHY_C_ISO = 0x0400,
-	PHY_C_RANEG = 0x0200, PHY_C_DUPLEX = 0x0100, PHY_C_COLT = 0x0080,
-};
-#define DM9161_PHY_C_ANEGEN 0	/* auto nego special */
-
-/* PHY_STAT */
-enum PHY_STAT_BIT {
-	PHY_S_100T4 = 0x8000, PHY_S_100X_F = 0x4000, PHY_S_100X_H = 0x2000,
-	PHY_S_10T_F = 0x1000, PHY_S_10T_H = 0x0800, PHY_S_ANEGC = 0x0020,
-	PHY_S_RFAULT = 0x0010, PHY_S_ANEGA = 0x0008, PHY_S_LINK = 0x0004,
-	PHY_S_JAB = 0x0002, PHY_S_EXTD = 0x0001,
-};
-
-/* PHY_ANA */
-enum PHY_ANA_BIT {
-	PHY_A_NP = 0x8000, PHY_A_ACK = 0x4000, PHY_A_RF = 0x2000,
-	PHY_A_FCS = 0x0400, PHY_A_T4 = 0x0200, PHY_A_FDX = 0x0100,
-	PHY_A_HDX = 0x0080, PHY_A_10FDX = 0x0040, PHY_A_10HDX = 0x0020,
-	PHY_A_SEL = 0x001e,
-};
-/* PHY_ANL */
-enum PHY_ANL_BIT {
-	PHY_L_NP = 0x8000, PHY_L_ACK = 0x4000, PHY_L_RF = 0x2000,
-	PHY_L_FCS = 0x0400, PHY_L_T4 = 0x0200, PHY_L_FDX = 0x0100,
-	PHY_L_HDX = 0x0080, PHY_L_10FDX = 0x0040, PHY_L_10HDX = 0x0020,
-	PHY_L_SEL = 0x001f,
-};
-
-/* PHY_ANE */
-enum PHY_ANE_BIT {
-	PHY_E_PDF = 0x0010, PHY_E_LPNPA = 0x0008, PHY_E_NPA = 0x0004,
-	PHY_E_PRX = 0x0002, PHY_E_LPANEGA = 0x0001,
-};
-
-/* DM9161 */
-enum PHY_16_BIT {
-	PHY_16_BP4B45 = 0x8000, PHY_16_BPSCR = 0x4000, PHY_16_BPALIGN = 0x2000,
-	PHY_16_BP_ADPOK = 0x1000, PHY_16_Repeatmode = 0x0800,
-	PHY_16_TXselect = 0x0400,
-	PHY_16_Rsvd = 0x0200, PHY_16_RMIIEnable = 0x0100,
-	PHY_16_Force100LNK = 0x0080,
-	PHY_16_APDLED_CTL = 0x0040, PHY_16_COLLED_CTL = 0x0020,
-	PHY_16_RPDCTR_EN = 0x0010,
-	PHY_16_ResetStMch = 0x0008, PHY_16_PreamSupr = 0x0004,
-	PHY_16_Sleepmode = 0x0002,
-	PHY_16_RemoteLoopOut = 0x0001,
-};
-
-#define POST_RX		0x08
-#define POST_FW		0x04
-#define POST0_RX	(POST_RX)
-#define POST0_FW	(POST_FW)
-#define POST1_RX	(POST_RX >> 2)
-#define POST1_FW	(POST_FW >> 2)
-#define POST_ALL	(POST0_RX | POST0_FW | POST1_RX | POST1_FW)
-
 /* ARSTR */
 enum ARSTR_BIT { ARSTR_ARSTR = 0x00000001, };

@@ -785,10 +720,6 @@ struct sh_eth_private {
 	int msg_enable;
 	int speed;
 	int duplex;
-	u32 rx_int_var, tx_int_var;	/* interrupt control variables */
-	char post_rx;		/* POST receive */
-	char post_fw;		/* POST forward */
-	struct net_device_stats tsu_stats;	/* TSU forward status */
 	int port;		/* for TSU */
 	int vlan_num_ids;	/* for VLAN tag filter */

-- 
1.7.1
