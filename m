From: David Miller <davem@davemloft.net>
Subject: [GIT] Networking
Date: Tue, 14 Dec 2010 12:39:17 -0800 (PST)
Message-ID: <20101214.123917.183056983.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


A lot of small stuff has queued up while you were away.

1) Revert a pppoe change that causes SKBs to be accessed after
   being freed, from Andrej Ota.

2) SFC driver crash and list corruption fixes from Ben Hutchings.

3) EHEA driver needs to respect ethtool enable/disable LRO requests
   otherwise bridging and routing won't work properly, from
   Breno Leitao.

4) x25 device refcount leak fix from Apollon Oikonomopoulos.

5) Endian fixes in LSO code in bnx2x driver from Vladislav Zolotarov.

6) stmmac driver uses spinlock uninitialized, from Vlad Lungu.

7) enic driver passes wrong pointer to IRQ handler, from Vasanthy Kolluri.

8) TCP time-wait bucket message can spam logs, use event counter instead.
   From Tom Herbert.

9) IPSEC code leaks in error path of xfrm_state_migrate(), fix from
   Thomas Egerer.

10) Elide checksumming offload on GE0301 option HSO cards
    From Thomas Bogendoerfer.

11) Runtime PM fix in r8169 from Rafael J. Wysocki.

12) Netlink group improperly choosen during ipv6 net link advertisement.
    Fix frm Nicolas Dichtel.

13) Improper cleanup in econet's SIOCSIFADDR ioctl code.

14) benet driver loads mac addresses incorrectly due to improperly
    coded memcpy() call, fix from Joe Jin.

15) Several fixes from Eric Dumazet:

    a) sk_filter() hits RCU incorrectly
    b) llc leaks netdevices
    c) obscure sysctl settings can make tcp divide by zero
    d) Use ACCESS_ONCE() when reading sysctl_tcp_cookie_size
       multiple times
    e) Fix crash when skb_defer_rx_timestamp() encounters a packet
       lacking a link-level header.

16) ECONET aun_incoming() makes bogus unconditional deref of skb->dev,
    it should use dst->dev when 'dst' is non-NULL instead.

17) Blocking mechanism for bonding netpoll support via a cpumask is
    busted, use a counter instead.  From Neil Horman.

18) SCTP_SET_PEER_PRIMARY_ADDR erroneously does not accept ipv4-mapped	
    ipv6 addresses, fix from Wei Yongjun.

19) ATM layer creates sysfs device links with bogus parent relationships,
    fix from Dan Williams.

20) Fix deadlock in qlge, from Ron Mercer.

21) Several bluetooth fixes:
    a) Fix error propagation from sco_connect_ind(), sco_connect_cfm(), and
       sco_disconn_cfm().
    b) fix btusb log spam during autosuspend
    c) Add USB device ID for Atheros 3011

22) Fix bonding regression in MAC address assignment behavior, from
    David Strand.

23) IPV6 over IPV4 tunnel fix from David McCullough.  SIT driver was
    consuming all the packets and sending ICMP port unreachables out.

24) Various ath9k, mac80211, orinoco, libertas et al. fixes via John
    Linville and the wireless team.

25) Fix NULL deref during ixgbe shutdown, from Don Skidmore.

26) TCP receive window initialization boundary checks improperly
    coded, fix from Nandita Dukkipati.

27) IFB transmit queue can deadlock, fix from Changli Gao.

28) Modalias fixes in l2tp and connector.

29) IPv6 tunnel uses incorrect MTU when encap limit is enabled, fix from
    Anders Franzen.

30) VHOST dirty page logging traversal fix from Michael S. Tsirkin.

Please pull, thanks a lot!

The following changes since commit bcb38ceb225f5d5b2198a2755277cd441ed1e82b:

  Revert "debug_locks: set oops_in_progress if we will log messages." (2010-11-29 15:18:28 -0800)

are available in the git repository at:
  master.kernel.org:/pub/scm/linux/kernel/git/davem/net-2.6.git master

Alexander V. Lukyanov (1):
      tulip: fix hang in dmfe driver on sending of big packet

Anders Franzen (1):
      Make the ip6_tunnel reflect the true mtu.

Andrej Ota (1):
      pppoe.c: Fix kernel panic caused by __pppoe_xmit

Apollon Oikonomopoulos (1):
      x25: decrement netdev reference counts on unload

Bala Shanmugam (1):
      Bluetooth: Add new PID for Atheros 3011

Ben Hutchings (2):
      sfc: Fix crash in legacy onterrupt handler during ring reallocation
      sfc: Fix NAPI list corruption during ring reallocation

Breno Leitao (1):
      ehea: Fixing LRO configuration

Casey Leedom (1):
      cxgb4vf: Ingress Queue Entry Size needs to be 64 bytes

Changli Gao (1):
      ifb: goto resched directly if error happens and dp->tq isn't empty

Christian Lamparter (2):
      carl9170: fix carl9170_tx_prepare typo
      mac80211: ignore non-bcast mcast deauth/disassoc franes

Dan Williams (1):
      atm: correct sysfs 'device' link creation and parent relationships

Daniel Drake (1):
      libertas: fix memory corruption in lbs_remove_card()

David Kilroy (4):
      orinoco: abort scan on interface down
      orinoco: initialise priv->hw before assigning the interrupt
      orinoco: clear countermeasure setting on commit
      orinoco: fix TKIP countermeasure behaviour

David McCullough (1):
      net/ipv6/sit.c: return unhandled skb to tunnel4_rcv

David S. Miller (5):
      Merge branch 'master' of git://git.kernel.org/.../linville/wireless-2.6
      Merge branch 'sfc-2.6.37' of git://git.kernel.org/.../bwh/sfc-2.6
      econet: Fix crash in aun_incoming().
      Merge branch 'master' of git://git.kernel.org/.../linville/wireless-2.6
      Merge branch 'vhost-net' of git://git.kernel.org/.../mst/vhost

David Strand (1):
      bonding: check for assigned mac before adopting the slaves mac address

Dimitris Michailidis (1):
      cxgb4: fix MAC address hash filter

Don Skidmore (1):
      ixgbe: fix possible NULL pointer deference in shutdown path

Eric Dumazet (5):
      filter: fix sk_filter rcu handling
      llc: fix a device refcount imbalance
      tcp: avoid a possible divide by zero
      tcp: protect sysctl_tcp_cookie_size reads
      net: fix skb_defer_rx_timestamp()

Felix Fietkau (3):
      ath9k_hw: fix endian issues with CTLs on AR9003
      ath9k_hw: fix more bitfield related endian issues
      ath9k: fix a DMA related race condition on reset

Gabor Juhos (1):
      ath9k: use per-device struct for pm_qos_* operations

Giuseppe CAVALLARO (1):
      phy: add the IC+ IP1001 driver

Gustavo F. Padovan (1):
      Bluetooth: Fix not returning proper error in SCO

Hauke Mehrtens (1):
      b44: fix workarround for wap54g10

Helmut Schaa (1):
      mac80211: Fix BUG in pskb_expand_head when transmitting shared skbs

Javier Cardona (3):
      ath5k: Fix beaconing in mesh mode
      ath5k: Prevent mesh interfaces from being counted as ad-hoc
      ath5k: Put the right tsf value in mesh beacons

Joe Jin (1):
      driver/net/benet: fix be_cmd_multicast_set() memcpy bug

Johannes Berg (1):
      ath9k/carl9170: advertise P2P

John W. Linville (2):
      Merge branch 'master' of git://git.kernel.org/.../padovan/bluetooth-2.6
      Revert "ath9k: Fix STA disconnect issue due to received MIC failed bcast frames"

Jouni Malinen (1):
      mac80211: Fix frame injection using non-AP vif

Kim Lilliestierna XX (1):
      CAIF: Fix U5500 compile error for shared memory driver

Krzysztof Halasa (1):
      WAN: Fix a TX IRQ causing BUG() in PC300 and PCI200SYN drivers.

Kyle McMartin (1):
      MAINTAINERS: remove me from tulip

Martin Lucina (1):
      net: Document the kernel_recvmsg() function

Matteo Croce (1):
      ath9k: fix bug in tx power

Michael S. Tsirkin (1):
      vhost: correctly set bits of dirty pages

Michal Marek (1):
      l2tp: Fix modalias of l2tp_ip

Nandita Dukkipati (1):
      tcp: Bug fix in initialization of receive window.

Neil Horman (1):
      net: Convert netpoll blocking api in bonding driver to be a counter

Nelson Elhage (1):
      econet: Do the correct cleanup after an unprivileged SIOCSIFADDR.

Nicolas Dichtel (1):
      ipv6: fix nl group when advertising a new link

Rafael J. Wysocki (1):
      r8169: Fix runtime power management

Rajkumar Manoharan (2):
      ath9k: Disable SWBA interrupt on remove_interface
      ath9k: fix beacon resource related race condition

Ron Mercer (1):
      qlge: Fix deadlock when cancelling worker.

Senthil Balasubramanian (3):
      mac80211: Fix STA disconnect due to MIC failure
      ath9k: Fix STA disconnect issue due to received MIC failed bcast frames
      ath9k: Fix STA disconnect issue due to received MIC failed bcast frames

Stefan Seyfried (1):
      Bluetooth: Fix log spamming in btusb due to autosuspend

Stephen Hemminger (1):
      connector: add module alias

Sujith Manoharan (1):
      ath9k_htc: Fix suspend/resume

Sven Neumann (1):
      libertas: fix invalid access

Thomas Bogendoerfer (1):
      hso: IP checksuming doesn't work on GE0301 option cards

Thomas Egerer (1):
      xfrm: Fix xfrm_state_migrate leak

Tom Herbert (1):
      tcp: Replace time wait bucket msg by counter

Vasanthakumar Thiagarajan (1):
      ath9k: Fix bug in reading input gpio state for ar9003

Vasanthy Kolluri (1):
      enic: Bug Fix: Pass napi reference to the isr that services receive queue

Vlad Lungu (1):
      stmmac: priv->lock can be used uninitialized

Vladislav Zolotarov (3):
      bnx2x: LSO code was broken on BE platforms
      bnx2x: Fixed a compilation warning
      bnx2x: Advance a version number to 1.60.01-0

Wei Yongjun (1):
      SCTP: Fix SCTP_SET_PEER_PRIMARY_ADDR to accpet v4mapped address

 MAINTAINERS                                    |    1 -
 drivers/atm/adummy.c                           |    2 +-
 drivers/atm/ambassador.c                       |    3 +-
 drivers/atm/atmtcp.c                           |    2 +-
 drivers/atm/eni.c                              |    2 +-
 drivers/atm/firestream.c                       |    2 +-
 drivers/atm/fore200e.c                         |   14 ++--
 drivers/atm/he.c                               |    2 +-
 drivers/atm/horizon.c                          |    3 +-
 drivers/atm/idt77252.c                         |    3 +-
 drivers/atm/iphase.c                           |    2 +-
 drivers/atm/lanai.c                            |    2 +-
 drivers/atm/nicstar.c                          |    3 +-
 drivers/atm/solos-pci.c                        |    8 +-
 drivers/atm/zatm.c                             |    2 +-
 drivers/bluetooth/ath3k.c                      |    4 +
 drivers/bluetooth/btusb.c                      |   12 +++-
 drivers/connector/connector.c                  |    1 +
 drivers/net/b44.c                              |   11 ++--
 drivers/net/benet/be_cmds.c                    |    2 +-
 drivers/net/bnx2x/bnx2x.h                      |    4 +-
 drivers/net/bnx2x/bnx2x_cmn.c                  |   42 ++++++++-----
 drivers/net/bnx2x/bnx2x_init_ops.h             |    4 +-
 drivers/net/bonding/bond_main.c                |   19 ++----
 drivers/net/bonding/bonding.h                  |   12 +---
 drivers/net/caif/caif_shm_u5500.c              |    2 +-
 drivers/net/caif/caif_shmcore.c                |    2 +-
 drivers/net/cxgb4/t4_hw.c                      |    2 +-
 drivers/net/cxgb4vf/cxgb4vf_main.c             |   15 ++++-
 drivers/net/ehea/ehea_ethtool.c                |    9 +++
 drivers/net/ehea/ehea_main.c                   |    7 ++-
 drivers/net/enic/enic_main.c                   |    3 +-
 drivers/net/ifb.c                              |    2 +
 drivers/net/ixgbe/ixgbe_main.c                 |    3 +
 drivers/net/phy/Kconfig                        |    2 +-
 drivers/net/phy/icplus.c                       |   59 +++++++++++++++++--
 drivers/net/pppoe.c                            |    2 +-
 drivers/net/qlge/qlge.h                        |    1 +
 drivers/net/qlge/qlge_main.c                   |    1 +
 drivers/net/qlge/qlge_mpi.c                    |   12 +---
 drivers/net/r8169.c                            |   26 +++++---
 drivers/net/sfc/efx.c                          |   43 +++++++++-----
 drivers/net/sfc/net_driver.h                   |    2 +
 drivers/net/sfc/nic.c                          |    6 ++
 drivers/net/stmmac/stmmac_main.c               |    4 +-
 drivers/net/tulip/dmfe.c                       |    6 +-
 drivers/net/usb/hso.c                          |    4 -
 drivers/net/wan/hd64572.c                      |    5 +-
 drivers/net/wireless/ath/ath5k/base.c          |   13 +++--
 drivers/net/wireless/ath/ath9k/ar9003_eeprom.c |   73 ++++++++++++-----------
 drivers/net/wireless/ath/ath9k/ar9003_eeprom.h |    9 +--
 drivers/net/wireless/ath/ath9k/ath9k.h         |    6 +-
 drivers/net/wireless/ath/ath9k/eeprom.c        |    6 +-
 drivers/net/wireless/ath/ath9k/eeprom.h        |   27 +++++----
 drivers/net/wireless/ath/ath9k/eeprom_def.c    |   23 +++++---
 drivers/net/wireless/ath/ath9k/hif_usb.c       |    7 ++
 drivers/net/wireless/ath/ath9k/htc.h           |    3 +
 drivers/net/wireless/ath/ath9k/htc_drv_init.c  |    6 ++
 drivers/net/wireless/ath/ath9k/htc_drv_main.c  |    4 +-
 drivers/net/wireless/ath/ath9k/hw.c            |    3 +-
 drivers/net/wireless/ath/ath9k/init.c          |    9 +--
 drivers/net/wireless/ath/ath9k/mac.c           |    3 +-
 drivers/net/wireless/ath/ath9k/main.c          |   28 +++++----
 drivers/net/wireless/ath/ath9k/recv.c          |    9 +++-
 drivers/net/wireless/ath/ath9k/reg.h           |    6 +-
 drivers/net/wireless/ath/ath9k/xmit.c          |   22 ++-----
 drivers/net/wireless/ath/carl9170/fw.c         |    3 +-
 drivers/net/wireless/ath/carl9170/main.c       |    3 +-
 drivers/net/wireless/ath/carl9170/tx.c         |    2 +-
 drivers/net/wireless/libertas/if_sdio.c        |    1 -
 drivers/net/wireless/libertas/if_spi.c         |    1 -
 drivers/net/wireless/libertas/main.c           |    2 -
 drivers/net/wireless/orinoco/main.c            |   18 ++++--
 drivers/net/wireless/orinoco/orinoco_cs.c      |   14 ++--
 drivers/net/wireless/orinoco/scan.c            |    8 +++
 drivers/net/wireless/orinoco/scan.h            |    1 +
 drivers/net/wireless/orinoco/spectrum_cs.c     |   14 ++--
 drivers/net/wireless/orinoco/wext.c            |    4 +-
 drivers/usb/atm/usbatm.c                       |   15 +----
 drivers/vhost/vhost.c                          |    3 +-
 include/linux/atmdev.h                         |    6 +-
 include/linux/snmp.h                           |    1 +
 include/net/sock.h                             |    4 +-
 net/atm/atm_sysfs.c                            |    3 +-
 net/atm/resources.c                            |    7 +-
 net/atm/resources.h                            |    2 +-
 net/bluetooth/sco.c                            |    6 +-
 net/core/filter.c                              |   19 ++----
 net/core/timestamping.c                        |    6 +-
 net/econet/af_econet.c                         |   12 +++-
 net/ipv4/proc.c                                |    1 +
 net/ipv4/tcp_minisocks.c                       |    2 +-
 net/ipv4/tcp_output.c                          |   42 ++++++++------
 net/ipv6/addrconf.c                            |    4 +-
 net/ipv6/ip6_tunnel.c                          |    7 ++
 net/ipv6/sit.c                                 |    3 +-
 net/l2tp/l2tp_ip.c                             |    6 ++-
 net/llc/af_llc.c                               |    5 +-
 net/mac80211/rx.c                              |    6 ++
 net/mac80211/tx.c                              |   28 ++++++++-
 net/sctp/socket.c                              |    8 +++
 net/socket.c                                   |   15 +++++
 net/x25/x25_link.c                             |    1 +
 net/xfrm/xfrm_state.c                          |    2 +-
 104 files changed, 569 insertions(+), 353 deletions(-)
