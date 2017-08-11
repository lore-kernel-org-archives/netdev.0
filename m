From: Jason Wang <jasowang@redhat.com>
Subject: [PATCH net-next V2 0/3] XDP support for tap
Date: Fri, 11 Aug 2017 19:41:15 +0800
Message-ID: <1502451678-17358-1-git-send-email-jasowang@redhat.com>
Cc: kubakici@wp.pl, Jason Wang <jasowang@redhat.com>
To: davem@davemloft.net, mst@redhat.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi all:

This series tries to implement XDP support for tap. Two path were
implemented:

- fast path: small & non-gso packet, For performance reason we do it
  at page level and use build_skb() to create skb if necessary.
- slow path: big or gso packet, we don't want to lose the capability
  compared to generic XDP, so we export some generic xdp helpers and
  do it after skb was created.

xdp1 shows about 41% improvement, xdp_redirect shows about 60%
improvement.

Changes from V1:
- fix the race between xdp set and free
- don't hold extra refcount
- add XDP_REDIRECT support

Please review.

Jason Wang (3):
  tap: use build_skb() for small packet
  net: export some generic xdp helpers
  tap: XDP support

 drivers/net/tun.c         | 247 ++++++++++++++++++++++++++++++++++++++++++----
 include/linux/netdevice.h |   2 +
 net/core/dev.c            |  14 +--
 3 files changed, 236 insertions(+), 27 deletions(-)

-- 
2.7.4
