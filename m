From: Joe Perches <joe@perches.com>
Subject: [PATCH 28/62] ixgb: Use static const
Date: Sat, 20 Nov 2010 18:38:29 -0800
Message-ID: <aea63062901ce9f2380c2c20439fc51980a3da43.1290305776.git.joe@perches.com>
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
   4115	    416	    448	   4979	   1373	drivers/net/ixgb/ixgb_param.o.old
   3998	    416	    448	   4862	   12fe	drivers/net/ixgb/ixgb_param.o.new

Change struct ixgb_opt_list to const struct and
change char *str to const char *str.

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/ixgb/ixgb_param.c |   21 +++++++++++----------
 1 files changed, 11 insertions(+), 10 deletions(-)

diff --git a/drivers/net/ixgb/ixgb_param.c b/drivers/net/ixgb/ixgb_param.c
index 88a08f0..48765a1 100644
--- a/drivers/net/ixgb/ixgb_param.c
+++ b/drivers/net/ixgb/ixgb_param.c
@@ -191,9 +191,9 @@ struct ixgb_option {
 		} r;
 		struct {	/* list_option info */
 			int nr;
-			struct ixgb_opt_list {
+			const struct ixgb_opt_list {
 				int i;
-				char *str;
+				const char *str;
 			} *p;
 		} l;
 	} arg;
@@ -226,7 +226,7 @@ ixgb_validate_option(unsigned int *value, const struct ixgb_option *opt)
 		break;
 	case list_option: {
 		int i;
-		struct ixgb_opt_list *ent;
+		const struct ixgb_opt_list *ent;
 
 		for (i = 0; i < opt->arg.l.nr; i++) {
 			ent = &opt->arg.l.p[i];
@@ -322,14 +322,15 @@ ixgb_check_options(struct ixgb_adapter *adapter)
 	}
 	{ /* Flow Control */
 
-		struct ixgb_opt_list fc_list[] =
-			{{ ixgb_fc_none,	"Flow Control Disabled" },
-			 { ixgb_fc_rx_pause,"Flow Control Receive Only" },
-			 { ixgb_fc_tx_pause,"Flow Control Transmit Only" },
-			 { ixgb_fc_full,	"Flow Control Enabled" },
-			 { ixgb_fc_default, "Flow Control Hardware Default" }};
+		static const struct ixgb_opt_list fc_list[] = {
+			{ ixgb_fc_none,     "Flow Control Disabled" },
+			{ ixgb_fc_rx_pause, "Flow Control Receive Only" },
+			{ ixgb_fc_tx_pause, "Flow Control Transmit Only" },
+			{ ixgb_fc_full,     "Flow Control Enabled" },
+			{ ixgb_fc_default,  "Flow Control Hardware Default" }
+		};
 
-		const struct ixgb_option opt = {
+		static const struct ixgb_option opt = {
 			.type = list_option,
 			.name = "Flow Control",
 			.err  = "reading default settings from EEPROM",
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
