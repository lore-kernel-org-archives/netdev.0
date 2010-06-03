From: Amerigo Wang <amwang@redhat.com>
Subject: [Patch] infiniband: check local reserved ports
Date: Thu, 3 Jun 2010 04:27:02 -0400
Message-ID: <20100603083106.6047.7657.sendpatchset@localhost.localdomain>
Cc: netdev@vger.kernel.org,
	Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>,
	Amerigo Wang <amwang@redhat.com>,
	Roland Dreier <rdreier@cisco.com>, davem@davemloft.net
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Since Tetsuo's patch already got merged, now this is the missing part
for local port reservation.

Cc: Roland Dreier <rdreier@cisco.com>
Cc: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Signed-off-by: WANG Cong <amwang@redhat.com>

---
diff --git a/drivers/infiniband/core/cma.c b/drivers/infiniband/core/cma.c
index b930b81..7b89bab 100644
--- a/drivers/infiniband/core/cma.c
+++ b/drivers/infiniband/core/cma.c
@@ -1978,6 +1978,7 @@ static int cma_alloc_any_port(struct idr *ps, struct rdma_id_private *id_priv)
 	rover = net_random() % remaining + low;
 retry:
 	if (last_used_port != rover &&
+	    !inet_is_reserved_local_port(rover) &&
 	    !idr_find(ps, (unsigned short) rover)) {
 		int ret = cma_alloc_port(ps, id_priv, rover);
 		/*
