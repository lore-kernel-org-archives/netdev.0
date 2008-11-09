From: Divy Le Ray <divy@chelsio.com>
Subject: [PATCH 1/2 2.6.28] cxgb3 - eeprom read fixes
Date: Sun, 09 Nov 2008 00:55:28 -0800
Message-ID: <20081109085528.3526.2329.stgit@speedy5>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	swise@opengridcomputing.com
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([12.22.49.110]:8288 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753919AbYKIIzd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 9 Nov 2008 03:55:33 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Divy Le Ray <divy@chelsio.com>

Protect against invalid phy entries in the eeprom.
Extend eeprom access timeout.

Signed-off-by: Divy Le Ray <divy@chelsio.com>
---

 drivers/net/cxgb3/t3_hw.c |    8 +++++++-
 1 files changed, 7 insertions(+), 1 deletions(-)

diff --git a/drivers/net/cxgb3/t3_hw.c b/drivers/net/cxgb3/t3_hw.c
index 968f64b..9a0898b 100644
--- a/drivers/net/cxgb3/t3_hw.c
+++ b/drivers/net/cxgb3/t3_hw.c
@@ -572,7 +572,7 @@ struct t3_vpd {
 	u32 pad;		/* for multiple-of-4 sizing and alignment */
 };
 
-#define EEPROM_MAX_POLL   4
+#define EEPROM_MAX_POLL   40
 #define EEPROM_STAT_ADDR  0x4000
 #define VPD_BASE          0xc00
 
@@ -3690,6 +3690,12 @@ int t3_prep_adapter(struct adapter *adapter, const struct adapter_info *ai,
 			;
 
 		pti = &port_types[adapter->params.vpd.port_type[j]];
+		if (!pti->phy_prep) {
+			CH_ALERT(adapter, "Invalid port type index %d\n",
+				 adapter->params.vpd.port_type[j]);
+			return -EINVAL;
+		}
+
 		ret = pti->phy_prep(&p->phy, adapter, ai->phy_base_addr + j,
 				    ai->mdio_ops);
 		if (ret)

