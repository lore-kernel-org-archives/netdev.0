From: David Miller <davem@davemloft.net>
Subject: [GIT] Networking
Date: Sun, 25 Mar 2012 17:51:51 -0400 (EDT)
Message-ID: <20120325.175151.853542033329072696.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


1) Name string overrun fix in gianfar driver from Joe Perches.

2) VHOST bug fixes from Michael S. Tsirkin and Nadav Har'El

3) Fix dependencies on xt_LOG netfilter module, from Pablo Neira
   Ayuso.

4) Fix RCU locking in xt_CT, also from Pablo Neira Ayuso.

4) Add a parameter to skb_add_rx_frag() so we can fix the truesize
   adjustments in the drivers that use it.  The individual drivers
   aren't fixed by this commit, but will be dealt with using follow-on
   commits.  From Eric Dumazet.

5) Add some device IDs to qmi_wwan driver, from Andrew Bird.

Please pull, thanks a lot!

The following changes since commit e22057c8599373e5caef0bc42bdb95d2a361ab0d:

  Merge tag 'stable/for-linus-3.4-tag-two' of git://git.kernel.org/pub/scm/linux/kernel/git/konrad/xen (2012-03-24 12:20:25 -0700)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/davem/net.git master

Andrew Bird (Sphere Systems) (3):
      USB: qmi_wwan: Add ZTE (Vodafone) K3565-Z and K4505-Z net interfaces
      USB: option: Ignore ZTE (Vodafone) K3570/71 net interfaces
      USB: qmi_wwan: Add ZTE (Vodafone) K3570-Z and K3571-Z net interfaces

Anirban Chakraborty (1):
      qlcnic: Bug fix for LRO

David S. Miller (2):
      Merge branch 'master' of git://1984.lsi.us.es/net
      Merge branch 'vhost-net' of git://git.kernel.org/.../mst/vhost

Eric Dumazet (1):
      net: add a truesize parameter to skb_add_rx_frag()

Joe Perches (1):
      gianfar: Fix possible overrun and simplify interrupt name field creation

Michael S. Tsirkin (4):
      tools/virtio: add linux/module.h stub
      tools/virtio: add linux/hrtimer.h stub
      tools/virtio: stub out strong barriers
      vhost: fix release path lockdep checks

Nadav Har'El (1):
      vhost: don't forget to schedule()

Pablo Neira Ayuso (5):
      netfilter: xt_LOG: use CONFIG_IP6_NF_IPTABLES instead of CONFIG_IPV6
      netfilter: cttimeout: fix dependency with l4protocol conntrack module
      netfilter: xt_CT: missing rcu_read_lock section in timeout assignment
      netfilter: xt_CT: fix assignation of the generic protocol tracker
      netfilter: nf_conntrack: permanently attach timeout policy to conntrack

 drivers/net/ethernet/freescale/gianfar.c         |   39 +++---------------
 drivers/net/ethernet/freescale/gianfar.h         |    2 +-
 drivers/net/ethernet/qlogic/qlcnic/qlcnic.h      |    4 +-
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c |    4 +-
 drivers/net/usb/cdc-phonet.c                     |    6 ++-
 drivers/net/usb/qmi_wwan.c                       |   36 +++++++++++++++++
 drivers/net/wireless/iwlegacy/3945.c             |    3 +-
 drivers/net/wireless/iwlegacy/4965-mac.c         |    3 +-
 drivers/net/wireless/iwlwifi/iwl-agn-rx.c        |    2 +-
 drivers/usb/gadget/f_phonet.c                    |    2 +-
 drivers/usb/serial/option.c                      |    6 ++-
 drivers/vhost/net.c                              |    2 +-
 drivers/vhost/vhost.c                            |   11 +++--
 drivers/vhost/vhost.h                            |    2 +-
 include/linux/skbuff.h                           |    2 +-
 include/net/netfilter/nf_conntrack_l4proto.h     |    4 ++
 include/net/netfilter/nf_conntrack_timeout.h     |    2 +-
 net/core/skbuff.c                                |    4 +-
 net/netfilter/nf_conntrack_core.c                |   39 +++++++++++--------
 net/netfilter/nf_conntrack_proto.c               |   21 ++++++++++
 net/netfilter/nfnetlink_cttimeout.c              |   45 +++++++++++-----------
 net/netfilter/xt_CT.c                            |   31 +++++++++++----
 net/netfilter/xt_LOG.c                           |   12 +++---
 tools/virtio/linux/virtio.h                      |    3 +
 24 files changed, 178 insertions(+), 107 deletions(-)
 create mode 100644 tools/virtio/linux/hrtimer.h
 create mode 100644 tools/virtio/linux/module.h
