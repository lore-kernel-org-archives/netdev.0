From: David Miller <davem@davemloft.net>
Subject: [GIT] Networking
Date: Thu, 26 Jul 2012 16:58:03 -0700 (PDT)
Message-ID: <20120726.165803.612314640731436574.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


1) Reinstate the no-ref optimization for input route lookups in ipv4
   to fix some routing cache removal perf regressions.

2) Make TCP socket pre-demux work on ipv6 side too, from Eric Dumazet.

3) Get RX hash value from correct place in be2net driver, from
   Sarveshwar Bandi.

4) Validation of FIB cached routes missing critical check, from Eric
   Dumazet.

5) EEH support in mlx4 driver, from Kleber Sacilotto de Souza.

Please pull, thanks a lot!

The following changes since commit 3c4cfadef6a1665d9cd02a543782d03d3e6740c6:

  Merge git://git.kernel.org/pub/scm/linux/kernel/git/davem/net-next (2012-07-24 10:01:50 -0700)

are available in the git repository at:


  git://git.kernel.org/pub/scm/linux/kernel/git/davem/net.git master

for you to fetch changes up to c7109986db3c945f50ceed884a30e0fd8af3b89b:

  ipv6: Early TCP socket demux (2012-07-26 15:50:39 -0700)

----------------------------------------------------------------
Alan Cox (2):
      caif: fix NULL pointer check
      wanmain: comparing array with NULL

Amir Vadai (1):
      net/mlx4_en: Limit the RFS filter IDs to be < RPS_NO_FILTER

Andy Cress (3):
      pch_gbe: fix transmit watchdog timeout
      pch_gbe: add extra clean tx
      pch_gbe: vlan skb len fix

Anton Blanchard (1):
      be2net: Missing byteswap in be_get_fw_log_level causes oops on PowerPC

Dan Williams (1):
      cdc-ncm: tag Ericsson WWAN devices (eg F5521gw) with FLAG_WWAN

David S. Miller (1):
      ipv4: Fix input route performance regression.

Emil Tantilov (1):
      ixgbe: fix panic while dumping packets on Tx hang with IOMMU

Eric Dumazet (3):
      tcp: early_demux fixes
      ipv4: rt_cache_valid must check expired routes
      ipv6: Early TCP socket demux

Haiyang Zhang (2):
      hyperv: Add a check for ring_size value
      hyperv: Add error handling to rndis_filter_device_add()

Jiri Pirko (1):
      team: init error value to 0 in team_netpoll_setup()

Kleber Sacilotto de Souza (1):
      mlx4: Add support for EEH error recovery

Sarveshwar Bandi (1):
      be2net: Fix to parse RSS hash from Receive completions correctly.

Wei Yang (1):
      net/pch_gpe: Cannot disable ethernet autonegation

Yuval Mintz (1):
      bnx2x: Correct EEE statistics gathering

frank.blaschka@de.ibm.com (3):
      net: wiznet add missing HAS_IOMEM dependency
      netiucv: cleanup attribute usage
      qeth: repair crash in qeth_l3_vlan_rx_kill_vid()

 drivers/net/caif/caif_serial.c                          |  3 ++
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_reg.h         |  4 +++
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_stats.c       |  8 +++--
 drivers/net/ethernet/emulex/benet/be_ethtool.c          |  5 ++--
 drivers/net/ethernet/emulex/benet/be_main.c             |  6 ++--
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c           | 11 +++----
 drivers/net/ethernet/mellanox/mlx4/catas.c              | 25 +++++++++++-----
 drivers/net/ethernet/mellanox/mlx4/cmd.c                | 49 +++++++++++++++++++++++++++++--
 drivers/net/ethernet/mellanox/mlx4/en_netdev.c          |  2 +-
 drivers/net/ethernet/mellanox/mlx4/main.c               | 30 ++++++++++++++++++-
 drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_ethtool.c |  1 -
 drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c    | 70 ++++++++++++++++++++++++++++++--------------
 drivers/net/ethernet/wiznet/Kconfig                     |  1 +
 drivers/net/hyperv/netvsc_drv.c                         |  7 ++++-
 drivers/net/hyperv/rndis_filter.c                       | 11 +++----
 drivers/net/team/team.c                                 |  2 +-
 drivers/net/usb/cdc_ncm.c                               | 68 +++++++++++++++++++++++++++---------------
 drivers/s390/net/netiucv.c                              | 34 ++++-----------------
 drivers/s390/net/qeth_l3_main.c                         |  4 +++
 include/net/inet6_hashtables.h                          | 13 ++++----
 include/net/protocol.h                                  |  2 ++
 include/net/route.h                                     | 19 ++++++++++--
 net/ipv4/arp.c                                          |  2 +-
 net/ipv4/fib_semantics.c                                |  4 +--
 net/ipv4/ip_fragment.c                                  |  4 +--
 net/ipv4/ip_input.c                                     | 10 +++++--
 net/ipv4/route.c                                        | 56 +++++++++++++++++------------------
 net/ipv4/tcp_ipv4.c                                     |  9 ++----
 net/ipv4/xfrm4_input.c                                  |  4 +--
 net/ipv6/ip6_input.c                                    | 13 ++++++--
 net/ipv6/tcp_ipv6.c                                     | 38 ++++++++++++++++++++++++
 net/wanrouter/wanmain.c                                 | 51 +++++++++++++++-----------------
 32 files changed, 374 insertions(+), 192 deletions(-)
