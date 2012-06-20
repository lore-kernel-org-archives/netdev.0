From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 2/9] igb: A fix to VF TX rate limit
Date: Wed, 20 Jun 2012 01:44:56 -0700
Message-ID: <1340181903-16382-3-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1340181903-16382-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Lior Levy <lior.levy@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:60849 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753746Ab2FTIpH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 20 Jun 2012 04:45:07 -0400
In-Reply-To: <1340181903-16382-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Lior Levy <lior.levy@intel.com>

There is a need to configure MMW_SIZE in register RTTBCNRM with a correct
value. For 82576 device, the value should be 0x14.

Signed-off-by: Lior Levy <lior.levy@intel.com>
Tested-by: Jeff Pieper <jeffrey.e.pieper@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/igb/e1000_regs.h |    1 +
 drivers/net/ethernet/intel/igb/igb_main.c   |    5 +++++
 2 files changed, 6 insertions(+)

diff --git a/drivers/net/ethernet/intel/igb/e1000_regs.h b/drivers/net/ethernet/intel/igb/e1000_regs.h
index 35d1e4f..10efcd8 100644
--- a/drivers/net/ethernet/intel/igb/e1000_regs.h
+++ b/drivers/net/ethernet/intel/igb/e1000_regs.h
@@ -117,6 +117,7 @@
 
 /* TX Rate Limit Registers */
 #define E1000_RTTDQSEL	0x3604	/* Tx Desc Plane Queue Select - WO */
+#define E1000_RTTBCNRM	0x3690	/* Tx BCN Rate-scheduler MMW */
 #define E1000_RTTBCNRC	0x36B0	/* Tx BCN Rate-Scheduler Config - WO */
 
 /* Split and Replication RX Control - RW */
diff --git a/drivers/net/ethernet/intel/igb/igb_main.c b/drivers/net/ethernet/intel/igb/igb_main.c
index dd3bfe8..6409054 100644
--- a/drivers/net/ethernet/intel/igb/igb_main.c
+++ b/drivers/net/ethernet/intel/igb/igb_main.c
@@ -6997,6 +6997,11 @@ static void igb_set_vf_rate_limit(struct e1000_hw *hw, int vf, int tx_rate,
 	}
 
 	wr32(E1000_RTTDQSEL, vf); /* vf X uses queue X */
+	/*
+	 * Set global transmit compensation time to the MMW_SIZE in RTTBCNRM
+	 * register. MMW_SIZE=0x014 if 9728-byte jumbo is supported.
+	 */
+	wr32(E1000_RTTBCNRM, 0x14);
 	wr32(E1000_RTTBCNRC, bcnrc_val);
 }
 
-- 
1.7.10.2
