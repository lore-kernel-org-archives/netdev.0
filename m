From: Dave Wiltshire <david.wiltshire@gmx.com>
Subject: [PATCH 0/3] skbuff: pskb_expand_head changes
Date: Wed, 12 Jun 2013 19:05:31 +1000
Message-ID: <1371027934-1955-1-git-send-email-david.wiltshire@gmx.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	nsujir@broadcom.com, mchan@broadcom.com, rmody@brocade.com,
	jcliburn@gmail.com, chris.snook@gmail.com,
	jeffrey.t.kirsher@intel.com, bruce.w.allan@intel.com,
	alexander.h.duyck@intel.com, cooldavid@cooldavid.org,
	linux-driver@qlogic.com, linux-wimax@intel.com,
	wimax@linuxwimax.org, linux-wireless@vger.kernel.org,
	viro@zeniv.linux.org.uk, eparis@redhat.com, edumazet@google.com,
	dev@openvswitch.org, jhs@mojatatu.com,
	Dave Wiltshire <david.wiltshire@gmx.com>
To: davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patchset applies against David Miller's net-next tree.

This is my first patch, so please let me know if I've done something
wrong or could do something better (e.g. splitting the patch in a
different way).

I think there is a problem with memory accounting in pskb_expand_head.
Some call sites update truesize while others don't. This means that the
skbuff can change in size without truesize being updated. This seems
incorrect to me. So I changed it. Perhaps I don't understand something,
but I thought it best to generate the change and then ask. So is this
correct?

The other patches are from looking at all the call sites to
pskb_expand_head and since I was doing that I cleaned some of them up.

Dave Wiltshire (3):
  skbuff: Update truesize in pskb_expand_head
  skbuff: skb_cow_head not used in some drivers.
  skbuff: Added new helper function skb_cow_clone_head.

 drivers/net/ethernet/atheros/atl1c/atl1c_main.c   |    8 ++------
 drivers/net/ethernet/atheros/atl1e/atl1e_main.c   |    8 ++------
 drivers/net/ethernet/atheros/atlx/atl1.c          |    8 ++------
 drivers/net/ethernet/broadcom/tg3.c               |    3 +--
 drivers/net/ethernet/brocade/bna/bnad.c           |   11 +++--------
 drivers/net/ethernet/intel/e1000/e1000_main.c     |    8 ++------
 drivers/net/ethernet/intel/e1000e/netdev.c        |    8 ++------
 drivers/net/ethernet/intel/igb/igb_main.c         |    7 ++-----
 drivers/net/ethernet/intel/igbvf/netdev.c         |   11 +++--------
 drivers/net/ethernet/intel/ixgb/ixgb_main.c       |    8 ++------
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c     |   10 +++-------
 drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c |    7 ++-----
 drivers/net/ethernet/jme.c                        |    3 +--
 drivers/net/ethernet/qlogic/qlge/qlge_main.c      |    8 ++------
 drivers/net/wimax/i2400m/netdev.c                 |    3 +--
 drivers/net/wireless/mwl8k.c                      |    1 -
 include/linux/skbuff.h                            |   14 +++++++++++++
 kernel/audit.c                                    |    2 --
 net/core/dev.c                                    |    8 ++------
 net/core/skbuff.c                                 |    1 +
 net/netlink/af_netlink.c                          |    3 +--
 net/openvswitch/actions.c                         |   22 +++++++--------------
 net/sched/act_csum.c                              |    8 ++------
 net/sched/act_nat.c                               |   18 +++++------------
 net/wireless/util.c                               |    2 --
 25 files changed, 62 insertions(+), 128 deletions(-)

-- 
1.7.10.4
