From: Monam Agarwal <monamagarwal123@gmail.com>
Subject: [PATCH 8/9] vhost: Replace rcu_assign_pointer(x, NULL) with RCU_INIT_POINTER(x, NULL) in drivers/vhost/net.c
Date: Thu, 20 Mar 2014 20:16:00 +0530
Message-ID: <649bfa7337b1aca38de9b1aa69f1d68e6c257a74.1395324808.git.monamagarwal123@gmail.com>
References: <db3a67a00fa847aabde7244268fafdbc78783207.1395324808.git.monamagarwal123@gmail.com>
Cc: linux-kernel@vger.kernel.org, eddie.wai@broadcom.com,
	paulmck@linux.vnet.ibm.com
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <db3a67a00fa847aabde7244268fafdbc78783207.1395324808.git.monamagarwal123@gmail.com>
In-Reply-To: <cover.1395324808.git.monamagarwal123@gmail.com>
References: <cover.1395324808.git.monamagarwal123@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Monam Agarwal <monamagarwal123@gmail.com>
---
 drivers/vhost/net.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/vhost/net.c b/drivers/vhost/net.c
index 882a51f..b243e06 100644
--- a/drivers/vhost/net.c
+++ b/drivers/vhost/net.c
@@ -556,7 +556,7 @@ static struct socket *vhost_net_stop_vq(struct vhost_net *n,
 	sock = rcu_dereference_protected(vq->private_data,
 					 lockdep_is_held(&vq->mutex));
 	vhost_net_disable_vq(n, vq);
-	rcu_assign_pointer(vq->private_data, NULL);
+	RCU_INIT_POINTER(vq->private_data, NULL);
 	mutex_unlock(&vq->mutex);
 	return sock;
 }
-- 
1.7.9.5
