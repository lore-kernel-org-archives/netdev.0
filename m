From: Alex Williamson <alex.williamson@hp.com>
Subject: [PATCH] virtio_net: Sync header with qemu
Date: Tue, 07 Jul 2009 08:47:10 -0600
Message-ID: <20090707144620.1269.65830.stgit@kvm.aw>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: markmc@redhat.com, qemu-devel@nongnu.org, alex.williamson@hp.com
To: netdev@vger.kernel.org, rusty@rustcorp.com.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from g5t0009.atlanta.hp.com ([15.192.0.46]:36706 "EHLO
	g5t0009.atlanta.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756236AbZGGOyE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Jul 2009 10:54:04 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Qemu added support for a few extra RX modes that Linux doesn't
currently make use of.  Sync the headers to maintain consistency.

Signed-off-by: Alex Williamson <alex.williamson@hp.com>
---

 include/linux/virtio_net.h |   14 ++++++++++----
 1 files changed, 10 insertions(+), 4 deletions(-)

diff --git a/include/linux/virtio_net.h b/include/linux/virtio_net.h
index cec79ad..9c543d6 100644
--- a/include/linux/virtio_net.h
+++ b/include/linux/virtio_net.h
@@ -27,6 +27,7 @@
 #define VIRTIO_NET_F_CTRL_VQ	17	/* Control channel available */
 #define VIRTIO_NET_F_CTRL_RX	18	/* Control channel RX mode support */
 #define VIRTIO_NET_F_CTRL_VLAN	19	/* Control channel VLAN filtering */
+#define VIRTIO_NET_F_CTRL_RX_EXTRA 20	/* Extra RX mode control support */
 
 #define VIRTIO_NET_S_LINK_UP	1	/* Link is up */
 
@@ -81,14 +82,19 @@ typedef __u8 virtio_net_ctrl_ack;
 #define VIRTIO_NET_ERR    1
 
 /*
- * Control the RX mode, ie. promisucous and allmulti.  PROMISC and
- * ALLMULTI commands require an "out" sg entry containing a 1 byte
- * state value, zero = disable, non-zero = enable.  These commands
- * are supported with the VIRTIO_NET_F_CTRL_RX feature.
+ * Control the RX mode, ie. promisucous, allmulti, etc...
+ * All commands require an "out" sg entry containing a 1 byte
+ * state value, zero = disable, non-zero = enable.  Commands
+ * 0 and 1 are supported with the VIRTIO_NET_F_CTRL_RX feature.
+ * Commands 2-5 are added with VIRTIO_NET_F_CTRL_RX_EXTRA.
  */
 #define VIRTIO_NET_CTRL_RX    0
  #define VIRTIO_NET_CTRL_RX_PROMISC      0
  #define VIRTIO_NET_CTRL_RX_ALLMULTI     1
+ #define VIRTIO_NET_CTRL_RX_ALLUNI       2
+ #define VIRTIO_NET_CTRL_RX_NOMULTI      3
+ #define VIRTIO_NET_CTRL_RX_NOUNI        4
+ #define VIRTIO_NET_CTRL_RX_NOBCAST      5
 
 /*
  * Control the MAC filter table.

