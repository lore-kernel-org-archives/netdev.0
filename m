From: David Miller <davem@davemloft.net>
Subject: [GIT] Networking
Date: Thu, 12 Jan 2012 20:22:14 -0800 (PST)
Message-ID: <20120112.202214.1590051930353397791.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


1) Bug fixes in HCI extended features parsing, from Andre Guedes.

2) Many fixed MDIO drivers don't use a unique device name, resulting
   in conflicts.  Generalize to ${PLATFORM_DEVICE_NAME}-${INDEX}.
   From Florian Fainelli.

3) ksz884x driver doesn't handle VLAN properly.  From Doug Kehn.

4) Conversion to rcu_assign_pointer() converted not just NULL cases,
   it converted non-NULL cases too which is wrong.  Partial revert
   from Eric Dumazet.

5) IRQ masking and NAPI handling in via-rhine was buggy and could
   wedge the device, fix this and suspend/resume as well.  From
   Francois Romieu.

6) Jump label optimization of memcg socket memory code was buggy and
   wouldn't actually turn the jump label back on when the feature
   was turned off.  Fix from Glauber Costa.

7) Missing iounmap() calls from Julia Lawall.

8) Fix TX timestamping in gianfar, from Manfred Rudigier.

9) Fix local BH enabling in wrong context when netconsole is used
   over bond_alb, from Maxim Uvarov.

10) Revert accidental user visible datastructure name changes in inet
    diag, from Pavel Emelyanov.

11) Support RED over SFQ, from Eric Dumazet.

Please pull, thanks a lot!

The following changes since commit 2485a4b610171f4e1c4ab0d053569747795c1bbe:

  Merge branch 'for-linus' of git://git.kernel.org/pub/scm/linux/kernel/git/dtor/input (2012-01-12 12:40:41 -0800)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/davem/net.git master

Andre Guedes (5):
      Bluetooth: Rename extfeatures
      Bluetooth: Fix hci_cc_read_local_ext_features()
      Bluetooth: Fix adv_work delay
      Bluetooth: Queue adv_work on system workqueue
      Bluetooth: Fix mgmt_stop_discovery_failed()

Andrei Emeltchenko (1):
      Bluetooth: Correct packet len calculation

Bradley Peterson (1):
      pptp: Accept packet with seq zero

David S. Miller (2):
      Merge branch 'davem-next.via-rhine' of git://violet.fr.zoreil.com/romieu/linux
      Merge branch 'master' of git://git.kernel.org/.../linville/wireless

Doug Kehn (1):
      ksz884x: fix mtu for VLAN

Eric Benard (1):
      net: fsl: fec: handle 10Mbps speed in RMII mode

Eric Dumazet (2):
      net: reintroduce missing rcu_assign_pointer() calls
      net_sched: sfq: add optional RED on top of SFQ

Fabio Estevam (1):
      drivers: isdn: Fix dependency for ISDN_PPP

Florian Fainelli (21):
      ax88796: use an unique MDIO bus name.
      bfin_mac: use an unique MDIO bus name.
      au1000-eth: use an unique MDIO bus name.
      sb1250: use an unique MDIO bus name.
      macb: use an unique MDIO bus name.
      dnet: use an unique MDIO bus name.
      fec: use an unique MDIO bus name.
      lantiq_etop: use an unique MDIO bus name.
      mv643xx-eth: use an unique MDIO bus name.
      pxa168-eth: use an unique MDIO bus name.
      sh-eth: use an unique MDIO bus name.
      s6gmac: use an unique MDIO bus name.
      smsc911x: use an unique MDIO bus name.
      stmmac: use an unique MDIO bus name.
      cpmac: use an unique MDIO bus name.
      davinci_emac: use an unique MDIO bus name.
      ixp4xx-eth: use an unique MDIO bus name.
      bcm63xx_enet: use an unique MDIO bus name.
      phy/fixed: use an unique MDIO bus name.
      mdio-gpio: use an unique MDIO bus name.
      mdio-octeon: use an unique MDIO bus name.

Francois Romieu (7):
      via-rhine: factor out tx_thresh handling
      via-rhine: balance interrupt acknowledge and events retrieval.
      via-rhine: remove useless forward declarations.
      via-rhine: move work from irq handler to softirq and beyond.
      via-rhine: RHINE_WAIT_FOR macro removal.
      via-rhine: per device debug level.
      via-rhine: rework suspend and resume.

Glauber Costa (1):
      net: decrement memcg jump label when limit, not usage, is changed

Gustavo F. Padovan (8):
      Bluetooth: Fix bacpy in l2cap_core.c
      Bluetooth: Fix context in rfcomm_sock_lock
      Bluetooth: Fix context in RFCOMM tty
      Bluetooth: Remove *_bh locks from SCO
      Bluetooth: Remove local_bh_disable() from hci_sock.c
      Bluetooth: Remove *_bh from socket list lock.
      Bluetooth: Don't use *_bh locks anymore
      Bluetooth: Keep chan->state and sk->sk_state in sync

Jesper Juhl (1):
      brcm80211: Don't leak 'vbuffer' in brcmf_sdbrcm_write_vars()

Johannes Berg (1):
      nl80211: fix old station flags compatibility

John W. Linville (1):
      Merge branch 'master' of git://git.kernel.org/.../padovan/bluetooth-next

Julia Lawall (2):
      drivers/net/ethernet/tundra/tsi108_eth.c: add missing iounmap
      drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c: add missing iounmap

Jussi Kivilinna (2):
      asix: fix setting custom MAC address on Asix 88772 devices
      asix: fix setting custom MAC address on Asix 88178 devices

Larry Finger (1):
      rtl8192se: Fix BUG caused by failure to check skb allocation

Manfred Rudigier (3):
      gianfar: Fix missing sock reference when processing TX time stamps
      gianfar: Fix invalid TX frames returned on error queue when time stamping
      dp83640: Fix NOHZ local_softirq_pending 08 warning

Maxim Uvarov (1):
      bond_alb: don't disable softirq under bond_alb_xmit

Mohammed Shafi Shajakhan (1):
      ath9k_hw: fix a comment

Pavel Emelyanov (2):
      inet_diag: Rename inet_diag_req into inet_diag_req_v2
      inet_diag: Rename inet_diag_req_compat into inet_diag_req

Rajkumar Manoharan (1):
      ath9k: Fix regression in channelwidth switch at the same channel

Roland Dreier (1):
      RDS: Remove some unused iWARP code

Stanislaw Gruszka (1):
      mac80211: fix rx->key NULL pointer dereference in promiscuous mode

Stefan Roese (2):
      stmmac: Fix compilation error in mmc_core.c
      stmmac: Add missing LF to pr_info() in stmmac_main.c

Timur Tabi (1):
      phylib: introduce mdiobus_alloc_size()

 drivers/isdn/i4l/Kconfig                           |    2 +-
 drivers/net/bonding/bond_alb.c                     |  112 +++-
 drivers/net/ethernet/8390/ax88796.c                |    3 +-
 drivers/net/ethernet/adi/bfin_mac.c                |    3 +-
 drivers/net/ethernet/amd/au1000_eth.c              |    3 +-
 drivers/net/ethernet/broadcom/bcm63xx_enet.c       |    2 +-
 drivers/net/ethernet/broadcom/sb1250-mac.c         |    3 +-
 drivers/net/ethernet/cadence/macb.c                |    3 +-
 drivers/net/ethernet/dnet.c                        |    3 +-
 drivers/net/ethernet/freescale/fec.c               |   12 +-
 drivers/net/ethernet/freescale/fec.h               |    4 +
 drivers/net/ethernet/freescale/gianfar.c           |   34 +-
 drivers/net/ethernet/freescale/gianfar.h           |    3 +
 drivers/net/ethernet/lantiq_etop.c                 |    5 +-
 drivers/net/ethernet/marvell/mv643xx_eth.c         |    3 +-
 drivers/net/ethernet/marvell/pxa168_eth.c          |    3 +-
 drivers/net/ethernet/micrel/ksz884x.c              |    2 +-
 drivers/net/ethernet/renesas/sh_eth.c              |    3 +-
 drivers/net/ethernet/s6gmac.c                      |    2 +-
 drivers/net/ethernet/smsc/smsc911x.c               |    3 +-
 drivers/net/ethernet/stmicro/stmmac/mmc_core.c     |    1 +
 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c  |    4 +-
 drivers/net/ethernet/stmicro/stmmac/stmmac_mdio.c  |    3 +-
 .../net/ethernet/stmicro/stmmac/stmmac_platform.c  |    2 +-
 drivers/net/ethernet/ti/cpmac.c                    |    2 +-
 drivers/net/ethernet/ti/davinci_mdio.c             |    3 +-
 drivers/net/ethernet/tundra/tsi108_eth.c           |    6 +-
 drivers/net/ethernet/via/via-rhine.c               |  668 +++++++++++---------
 drivers/net/ethernet/xscale/ixp4xx_eth.c           |    2 +-
 drivers/net/phy/dp83640.c                          |    2 +-
 drivers/net/phy/fixed.c                            |    2 +-
 drivers/net/phy/mdio-gpio.c                        |    2 +-
 drivers/net/phy/mdio-octeon.c                      |    3 +-
 drivers/net/phy/mdio_bus.c                         |   24 +-
 drivers/net/ppp/pptp.c                             |    4 +-
 drivers/net/usb/asix.c                             |   15 +
 drivers/net/wireless/ath/ath9k/ar9003_phy.c        |    2 +-
 drivers/net/wireless/ath/ath9k/ath9k.h             |    1 -
 drivers/net/wireless/ath/ath9k/calib.c             |    1 +
 drivers/net/wireless/ath/ath9k/calib.h             |    1 -
 drivers/net/wireless/ath/ath9k/main.c              |    8 +-
 drivers/net/wireless/brcm80211/brcmfmac/dhd_sdio.c |    4 +-
 drivers/net/wireless/rtlwifi/rtl8192se/fw.c        |    4 +
 include/linux/inet_diag.h                          |   14 +-
 include/linux/phy.h                                |    7 +-
 include/linux/pkt_sched.h                          |   20 +
 include/net/bluetooth/hci_core.h                   |    4 +-
 include/net/red.h                                  |    3 +-
 net/bluetooth/af_bluetooth.c                       |    8 +-
 net/bluetooth/hci_event.c                          |   22 +-
 net/bluetooth/hci_sock.c                           |    2 -
 net/bluetooth/l2cap_core.c                         |   26 +-
 net/bluetooth/l2cap_sock.c                         |    2 +
 net/bluetooth/mgmt.c                               |    4 +-
 net/bluetooth/rfcomm/sock.c                        |   12 +-
 net/bluetooth/rfcomm/tty.c                         |   22 +-
 net/bluetooth/sco.c                                |    8 +-
 net/core/net-sysfs.c                               |    6 +-
 net/core/netpoll.c                                 |    2 +-
 net/dccp/diag.c                                    |    4 +-
 net/decnet/dn_dev.c                                |    4 +-
 net/ipv4/devinet.c                                 |    2 +-
 net/ipv4/fib_trie.c                                |   10 +-
 net/ipv4/igmp.c                                    |    8 +-
 net/ipv4/inet_diag.c                               |   42 +-
 net/ipv4/ipip.c                                    |    8 +-
 net/ipv4/ipmr.c                                    |    2 +-
 net/ipv4/tcp_diag.c                                |    4 +-
 net/ipv4/tcp_memcontrol.c                          |    2 +-
 net/ipv4/udp_diag.c                                |   14 +-
 net/ipv6/addrconf.c                                |    2 +-
 net/ipv6/ip6_tunnel.c                              |    8 +-
 net/ipv6/raw.c                                     |    2 +-
 net/ipv6/sit.c                                     |   10 +-
 net/mac80211/agg-rx.c                              |    2 +-
 net/mac80211/cfg.c                                 |    4 +-
 net/mac80211/ibss.c                                |    2 +-
 net/mac80211/sta_info.c                            |    6 +-
 net/mac80211/wpa.c                                 |    2 +-
 net/netfilter/nf_conntrack_core.c                  |    2 +-
 net/netfilter/nf_conntrack_ecache.c                |    4 +-
 net/netfilter/nf_conntrack_extend.c                |    2 +-
 net/netfilter/nf_conntrack_helper.c                |    2 +-
 net/netfilter/nf_conntrack_netlink.c               |    2 +-
 net/netfilter/nf_log.c                             |    6 +-
 net/netfilter/nf_queue.c                           |    2 +-
 net/netfilter/nfnetlink.c                          |    4 +-
 net/netlabel/netlabel_domainhash.c                 |    4 +-
 net/netlabel/netlabel_unlabeled.c                  |    6 +-
 net/phonet/af_phonet.c                             |    2 +-
 net/phonet/pn_dev.c                                |    2 +-
 net/phonet/socket.c                                |    2 +-
 net/rds/iw_rdma.c                                  |   15 +-
 net/sched/sch_sfq.c                                |  146 ++++-
 net/socket.c                                       |    2 +-
 net/sunrpc/auth_gss/auth_gss.c                     |    2 +-
 net/wireless/nl80211.c                             |   34 +-
 net/xfrm/xfrm_user.c                               |    2 +-
 98 files changed, 925 insertions(+), 588 deletions(-)
