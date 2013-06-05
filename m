From: Jason Wang <jasowang@redhat.com>
Subject: [net-next rfc V3 9/9] macvtap: enable multiqueue flag
Date: Wed,  5 Jun 2013 14:36:32 +0800
Message-ID: <1370414192-5830-10-git-send-email-jasowang@redhat.com>
References: <1370414192-5830-1-git-send-email-jasowang@redhat.com>
Cc: sergei.shtylyov@cogentembedded.com,
	Jason Wang <jasowang@redhat.com>
To: davem@davemloft.net, mst@redhat.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1370414192-5830-1-git-send-email-jasowang@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

To notify the userspace about our capability of multiqueue.

Signed-off-by: Jason Wang <jasowang@redhat.com>
---
 drivers/net/macvtap.c |    7 ++-----
 1 files changed, 2 insertions(+), 5 deletions(-)

diff --git a/drivers/net/macvtap.c b/drivers/net/macvtap.c
index 355e6ad..b907aee 100644
--- a/drivers/net/macvtap.c
+++ b/drivers/net/macvtap.c
@@ -31,10 +31,6 @@
  * macvtap_proto is used to allocate queues through the sock allocation
  * mechanism.
  *
- * TODO: multiqueue support is currently not implemented, even though
- * macvtap is basically prepared for that. We will need to add this
- * here as well as in virtio-net and qemu to get line rate on 10gbit
- * adapters from a guest.
  */
 struct macvtap_queue {
 	struct sock sk;
@@ -1062,7 +1058,8 @@ static long macvtap_ioctl(struct file *file, unsigned int cmd,
 		return macvtap_ioctl_set_queue(file, u);
 
 	case TUNGETFEATURES:
-		if (put_user(IFF_TAP | IFF_NO_PI | IFF_VNET_HDR, up))
+		if (put_user(IFF_TAP | IFF_NO_PI | IFF_VNET_HDR |
+			     IFF_MULTI_QUEUE, up))
 			return -EFAULT;
 		return 0;
 
-- 
1.7.1
