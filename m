From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 PATCH 03/13] igb: change configure_pcs_link to void
	since it always returns 0
Date: Thu, 23 Jul 2009 21:07:58 -0700
Message-ID: <20090724040757.30709.25652.stgit@localhost.localdomain>
References: <20090724040700.30709.31473.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta04.emeryville.ca.mail.comcast.net ([76.96.30.40]:43606 "EHLO
	QMTA04.emeryville.ca.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751393AbZGXEIP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Jul 2009 00:08:15 -0400
In-Reply-To: <20090724040700.30709.31473.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

Since igb_configure_pcs_link always returns 0 there isn't really much point
to checking for the result so it is best just to change this to a void so
we can properly ignore the return result.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/igb/e1000_82575.c |   13 ++++---------
 1 files changed, 4 insertions(+), 9 deletions(-)

diff --git a/drivers/net/igb/e1000_82575.c b/drivers/net/igb/e1000_82575.c
index fa4a762..f946bed 100644
--- a/drivers/net/igb/e1000_82575.c
+++ b/drivers/net/igb/e1000_82575.c
@@ -53,7 +53,7 @@ static s32  igb_setup_fiber_serdes_link_82575(struct e1000_hw *);
 static s32  igb_write_phy_reg_sgmii_82575(struct e1000_hw *, u32, u16);
 static void igb_clear_hw_cntrs_82575(struct e1000_hw *);
 static s32  igb_acquire_swfw_sync_82575(struct e1000_hw *, u16);
-static s32  igb_configure_pcs_link_82575(struct e1000_hw *);
+static void igb_configure_pcs_link_82575(struct e1000_hw *);
 static s32  igb_get_pcs_speed_and_duplex_82575(struct e1000_hw *, u16 *,
 						 u16 *);
 static s32  igb_get_phy_id_82575(struct e1000_hw *);
@@ -1050,9 +1050,7 @@ static s32 igb_setup_copper_link_82575(struct e1000_hw *hw)
 		}
 	}
 
-	ret_val = igb_configure_pcs_link_82575(hw);
-	if (ret_val)
-		goto out;
+	igb_configure_pcs_link_82575(hw);
 
 	/*
 	 * Check link status. Wait up to 100 microseconds for link to become
@@ -1161,14 +1159,14 @@ static s32 igb_setup_fiber_serdes_link_82575(struct e1000_hw *hw)
  *  independent interface (sgmii) is being used.  Configures the link
  *  for auto-negotiation or forces speed/duplex.
  **/
-static s32 igb_configure_pcs_link_82575(struct e1000_hw *hw)
+static void igb_configure_pcs_link_82575(struct e1000_hw *hw)
 {
 	struct e1000_mac_info *mac = &hw->mac;
 	u32 reg = 0;
 
 	if (hw->phy.media_type != e1000_media_type_copper ||
 	    !(igb_sgmii_active_82575(hw)))
-		goto out;
+		return;
 
 	/* For SGMII, we need to issue a PCS autoneg restart */
 	reg = rd32(E1000_PCS_LCTL);
@@ -1211,9 +1209,6 @@ static s32 igb_configure_pcs_link_82575(struct e1000_hw *hw)
 		       reg);
 	}
 	wr32(E1000_PCS_LCTL, reg);
-
-out:
-	return 0;
 }
 
 /**

