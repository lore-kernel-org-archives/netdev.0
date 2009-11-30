From: David Miller <davem@davemloft.net>
Subject: [GIT]: Networking
Date: Mon, 30 Nov 2009 01:12:00 -0800 (PST)
Message-ID: <20091130.011200.151941188.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-2022-jp-2
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1753253AbZK3JL5@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


1) EMAC driver build fix, macro issues.  From chaithrika@ti.com

2) Fix order 5 GFP_ATOMIC allocation on resume in e100, from Roger Oksanen.
   This fixes a regression list entry.

3) smc91x IRQ number handling broken since 2.6.26 on some platforms.
   Fix from Russell King.

4) Netxen promisc and bonding TLB/ALB mode fix from Narender Kumar.

5) stmmac build fix from Giuseppe CAVALLARO.

6) ETHOC bad kconfig dependencies, fix from Geert Uytterhoeven.

7) ep93xx-eth can register with zero MAC addr, fix from Florian Fainelli.

8) b44 spews log messages on a normal interrupt status condition,
   making netconsole over it wedge the machine.

9) IP fragmentation handling can OOPS due to misreferenced network
   namespace pointer.  Fix from David Ford.

10) Missing semaphore release in cosa driver, from Dan Carpenter.

11) Fix build with debug enabled and fix soft lockup, by Antti Kaijanmäki
    via Andrew Morton.

12) SCTP retransmit fix from Andrei Pelinescu-Onciul.

13) au1x00 does netdevice register before ->netdev_ops is setup
    properly.  Fix from Alexander Beregalov.

14) Several netfilter fixes via Patrick McHardy, in particular keep
    nf_log from taking a mutex inside of an RCU section thus triggering
    might_sleep() warnings.

15) Oops, veth driver accesses statistics in parallal from multiple
    cpus completely unlocked.  Fix from Eric Dumazet.

16) ieee802154_fake_xmit() claims to handle the SKB but doesn't free
    it resulting in a leak.  Fix from Eric Dumazet.

17) A few small wireless fixes via John Linville, including hopefully
    the final fix for addba timers from Johannes Berg.

Please pull, thanks a lot!

The following changes since commit a8a8a669ea13d792296737505adc43ccacf3a648:
  Linus Torvalds (1):
        Merge branch 'i2c-pnx-fixes' of git://git.fluff.org/bjdooks/linux

are available in the git repository at:

  master.kernel.org:/pub/scm/linux/kernel/git/davem/net-2.6.git master

Alexander Beregalov (1):
      Au1x00: fix crash when trying register_netdev()

Amit Kumar Salecha (1):
      netxen: fix memory initialization

Andrei Pelinescu-Onciul (1):
      sctp: on T3_RTX retransmit all the in-flight chunks

Antti Kaijanmäki (2):
      hso: fix debug routines
      hso: fix soft-lockup

Bruce Allan (7):
      e1000e: partial revert of 3ec2a2b8 plus FC workraround for 82577/8
      e1000e: read of PHY register may access wrong page on 82578
      e1000e: set flow control thresholds properly after enabling/disabling pause
      e1000e: add Tx timeout factor for 100Mbps
      e1000e: flow control thresholds not correct when changing mtu
      e1000e: remove unnecessary 82577 workaround causing link issues
      e1000e: do not initiate autonegotiation during OEM configuration

Dan Carpenter (1):
      wan: cosa: drop chan->wsem on error path

David Ford (1):
      ipv4: additional update of dev_net(dev) to struct *net in ip_fragment.c, NULL ptr OOPS

David J. Choi (1):
      drivers/net: ks8851_mll ethernet network driver -resubmit

David S. Miller (3):
      Merge branch 'master' of git://git.kernel.org/.../kaber/nf-2.6
      Merge branch 'master' of git://git.kernel.org/.../linville/wireless-2.6
      b44: Fix wedge when using netconsole.

Eric Dumazet (4):
      ieee802154: dont leak skbs in ieee802154_fake_xmit()
      veth: Fix veth_get_stats()
      pktgen: Fix device name compares
      pktgen: Fix netdevice unregister

Florian Fainelli (1):
      ep93xx-eth: check for zero MAC address on probe, not on device open

Geert Uytterhoeven (1):
      net: ETHOC should depend on HAS_DMA

Giuseppe CAVALLARO (2):
      stmmac: fixed a compilation error when use the external timer
      stmmac: do not fail when the timer cannot be used.

Ivan Vecera (1):
      r8169: restore mac addr in rtl8169_remove_one and rtl_shutdown

Jaswinder Singh Rajput (1):
      ixgbe: move tc variable to CONFIG_IXGBE_DCB

Johannes Berg (3):
      mac80211: fix addba timer (again...)
      mac80211: fix resume
      rfkill: fix miscdev ops

John W. Linville (1):
      ath9k: set ps_default as false

Narender Kumar (2):
      netxen: fix promisc for NX2031.
      netxen : fix BOND_MODE_TLB/ALB mode.

Patrick McHardy (4):
      netfilter: xt_osf: fix xt_osf_remove_callback() return value
      netfilter: nf_log: fix sleeping function called from invalid context in seq_show()
      netfilter: xt_limit: fix invalid return code in limit_mt_check()
      macvlan: fix gso_max_size setting

Roel Kluin (1):
      netfilter: xt_osf: fix xt_osf_remove_callback() return value

Roger Oksanen (1):
      e100: Use pci pool to work around GFP_ATOMIC order 5 memory allocation failure

Russell King - ARM Linux (1):
      NET: smc91x: Fix irq flags

Steve Glendinning (1):
      smsc9420: prevent BUG() if ethtool is called with interface down

Wu Fengguang (1):
      netfilter: nf_log: fix sleeping function called from invalid context in seq_show()

chaithrika@ti.com (1):
      TI DaVinci EMAC: Minor macro related updates

 drivers/ieee802154/fakehard.c         |    5 +-
 drivers/net/Kconfig                   |    2 +-
 drivers/net/arm/ep93xx_eth.c          |   12 +--
 drivers/net/au1000_eth.c              |   15 ++--
 drivers/net/b44.c                     |    3 -
 drivers/net/davinci_emac.c            |   26 +++----
 drivers/net/e100.c                    |   17 +++--
 drivers/net/e1000e/e1000.h            |    2 +
 drivers/net/e1000e/ethtool.c          |   12 +++-
 drivers/net/e1000e/ich8lan.c          |    4 +-
 drivers/net/e1000e/netdev.c           |   50 ++++++++----
 drivers/net/e1000e/phy.c              |   56 +++++--------
 drivers/net/ixgbe/ixgbe_main.c        |    2 +-
 drivers/net/ks8851_mll.c              |  142 ++++++++++++++++-----------------
 drivers/net/macvlan.c                 |    2 +
 drivers/net/netxen/netxen_nic.h       |    2 +
 drivers/net/netxen/netxen_nic_hdr.h   |    2 +
 drivers/net/netxen/netxen_nic_hw.c    |   55 ++++++++++---
 drivers/net/netxen/netxen_nic_init.c  |    2 +
 drivers/net/netxen/netxen_nic_main.c  |    4 +-
 drivers/net/r8169.c                   |    7 ++
 drivers/net/smc91x.c                  |    2 +-
 drivers/net/smsc9420.c                |   14 +++
 drivers/net/stmmac/stmmac_main.c      |   50 +++++++-----
 drivers/net/stmmac/stmmac_timer.c     |    4 +-
 drivers/net/stmmac/stmmac_timer.h     |    1 +
 drivers/net/usb/hso.c                 |    8 +-
 drivers/net/veth.c                    |   35 ++++-----
 drivers/net/wan/cosa.c                |    1 +
 drivers/net/wireless/ath/ath9k/main.c |    2 +
 include/net/sctp/structs.h            |    1 -
 net/core/pktgen.c                     |   32 +++++---
 net/ipv4/ip_fragment.c                |    2 +-
 net/mac80211/agg-tx.c                 |   18 ++---
 net/mac80211/ieee80211_i.h            |    8 ++
 net/mac80211/util.c                   |   19 ++---
 net/netfilter/nf_log.c                |   18 +---
 net/netfilter/xt_limit.c              |    2 +-
 net/netfilter/xt_osf.c                |    2 +-
 net/rfkill/core.c                     |    1 +
 net/sctp/outqueue.c                   |   10 ---
 net/sctp/sm_sideeffect.c              |    1 -
 net/sctp/transport.c                  |    5 +-
 43 files changed, 359 insertions(+), 299 deletions(-)
