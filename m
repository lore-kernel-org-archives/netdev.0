From: Jason Wang <jasowang@redhat.com>
Subject: [PATCH net-next V2 1/5] virtio_ring: allow to store zero as the ctx
Date: Wed, 19 Jul 2017 16:54:45 +0800
Message-ID: <1500454489-16805-2-git-send-email-jasowang@redhat.com>
References: <1500454489-16805-1-git-send-email-jasowang@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: mst@redhat.com, virtualization@lists.linux-foundation.org,
	jasowang@redhat.com, netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <1500454489-16805-1-git-send-email-jasowang@redhat.com>
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

Allow zero to be store as a ctx, with this we could store e.g zero
value which could be meaningful for the case of storing headroom
through ctx.

Signed-off-by: Jason Wang <jasowang@redhat.com>
---
 drivers/virtio/virtio_ring.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/virtio/virtio_ring.c b/drivers/virtio/virtio_ring.c
index 5e1b548..9aaa177 100644
--- a/drivers/virtio/virtio_ring.c
+++ b/drivers/virtio/virtio_ring.c
@@ -391,7 +391,7 @@ static inline int virtqueue_add(struct virtqueue *_vq,
 	vq->desc_state[head].data = data;
 	if (indirect)
 		vq->desc_state[head].indir_desc = desc;
-	if (ctx)
+	else
 		vq->desc_state[head].indir_desc = ctx;
 
 	/* Put entry in available array (but don't update avail->idx until they
-- 
2.7.4
