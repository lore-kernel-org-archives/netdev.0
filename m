From: Jason Wang <jasowang@redhat.com>
Subject: [PATCH V2 net-next 0/7] vhost-net rx batching
Date: Thu, 30 Mar 2017 15:22:23 +0800
Message-ID: <1490858550-7763-1-git-send-email-jasowang@redhat.com>
Cc: mst@redhat.com, Jason Wang <jasowang@redhat.com>
To: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi all:

This series tries to implement rx batching for vhost-net. This is done
by batching the dequeuing from skb_array which was exported by
underlayer socket and pass the sbk back through msg_control to finish
userspace copying.

Tests shows at most 19% improvment on rx pps.

Please review.

Thanks

Changes from V1:
- switch to use for() in __ptr_ring_consume_batched()
- rename peek_head_len_batched() to fetch_skbs()
- use skb_array_consume_batched() instead of
  skb_array_consume_batched_bh() since no consumer run in bh
- drop the lockless peeking patch since skb_array could be resized, so
  it's not safe to call lockless one

Jason Wang (7):
  ptr_ring: introduce batch dequeuing
  skb_array: introduce batch dequeuing
  tun: export skb_array
  tap: export skb_array
  tun: support receiving skb through msg_control
  tap: support receiving skb from msg_control
  vhost_net: try batch dequing from skb array

 drivers/net/tap.c         | 25 +++++++++++++++---
 drivers/net/tun.c         | 31 ++++++++++++++++------
 drivers/vhost/net.c       | 64 +++++++++++++++++++++++++++++++++++++++++++---
 include/linux/if_tap.h    |  5 ++++
 include/linux/if_tun.h    |  5 ++++
 include/linux/ptr_ring.h  | 65 +++++++++++++++++++++++++++++++++++++++++++++++
 include/linux/skb_array.h | 25 ++++++++++++++++++
 7 files changed, 204 insertions(+), 16 deletions(-)

-- 
2.7.4
