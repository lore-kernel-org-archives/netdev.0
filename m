From: Monam Agarwal <monamagarwal123@gmail.com>
Subject: [PATCH 9/9] vhost: Replace rcu_assign_pointer(x, NULL) with RCU_INIT_POINTER(x, NULL) in test.c
Date: Thu, 20 Mar 2014 20:16:42 +0530
Message-ID: <07dc03597c3779e18b0e402efd59c39eabc5bb57.1395324808.git.monamagarwal123@gmail.com>
References: <649bfa7337b1aca38de9b1aa69f1d68e6c257a74.1395324808.git.monamagarwal123@gmail.com>
Cc: linux-kernel@vger.kernel.org, eddie.wai@broadcom.com,
	paulmck@linux.vnet.ibm.com
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <649bfa7337b1aca38de9b1aa69f1d68e6c257a74.1395324808.git.monamagarwal123@gmail.com>
In-Reply-To: <cover.1395324808.git.monamagarwal123@gmail.com>
References: <cover.1395324808.git.monamagarwal123@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Monam Agarwal <monamagarwal123@gmail.com>
---
 drivers/vhost/test.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/vhost/test.c b/drivers/vhost/test.c
index fc9a1d7..82b3744 100644
--- a/drivers/vhost/test.c
+++ b/drivers/vhost/test.c
@@ -128,7 +128,7 @@ static void *vhost_test_stop_vq(struct vhost_test *n,
 	mutex_lock(&vq->mutex);
 	private = rcu_dereference_protected(vq->private_data,
 					 lockdep_is_held(&vq->mutex));
-	rcu_assign_pointer(vq->private_data, NULL);
+	RCU_INIT_POINTER(vq->private_data, NULL);
 	mutex_unlock(&vq->mutex);
 	return private;
 }
-- 
1.7.9.5
