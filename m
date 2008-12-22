From: Hannes Eder <hannes@hanneseder.net>
Subject: [PATCH 25/27] drivers/net/wireless/b43: fix sparse warnings: make
	symbols static
Date: Mon, 22 Dec 2008 20:18:41 +0100
Message-ID: <20081222191841.11807.10116.stgit@vmbox.hanneseder.net>
References: <20081222191259.11807.53190.stgit@vmbox.hanneseder.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: kernel-janitors@vger.kernel.org, linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f21.google.com ([209.85.218.21]:50184 "EHLO
	mail-bw0-f21.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756093AbYLVTSt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Dec 2008 14:18:49 -0500
In-Reply-To: <20081222191259.11807.53190.stgit@vmbox.hanneseder.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fix this sparse warnings:

  drivers/net/wireless/b43/phy_a.c:80:6: warning: symbol 'b43_radio_set_tx_iq' was not declared. Should it be static?
  drivers/net/wireless/b43/phy_a.c:150:6: warning: symbol 'b43_radio_init2060' was not declared. Should it be static?
  drivers/net/wireless/b43/phy_g.c:57:10: warning: symbol 'b43_radio_channel_codes_bg' was not declared. Should it be static?
  drivers/net/wireless/b43/phy_g.c:218:6: warning: symbol 'b43_set_txpower_g' was not declared. Should it be static?
  drivers/net/wireless/b43/phy_g.c:386:6: warning: symbol 'b43_nrssi_hw_write' was not declared. Should it be static?
  drivers/net/wireless/b43/phy_g.c:393:5: warning: symbol 'b43_nrssi_hw_read' was not declared. Should it be static?
  drivers/net/wireless/b43/phy_g.c:404:6: warning: symbol 'b43_nrssi_hw_update' was not declared. Should it be static?
  drivers/net/wireless/b43/phy_g.c:418:6: warning: symbol 'b43_nrssi_mem_update' was not declared. Should it be static?
  drivers/net/wireless/b43/phy_g.c:592:6: warning: symbol 'b43_calc_nrssi_slope' was not declared. Should it be static?
  drivers/net/wireless/b43/phy_g.c:1357:5: warning: symbol 'b43_radio_init2050' was not declared. Should it be static?

Signed-off-by: Hannes Eder <hannes@hanneseder.net>
---
 drivers/net/wireless/b43/phy_a.c |    4 ++--
 drivers/net/wireless/b43/phy_g.c |   20 ++++++++++----------
 2 files changed, 12 insertions(+), 12 deletions(-)

diff --git a/drivers/net/wireless/b43/phy_a.c b/drivers/net/wireless/b43/phy_a.c
index 0f1a84c..7fe9d17 100644
--- a/drivers/net/wireless/b43/phy_a.c
+++ b/drivers/net/wireless/b43/phy_a.c
@@ -77,7 +77,7 @@ static s8 b43_aphy_estimate_power_out(struct b43_wldev *dev, s8 tssi)
 }
 #endif
 
-void b43_radio_set_tx_iq(struct b43_wldev *dev)
+static void b43_radio_set_tx_iq(struct b43_wldev *dev)
 {
 	static const u8 data_high[5] = { 0x00, 0x40, 0x80, 0x90, 0xD0 };
 	static const u8 data_low[5] = { 0x00, 0x01, 0x05, 0x06, 0x0A };
@@ -147,7 +147,7 @@ static void aphy_channel_switch(struct b43_wldev *dev, unsigned int channel)
 //FIXME	b43_phy_xmitpower(dev);
 }
 
-void b43_radio_init2060(struct b43_wldev *dev)
+static void b43_radio_init2060(struct b43_wldev *dev)
 {
 	b43_radio_write16(dev, 0x0004, 0x00C0);
 	b43_radio_write16(dev, 0x0005, 0x0008);
diff --git a/drivers/net/wireless/b43/phy_g.c b/drivers/net/wireless/b43/phy_g.c
index 232181f..9fc354c 100644
--- a/drivers/net/wireless/b43/phy_g.c
+++ b/drivers/net/wireless/b43/phy_g.c
@@ -54,7 +54,7 @@ static const s8 b43_tssi2dbm_g_table[] = {
 	-20, -20, -20, -20,
 };
 
-const u8 b43_radio_channel_codes_bg[] = {
+static const u8 b43_radio_channel_codes_bg[] = {
 	12, 17, 22, 27,
 	32, 37, 42, 47,
 	52, 57, 62, 67,
@@ -215,9 +215,9 @@ void b43_gphy_set_baseband_attenuation(struct b43_wldev *dev,
 }
 
 /* Adjust the transmission power output (G-PHY) */
-void b43_set_txpower_g(struct b43_wldev *dev,
-		       const struct b43_bbatt *bbatt,
-		       const struct b43_rfatt *rfatt, u8 tx_control)
+static void b43_set_txpower_g(struct b43_wldev *dev,
+			      const struct b43_bbatt *bbatt,
+			      const struct b43_rfatt *rfatt, u8 tx_control)
 {
 	struct b43_phy *phy = &dev->phy;
 	struct b43_phy_g *gphy = phy->g;
@@ -383,14 +383,14 @@ static void b43_set_original_gains(struct b43_wldev *dev)
 }
 
 /* http://bcm-specs.sipsolutions.net/NRSSILookupTable */
-void b43_nrssi_hw_write(struct b43_wldev *dev, u16 offset, s16 val)
+static void b43_nrssi_hw_write(struct b43_wldev *dev, u16 offset, s16 val)
 {
 	b43_phy_write(dev, B43_PHY_NRSSILT_CTRL, offset);
 	b43_phy_write(dev, B43_PHY_NRSSILT_DATA, (u16) val);
 }
 
 /* http://bcm-specs.sipsolutions.net/NRSSILookupTable */
-s16 b43_nrssi_hw_read(struct b43_wldev *dev, u16 offset)
+static s16 b43_nrssi_hw_read(struct b43_wldev *dev, u16 offset)
 {
 	u16 val;
 
@@ -401,7 +401,7 @@ s16 b43_nrssi_hw_read(struct b43_wldev *dev, u16 offset)
 }
 
 /* http://bcm-specs.sipsolutions.net/NRSSILookupTable */
-void b43_nrssi_hw_update(struct b43_wldev *dev, u16 val)
+static void b43_nrssi_hw_update(struct b43_wldev *dev, u16 val)
 {
 	u16 i;
 	s16 tmp;
@@ -415,7 +415,7 @@ void b43_nrssi_hw_update(struct b43_wldev *dev, u16 val)
 }
 
 /* http://bcm-specs.sipsolutions.net/NRSSILookupTable */
-void b43_nrssi_mem_update(struct b43_wldev *dev)
+static void b43_nrssi_mem_update(struct b43_wldev *dev)
 {
 	struct b43_phy_g *gphy = dev->phy.g;
 	s16 i, delta;
@@ -589,7 +589,7 @@ static void b43_calc_nrssi_offset(struct b43_wldev *dev)
 	b43_phy_write(dev, 0x0811, backup[1]);
 }
 
-void b43_calc_nrssi_slope(struct b43_wldev *dev)
+static void b43_calc_nrssi_slope(struct b43_wldev *dev)
 {
 	struct b43_phy *phy = &dev->phy;
 	struct b43_phy_g *gphy = phy->g;
@@ -1354,7 +1354,7 @@ struct init2050_saved_values {
 	u16 phy_syncctl;
 };
 
-u16 b43_radio_init2050(struct b43_wldev *dev)
+static u16 b43_radio_init2050(struct b43_wldev *dev)
 {
 	struct b43_phy *phy = &dev->phy;
 	struct init2050_saved_values sav;

