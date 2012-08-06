From: Cong Wang <amwang@redhat.com>
Subject: [PATCH v2 0/8] some netpoll and netconsole fixes
Date: Mon,  6 Aug 2012 22:23:24 +0800
Message-ID: <1344263012-4031-1-git-send-email-amwang@redhat.com>
Cc: Cong Wang <amwang@redhat.com>,
	"David S. Miller" <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:44882 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756532Ab2HFOXo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 6 Aug 2012 10:23:44 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

V2:
* update patch 1/8 as Eric suggested
* drop the bridge patch, add comments instead
* add patch 8/8

This patch fixes serval problems in netconsole and netpoll.

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

---

Cong Wang (8):
  netpoll: use GFP_ATOMIC in slave_enable_netpoll() and __netpoll_setup()
  netpoll: make __netpoll_cleanup non-block
  netconsole: do not release spin_lock when calling __netpoll_cleanup
  netpoll: take rcu_read_lock_bh() in netpoll_rx()
  netpoll: use netpoll_rx_on() in netpoll_rx()
  netpoll: take rcu_read_lock_bh() in netpoll_send_skb_on_dev()
  bridge: add some comments for NETDEV_RELEASE
  bridge: use list_for_each_entry() in netpoll functions

 drivers/net/bonding/bond_main.c |   10 ++---
 drivers/net/netconsole.c        |    5 --
 drivers/net/team/team.c         |   16 ++++---
 include/linux/netdevice.h       |    3 +-
 include/linux/netpoll.h         |   27 +++++++------
 net/8021q/vlan_dev.c            |   13 ++----
 net/bridge/br_device.c          |   27 +++++-------
 net/bridge/br_if.c              |    6 ++-
 net/bridge/br_private.h         |    4 +-
 net/core/netpoll.c              |   84 +++++++++++++++++++++++++--------------
 10 files changed, 107 insertions(+), 88 deletions(-)

-- 
1.7.7.6
