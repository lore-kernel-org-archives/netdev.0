From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-2.6 PATCH] e1000e: LED settings in EEPROM ignored on 82571 and
	82572
Date: Thu, 17 Dec 2009 17:42:15 -0800
Message-ID: <20091218014214.4948.26355.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Bruce Allan <bruce.w.allan@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta05.westchester.pa.mail.comcast.net ([76.96.62.48]:56725
	"EHLO QMTA05.westchester.pa.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755963AbZLRBme (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Dec 2009 20:42:34 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Bruce Allan <bruce.w.allan@intel.com>

Do not override the customizable LED configuration set in the EEPROM.

Signed-off-by: Bruce Allan <bruce.w.allan@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/e1000e/82571.c |    6 ------
 1 files changed, 0 insertions(+), 6 deletions(-)

diff --git a/drivers/net/e1000e/82571.c b/drivers/net/e1000e/82571.c
index c1a42cf..b979464 100644
--- a/drivers/net/e1000e/82571.c
+++ b/drivers/net/e1000e/82571.c
@@ -1290,7 +1290,6 @@ static s32 e1000_setup_link_82571(struct e1000_hw *hw)
 static s32 e1000_setup_copper_link_82571(struct e1000_hw *hw)
 {
 	u32 ctrl;
-	u32 led_ctrl;
 	s32 ret_val;
 
 	ctrl = er32(CTRL);
@@ -1305,11 +1304,6 @@ static s32 e1000_setup_copper_link_82571(struct e1000_hw *hw)
 		break;
 	case e1000_phy_igp_2:
 		ret_val = e1000e_copper_link_setup_igp(hw);
-		/* Setup activity LED */
-		led_ctrl = er32(LEDCTL);
-		led_ctrl &= IGP_ACTIVITY_LED_MASK;
-		led_ctrl |= (IGP_ACTIVITY_LED_ENABLE | IGP_LED3_MODE);
-		ew32(LEDCTL, led_ctrl);
 		break;
 	default:
 		return -E1000_ERR_PHY;

