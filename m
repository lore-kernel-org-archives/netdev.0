From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 11/15] i40e: fix led blink toggle to enable steady state
Date: Mon,  9 Feb 2015 02:43:57 -0800
Message-ID: <1423478641-3138-12-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1423478641-3138-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Matt Jared <matthew.a.jared@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:38701 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760602AbbBIKoG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 9 Feb 2015 05:44:06 -0500
In-Reply-To: <1423478641-3138-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Matt Jared <matthew.a.jared@intel.com>

Make sure to clear the GPIO blink field, instead of OR'ing against zero
if the field is already '1'.

Change-ID: Ie52a52abd48f6f52b20778a6b8b0c542dfc9245c
Signed-off-by: Matt Jared <matthew.a.jared@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_common.c | 6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_common.c b/drivers/net/ethernet/intel/i40e/i40e_common.c
index 5669bfa..11a9ffe 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_common.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_common.c
@@ -1142,8 +1142,10 @@ void i40e_led_set(struct i40e_hw *hw, u32 mode, bool blink)
 		if (mode == I40E_LINK_ACTIVITY)
 			blink = false;
 
-		gpio_val |= (blink ? 1 : 0) <<
-			    I40E_GLGEN_GPIO_CTL_LED_BLINK_SHIFT;
+		if (blink)
+			gpio_val |= (1 << I40E_GLGEN_GPIO_CTL_LED_BLINK_SHIFT);
+		else
+			gpio_val &= ~(1 << I40E_GLGEN_GPIO_CTL_LED_BLINK_SHIFT);
 
 		wr32(hw, I40E_GLGEN_GPIO_CTL(i), gpio_val);
 		break;
-- 
1.9.3
