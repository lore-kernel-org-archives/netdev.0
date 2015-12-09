From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: [patch -next] VSOCK: signedness bug in
 virtio_transport_dgram_enqueue()
Date: Wed, 9 Dec 2015 13:27:13 +0300
Message-ID: <20151209102713.GG3173@mwanda>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ray Jui <rjui@broadcom.com>, Scott Branden <sbranden@broadcom.com>,
	Jon Mason <jonmason@broadcom.com>,
	Stefan Hajnoczi <stefanha@redhat.com>, netdev@vger.kernel.org,
	bcm-kernel-feedback-list@broadcom.com,
	kernel-janitors@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>,
	Asias He <asias@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:19076 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754206AbbLIK10 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Dec 2015 05:27:26 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

"written" has to be signed for the error handling to work.
trans->ops->send_pkt() returns an int so that's fine.

Fixes: 80a19e338d45 ('VSOCK: Introduce virtio-vsock-common.ko')
Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

diff --git a/net/vmw_vsock/virtio_transport_common.c b/net/vmw_vsock/virtio_transport_common.c
index 28f790d..d9a2325 100644
--- a/net/vmw_vsock/virtio_transport_common.c
+++ b/net/vmw_vsock/virtio_transport_common.c
@@ -815,7 +815,8 @@ virtio_transport_dgram_enqueue(struct vsock_sock *vsk,
 		.type = VIRTIO_VSOCK_TYPE_DGRAM,
 		.msg = msg,
 	};
-	size_t total_written = 0, pkt_off = 0, written;
+	size_t total_written = 0, pkt_off = 0;
+	int written;
 	u16 dgram_id;
 
 	/* The max size of a single dgram we support is 64KB */
@@ -845,7 +846,7 @@ virtio_transport_dgram_enqueue(struct vsock_sock *vsk,
 		}
 		total_written += written;
 		pkt_off += written;
-		pr_debug("%s:id=%d, dgram_len=%zu, off=%zu, total_written=%zu, written=%zu\n",
+		pr_debug("%s:id=%d, dgram_len=%zu, off=%zu, total_written=%zu, written=%d\n",
 			  __func__, dgram_id, dgram_len, pkt_off, total_written, written);
 	}
 
