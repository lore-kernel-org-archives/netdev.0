From: Stephen Hemminger <stephen@networkplumber.org>
Subject: [PATCH] virtio: don't expose u16 in userspace api
Date: Fri, 3 May 2013 17:49:41 -0700
Message-ID: <20130503174941.043d10b7@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Amos Kong <akong@redhat.com>
To: David Miller <davem@davemloft.net>,
	Jason Wang <jasowang@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Programs using virtio headers outside of kernel will no longer
build because u16 type does not exist in userspace. All user ABI
must use __u16 typedef instead.

Bug introduce by:
  commit 986a4f4d452dec004697f667439d27c3fda9c928
  Author: Jason Wang <jasowang@redhat.com>
  Date:   Fri Dec 7 07:04:56 2012 +0000

    virtio_net: multiqueue support

Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>

---
Patch against -net but should go to stable for 3.9.1

--- a/include/uapi/linux/virtio_net.h	2013-05-02 14:30:53.362557982 -0700
+++ b/include/uapi/linux/virtio_net.h	2013-05-03 17:44:06.028365521 -0700
@@ -191,7 +191,7 @@ struct virtio_net_ctrl_mac {
  * specified.
  */
 struct virtio_net_ctrl_mq {
-	u16 virtqueue_pairs;
+	__u16 virtqueue_pairs;
 };
 
 #define VIRTIO_NET_CTRL_MQ   4
