From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: [PATCH RFC] virtio_net: fix mergeable bufs error handling
Date: Fri, 10 Mar 2017 18:17:24 +0200
Message-ID: <1489162605-5673-1-git-send-email-mst@redhat.com>
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

On xdp error we try to free head_skb without having
initialized it, that's clearly bogus.

Fixes: f600b6905015 ("virtio_net: Add XDP support")
Cc: John Fastabend <john.fastabend@gmail.com>
Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
---

I'm cleaning up a bunch of issues in this code, thus
RFC, will test and post it all together.

 drivers/net/virtio_net.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
index 11773d6..e0fb3707 100644
--- a/drivers/net/virtio_net.c
+++ b/drivers/net/virtio_net.c
@@ -570,7 +570,7 @@ static struct sk_buff *receive_mergeable(struct net_device *dev,
 	u16 num_buf;
 	struct page *page;
 	int offset;
-	struct sk_buff *head_skb, *curr_skb;
+	struct sk_buff *head_skb = NULL, *curr_skb;
 	struct bpf_prog *xdp_prog;
 	unsigned int truesize;
 
-- 
MST
