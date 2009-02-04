From: Alex Chiang <achiang@hp.com>
Subject: [net-next PATCH] e1000e: normalize usage of serdes_has_link
Date: Wed, 4 Feb 2009 15:04:34 -0700
Message-ID: <20090204220434.GD20091@ldl.fc.hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, jeff@garzik.org,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Bruce Allan <bruce.w.allan@intel.com>, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from g1t0027.austin.hp.com ([15.216.28.34]:34842 "EHLO
	g1t0027.austin.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756869AbZBDWEg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Feb 2009 17:04:36 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Cosmetic change to use struct e1000_mac_info.serdes_has_link
consistently as the 'bool' that it's declared as.

No functional change.

Signed-off-by: Alex Chiang <achiang@hp.com>
---

 ethtool.c |    2 +-
 lib.c     |    4 ++--
 2 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/e1000e/ethtool.c b/drivers/net/e1000e/ethtool.c
index e48956d..2557aee 100644
--- a/drivers/net/e1000e/ethtool.c
+++ b/drivers/net/e1000e/ethtool.c
@@ -1589,7 +1589,7 @@ static int e1000_link_test(struct e1000_adapter *adapter, u64 *data)
 	*data = 0;
 	if (hw->phy.media_type == e1000_media_type_internal_serdes) {
 		int i = 0;
-		hw->mac.serdes_has_link = 0;
+		hw->mac.serdes_has_link = false;
 
 		/*
 		 * On some blade server designs, link establishment
diff --git a/drivers/net/e1000e/lib.c b/drivers/net/e1000e/lib.c
index 6674110..ac2f34e 100644
--- a/drivers/net/e1000e/lib.c
+++ b/drivers/net/e1000e/lib.c
@@ -501,7 +501,7 @@ s32 e1000e_check_for_fiber_link(struct e1000_hw *hw)
 		ew32(TXCW, mac->txcw);
 		ew32(CTRL, (ctrl & ~E1000_CTRL_SLU));
 
-		mac->serdes_has_link = 1;
+		mac->serdes_has_link = true;
 	}
 
 	return 0;
@@ -566,7 +566,7 @@ s32 e1000e_check_for_serdes_link(struct e1000_hw *hw)
 		ew32(TXCW, mac->txcw);
 		ew32(CTRL, (ctrl & ~E1000_CTRL_SLU));
 
-		mac->serdes_has_link = 1;
+		mac->serdes_has_link = true;
 	} else if (!(E1000_TXCW_ANE & er32(TXCW))) {
 		/*
 		 * If we force link for non-auto-negotiation switch, check
