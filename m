From: Michal Schmidt <mschmidt@redhat.com>
Subject: [PATCH net 2/7] bnx2x: lower verbosity of VF stats debug messages
Date: Fri,  3 Mar 2017 17:08:29 +0100
Message-ID: <20170303160834.4125-3-mschmidt@redhat.com>
References: <20170303160834.4125-1-mschmidt@redhat.com>
Cc: Yuval Mintz <Yuval.Mintz@cavium.com>,
        Ariel Elior <ariel.elior@cavium.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:53952 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752017AbdCCQIk (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 3 Mar 2017 11:08:40 -0500
In-Reply-To: <20170303160834.4125-1-mschmidt@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When BNX2X_MSG_IOV is enabled, the driver produces too many VF statistics
messages. Lower the verbosity of the VF stats messages similarly as in
commit 76ca70fabbdaa3 ("bnx2x: [Debug] change verbosity of some prints").

Signed-off-by: Michal Schmidt <mschmidt@redhat.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.c | 14 ++++++++------
 1 file changed, 8 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.c
index 6fad22adbb..9f0f851774 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.c
@@ -1899,7 +1899,8 @@ void bnx2x_iov_adjust_stats_req(struct bnx2x *bp)
 			continue;
 		}
 
-		DP(BNX2X_MSG_IOV, "add addresses for vf %d\n", vf->abs_vfid);
+		DP_AND((BNX2X_MSG_IOV | BNX2X_MSG_STATS),
+		       "add addresses for vf %d\n", vf->abs_vfid);
 		for_each_vfq(vf, j) {
 			struct bnx2x_vf_queue *rxq = vfq_get(vf, j);
 
@@ -1920,11 +1921,12 @@ void bnx2x_iov_adjust_stats_req(struct bnx2x *bp)
 				cpu_to_le32(U64_HI(q_stats_addr));
 			cur_query_entry->address.lo =
 				cpu_to_le32(U64_LO(q_stats_addr));
-			DP(BNX2X_MSG_IOV,
-			   "added address %x %x for vf %d queue %d client %d\n",
-			   cur_query_entry->address.hi,
-			   cur_query_entry->address.lo, cur_query_entry->funcID,
-			   j, cur_query_entry->index);
+			DP_AND((BNX2X_MSG_IOV | BNX2X_MSG_STATS),
+			       "added address %x %x for vf %d queue %d client %d\n",
+			       cur_query_entry->address.hi,
+			       cur_query_entry->address.lo,
+			       cur_query_entry->funcID,
+			       j, cur_query_entry->index);
 			cur_query_entry++;
 			cur_data_offset += sizeof(struct per_queue_stats);
 			stats_count++;
-- 
2.9.3
