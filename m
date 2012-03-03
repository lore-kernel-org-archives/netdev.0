From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 1/4] e100: Fix rx-over-length statistics.
Date: Fri,  2 Mar 2012 18:26:24 -0800
Message-ID: <1330741587-24073-2-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1330741587-24073-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Ben Greear <greearb@candelatech.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:10531 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751529Ab2CCC0b (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 2 Mar 2012 21:26:31 -0500
In-Reply-To: <1330741587-24073-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Greear <greearb@candelatech.com>

The old code would += the total errors every time
stats were gathered.  Instead, keep a count of short-pkt
and long-pkt counters and then simply add them together
for the rx-over-length stat.

Signed-off-by: Ben Greear <greearb@candelatech.com>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/e100.c |    5 ++++-
 1 files changed, 4 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/intel/e100.c b/drivers/net/ethernet/intel/e100.c
index 4d8a616..d2b7872 100644
--- a/drivers/net/ethernet/intel/e100.c
+++ b/drivers/net/ethernet/intel/e100.c
@@ -622,6 +622,7 @@ struct nic {
 	u32 rx_fc_pause;
 	u32 rx_fc_unsupported;
 	u32 rx_tco_frames;
+	u32 rx_short_frame_errors;
 	u32 rx_over_length_errors;
 
 	u16 eeprom_wc;
@@ -1622,7 +1623,9 @@ static void e100_update_stats(struct nic *nic)
 		ns->collisions += nic->tx_collisions;
 		ns->tx_errors += le32_to_cpu(s->tx_max_collisions) +
 			le32_to_cpu(s->tx_lost_crs);
-		ns->rx_length_errors += le32_to_cpu(s->rx_short_frame_errors) +
+		nic->rx_short_frame_errors +=
+			le32_to_cpu(s->rx_short_frame_errors);
+		ns->rx_length_errors = nic->rx_short_frame_errors +
 			nic->rx_over_length_errors;
 		ns->rx_crc_errors += le32_to_cpu(s->rx_crc_errors);
 		ns->rx_frame_errors += le32_to_cpu(s->rx_alignment_errors);
-- 
1.7.7.6
