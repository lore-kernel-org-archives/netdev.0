From: Christophe JAILLET <christophe.jaillet@wanadoo.fr>
Subject: [PATCH] igb: check memory allocation failure
Date: Sun, 27 Aug 2017 08:39:51 +0200
Message-ID: <20170827063951.5975-1-christophe.jaillet@wanadoo.fr>
Cc: intel-wired-lan@lists.osuosl.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, kernel-janitors@vger.kernel.org,
        Christophe JAILLET <christophe.jaillet@wanadoo.fr>
To: jeffrey.t.kirsher@intel.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Check memory allocation failures and return -ENOMEM in such cases, as
already done for other memory allocations in this function.

This avoids NULL pointers dereference.

Signed-off-by: Christophe JAILLET <christophe.jaillet@wanadoo.fr>
---
 drivers/net/ethernet/intel/igb/igb_main.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/drivers/net/ethernet/intel/igb/igb_main.c b/drivers/net/ethernet/intel/igb/igb_main.c
index fd4a46b03cc8..837d9b46a390 100644
--- a/drivers/net/ethernet/intel/igb/igb_main.c
+++ b/drivers/net/ethernet/intel/igb/igb_main.c
@@ -3162,6 +3162,8 @@ static int igb_sw_init(struct igb_adapter *adapter)
 	/* Setup and initialize a copy of the hw vlan table array */
 	adapter->shadow_vfta = kcalloc(E1000_VLAN_FILTER_TBL_SIZE, sizeof(u32),
 				       GFP_ATOMIC);
+	if (!adapter->shadow_vfta)
+		return -ENOMEM;
 
 	/* This call may decrease the number of queues */
 	if (igb_init_interrupt_scheme(adapter, true)) {
-- 
2.11.0
