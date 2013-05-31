From: Jason Wang <jasowang@redhat.com>
Subject: [net-next rfc V2 8/8] macvtap: enable multiqueue flag
Date: Fri, 31 May 2013 17:53:25 +0800
Message-ID: <1369994005-5943-9-git-send-email-jasowang@redhat.com>
References: <1369994005-5943-1-git-send-email-jasowang@redhat.com>
Cc: Jason Wang <jasowang@redhat.com>
To: davem@davemloft.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, mst@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:26080 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754449Ab3EaKEQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 31 May 2013 06:04:16 -0400
In-Reply-To: <1369994005-5943-1-git-send-email-jasowang@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Jason Wang <jasowang@redhat.com>
---
 drivers/net/macvtap.c |    7 ++-----
 1 files changed, 2 insertions(+), 5 deletions(-)

diff --git a/drivers/net/macvtap.c b/drivers/net/macvtap.c
index 03b781c..fac9dbf 100644
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
@@ -1097,7 +1093,8 @@ static long macvtap_ioctl(struct file *file, unsigned int cmd,
 		return macvtap_ioctl_set_queue(file, u);
 
 	case TUNGETFEATURES:
-		if (put_user(IFF_TAP | IFF_NO_PI | IFF_VNET_HDR, up))
+		if (put_user(IFF_TAP | IFF_NO_PI | IFF_VNET_HDR |
+			     IFF_MULTI_QUEUE, up))
 			return -EFAULT;
 		return 0;
 
-- 
1.7.1
