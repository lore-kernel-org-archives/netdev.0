From: Paolo Abeni <pabeni@redhat.com>
Subject: [PATCH net-next] virtio_net: replace netdev_alloc_skb_ip_align() with
	napi_alloc_skb()
Date: Thu, 17 Mar 2016 15:44:00 +0100
Message-ID: <b436c3eb5d4c19e92184c27d89ec8118d6fd3f81.1458224603.git.pabeni@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: virtualization@lists.linux-foundation.org,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	"Michael S. Tsirkin" <mst@redhat.com>
To: netdev@vger.kernel.org
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

This gives small but noticeable rx performance improvement (2-3%)
and will allow exploiting future napi improvement.

Signed-off-by: Paolo Abeni <pabeni@redhat.com>
---
 drivers/net/virtio_net.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
index fb0eae4..49d84e5 100644
--- a/drivers/net/virtio_net.c
+++ b/drivers/net/virtio_net.c
@@ -260,7 +260,7 @@ static struct sk_buff *page_to_skb(struct virtnet_info *vi,
 	p = page_address(page) + offset;
 
 	/* copy small packet so we can reuse these pages for small data */
-	skb = netdev_alloc_skb_ip_align(vi->dev, GOOD_COPY_LEN);
+	skb = napi_alloc_skb(&rq->napi, GOOD_COPY_LEN);
 	if (unlikely(!skb))
 		return NULL;
 
-- 
1.8.3.1
