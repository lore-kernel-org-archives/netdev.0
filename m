From: Joe Perches <joe@perches.com>
Subject: [PATCH net-next] intel: Remove addressof casts to
	same type
Date: Mon, 24 Mar 2014 10:45:59 -0700
Message-ID: <1395683159.13968.60.camel@joe-AO722>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: e1000-devel <e1000-devel@lists.sourceforge.net>,
	netdev <netdev@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, linux.nics@intel.com
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

Using addressof then casting to the original type is pointless,
so remove these unnecessary casts.

Done via coccinelle script:

$ cat typecast.cocci 
@@
type T;
T foo;
@@

-	(T *)&foo
+	&foo

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/ethernet/intel/i40e/i40e_common.c   | 4 ++--
 drivers/net/ethernet/intel/i40evf/i40e_common.c | 3 +--
 2 files changed, 3 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_common.c b/drivers/net/ethernet/intel/i40e/i40e_common.c
index bb948dd..922cdcc 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_common.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_common.c
@@ -1775,9 +1775,9 @@ static void i40e_parse_discover_capabilities(struct i40e_hw *hw, void *buff,
 	cap = (struct i40e_aqc_list_capabilities_element_resp *) buff;
 
 	if (list_type_opc == i40e_aqc_opc_list_dev_capabilities)
-		p = (struct i40e_hw_capabilities *)&hw->dev_caps;
+		p = &hw->dev_caps;
 	else if (list_type_opc == i40e_aqc_opc_list_func_capabilities)
-		p = (struct i40e_hw_capabilities *)&hw->func_caps;
+		p = &hw->func_caps;
 	else
 		return;
 
diff --git a/drivers/net/ethernet/intel/i40evf/i40e_common.c b/drivers/net/ethernet/intel/i40evf/i40e_common.c
index c688a0f..ae08437 100644
--- a/drivers/net/ethernet/intel/i40evf/i40e_common.c
+++ b/drivers/net/ethernet/intel/i40evf/i40e_common.c
@@ -565,8 +565,7 @@ i40e_status i40e_aq_send_msg_to_pf(struct i40e_hw *hw,
 		details.async = true;
 		cmd_details = &details;
 	}
-	status = i40evf_asq_send_command(hw, (struct i40e_aq_desc *)&desc, msg,
-				       msglen, cmd_details);
+	status = i40evf_asq_send_command(hw, &desc, msg, msglen, cmd_details);
 	return status;
 }
 



------------------------------------------------------------------------------
Learn Graph Databases - Download FREE O'Reilly Book
"Graph Databases" is the definitive new guide to graph databases and their
applications. Written by three acclaimed leaders in the field,
this first edition is now available. Download your free book today!
http://p.sf.net/sfu/13534_NeoTech
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired
