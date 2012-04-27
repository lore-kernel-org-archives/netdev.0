From: roy.qing.li@gmail.com
Subject: [PATCH net-next 1/2] drivers/net/oki-semi: Remove the definition of PCH_GBE_ETH_ALEN
Date: Fri, 27 Apr 2012 15:01:12 +0800
Message-ID: <1335510073-14018-1-git-send-email-roy.qing.li@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pz0-f51.google.com ([209.85.210.51]:65441 "EHLO
	mail-pz0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755508Ab2D0HBU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Apr 2012 03:01:20 -0400
Received: by dadz8 with SMTP id z8so605612dad.10
        for <netdev@vger.kernel.org>; Fri, 27 Apr 2012 00:01:20 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: RongQing.Li <roy.qing.li@gmail.com>

PCH_GBE_ETH_ALEN is equal to ETH_ALEN, so we can replace it with
ETH_ALEN.

If they are not equal, it must be a bug, since this is ethernet,
and the address has been already stored to mc_addr_list as ETH_ALEN
bytes when call pch_gbe_mac_mc_addr_list_update.

Signed-off-by: RongQing.Li <roy.qing.li@gmail.com>
---
 .../net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c   |    3 +--
 1 files changed, 1 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c b/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c
index 89c6bcf..835e3bb 100644
--- a/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c
+++ b/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c
@@ -79,7 +79,6 @@ const char pch_driver_version[] = DRV_VERSION;
 #define	PCH_GBE_PAUSE_PKT4_VALUE    0x01000888
 #define	PCH_GBE_PAUSE_PKT5_VALUE    0x0000FFFF
 
-#define PCH_GBE_ETH_ALEN            6
 
 /* This defines the bits that are set in the Interrupt Mask
  * Set/Read Register.  Each bit is documented below:
@@ -519,7 +518,7 @@ static void pch_gbe_mac_mc_addr_list_update(struct pch_gbe_hw *hw,
 		if (mc_addr_count) {
 			pch_gbe_mac_mar_set(hw, mc_addr_list, i);
 			mc_addr_count--;
-			mc_addr_list += PCH_GBE_ETH_ALEN;
+			mc_addr_list += ETH_ALEN;
 		} else {
 			/* Clear MAC address mask */
 			adrmask = ioread32(&hw->reg->ADDR_MASK);
-- 
1.7.1
