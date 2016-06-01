From: Jason Wang <jasowang@redhat.com>
Subject: [PATCH V3 0/2] vhost_net polling optimization
Date: Wed,  1 Jun 2016 01:56:32 -0400
Message-ID: <1464760594-30326-1-git-send-email-jasowang@redhat.com>
Cc: Jason Wang <jasowang@redhat.com>
To: mst@redhat.com, kvm@vger.kernel.org,
	virtualization@lists.linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi:

This series tries to optimize vhost_net polling at two points:

- Stop rx polling for reduicng the unnecessary wakeups during
  handle_rx().
- Conditonally enable tx polling for reducing the unnecessary
  traversing and spinlock touching.

Test shows about 17% improvement on rx pps.

Please review

Changes from V2:
- Don't enable rx vq if we meet an err or rx vq is empty
Changes from V1:
- use vhost_net_disable_vq()/vhost_net_enable_vq() instead of open
  coding.
- Add a new patch for conditionally enable tx polling.

Jason Wang (2):
  vhost_net: stop polling socket during rx processing
  vhost_net: conditionally enable tx polling

 drivers/vhost/net.c | 67 ++++++++++++++++++++++++++++-------------------------
 1 file changed, 36 insertions(+), 31 deletions(-)

-- 
1.8.3.1
