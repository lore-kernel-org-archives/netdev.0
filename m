From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Subject: [PATCHv2 1/6] RDS: Re-add pf/sol access via sysctl
Date: Thu,  2 Apr 2015 10:19:35 -0400
Message-ID: <6df5ee9a571eb865e5a26f367e18c34182de9e17.1427983908.git.sowmini.varadhan@oracle.com>
References: <cover.1427983908.git.sowmini.varadhan@oracle.com>
Cc: chien.yen@oracle.com, davem@davemloft.net,
	rds-devel@oss.oracle.com, agrover@redhat.com, clm@fb.com,
	zab@zabbo.net, ajaykumar.hotchandani@oracle.com,
	sergei.shtylyov@cogentembedded.com,
	Sowmini Varadhan <sowmini.varadhan@oracle.com>
To: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1427983908.git.sowmini.varadhan@oracle.com>
In-Reply-To: <cover.1427983908.git.sowmini.varadhan@oracle.com>
References: <cover.1427983908.git.sowmini.varadhan@oracle.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Although RDS has an official PF_RDS value now, existing software
expects to look for rds sysctls to determine it. We need to maintain
these for now, for backwards compatibility.

Original patch by Andy Grover

Signed-off-by: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Reviewed-by: Ajaykumar Hotchandani <ajaykumar.hotchandani@oracle.com>
---
 net/rds/sysctl.c |   20 ++++++++++++++++++++
 1 files changed, 20 insertions(+), 0 deletions(-)

diff --git a/net/rds/sysctl.c b/net/rds/sysctl.c
index c173f69..5fbe9e6 100644
--- a/net/rds/sysctl.c
+++ b/net/rds/sysctl.c
@@ -49,6 +49,12 @@ unsigned int  rds_sysctl_max_unacked_bytes = (16 << 20);
 
 unsigned int rds_sysctl_ping_enable = 1;
 
+/* We have official values, but must maintain the sysctl interface for existing
+ * software that expects to find these values here.
+ */
+static int rds_sysctl_pf_rds = PF_RDS;
+static int rds_sysctl_sol_rds = SOL_RDS;
+
 static struct ctl_table rds_sysctl_rds_table[] = {
 	{
 		.procname       = "reconnect_min_delay_ms",
@@ -69,6 +75,20 @@ static struct ctl_table rds_sysctl_rds_table[] = {
 		.extra2		= &rds_sysctl_reconnect_max,
 	},
 	{
+		.procname       = "pf_rds",
+		.data		= &rds_sysctl_pf_rds,
+		.maxlen         = sizeof(int),
+		.mode           = 0444,
+		.proc_handler   = proc_dointvec,
+	},
+	{
+		.procname       = "sol_rds",
+		.data		= &rds_sysctl_sol_rds,
+		.maxlen         = sizeof(int),
+		.mode           = 0444,
+		.proc_handler   = proc_dointvec,
+	},
+	{
 		.procname	= "max_unacked_packets",
 		.data		= &rds_sysctl_max_unacked_packets,
 		.maxlen         = sizeof(int),
-- 
1.7.1
