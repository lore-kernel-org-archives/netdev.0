From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: [PATCH-next] intel ethernet: fix s390 build failure
	due to implicit prefetch.h
Date: Fri, 10 Jan 2014 14:28:16 -0500
Message-ID: <1389382096-17122-1-git-send-email-paul.gortmaker@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Sibai Li <sibai.li@intel.com>,
	Paul Gortmaker <paul.gortmaker@windriver.com>, netdev@vger.kernel.org,
	Jesse Brandeburg <jesse.brandeburg@intel.com>
To: <e1000-devel@lists.sourceforge.net>
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

As of commit 7f12ad741a4870b8b6e3aafbcd868d0191770802 ("i40evf: transmit
and receive functionality") the s390 builds (allyesconfig) fail with:

drivers/net/ethernet/intel/i40evf/i40e_txrx.c: In function 'i40e_clean_rx_irq':
drivers/net/ethernet/intel/i40evf/i40e_txrx.c:818:3: error: implicit declaration of function 'prefetch'
make[5]: *** [drivers/net/ethernet/intel/i40evf/i40e_txrx.o] Error 1

due to an implicit assumption that the prototype from linux/prefetch.h
will be present.

Cc: Mitch Williams <mitch.a.williams@intel.com>
Cc: Greg Rose <gregory.v.rose@intel.com>
Cc: Sibai Li <sibai.li@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>

diff --git a/drivers/net/ethernet/intel/i40evf/i40e_txrx.c b/drivers/net/ethernet/intel/i40evf/i40e_txrx.c
index 8f2b3b2..ffdb01d 100644
--- a/drivers/net/ethernet/intel/i40evf/i40e_txrx.c
+++ b/drivers/net/ethernet/intel/i40evf/i40e_txrx.c
@@ -21,6 +21,8 @@
  *
  ******************************************************************************/
 
+#include <linux/prefetch.h>
+
 #include "i40evf.h"
 
 static inline __le64 build_ctob(u32 td_cmd, u32 td_offset, unsigned int size,
-- 
1.8.5.1


------------------------------------------------------------------------------
CenturyLink Cloud: The Leader in Enterprise Cloud Services.
Learn Why More Businesses Are Choosing CenturyLink Cloud For
Critical Workloads, Development Environments & Everything In Between.
Get a Quote or Start a Free Trial Today. 
http://pubads.g.doubleclick.net/gampad/clk?id=119420431&iu=/4140/ostg.clktrk
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired
