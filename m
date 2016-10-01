From: Joe Perches <joe@perches.com>
Subject: [PATCH] realtek: rtl8xxxu: Use const init arrays
Date: Sat,  1 Oct 2016 10:39:25 -0700
Message-ID: <459bf15427d92cd052fb2fe080438fd97a8a6cd8.1475343483.git.joe@perches.com>
Cc: Kalle Valo <kvalo@codeaurora.org>, linux-wireless@vger.kernel.org,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Jes Sorensen <Jes.Sorensen@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay0100.hostedemail.com ([216.40.44.100]:56976 "EHLO
        smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1751631AbcJARja (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 1 Oct 2016 13:39:30 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Make the init arrays const to reduce data.

$ size drivers/net/wireless/realtek/rtl8xxxu/built-in.o* (allyesconfig: x86-32)
   text	   data	    bss	    dec	    hex	filename
  80107	  13651	     58	  93816	  16e78	drivers/net/wireless/realtek/rtl8xxxu/built-in.o.new
  65303	  28435	     58	  93796	  16e64	drivers/net/wireless/realtek/rtl8xxxu/built-in.o.old

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/wireless/realtek/rtl8xxxu/rtl8xxxu.h       |  6 +++---
 drivers/net/wireless/realtek/rtl8xxxu/rtl8xxxu_8192e.c |  8 ++++----
 drivers/net/wireless/realtek/rtl8xxxu/rtl8xxxu_8723b.c |  6 +++---
 drivers/net/wireless/realtek/rtl8xxxu/rtl8xxxu_core.c  | 16 ++++++++--------
 4 files changed, 18 insertions(+), 18 deletions(-)

diff --git a/drivers/net/wireless/realtek/rtl8xxxu/rtl8xxxu.h b/drivers/net/wireless/realtek/rtl8xxxu/rtl8xxxu.h
index 1016628926d2..bd4449704dfa 100644
--- a/drivers/net/wireless/realtek/rtl8xxxu/rtl8xxxu.h
+++ b/drivers/net/wireless/realtek/rtl8xxxu/rtl8xxxu.h
@@ -1355,7 +1355,7 @@ struct rtl8xxxu_fileops {
 	u16 trxff_boundary;
 	u8 pbp_rx;
 	u8 pbp_tx;
-	struct rtl8xxxu_reg8val *mactable;
+	const struct rtl8xxxu_reg8val *mactable;
 	u8 total_page_num;
 	u8 page_num_hi;
 	u8 page_num_lo;
@@ -1364,7 +1364,7 @@ struct rtl8xxxu_fileops {
 
 extern int rtl8xxxu_debug;
 
-extern struct rtl8xxxu_reg8val rtl8xxxu_gen1_mac_init_table[];
+extern const struct rtl8xxxu_reg8val rtl8xxxu_gen1_mac_init_table[];
 extern const u32 rtl8xxxu_iqk_phy_iq_bb_reg[];
 u8 rtl8xxxu_read8(struct rtl8xxxu_priv *priv, u16 addr);
 u16 rtl8xxxu_read16(struct rtl8xxxu_priv *priv, u16 addr);
@@ -1396,7 +1396,7 @@ int rtl8xxxu_init_phy_rf(struct rtl8xxxu_priv *priv,
 			 struct rtl8xxxu_rfregval *table,
 			 enum rtl8xxxu_rfpath path);
 int rtl8xxxu_init_phy_regs(struct rtl8xxxu_priv *priv,
-			   struct rtl8xxxu_reg32val *array);
+			   const struct rtl8xxxu_reg32val *array);
 int rtl8xxxu_load_firmware(struct rtl8xxxu_priv *priv, char *fw_name);
 void rtl8xxxu_firmware_self_reset(struct rtl8xxxu_priv *priv);
 void rtl8xxxu_power_off(struct rtl8xxxu_priv *priv);
diff --git a/drivers/net/wireless/realtek/rtl8xxxu/rtl8xxxu_8192e.c b/drivers/net/wireless/realtek/rtl8xxxu/rtl8xxxu_8192e.c
index df54d27e7851..934a380f09b1 100644
--- a/drivers/net/wireless/realtek/rtl8xxxu/rtl8xxxu_8192e.c
+++ b/drivers/net/wireless/realtek/rtl8xxxu/rtl8xxxu_8192e.c
@@ -40,7 +40,7 @@
 #include "rtl8xxxu.h"
 #include "rtl8xxxu_regs.h"
 
-static struct rtl8xxxu_reg8val rtl8192e_mac_init_table[] = {
+static const struct rtl8xxxu_reg8val rtl8192e_mac_init_table[] = {
 	{0x011, 0xeb}, {0x012, 0x07}, {0x014, 0x75}, {0x303, 0xa7},
 	{0x428, 0x0a}, {0x429, 0x10}, {0x430, 0x00}, {0x431, 0x00},
 	{0x432, 0x00}, {0x433, 0x01}, {0x434, 0x04}, {0x435, 0x05},
@@ -70,7 +70,7 @@ static struct rtl8xxxu_reg8val rtl8192e_mac_init_table[] = {
 	{0xffff, 0xff},
 };
 
-static struct rtl8xxxu_reg32val rtl8192eu_phy_init_table[] = {
+static const struct rtl8xxxu_reg32val rtl8192eu_phy_init_table[] = {
 	{0x800, 0x80040000}, {0x804, 0x00000003},
 	{0x808, 0x0000fc00}, {0x80c, 0x0000000a},
 	{0x810, 0x10001331}, {0x814, 0x020c3d10},
@@ -202,7 +202,7 @@ static struct rtl8xxxu_reg32val rtl8192eu_phy_init_table[] = {
 	{0xffff, 0xffffffff},
 };
 
-static struct rtl8xxxu_reg32val rtl8xxx_agc_8192eu_std_table[] = {
+static const struct rtl8xxxu_reg32val rtl8xxx_agc_8192eu_std_table[] = {
 	{0xc78, 0xfb000001}, {0xc78, 0xfb010001},
 	{0xc78, 0xfb020001}, {0xc78, 0xfb030001},
 	{0xc78, 0xfb040001}, {0xc78, 0xfb050001},
@@ -271,7 +271,7 @@ static struct rtl8xxxu_reg32val rtl8xxx_agc_8192eu_std_table[] = {
 	{0xffff, 0xffffffff}
 };
 
-static struct rtl8xxxu_reg32val rtl8xxx_agc_8192eu_highpa_table[] = {
+static const struct rtl8xxxu_reg32val rtl8xxx_agc_8192eu_highpa_table[] = {
 	{0xc78, 0xfa000001}, {0xc78, 0xf9010001},
 	{0xc78, 0xf8020001}, {0xc78, 0xf7030001},
 	{0xc78, 0xf6040001}, {0xc78, 0xf5050001},
diff --git a/drivers/net/wireless/realtek/rtl8xxxu/rtl8xxxu_8723b.c b/drivers/net/wireless/realtek/rtl8xxxu/rtl8xxxu_8723b.c
index 6c086b5657e9..3f173b67fc0d 100644
--- a/drivers/net/wireless/realtek/rtl8xxxu/rtl8xxxu_8723b.c
+++ b/drivers/net/wireless/realtek/rtl8xxxu/rtl8xxxu_8723b.c
@@ -40,7 +40,7 @@
 #include "rtl8xxxu.h"
 #include "rtl8xxxu_regs.h"
 
-static struct rtl8xxxu_reg8val rtl8723b_mac_init_table[] = {
+static const struct rtl8xxxu_reg8val rtl8723b_mac_init_table[] = {
 	{0x02f, 0x30}, {0x035, 0x00}, {0x039, 0x08}, {0x04e, 0xe0},
 	{0x064, 0x00}, {0x067, 0x20}, {0x428, 0x0a}, {0x429, 0x10},
 	{0x430, 0x00}, {0x431, 0x00},
@@ -71,7 +71,7 @@ static struct rtl8xxxu_reg8val rtl8723b_mac_init_table[] = {
 	{0xffff, 0xff},
 };
 
-static struct rtl8xxxu_reg32val rtl8723b_phy_1t_init_table[] = {
+static const struct rtl8xxxu_reg32val rtl8723b_phy_1t_init_table[] = {
 	{0x800, 0x80040000}, {0x804, 0x00000003},
 	{0x808, 0x0000fc00}, {0x80c, 0x0000000a},
 	{0x810, 0x10001331}, {0x814, 0x020c3d10},
@@ -172,7 +172,7 @@ static struct rtl8xxxu_reg32val rtl8723b_phy_1t_init_table[] = {
 	{0xffff, 0xffffffff},
 };
 
-static struct rtl8xxxu_reg32val rtl8xxx_agc_8723bu_table[] = {
+static const struct rtl8xxxu_reg32val rtl8xxx_agc_8723bu_table[] = {
 	{0xc78, 0xfd000001}, {0xc78, 0xfc010001},
 	{0xc78, 0xfb020001}, {0xc78, 0xfa030001},
 	{0xc78, 0xf9040001}, {0xc78, 0xf8050001},
diff --git a/drivers/net/wireless/realtek/rtl8xxxu/rtl8xxxu_core.c b/drivers/net/wireless/realtek/rtl8xxxu/rtl8xxxu_core.c
index b2d7f6e69667..7c62293948cb 100644
--- a/drivers/net/wireless/realtek/rtl8xxxu/rtl8xxxu_core.c
+++ b/drivers/net/wireless/realtek/rtl8xxxu/rtl8xxxu_core.c
@@ -135,7 +135,7 @@ static struct ieee80211_supported_band rtl8xxxu_supported_band = {
 	.n_bitrates = ARRAY_SIZE(rtl8xxxu_rates),
 };
 
-struct rtl8xxxu_reg8val rtl8xxxu_gen1_mac_init_table[] = {
+const struct rtl8xxxu_reg8val rtl8xxxu_gen1_mac_init_table[] = {
 	{0x420, 0x80}, {0x423, 0x00}, {0x430, 0x00}, {0x431, 0x00},
 	{0x432, 0x00}, {0x433, 0x01}, {0x434, 0x04}, {0x435, 0x05},
 	{0x436, 0x06}, {0x437, 0x07}, {0x438, 0x00}, {0x439, 0x00},
@@ -160,7 +160,7 @@ struct rtl8xxxu_reg8val rtl8xxxu_gen1_mac_init_table[] = {
 	{0x70a, 0x65}, {0x70b, 0x87}, {0xffff, 0xff},
 };
 
-static struct rtl8xxxu_reg32val rtl8723a_phy_1t_init_table[] = {
+static const struct rtl8xxxu_reg32val rtl8723a_phy_1t_init_table[] = {
 	{0x800, 0x80040000}, {0x804, 0x00000003},
 	{0x808, 0x0000fc00}, {0x80c, 0x0000000a},
 	{0x810, 0x10001331}, {0x814, 0x020c3d10},
@@ -258,7 +258,7 @@ static struct rtl8xxxu_reg32val rtl8723a_phy_1t_init_table[] = {
 	{0xffff, 0xffffffff},
 };
 
-static struct rtl8xxxu_reg32val rtl8192cu_phy_2t_init_table[] = {
+static const struct rtl8xxxu_reg32val rtl8192cu_phy_2t_init_table[] = {
 	{0x024, 0x0011800f}, {0x028, 0x00ffdb83},
 	{0x800, 0x80040002}, {0x804, 0x00000003},
 	{0x808, 0x0000fc00}, {0x80c, 0x0000000a},
@@ -356,7 +356,7 @@ static struct rtl8xxxu_reg32val rtl8192cu_phy_2t_init_table[] = {
 	{0xffff, 0xffffffff},
 };
 
-static struct rtl8xxxu_reg32val rtl8188ru_phy_1t_highpa_table[] = {
+static const struct rtl8xxxu_reg32val rtl8188ru_phy_1t_highpa_table[] = {
 	{0x024, 0x0011800f}, {0x028, 0x00ffdb83},
 	{0x040, 0x000c0004}, {0x800, 0x80040000},
 	{0x804, 0x00000001}, {0x808, 0x0000fc00},
@@ -455,7 +455,7 @@ static struct rtl8xxxu_reg32val rtl8188ru_phy_1t_highpa_table[] = {
 	{0xffff, 0xffffffff},
 };
 
-static struct rtl8xxxu_reg32val rtl8xxx_agc_standard_table[] = {
+static const struct rtl8xxxu_reg32val rtl8xxx_agc_standard_table[] = {
 	{0xc78, 0x7b000001}, {0xc78, 0x7b010001},
 	{0xc78, 0x7b020001}, {0xc78, 0x7b030001},
 	{0xc78, 0x7b040001}, {0xc78, 0x7b050001},
@@ -539,7 +539,7 @@ static struct rtl8xxxu_reg32val rtl8xxx_agc_standard_table[] = {
 	{0xffff, 0xffffffff}
 };
 
-static struct rtl8xxxu_reg32val rtl8xxx_agc_highpa_table[] = {
+static const struct rtl8xxxu_reg32val rtl8xxx_agc_highpa_table[] = {
 	{0xc78, 0x7b000001}, {0xc78, 0x7b010001},
 	{0xc78, 0x7b020001}, {0xc78, 0x7b030001},
 	{0xc78, 0x7b040001}, {0xc78, 0x7b050001},
@@ -2146,7 +2146,7 @@ void rtl8xxxu_firmware_self_reset(struct rtl8xxxu_priv *priv)
 static int
 rtl8xxxu_init_mac(struct rtl8xxxu_priv *priv)
 {
-	struct rtl8xxxu_reg8val *array = priv->fops->mactable;
+	const struct rtl8xxxu_reg8val *array = priv->fops->mactable;
 	int i, ret;
 	u16 reg;
 	u8 val;
@@ -2174,7 +2174,7 @@ rtl8xxxu_init_mac(struct rtl8xxxu_priv *priv)
 }
 
 int rtl8xxxu_init_phy_regs(struct rtl8xxxu_priv *priv,
-			   struct rtl8xxxu_reg32val *array)
+			   const struct rtl8xxxu_reg32val *array)
 {
 	int i, ret;
 	u16 reg;
-- 
2.10.0.rc2.1.g053435c
