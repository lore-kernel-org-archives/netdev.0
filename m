From: David Miller <davem@davemloft.net>
Subject: [GIT] Networking
Date: Sun, 22 Apr 2012 22:28:11 -0400 (EDT)
Message-ID: <20120422.222811.252393185353944111.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


1) Fix namespace init and cleanup in phonet to fix some oopses, from
   Eric W. Biederman.

2) Missing kfree_skb() in AF_KEY, from Julia Lawall.

3) Refcount leak and source address handling fix in l2tp from
   James Chapman.

4) Memory leak fix in CAIF from Tomasz Gregorek.

5) When routes are cloned from ipv6 addrconf routes, we don't
   process expirations properly.  Fix from Gao Feng.

6) Fix panic on DMA errors in atl1 driver, from Tony Zelenoff.

7) Only enable interrupts in 8139cp driver after we've
   registered the IRQ handler.  From Jason Wang.

8) Fix too many reads of KS_CIDER register in ks8851 during
   probe, fixing crashes on spurious interrupts.  From
   Matt Renzelmann.

9) Missing include in ath5k driver and missing iounmap on probe
   failure, from Jonathan Bither.

10) Fix RX packet handling in smsc911x driver, from Will Deacon.

11) Fix ixgbe WoL on fiber by leaving the laser on during shutdown.

12) ks8851 needs MAX_RECV_FRAMES increased otherwise the internal
    MAC buffers are easily overflown.  Fix from Davide Cimingahi.

13) Fix memory leaks in peak_usb CAN driver, from Jesper Juhl.

14) gred packet scheduler can dump in WRED more when doing a
    netlink dump.  Fix from David Ward.

15) Fix MTU in USB smsc75xx driver, from Stephane Fillod.

16) Dummy device needs ->ndo_uninit handler to properly handle
    ->ndo_init failures.  From Hiroaki SHIMODA.

17) Fix TX fragmentation in ath9k driver, from Sujith Manoharan.

18) Missing RTNL lock in ixgbe PM resume, from Benjamin Poirier.

19) Missing iounmap in farsync WAN driver, from Julia Lawall.

20) With LRO/GRO, tcp_grow_window() is easily tricked into not growing
    the receive window properly, and this hurts performance.  Fix
    from Eric Dumazet.

21) Network namespace init failure can leak net_generic data, fix
    from Julian Anastasov.

22) Fix skb_over_panic due to mis-accounting in TCP for partially
    ACK'd SKBs.  From Eric Dumazet.

23) New IDs for qmi_wwan driver, from Bj=F8rn Mork.

24) Fix races in ax25_exit(), from Eric W. Biederman.

25) IPV6 TCP doesn't handle TCP_MAXSEG socket option properly, copy
    over logic from the IPV4 side.  From Neal Cardwell.

Please pull, thanks a lot!

The following changes since commit 66f75a5d028beaf67c931435fdc3e7823125=
730c:

  Linux 3.4-rc4 (2012-04-21 14:47:52 -0700)

are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/davem/net.git master

Alexander Duyck (1):
      ixgbe: Identify FCoE rings earlier to resolve memory corruption w=
/ FCoE

Amitkumar Karwar (1):
      libertas: fix signedness bug in lbs_auth_to_authtype()

Arend van Spriel (1):
      brcm80211: smac: resume transmit fifo upon receiving frames

Benjamin Poirier (1):
      ixgbe: add missing rtnl_lock in PM resume path

Bing Zhao (1):
      mwifiex: update pcie8766 scratch register addresses

Bj=F8rn Mork (1):
      net: qmi_wwan: support Sierra Wireless MC77xx devices in QMI mode

Bruce Allan (1):
      e1000e: issues in Sx on 82577/8/9

Christian Riesch (1):
      davinci_mdio: Fix MDIO timeout check

Dan Carpenter (2):
      ksz884x: don't copy too much in netdev_set_mac_address()
      bnx2x: off by one in bnx2x_ets_e3b0_sp_pri_to_cos_set()

David S. Miller (2):
      Merge branch 'master' of git://git.kernel.org/.../jkirsher/net
      Merge branch 'for-davem' of git://git.kernel.org/.../linville/wir=
eless

David Ward (2):
      net_sched: gred: Fix oops in gred_dump() in WRED mode
      net_sched: red: Make minor corrections to comments

David Woodhouse (1):
      ppp: Fix race condition with queue start/stop

Davide Ciminaghi (1):
      net/ethernet: ks8851_mll fix rx frame buffer overflow

Don Skidmore (1):
      ixgbe: fix WoL issue with fiber

Eric Dumazet (3):
      tcp: fix tcp_grow_window() for large incoming frames
      tcp: fix retransmit of partially acked frames
      drop_monitor: allow more events per second

Eric W. Biederman (3):
      net: In unregister_netdevice_notifier unregister the netdevices.
      phonet: Sort out initiailziation and cleanup code.
      net ax25: Reorder ax25_exit to remove races.

=46elix Fietkau (3):
      ath9k: wake up the hardware from full sleep when idle is turned o=
ff
      mac80211: fix truncated packets in cooked monitor rx
      mac80211: fix logic error in ibss channel type check

Gao feng (1):
      ipv6: fix problem with expired dst cache

Giuseppe CAVALLARO (1):
      icplus: fix interrupt for IC+ 101A/G and 1001LF

Hauke Mehrtens (1):
      bcma: use fallback sprom if no on chip sprom is available

Hiroaki SHIMODA (1):
      dummy: Add ndo_uninit().

James Chapman (2):
      l2tp: fix refcount leak in l2tp_ip sockets
      l2tp: don't overwrite source address in l2tp_ip_bind()

Jason Wang (1):
      8139cp: set intr mask after its handler is registered

Jesper Juhl (1):
      can: usb: PCAN-USB Pro: fix mem leaks in pcan_usb_pro_init() on e=
rror paths

Jiri Bohac (2):
      ipv6: fix rt6_update_expires
      ipv6: clean up rt6_clean_expires

Jiri Kosina (1):
      arcnet: rimi: Fix device name in debug output

John W. Linville (1):
      Merge branch 'master' of git://git.kernel.org/.../linville/wirele=
ss into for-davem

Jonathan Bither (2):
      ath5k: fix undefined 'THIS_MODULE'
      ath5k: unmap io memory on probe failure

Julia Lawall (2):
      net/key/af_key.c: add missing kfree_skb
      drivers/net/wan/farsync.c: add missing iounmap

Julian Anastasov (1):
      netns: do not leak net_generic data on failed init

Kim Lilliestierna XX (1):
      caif_hsi: use dev_dbg not dev_err for reporting

Lee Jones (1):
      drivers/net: Do not free an IRQ if its request failed

Lukasz Kucharczyk (1):
      cfg80211: fix interface combinations check.

Matt Renzelmann (2):
      ks8851: Fix missing mutex_lock/unlock
      ks8851: Fix request_irq/free_irq mismatch

Michael S. Tsirkin (1):
      skbuff: struct ubuf_info callback type safety

Michal Simek (1):
      drivers/net/ethernet/xilinx/axi ethernet: Correct Copyright

Neal Cardwell (1):
      tcp: fix TCP_MAXSEG for established IPv6 passive sockets

Randy Dunlap (1):
      net/sock.h: fix sk_peek_off kernel-doc warning

Stephane Fillod (1):
      net: usb: smsc75xx: fix mtu

Stephen Boyd (1):
      ks8851: Fix mutex deadlock in ks8851_net_stop()

Sujith Manoharan (1):
      ath9k: Fix TX fragmentation

Tomasz Gregorek (1):
      caif: Fix memory leakage in the chnl_net.c.

Tony Zelenoff (1):
      atl1: fix kernel panic in case of DMA errors

Torsten Kaiser (1):
      net: Fix misplaced parenthesis in virtio_net.c

Wenqi Ma (1):
      net/hyperv: Adding cancellation to ensure rndis filter is closed

Wey-Yi Guy (1):
      MAINTAINERS: Add maintainer for iwlwifi

Will Deacon (1):
      net: smsc911x: fix skb handling in receive path

sjur.brandeland@stericsson.com (1):
      caif-hsi: Free flip_buffer at shutdown

 MAINTAINERS                                       |    5 +-
 drivers/bcma/sprom.c                              |    7 ++-
 drivers/net/arcnet/arc-rimi.c                     |    8 +-
 drivers/net/caif/caif_hsi.c                       |    9 ++-
 drivers/net/can/usb/peak_usb/pcan_usb_pro.c       |    2 +
 drivers/net/dummy.c                               |    6 +-
 drivers/net/ethernet/atheros/atlx/atl1.c          |   12 ++--
 drivers/net/ethernet/atheros/atlx/atl1.h          |    3 +-
 drivers/net/ethernet/atheros/atlx/atlx.c          |    2 +-
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c  |   12 ++--
 drivers/net/ethernet/intel/e1000e/ich8lan.c       |   15 +++--
 drivers/net/ethernet/intel/ixgbe/ixgbe_lib.c      |   10 +++
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c     |   20 ++++---
 drivers/net/ethernet/micrel/ks8851.c              |   21 +++---
 drivers/net/ethernet/micrel/ks8851_mll.c          |    2 +-
 drivers/net/ethernet/micrel/ksz884x.c             |    2 +-
 drivers/net/ethernet/realtek/8139cp.c             |   10 +++-
 drivers/net/ethernet/smsc/smsc911x.c              |   17 ++---
 drivers/net/ethernet/ti/davinci_mdio.c            |    5 ++
 drivers/net/ethernet/xilinx/xilinx_axienet.h      |    4 +-
 drivers/net/ethernet/xilinx/xilinx_axienet_main.c |    6 +-
 drivers/net/ethernet/xilinx/xilinx_axienet_mdio.c |    6 +-
 drivers/net/hyperv/netvsc_drv.c                   |   38 ++++-------
 drivers/net/phy/icplus.c                          |   12 +++-
 drivers/net/ppp/ppp_generic.c                     |   15 ++---
 drivers/net/usb/qmi_wwan.c                        |   30 +++++++++
 drivers/net/usb/smsc75xx.c                        |    1 +
 drivers/net/virtio_net.c                          |    5 +-
 drivers/net/wan/farsync.c                         |    1 +
 drivers/net/wireless/ath/ath5k/ahb.c              |    7 ++-
 drivers/net/wireless/ath/ath9k/main.c             |    9 +++-
 drivers/net/wireless/ath/ath9k/xmit.c             |   10 +++-
 drivers/net/wireless/brcm80211/brcmsmac/main.c    |    8 +++
 drivers/net/wireless/libertas/cfg.c               |    9 ++-
 drivers/net/wireless/mwifiex/pcie.h               |   18 +++---
 drivers/vhost/net.c                               |    2 +-
 drivers/vhost/vhost.c                             |    5 +-
 drivers/vhost/vhost.h                             |    2 +-
 include/linux/skbuff.h                            |    7 +-
 include/net/dst.h                                 |    6 ++-
 include/net/ip6_fib.h                             |   48 +++++++++++++=
+
 include/net/red.h                                 |    6 +-
 include/net/sock.h                                |    1 +
 net/ax25/af_ax25.c                                |    9 ++-
 net/caif/chnl_net.c                               |    9 ++-
 net/core/dev.c                                    |   20 ++++++
 net/core/drop_monitor.c                           |    1 +
 net/core/net_namespace.c                          |   33 +++++-----
 net/ipv4/tcp_input.c                              |    1 +
 net/ipv4/tcp_output.c                             |    1 +
 net/ipv6/addrconf.c                               |    9 +--
 net/ipv6/ip6_fib.c                                |    9 +--
 net/ipv6/ndisc.c                                  |    3 +-
 net/ipv6/route.c                                  |   71 +++++++++++++=
--------
 net/ipv6/tcp_ipv6.c                               |    4 +
 net/key/af_key.c                                  |    2 +-
 net/l2tp/l2tp_ip.c                                |    5 +-
 net/mac80211/ibss.c                               |    4 +-
 net/mac80211/rx.c                                 |   10 ++-
 net/phonet/pn_dev.c                               |   21 +------
 net/sched/sch_gred.c                              |    7 +--
 net/wireless/util.c                               |    2 +-
 62 files changed, 407 insertions(+), 238 deletions(-)
