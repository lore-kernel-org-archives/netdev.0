From: Joe Perches <joe@perches.com>
Subject: [PATCH 17/62] e1000e: Use static const
Date: Sat, 20 Nov 2010 18:38:18 -0800
Message-ID: <09db4d88d103166998a131dca7e3e28b26618576.1290305776.git.joe@perches.com>
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
  30847	   1400	   7088	  39335	   99a7	drivers/net/e1000e/phy.o.new
  30861	   1400	   7088	  39349	   99b5	drivers/net/e1000e/phy.o.old

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/e1000e/phy.c |   11 ++++++-----
 1 files changed, 6 insertions(+), 5 deletions(-)

diff --git a/drivers/net/e1000e/phy.c b/drivers/net/e1000e/phy.c
index b9bff5b..a7ea4e7 100644
--- a/drivers/net/e1000e/phy.c
+++ b/drivers/net/e1000e/phy.c
@@ -1840,11 +1840,12 @@ s32 e1000e_get_cable_length_igp_2(struct e1000_hw *hw)
 	u16 phy_data, i, agc_value = 0;
 	u16 cur_agc_index, max_agc_index = 0;
 	u16 min_agc_index = IGP02E1000_CABLE_LENGTH_TABLE_SIZE - 1;
-	u16 agc_reg_array[IGP02E1000_PHY_CHANNEL_NUM] =
-							 {IGP02E1000_PHY_AGC_A,
-							  IGP02E1000_PHY_AGC_B,
-							  IGP02E1000_PHY_AGC_C,
-							  IGP02E1000_PHY_AGC_D};
+	static const u16 agc_reg_array[IGP02E1000_PHY_CHANNEL_NUM] = {
+		IGP02E1000_PHY_AGC_A,
+		IGP02E1000_PHY_AGC_B,
+		IGP02E1000_PHY_AGC_C,
+		IGP02E1000_PHY_AGC_D
+	};
 
 	/* Read the AGC registers for all channels */
 	for (i = 0; i < IGP02E1000_PHY_CHANNEL_NUM; i++) {
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
