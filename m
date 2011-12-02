From: Kumar Gala <galak@kernel.crashing.org>
Subject: [PATCH] e1000e: Fix bug for e1000e interrupt default
	mode select.
Date: Fri,  2 Dec 2011 01:11:46 -0600
Message-ID: <1322809906-6428-1-git-send-email-galak@kernel.crashing.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	jesse.brandeburg@intel.com, Prabhakar <prabhakar@freescale.com>
To: jeffrey.t.kirsher@intel.com
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

From: Prabhakar <prabhakar@freescale.com>

If the kernel config does not have MSI enabled (CONFIG_PCI_MSI) the driver
should not default to MSI interrupt mode but legacy interrupt mode.

Signed-off-by: Jin Qing <b24347@freescale.com>
Signed-off-by: Prabhakar <prabhakar@freescale.com>
Signed-off-by: Kumar Gala <galak@kernel.crashing.org>
---
 drivers/net/ethernet/intel/e1000e/param.c |    5 +++++
 1 files changed, 5 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/intel/e1000e/param.c b/drivers/net/ethernet/intel/e1000e/param.c
index 20e93b0..18c35c6 100644
--- a/drivers/net/ethernet/intel/e1000e/param.c
+++ b/drivers/net/ethernet/intel/e1000e/param.c
@@ -388,8 +388,13 @@ void __devinit e1000e_check_options(struct e1000_adapter *adapter)
 		static struct e1000_option opt = {
 			.type = range_option,
 			.name = "Interrupt Mode",
+#ifdef CONFIG_PCI_MSI
 			.err  = "defaulting to 2 (MSI-X)",
 			.def  = E1000E_INT_MODE_MSIX,
+#else
+			.err  = "defaulting to 0 (Legacy)",
+			.def  = E1000E_INT_MODE_LEGACY,
+#endif
 			.arg  = { .r = { .min = MIN_INTMODE,
 					 .max = MAX_INTMODE } }
 		};
-- 
1.7.3.4


------------------------------------------------------------------------------
All the data continuously generated in your IT infrastructure 
contains a definitive record of customers, application performance, 
security threats, fraudulent activity, and more. Splunk takes this 
data and makes sense of it. IT sense. And common sense.
http://p.sf.net/sfu/splunk-novd2d
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired
