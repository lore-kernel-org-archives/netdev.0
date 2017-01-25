From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: [PATCH net resend] virtio_net: reject XDP programs using header adjustment
Date: Wed, 25 Jan 2017 14:56:36 -0800
Message-ID: <20170125225636.167620-1-jakub.kicinski@netronome.com>
References: <5888C9B7.8040603@gmail.com>
Cc: Jason Wang <jasowang@redhat.com>,
        David Miller <davem@davemloft.net>,
        John Fastabend <john.r.fastabend@intel.com>,
        Daniel Borkmann <daniel@iogearbox.net>,
        oss-drivers@netronome.com,
        Jakub Kicinski <jakub.kicinski@netronome.com>
To: netdev@vger.kernel.org, john.fastabend@gmail.com,
        "Michael S . Tsirkin" <mst@redhat.com>,
        Alexei Starovoitov <alexei.starovoitov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f173.google.com ([209.85.192.173]:34138 "EHLO
        mail-pf0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752382AbdAYW5x (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 25 Jan 2017 17:57:53 -0500
Received: by mail-pf0-f173.google.com with SMTP id e4so61043070pfg.1
        for <netdev@vger.kernel.org>; Wed, 25 Jan 2017 14:57:53 -0800 (PST)
In-Reply-To: <5888C9B7.8040603@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

commit 17bedab27231 ("bpf: xdp: Allow head adjustment in XDP prog")
added a new XDP helper to prepend and remove data from a frame.
Make virtio_net reject programs making use of this helper until
proper support is added.

Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
Acked-by: John Fastabend <john.r.fastabend@intel.com>
---
 drivers/net/virtio_net.c | 5 +++++
 1 file changed, 5 insertions(+)

diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
index f9bf94887ff1..a2aac4fd8e42 100644
--- a/drivers/net/virtio_net.c
+++ b/drivers/net/virtio_net.c
@@ -1710,6 +1710,11 @@ static int virtnet_xdp_set(struct net_device *dev, struct bpf_prog *prog)
 	u16 xdp_qp = 0, curr_qp;
 	int i, err;
 
+	if (prog && prog->xdp_adjust_head) {
+		netdev_warn(dev, "Does not support bpf_xdp_adjust_head()\n");
+		return -EOPNOTSUPP;
+	}
+
 	if (virtio_has_feature(vi->vdev, VIRTIO_NET_F_GUEST_TSO4) ||
 	    virtio_has_feature(vi->vdev, VIRTIO_NET_F_GUEST_TSO6) ||
 	    virtio_has_feature(vi->vdev, VIRTIO_NET_F_GUEST_ECN) ||
-- 
2.11.0
