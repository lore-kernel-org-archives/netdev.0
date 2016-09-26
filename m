From: Baoyou Xie <baoyou.xie@linaro.org>
Subject: [PATCH] vhost: mark symbols static in vhost.c
Date: Mon, 26 Sep 2016 19:45:03 +0800
Message-ID: <1474890303-3456-1-git-send-email-baoyou.xie@linaro.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: kvm@vger.kernel.org, arnd@arndb.de, netdev@vger.kernel.org,
	tang.qiang007@zte.com.cn, xie.baoyou@zte.com.cn,
	linux-kernel@vger.kernel.org,
	virtualization@lists.linux-foundation.org, han.fei@zte.com.cn,
	baoyou.xie@linaro.org
To: mst@redhat.com
Return-path: <virtualization-bounces@lists.linux-foundation.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/virtualization/>
List-Post: <mailto:virtualization@lists.linux-foundation.org>
List-Help: <mailto:virtualization-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=subscribe>
Sender: virtualization-bounces@lists.linux-foundation.org
Errors-To: virtualization-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

We get 4 warnings when building kernel with W=1:
drivers/vhost/vhost.c:52:23: warning: no previous prototype for 'vhost_umem_interval_tree_insert' [-Wmissing-prototypes]
drivers/vhost/vhost.c:52:23: warning: no previous prototype for 'vhost_umem_interval_tree_remove' [-Wmissing-prototypes]
drivers/vhost/vhost.c:52:23: warning: no previous prototype for 'vhost_umem_interval_tree_iter_first' [-Wmissing-prototypes]
drivers/vhost/vhost.c:52:23: warning: no previous prototype for 'vhost_umem_interval_tree_iter_next' [-Wmissing-prototypes]

In fact, these functions are defined in the
macro 'INTERVAL_TREE_DEFINE' in include/linux/interval_tree_generic.h
and don't need a declaration, but can be made static.

so this patch marks these functions with 'static' by modifying
the macro.

Signed-off-by: Baoyou Xie <baoyou.xie@linaro.org>
---
 drivers/vhost/vhost.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/vhost/vhost.c b/drivers/vhost/vhost.c
index c6f2d89..99c6d0d 100644
--- a/drivers/vhost/vhost.c
+++ b/drivers/vhost/vhost.c
@@ -48,8 +48,8 @@ enum {
 #define vhost_avail_event(vq) ((__virtio16 __user *)&vq->used->ring[vq->num])
 
 INTERVAL_TREE_DEFINE(struct vhost_umem_node,
-		     rb, __u64, __subtree_last,
-		     START, LAST, , vhost_umem_interval_tree);
+		     rb, __u64, __subtree_last, START, LAST,
+		     static, vhost_umem_interval_tree);
 
 #ifdef CONFIG_VHOST_CROSS_ENDIAN_LEGACY
 static void vhost_disable_cross_endian(struct vhost_virtqueue *vq)
-- 
2.7.4
