From: Joe Perches <joe@perches.com>
Subject: [PATCH 15/62] e1000: Use static const
Date: Sat, 20 Nov 2010 18:38:16 -0800
Message-ID: <4aca5fa3f038345bdea4975476693cc3c73e8373.1290305776.git.joe@perches.com>
References: <cover.1290305773.git.joe@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Bruce Allan <bruce.w.allan@intel.com>,
	Carolyn Wyborny <carolyn.wyborny@intel.com>,
	Don Ski
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <cover.1290305773.git.joe@perches.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

Using static const generally increases object text and decreases data size.
It also generally decreases overall object size.

   text	   data	    bss	    dec	    hex	filename
  74538	   4296	  19168	  98002	  17ed2	drivers/net/e1000/e1000_hw.o.old
  74501	   4296	  19168	  97965	  17ead	drivers/net/e1000/e1000_hw.o.new

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/e1000/e1000_hw.c |    8 ++++----
 1 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/net/e1000/e1000_hw.c b/drivers/net/e1000/e1000_hw.c
index c7e242b6..c866ef0 100644
--- a/drivers/net/e1000/e1000_hw.c
+++ b/drivers/net/e1000/e1000_hw.c
@@ -4892,8 +4892,8 @@ static s32 e1000_get_cable_length(struct e1000_hw *hw, u16 *min_length,
 	} else if (hw->phy_type == e1000_phy_igp) {	/* For IGP PHY */
 		u16 cur_agc_value;
 		u16 min_agc_value = IGP01E1000_AGC_LENGTH_TABLE_SIZE;
-		u16 agc_reg_array[IGP01E1000_PHY_CHANNEL_NUM] =
-		    { IGP01E1000_PHY_AGC_A,
+		static const u16 agc_reg_array[IGP01E1000_PHY_CHANNEL_NUM] = {
+			IGP01E1000_PHY_AGC_A,
 			IGP01E1000_PHY_AGC_B,
 			IGP01E1000_PHY_AGC_C,
 			IGP01E1000_PHY_AGC_D
@@ -5071,8 +5071,8 @@ static s32 e1000_config_dsp_after_link_change(struct e1000_hw *hw, bool link_up)
 {
 	s32 ret_val;
 	u16 phy_data, phy_saved_data, speed, duplex, i;
-	u16 dsp_reg_array[IGP01E1000_PHY_CHANNEL_NUM] =
-	    { IGP01E1000_PHY_AGC_PARAM_A,
+	static const u16 dsp_reg_array[IGP01E1000_PHY_CHANNEL_NUM] = {
+		IGP01E1000_PHY_AGC_PARAM_A,
 		IGP01E1000_PHY_AGC_PARAM_B,
 		IGP01E1000_PHY_AGC_PARAM_C,
 		IGP01E1000_PHY_AGC_PARAM_D
-- 
1.7.3.2.245.g03276.dirty


------------------------------------------------------------------------------
Beautiful is writing same markup. Internet Explorer 9 supports
standards for HTML5, CSS3, SVG 1.1,  ECMAScript5, and DOM L2 & L3.
Spend less time writing and  rewriting code and more time creating great
experiences on the web. Be a part of the beta today
http://p.sf.net/sfu/msIE9-sfdev2dev
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired
