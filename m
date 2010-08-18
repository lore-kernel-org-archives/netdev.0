From: David Miller <davem@davemloft.net>
Subject: [GIT] Networking
Date: Tue, 17 Aug 2010 18:08:58 -0700 (PDT)
Message-ID: <20100817.180858.189708416.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37894
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752489Ab0HRBIk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Aug 2010 21:08:40 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Several bug fixes:

1) Revert netlink_recvmsg() fix, it breaks more than it fixes.
   Based upon analysis by Johannes Berg and Eric Dumazet.

2) dev_gro_receive() does memmove() with wrong size argument,
   fix from Jarek Poplawski.

3) xfrm_compile_policy() needs to use GFP_ATOMIC, from Herbert Xu.

4) Some of the classful qdisc code leaks an uninitialized 32-bit
   kernel stack word to userspace, use explicit initializers to
   fix this.  From Eric Dumazet.

5) pm_qos registry ordering fix in ipw2100 from John W. Linville

6) ASPM L0s needs to be disabled for all ath5k cards, from Maxim
   Levitsky.

7) Fix lockdep false positive in netfilter, from Eric Dumazet.

8) ipv6 does bogus jiffies conversions on non-jiffy sysctls, fix from
   Min Zhang.

9) ath9k disconnect fix from Vivek Natarajan.

10) Trigger scan timeout fix in wl1251 from Yuri Kululin.

11) Crash and firmware fixes to ath9k from Rajkumar Manoharan.

Please pull, thanks a lot!

The following changes since commit da5cabf80e2433131bf0ed8993abc0f7ea618c73:

  Linux 2.6.36-rc1 (2010-08-15 17:41:37 -0700)

are available in the git repository at:
  master.kernel.org:/pub/scm/linux/kernel/git/davem/net-2.6.git master

David S. Miller (2):
      Revert "netlink: netlink_recvmsg() fix"
      Merge branch 'master' of git://git.kernel.org/.../linville/wireless-2.6

Eric Dumazet (2):
      netfilter: {ip,ip6,arp}_tables: avoid lockdep false positive
      net sched: fix some kernel memory leaks

Herbert Xu (1):
      xfrm: Use GFP_ATOMIC in xfrm_compile_policy

Jarek Poplawski (1):
      net: Fix a memmove bug in dev_gro_receive()

John W. Linville (1):
      ipw2100: register pm_qos request before registering pci driver

Maxim Levitsky (1):
      ath5k: disable ASPM L0s for all cards

Min Zhang (1):
      ipv6: remove sysctl jiffies conversion on gc_elasticity and min_adv_mss

Rajkumar Manoharan (2):
      ath9k_htc: fix panic on packet injection using airbase-ng tool.
      ath9k_htc: load proper firmware for device ID 7015

Vivek Natarajan (1):
      ath9k_htc: Fix disconnect issue in HT40 mode.

Yuri Kululin (1):
      wl1251: fix trigger scan timeout usage

 drivers/net/wireless/ath/ath5k/base.c         |   21 +++++++++++++++++++++
 drivers/net/wireless/ath/ath9k/eeprom.h       |    1 +
 drivers/net/wireless/ath/ath9k/eeprom_9287.c  |    7 ++++++-
 drivers/net/wireless/ath/ath9k/hif_usb.c      |    8 ++------
 drivers/net/wireless/ath/ath9k/htc_drv_init.c |    1 +
 drivers/net/wireless/ath/ath9k/htc_drv_main.c |    3 ++-
 drivers/net/wireless/ath/ath9k/htc_drv_txrx.c |   15 ++++++++++-----
 drivers/net/wireless/ath/ath9k/reg.h          |    1 +
 drivers/net/wireless/ipw2x00/ipw2100.c        |    5 +++--
 drivers/net/wireless/wl12xx/wl1251_cmd.c      |    2 +-
 net/core/dev.c                                |    2 +-
 net/ipv4/netfilter/arp_tables.c               |    2 ++
 net/ipv4/netfilter/ip_tables.c                |    2 ++
 net/ipv6/netfilter/ip6_tables.c               |    2 ++
 net/ipv6/route.c                              |    4 ++--
 net/netlink/af_netlink.c                      |   22 ++++++----------------
 net/sched/act_gact.c                          |   21 ++++++++++++---------
 net/sched/act_mirred.c                        |   15 ++++++++-------
 net/sched/act_nat.c                           |   22 +++++++++++-----------
 net/sched/act_simple.c                        |   11 ++++++-----
 net/sched/act_skbedit.c                       |   11 ++++++-----
 net/xfrm/xfrm_user.c                          |    2 +-
 22 files changed, 107 insertions(+), 73 deletions(-)
