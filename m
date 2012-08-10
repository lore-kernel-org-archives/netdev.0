From: Cong Wang <amwang@redhat.com>
Subject: [PATCH v4 00/14] some netpoll and netconsole fixes
Date: Fri, 10 Aug 2012 15:10:23 +0800
Message-ID: <1344582637-18261-1-git-send-email-amwang@redhat.com>
Cc: "David S. Miller" <davem@davemloft.net>,
	Cong Wang <amwang@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:56205 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751831Ab2HJHKy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 10 Aug 2012 03:10:54 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

V4:
* rebase against net tree
* fix a compile error in patch 9
* update patch 7 as Stephen suggested

V3:
* add more patches
* update patch 7 as David suggested

V2:
* update patch 1/8 as Eric suggested
* drop the bridge patch, add comments instead
* add patch 8/8

This patchset fixes serval problems in netconsole and netpoll.

I ran this patch in my KVM guest with some netpoll test cases,
even covered with some corner cases, everything worked as expected.

BTW, my kernel config enables the following validatation options:

CONFIG_DEBUG_ATOMIC_SLEEP=y
CONFIG_PROVE_LOCKING=y
CONFIG_PROVE_RCU=y
CONFIG_LOCKDEP=y
CONFIG_RCU_CPU_STALL_TIMEOUT=60
CONFIG_LOCKUP_DETECTOR=y
CONFIG_HARDLOCKUP_DETECTOR=y

Cc: "David S. Miller" <davem@davemloft.net>
Signed-off-by: Cong Wang <amwang@redhat.com>

--------

 netpoll: use GFP_ATOMIC in slave_enable_netpoll() and
 netpoll: make __netpoll_cleanup non-block
 netconsole: do not release spin_lock when calling
 netpoll: take rcu_read_lock_bh() in netpoll_rx()
 netpoll: use netpoll_rx_on() in netpoll_rx()
 netpoll: take rcu_read_lock_bh() in
 bridge: add some comments for NETDEV_RELEASE
 bridge: use list_for_each_entry() in netpoll functions
 netpoll: check netpoll tx status on the right device
 netpoll: convert several functions to bool
 vlan: clean up vlan_dev_hard_start_xmit()
 netpoll: handle vlan tags in netpoll tx and rx path
 netpoll: re-enable irq in poll_napi()
 netconsole.txt: revision of examples for the receiver

 Documentation/networking/netconsole.txt |   19 +++++-
 drivers/net/bonding/bond_main.c         |   12 ++--
 drivers/net/netconsole.c                |    5 --
 drivers/net/team/team.c                 |   16 +++--
 include/linux/if_team.h                 |   30 ++++----
 include/linux/netdevice.h               |    3 +-
 include/linux/netpoll.h                 |   42 +++++++-----
 net/8021q/vlan_dev.c                    |   40 +++++++----
 net/bridge/br_device.c                  |   27 +++-----
 net/bridge/br_forward.c                 |    2 +-
 net/bridge/br_if.c                      |    6 ++-
 net/bridge/br_private.h                 |    4 +-
 net/core/netpoll.c                      |  109 ++++++++++++++++++++++---------
 13 files changed, 194 insertions(+), 121 deletions(-)
