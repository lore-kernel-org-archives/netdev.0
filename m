From: Joe Perches <joe@perches.com>
Subject: [PATCH 16/62] e1000: Use static const
Date: Sat, 20 Nov 2010 18:38:17 -0800
Message-ID: <4aeb81ea2fe3e78609cb557286aa530715195e40.1290305776.git.joe@perches.com>
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
   9083	   1772	    936	  11791	   2e0f	drivers/net/e1000/e1000_param.o.new
   9147	   1772	    936	  11855	   2e4f	drivers/net/e1000/e1000_param.o.old

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/e1000/e1000_param.c |   13 +++++++------
 1 files changed, 7 insertions(+), 6 deletions(-)

diff --git a/drivers/net/e1000/e1000_param.c b/drivers/net/e1000/e1000_param.c
index 10d8d98..6ba2aee 100644
--- a/drivers/net/e1000/e1000_param.c
+++ b/drivers/net/e1000/e1000_param.c
@@ -352,12 +352,13 @@ void __devinit e1000_check_options(struct e1000_adapter *adapter)
 	}
 	{ /* Flow Control */
 
-		struct e1000_opt_list fc_list[] =
-			{{ E1000_FC_NONE,    "Flow Control Disabled" },
-			 { E1000_FC_RX_PAUSE,"Flow Control Receive Only" },
-			 { E1000_FC_TX_PAUSE,"Flow Control Transmit Only" },
-			 { E1000_FC_FULL,    "Flow Control Enabled" },
-			 { E1000_FC_DEFAULT, "Flow Control Hardware Default" }};
+		static const struct e1000_opt_list fc_list[] = {
+			{ E1000_FC_NONE,     "Flow Control Disabled" },
+			{ E1000_FC_RX_PAUSE, "Flow Control Receive Only" },
+			{ E1000_FC_TX_PAUSE, "Flow Control Transmit Only" },
+			{ E1000_FC_FULL,     "Flow Control Enabled" },
+			{ E1000_FC_DEFAULT,  "Flow Control Hardware Default" }
+		};
 
 		opt = (struct e1000_option) {
 			.type = list_option,
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
