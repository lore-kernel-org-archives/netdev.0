From: Cong Wang <amwang@redhat.com>
Subject: [PATCH 0/7] netpoll and netconsole fixes for 3.6
Date: Fri, 27 Jul 2012 23:37:57 +0800
Message-ID: <1343403484-29347-1-git-send-email-amwang@redhat.com>
Cc: Cong Wang <amwang@redhat.com>,
	"David S. Miller" <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:48515 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751693Ab2G0PiY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 27 Jul 2012 11:38:24 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

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

Cong Wang (7):
  netpoll: use GFP_ATOMIC in slave_enable_netpoll() and __netpoll_setup()
  netpoll: make __netpoll_cleanup non-block
  netconsole: do not release spin_lock when calling __netpoll_cleanup
  bridge: call NETDEV_RELEASE notifier in br_del_if()
  netpoll: take rcu_read_lock_bh() in netpoll_rx()
  netpoll: use netpoll_rx_on() in netpoll_rx()
  netpoll: take rcu_read_lock_bh() in netpoll_send_skb_on_dev()

 drivers/net/bonding/bond_main.c |    6 +--
 drivers/net/netconsole.c        |    5 --
 include/linux/netpoll.h         |   25 +++++++-----
 net/8021q/vlan_dev.c            |    6 +--
 net/bridge/br_device.c          |    6 +--
 net/bridge/br_if.c              |    1 +
 net/core/netpoll.c              |   78 +++++++++++++++++++++++++-------------
 7 files changed, 70 insertions(+), 57 deletions(-)

-- 
1.7.7.6
