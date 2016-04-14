From: Santosh Shilimkar <santosh.shilimkar@oracle.com>
Subject: [net][PATCH v2 1/2] RDS: fix endianness for dp_ack_seq
Date: Thu, 14 Apr 2016 10:43:26 -0700
Message-ID: <1460655807-26236-2-git-send-email-santosh.shilimkar@oracle.com>
References: <1460655807-26236-1-git-send-email-santosh.shilimkar@oracle.com>
Cc: linux-kernel@vger.kernel.org,
	Santosh Shilimkar <santosh.shilimkar@oracle.com>
To: netdev@vger.kernel.org, davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1460655807-26236-1-git-send-email-santosh.shilimkar@oracle.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Qing Huang <qing.huang@oracle.com>

dp->dp_ack_seq is used in big endian format. We need to do the
big endianness conversion when we assign a value in host format
to it.

Signed-off-by: Qing Huang <qing.huang@oracle.com>
Signed-off-by: Santosh Shilimkar <santosh.shilimkar@oracle.com>
---
 net/rds/ib_cm.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/rds/ib_cm.c b/net/rds/ib_cm.c
index 8764970..310cabc 100644
--- a/net/rds/ib_cm.c
+++ b/net/rds/ib_cm.c
@@ -194,7 +194,7 @@ static void rds_ib_cm_fill_conn_param(struct rds_connection *conn,
 		dp->dp_protocol_major = RDS_PROTOCOL_MAJOR(protocol_version);
 		dp->dp_protocol_minor = RDS_PROTOCOL_MINOR(protocol_version);
 		dp->dp_protocol_minor_mask = cpu_to_be16(RDS_IB_SUPPORTED_PROTOCOLS);
-		dp->dp_ack_seq = rds_ib_piggyb_ack(ic);
+		dp->dp_ack_seq = cpu_to_be64(rds_ib_piggyb_ack(ic));
 
 		/* Advertise flow control */
 		if (ic->i_flowctl) {
-- 
1.9.1
