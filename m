From: greearb@candelatech.com
Subject: [PATCH] e100:  Fix rx-over-length statistics.
Date: Thu, 16 Feb 2012 10:55:04 -0800
Message-ID: <1329418504-31616-1-git-send-email-greearb@candelatech.com>
Cc: jeffrey.t.kirsher@intel.com, Ben Greear <greearb@candelatech.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:59131 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754552Ab2BPSzj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Feb 2012 13:55:39 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Greear <greearb@candelatech.com>

The old code would += the total errors every time
stats were gathered.  Instead, keep a count of short-pkt
and long-pkt counters and then simply add them together
for the rx-over-length stat.

Signed-off-by: Ben Greear <greearb@candelatech.com>
---
:100644 100644 4d8a616... db20a36... M	drivers/net/ethernet/intel/e100.c
 drivers/net/ethernet/intel/e100.c |    4 +++-
 1 files changed, 3 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/intel/e100.c b/drivers/net/ethernet/intel/e100.c
index 4d8a616..db20a36 100644
--- a/drivers/net/ethernet/intel/e100.c
+++ b/drivers/net/ethernet/intel/e100.c
@@ -622,6 +622,7 @@ struct nic {
 	u32 rx_fc_pause;
 	u32 rx_fc_unsupported;
 	u32 rx_tco_frames;
+	u32 rx_short_frame_errors;
 	u32 rx_over_length_errors;
 
 	u16 eeprom_wc;
@@ -1622,7 +1623,8 @@ static void e100_update_stats(struct nic *nic)
 		ns->collisions += nic->tx_collisions;
 		ns->tx_errors += le32_to_cpu(s->tx_max_collisions) +
 			le32_to_cpu(s->tx_lost_crs);
-		ns->rx_length_errors += le32_to_cpu(s->rx_short_frame_errors) +
+		nic->rx_short_frame_errors += le32_to_cpu(s->rx_short_frame_errors);
+		ns->rx_length_errors = nic->rx_short_frame_errors +
 			nic->rx_over_length_errors;
 		ns->rx_crc_errors += le32_to_cpu(s->rx_crc_errors);
 		ns->rx_frame_errors += le32_to_cpu(s->rx_alignment_errors);
-- 
1.7.3.4
