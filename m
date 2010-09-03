From: David Miller <davem@davemloft.net>
Subject: [GIT] Networking
Date: Fri, 03 Sep 2010 08:27:30 -0700 (PDT)
Message-ID: <20100903.082730.241447728.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:57246
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753002Ab0ICP1N (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Sep 2010 11:27:13 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


1) Fix for IRDA OOPS'er reported by Tavis Ormandy.

2) NETLINK_USERSOCK unintentionally broken, make it work again.

3) kthread_stop() OOPS'er fix in vhost by Eric Dumazet.

4) act_police leaks kernel mem, fix from Jeff Mahoney.

5) mdiobus leak in pxa168 driver, from Denis Kirjanov.

6) Kill double ";" to rectify compiler warning, from Nicolas Dichtel.

7) Kconfig help for rp_filter is wrong, fix from Nicolas Dichtel.

8) Fix MII locking in 3c59x driver, from Ben Hutchings.

9) bridge calls ip_fragment() with garbage INET SKB control block,
   just zero it out like we do elsewhere in bridging.

10) Fix crashes in GRO when packets are merged with different headroom
    amounts.  The problem is that in this case the ->csum_start
    packet offset is not adjusted correctly.  Later on we crash trying
    to fixup the checksum at an out-of-range offset.

    From Eric Dumazet.  Special thanks to Plamen Petrov for testing
    various debugging patches to help us track this down.

11) Fix est_tree_lock locking in generic estimator, it must use BH
    protection.  From Jarek Poplawski.

12) Add new PCNET_CS device ID, from Ken Kawasaki.

13) HFSC packet scheduler fix from Michal Soltys, cfmin of parent must
    be updated unconditionally in init_vf().

14) Fix DMA mis-alignment problems in libertas on some platforms,
    from Mike Rapoport.

15) ieee80211_get_tx_rate() return not checked properly in ath5k_txbuf_setup
    leading to OOPS, from John Linville.

16) Two ath9k fixes from Luis R. Rodriguez.  Fix EEPROM reading, and fix
    parsing of 5GHz CTL indexes.

17) Fix TX status flag bit check in p54, fixes power save.
    From Christian Lamparter.

18) mac80211 workqueue timer deletion fix from Johannes Berg.

19) Kernel memory leak fix in wireless extensions, also from Johannes.

20) Circular locking fix in wiphy_register(), from John W. Linville.

21) IPVS passive ftp crash fix from Julian Anastasov.

Please pull, thanks a lot!

The following changes since commit 2bfc96a127bc1cc94d26bfaa40159966064f9c8c:

  Linux 2.6.36-rc3 (2010-08-29 08:36:04 -0700)

are available in the git repository at:
  master.kernel.org:/pub/scm/linux/kernel/git/davem/net-2.6.git master

Ben Hutchings (1):
      3c59x: Remove incorrect locking; correct documented lock hierarchy

Breno Leitao (1):
      MAINTAINERS: Add ehea driver as Supported

Christian Lamparter (1):
      p54: fix tx feedback status flag check

David S. Miller (5):
      irda: Correctly clean up self->ias_obj on irda_bind() failure.
      netlink: Make NETLINK_USERSOCK work again.
      Merge branch 'master' of git://git.kernel.org/.../linville/wireless-2.6
      bridge: Clear INET control block of SKBs passed into ip_fragment().
      Revert "sky2: don't do GRO on second port"

Denis Kirjanov (1):
      pxa168_eth: fix a mdiobus leak

Eric Dumazet (2):
      vhost: stop worker only if created
      gro: fix different skb headrooms

Jarek Poplawski (1):
      pkt_sched: Fix lockdep warning on est_tree_lock in gen_estimator

Jeff Mahoney (1):
      net sched: fix kernel leak in act_police

Johannes Berg (2):
      mac80211: delete work timer
      wireless extensions: fix kernel heap content leak

John W. Linville (3):
      ath5k: check return value of ieee80211_get_tx_rate
      MAINTAINERS: change broken url for prism54
      wireless: register wiphy rfkill w/o holding cfg80211_mutex

Julian Anastasov (1):
      ipvs: avoid oops for passive FTP

Ken Kawasaki (1):
      pcnet_cs: add new_id

Luis R. Rodriguez (2):
      ath9k_hw: Fix EEPROM uncompress block reading on AR9003
      ath9k_hw: fix parsing of HT40 5 GHz CTLs

Michal Soltys (1):
      net/sched/sch_hfsc.c: initialize parent's cl_cfmin properly in init_vf()

Mike Rapoport (1):
      libertas: if_sdio: fix buffer alignment in struct if_sdio_card

Nicolas Dichtel (2):
      xfrm_user: avoid a warning with some compiler
      ipv4: minor fix about RPF in help of Kconfig

stephen hemminger (1):
      sky2: don't do GRO on second port

 MAINTAINERS                                    |    8 +++++++-
 drivers/net/3c59x.c                            |    5 +----
 drivers/net/pcmcia/pcnet_cs.c                  |    1 +
 drivers/net/pxa168_eth.c                       |    2 ++
 drivers/net/wireless/ath/ath5k/base.c          |    4 ++++
 drivers/net/wireless/ath/ath9k/ar9003_eeprom.c |    2 +-
 drivers/net/wireless/ath/ath9k/eeprom.h        |    2 +-
 drivers/net/wireless/ath/regd.h                |    1 -
 drivers/net/wireless/libertas/if_sdio.c        |    2 +-
 drivers/net/wireless/p54/txrx.c                |    2 +-
 drivers/vhost/vhost.c                          |    5 ++++-
 net/bridge/br_netfilter.c                      |    6 ++++--
 net/core/gen_estimator.c                       |   12 ++++++------
 net/core/skbuff.c                              |    8 ++++++--
 net/ipv4/Kconfig                               |    2 +-
 net/irda/af_irda.c                             |    4 ++--
 net/mac80211/main.c                            |    6 ++++++
 net/netfilter/ipvs/ip_vs_ftp.c                 |    3 ++-
 net/netlink/af_netlink.c                       |   22 ++++++++++++++++++++++
 net/sched/act_police.c                         |   21 +++++++++------------
 net/sched/sch_hfsc.c                           |    2 +-
 net/wireless/core.c                            |   21 ++++++++++++---------
 net/wireless/wext-compat.c                     |    3 +++
 net/wireless/wext-core.c                       |   16 ++++++++++++++++
 net/xfrm/xfrm_user.c                           |    2 +-
 25 files changed, 114 insertions(+), 48 deletions(-)
