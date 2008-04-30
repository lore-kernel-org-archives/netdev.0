From: David Miller <davem@davemloft.net>
Subject: [GIT]: Networking
Date: Wed, 30 Apr 2008 01:31:38 -0700 (PDT)
Message-ID: <20080430.013138.157977693.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53236
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754916AbYD3Ibj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Apr 2008 04:31:39 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Several cures and additions:

1) TCP congestion window fixups in the presence of TSO, from John
   Heffner, based upon some recent reports from google.

2) IPVS OOPS fix from Julian Anastasov.

3) IPSEC auditing fix from Yoshifuji HIDEAKI.

4) Various network driver updates from Jeff Garzik, and in particular
   a new driver for Solarstorm SFC4000 chips, and one for
   some IXP4xxx ethernet ports.

5) More multicast socket option compat handling work from David
   Stevens.

6) Hopefully the last of the iwlwifi build issues are cured thanks to
   Adrian Bunk.

7) SFQ scheduler shutdown should use dev_timer_sync(), from Jarek
   Poplawski.

8) Imporperly fragmented SKBs can get created by layers such as
   sunrpc when sending to UFO capable devices.  Fix from
   Kostya B, and reviewed by Herbert Xu.

9) Netfilter connection tracking hash calculation bug on ARM, diagnosed
   and fixed by Philip Craig.

10) Two bridge fixes from Bodo Stroesser and Volodymyr G Lukiianyk, via
    Stephen Hemminger.

Please pull, thanks a lot!

The following changes since commit 358c12953b88c5a06a57c33eb27c753b2e7934d1:
  Jason Riedy (1):
        iwlwifi: Allow building iwl3945 without iwl4965.

are available in the git repository at:

  master.kernel.org:/pub/scm/linux/kernel/git/davem/net-2.6.git master

Adrian Bunk (1):
      iwlwifi: move the selects to the tristate drivers

Arnaud Ebalard (1):
      netfilter: {nfnetlink,ip,ip6}_queue: fix skb_over_panic when enlarging packets

Ben Hutchings (1):
      New driver "sfc" for Solarstorm SFC4000 controller.

Bodo Stroesser (1):
      bridge: kernel panic when unloading bridge module

Bryan Wu (2):
      Blackfin EMAC Driver: code cleanup
      Blackfin EMAC Driver: Initial version of ethtool support

Cornelia Huck (1):
      netiucv: Fix missing driver attributes.

Daniel Walker (1):
      atm: ambassador: vcc_sf semaphore to mutex

David L Stevens (2):
      net: Several cleanups for the setsockopt compat support.
      net: Add compat support for getsockopt (MCAST_MSFILTER)

Francois Romieu (3):
      sis190: Rx path update
      sis190: remove needless MII reset
      sis190: account for Tx errors

Frank Blaschka (5):
      qeth: layer 3 support vlan IPv6 on hiper socket
      qeth: provide get ethtool settings
      qeth: rework fast path
      qeth: layer 3 add missing dev_open/close to ccwgroup handler
      qeth: layer 2 allow ethtool to set TSO

Harvey Harrison (1):
      net: eepro autoport typo

Ivan Vecera (1):
      r8169: fix oops in r8169_get_mac_version

Jarek Poplawski (1):
      sch_sfq: use del_timer_sync() in sfq_destroy()

Jeff Garzik (2):
      Merge branch 'sis190' of git://git.kernel.org/.../romieu/netdev-2.6 into upstream
      Merge branch 'upstream-jeff' of git://git.kernel.org/.../romieu/netdev-2.6 into upstream

John Heffner (2):
      tcp: Allow send-limited cwnd to grow up to max_burst when gso disabled
      tcp: Limit cwnd growth when deferring for GSO

Julian Anastasov (1):
      ipvs: fix oops in backup for fwmark conn templates

Klaus D. Wacker (1):
      lcs: CCL-sequ. numbers required for protocol 802.2 only.

Kostya B (1):
      [IPv4] UFO: prevent generation of chained skb destined to UFO device

Krzysztof Halasa (1):
      Driver for IXP4xx built-in Ethernet ports

Lachlan Andrew (1):
      tcp: Overflow bug in Vegas

Paul Gortmaker (1):
      [netdrvr] gianfar: Determine TBIPA value dynamically

Paulius Zaleckas (3):
      3c505: use netstats in net_device structure
      3c509: use netstats in net_device structure
      3c515: use netstats in net_device structure

Pavel Emelyanov (2):
      netfilter: x_tables: fix net namespace leak when reading /proc/net/xxx_tables_names
      MAINTAINERS: The socketcan-core list is subscribers-only.

Peter Tiedemann (1):
      qeth module size reduction.

Philip Craig (1):
      netfilter: nf_conntrack: padding breaks conntrack hash on ARM

Randy Dunlap (1):
      drivers/net/phy: fix kernel-doc notation

Roel Kluin (3):
      r8169: fix past rtl_chip_info array size for unknown chipsets
      ARM: am79c961a: platform_get_irq() may return signed unnoticed
      netfilter: xt_TCPOPTSTRIP: signed tcphoff for ipv6_skip_exthdr() retval

Sam Ravnborg (1):
      ipv4: annotate a few functions __init in ipconfig.c

Sreenivasa Honnur (2):
      S2io: Enable multi ring support
      S2io: Version update for multi ring patches

Stephen Hemminger (3):
      sis190: use the allocated buffer as a status code in sis190_alloc_rx_skb
      sis190: hard-code the alignment of tiny packets
      sis190: use netdev_alloc_skb

Steve Glendinning (2):
      Rename SMSC phy functions to be more generic
      Add support for SMSC LAN8187 and LAN8700 PHYs

Timo Teras (1):
      ipv4: Update MTU to all related cache entries in ip_rt_frag_needed()

Ursula Braun (3):
      netiucv: get rid of in_atomic() use
      ccwgroup: Unify parsing for group attribute.
      qeth: read number of ports from card

Volodymyr G Lukiianyk (1):
      bridge: fix error handling in br_add_if()

 MAINTAINERS                                    |    9 +-
 arch/arm/mach-ixp4xx/ixp4xx_npe.c              |    4 +
 arch/arm/mach-ixp4xx/ixp4xx_qmgr.c             |    2 +
 drivers/atm/ambassador.c                       |   19 +-
 drivers/atm/ambassador.h                       |    2 +-
 drivers/net/3c505.c                            |   30 +-
 drivers/net/3c505.h                            |    1 -
 drivers/net/3c509.c                            |   47 +-
 drivers/net/3c515.c                            |   64 +-
 drivers/net/Kconfig                            |    1 +
 drivers/net/Makefile                           |    2 +
 drivers/net/arm/Kconfig                        |    8 +
 drivers/net/arm/Makefile                       |    1 +
 drivers/net/arm/am79c961a.c                    |   10 +-
 drivers/net/arm/ixp4xx_eth.c                   | 1265 +++++++++++
 drivers/net/bfin_mac.c                         |  296 ++--
 drivers/net/bfin_mac.h                         |    2 +-
 drivers/net/eepro.c                            |    2 +-
 drivers/net/gianfar.c                          |   27 +-
 drivers/net/gianfar.h                          |    1 -
 drivers/net/gianfar_mii.c                      |   38 +-
 drivers/net/gianfar_mii.h                      |    3 +
 drivers/net/phy/Kconfig                        |    2 +-
 drivers/net/phy/phy_device.c                   |    2 +-
 drivers/net/phy/smsc.c                         |   83 +-
 drivers/net/r8169.c                            |    8 +-
 drivers/net/s2io.c                             |  337 ++--
 drivers/net/s2io.h                             |   82 +-
 drivers/net/sfc/Kconfig                        |   12 +
 drivers/net/sfc/Makefile                       |    5 +
 drivers/net/sfc/bitfield.h                     |  508 +++++
 drivers/net/sfc/boards.c                       |  167 ++
 drivers/net/sfc/boards.h                       |   26 +
 drivers/net/sfc/efx.c                          | 2208 +++++++++++++++++++
 drivers/net/sfc/efx.h                          |   67 +
 drivers/net/sfc/enum.h                         |   50 +
 drivers/net/sfc/ethtool.c                      |  460 ++++
 drivers/net/sfc/ethtool.h                      |   27 +
 drivers/net/sfc/falcon.c                       | 2722 ++++++++++++++++++++++++
 drivers/net/sfc/falcon.h                       |  130 ++
 drivers/net/sfc/falcon_hwdefs.h                | 1135 ++++++++++
 drivers/net/sfc/falcon_io.h                    |  243 +++
 drivers/net/sfc/falcon_xmac.c                  |  585 +++++
 drivers/net/sfc/gmii.h                         |  195 ++
 drivers/net/sfc/i2c-direct.c                   |  381 ++++
 drivers/net/sfc/i2c-direct.h                   |   91 +
 drivers/net/sfc/mac.h                          |   33 +
 drivers/net/sfc/mdio_10g.c                     |  282 +++
 drivers/net/sfc/mdio_10g.h                     |  232 ++
 drivers/net/sfc/net_driver.h                   |  883 ++++++++
 drivers/net/sfc/phy.h                          |   48 +
 drivers/net/sfc/rx.c                           |  875 ++++++++
 drivers/net/sfc/rx.h                           |   29 +
 drivers/net/sfc/sfe4001.c                      |  252 +++
 drivers/net/sfc/spi.h                          |   71 +
 drivers/net/sfc/tenxpress.c                    |  434 ++++
 drivers/net/sfc/tx.c                           |  452 ++++
 drivers/net/sfc/tx.h                           |   24 +
 drivers/net/sfc/workarounds.h                  |   56 +
 drivers/net/sfc/xenpack.h                      |   62 +
 drivers/net/sfc/xfp_phy.c                      |  132 ++
 drivers/net/sis190.c                           |  136 +-
 drivers/net/wireless/iwlwifi/Kconfig           |   12 +-
 drivers/s390/cio/ccwgroup.c                    |   96 +-
 drivers/s390/net/cu3088.c                      |   20 +-
 drivers/s390/net/lcs.c                         |    3 +-
 drivers/s390/net/netiucv.c                     |    3 +-
 drivers/s390/net/qeth_core.h                   |   50 +-
 drivers/s390/net/qeth_core_main.c              |  200 +-
 drivers/s390/net/qeth_l2_main.c                |   30 +-
 drivers/s390/net/qeth_l3.h                     |    3 -
 drivers/s390/net/qeth_l3_main.c                |   30 +-
 include/asm-s390/ccwgroup.h                    |    7 +-
 include/asm-s390/qdio.h                        |    1 +
 include/net/compat.h                           |    3 +
 include/net/ip_vs.h                            |    3 +-
 include/net/netfilter/nf_conntrack_tuple.h     |   10 -
 include/net/route.h                            |    2 +-
 net/bridge/br.c                                |    2 +-
 net/bridge/br_if.c                             |    5 +-
 net/compat.c                                   |   90 +-
 net/ipv4/icmp.c                                |    3 +-
 net/ipv4/ip_output.c                           |   22 +-
 net/ipv4/ip_sockglue.c                         |    9 +-
 net/ipv4/ipconfig.c                            |    8 +-
 net/ipv4/ipvs/ip_vs_proto.c                    |    2 +-
 net/ipv4/ipvs/ip_vs_proto_ah.c                 |    1 +
 net/ipv4/ipvs/ip_vs_proto_esp.c                |    1 +
 net/ipv4/ipvs/ip_vs_proto_tcp.c                |    1 +
 net/ipv4/ipvs/ip_vs_proto_udp.c                |    1 +
 net/ipv4/ipvs/ip_vs_sync.c                     |   80 +-
 net/ipv4/netfilter/ip_queue.c                  |    5 +-
 net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c |    2 +-
 net/ipv4/route.c                               |   40 +-
 net/ipv4/tcp_cong.c                            |   12 +-
 net/ipv4/tcp_vegas.c                           |   10 +-
 net/ipv4/tcp_veno.c                            |    8 +-
 net/ipv6/ipv6_sockglue.c                       |    4 +
 net/ipv6/netfilter/ip6_queue.c                 |    5 +-
 net/netfilter/nf_conntrack_core.c              |    4 +-
 net/netfilter/nfnetlink_queue.c                |    5 +-
 net/netfilter/x_tables.c                       |    2 +-
 net/netfilter/xt_TCPOPTSTRIP.c                 |    2 +-
 net/sched/sch_sfq.c                            |    3 +-
 104 files changed, 15349 insertions(+), 812 deletions(-)
 create mode 100644 drivers/net/arm/ixp4xx_eth.c
 create mode 100644 drivers/net/sfc/Kconfig
 create mode 100644 drivers/net/sfc/Makefile
 create mode 100644 drivers/net/sfc/bitfield.h
 create mode 100644 drivers/net/sfc/boards.c
 create mode 100644 drivers/net/sfc/boards.h
 create mode 100644 drivers/net/sfc/efx.c
 create mode 100644 drivers/net/sfc/efx.h
 create mode 100644 drivers/net/sfc/enum.h
 create mode 100644 drivers/net/sfc/ethtool.c
 create mode 100644 drivers/net/sfc/ethtool.h
 create mode 100644 drivers/net/sfc/falcon.c
 create mode 100644 drivers/net/sfc/falcon.h
 create mode 100644 drivers/net/sfc/falcon_hwdefs.h
 create mode 100644 drivers/net/sfc/falcon_io.h
 create mode 100644 drivers/net/sfc/falcon_xmac.c
 create mode 100644 drivers/net/sfc/gmii.h
 create mode 100644 drivers/net/sfc/i2c-direct.c
 create mode 100644 drivers/net/sfc/i2c-direct.h
 create mode 100644 drivers/net/sfc/mac.h
 create mode 100644 drivers/net/sfc/mdio_10g.c
 create mode 100644 drivers/net/sfc/mdio_10g.h
 create mode 100644 drivers/net/sfc/net_driver.h
 create mode 100644 drivers/net/sfc/phy.h
 create mode 100644 drivers/net/sfc/rx.c
 create mode 100644 drivers/net/sfc/rx.h
 create mode 100644 drivers/net/sfc/sfe4001.c
 create mode 100644 drivers/net/sfc/spi.h
 create mode 100644 drivers/net/sfc/tenxpress.c
 create mode 100644 drivers/net/sfc/tx.c
 create mode 100644 drivers/net/sfc/tx.h
 create mode 100644 drivers/net/sfc/workarounds.h
 create mode 100644 drivers/net/sfc/xenpack.h
 create mode 100644 drivers/net/sfc/xfp_phy.c
