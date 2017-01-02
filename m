From: Santosh Shilimkar <santosh.shilimkar@oracle.com>
Subject: [net-next][PATCH v3 01/17] RDS: log the address on bind failure
Date: Mon,  2 Jan 2017 14:45:36 -0800
Message-ID: <1483397152-8307-2-git-send-email-santosh.shilimkar@oracle.com>
References: <1483397152-8307-1-git-send-email-santosh.shilimkar@oracle.com>
Cc: linux-kernel@vger.kernel.org, santosh.shilimkar@oracle.com
To: netdev@vger.kernel.org, davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1483397152-8307-1-git-send-email-santosh.shilimkar@oracle.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

It's useful to know the IP address when RDS fails to bind a
connection. Thus, adding it to the error message.

Orabug: 21894138
Reviewed-by: Wei Lin Guay <wei.lin.guay@oracle.com>
Signed-off-by: Santosh Shilimkar <santosh.shilimkar@oracle.com>
---
 net/rds/bind.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/rds/bind.c b/net/rds/bind.c
index 095f6ce..3a915be 100644
--- a/net/rds/bind.c
+++ b/net/rds/bind.c
@@ -176,8 +176,8 @@ int rds_bind(struct socket *sock, struct sockaddr *uaddr, int addr_len)
 	if (!trans) {
 		ret = -EADDRNOTAVAIL;
 		rds_remove_bound(rs);
-		printk_ratelimited(KERN_INFO "RDS: rds_bind() could not find a transport, "
-				"load rds_tcp or rds_rdma?\n");
+		pr_info_ratelimited("RDS: %s could not find a transport for %pI4, load rds_tcp or rds_rdma?\n",
+				    __func__, &sin->sin_addr.s_addr);
 		goto out;
 	}
 
-- 
1.9.1
