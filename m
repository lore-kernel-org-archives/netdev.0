From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [PATCH] ixgbe: fix vlan filtering
Date: Thu, 21 Aug 2008 18:01:28 -0700
Message-ID: <20080822010128.5002.2293.stgit@jtkirshe-mobile.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	akpm@linux-foundation.org,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rv-out-0506.google.com ([209.85.198.234]:39403 "EHLO
	rv-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755074AbYHVBB3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Aug 2008 21:01:29 -0400
Received: by rv-out-0506.google.com with SMTP id k40so205540rvb.1
        for <netdev@vger.kernel.org>; Thu, 21 Aug 2008 18:01:28 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

there are not vlan filter settings in the fctrl register.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/ixgbe/ixgbe_main.c |    8 +++++---
 1 files changed, 5 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
index 34bca16..53f41b6 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -1636,16 +1636,17 @@ static void ixgbe_set_multi(struct net_device *netdev)
 	struct ixgbe_hw *hw = &adapter->hw;
 	struct dev_mc_list *mc_ptr;
 	u8 *mta_list;
-	u32 fctrl;
+	u32 fctrl, vlnctrl;
 	int i;
 
 	/* Check for Promiscuous and All Multicast modes */
 
 	fctrl = IXGBE_READ_REG(hw, IXGBE_FCTRL);
+	vlnctrl = IXGBE_READ_REG(hw, IXGBE_VLNCTRL);
 
 	if (netdev->flags & IFF_PROMISC) {
 		fctrl |= (IXGBE_FCTRL_UPE | IXGBE_FCTRL_MPE);
-		fctrl &= ~IXGBE_VLNCTRL_VFE;
+		vlnctrl &= ~IXGBE_VLNCTRL_VFE;
 	} else {
 		if (netdev->flags & IFF_ALLMULTI) {
 			fctrl |= IXGBE_FCTRL_MPE;
@@ -1653,10 +1654,11 @@ static void ixgbe_set_multi(struct net_device *netdev)
 		} else {
 			fctrl &= ~(IXGBE_FCTRL_UPE | IXGBE_FCTRL_MPE);
 		}
-		fctrl |= IXGBE_VLNCTRL_VFE;
+		vlnctrl |= IXGBE_VLNCTRL_VFE;
 	}
 
 	IXGBE_WRITE_REG(hw, IXGBE_FCTRL, fctrl);
+	IXGBE_WRITE_REG(hw, IXGBE_VLNCTRL, vlnctrl);
 
 	if (netdev->mc_count) {
 		mta_list = kcalloc(netdev->mc_count, ETH_ALEN, GFP_ATOMIC);

