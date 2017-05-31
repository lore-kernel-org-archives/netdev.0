From: Felix Manlunas <felix.manlunas@cavium.com>
Subject: [PATCH net-next] liquidio: Fix checkpatch errors with references
 crossing single line
Date: Wed, 31 May 2017 10:45:15 -0700
Message-ID: <20170531174515.GA1539@felix-thinkpad.cavium.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, raghu.vatsavayi@cavium.com,
        derek.chickles@cavium.com, satananda.burla@cavium.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-by2nam03on0071.outbound.protection.outlook.com ([104.47.42.71]:31231
        "EHLO NAM03-BY2-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751205AbdEaRpV (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 31 May 2017 13:45:21 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Satanand Burla <satananda.burla@cavium.com>

Signed-off-by: Satanand Burla <satananda.burla@cavium.com>
Signed-off-by: Derek Chickles <derek.chickles@cavium.com>
Signed-off-by: Felix Manlunas <felix.manlunas@cavium.com>
---
 drivers/net/ethernet/cavium/liquidio/lio_ethtool.c     |  8 ++++----
 drivers/net/ethernet/cavium/liquidio/octeon_droq.c     | 11 +++++------
 drivers/net/ethernet/cavium/liquidio/request_manager.c |  3 +--
 3 files changed, 10 insertions(+), 12 deletions(-)

diff --git a/drivers/net/ethernet/cavium/liquidio/lio_ethtool.c b/drivers/net/ethernet/cavium/liquidio/lio_ethtool.c
index 579dc73..2e25306 100644
--- a/drivers/net/ethernet/cavium/liquidio/lio_ethtool.c
+++ b/drivers/net/ethernet/cavium/liquidio/lio_ethtool.c
@@ -984,11 +984,11 @@ lio_get_ethtool_stats(struct net_device *netdev,
 		data[i++] =
 			CVM_CAST64(oct_dev->instr_queue[j]->stats.instr_posted);
 		/*# of instructions processed */
-		data[i++] = CVM_CAST64(oct_dev->instr_queue[j]->
-				       stats.instr_processed);
+		data[i++] = CVM_CAST64(
+				oct_dev->instr_queue[j]->stats.instr_processed);
 		/*# of instructions could not be processed */
-		data[i++] = CVM_CAST64(oct_dev->instr_queue[j]->
-				       stats.instr_dropped);
+		data[i++] = CVM_CAST64(
+				oct_dev->instr_queue[j]->stats.instr_dropped);
 		/*bytes sent through the queue */
 		data[i++] =
 			CVM_CAST64(oct_dev->instr_queue[j]->stats.bytes_sent);
diff --git a/drivers/net/ethernet/cavium/liquidio/octeon_droq.c b/drivers/net/ethernet/cavium/liquidio/octeon_droq.c
index 286be55..d3a6a1c 100644
--- a/drivers/net/ethernet/cavium/liquidio/octeon_droq.c
+++ b/drivers/net/ethernet/cavium/liquidio/octeon_droq.c
@@ -425,8 +425,7 @@ octeon_droq_refill_pullup_descs(struct octeon_droq *droq,
 							      droq->max_count);
 				desc_refilled++;
 				droq->refill_count--;
-			} while (droq->recv_buf_list[droq->refill_idx].
-				 buffer);
+			} while (droq->recv_buf_list[droq->refill_idx].buffer);
 		}
 		refill_index = incr_index(refill_index, 1, droq->max_count);
 	}                       /* while */
@@ -490,8 +489,8 @@ octeon_droq_refill(struct octeon_device *octeon_dev, struct octeon_droq *droq)
 		droq->recv_buf_list[droq->refill_idx].data = data;
 
 		desc_ring[droq->refill_idx].buffer_ptr =
-			lio_map_ring(droq->recv_buf_list[droq->
-				     refill_idx].buffer);
+			lio_map_ring(droq->recv_buf_list[
+				     droq->refill_idx].buffer);
 		/* Reset any previous values in the length field. */
 		droq->info_list[droq->refill_idx].length = 0;
 
@@ -690,8 +689,8 @@ octeon_droq_fast_process_packets(struct octeon_device *oct,
 									nicbuf,
 									cpy_len,
 									idx);
-						buf = droq->recv_buf_list[idx].
-							buffer;
+						buf = droq->recv_buf_list[
+							idx].buffer;
 						recv_buffer_fast_free(buf);
 						droq->recv_buf_list[idx].buffer
 							= NULL;
diff --git a/drivers/net/ethernet/cavium/liquidio/request_manager.c b/drivers/net/ethernet/cavium/liquidio/request_manager.c
index 261f448..7b297f1 100644
--- a/drivers/net/ethernet/cavium/liquidio/request_manager.c
+++ b/drivers/net/ethernet/cavium/liquidio/request_manager.c
@@ -252,8 +252,7 @@ int lio_wait_for_instr_fetch(struct octeon_device *oct)
 			if (!(oct->io_qmask.iq & BIT_ULL(i)))
 				continue;
 			pending =
-			    atomic_read(&oct->
-					       instr_queue[i]->instr_pending);
+			    atomic_read(&oct->instr_queue[i]->instr_pending);
 			if (pending)
 				__check_db_timeout(oct, i);
 			instr_cnt += pending;
