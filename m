From: Joe Perches <joe@perches.com>
Subject: [PATCH 30/62] ksz884x: Use static const
Date: Sat, 20 Nov 2010 18:38:31 -0800
Message-ID: <cdf8dc7ba628b48a602ead709ef7abd42639863e.1290305776.git.joe@perches.com>
References: <cover.1290305773.git.joe@perches.com>
Cc: linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.perches.com ([173.55.12.10]:1685 "EHLO mail.perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756684Ab0KUCkL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 20 Nov 2010 21:40:11 -0500
In-Reply-To: <cover.1290305773.git.joe@perches.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Using static const generally increases object text and decreases data size.
It also generally decreases overall object size.

   text	   data	    bss	    dec	    hex	filename
  42018	   1721	  10204	  53943	   d2b7	drivers/net/ksz884x.o.new
  42164	   1721	  10204	  54089	   d349	drivers/net/ksz884x.o.old

Changed some functions to take const u8 *.

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/ksz884x.c |   20 ++++++++++----------
 1 files changed, 10 insertions(+), 10 deletions(-)

diff --git a/drivers/net/ksz884x.c b/drivers/net/ksz884x.c
index 37504a3..49ea870 100644
--- a/drivers/net/ksz884x.c
+++ b/drivers/net/ksz884x.c
@@ -3570,7 +3570,7 @@ static void hw_cfg_wol(struct ksz_hw *hw, u16 frame, int set)
  * This routine is used to program Wake-on-LAN pattern.
  */
 static void hw_set_wol_frame(struct ksz_hw *hw, int i, uint mask_size,
-	u8 *mask, uint frame_size, u8 *pattern)
+	const u8 *mask, uint frame_size, const u8 *pattern)
 {
 	int bits;
 	int from;
@@ -3626,9 +3626,9 @@ static void hw_set_wol_frame(struct ksz_hw *hw, int i, uint mask_size,
  *
  * This routine is used to add ARP pattern for waking up the host.
  */
-static void hw_add_wol_arp(struct ksz_hw *hw, u8 *ip_addr)
+static void hw_add_wol_arp(struct ksz_hw *hw, const u8 *ip_addr)
 {
-	u8 mask[6] = { 0x3F, 0xF0, 0x3F, 0x00, 0xC0, 0x03 };
+	static const u8 mask[6] = { 0x3F, 0xF0, 0x3F, 0x00, 0xC0, 0x03 };
 	u8 pattern[42] = {
 		0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF,
 		0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
@@ -3651,8 +3651,8 @@ static void hw_add_wol_arp(struct ksz_hw *hw, u8 *ip_addr)
  */
 static void hw_add_wol_bcast(struct ksz_hw *hw)
 {
-	u8 mask[] = { 0x3F };
-	u8 pattern[] = { 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF };
+	static const u8 mask[] = { 0x3F };
+	static const u8 pattern[] = { 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF };
 
 	hw_set_wol_frame(hw, 2, 1, mask, MAC_ADDR_LEN, pattern);
 }
@@ -3669,7 +3669,7 @@ static void hw_add_wol_bcast(struct ksz_hw *hw)
  */
 static void hw_add_wol_mcast(struct ksz_hw *hw)
 {
-	u8 mask[] = { 0x3F };
+	static const u8 mask[] = { 0x3F };
 	u8 pattern[] = { 0x33, 0x33, 0xFF, 0x00, 0x00, 0x00 };
 
 	memcpy(&pattern[3], &hw->override_addr[3], 3);
@@ -3687,7 +3687,7 @@ static void hw_add_wol_mcast(struct ksz_hw *hw)
  */
 static void hw_add_wol_ucast(struct ksz_hw *hw)
 {
-	u8 mask[] = { 0x3F };
+	static const u8 mask[] = { 0x3F };
 
 	hw_set_wol_frame(hw, 0, 1, mask, MAC_ADDR_LEN, hw->override_addr);
 }
@@ -3700,7 +3700,7 @@ static void hw_add_wol_ucast(struct ksz_hw *hw)
  *
  * This routine is used to enable Wake-on-LAN depending on driver settings.
  */
-static void hw_enable_wol(struct ksz_hw *hw, u32 wol_enable, u8 *net_addr)
+static void hw_enable_wol(struct ksz_hw *hw, u32 wol_enable, const u8 *net_addr)
 {
 	hw_cfg_wol(hw, KS8841_WOL_MAGIC_ENABLE, (wol_enable & WAKE_MAGIC));
 	hw_cfg_wol(hw, KS8841_WOL_FRAME0_ENABLE, (wol_enable & WAKE_UCAST));
@@ -6208,7 +6208,7 @@ static int netdev_set_wol(struct net_device *dev,
 	struct dev_info *hw_priv = priv->adapter;
 
 	/* Need to find a way to retrieve the device IP address. */
-	u8 net_addr[] = { 192, 168, 1, 1 };
+	static const u8 net_addr[] = { 192, 168, 1, 1 };
 
 	if (wol->wolopts & ~hw_priv->wol_support)
 		return -EINVAL;
@@ -7241,7 +7241,7 @@ static int pcidev_suspend(struct pci_dev *pdev, pm_message_t state)
 	struct ksz_hw *hw = &hw_priv->hw;
 
 	/* Need to find a way to retrieve the device IP address. */
-	u8 net_addr[] = { 192, 168, 1, 1 };
+	static const u8 net_addr[] = { 192, 168, 1, 1 };
 
 	for (i = 0; i < hw->dev_count; i++) {
 		if (info->netdev[i]) {
-- 
1.7.3.2.245.g03276.dirty

