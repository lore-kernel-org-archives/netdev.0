From: akpm@osdl.org
Subject: [patch 10/10] e1000: fix media_type <-> phy_type thinko
Date: Tue, 18 Apr 2006 21:04:42 -0700
Message-ID: <200604190405.k3J45Oln008022@shell0.pdx.osdl.net>
Cc: linville@tuxdriver.com, netdev@vger.kernel.org, akpm@osdl.org,
	willy@w.ods.org, jesse.brandeburg@intel.com, john.ronciak@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:1228 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1750771AbWDSEFl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Apr 2006 00:05:41 -0400
To: jeff@garzik.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


From: Willy TARREAU <willy@w.ods.org>

Recent patch cb764326dff0ee51aca0d450e1a292de65661055 introduced a thinko
in e1000_main.c : e1000_media_type_copper is compared to hw.phy_type
instead of hw.media_type.  Original patch proposed by Jesse Brandeburg was
correct, but what has been merged is not.

Acked-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Cc: "Ronciak, John" <john.ronciak@intel.com>
Cc: Jeff Garzik <jeff@garzik.org>
Signed-off-by: Andrew Morton <akpm@osdl.org>
---

 drivers/net/e1000/e1000_main.c |    2 +-
 1 files changed, 1 insertion(+), 1 deletion(-)

diff -puN drivers/net/e1000/e1000_main.c~e1000-fix-media_type-phy_type-thinko drivers/net/e1000/e1000_main.c
--- devel/drivers/net/e1000/e1000_main.c~e1000-fix-media_type-phy_type-thinko	2006-04-17 21:42:32.000000000 -0700
+++ devel-akpm/drivers/net/e1000/e1000_main.c	2006-04-17 21:43:30.000000000 -0700
@@ -4195,7 +4195,7 @@ e1000_mii_ioctl(struct net_device *netde
 			spin_unlock_irqrestore(&adapter->stats_lock, flags);
 			return -EIO;
 		}
-		if (adapter->hw.phy_type == e1000_media_type_copper) {
+		if (adapter->hw.media_type == e1000_media_type_copper) {
 			switch (data->reg_num) {
 			case PHY_CTRL:
 				if (mii_reg & MII_CR_POWER_DOWN)
_
