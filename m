From: David Miller <davem@davemloft.net>
Subject: [GIT]: Networking
Date: Mon, 25 Jan 2010 16:56:34 -0800 (PST)
Message-ID: <20100125.165634.92235663.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1752503Ab0AZA4Y@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


1) SKY2 revert to fix a resume regression, from Stephem Hemminger

2) We can end up trying to remove/proc/net/rt_acct when exiting
   a namespace even when we didn't create it in the first place.
   Fix from Alexey Dobriyan.

3) IPSEC in namespaces can wedge if IPSEC route creation hits the
   garbage collection threshold, it'll wedge until the initial
   namespace happens to hit GC limits and garbage collect.

   Fix from Alexey Dobriyan.

4) igb/igbvg test for DMA mapping failures incorrectly in TX
   path, from Alexander Duyck.

5) qlge tries to free resources never allocated, fix from Breno Leitao

6) vlan_skb_recv() references wrong device for statistics bumping,
   resulting in OOPS.  Regression fixed by Eric Dumazet.

7) virtio_net refilling is unreliable when OOM and can wedge,
   fix from Herbert Xu

8) Intel drivers test for ipv6 GRO incorrectly, fix from Sridhar
   Samudrala.

9) tcp_probe reports available space incorrectly (off by one) and
   does many unnecessary expensive modulus operations, from Stephen
   Hemminger.

10) Add ID for Microsoft MN-120 PCMCIA card, from Ron Murray.

11) Appletalk's aarp_recv() references wrong foo.s_net, from Roel Kluin.

12) INET_DIAG_BC_S_LE compares wrong TCP port, also from Roel Kluin.

13) Fix two branches of an if() in S2IO which erroneously program the
    chip identically, noticed by Roel Kluin and fixed by Ram Vepa.

14) Fix dccp_probe/dccp module dependencies, and cure crashes on
    dccp module unload.  From Neil Horman.

15) SKY2 needs to enable/disable WOL per card, not per port.  Fix
    from Mike McCormack.

16) SFC bug fixes (bad MMD checks at init, GMAC bug workaround fix,
    BUG() and hang due to misaligned MCDI NVRAM requests, etc.) from
    Matthew Slattery, Guido Barzini, and Ben Hutchings.

17) Fix regression by moving phylib's workqueue init to the proper
    place, from Anton Vorontsov.

18) I/O AT maintainership update.

19) Wireless fixes via John Linville and co.

Please pull, thanks a lot!

The following changes since commit f6760aa024199cfbce564311dc4bc4d47b6fb349:
  Linus Torvalds (1):
        Merge branch 'timers-fixes-for-linus' of git://git.kernel.org/.../tip/linux-2.6-tip

are available in the git repository at:

  master.kernel.org:/pub/scm/linux/kernel/git/davem/net-2.6.git master

Abhijeet Kolekar (1):
      cfg80211: fix channel setting for wext

Alexander Duyck (1):
      igb/igbvf: cleanup exception handling in tx_map_adv

Alexey Dobriyan (3):
      ipv4: don't remove /proc/net/rt_acct
      netns xfrm: fix "ip xfrm state|policy count" misreport
      netns xfrm: deal with dst entries in netns

Anton Vorontsov (1):
      phylib: Move workqueue initialization to a proper place

Ben Hutchings (1):
      sfc: Use fixed-size buffers for MCDI NVRAM requests

Benoit Papillault (1):
      mac80211: check that ieee80211_set_power_mgmt only handles STA interfaces.

Bob Copeland (1):
      mac80211: fix sign error in pid controller

Breno Leitao (1):
      qlge: Only free resources if they were allocated

Christian Lamparter (1):
      p54pci: rx frame length check

Dan Williams (1):
      MAINTAINERS: transfer maintainership of I/OAT

David S. Miller (3):
      Merge branch 'master' of git://git.kernel.org/.../linville/wireless-2.6
      Merge branch 'master' of /home/davem/src/GIT/linux-2.6/
      Merge branch 'linux-2.6.33.y' of git://git.kernel.org/.../inaky/wimax

Eric Dumazet (1):
      vlan: fix vlan_skb_recv()

Guido Barzini (1):
      sfc: Add workspace for GMAC bug workaround to MCDI MAC_STATS buffer

Herbert Xu (1):
      virtio_net: Make delayed refill more reliable

Hin-Tak Leung (1):
      zd1211rw: adding 0409:0248 to supported device list

Inaky Perez-Gonzalez (1):
      wimax/i2400m: Add support for more i6x50 SKUs

Jarek Poplawski (1):
      ax25: netrom: rose: Fix timer oopses

Jeff Kirsher (1):
      MAINTAINERS: Add Intel igbvf maintainer

Jesse Brandeburg (3):
      e1000: enhance frame fragment detection
      e1000e: enhance frame fragment detection
      e1000/e1000e: don't use small hardware rx buffers

Jiajun Wu (1):
      ucc_geth: Fix full TX queue processing

Ken Kawasaki (1):
      fmvj18x_cs: add new id (Panasonic lan & modem card)

Matthew Slattery (1):
      sfc: QT202x: Remove unreliable MMD check at initialisation

Mike Frysinger (1):
      bfin_mac: use the newer CLKBUFOE bit name via asm/dpmc.h

Mike McCormack (1):
      sky2: Enable/disable WOL per hardware device

Neil Horman (2):
      dccp_probe: Fix module load dependencies between dccp and dccp_probe
      dccp: fix dccp rmmod when kernel configured to use slub

Ram Vepa (1):
      S2io: two branches the same in wait_for_cmd_complete()

Reinette Chatre (1):
      iwlwifi: add license to tracing files

Roel Kluin (3):
      appletalk:: da.s_net not copied but assigned to itself in aarp_rcv()
      netlink: With opcode INET_DIAG_BC_S_LE dport was compared in inet_diag_bc_run()
      e1000/e1000e/igb/igbvf/ixgb/ixgbe: Fix tests of unsigned in *_tx_map()

Ron Murray (1):
      Please add support for Microsoft MN-120 PCMCIA network card

Samuel Ortiz (1):
      iwmc3200wifi: Add UMAC wifi headers to the pmkid command

Sathya Perla (2):
      be2net: fix bug in rx page posting
      be2net: swap only first 2 fields of mcc_wrb

Sridhar Samudrala (1):
      net: Fix IPv6 GSO type checks in Intel ethernet drivers

Stephen Hemminger (1):
      tcp_probe: avoid modulus operation and wrap fix

Wey-Yi Guy (1):
      iwlwifi: Fix throughput stall issue in HT mode for 5000

stephen hemminger (1):
      sky2: revert config space change

 MAINTAINERS                                  |    8 ++--
 drivers/net/benet/be_cmds.c                  |    2 +-
 drivers/net/benet/be_main.c                  |    8 ++-
 drivers/net/bfin_mac.c                       |    5 +-
 drivers/net/e1000/e1000.h                    |    2 +
 drivers/net/e1000/e1000_main.c               |   43 ++++++---------
 drivers/net/e1000e/e1000.h                   |    1 +
 drivers/net/e1000e/netdev.c                  |   57 ++++++++++----------
 drivers/net/igb/igb_main.c                   |    4 +-
 drivers/net/igbvf/netdev.c                   |   14 +++---
 drivers/net/ixgb/ixgb_main.c                 |   10 ++--
 drivers/net/ixgbe/ixgbe_main.c               |   12 ++--
 drivers/net/pcmcia/fmvj18x_cs.c              |    1 +
 drivers/net/phy/phy.c                        |    4 +-
 drivers/net/phy/phy_device.c                 |    1 +
 drivers/net/qlge/qlge_main.c                 |   15 +++---
 drivers/net/s2io.c                           |    2 +-
 drivers/net/sfc/mcdi.c                       |    7 ++-
 drivers/net/sfc/mcdi.h                       |    1 +
 drivers/net/sfc/mcdi_pcol.h                  |    4 +-
 drivers/net/sfc/mtd.c                        |    5 +-
 drivers/net/sfc/qt202x_phy.c                 |    6 --
 drivers/net/sky2.c                           |   42 ++++++++++++---
 drivers/net/tulip/tulip_core.c               |    1 +
 drivers/net/ucc_geth.c                       |    5 +-
 drivers/net/virtio_net.c                     |    3 +-
 drivers/net/wimax/i2400m/i2400m-usb.h        |    2 +
 drivers/net/wimax/i2400m/usb.c               |   12 ++++-
 drivers/net/wireless/iwlwifi/iwl-5000.c      |    5 ++
 drivers/net/wireless/iwlwifi/iwl-devtrace.c  |   26 +++++++++
 drivers/net/wireless/iwlwifi/iwl-devtrace.h  |   26 +++++++++
 drivers/net/wireless/iwmc3200wifi/commands.c |    4 ++
 drivers/net/wireless/iwmc3200wifi/commands.h |    1 +
 drivers/net/wireless/p54/p54pci.c            |    8 +++
 drivers/net/wireless/zd1211rw/zd_usb.c       |    1 +
 drivers/serial/serial_cs.c                   |    1 +
 include/linux/phy.h                          |    1 +
 include/net/netns/xfrm.h                     |    6 ++
 include/net/netrom.h                         |    2 +
 include/net/xfrm.h                           |    4 +-
 net/8021q/vlan_dev.c                         |    2 +-
 net/appletalk/aarp.c                         |    2 +-
 net/ax25/ax25_out.c                          |    6 ++
 net/dccp/ccid.c                              |   18 ++-----
 net/dccp/ccid.h                              |    2 +
 net/dccp/probe.c                             |    3 +-
 net/ipv4/inet_diag.c                         |    2 +-
 net/ipv4/route.c                             |    2 +
 net/ipv4/tcp_probe.c                         |   19 ++++---
 net/ipv4/xfrm4_policy.c                      |   14 +++--
 net/ipv6/xfrm6_policy.c                      |   25 +++++----
 net/mac80211/cfg.c                           |    3 +
 net/mac80211/rc80211_pid_algo.c              |    2 +-
 net/netrom/nr_route.c                        |   11 ++--
 net/rose/rose_link.c                         |    8 +++
 net/rose/rose_route.c                        |    5 ++
 net/wireless/sme.c                           |    1 +
 net/xfrm/xfrm_policy.c                       |   75 ++++++++++++++++++++++----
 net/xfrm/xfrm_state.c                        |    6 +-
 net/xfrm/xfrm_user.c                         |   14 +++--
 60 files changed, 389 insertions(+), 193 deletions(-)
