From: Joe Perches <joe@perches.com>
Subject: [PATCH 47/49] net/rds: Use vzalloc
Date: Thu,  4 Nov 2010 20:08:11 -0700
Message-ID: <8a5a2c1182dcc6c558c1c351e63c5bcccac537f1.1288925425.git.joe@perches.com>
References: <alpine.DEB.2.00.1011031108260.11625@router.home>
Cc: Andy Grover <andy.grover@oracle.com>,
	"David S. Miller" <davem@davemloft.net>, rds-devel@oss.oracle.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Jiri Kosina <trivial@kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <alpine.DEB.2.00.1011031108260.11625@router.home>
In-Reply-To: <cover.1288925424.git.joe@perches.com>
References: <cover.1288925424.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Joe Perches <joe@perches.com>
---
 net/rds/ib_cm.c |    6 ++----
 1 files changed, 2 insertions(+), 4 deletions(-)

diff --git a/net/rds/ib_cm.c b/net/rds/ib_cm.c
index ee369d2..cc6b073 100644
--- a/net/rds/ib_cm.c
+++ b/net/rds/ib_cm.c
@@ -374,23 +374,21 @@ static int rds_ib_setup_qp(struct rds_connection *conn)
 		goto out;
 	}
 
-	ic->i_sends = vmalloc_node(ic->i_send_ring.w_nr * sizeof(struct rds_ib_send_work),
+	ic->i_sends = vzalloc_node(ic->i_send_ring.w_nr * sizeof(struct rds_ib_send_work),
 				   ibdev_to_node(dev));
 	if (!ic->i_sends) {
 		ret = -ENOMEM;
 		rdsdebug("send allocation failed\n");
 		goto out;
 	}
-	memset(ic->i_sends, 0, ic->i_send_ring.w_nr * sizeof(struct rds_ib_send_work));
 
-	ic->i_recvs = vmalloc_node(ic->i_recv_ring.w_nr * sizeof(struct rds_ib_recv_work),
+	ic->i_recvs = vzalloc_node(ic->i_recv_ring.w_nr * sizeof(struct rds_ib_recv_work),
 				   ibdev_to_node(dev));
 	if (!ic->i_recvs) {
 		ret = -ENOMEM;
 		rdsdebug("recv allocation failed\n");
 		goto out;
 	}
-	memset(ic->i_recvs, 0, ic->i_recv_ring.w_nr * sizeof(struct rds_ib_recv_work));
 
 	rds_ib_recv_init_ack(ic);
 
-- 
1.7.3.1.g432b3.dirty
