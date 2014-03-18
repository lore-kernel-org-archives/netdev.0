From: Monam Agarwal <monamagarwal123@gmail.com>
Subject: [PATCH 8/9] rcu: Replace rcu_assign_pointer(x, NULL) with RCU_INIT_POINTER(x, NULL)
Date: Wed, 19 Mar 2014 04:20:31 +0530
Message-ID: <559d2e263bf280dff5c56c68de08a7ea747cc5c2.1395182132.git.monamagarwal123@gmail.com>
References: <58ab73ae9aaa60d9676d5e7cf3a331ae8536b4d2.1395182132.git.monamagarwal123@gmail.com>
Cc: linux-kernel@vger.kernel.org, eddie.wai@broadcom.com,
	paulmck@linux.vnet.ibm.com
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <58ab73ae9aaa60d9676d5e7cf3a331ae8536b4d2.1395182132.git.monamagarwal123@gmail.com>
In-Reply-To: <cover.1395182132.git.monamagarwal123@gmail.com>
References: <cover.1395182132.git.monamagarwal123@gmail.com>
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
