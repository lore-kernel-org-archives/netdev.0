From: Jason Wang <jasowang@redhat.com>
Subject: [net-next PATCH 1/2] virtio-net: initialize vlan_features
Date: Thu, 11 Apr 2013 17:32:21 +0800
Message-ID: <1365672742-42258-2-git-send-email-jasowang@redhat.com>
References: <1365672742-42258-1-git-send-email-jasowang@redhat.com>
Cc: Jason Wang <jasowang@redhat.com>,
	Rusty Russell <rusty@rustcorp.com.au>
To: davem@davemloft.net, mst@redhat.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1365672742-42258-1-git-send-email-jasowang@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

There's nothing that prevent passing the device features of virtio_net to its
vlan device. So this patch simply passes those to vlan device to benefit from
advanced features.

Netperf shows better sending performance for vlan device since TSO can work on
vlan now.

before:
netperf -H 192.168.5.2
MIGRATED TCP STREAM TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to 192.168.5.2 ()
port 0 AF_INET : demo
Recv   Send    Send
Socket Socket  Message  Elapsed
Size   Size    Size     Time     Throughput
bytes  bytes   bytes    secs.    10^6bits/sec

 87380  16384  16384    10.00    4162.35

after:
netperf -H 192.168.5.2
MIGRATED TCP STREAM TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to 192.168.5.2 ()
port 0 AF_INET : demo
Recv   Send    Send
Socket Socket  Message  Elapsed
Size   Size    Size     Time     Throughput
bytes  bytes   bytes    secs.    10^6bits/sec

 87380  16384  16384    10.00    9365.42

Cc: Rusty Russell <rusty@rustcorp.com.au>
Cc: "Michael S. Tsirkin" <mst@redhat.com>
Signed-off-by: Jason Wang <jasowang@redhat.com>
---
 drivers/net/virtio_net.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
index f7d67e8..8fdfde6 100644
--- a/drivers/net/virtio_net.c
+++ b/drivers/net/virtio_net.c
@@ -1511,6 +1511,8 @@ static int virtnet_probe(struct virtio_device *vdev)
 		/* (!csum && gso) case will be fixed by register_netdev() */
 	}
 
+	dev->vlan_features = dev->features;
+
 	/* Configuration may specify what MAC to use.  Otherwise random. */
 	if (virtio_config_val_len(vdev, VIRTIO_NET_F_MAC,
 				  offsetof(struct virtio_net_config, mac),
-- 
1.7.1
