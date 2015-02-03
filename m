From: Sasha Levin <sasha.levin@oracle.com>
Subject: [PATCH] net: rds: use correct size for max unacked packets and bytes
Date: Tue,  3 Feb 2015 08:55:58 -0500
Message-ID: <1422971760-8217-1-git-send-email-sasha.levin@oracle.com>
Cc: Sasha Levin <sasha.levin@oracle.com>,
	Chien Yen <chien.yen@oracle.com>,
	"David S. Miller" <davem@davemloft.net>,
	rds-devel@oss.oracle.com (moderated list:RDS - RELIABLE DA...),
	netdev@vger.kernel.org (open list:NETWORKING [GENERAL])
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Max unacked packets/bytes is an int while sizeof(long) was used in the
sysctl table.

This means that when they were getting read we'd also leak kernel memory
to userspace along with the timeout values.

Signed-off-by: Sasha Levin <sasha.levin@oracle.com>
---
 net/rds/sysctl.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/rds/sysctl.c b/net/rds/sysctl.c
index c3b0cd4..c173f69 100644
--- a/net/rds/sysctl.c
+++ b/net/rds/sysctl.c
@@ -71,14 +71,14 @@ static struct ctl_table rds_sysctl_rds_table[] = {
 	{
 		.procname	= "max_unacked_packets",
 		.data		= &rds_sysctl_max_unacked_packets,
-		.maxlen         = sizeof(unsigned long),
+		.maxlen         = sizeof(int),
 		.mode           = 0644,
 		.proc_handler   = proc_dointvec,
 	},
 	{
 		.procname	= "max_unacked_bytes",
 		.data		= &rds_sysctl_max_unacked_bytes,
-		.maxlen         = sizeof(unsigned long),
+		.maxlen         = sizeof(int),
 		.mode           = 0644,
 		.proc_handler   = proc_dointvec,
 	},
-- 
1.7.10.4
