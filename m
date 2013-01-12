From: David Miller <davem@davemloft.net>
Subject: [GIT] Networking
Date: Sat, 12 Jan 2013 15:56:51 -0800 (PST)
Message-ID: <20130112.155651.1165922449897847275.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:34299 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751382Ab3ALX4w (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 12 Jan 2013 18:56:52 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


1) Fix regression allowing IP_TTL setting of zero, fix from Eric
   Dumazet.

2) Fix leak regressions in tunap, from Jason Wang.

3) be2net driver always returns IRQ_HANDLED in INTx handler, fix
   from Sathya Perla.

4) qlge doesn't really support NETIF_F_TSO6, don't set that
   flag.  Fix from Amerigo Wang.

5) Add 802.11ad Atheros wil6210 driver, from Vladimir Kondratiev.

6) Fix MTU calculations in mac80211 layer, from T Krishna Chaitanya.

7) Station info layer of mac80211 needs to use del_timer_sync(),
   from Johannes Berg.

8) tcp_read_sock() can loop forever, because we don't immediately
   stop when recv_actor() returns zero.  Fix from Eric Dumazet.

9) Fix WARN_ON() in tcp_cleanup_rbuf().  We have to use sk_eat_skb()
   in tcp_recv_skb() to handle the case where a large GRO packet
   is split up while it is use by a splice() operation.  Fix also
   from Eric Dumazet.

10) addrconf_get_prefix_route() in ipv6 tests flags incorrectly, it
    does:

	if (X && (p->flags & Y) != 0)

    when it really meant to go:

	if (X && (p->flags & X) != 0)

    fix from Romain Kuntz.

11) Fix lost Kconfig dependency for bfin_mac driver hardware
    timestamping.  From Lars-Peter Clausen.

12) Fix regression in handling of RST without ACK in TCP, from
    Eric Dumazet.

Please pull, thanks a lot!

The following changes since commit ed2c8911684ac780d051d251ad0cd9d797dd029c:

  Merge tag 'sound-3.8' of git://git.kernel.org/pub/scm/linux/kernel/git/tiwai/sound (2013-01-08 07:33:41 -0800)

are available in the git repository at:


  git://git.kernel.org/pub/scm/linux/kernel/git/davem/net master

for you to fetch changes up to d0b9cec3e27d0e9fda2fbf6aaacece68c99b1104:

  be2net: fix unconditionally returning IRQ_HANDLED in INTx (2013-01-12 15:33:01 -0800)

----------------------------------------------------------------
Amerigo Wang (1):
      qlge: remove NETIF_F_TSO6 flag

Amitkumar Karwar (1):
      mwifiex: fix typo in setting up ibss network parameters

Barak Witkowski (1):
      bnx2x: Allow management traffic after boot from SAN

Bing Zhao (1):
      mwifiex: check wait_event_interruptible return value

Chaitanya (1):
      mac80211: fix maximum MTU

Chen Gang (1):
      drivers/net/wireless/iwlegacy: use strlcpy instead of strncpy

Cong Wang (1):
      net: prevent setting ttl=0 via IP_TTL

Dan Carpenter (1):
      bnx2x: move debugging code before the return

Emmanuel Grumbach (1):
      iwlwifi: fix the reclaimed packet tracking upon flush queue

Eric Dumazet (3):
      tcp: splice: fix an infinite loop in tcp_read_sock()
      tcp: fix splice() and tcp collapsing interaction
      tcp: accept RST without ACK flag

Felix Fietkau (1):
      mac80211: flush AP_VLAN stations when tearing down the BSS AP

Jason Wang (3):
      tuntap: switch to use rtnl_dereference()
      tuntap: forbid calling TUNSETIFF when detached
      tuntap: fix leaking reference count

Johannes Berg (5):
      mac80211: assign VLAN channel contexts
      mac80211: fix station destruction in AP/mesh modes
      mac80211: use del_timer_sync for final sta cleanup timer deletion
      mac80211: fix dtim_period in hidden SSID AP association
      iwlwifi: fix PCIe interrupt handle return value

John W. Linville (3):
      Merge branch 'for-john' of git://git.kernel.org/.../jberg/mac80211
      Merge branch 'for-john' of git://git.kernel.org/.../iwlwifi/iwlwifi-fixes
      Merge branch 'master' of git://git.kernel.org/.../linville/wireless into for-davem

Julian Wollrath (1):
      rtlwifi: Fix typo in debug output of rtl8192c and rtl8723ae

Larry Finger (1):
      b43: Fix firmware loading when driver is built into the kernel

Lars-Peter Clausen (1):
      bfin_mac: Restore hardware time-stamping dependency on BF518

Michael S. Tsirkin (1):
      tun: avoid owner checks on IFF_ATTACH_QUEUE

Michal Simek (2):
      net: ethernet: xilinx: Do not use axienet on PPC
      net: ethernet: xilinx: Do not use NO_IRQ in axienet

Nickolai Zeldovich (1):
      drivers/net/wireless/mwl8k.c: avoid use-after-free

Romain Kuntz (2):
      ipv6: fix the noflags test in addrconf_get_prefix_route
      ipv6: use addrconf_get_prefix_route for prefix route lookup [v2]

Sathya Perla (1):
      be2net: fix unconditionally returning IRQ_HANDLED in INTx

Stanislaw Gruszka (2):
      mac80211: fix ibss scanning
      net, wireless: overwrite default_ethtool_ops

Stefan Hajnoczi (1):
      tuntap: refuse to re-attach to different tun_struct

Thomas Pedersen (1):
      mac80211: RMC buckets are just list heads

Vladimir Kondratiev (1):
      wireless: add new wil6210 802.11ad 60GHz driver

Yuval Mintz (1):
      bnx2x: Fix fastpath structures when memory allocation fails

 MAINTAINERS                                         |    8 +
 drivers/net/ethernet/adi/Kconfig                    |    1 +
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c     |   30 +-
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c |    2 +-
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c    |   60 +++-
 drivers/net/ethernet/emulex/benet/be.h              |    1 +
 drivers/net/ethernet/emulex/benet/be_main.c         |   29 +-
 drivers/net/ethernet/qlogic/qlge/qlge_main.c        |    2 +-
 drivers/net/ethernet/xilinx/Kconfig                 |    2 +-
 drivers/net/ethernet/xilinx/xilinx_axienet_main.c   |    2 +-
 drivers/net/tun.c                                   |   44 +--
 drivers/net/wireless/ath/Kconfig                    |    1 +
 drivers/net/wireless/ath/Makefile                   |    1 +
 drivers/net/wireless/ath/wil6210/Kconfig            |   29 ++
 drivers/net/wireless/ath/wil6210/Makefile           |   13 +
 drivers/net/wireless/ath/wil6210/cfg80211.c         |  573 ++++++++++++++++++++++++++++++
 drivers/net/wireless/ath/wil6210/dbg_hexdump.h      |   30 ++
 drivers/net/wireless/ath/wil6210/debugfs.c          |  603 ++++++++++++++++++++++++++++++++
 drivers/net/wireless/ath/wil6210/interrupt.c        |  471 +++++++++++++++++++++++++
 drivers/net/wireless/ath/wil6210/main.c             |  407 ++++++++++++++++++++++
 drivers/net/wireless/ath/wil6210/netdev.c           |  157 +++++++++
 drivers/net/wireless/ath/wil6210/pcie_bus.c         |  223 ++++++++++++
 drivers/net/wireless/ath/wil6210/txrx.c             |  871 ++++++++++++++++++++++++++++++++++++++++++++++
 drivers/net/wireless/ath/wil6210/txrx.h             |  362 +++++++++++++++++++
 drivers/net/wireless/ath/wil6210/wil6210.h          |  363 +++++++++++++++++++
 drivers/net/wireless/ath/wil6210/wmi.c              |  975 +++++++++++++++++++++++++++++++++++++++++++++++++++
 drivers/net/wireless/ath/wil6210/wmi.h              | 1116 +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
 drivers/net/wireless/b43/b43.h                      |    5 +
 drivers/net/wireless/b43/main.c                     |   54 ++-
 drivers/net/wireless/b43/main.h                     |    5 +-
 drivers/net/wireless/iwlegacy/3945-mac.c            |    2 +-
 drivers/net/wireless/iwlwifi/dvm/tx.c               |   24 +-
 drivers/net/wireless/iwlwifi/pcie/rx.c              |    1 +
 drivers/net/wireless/mwifiex/cfg80211.c             |    2 +-
 drivers/net/wireless/mwifiex/sta_ioctl.c            |   21 +-
 drivers/net/wireless/mwl8k.c                        |    4 +-
 drivers/net/wireless/rtlwifi/rtl8192c/phy_common.c  |    2 +-
 drivers/net/wireless/rtlwifi/rtl8723ae/phy.c        |    2 +-
 include/linux/netdevice.h                           |    3 +
 net/core/dev.c                                      |    8 +
 net/ipv4/ip_sockglue.c                              |    2 +-
 net/ipv4/tcp.c                                      |   15 +-
 net/ipv4/tcp_input.c                                |    4 +-
 net/ipv6/addrconf.c                                 |   27 +-
 net/mac80211/cfg.c                                  |    2 +
 net/mac80211/chan.c                                 |   38 ++
 net/mac80211/ibss.c                                 |    9 +-
 net/mac80211/ieee80211_i.h                          |   16 +-
 net/mac80211/iface.c                                |   48 ++-
 net/mac80211/mesh.c                                 |    8 +-
 net/mac80211/mesh.h                                 |    2 +-
 net/mac80211/mlme.c                                 |   75 ++--
 net/mac80211/scan.c                                 |   46 +--
 net/mac80211/sta_info.c                             |   46 ++-
 net/mac80211/sta_info.h                             |    3 +-
 net/wireless/core.c                                 |    3 +-
 56 files changed, 6654 insertions(+), 199 deletions(-)
 create mode 100644 drivers/net/wireless/ath/wil6210/Kconfig
 create mode 100644 drivers/net/wireless/ath/wil6210/Makefile
 create mode 100644 drivers/net/wireless/ath/wil6210/cfg80211.c
 create mode 100644 drivers/net/wireless/ath/wil6210/dbg_hexdump.h
 create mode 100644 drivers/net/wireless/ath/wil6210/debugfs.c
 create mode 100644 drivers/net/wireless/ath/wil6210/interrupt.c
 create mode 100644 drivers/net/wireless/ath/wil6210/main.c
 create mode 100644 drivers/net/wireless/ath/wil6210/netdev.c
 create mode 100644 drivers/net/wireless/ath/wil6210/pcie_bus.c
 create mode 100644 drivers/net/wireless/ath/wil6210/txrx.c
 create mode 100644 drivers/net/wireless/ath/wil6210/txrx.h
 create mode 100644 drivers/net/wireless/ath/wil6210/wil6210.h
 create mode 100644 drivers/net/wireless/ath/wil6210/wmi.c
 create mode 100644 drivers/net/wireless/ath/wil6210/wmi.h
