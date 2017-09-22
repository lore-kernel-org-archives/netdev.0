From: Jason Wang <jasowang@redhat.com>
Subject: [PATCH net-next RFC 0/5] batched tx processing in vhost_net
Date: Fri, 22 Sep 2017 16:02:30 +0800
Message-ID: <1506067355-5771-1-git-send-email-jasowang@redhat.com>
Cc: kvm@vger.kernel.org
To: mst@redhat.com, jasowang@redhat.com,
        virtualization@lists.linux-foundation.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi:

This series tries to implement basic tx batched processing. This is
done by prefetching descriptor indices and update used ring in a
batch. This intends to speed up used ring updating and improve the
cache utilization. Test shows about ~22% improvement in tx pss.

Please review.

Jason Wang (5):
  vhost: split out ring head fetching logic
  vhost: introduce helper to prefetch desc index
  vhost: introduce vhost_add_used_idx()
  vhost_net: rename VHOST_RX_BATCH to VHOST_NET_BATCH
  vhost_net: basic tx virtqueue batched processing

 drivers/vhost/net.c   | 221 ++++++++++++++++++++++++++++----------------------
 drivers/vhost/vhost.c | 165 +++++++++++++++++++++++++++++++------
 drivers/vhost/vhost.h |   9 ++
 3 files changed, 270 insertions(+), 125 deletions(-)

-- 
2.7.4
