From: Jason Wang <jasowang@redhat.com>
Subject: [PATCH V2 0/2] vhost_net polling optimization
Date: Mon, 30 May 2016 02:47:52 -0400
Message-ID: <1464590874-39539-1-git-send-email-jasowang@redhat.com>
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

Changes from V1:
- use vhost_net_disable_vq()/vhost_net_enable_vq() instead of open
  coding.
- Add a new patch for conditionally enable tx polling.

Jason Wang (2):
  vhost_net: stop polling socket during rx processing
  vhost_net: conditionally enable tx polling

 drivers/vhost/net.c | 59 +++++++++++++++++++++++++++++------------------------
 1 file changed, 32 insertions(+), 27 deletions(-)

-- 
1.8.3.1
