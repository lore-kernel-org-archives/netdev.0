From: Benjamin Poirier <bpoirier@suse.com>
Subject: [PATCH 1/2] e1000e: remove unreachable code
Date: Thu, 22 Oct 2015 17:32:27 -0700
Message-ID: <1445560348-29872-2-git-send-email-bpoirier@suse.com>
References: <1445560348-29872-1-git-send-email-bpoirier@suse.com>
Cc: Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Shannon Nelson <shannon.nelson@intel.com>,
	Carolyn Wyborny <carolyn.wyborny@intel.com>,
	Don Skidmore <donald.c.skidmore@intel.com>,
	Matthew Vick <matthew.vick@intel.com>,
	John Ronciak <john.ronciak@intel.com>,
	Mitch Williams <mitch.a.williams@intel.com>,
	intel-wired-lan@lists.osuosl.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1445560348-29872-1-git-send-email-bpoirier@suse.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

msi-x interrupts are not shared so there's no need to check if the
interrupt was really from this adapter.

Signed-off-by: Benjamin Poirier <bpoirier@suse.com>
---
 drivers/net/ethernet/intel/e1000e/netdev.c | 6 ------
 1 file changed, 6 deletions(-)

diff --git a/drivers/net/ethernet/intel/e1000e/netdev.c b/drivers/net/ethernet/intel/e1000e/netdev.c
index 0a854a4..a228167 100644
--- a/drivers/net/ethernet/intel/e1000e/netdev.c
+++ b/drivers/net/ethernet/intel/e1000e/netdev.c
@@ -1907,12 +1907,6 @@ static irqreturn_t e1000_msix_other(int __always_unused irq, void *data)
 	struct e1000_hw *hw = &adapter->hw;
 	u32 icr = er32(ICR);
 
-	if (!(icr & E1000_ICR_INT_ASSERTED)) {
-		if (!test_bit(__E1000_DOWN, &adapter->state))
-			ew32(IMS, E1000_IMS_OTHER);
-		return IRQ_NONE;
-	}
-
 	if (icr & adapter->eiac_mask)
 		ew32(ICS, (icr & adapter->eiac_mask));
 
-- 
2.5.0
