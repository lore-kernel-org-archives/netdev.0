From: Santosh Shilimkar <santosh.shilimkar@oracle.com>
Subject: [net-next][PATCH] RDS: validate the requested traces user input against max supported
Date: Fri,  6 Jan 2017 10:44:15 -0800
Message-ID: <1483728255-9111-1-git-send-email-santosh.shilimkar@oracle.com>
Cc: linux-kernel@vger.kernel.org,
        Santosh Shilimkar <santosh.shilimkar@oracle.com>
To: netdev@vger.kernel.org, davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Larger than supported value can lead to array read/write overflow.

Reported-by: Colin Ian King <colin.king@canonical.com>
Signed-off-by: Santosh Shilimkar <santosh.shilimkar@oracle.com>
---
 net/rds/af_rds.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/net/rds/af_rds.c b/net/rds/af_rds.c
index fd821740..b405f77 100644
--- a/net/rds/af_rds.c
+++ b/net/rds/af_rds.c
@@ -310,6 +310,9 @@ static int rds_recv_track_latency(struct rds_sock *rs, char __user *optval,
 	if (copy_from_user(&trace, optval, sizeof(trace)))
 		return -EFAULT;
 
+	if (trace.rx_traces > RDS_MSG_RX_DGRAM_TRACE_MAX)
+		return -EFAULT;
+
 	rs->rs_rx_traces = trace.rx_traces;
 	for (i = 0; i < rs->rs_rx_traces; i++) {
 		if (trace.rx_trace_pos[i] > RDS_MSG_RX_DGRAM_TRACE_MAX) {
-- 
1.9.1
