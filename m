From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: [PATCH net-next] virtio_net: don't reset twice on XDP on/off
Date: Wed, 29 Mar 2017 23:14:38 +0300
Message-ID: <1490818456-6861-1-git-send-email-mst@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, John Fastabend <john.fastabend@gmail.com>,
	virtualization@lists.linux-foundation.org
To: linux-kernel@vger.kernel.org
Return-path: <virtualization-bounces@lists.linux-foundation.org>
Content-Disposition: inline
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

We already do a reset once in remove_vq_common -
there appears to be no point in doing another one
when we add/remove XDP.

Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
---
 drivers/net/virtio_net.c | 1 -
 1 file changed, 1 deletion(-)

diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
index de42e9a..ed8f548 100644
--- a/drivers/net/virtio_net.c
+++ b/drivers/net/virtio_net.c
@@ -1810,7 +1810,6 @@ static int virtnet_reset(struct virtnet_info *vi, int curr_qp, int xdp_qp)
 	virtnet_freeze_down(dev);
 	_remove_vq_common(vi);
 
-	dev->config->reset(dev);
 	virtio_add_status(dev, VIRTIO_CONFIG_S_ACKNOWLEDGE);
 	virtio_add_status(dev, VIRTIO_CONFIG_S_DRIVER);
 
-- 
MST
