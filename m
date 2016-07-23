From: Jarod Wilson <jarod@redhat.com>
Subject: [PATCH net-next 2/2] e1000e: fix PTP on e1000_pch_lpt variants
Date: Sat, 23 Jul 2016 12:44:34 -0400
Message-ID: <1469292274-59237-3-git-send-email-jarod@redhat.com>
References: <1468959902-25071-1-git-send-email-jarod@redhat.com>
 <1469292274-59237-1-git-send-email-jarod@redhat.com>
Cc: Jarod Wilson <jarod@redhat.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	intel-wired-lan@lists.osuosl.org, netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1469292274-59237-1-git-send-email-jarod@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

I've got reports that the Intel I-218V NIC in Intel NUC5i5RYH systems used
as a PTP slave experiences random ~10 hour clock jumps, which are resolved
if the same workaround for the 82574 and 82583 is employed.

Reported-by: Rupesh Patel <rupatel@redhat.com>
CC: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
CC: intel-wired-lan@lists.osuosl.org
CC: netdev@vger.kernel.org
Signed-off-by: Jarod Wilson <jarod@redhat.com>
---
 drivers/net/ethernet/intel/e1000e/netdev.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/ethernet/intel/e1000e/netdev.c b/drivers/net/ethernet/intel/e1000e/netdev.c
index 955b294..206bd6a 100644
--- a/drivers/net/ethernet/intel/e1000e/netdev.c
+++ b/drivers/net/ethernet/intel/e1000e/netdev.c
@@ -4374,6 +4374,7 @@ static cycle_t e1000e_cyclecounter_read(const struct cyclecounter *cc)
 	switch (hw->mac.type) {
 	case e1000_82574:
 	case e1000_82583:
+	case e1000_pch_lpt:
 		systim = e1000e_sanitize_systim(hw, systim);
 		break;
 	default:
-- 
1.8.3.1
