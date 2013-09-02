From: Jason Wang <jasowang@redhat.com>
Subject: [PATCH V3 1/6] vhost_net: make vhost_zerocopy_signal_used() return
	void
Date: Mon,  2 Sep 2013 16:40:56 +0800
Message-ID: <1378111261-14826-2-git-send-email-jasowang@redhat.com>
References: <1378111261-14826-1-git-send-email-jasowang@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: mst@redhat.com, kvm@vger.kernel.org,
	virtualization@lists.linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <1378111261-14826-1-git-send-email-jasowang@redhat.com>
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

None of its caller use its return value, so let it return void.

Signed-off-by: Jason Wang <jasowang@redhat.com>
---
 drivers/vhost/net.c |    5 ++---
 1 files changed, 2 insertions(+), 3 deletions(-)

diff --git a/drivers/vhost/net.c b/drivers/vhost/net.c
index 969a859..280ee66 100644
--- a/drivers/vhost/net.c
+++ b/drivers/vhost/net.c
@@ -276,8 +276,8 @@ static void copy_iovec_hdr(const struct iovec *from, struct iovec *to,
  * of used idx. Once lower device DMA done contiguously, we will signal KVM
  * guest used idx.
  */
-static int vhost_zerocopy_signal_used(struct vhost_net *net,
-				      struct vhost_virtqueue *vq)
+static void vhost_zerocopy_signal_used(struct vhost_net *net,
+				       struct vhost_virtqueue *vq)
 {
 	struct vhost_net_virtqueue *nvq =
 		container_of(vq, struct vhost_net_virtqueue, vq);
@@ -297,7 +297,6 @@ static int vhost_zerocopy_signal_used(struct vhost_net *net,
 	}
 	if (j)
 		nvq->done_idx = i;
-	return j;
 }
 
 static void vhost_zerocopy_callback(struct ubuf_info *ubuf, bool success)
-- 
1.7.1
