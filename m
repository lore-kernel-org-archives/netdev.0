From: Denis Cheng <crquan@gmail.com>
Subject: [PATCH 2/2] drivers/net/: all drivers/net/ cleanup with ARRAY_SIZE
Date: Sun,  2 Sep 2007 18:30:18 +0800
Message-ID: <11887290302449-git-send-email-crquan@gmail.com>
References: <Pine.LNX.4.64.0709020235420.22012@localhost.localdomain>
 <11887290181154-git-send-email-crquan@gmail.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	cr_quan@163.com
To: "Robert P. J. Day" <rpjday@mindspring.com>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rv-out-0910.google.com ([209.85.198.187]:46069 "EHLO
	rv-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933884AbXIBKaw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 2 Sep 2007 06:30:52 -0400
Received: by rv-out-0910.google.com with SMTP id k20so721631rvb
        for <netdev@vger.kernel.org>; Sun, 02 Sep 2007 03:30:51 -0700 (PDT)
In-Reply-To: <11887290181154-git-send-email-crquan@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Denis Cheng <crquan@gmail.com>
---
 drivers/net/apne.c                         |    2 +-
 drivers/net/arm/am79c961a.c                |    2 +-
 drivers/net/atarilance.c                   |    2 +-
 drivers/net/atl1/atl1_hw.c                 |    2 +-
 drivers/net/bnx2.c                         |    2 +-
 drivers/net/cs89x0.c                       |    6 +++---
 drivers/net/e1000/e1000_ethtool.c          |    3 +--
 drivers/net/fec_8xx/fec_mii.c              |    5 ++---
 drivers/net/ibm_emac/ibm_emac_debug.c      |    8 ++++----
 drivers/net/irda/actisys-sir.c             |    2 +-
 drivers/net/ixgb/ixgb_ethtool.c            |    3 +--
 drivers/net/lp486e.c                       |    4 +---
 drivers/net/mv643xx_eth.c                  |    3 +--
 drivers/net/ne-h8300.c                     |    2 +-
 drivers/net/ne.c                           |    2 +-
 drivers/net/ne2.c                          |    2 +-
 drivers/net/ne2k-pci.c                     |    2 +-
 drivers/net/netxen/netxen_nic.h            |    2 +-
 drivers/net/netxen/netxen_nic_hw.c         |    2 +-
 drivers/net/pcmcia/axnet_cs.c              |    2 +-
 drivers/net/pcmcia/pcnet_cs.c              |    4 ++--
 drivers/net/phy/phy.c                      |    2 +-
 drivers/net/skfp/smt.c                     |    2 +-
 drivers/net/skfp/srf.c                     |    4 ++--
 drivers/net/tulip/de4x5.c                  |    6 +++---
 drivers/net/wireless/airo.c                |    6 +++---
 drivers/net/wireless/hostap/hostap_ioctl.c |    6 +++---
 drivers/net/wireless/ipw2100.c             |    7 +++----
 drivers/net/wireless/libertas/fw.c         |    3 +--
 drivers/net/wireless/libertas/main.c       |   14 +++++++-------
 drivers/net/wireless/libertas/wext.c       |    4 ++--
 drivers/net/wireless/netwave_cs.c          |    6 +++---
 drivers/net/wireless/prism54/isl_ioctl.c   |    7 +++----
 drivers/net/wireless/ray_cs.c              |    6 +++---
 drivers/net/wireless/wavelan.c             |    6 +++---
 drivers/net/wireless/wavelan_cs.c          |    6 +++---
 drivers/net/wireless/wl3501_cs.c           |    2 +-
 drivers/net/zorro8390.c                    |    2 +-
 38 files changed, 71 insertions(+), 80 deletions(-)

diff --git a/drivers/net/apne.c b/drivers/net/apne.c
index 9541911..8806151 100644
--- a/drivers/net/apne.c
+++ b/drivers/net/apne.c
@@ -247,7 +247,7 @@ static int __init apne_probe1(struct net_device *dev, int ioaddr)
 	    {0x00,	NE_EN0_RSARHI},
 	    {E8390_RREAD+E8390_START, NE_CMD},
 	};
-	for (i = 0; i < sizeof(program_seq)/sizeof(program_seq[0]); i++) {
+	for (i = 0; i < ARRAY_SIZE(program_seq); i++) {
 	    outb(program_seq[i].value, ioaddr + program_seq[i].offset);
 	}
 
diff --git a/drivers/net/arm/am79c961a.c b/drivers/net/arm/am79c961a.c
index 2143eeb..7796455 100644
--- a/drivers/net/arm/am79c961a.c
+++ b/drivers/net/arm/am79c961a.c
@@ -414,7 +414,7 @@ static void am79c961_setmulticastlist (struct net_device *dev)
 	/*
 	 * Update the multicast hash table
 	 */
-	for (i = 0; i < sizeof(multi_hash) / sizeof(multi_hash[0]); i++)
+	for (i = 0; i < ARRAY_SIZE(multi_hash); i++)
 		write_rreg(dev->base_addr, i + LADRL, multi_hash[i]);
 
 	/*
diff --git a/drivers/net/atarilance.c b/drivers/net/atarilance.c
index dfa8b9b..a5c20d2 100644
--- a/drivers/net/atarilance.c
+++ b/drivers/net/atarilance.c
@@ -263,7 +263,7 @@ struct lance_addr {
 									   (highest byte stripped) */
 };
 
-#define	N_LANCE_ADDR	(sizeof(lance_addr_list)/sizeof(*lance_addr_list))
+#define	N_LANCE_ADDR	ARRAY_SIZE(lance_addr_list)
 
 
 /* Definitions for the Lance */
diff --git a/drivers/net/atl1/atl1_hw.c b/drivers/net/atl1/atl1_hw.c
index ef886bd..9d3bd22 100644
--- a/drivers/net/atl1/atl1_hw.c
+++ b/drivers/net/atl1/atl1_hw.c
@@ -603,7 +603,7 @@ static struct atl1_spi_flash_dev flash_table[] = {
 
 static void atl1_init_flash_opcode(struct atl1_hw *hw)
 {
-	if (hw->flash_vendor >= sizeof(flash_table) / sizeof(flash_table[0]))
+	if (hw->flash_vendor >= ARRAY_SIZE(flash_table))
 		hw->flash_vendor = 0;	/* ATMEL */
 
 	/* Init OP table */
diff --git a/drivers/net/bnx2.c b/drivers/net/bnx2.c
index 854d80c..aa9e636 100644
--- a/drivers/net/bnx2.c
+++ b/drivers/net/bnx2.c
@@ -3500,7 +3500,7 @@ bnx2_init_nvram(struct bnx2 *bp)
 	/* Determine the selected interface. */
 	val = REG_RD(bp, BNX2_NVM_CFG1);
 
-	entry_count = sizeof(flash_table) / sizeof(struct flash_spec);
+	entry_count = ARRAY_SIZE(flash_table);
 
 	if (val & 0x40000000) {
 
diff --git a/drivers/net/cs89x0.c b/drivers/net/cs89x0.c
index 9774bb1..d0f4a1a 100644
--- a/drivers/net/cs89x0.c
+++ b/drivers/net/cs89x0.c
@@ -806,7 +806,7 @@ cs89x0_probe1(struct net_device *dev, int ioaddr, int modular)
 		        i = cs8900_irq_map[0];
 #else
 			/* Translate the IRQ using the IRQ mapping table. */
-			if (i >= sizeof(cs8900_irq_map)/sizeof(cs8900_irq_map[0]))
+			if (i >= ARRAY_SIZE(cs8900_irq_map))
 				printk("\ncs89x0: invalid ISA interrupt number %d\n", i);
 			else
 				i = cs8900_irq_map[i];
@@ -1247,11 +1247,11 @@ write_irq(struct net_device *dev, int chip_type, int irq)
 
 	if (chip_type == CS8900) {
 		/* Search the mapping table for the corresponding IRQ pin. */
-		for (i = 0; i != sizeof(cs8900_irq_map)/sizeof(cs8900_irq_map[0]); i++)
+		for (i = 0; i != ARRAY_SIZE(cs8900_irq_map); i++)
 			if (cs8900_irq_map[i] == irq)
 				break;
 		/* Not found */
-		if (i == sizeof(cs8900_irq_map)/sizeof(cs8900_irq_map[0]))
+		if (i == ARRAY_SIZE(cs8900_irq_map))
 			i = 3;
 		writereg(dev, PP_CS8900_ISAINT, i);
 	} else {
diff --git a/drivers/net/e1000/e1000_ethtool.c b/drivers/net/e1000/e1000_ethtool.c
index 4c3785c..55909d7 100644
--- a/drivers/net/e1000/e1000_ethtool.c
+++ b/drivers/net/e1000/e1000_ethtool.c
@@ -106,8 +106,7 @@ static const struct e1000_stats e1000_gstrings_stats[] = {
 };
 
 #define E1000_QUEUE_STATS_LEN 0
-#define E1000_GLOBAL_STATS_LEN	\
-	sizeof(e1000_gstrings_stats) / sizeof(struct e1000_stats)
+#define E1000_GLOBAL_STATS_LEN ARRAY_SIZE(e1000_gstrings_stats)
 #define E1000_STATS_LEN (E1000_GLOBAL_STATS_LEN + E1000_QUEUE_STATS_LEN)
 static const char e1000_gstrings_test[][ETH_GSTRING_LEN] = {
 	"Register test  (offline)", "Eeprom test    (offline)",
diff --git a/drivers/net/fec_8xx/fec_mii.c b/drivers/net/fec_8xx/fec_mii.c
index b3fa0d6..e8e10a0 100644
--- a/drivers/net/fec_8xx/fec_mii.c
+++ b/drivers/net/fec_8xx/fec_mii.c
@@ -308,12 +308,11 @@ int fec_mii_phy_id_detect(struct net_device *dev)
 		return -1;
 	}
 
-	for (i = 0, phy = phy_info; i < sizeof(phy_info) / sizeof(phy_info[0]);
-	     i++, phy++)
+	for (i = 0, phy = phy_info; i < ARRAY_SIZE(phy_info); i++, phy++)
 		if (phy->id == (phy_hwid >> 4) || phy->id == 0)
 			break;
 
-	if (i >= sizeof(phy_info) / sizeof(phy_info[0])) {
+	if (i >= ARRAY_SIZE(phy_info)) {
 		printk(KERN_ERR DRV_MODULE_NAME
 		       ": %s PHY id 0x%08x is not supported!\n",
 		       dev->name, phy_hwid);
diff --git a/drivers/net/ibm_emac/ibm_emac_debug.c b/drivers/net/ibm_emac/ibm_emac_debug.c
index 92f970d..1f70906 100644
--- a/drivers/net/ibm_emac/ibm_emac_debug.c
+++ b/drivers/net/ibm_emac/ibm_emac_debug.c
@@ -132,7 +132,7 @@ void emac_dbg_register(int idx, struct ocp_enet_private *dev)
 {
 	unsigned long flags;
 
-	if (idx >= sizeof(__emacs) / sizeof(__emacs[0])) {
+	if (idx >= ARRAY_SIZE(__emacs)) {
 		printk(KERN_WARNING
 		       "invalid index %d when registering EMAC for debugging\n",
 		       idx);
@@ -148,7 +148,7 @@ void mal_dbg_register(int idx, struct ibm_ocp_mal *mal)
 {
 	unsigned long flags;
 
-	if (idx >= sizeof(__mals) / sizeof(__mals[0])) {
+	if (idx >= ARRAY_SIZE(__mals)) {
 		printk(KERN_WARNING
 		       "invalid index %d when registering MAL for debugging\n",
 		       idx);
@@ -167,11 +167,11 @@ void emac_dbg_dump_all(void)
 
 	local_irq_save(flags);
 
-	for (i = 0; i < sizeof(__mals) / sizeof(__mals[0]); ++i)
+	for (i = 0; i < ARRAY_SIZE(__mals); ++i)
 		if (__mals[i])
 			emac_mal_dump(__mals[i]);
 
-	for (i = 0; i < sizeof(__emacs) / sizeof(__emacs[0]); ++i)
+	for (i = 0; i < ARRAY_SIZE(__emacs); ++i)
 		if (__emacs[i])
 			emac_mac_dump(i, __emacs[i]);
 
diff --git a/drivers/net/irda/actisys-sir.c b/drivers/net/irda/actisys-sir.c
index 9715ab5..ccf6ec5 100644
--- a/drivers/net/irda/actisys-sir.c
+++ b/drivers/net/irda/actisys-sir.c
@@ -67,7 +67,7 @@ static int actisys_reset(struct sir_dev *);
 /* Note : the 220L doesn't support 38400, but we will fix that below */
 static unsigned baud_rates[] = { 9600, 19200, 57600, 115200, 38400 };
 
-#define MAX_SPEEDS (sizeof(baud_rates)/sizeof(baud_rates[0]))
+#define MAX_SPEEDS ARRAY_SIZE(baud_rates)
 
 static struct dongle_driver act220l = {
 	.owner		= THIS_MODULE,
diff --git a/drivers/net/ixgb/ixgb_ethtool.c b/drivers/net/ixgb/ixgb_ethtool.c
index 0413cd9..21d35bc 100644
--- a/drivers/net/ixgb/ixgb_ethtool.c
+++ b/drivers/net/ixgb/ixgb_ethtool.c
@@ -94,8 +94,7 @@ static struct ixgb_stats ixgb_gstrings_stats[] = {
 	{"tx_csum_offload_errors", IXGB_STAT(hw_csum_tx_error)}
 };
 
-#define IXGB_STATS_LEN	\
-	sizeof(ixgb_gstrings_stats) / sizeof(struct ixgb_stats)
+#define IXGB_STATS_LEN	ARRAY_SIZE(ixgb_gstrings_stats)
 
 static int
 ixgb_get_settings(struct net_device *netdev, struct ethtool_cmd *ecmd)
diff --git a/drivers/net/lp486e.c b/drivers/net/lp486e.c
index 5fc18da..408ae6e 100644
--- a/drivers/net/lp486e.c
+++ b/drivers/net/lp486e.c
@@ -515,8 +515,6 @@ CLEAR_INT(void) {
 	outb(0, IOADDR+8);
 }
 
-#define SIZE(x)	(sizeof(x)/sizeof((x)[0]))
-
 #if 0
 /* selftest or dump */
 static void
@@ -532,7 +530,7 @@ i596_port_do(struct net_device *dev, int portcmd, char *cmdname) {
 	mdelay(30);             /* random, unmotivated */
 
 	printk("lp486e i82596 %s result:\n", cmdname);
-	for (m = SIZE(lp->dump.dump); m && lp->dump.dump[m-1] == 0; m--)
+	for (m = ARRAY_SIZE(lp->dump.dump); m && lp->dump.dump[m-1] == 0; m--)
 		;
 	for (i = 0; i < m; i++) {
 		printk(" %04x", lp->dump.dump[i]);
diff --git a/drivers/net/mv643xx_eth.c b/drivers/net/mv643xx_eth.c
index 1799eee..80fa3e8 100644
--- a/drivers/net/mv643xx_eth.c
+++ b/drivers/net/mv643xx_eth.c
@@ -2688,8 +2688,7 @@ static const struct mv643xx_stats mv643xx_gstrings_stats[] = {
 	{ "late_collision", MV643XX_STAT(mib_counters.late_collision) },
 };
 
-#define MV643XX_STATS_LEN	\
-	sizeof(mv643xx_gstrings_stats) / sizeof(struct mv643xx_stats)
+#define MV643XX_STATS_LEN	ARRAY_SIZE(mv643xx_gstrings_stats)
 
 static void mv643xx_get_drvinfo(struct net_device *netdev,
 				struct ethtool_drvinfo *drvinfo)
diff --git a/drivers/net/ne-h8300.c b/drivers/net/ne-h8300.c
index 38fd525..7599d77 100644
--- a/drivers/net/ne-h8300.c
+++ b/drivers/net/ne-h8300.c
@@ -259,7 +259,7 @@ static int __init ne_probe1(struct net_device *dev, int ioaddr)
 			{E8390_RREAD+E8390_START, E8390_CMD},
 		};
 
-		for (i = 0; i < sizeof(program_seq)/sizeof(program_seq[0]); i++)
+		for (i = 0; i < ARRAY_SIZE(program_seq); i++)
 			outb_p(program_seq[i].value, ioaddr + program_seq[i].offset);
 
 	}
diff --git a/drivers/net/ne.c b/drivers/net/ne.c
index c9f74bf..eac2fa6 100644
--- a/drivers/net/ne.c
+++ b/drivers/net/ne.c
@@ -377,7 +377,7 @@ static int __init ne_probe1(struct net_device *dev, unsigned long ioaddr)
 			{E8390_RREAD+E8390_START, E8390_CMD},
 		};
 
-		for (i = 0; i < sizeof(program_seq)/sizeof(program_seq[0]); i++)
+		for (i = 0; i < ARRAY_SIZE(program_seq); i++)
 			outb_p(program_seq[i].value, ioaddr + program_seq[i].offset);
 
 	}
diff --git a/drivers/net/ne2.c b/drivers/net/ne2.c
index 089b5bb..c6c2a91 100644
--- a/drivers/net/ne2.c
+++ b/drivers/net/ne2.c
@@ -432,7 +432,7 @@ static int __init ne2_probe1(struct net_device *dev, int slot)
 			{E8390_RREAD+E8390_START, E8390_CMD},
 		};
 
-		for (i = 0; i < sizeof(program_seq)/sizeof(program_seq[0]); i++)
+		for (i = 0; i < ARRAY_SIZE(program_seq); i++)
 			outb_p(program_seq[i].value, base_addr +
 				program_seq[i].offset);
 
diff --git a/drivers/net/ne2k-pci.c b/drivers/net/ne2k-pci.c
index f81d939..9c2abcc 100644
--- a/drivers/net/ne2k-pci.c
+++ b/drivers/net/ne2k-pci.c
@@ -308,7 +308,7 @@ static int __devinit ne2k_pci_init_one (struct pci_dev *pdev,
 			{0x00,	EN0_RSARHI},
 			{E8390_RREAD+E8390_START, E8390_CMD},
 		};
-		for (i = 0; i < sizeof(program_seq)/sizeof(program_seq[0]); i++)
+		for (i = 0; i < ARRAY_SIZE(program_seq); i++)
 			outb(program_seq[i].value, ioaddr + program_seq[i].offset);
 
 	}
diff --git a/drivers/net/netxen/netxen_nic.h b/drivers/net/netxen/netxen_nic.h
index d4c92cc..9ff7117 100644
--- a/drivers/net/netxen/netxen_nic.h
+++ b/drivers/net/netxen/netxen_nic.h
@@ -1118,7 +1118,7 @@ static const struct netxen_brdinfo netxen_boards[] = {
 	{NETXEN_BRDTYPE_P2_SB31_2G, 2, "Dual Gb"},
 };
 
-#define NUM_SUPPORTED_BOARDS (sizeof(netxen_boards)/sizeof(struct netxen_brdinfo))
+#define NUM_SUPPORTED_BOARDS ARRAY_SIZE(netxen_boards)
 
 static inline void get_brd_port_by_type(u32 type, int *ports)
 {
diff --git a/drivers/net/netxen/netxen_nic_hw.c b/drivers/net/netxen/netxen_nic_hw.c
index a7b8d7f..2c19b8d 100644
--- a/drivers/net/netxen/netxen_nic_hw.c
+++ b/drivers/net/netxen/netxen_nic_hw.c
@@ -569,7 +569,7 @@ int netxen_is_flash_supported(struct netxen_adapter *adapter)
 	/* if the flash size less than 4Mb, make huge war cry and die */
 	for (j = 1; j < 4; j++) {
 		addr = j * NETXEN_NIC_WINDOW_MARGIN;
-		for (i = 0; i < (sizeof(locs) / sizeof(locs[0])); i++) {
+		for (i = 0; i < ARRAY_SIZE(locs); i++) {
 			if (netxen_rom_fast_read(adapter, locs[i], &val01) == 0
 			    && netxen_rom_fast_read(adapter, (addr + locs[i]),
 						    &val02) == 0) {
diff --git a/drivers/net/pcmcia/axnet_cs.c b/drivers/net/pcmcia/axnet_cs.c
index 50dff1b..2f3c4dc 100644
--- a/drivers/net/pcmcia/axnet_cs.c
+++ b/drivers/net/pcmcia/axnet_cs.c
@@ -232,7 +232,7 @@ static int get_prom(struct pcmcia_device *link)
     axnet_reset_8390(dev);
     mdelay(10);
 
-    for (i = 0; i < sizeof(program_seq)/sizeof(program_seq[0]); i++)
+    for (i = 0; i < ARRAY_SIZE(program_seq); i++)
 	outb_p(program_seq[i].value, ioaddr + program_seq[i].offset);
 
     for (i = 0; i < 6; i += 2) {
diff --git a/drivers/net/pcmcia/pcnet_cs.c b/drivers/net/pcmcia/pcnet_cs.c
index 63de89e..02c245b 100644
--- a/drivers/net/pcmcia/pcnet_cs.c
+++ b/drivers/net/pcmcia/pcnet_cs.c
@@ -207,7 +207,7 @@ static hw_info_t hw_info[] = {
     { /* PCMCIA Technology OEM */ 0x01c8, 0x00, 0xa0, 0x0c, 0 }
 };
 
-#define NR_INFO		(sizeof(hw_info)/sizeof(hw_info_t))
+#define NR_INFO		ARRAY_SIZE(hw_info)
 
 static hw_info_t default_info = { 0, 0, 0, 0, 0 };
 static hw_info_t dl10019_info = { 0, 0, 0, 0, IS_DL10019|HAS_MII };
@@ -375,7 +375,7 @@ static hw_info_t *get_prom(struct pcmcia_device *link)
     pcnet_reset_8390(dev);
     mdelay(10);
 
-    for (i = 0; i < sizeof(program_seq)/sizeof(program_seq[0]); i++)
+    for (i = 0; i < ARRAY_SIZE(program_seq); i++)
 	outb_p(program_seq[i].value, ioaddr + program_seq[i].offset);
 
     for (i = 0; i < 32; i++)
diff --git a/drivers/net/phy/phy.c b/drivers/net/phy/phy.c
index e323efd..003e7e7 100644
--- a/drivers/net/phy/phy.c
+++ b/drivers/net/phy/phy.c
@@ -204,7 +204,7 @@ static const struct phy_setting settings[] = {
 	},
 };
 
-#define MAX_NUM_SETTINGS (sizeof(settings)/sizeof(struct phy_setting))
+#define MAX_NUM_SETTINGS ARRAY_SIZE(settings)
 
 /**
  * phy_find_setting - find a PHY settings array entry that matches speed & duplex
diff --git a/drivers/net/skfp/smt.c b/drivers/net/skfp/smt.c
index 75afc1f..ced2c8f 100644
--- a/drivers/net/skfp/smt.c
+++ b/drivers/net/skfp/smt.c
@@ -1654,7 +1654,7 @@ static const struct smt_pdef {
 	{ SMT_P4053,	0,	SWAP_SMT_P4053			} ,
 } ;
 
-#define N_SMT_PLEN	(sizeof(smt_pdef)/sizeof(smt_pdef[0]))
+#define N_SMT_PLEN	ARRAY_SIZE(smt_pdef)
 
 int smt_check_para(struct s_smc *smc, struct smt_header	*sm,
 		   const u_short list[])
diff --git a/drivers/net/skfp/srf.c b/drivers/net/skfp/srf.c
index 16573ac..6caf713 100644
--- a/drivers/net/skfp/srf.c
+++ b/drivers/net/skfp/srf.c
@@ -43,7 +43,7 @@ static void clear_reported(struct s_smc *smc);
 static void smt_send_srf(struct s_smc *smc);
 static struct s_srf_evc *smt_get_evc(struct s_smc *smc, int code, int index);
 
-#define MAX_EVCS	(sizeof(smc->evcs)/sizeof(smc->evcs[0]))
+#define MAX_EVCS	ARRAY_SIZE(smc->evcs)
 
 struct evc_init {
 	u_char code ;
@@ -67,7 +67,7 @@ static const struct evc_init evc_inits[] = {
 	{ SMT_EVENT_PORT_PATH_CHANGE,		INDEX_PORT,NUMPHYS,SMT_P4053 } ,
 } ;
 
-#define MAX_INIT_EVC	(sizeof(evc_inits)/sizeof(evc_inits[0]))
+#define MAX_INIT_EVC	ARRAY_SIZE(evc_inits)
 
 void smt_init_evc(struct s_smc *smc)
 {
diff --git a/drivers/net/tulip/de4x5.c b/drivers/net/tulip/de4x5.c
index 0990289..dcddaf7 100644
--- a/drivers/net/tulip/de4x5.c
+++ b/drivers/net/tulip/de4x5.c
@@ -3946,7 +3946,7 @@ create_packet(struct net_device *dev, char *frame, int len)
 static int
 EISA_signature(char *name, struct device *device)
 {
-    int i, status = 0, siglen = sizeof(de4x5_signatures)/sizeof(c_char *);
+    int i, status = 0, siglen = ARRAY_SIZE(de4x5_signatures);
     struct eisa_device *edev;
 
     *name = '\0';
@@ -3967,7 +3967,7 @@ EISA_signature(char *name, struct device *device)
 static int
 PCI_signature(char *name, struct de4x5_private *lp)
 {
-    int i, status = 0, siglen = sizeof(de4x5_signatures)/sizeof(c_char *);
+    int i, status = 0, siglen = ARRAY_SIZE(de4x5_signatures);
 
     if (lp->chipset == DC21040) {
 	strcpy(name, "DE434/5");
@@ -5073,7 +5073,7 @@ mii_get_phy(struct net_device *dev)
 {
     struct de4x5_private *lp = netdev_priv(dev);
     u_long iobase = dev->base_addr;
-    int i, j, k, n, limit=sizeof(phy_info)/sizeof(struct phy_table);
+    int i, j, k, n, limit=ARRAY_SIZE(phy_info);
     int id;
 
     lp->active = 0;
diff --git a/drivers/net/wireless/airo.c b/drivers/net/wireless/airo.c
index ee1cc14..7519f9c 100644
--- a/drivers/net/wireless/airo.c
+++ b/drivers/net/wireless/airo.c
@@ -7579,9 +7579,9 @@ static const iw_handler		airo_private_handler[] =
 
 static const struct iw_handler_def	airo_handler_def =
 {
-	.num_standard	= sizeof(airo_handler)/sizeof(iw_handler),
-	.num_private	= sizeof(airo_private_handler)/sizeof(iw_handler),
-	.num_private_args = sizeof(airo_private_args)/sizeof(struct iw_priv_args),
+	.num_standard	= ARRAY_SIZE(airo_handler),
+	.num_private	= ARRAY_SIZE(airo_private_handler),
+	.num_private_args = ARRAY_SIZE(airo_private_args),
 	.standard	= airo_handler,
 	.private	= airo_private_handler,
 	.private_args	= airo_private_args,
diff --git a/drivers/net/wireless/hostap/hostap_ioctl.c b/drivers/net/wireless/hostap/hostap_ioctl.c
index 8c71077..65dffbb 100644
--- a/drivers/net/wireless/hostap/hostap_ioctl.c
+++ b/drivers/net/wireless/hostap/hostap_ioctl.c
@@ -3976,9 +3976,9 @@ static const iw_handler prism2_private_handler[] =
 
 const struct iw_handler_def hostap_iw_handler_def =
 {
-	.num_standard	= sizeof(prism2_handler) / sizeof(iw_handler),
-	.num_private	= sizeof(prism2_private_handler) / sizeof(iw_handler),
-	.num_private_args = sizeof(prism2_priv) / sizeof(struct iw_priv_args),
+	.num_standard	= ARRAY_SIZE(prism2_handler),
+	.num_private	= ARRAY_SIZE(prism2_private_handler),
+	.num_private_args = ARRAY_SIZE(prism2_priv),
 	.standard	= (iw_handler *) prism2_handler,
 	.private	= (iw_handler *) prism2_private_handler,
 	.private_args	= (struct iw_priv_args *) prism2_priv,
diff --git a/drivers/net/wireless/ipw2100.c b/drivers/net/wireless/ipw2100.c
index 8990585..7ba033b 100644
--- a/drivers/net/wireless/ipw2100.c
+++ b/drivers/net/wireless/ipw2100.c
@@ -8279,10 +8279,9 @@ static struct iw_statistics *ipw2100_wx_wireless_stats(struct net_device *dev)
 
 static struct iw_handler_def ipw2100_wx_handler_def = {
 	.standard = ipw2100_wx_handlers,
-	.num_standard = sizeof(ipw2100_wx_handlers) / sizeof(iw_handler),
-	.num_private = sizeof(ipw2100_private_handler) / sizeof(iw_handler),
-	.num_private_args = sizeof(ipw2100_private_args) /
-	    sizeof(struct iw_priv_args),
+	.num_standard = ARRAY_SIZE(ipw2100_wx_handlers),
+	.num_private = ARRAY_SIZE(ipw2100_private_handler),
+	.num_private_args = ARRAY_SIZE(ipw2100_private_args),
 	.private = (iw_handler *) ipw2100_private_handler,
 	.private_args = (struct iw_priv_args *)ipw2100_private_args,
 	.get_wireless_stats = ipw2100_wx_wireless_stats,
diff --git a/drivers/net/wireless/libertas/fw.c b/drivers/net/wireless/libertas/fw.c
index 2dc84ff..c77b1f4 100644
--- a/drivers/net/wireless/libertas/fw.c
+++ b/drivers/net/wireless/libertas/fw.c
@@ -179,8 +179,7 @@ static void wlan_init_adapter(wlan_private * priv)
 
 	/* 802.11 specific */
 	adapter->secinfo.wep_enabled = 0;
-	for (i = 0; i < sizeof(adapter->wep_keys) / sizeof(adapter->wep_keys[0]);
-	     i++)
+	for (i = 0; i < ARRAY_SIZE(adapter->wep_keys); i++)
 		memset(&adapter->wep_keys[i], 0, sizeof(struct WLAN_802_11_KEY));
 	adapter->wep_tx_keyidx = 0;
 	adapter->secinfo.auth_mode = IW_AUTH_ALG_OPEN_SYSTEM;
diff --git a/drivers/net/wireless/libertas/main.c b/drivers/net/wireless/libertas/main.c
index 9f36624..db9e504 100644
--- a/drivers/net/wireless/libertas/main.c
+++ b/drivers/net/wireless/libertas/main.c
@@ -121,28 +121,28 @@ struct region_cfp_table {
 static struct region_cfp_table region_cfp_table[] = {
 	{0x10,			/*US FCC */
 	 channel_freq_power_US_BG,
-	 sizeof(channel_freq_power_US_BG) / sizeof(struct chan_freq_power),
+	 ARRAY_SIZE(channel_freq_power_US_BG),
 	 }
 	,
 	{0x20,			/*CANADA IC */
 	 channel_freq_power_US_BG,
-	 sizeof(channel_freq_power_US_BG) / sizeof(struct chan_freq_power),
+	 ARRAY_SIZE(channel_freq_power_US_BG),
 	 }
 	,
 	{0x30, /*EU*/ channel_freq_power_EU_BG,
-	 sizeof(channel_freq_power_EU_BG) / sizeof(struct chan_freq_power),
+	 ARRAY_SIZE(channel_freq_power_EU_BG),
 	 }
 	,
 	{0x31, /*SPAIN*/ channel_freq_power_SPN_BG,
-	 sizeof(channel_freq_power_SPN_BG) / sizeof(struct chan_freq_power),
+	 ARRAY_SIZE(channel_freq_power_SPN_BG),
 	 }
 	,
 	{0x32, /*FRANCE*/ channel_freq_power_FR_BG,
-	 sizeof(channel_freq_power_FR_BG) / sizeof(struct chan_freq_power),
+	 ARRAY_SIZE(channel_freq_power_FR_BG),
 	 }
 	,
 	{0x40, /*JAPAN*/ channel_freq_power_JPN_BG,
-	 sizeof(channel_freq_power_JPN_BG) / sizeof(struct chan_freq_power),
+	 ARRAY_SIZE(channel_freq_power_JPN_BG),
 	 }
 	,
 /*Add new region here */
@@ -1076,7 +1076,7 @@ struct chan_freq_power *libertas_get_region_cfp_table(u8 region, u8 band, int *c
 
 	lbs_deb_enter(LBS_DEB_MAIN);
 
-	end = sizeof(region_cfp_table)/sizeof(struct region_cfp_table);
+	end = ARRAY_SIZE(region_cfp_table);
 
 	for (i = 0; i < end ; i++) {
 		lbs_deb_main("region_cfp_table[i].region=%d\n",
diff --git a/drivers/net/wireless/libertas/wext.c b/drivers/net/wireless/libertas/wext.c
index 2fcc3bf..8a9379c 100644
--- a/drivers/net/wireless/libertas/wext.c
+++ b/drivers/net/wireless/libertas/wext.c
@@ -2298,13 +2298,13 @@ static const iw_handler mesh_wlan_handler[] = {
 	(iw_handler) NULL,		/* SIOCSIWPMKSA */
 };
 struct iw_handler_def libertas_handler_def = {
-	.num_standard	= sizeof(wlan_handler) / sizeof(iw_handler),
+	.num_standard	= ARRAY_SIZE(wlan_handler),
 	.standard	= (iw_handler *) wlan_handler,
 	.get_wireless_stats = wlan_get_wireless_stats,
 };
 
 struct iw_handler_def mesh_handler_def = {
-	.num_standard	= sizeof(mesh_wlan_handler) / sizeof(iw_handler),
+	.num_standard	= ARRAY_SIZE(mesh_wlan_handler),
 	.standard	= (iw_handler *) mesh_wlan_handler,
 	.get_wireless_stats = wlan_get_wireless_stats,
 };
diff --git a/drivers/net/wireless/netwave_cs.c b/drivers/net/wireless/netwave_cs.c
index 45b00e1..c580188 100644
--- a/drivers/net/wireless/netwave_cs.c
+++ b/drivers/net/wireless/netwave_cs.c
@@ -710,9 +710,9 @@ static const iw_handler		netwave_private_handler[] =
 
 static const struct iw_handler_def	netwave_handler_def =
 {
-	.num_standard	= sizeof(netwave_handler)/sizeof(iw_handler),
-	.num_private	= sizeof(netwave_private_handler)/sizeof(iw_handler),
-	.num_private_args = sizeof(netwave_private_args)/sizeof(struct iw_priv_args),
+	.num_standard	= ARRAY_SIZE(netwave_handler),
+	.num_private	= ARRAY_SIZE(netwave_private_handler),
+	.num_private_args = ARRAY_SIZE(netwave_private_args),
 	.standard	= (iw_handler *) netwave_handler,
 	.private	= (iw_handler *) netwave_private_handler,
 	.private_args	= (struct iw_priv_args *) netwave_private_args,
diff --git a/drivers/net/wireless/prism54/isl_ioctl.c b/drivers/net/wireless/prism54/isl_ioctl.c
index 585f599..19e2b50 100644
--- a/drivers/net/wireless/prism54/isl_ioctl.c
+++ b/drivers/net/wireless/prism54/isl_ioctl.c
@@ -3239,10 +3239,9 @@ static const iw_handler prism54_private_handler[] = {
 };
 
 const struct iw_handler_def prism54_handler_def = {
-	.num_standard = sizeof (prism54_handler) / sizeof (iw_handler),
-	.num_private = sizeof (prism54_private_handler) / sizeof (iw_handler),
-	.num_private_args =
-	    sizeof (prism54_private_args) / sizeof (struct iw_priv_args),
+	.num_standard = ARRAY_SIZE(prism54_handler),
+	.num_private = ARRAY_SIZE(prism54_private_handler),
+	.num_private_args = ARRAY_SIZE(prism54_private_args),
 	.standard = (iw_handler *) prism54_handler,
 	.private = (iw_handler *) prism54_private_handler,
 	.private_args = (struct iw_priv_args *) prism54_private_args,
diff --git a/drivers/net/wireless/ray_cs.c b/drivers/net/wireless/ray_cs.c
index 3be6242..6a93fc6 100644
--- a/drivers/net/wireless/ray_cs.c
+++ b/drivers/net/wireless/ray_cs.c
@@ -1568,9 +1568,9 @@ static const struct iw_priv_args	ray_private_args[] = {
 
 static const struct iw_handler_def	ray_handler_def =
 {
-	.num_standard	= sizeof(ray_handler)/sizeof(iw_handler),
-	.num_private	= sizeof(ray_private_handler)/sizeof(iw_handler),
-	.num_private_args = sizeof(ray_private_args)/sizeof(struct iw_priv_args),
+	.num_standard	= ARRAY_SIZE(ray_handler),
+	.num_private	= ARRAY_SIZE(ray_private_handler),
+	.num_private_args = ARRAY_SIZE(ray_private_args),
 	.standard	= ray_handler,
 	.private	= ray_private_handler,
 	.private_args	= ray_private_args,
diff --git a/drivers/net/wireless/wavelan.c b/drivers/net/wireless/wavelan.c
index 1cf090d..d8803d6 100644
--- a/drivers/net/wireless/wavelan.c
+++ b/drivers/net/wireless/wavelan.c
@@ -2400,9 +2400,9 @@ static const struct iw_priv_args wavelan_private_args[] = {
 
 static const struct iw_handler_def	wavelan_handler_def =
 {
-	.num_standard	= sizeof(wavelan_handler)/sizeof(iw_handler),
-	.num_private	= sizeof(wavelan_private_handler)/sizeof(iw_handler),
-	.num_private_args = sizeof(wavelan_private_args)/sizeof(struct iw_priv_args),
+	.num_standard	= ARRAY_SIZE(wavelan_handler),
+	.num_private	= ARRAY_SIZE(wavelan_private_handler),
+	.num_private_args = ARRAY_SIZE(wavelan_private_args),
 	.standard	= wavelan_handler,
 	.private	= wavelan_private_handler,
 	.private_args	= wavelan_private_args,
diff --git a/drivers/net/wireless/wavelan_cs.c b/drivers/net/wireless/wavelan_cs.c
index 5740d4d..212afee 100644
--- a/drivers/net/wireless/wavelan_cs.c
+++ b/drivers/net/wireless/wavelan_cs.c
@@ -2719,9 +2719,9 @@ static const iw_handler		wavelan_private_handler[] =
 
 static const struct iw_handler_def	wavelan_handler_def =
 {
-	.num_standard	= sizeof(wavelan_handler)/sizeof(iw_handler),
-	.num_private	= sizeof(wavelan_private_handler)/sizeof(iw_handler),
-	.num_private_args = sizeof(wavelan_private_args)/sizeof(struct iw_priv_args),
+	.num_standard	= ARRAY_SIZE(wavelan_handler),
+	.num_private	= ARRAY_SIZE(wavelan_private_handler),
+	.num_private_args = ARRAY_SIZE(wavelan_private_args),
 	.standard	= wavelan_handler,
 	.private	= wavelan_private_handler,
 	.private_args	= wavelan_private_args,
diff --git a/drivers/net/wireless/wl3501_cs.c b/drivers/net/wireless/wl3501_cs.c
index c8b5c22..5874451 100644
--- a/drivers/net/wireless/wl3501_cs.c
+++ b/drivers/net/wireless/wl3501_cs.c
@@ -1894,7 +1894,7 @@ static const iw_handler	wl3501_handler[] = {
 };
 
 static const struct iw_handler_def wl3501_handler_def = {
-	.num_standard	= sizeof(wl3501_handler) / sizeof(iw_handler),
+	.num_standard	= ARRAY_SIZE(wl3501_handler),
 	.standard	= (iw_handler *)wl3501_handler,
 	.get_wireless_stats = wl3501_get_wireless_stats,
 };
diff --git a/drivers/net/zorro8390.c b/drivers/net/zorro8390.c
index d85e2ea..29f9750 100644
--- a/drivers/net/zorro8390.c
+++ b/drivers/net/zorro8390.c
@@ -191,7 +191,7 @@ static int __devinit zorro8390_init(struct net_device *dev,
 	    {0x00,	NE_EN0_RSARHI},
 	    {E8390_RREAD+E8390_START, NE_CMD},
 	};
-	for (i = 0; i < sizeof(program_seq)/sizeof(program_seq[0]); i++) {
+	for (i = 0; i < ARRAY_SIZE(program_seq); i++) {
 	    z_writeb(program_seq[i].value, ioaddr + program_seq[i].offset);
 	}
     }
-- 
1.5.3.rc7

