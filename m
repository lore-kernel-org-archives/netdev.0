From: Jean Sacren <sakiwit@gmail.com>
Subject: [PATCH net] i40e: fix passing wrong error code to
	i40e_open()
Date: Wed, 30 Apr 2014 21:55:13 -0600
Message-ID: <1398916513-1573-1-git-send-email-sakiwit@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	Elizabeth Kappler <elizabeth.m.kappler@intel.com>
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
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

The commit 6c167f582ea9 ("i40e: Refactor and cleanup i40e_open(),
adding i40e_vsi_open()") introduced a new function i40e_vsi_open()
with the regression by a typo. Due to the commit, the wrong error
code would be passed to i40e_open(). Fix this error in
i40e_vsi_open() by turning the macro into a negative value so that
i40e_open() could return the pertinent error code correctly.

Fixes: 6c167f582ea9 ("i40e: Refactor and cleanup i40e_open(), adding i40e_vsi_open()")
Signed-off-by: Jean Sacren <sakiwit@gmail.com>
Cc: Elizabeth Kappler <elizabeth.m.kappler@intel.com>
---
3.14 appears to be affected. Petition for -stable.

 drivers/net/ethernet/intel/i40e/i40e_main.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index cf0761f08911..71dfd79f391a 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -4310,7 +4310,7 @@ int i40e_vsi_open(struct i40e_vsi *vsi)
 		goto err_setup_rx;
 
 	if (!vsi->netdev) {
-		err = EINVAL;
+		err = -EINVAL;
 		goto err_setup_rx;
 	}
 	snprintf(int_name, sizeof(int_name) - 1, "%s-%s",

------------------------------------------------------------------------------
"Accelerate Dev Cycles with Automated Cross-Browser Testing - For FREE
Instantly run your Selenium tests across 300+ browser/OS combos.  Get 
unparalleled scalability from the best Selenium testing platform available.
Simple to use. Nothing to install. Get started now for free."
http://p.sf.net/sfu/SauceLabs
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired
