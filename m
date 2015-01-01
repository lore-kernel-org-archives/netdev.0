From: Rickard Strandqvist <rickard_strandqvist@spectrumdigital.se>
Subject: [PATCH] net: ethernet: micrel: ksz884x.c:  Remove some unused functions
Date: Thu,  1 Jan 2015 18:00:23 +0100
Message-ID: <1420131623-30749-1-git-send-email-rickard_strandqvist@spectrumdigital.se>
Cc: Rickard Strandqvist <rickard_strandqvist@spectrumdigital.se>,
	Wilfried Klaebe <w-lkml@lebenslange-mailadresse.de>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Benoit Taine <benoit.taine@lip6.fr>,
	Julia Lawall <Julia.Lawall@lip6.fr>,
	=?UTF-8?q?Manuel=20Sch=C3=B6lling?= <manuel.schoelling@gmx.de>,
	Joe Perches <joe@perches.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>,
	Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f179.google.com ([74.125.82.179]:40079 "EHLO
	mail-we0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751804AbbAAQ5Y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Jan 2015 11:57:24 -0500
Received: by mail-we0-f179.google.com with SMTP id q59so3587038wes.38
        for <netdev@vger.kernel.org>; Thu, 01 Jan 2015 08:57:23 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Removes some functions that are not used anywhere:
hw_w_phy_link_md() hw_r_phy_link_md() hw_w_phy_polarity()
hw_r_phy_polarity() hw_w_phy_crossover() hw_r_phy_crossover()
hw_r_phy_rem_cap() hw_w_phy_auto_neg() hw_r_phy_auto_neg()
hw_r_phy_link_stat() sw_get_addr() port_chk_prio() port_chk_replace_vid()
port_chk_802_1p() port_chk_diffserv() sw_chk_unk_def_port()
sw_cfg_unk_def_port() sw_cfg_chk_unk_def_deliver() sw_cfg_unk_def_deliver()
port_chk_in_filter() port_chk_dis_non_vid() port_cfg_in_filter()
port_cfg_dis_non_vid() port_chk_rmv_tag() port_chk_ins_tag()
port_cfg_rmv_tag() port_cfg_ins_tag() sw_flush_dyn_mac_table() port_cfg_tx()
port_cfg_rx() port_chk_force_flow_ctrl() port_chk_back_pressure()
port_cfg_force_flow_ctrl() port_chk_broad_storm() hw_ena_intr_bit()

This was partially found by using a static code analysis program called cppcheck.

Signed-off-by: Rickard Strandqvist <rickard_strandqvist@spectrumdigital.se>
---
 drivers/net/ethernet/micrel/ksz884x.c |  217 ---------------------------------
 1 file changed, 217 deletions(-)

diff --git a/drivers/net/ethernet/micrel/ksz884x.c b/drivers/net/ethernet/micrel/ksz884x.c
index f1ebed6c..582973f 100644
--- a/drivers/net/ethernet/micrel/ksz884x.c
+++ b/drivers/net/ethernet/micrel/ksz884x.c
@@ -1551,15 +1551,6 @@ static void hw_turn_on_intr(struct ksz_hw *hw, u32 bit)
 		hw_set_intr(hw, hw->intr_mask);
 }
 
-static inline void hw_ena_intr_bit(struct ksz_hw *hw, uint interrupt)
-{
-	u32 read_intr;
-
-	read_intr = readl(hw->io + KS884X_INTERRUPTS_ENABLE);
-	hw->intr_set = read_intr | interrupt;
-	writel(hw->intr_set, hw->io + KS884X_INTERRUPTS_ENABLE);
-}
-
 static inline void hw_read_intr(struct ksz_hw *hw, uint *status)
 {
 	*status = readl(hw->io + KS884X_INTERRUPTS_STATUS);
@@ -2125,12 +2116,6 @@ static inline void port_cfg_broad_storm(struct ksz_hw *hw, int p, int set)
 		KS8842_PORT_CTRL_1_OFFSET, PORT_BROADCAST_STORM, set);
 }
 
-static inline int port_chk_broad_storm(struct ksz_hw *hw, int p)
-{
-	return port_chk(hw, p,
-		KS8842_PORT_CTRL_1_OFFSET, PORT_BROADCAST_STORM);
-}
-
 /* Driver set switch broadcast storm protection at 10% rate. */
 #define BROADCAST_STORM_PROTECTION_RATE	10
 
@@ -2283,24 +2268,6 @@ static inline void port_cfg_back_pressure(struct ksz_hw *hw, int p, int set)
 		KS8842_PORT_CTRL_2_OFFSET, PORT_BACK_PRESSURE, set);
 }
 
-static inline void port_cfg_force_flow_ctrl(struct ksz_hw *hw, int p, int set)
-{
-	port_cfg(hw, p,
-		KS8842_PORT_CTRL_2_OFFSET, PORT_FORCE_FLOW_CTRL, set);
-}
-
-static inline int port_chk_back_pressure(struct ksz_hw *hw, int p)
-{
-	return port_chk(hw, p,
-		KS8842_PORT_CTRL_2_OFFSET, PORT_BACK_PRESSURE);
-}
-
-static inline int port_chk_force_flow_ctrl(struct ksz_hw *hw, int p)
-{
-	return port_chk(hw, p,
-		KS8842_PORT_CTRL_2_OFFSET, PORT_FORCE_FLOW_CTRL);
-}
-
 /* Spanning Tree */
 
 static inline void port_cfg_dis_learn(struct ksz_hw *hw, int p, int set)
@@ -2309,82 +2276,11 @@ static inline void port_cfg_dis_learn(struct ksz_hw *hw, int p, int set)
 		KS8842_PORT_CTRL_2_OFFSET, PORT_LEARN_DISABLE, set);
 }
 
-static inline void port_cfg_rx(struct ksz_hw *hw, int p, int set)
-{
-	port_cfg(hw, p,
-		KS8842_PORT_CTRL_2_OFFSET, PORT_RX_ENABLE, set);
-}
-
-static inline void port_cfg_tx(struct ksz_hw *hw, int p, int set)
-{
-	port_cfg(hw, p,
-		KS8842_PORT_CTRL_2_OFFSET, PORT_TX_ENABLE, set);
-}
-
 static inline void sw_cfg_fast_aging(struct ksz_hw *hw, int set)
 {
 	sw_cfg(hw, KS8842_SWITCH_CTRL_1_OFFSET, SWITCH_FAST_AGING, set);
 }
 
-static inline void sw_flush_dyn_mac_table(struct ksz_hw *hw)
-{
-	if (!(hw->overrides & FAST_AGING)) {
-		sw_cfg_fast_aging(hw, 1);
-		mdelay(1);
-		sw_cfg_fast_aging(hw, 0);
-	}
-}
-
-/* VLAN */
-
-static inline void port_cfg_ins_tag(struct ksz_hw *hw, int p, int insert)
-{
-	port_cfg(hw, p,
-		KS8842_PORT_CTRL_1_OFFSET, PORT_INSERT_TAG, insert);
-}
-
-static inline void port_cfg_rmv_tag(struct ksz_hw *hw, int p, int remove)
-{
-	port_cfg(hw, p,
-		KS8842_PORT_CTRL_1_OFFSET, PORT_REMOVE_TAG, remove);
-}
-
-static inline int port_chk_ins_tag(struct ksz_hw *hw, int p)
-{
-	return port_chk(hw, p,
-		KS8842_PORT_CTRL_1_OFFSET, PORT_INSERT_TAG);
-}
-
-static inline int port_chk_rmv_tag(struct ksz_hw *hw, int p)
-{
-	return port_chk(hw, p,
-		KS8842_PORT_CTRL_1_OFFSET, PORT_REMOVE_TAG);
-}
-
-static inline void port_cfg_dis_non_vid(struct ksz_hw *hw, int p, int set)
-{
-	port_cfg(hw, p,
-		KS8842_PORT_CTRL_2_OFFSET, PORT_DISCARD_NON_VID, set);
-}
-
-static inline void port_cfg_in_filter(struct ksz_hw *hw, int p, int set)
-{
-	port_cfg(hw, p,
-		KS8842_PORT_CTRL_2_OFFSET, PORT_INGRESS_VLAN_FILTER, set);
-}
-
-static inline int port_chk_dis_non_vid(struct ksz_hw *hw, int p)
-{
-	return port_chk(hw, p,
-		KS8842_PORT_CTRL_2_OFFSET, PORT_DISCARD_NON_VID);
-}
-
-static inline int port_chk_in_filter(struct ksz_hw *hw, int p)
-{
-	return port_chk(hw, p,
-		KS8842_PORT_CTRL_2_OFFSET, PORT_INGRESS_VLAN_FILTER);
-}
-
 /* Mirroring */
 
 static inline void port_cfg_mirror_sniffer(struct ksz_hw *hw, int p, int set)
@@ -2422,28 +2318,6 @@ static void sw_init_mirror(struct ksz_hw *hw)
 	sw_cfg_mirror_rx_tx(hw, 0);
 }
 
-static inline void sw_cfg_unk_def_deliver(struct ksz_hw *hw, int set)
-{
-	sw_cfg(hw, KS8842_SWITCH_CTRL_7_OFFSET,
-		SWITCH_UNK_DEF_PORT_ENABLE, set);
-}
-
-static inline int sw_cfg_chk_unk_def_deliver(struct ksz_hw *hw)
-{
-	return sw_chk(hw, KS8842_SWITCH_CTRL_7_OFFSET,
-		SWITCH_UNK_DEF_PORT_ENABLE);
-}
-
-static inline void sw_cfg_unk_def_port(struct ksz_hw *hw, int port, int set)
-{
-	port_cfg_shift(hw, port, KS8842_SWITCH_CTRL_7_OFFSET, 0, set);
-}
-
-static inline int sw_chk_unk_def_port(struct ksz_hw *hw, int port)
-{
-	return port_chk_shift(hw, port, KS8842_SWITCH_CTRL_7_OFFSET, 0);
-}
-
 /* Priority */
 
 static inline void port_cfg_diffserv(struct ksz_hw *hw, int p, int set)
@@ -2470,30 +2344,6 @@ static inline void port_cfg_prio(struct ksz_hw *hw, int p, int set)
 		KS8842_PORT_CTRL_1_OFFSET, PORT_PRIO_QUEUE_ENABLE, set);
 }
 
-static inline int port_chk_diffserv(struct ksz_hw *hw, int p)
-{
-	return port_chk(hw, p,
-		KS8842_PORT_CTRL_1_OFFSET, PORT_DIFFSERV_ENABLE);
-}
-
-static inline int port_chk_802_1p(struct ksz_hw *hw, int p)
-{
-	return port_chk(hw, p,
-		KS8842_PORT_CTRL_1_OFFSET, PORT_802_1P_ENABLE);
-}
-
-static inline int port_chk_replace_vid(struct ksz_hw *hw, int p)
-{
-	return port_chk(hw, p,
-		KS8842_PORT_CTRL_2_OFFSET, PORT_USER_PRIORITY_CEILING);
-}
-
-static inline int port_chk_prio(struct ksz_hw *hw, int p)
-{
-	return port_chk(hw, p,
-		KS8842_PORT_CTRL_1_OFFSET, PORT_PRIO_QUEUE_ENABLE);
-}
-
 /**
  * sw_dis_diffserv - disable switch DiffServ priority
  * @hw: 	The hardware instance.
@@ -2694,23 +2544,6 @@ static void sw_cfg_port_base_vlan(struct ksz_hw *hw, int port, u8 member)
 }
 
 /**
- * sw_get_addr - get the switch MAC address.
- * @hw: 	The hardware instance.
- * @mac_addr:	Buffer to store the MAC address.
- *
- * This function retrieves the MAC address of the switch.
- */
-static inline void sw_get_addr(struct ksz_hw *hw, u8 *mac_addr)
-{
-	int i;
-
-	for (i = 0; i < 6; i += 2) {
-		mac_addr[i] = readb(hw->io + KS8842_MAC_ADDR_0_OFFSET + i);
-		mac_addr[1 + i] = readb(hw->io + KS8842_MAC_ADDR_1_OFFSET + i);
-	}
-}
-
-/**
  * sw_set_addr - configure switch MAC address
  * @hw: 	The hardware instance.
  * @mac_addr:	The MAC address.
@@ -2917,56 +2750,6 @@ static inline void hw_w_phy_ctrl(struct ksz_hw *hw, int phy, u16 data)
 	writew(data, hw->io + phy + KS884X_PHY_CTRL_OFFSET);
 }
 
-static inline void hw_r_phy_link_stat(struct ksz_hw *hw, int phy, u16 *data)
-{
-	*data = readw(hw->io + phy + KS884X_PHY_STATUS_OFFSET);
-}
-
-static inline void hw_r_phy_auto_neg(struct ksz_hw *hw, int phy, u16 *data)
-{
-	*data = readw(hw->io + phy + KS884X_PHY_AUTO_NEG_OFFSET);
-}
-
-static inline void hw_w_phy_auto_neg(struct ksz_hw *hw, int phy, u16 data)
-{
-	writew(data, hw->io + phy + KS884X_PHY_AUTO_NEG_OFFSET);
-}
-
-static inline void hw_r_phy_rem_cap(struct ksz_hw *hw, int phy, u16 *data)
-{
-	*data = readw(hw->io + phy + KS884X_PHY_REMOTE_CAP_OFFSET);
-}
-
-static inline void hw_r_phy_crossover(struct ksz_hw *hw, int phy, u16 *data)
-{
-	*data = readw(hw->io + phy + KS884X_PHY_CTRL_OFFSET);
-}
-
-static inline void hw_w_phy_crossover(struct ksz_hw *hw, int phy, u16 data)
-{
-	writew(data, hw->io + phy + KS884X_PHY_CTRL_OFFSET);
-}
-
-static inline void hw_r_phy_polarity(struct ksz_hw *hw, int phy, u16 *data)
-{
-	*data = readw(hw->io + phy + KS884X_PHY_PHY_CTRL_OFFSET);
-}
-
-static inline void hw_w_phy_polarity(struct ksz_hw *hw, int phy, u16 data)
-{
-	writew(data, hw->io + phy + KS884X_PHY_PHY_CTRL_OFFSET);
-}
-
-static inline void hw_r_phy_link_md(struct ksz_hw *hw, int phy, u16 *data)
-{
-	*data = readw(hw->io + phy + KS884X_PHY_LINK_MD_OFFSET);
-}
-
-static inline void hw_w_phy_link_md(struct ksz_hw *hw, int phy, u16 data)
-{
-	writew(data, hw->io + phy + KS884X_PHY_LINK_MD_OFFSET);
-}
-
 /**
  * hw_r_phy - read data from PHY register
  * @hw: 	The hardware instance.
-- 
1.7.10.4
