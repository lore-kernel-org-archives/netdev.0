From: Bill Pemberton <wfp5p@virginia.edu>
Subject: [PATCH 333/493] net: remove use of __devinitdata
Date: Mon, 19 Nov 2012 13:24:42 -0500
Message-ID: <1353349642-3677-333-git-send-email-wfp5p@virginia.edu>
References: <1353349642-3677-1-git-send-email-wfp5p@virginia.edu>
Cc: Wolfgang Grandegger <wg@grandegger.com>,
	Marc Kleine-Budde <mkl@pengutronix.de>,
	"Maciej W. Rozycki" <macro@linux-mips.org>,
	Jes Sorensen <jes@trained-monkey.org>,
	"John W. Linville" <linville@tuxdriver.com>,
	Larry Finger <Larry.Finger@lwfinger.net>,
	Chaoming Li <chaoming_li@realsil.com.cn>,
	linux-can@vger.kernel.org, netdev@vger.kernel.org,
	linux-hippi@sunsite.dk, linux-wireless@vger.kernel.org
To: gregkh@linuxfoundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from viridian.itc.Virginia.EDU ([128.143.12.139]:41475 "EHLO
	viridian.itc.virginia.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754197Ab2KSSec (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Nov 2012 13:34:32 -0500
In-Reply-To: <1353349642-3677-1-git-send-email-wfp5p@virginia.edu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

CONFIG_HOTPLUG is going away as an option so __devinitdata is no
longer needed.

Signed-off-by: Bill Pemberton <wfp5p@virginia.edu>
Cc: Wolfgang Grandegger <wg@grandegger.com> 
Cc: Marc Kleine-Budde <mkl@pengutronix.de> 
Cc: "Maciej W. Rozycki" <macro@linux-mips.org> 
Cc: Jes Sorensen <jes@trained-monkey.org> 
Cc: "John W. Linville" <linville@tuxdriver.com> 
Cc: Larry Finger <Larry.Finger@lwfinger.net> 
Cc: Chaoming Li <chaoming_li@realsil.com.cn> 
Cc: linux-can@vger.kernel.org 
Cc: netdev@vger.kernel.org 
Cc: linux-hippi@sunsite.dk 
Cc: linux-wireless@vger.kernel.org 
---
 drivers/net/can/cc770/cc770_isa.c             | 12 ++++++------
 drivers/net/can/cc770/cc770_platform.c        |  2 +-
 drivers/net/can/mscan/mpc5xxx_can.c           |  4 ++--
 drivers/net/can/sja1000/plx_pci.c             | 16 ++++++++--------
 drivers/net/can/sja1000/sja1000_isa.c         | 10 +++++-----
 drivers/net/can/sja1000/sja1000_of_platform.c |  2 +-
 drivers/net/fddi/defxx.c                      |  2 +-
 drivers/net/hippi/rrunner.c                   |  2 +-
 drivers/net/wan/farsync.c                     |  2 +-
 drivers/net/wireless/mwl8k.c                  |  2 +-
 drivers/net/wireless/rtlwifi/rtl8192de/sw.c   |  2 +-
 drivers/net/wireless/rtlwifi/rtl8192se/sw.c   |  2 +-
 drivers/net/wireless/rtlwifi/rtl8723ae/sw.c   |  2 +-
 13 files changed, 30 insertions(+), 30 deletions(-)

diff --git a/drivers/net/can/cc770/cc770_isa.c b/drivers/net/can/cc770/cc770_isa.c
index 9ca0461..bed9d19 100644
--- a/drivers/net/can/cc770/cc770_isa.c
+++ b/drivers/net/can/cc770/cc770_isa.c
@@ -75,12 +75,12 @@ MODULE_LICENSE("GPL v2");
 
 static unsigned long port[MAXDEV];
 static unsigned long mem[MAXDEV];
-static int __devinitdata irq[MAXDEV];
-static int __devinitdata clk[MAXDEV];
-static u8 __devinitdata cir[MAXDEV] = {[0 ... (MAXDEV - 1)] = 0xff};
-static u8 __devinitdata cor[MAXDEV] = {[0 ... (MAXDEV - 1)] = 0xff};
-static u8 __devinitdata bcr[MAXDEV] = {[0 ... (MAXDEV - 1)] = 0xff};
-static int __devinitdata indirect[MAXDEV] = {[0 ... (MAXDEV - 1)] = -1};
+static int irq[MAXDEV];
+static int clk[MAXDEV];
+static u8 cir[MAXDEV] = {[0 ... (MAXDEV - 1)] = 0xff};
+static u8 cor[MAXDEV] = {[0 ... (MAXDEV - 1)] = 0xff};
+static u8 bcr[MAXDEV] = {[0 ... (MAXDEV - 1)] = 0xff};
+static int indirect[MAXDEV] = {[0 ... (MAXDEV - 1)] = -1};
 
 module_param_array(port, ulong, NULL, S_IRUGO);
 MODULE_PARM_DESC(port, "I/O port number");
diff --git a/drivers/net/can/cc770/cc770_platform.c b/drivers/net/can/cc770/cc770_platform.c
index fef046f..caf4d70 100644
--- a/drivers/net/can/cc770/cc770_platform.c
+++ b/drivers/net/can/cc770/cc770_platform.c
@@ -253,7 +253,7 @@ static int __devexit cc770_platform_remove(struct platform_device *pdev)
 	return 0;
 }
 
-static struct of_device_id __devinitdata cc770_platform_table[] = {
+static struct of_device_id cc770_platform_table[] = {
 	{.compatible = "bosch,cc770"}, /* CC770 from Bosch */
 	{.compatible = "intc,82527"},  /* AN82527 from Intel CP */
 	{},
diff --git a/drivers/net/can/mscan/mpc5xxx_can.c b/drivers/net/can/mscan/mpc5xxx_can.c
index 752bfed..254c168 100644
--- a/drivers/net/can/mscan/mpc5xxx_can.c
+++ b/drivers/net/can/mscan/mpc5xxx_can.c
@@ -43,7 +43,7 @@ struct mpc5xxx_can_data {
 };
 
 #ifdef CONFIG_PPC_MPC52xx
-static struct of_device_id __devinitdata mpc52xx_cdm_ids[] = {
+static struct of_device_id mpc52xx_cdm_ids[] = {
 	{ .compatible = "fsl,mpc5200-cdm", },
 	{}
 };
@@ -124,7 +124,7 @@ struct mpc512x_clockctl {
 	u32 mccr[4];		/* MSCAN Clk Ctrl Reg 1-3 */
 };
 
-static struct of_device_id __devinitdata mpc512x_clock_ids[] = {
+static struct of_device_id mpc512x_clock_ids[] = {
 	{ .compatible = "fsl,mpc5121-clock", },
 	{}
 };
diff --git a/drivers/net/can/sja1000/plx_pci.c b/drivers/net/can/sja1000/plx_pci.c
index 619b96c..f1c7a50 100644
--- a/drivers/net/can/sja1000/plx_pci.c
+++ b/drivers/net/can/sja1000/plx_pci.c
@@ -158,7 +158,7 @@ struct plx_pci_card_info {
 	void (*reset_func)(struct pci_dev *pdev);
 };
 
-static struct plx_pci_card_info plx_pci_card_info_adlink __devinitdata = {
+static struct plx_pci_card_info plx_pci_card_info_adlink = {
 	"Adlink PCI-7841/cPCI-7841", 2,
 	PLX_PCI_CAN_CLOCK, PLX_PCI_OCR, PLX_PCI_CDR,
 	{1, 0x00, 0x00}, { {2, 0x00, 0x80}, {2, 0x80, 0x80} },
@@ -166,7 +166,7 @@ static struct plx_pci_card_info plx_pci_card_info_adlink __devinitdata = {
 	/* based on PLX9052 */
 };
 
-static struct plx_pci_card_info plx_pci_card_info_adlink_se __devinitdata = {
+static struct plx_pci_card_info plx_pci_card_info_adlink_se = {
 	"Adlink PCI-7841/cPCI-7841 SE", 2,
 	PLX_PCI_CAN_CLOCK, PLX_PCI_OCR, PLX_PCI_CDR,
 	{0, 0x00, 0x00}, { {2, 0x00, 0x80}, {2, 0x80, 0x80} },
@@ -174,7 +174,7 @@ static struct plx_pci_card_info plx_pci_card_info_adlink_se __devinitdata = {
 	/* based on PLX9052 */
 };
 
-static struct plx_pci_card_info plx_pci_card_info_esd200 __devinitdata = {
+static struct plx_pci_card_info plx_pci_card_info_esd200 = {
 	"esd CAN-PCI/CPCI/PCI104/200", 2,
 	PLX_PCI_CAN_CLOCK, PLX_PCI_OCR, PLX_PCI_CDR,
 	{0, 0x00, 0x00}, { {2, 0x00, 0x80}, {2, 0x100, 0x80} },
@@ -182,7 +182,7 @@ static struct plx_pci_card_info plx_pci_card_info_esd200 __devinitdata = {
 	/* based on PLX9030/9050 */
 };
 
-static struct plx_pci_card_info plx_pci_card_info_esd266 __devinitdata = {
+static struct plx_pci_card_info plx_pci_card_info_esd266 = {
 	"esd CAN-PCI/PMC/266", 2,
 	PLX_PCI_CAN_CLOCK, PLX_PCI_OCR, PLX_PCI_CDR,
 	{0, 0x00, 0x00}, { {2, 0x00, 0x80}, {2, 0x100, 0x80} },
@@ -190,7 +190,7 @@ static struct plx_pci_card_info plx_pci_card_info_esd266 __devinitdata = {
 	/* based on PLX9056 */
 };
 
-static struct plx_pci_card_info plx_pci_card_info_esd2000 __devinitdata = {
+static struct plx_pci_card_info plx_pci_card_info_esd2000 = {
 	"esd CAN-PCIe/2000", 2,
 	PLX_PCI_CAN_CLOCK, PLX_PCI_OCR, PLX_PCI_CDR,
 	{0, 0x00, 0x00}, { {2, 0x00, 0x80}, {2, 0x100, 0x80} },
@@ -198,7 +198,7 @@ static struct plx_pci_card_info plx_pci_card_info_esd2000 __devinitdata = {
 	/* based on PEX8311 */
 };
 
-static struct plx_pci_card_info plx_pci_card_info_ixxat __devinitdata = {
+static struct plx_pci_card_info plx_pci_card_info_ixxat = {
 	"IXXAT PC-I 04/PCI", 2,
 	PLX_PCI_CAN_CLOCK, PLX_PCI_OCR, PLX_PCI_CDR,
 	{0, 0x00, 0x00}, { {2, 0x00, 0x80}, {2, 0x200, 0x80} },
@@ -206,7 +206,7 @@ static struct plx_pci_card_info plx_pci_card_info_ixxat __devinitdata = {
 	/* based on PLX9050 */
 };
 
-static struct plx_pci_card_info plx_pci_card_info_marathon __devinitdata = {
+static struct plx_pci_card_info plx_pci_card_info_marathon = {
 	"Marathon CAN-bus-PCI", 2,
 	PLX_PCI_CAN_CLOCK, PLX_PCI_OCR, PLX_PCI_CDR,
 	{0, 0x00, 0x00}, { {2, 0x00, 0x00}, {4, 0x00, 0x00} },
@@ -214,7 +214,7 @@ static struct plx_pci_card_info plx_pci_card_info_marathon __devinitdata = {
 	/* based on PLX9052 */
 };
 
-static struct plx_pci_card_info plx_pci_card_info_tews __devinitdata = {
+static struct plx_pci_card_info plx_pci_card_info_tews = {
 	"TEWS TECHNOLOGIES TPMC810", 2,
 	PLX_PCI_CAN_CLOCK, PLX_PCI_OCR, PLX_PCI_CDR,
 	{0, 0x00, 0x00}, { {2, 0x000, 0x80}, {2, 0x100, 0x80} },
diff --git a/drivers/net/can/sja1000/sja1000_isa.c b/drivers/net/can/sja1000/sja1000_isa.c
index 3f12e85..a872f24 100644
--- a/drivers/net/can/sja1000/sja1000_isa.c
+++ b/drivers/net/can/sja1000/sja1000_isa.c
@@ -42,11 +42,11 @@ MODULE_LICENSE("GPL v2");
 
 static unsigned long port[MAXDEV];
 static unsigned long mem[MAXDEV];
-static int __devinitdata irq[MAXDEV];
-static int __devinitdata clk[MAXDEV];
-static unsigned char __devinitdata cdr[MAXDEV] = {[0 ... (MAXDEV - 1)] = 0xff};
-static unsigned char __devinitdata ocr[MAXDEV] = {[0 ... (MAXDEV - 1)] = 0xff};
-static int __devinitdata indirect[MAXDEV] = {[0 ... (MAXDEV - 1)] = -1};
+static int irq[MAXDEV];
+static int clk[MAXDEV];
+static unsigned char cdr[MAXDEV] = {[0 ... (MAXDEV - 1)] = 0xff};
+static unsigned char ocr[MAXDEV] = {[0 ... (MAXDEV - 1)] = 0xff};
+static int indirect[MAXDEV] = {[0 ... (MAXDEV - 1)] = -1};
 
 module_param_array(port, ulong, NULL, S_IRUGO);
 MODULE_PARM_DESC(port, "I/O port number");
diff --git a/drivers/net/can/sja1000/sja1000_of_platform.c b/drivers/net/can/sja1000/sja1000_of_platform.c
index 259d5a1d..1ca0ee1 100644
--- a/drivers/net/can/sja1000/sja1000_of_platform.c
+++ b/drivers/net/can/sja1000/sja1000_of_platform.c
@@ -204,7 +204,7 @@ exit_release_mem:
 	return err;
 }
 
-static struct of_device_id __devinitdata sja1000_ofp_table[] = {
+static struct of_device_id sja1000_ofp_table[] = {
 	{.compatible = "nxp,sja1000"},
 	{},
 };
diff --git a/drivers/net/fddi/defxx.c b/drivers/net/fddi/defxx.c
index 13f42cc..fd58f0b 100644
--- a/drivers/net/fddi/defxx.c
+++ b/drivers/net/fddi/defxx.c
@@ -228,7 +228,7 @@
 #define DRV_VERSION "v1.10"
 #define DRV_RELDATE "2006/12/14"
 
-static char version[] __devinitdata =
+static char version[] =
 	DRV_NAME ": " DRV_VERSION " " DRV_RELDATE
 	"  Lawrence V. Stefani and others\n";
 
diff --git a/drivers/net/hippi/rrunner.c b/drivers/net/hippi/rrunner.c
index 164d845..12b7ff9 100644
--- a/drivers/net/hippi/rrunner.c
+++ b/drivers/net/hippi/rrunner.c
@@ -61,7 +61,7 @@ MODULE_AUTHOR("Jes Sorensen <jes@wildopensource.com>");
 MODULE_DESCRIPTION("Essential RoadRunner HIPPI driver");
 MODULE_LICENSE("GPL");
 
-static char version[] __devinitdata = "rrunner.c: v0.50 11/11/2002  Jes Sorensen (jes@wildopensource.com)\n";
+static char version[] = "rrunner.c: v0.50 11/11/2002  Jes Sorensen (jes@wildopensource.com)\n";
 
 
 static const struct net_device_ops rr_netdev_ops = {
diff --git a/drivers/net/wan/farsync.c b/drivers/net/wan/farsync.c
index dc529aa..dbbe06e 100644
--- a/drivers/net/wan/farsync.c
+++ b/drivers/net/wan/farsync.c
@@ -2361,7 +2361,7 @@ fst_start_xmit(struct sk_buff *skb, struct net_device *dev)
  *      via a printk and leave the corresponding interface and all that follow
  *      disabled.
  */
-static char *type_strings[] __devinitdata = {
+static char *type_strings[] = {
 	"no hardware",		/* Should never be seen */
 	"FarSync T2P",
 	"FarSync T4P",
diff --git a/drivers/net/wireless/mwl8k.c b/drivers/net/wireless/mwl8k.c
index 1bbdc63..b9f71fd 100644
--- a/drivers/net/wireless/mwl8k.c
+++ b/drivers/net/wireless/mwl8k.c
@@ -5257,7 +5257,7 @@ enum {
 #define _MWL8K_8366_AP_FW(api) "mwl8k/fmimage_8366_ap-" #api ".fw"
 #define MWL8K_8366_AP_FW(api) _MWL8K_8366_AP_FW(api)
 
-static struct mwl8k_device_info mwl8k_info_tbl[] __devinitdata = {
+static struct mwl8k_device_info mwl8k_info_tbl[] = {
 	[MWL8363] = {
 		.part_name	= "88w8363",
 		.helper_image	= "mwl8k/helper_8363.fw",
diff --git a/drivers/net/wireless/rtlwifi/rtl8192de/sw.c b/drivers/net/wireless/rtlwifi/rtl8192de/sw.c
index 480862c..93d792a 100644
--- a/drivers/net/wireless/rtlwifi/rtl8192de/sw.c
+++ b/drivers/net/wireless/rtlwifi/rtl8192de/sw.c
@@ -352,7 +352,7 @@ static struct rtl_hal_cfg rtl92de_hal_cfg = {
 	.maps[RTL_RC_HT_RATEMCS15] = DESC92_RATEMCS15,
 };
 
-static struct pci_device_id rtl92de_pci_ids[] __devinitdata = {
+static struct pci_device_id rtl92de_pci_ids[] = {
 	{RTL_PCI_DEVICE(PCI_VENDOR_ID_REALTEK, 0x8193, rtl92de_hal_cfg)},
 	{RTL_PCI_DEVICE(PCI_VENDOR_ID_REALTEK, 0x002B, rtl92de_hal_cfg)},
 	{},
diff --git a/drivers/net/wireless/rtlwifi/rtl8192se/sw.c b/drivers/net/wireless/rtlwifi/rtl8192se/sw.c
index ad4b480..ca80fa8 100644
--- a/drivers/net/wireless/rtlwifi/rtl8192se/sw.c
+++ b/drivers/net/wireless/rtlwifi/rtl8192se/sw.c
@@ -403,7 +403,7 @@ static struct rtl_hal_cfg rtl92se_hal_cfg = {
 	.maps[RTL_RC_HT_RATEMCS15] = DESC92_RATEMCS15,
 };
 
-static struct pci_device_id rtl92se_pci_ids[] __devinitdata = {
+static struct pci_device_id rtl92se_pci_ids[] = {
 	{RTL_PCI_DEVICE(PCI_VENDOR_ID_REALTEK, 0x8192, rtl92se_hal_cfg)},
 	{RTL_PCI_DEVICE(PCI_VENDOR_ID_REALTEK, 0x8171, rtl92se_hal_cfg)},
 	{RTL_PCI_DEVICE(PCI_VENDOR_ID_REALTEK, 0x8172, rtl92se_hal_cfg)},
diff --git a/drivers/net/wireless/rtlwifi/rtl8723ae/sw.c b/drivers/net/wireless/rtlwifi/rtl8723ae/sw.c
index 0afdc24..b1c3626 100644
--- a/drivers/net/wireless/rtlwifi/rtl8723ae/sw.c
+++ b/drivers/net/wireless/rtlwifi/rtl8723ae/sw.c
@@ -341,7 +341,7 @@ static struct rtl_hal_cfg rtl8723ae_hal_cfg = {
 	.maps[RTL_RC_HT_RATEMCS15] = DESC92_RATEMCS15,
 };
 
-static struct pci_device_id rtl8723ae_pci_ids[] __devinitdata = {
+static struct pci_device_id rtl8723ae_pci_ids[] = {
 	{RTL_PCI_DEVICE(PCI_VENDOR_ID_REALTEK, 0x8723, rtl8723ae_hal_cfg)},
 	{},
 };
-- 
1.8.0
