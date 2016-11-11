From: Tobias Klauser <tklauser@distanz.ch>
Subject: [PATCH] vhost/vsock: Remove unused but set variable
Date: Fri, 11 Nov 2016 14:26:31 +0100
Message-ID: <20161111132631.25708-1-tklauser@distanz.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: kvm@vger.kernel.org, virtualization@lists.linux-foundation.org,
        netdev@vger.kernel.org
To: Stefan Hajnoczi <stefanha@redhat.com>,
        "Michael S. Tsirkin" <mst@redhat.com>,
        Jason Wang <jasowang@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.zhinst.com ([212.126.164.98]:56806 "EHLO mail.zhinst.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1756358AbcKKN0m (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 11 Nov 2016 08:26:42 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Remove the unused but set variable vq in vhost_transport_send_pkt() to
fix the following GCC warning when building with 'W=1':

  drivers/vhost/vsock.c:198:26: warning: variable ‘vq’ set but not used

Signed-off-by: Tobias Klauser <tklauser@distanz.ch>
---
 drivers/vhost/vsock.c | 3 ---
 1 file changed, 3 deletions(-)

diff --git a/drivers/vhost/vsock.c b/drivers/vhost/vsock.c
index e3b30ea9ece5..9c3c68b9a49e 100644
--- a/drivers/vhost/vsock.c
+++ b/drivers/vhost/vsock.c
@@ -195,7 +195,6 @@ static int
 vhost_transport_send_pkt(struct virtio_vsock_pkt *pkt)
 {
 	struct vhost_vsock *vsock;
-	struct vhost_virtqueue *vq;
 	int len = pkt->len;
 
 	/* Find the vhost_vsock according to guest context id  */
@@ -205,8 +204,6 @@ vhost_transport_send_pkt(struct virtio_vsock_pkt *pkt)
 		return -ENODEV;
 	}
 
-	vq = &vsock->vqs[VSOCK_VQ_RX];
-
 	if (pkt->reply)
 		atomic_inc(&vsock->queued_replies);
 
-- 
2.11.0.rc0.7.gbe5a750
