From: SF Markus Elfring <elfring@users.sourceforge.net>
Subject: [PATCH 3/3] RDS: TCP: Delete an error message for a failed memory
 allocation in rds_tcp_init_net()
Date: Mon, 22 May 2017 16:13:11 +0200
Message-ID: <5d523cf8-1540-e704-2301-a5e0205cb536@users.sourceforge.net>
References: <44b46c51-3665-5f14-dd3b-6e6f230258a7@users.sourceforge.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: LKML <linux-kernel@vger.kernel.org>,
        kernel-janitors@vger.kernel.org
To: linux-rdma@vger.kernel.org, netdev@vger.kernel.org,
        rds-devel@oss.oracle.com, "David S. Miller" <davem@davemloft.net>,
        Santosh Shilimkar <santosh.shilimkar@oracle.com>,
        Sowmini Varadhan <sowmini.varadhan@oracle.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <44b46c51-3665-5f14-dd3b-6e6f230258a7@users.sourceforge.net>
Content-Language: en-GB
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Markus Elfring <elfring@users.sourceforge.net>
Date: Mon, 22 May 2017 15:45:31 +0200

Omit an extra message for a memory allocation failure in this function.

This issue was detected by using the Coccinelle software.

Link: http://events.linuxfoundation.org/sites/events/files/slides/LCJ16-Refactor_Strings-WSang_0.pdf
Signed-off-by: Markus Elfring <elfring@users.sourceforge.net>
---
 net/rds/tcp.c | 5 ++---
 1 file changed, 2 insertions(+), 3 deletions(-)

diff --git a/net/rds/tcp.c b/net/rds/tcp.c
index 431404dbdad1..b0348697dee5 100644
--- a/net/rds/tcp.c
+++ b/net/rds/tcp.c
@@ -431,10 +431,9 @@ static __net_init int rds_tcp_init_net(struct net *net)
 	} else {
 		tbl = kmemdup(rds_tcp_sysctl_table,
 			      sizeof(rds_tcp_sysctl_table), GFP_KERNEL);
-		if (!tbl) {
-			pr_warn("could not set allocate syctl table\n");
+		if (!tbl)
 			return -ENOMEM;
-		}
+
 		rtn->ctl_table = tbl;
 	}
 	tbl[RDS_TCP_SNDBUF].data = &rtn->sndbuf_size;
-- 
2.13.0
