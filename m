From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 PATCH 04/13] igb: do not overwrite EEPROM LED settings
Date: Thu, 23 Jul 2009 21:08:16 -0700
Message-ID: <20090724040816.30709.39700.stgit@localhost.localdomain>
References: <20090724040700.30709.31473.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta09.emeryville.ca.mail.comcast.net ([76.96.30.96]:46608 "EHLO
	QMTA09.emeryville.ca.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751364AbZGXEId (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Jul 2009 00:08:33 -0400
In-Reply-To: <20090724040700.30709.31473.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

The igb driver was overwritting the LED settings that were configured via
EEPROM.  This is not correct behavior as the LED settings are meant to be
configured by EEPROM and not changed.  This change removes the code that
was setting the LED behavior on the interface.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/igb/e1000_82575.c |    7 +------
 1 files changed, 1 insertions(+), 6 deletions(-)

diff --git a/drivers/net/igb/e1000_82575.c b/drivers/net/igb/e1000_82575.c
index f946bed..606c25c 100644
--- a/drivers/net/igb/e1000_82575.c
+++ b/drivers/net/igb/e1000_82575.c
@@ -1000,7 +1000,7 @@ static s32 igb_init_hw_82575(struct e1000_hw *hw)
  **/
 static s32 igb_setup_copper_link_82575(struct e1000_hw *hw)
 {
-	u32 ctrl, led_ctrl;
+	u32 ctrl;
 	s32  ret_val;
 	bool link;
 
@@ -1015,11 +1015,6 @@ static s32 igb_setup_copper_link_82575(struct e1000_hw *hw)
 		break;
 	case e1000_phy_igp_3:
 		ret_val = igb_copper_link_setup_igp(hw);
-		/* Setup activity LED */
-		led_ctrl = rd32(E1000_LEDCTL);
-		led_ctrl &= IGP_ACTIVITY_LED_MASK;
-		led_ctrl |= (IGP_ACTIVITY_LED_ENABLE | IGP_LED3_MODE);
-		wr32(E1000_LEDCTL, led_ctrl);
 		break;
 	default:
 		ret_val = -E1000_ERR_PHY;

