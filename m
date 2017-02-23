From: "Dmitry V. Levin" <ldv@altlinux.org>
Subject: [PATCH v2] uapi: fix linux/rds.h userspace compilation errors
Date: Thu, 23 Feb 2017 14:35:23 +0300
Message-ID: <20170223113523.GB22568@altlinux.org>
References: <20170223011320.GA16142@altlinux.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>,
        Santosh Shilimkar <santosh.shilimkar@oracle.com>,
        Sowmini Varadhan <sowmini.varadhan@oracle.com>,
        Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <46a28c0c-36fe-db81-d263-f737f1d3ea05@cogentembedded.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Consistently use types from linux/types.h to fix the following
linux/rds.h userspace compilation errors:

/usr/include/linux/rds.h:198:2: error: unknown type name 'u8'
  u8 rx_traces;
/usr/include/linux/rds.h:199:2: error: unknown type name 'u8'
  u8 rx_trace_pos[RDS_MSG_RX_DGRAM_TRACE_MAX];
/usr/include/linux/rds.h:203:2: error: unknown type name 'u8'
  u8 rx_traces;
/usr/include/linux/rds.h:204:2: error: unknown type name 'u8'
  u8 rx_trace_pos[RDS_MSG_RX_DGRAM_TRACE_MAX];
/usr/include/linux/rds.h:205:2: error: unknown type name 'u64'
  u64 rx_trace[RDS_MSG_RX_DGRAM_TRACE_MAX];

Fixes: 3289025aedc0 ("RDS: add receive message trace used by application")
Signed-off-by: Dmitry V. Levin <ldv@altlinux.org>
Acked-by: Santosh Shilimkar <santosh.shilimkar@oracle.com>
---
v2: fixed "Fixes:" line

 include/uapi/linux/rds.h | 10 +++++-----
 1 file changed, 5 insertions(+), 5 deletions(-)

diff --git a/include/uapi/linux/rds.h b/include/uapi/linux/rds.h
index 47c03ca..198892b 100644
--- a/include/uapi/linux/rds.h
+++ b/include/uapi/linux/rds.h
@@ -195,14 +195,14 @@ enum rds_message_rxpath_latency {
 };
 
 struct rds_rx_trace_so {
-	u8 rx_traces;
-	u8 rx_trace_pos[RDS_MSG_RX_DGRAM_TRACE_MAX];
+	__u8 rx_traces;
+	__u8 rx_trace_pos[RDS_MSG_RX_DGRAM_TRACE_MAX];
 };
 
 struct rds_cmsg_rx_trace {
-	u8 rx_traces;
-	u8 rx_trace_pos[RDS_MSG_RX_DGRAM_TRACE_MAX];
-	u64 rx_trace[RDS_MSG_RX_DGRAM_TRACE_MAX];
+	__u8 rx_traces;
+	__u8 rx_trace_pos[RDS_MSG_RX_DGRAM_TRACE_MAX];
+	__u64 rx_trace[RDS_MSG_RX_DGRAM_TRACE_MAX];
 };
 
 /*
-- 
ldv
