From: Baoyou Xie <baoyou.xie@linaro.org>
Subject: [PATCH] ixgbe: mark symbols static where possible
Date: Sun, 18 Sep 2016 16:47:34 +0800
Message-ID: <1474188454-8872-1-git-send-email-baoyou.xie@linaro.org>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        arnd@arndb.de, baoyou.xie@linaro.org, xie.baoyou@zte.com.cn
To: jeffrey.t.kirsher@intel.com, intel-wired-lan@lists.osuosl.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

We get 2 warnings when building kernel with W=1:
drivers/net/ethernet/intel/ixgbe/ixgbe_x550.c:2128:5: warning: no previous prototype for 'ixgbe_led_on_t_x550em' [-Wmissing-prototypes]
drivers/net/ethernet/intel/ixgbe/ixgbe_x550.c:2150:5: warning: no previous prototype for 'ixgbe_led_off_t_x550em' [-Wmissing-prototypes]

In fact, these functions are only used in the file in which they are
declared and don't need a declaration, but can be made static.
so this patch marks these functions with 'static'.

Signed-off-by: Baoyou Xie <baoyou.xie@linaro.org>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_x550.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_x550.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_x550.c
index e092a89..dec8b11 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_x550.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_x550.c
@@ -2125,7 +2125,7 @@ static s32 ixgbe_reset_phy_t_X550em(struct ixgbe_hw *hw)
  *  @hw: pointer to hardware structure
  *  @led_idx: led number to turn on
  **/
-s32 ixgbe_led_on_t_x550em(struct ixgbe_hw *hw, u32 led_idx)
+static s32 ixgbe_led_on_t_x550em(struct ixgbe_hw *hw, u32 led_idx)
 {
 	u16 phy_data;
 
@@ -2147,7 +2147,7 @@ s32 ixgbe_led_on_t_x550em(struct ixgbe_hw *hw, u32 led_idx)
  *  @hw: pointer to hardware structure
  *  @led_idx: led number to turn off
  **/
-s32 ixgbe_led_off_t_x550em(struct ixgbe_hw *hw, u32 led_idx)
+static s32 ixgbe_led_off_t_x550em(struct ixgbe_hw *hw, u32 led_idx)
 {
 	u16 phy_data;
 
-- 
2.7.4
