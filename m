From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 06/14] i40e: reduce lrxqthresh from 2 to 1
Date: Mon,  9 Oct 2017 15:38:33 -0700
Message-ID: <20171009223841.2557-7-jeffrey.t.kirsher@intel.com>
References: <20171009223841.2557-1-jeffrey.t.kirsher@intel.com>
Cc: Jacob Keller <jacob.e.keller@intel.com>, netdev@vger.kernel.org,
        nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:36097 "EHLO mga03.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1755501AbdJIWjG (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 9 Oct 2017 18:39:06 -0400
In-Reply-To: <20171009223841.2557-1-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jacob Keller <jacob.e.keller@intel.com>

The lrxq thresh value tells hardware to immediately interrupt when there
are fewer than N*64 packets left in the ring.

Counter intuitively, empirical testing has shown that decreasing this
value from 2 to 1, and thus changing from an immediate interrupt at
fewer than 128 descriptors down to 64 descriptors causes a small
increase in the maximum total packets per second we can receive. This
increase occurs even when we're polling with interrupts masked, as the
hardware must still handle interrupts internally even if we've disabled
them in software.

Also reduce the value for any VFs we allocate.

Signed-off-by: Jacob Keller <jacob.e.keller@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_main.c        | 2 +-
 drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c | 2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index 00a83afb02e9..74875ddaeb33 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -3030,7 +3030,7 @@ static int i40e_configure_rx_ring(struct i40e_ring *ring)
 	if (hw->revision_id == 0)
 		rx_ctx.lrxqthresh = 0;
 	else
-		rx_ctx.lrxqthresh = 2;
+		rx_ctx.lrxqthresh = 1;
 	rx_ctx.crcstrip = 1;
 	rx_ctx.l2tsel = 1;
 	/* this controls whether VLAN is stripped from inner headers */
diff --git a/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c b/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
index 10298956a81b..83727906a386 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
@@ -639,7 +639,7 @@ static int i40e_config_vsi_rx_queue(struct i40e_vf *vf, u16 vsi_id,
 	rx_ctx.dsize = 1;
 
 	/* default values */
-	rx_ctx.lrxqthresh = 2;
+	rx_ctx.lrxqthresh = 1;
 	rx_ctx.crcstrip = 1;
 	rx_ctx.prefena = 1;
 	rx_ctx.l2tsel = 1;
-- 
2.14.2
