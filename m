From: Daniel Borkmann <dborkman@redhat.com>
Subject: [PATCH net] net: i40e: fix shifting error in i40e_led_get
Date: Thu, 19 Dec 2013 22:57:17 +0100
Message-ID: <1387490237-27260-1-git-send-email-dborkman@redhat.com>
Cc: netdev@vger.kernel.org, jeffrey.t.kirsher@intel.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:58586 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755052Ab3LSV50 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 19 Dec 2013 16:57:26 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In function i40e_led_get(), we fetch the LED mode from the GPIO
registers and extract it from gpio_val. However, regardless of
the outcome of the fetched value in gpio_val, the calculation
to extract the mode will always be 0, as we do the following:

  (gpio_val & (61440U /* 0xf << 12 */)) >> 17

Instead of I40E_GLGEN_GPIO_CTL_INT_MODE_SHIFT, we need to use
I40E_GLGEN_GPIO_CTL_LED_MODE_SHIFT to fix this.

Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
---
 Seems like this is still unfixed, so sending to netdev.

 drivers/net/ethernet/intel/i40e/i40e_common.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_common.c b/drivers/net/ethernet/intel/i40e/i40e_common.c
index 1e4ea13..a170761 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_common.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_common.c
@@ -365,8 +365,8 @@ u32 i40e_led_get(struct i40e_hw *hw)
 		if (port != hw->port)
 			continue;
 
-		mode = (gpio_val & I40E_GLGEN_GPIO_CTL_LED_MODE_MASK)
-				>> I40E_GLGEN_GPIO_CTL_INT_MODE_SHIFT;
+		mode = (gpio_val & I40E_GLGEN_GPIO_CTL_LED_MODE_MASK) >>
+		       I40E_GLGEN_GPIO_CTL_LED_MODE_SHIFT;
 		break;
 	}
 
-- 
1.8.3.1
