From: Guenter Roeck <linux@roeck-us.net>
Subject: [PATCH 4/5] igb: Start temperature sensor attribute
	index with 1
Date: Fri, 22 Nov 2013 22:08:00 -0800
Message-ID: <1385186881-7931-5-git-send-email-linux@roeck-us.net>
References: <1385186881-7931-1-git-send-email-linux@roeck-us.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Nithin Nayak Sujir <nsujir@broadcom.com>, e1000-devel@lists.sourceforge.net,
	Bruce Allan <bruce.w.allan@intel.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	lm-sensors@lm-sensors.org, Michael Chan <mchan@broadcom.com>,
	"David S. Miller" <davem@davemloft.net>, Guenter Roeck <linux@roeck-us.net>
To: netdev@vger.kernel.org
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <1385186881-7931-1-git-send-email-linux@roeck-us.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

Per hwmon ABI, temperature sensor attribute index starts with 1, not 0.

Signed-off-by: Guenter Roeck <linux@roeck-us.net>
---
 drivers/net/ethernet/intel/igb/igb_hwmon.c |    8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/intel/igb/igb_hwmon.c b/drivers/net/ethernet/intel/igb/igb_hwmon.c
index 2e7ef2d..e0af5bc 100644
--- a/drivers/net/ethernet/intel/igb/igb_hwmon.c
+++ b/drivers/net/ethernet/intel/igb/igb_hwmon.c
@@ -124,22 +124,22 @@ static int igb_add_hwmon_attr(struct igb_adapter *adapter,
 	case IGB_HWMON_TYPE_LOC:
 		igb_attr->dev_attr.show = igb_hwmon_show_location;
 		snprintf(igb_attr->name, sizeof(igb_attr->name),
-			 "temp%u_label", offset);
+			 "temp%u_label", offset + 1);
 		break;
 	case IGB_HWMON_TYPE_TEMP:
 		igb_attr->dev_attr.show = igb_hwmon_show_temp;
 		snprintf(igb_attr->name, sizeof(igb_attr->name),
-			 "temp%u_input", offset);
+			 "temp%u_input", offset + 1);
 		break;
 	case IGB_HWMON_TYPE_CAUTION:
 		igb_attr->dev_attr.show = igb_hwmon_show_cautionthresh;
 		snprintf(igb_attr->name, sizeof(igb_attr->name),
-			 "temp%u_max", offset);
+			 "temp%u_max", offset + 1);
 		break;
 	case IGB_HWMON_TYPE_MAX:
 		igb_attr->dev_attr.show = igb_hwmon_show_maxopthresh;
 		snprintf(igb_attr->name, sizeof(igb_attr->name),
-			 "temp%u_crit", offset);
+			 "temp%u_crit", offset + 1);
 		break;
 	default:
 		rc = -EPERM;
-- 
1.7.9.7


------------------------------------------------------------------------------
Shape the Mobile Experience: Free Subscription
Software experts and developers: Be at the forefront of tech innovation.
Intel(R) Software Adrenaline delivers strategic insight and game-changing 
conversations that shape the rapidly evolving mobile landscape. Sign up now. 
http://pubads.g.doubleclick.net/gampad/clk?id=63431311&iu=/4140/ostg.clktrk
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired
