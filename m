From: David Miller <davem@davemloft.net>
Subject: [GIT]: Networking
Date: Wed, 22 Apr 2009 03:48:02 -0700 (PDT)
Message-ID: <20090422.034802.154191032.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:40413
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751652AbZDVKsJ convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 22 Apr 2009 06:48:09 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


1) The usual assortment of several small wired driver fixes.

   CXGB3 link fault, workqueue lockup, MSI-X leak, EEH fixes from Divy =
Le Ray
   MACB retry limit and interrupt status loss fixes from Eric Waling
   UCC_GETH RMII PHY mode fix from Heiko Schocher
   TG3 final fix for the endian-corrupted MAC issue from Matt Carlson.
   IXGBE chip settings fix for 82599 from P. J. Waskiewicz.
   "(!x & y)" --> "(!(x & y))" fix in IXGBE from Tony Breeds
   TX queue restart fix in e1000e from Jesse Brandeburg
   ->hard_start_xmit() exit bug fix in e1000, also from Jesse
   MLX4_EN workqueue cleanup on error fix from Roland Dreier.
   MLX4_EN RX ring error, restart race, TX checksum and statistic bug
   fixes from Yevgeny Petrilin.

2) Wireless driver bug fixes via John Linville.

   The Intel WIFI updates are non-trivial but it seems that they are
   finally having a handle on the DMA memory corruption issues.  All
   problems spotted by the DMA-API debugger seem to be cured, and some
   debugging facilities have been added on the TX side to help track
   down any problems that remain.

3) TCP write-queue adjustment fix from Ilpo J=E4rvinen.

4) GRO/TUN fixes from Herbert Xu.

   SKB use after free in GRO code
   TUN reference to wait queue object after released
   TUN Netdev release adjustment to facilitate wait queue fix

5) netem packet scheduler timestamp handling fix from Jarek Poplawski

6) Alan unintentionally broke socket locking in netrom, fix from
   Jean Delvare.

7) Netowrking MAINTAINERS file tidy from Joe Perches.

8) VLAN/MACVLAN OOPS'er fix from Patrick McHardy.

9) Netfilter fixes from Pablo Neira Ayuso (ctnetlink and nfnetlink),
   Patrick McHardy (conntrack helper unload crash, NAT regression
   fix wrt. SNAT), and Eric Dumazet (nf_log regression).

10) AX25 procfs regression fix from Alan Cox, header line missing from
    output.

11) S390 IUCV protocol bug fixes from Ursula Braun and Hendrik Brueckne=
r.

Please pull, thanks a lot!

The following changes since commit 091069740304c979f957ceacec39c461d019=
2158:
  Linus Torvalds (1):
        Linux 2.6.30-rc3

are available in the git repository at:

  master.kernel.org:/pub/scm/linux/kernel/git/davem/net-2.6.git master

Alan Cox (1):
      ax25: proc uid file misses header

Ben Hutchings (1):
      net: Fix GRO for multiple page fragments

Christian Lamparter (7):
      p54: replace MAC80211_LEDS with P54_LEDS in p54.h
      p54spi: fix locking warning in p54spi_op_tx
      ar9170: add Cace Airpcap NX usb_id
      p54usb: add Telsey 802.11g USB2.0 Adapter
      ar9170usb: add ZyXEL NWD271N
      p54: deactivate broken powersave function
      ar9170usb: fix hang on resume

Dan Williams (1):
      airo: queue SIOCSIWAUTH-requested auth mode change for next commi=
t

David S. Miller (5):
      Merge branch 'master' of git://git.kernel.org/.../kaber/nf-2.6
      Merge branch 'master' of git://git.kernel.org/.../kaber/nf-2.6
      Merge branch 'master' of git://git.kernel.org/.../linville/wirele=
ss-2.6
      Merge branch 'master' of git://git.kernel.org/.../holtmann/blueto=
oth-2.6
      Merge branch 'master' of git://git.kernel.org/.../linville/wirele=
ss-2.6

Divy Le Ray (4):
      cxgb3: fix link fault handling
      cxgb3: fix workqueue flush issues
      cxgb3: Fix potential msi-x vector leak
      cxgb3: Fix EEH final recovery attempt

Eric Dumazet (1):
      netfilter: nf_log regression fix

Erik Waling (2):
      macb: Handle Retry Limit Exceeded errors
      macb: process the RX ring regardless of interrupt status

Gerrit Renker (1):
      mac80211: Fragmentation threshold (typo)

Heiko Schocher (1):
      ucc_geth.c: Fix upsmr setting in RMII mode

Hendrik Brueckner (4):
      af_iucv: fix oops in iucv_sock_recvmsg() for MSG_PEEK flag
      af_iucv: Reject incoming msgs if RECV_SHUTDOWN is set
      af_iucv: Test additional sk states in iucv_sock_shutdown
      af_iucv: Fix race when queuing incoming iucv messages

Herbert Xu (3):
      gro: Fix use after free in tcp_gro_receive
      tun: Only free a netdev when all tun descriptors are closed
      tun: Fix sk_sleep races when attaching/detaching

Herton Ronaldo Krzesinski (1):
      rt2x00: prevent double kfree when failing to register hardware

Ilpo J=E4rvinen (1):
      tcp: fix mid-wq adjustment helper

Ivo van Doorn (2):
      rt2x00: Add rt73usb USB IDs
      rt2x00: Don't free register information on suspend

Jamie Lentin (1):
      at76c50x-usb: Add device ID for OQO model 01+

Jarek Poplawski (1):
      net: sch_netem: Fix an inconsistency in ingress netem timestamps.

Jay Sternberg (1):
      iwlwifi: fix EEPROM validation mask to include OTP only devices

Jean Delvare (1):
      net/netrom: Fix socket locking

Jesse Brandeburg (2):
      e1000e: fix bug in restart queue logic
      e1000: fix transmit routine exit bug

Jianjun kong (1):
      8139too: fix HW initial flow

Joe Perches (3):
      MAINTAINERS - Add section NETWORKING DRIVERS
      MAINTAINERS - Update NETWORKING W: url and standardize T: git url
      iwl3945-base.c: Add missing space to debug print

Joerg Albert (1):
      mwl8k: fix module re-insertion bug

Johan Hedberg (1):
      Bluetooth: Fix removing of RFCOMM DLC timer with DEFER_SETUP

Johannes Berg (10):
      mac80211: correct wext transmit power handler
      fix iwl3945 registration regression
      ar9170: fix struct layout on arm
      mac80211: avoid crashing when no scan sdata
      cfg80211: copy hold when replacing BSS
      cfg80211: do not replace BSS structs
      mac80211: validate TIM IE length
      mac80211: fix basic rate bitmap calculation
      atmel: fix netdev ops conversion
      mac80211: fix alignment calculation bug

Jouni Malinen (1):
      nl80211: Make nl80211_send_mlme_event() atomic

Kalle Valo (1):
      mac80211: fix beacon loss detection after scan

Ken Kawasaki (1):
      pcnet_cs: add cis(firmware) of the Allied Telesis LA-PCM

Luis R. Rodriguez (1):
      cfg80211: fix NULL pointer deference in reg_device_remove()

Marcel Holtmann (2):
      Bluetooth: Fallback from eSCO to SCO on unspecified error
      Bluetooth: Add workaround for wrong HCI event in eSCO setup

Marcin Slusarz (1):
      net: fix "compatibility" typos

Masakazu Mokuno (1):
      net/ps3: Fix wireless AP connect error handling

Matt Carlson (1):
      tg3: Fix SEEPROM accesses

Michael Buesch (4):
      b43: Poison RX buffers
      b43: Refresh RX poison on buffer recycling
      b43: Do radio lock assertion in software
      mac80211: quiet beacon loss messages

Oliver Hartkopp (1):
      can: Network Drop Monitor: Make use of consume_skb() in af_can.c

Oliver Neukum (1):
      pegasus: Handle disconnect error code correctly.

PJ Waskiewicz (2):
      ixgbe: Fix DCB traffic class mapping for 82599
      ixgbe: Fix the DCB PFC thresholds for 82599

Pablo Neira Ayuso (3):
      netfilter: ctnetlink: report error if event message allocation fa=
ils
      netfilter: nfnetlink: return ENOMEM if we fail to create netlink =
socket
      netfilter: ctnetlink: fix gcc warning during compilation

Patrick McHardy (3):
      netfilter: nf_conntrack: fix crash when unloading helpers
      netfilter: nf_nat: add support for persistent mappings
      vlan/macvlan: fix NULL pointer dereferences in ethtool handlers

Paul Moore (1):
      netlabel: Always remove the correct address selector

Pavel Roskin (2):
      ath9k: fix access to a freed skb in ath_rx_tasklet()
      orinoco: correct timeout logic in __orinoco_hw_set_tkip_key()

Philip Rakity (1):
      libertas: don't leak skb on receive error

Rami Rosen (1):
      mwl8: fix build warning.

Reinette Chatre (4):
      iwl3945: use cancel_delayed_work_sync to cancel rfkill_poll
      mac80211: do not print WARN if config interface
      iwlwifi: add debugging for TX path
      iwlwifi: DMA fixes

Robert P. J. Day (1):
      MAC80211: Remove unused MAC80211_VERBOSE_SPECT_MGMT_DEBUG.

Roland Dreier (1):
      mlx4_en: Fix cleanup if workqueue create in mlx4_en_add() fails

Tony Breeds (1):
      ixgbe: Be explict with what we are !'ing in ixgbe_sfp_config_modu=
le_task()

Ursula Braun (1):
      af_iucv: consider state IUCV_CLOSING when closing a socket

Vasanthakumar Thiagarajan (1):
      mac80211: Fix bug in getting rx status for frames pending in reor=
der buffer

Yevgeny Petrilin (5):
      mlx4_en: Fix error handling while activating RX rings
      mlx4_en: Fix a race at restart task
      mlx4_en: Assign dummy event handler for TX queue
      mlx4_en: use NETIF_F_IP_CSUM | NETIF_F_IPV6_CSUM for tx csum at i=
nitialization
      mlx4_en: Move to SW counters for total bytes and packets

 MAINTAINERS                                 |   11 ++-
 drivers/net/8139too.c                       |   10 +-
 drivers/net/Kconfig                         |    4 +-
 drivers/net/cxgb3/cxgb3_main.c              |   44 ++++----
 drivers/net/cxgb3/t3_hw.c                   |   11 +--
 drivers/net/e1000/e1000_main.c              |    6 +-
 drivers/net/e1000e/netdev.c                 |    8 +-
 drivers/net/ixgbe/ixgbe_dcb_82599.c         |   28 +++--
 drivers/net/ixgbe/ixgbe_main.c              |   54 +++++++++-
 drivers/net/macb.c                          |   28 +----
 drivers/net/macvlan.c                       |    9 +-
 drivers/net/mlx4/en_main.c                  |    5 +-
 drivers/net/mlx4/en_netdev.c                |   21 ++--
 drivers/net/mlx4/en_port.c                  |   45 +++------
 drivers/net/mlx4/en_resources.c             |    6 +
 drivers/net/mlx4/en_rx.c                    |   12 +--
 drivers/net/mlx4/en_tx.c                    |    1 +
 drivers/net/mlx4/mlx4_en.h                  |    1 +
 drivers/net/pcmcia/pcnet_cs.c               |    2 +-
 drivers/net/ps3_gelic_wireless.c            |    3 +
 drivers/net/tg3.c                           |   26 +++--
 drivers/net/tun.c                           |   47 +++++----
 drivers/net/ucc_geth.c                      |    3 +-
 drivers/net/usb/pegasus.c                   |    1 +
 drivers/net/wireless/airo.c                 |    2 +-
 drivers/net/wireless/ar9170/hw.h            |    8 +-
 drivers/net/wireless/ar9170/usb.c           |  114 +++++++++++++++++--=
--
 drivers/net/wireless/at76c50x-usb.c         |    2 +
 drivers/net/wireless/ath9k/recv.c           |    4 +-
 drivers/net/wireless/atmel.c                |    1 -
 drivers/net/wireless/b43/dma.c              |   50 +++++++--
 drivers/net/wireless/b43/main.c             |    5 +
 drivers/net/wireless/b43/phy_common.c       |   16 ++-
 drivers/net/wireless/b43/phy_common.h       |    4 +-
 drivers/net/wireless/iwlwifi/iwl-3945.c     |    2 +-
 drivers/net/wireless/iwlwifi/iwl-3945.h     |    1 +
 drivers/net/wireless/iwlwifi/iwl-agn.c      |   11 +--
 drivers/net/wireless/iwlwifi/iwl-csr.h      |    2 +-
 drivers/net/wireless/iwlwifi/iwl-dev.h      |    4 +
 drivers/net/wireless/iwlwifi/iwl-tx.c       |   99 ++++++++++--------
 drivers/net/wireless/iwlwifi/iwl3945-base.c |  152 +++++++++++++++++++=
--------
 drivers/net/wireless/libertas/rx.c          |    2 +
 drivers/net/wireless/mwl8k.c                |    7 +-
 drivers/net/wireless/orinoco/hw.c           |    8 +-
 drivers/net/wireless/p54/p54.h              |   12 +-
 drivers/net/wireless/p54/p54common.c        |    2 -
 drivers/net/wireless/p54/p54spi.c           |   25 +++--
 drivers/net/wireless/p54/p54usb.c           |    1 +
 drivers/net/wireless/rt2x00/rt2x00dev.c     |    4 +-
 drivers/net/wireless/rt2x00/rt2x00pci.c     |   18 +---
 drivers/net/wireless/rt2x00/rt2x00usb.c     |   18 +---
 drivers/net/wireless/rt2x00/rt73usb.c       |    2 +
 firmware/Makefile                           |    1 +
 firmware/WHENCE                             |   10 ++
 firmware/cis/LA-PCM.cis.ihex                |   20 ++++
 include/net/netfilter/nf_nat.h              |    1 +
 net/8021q/vlan_dev.c                        |    3 +-
 net/ax25/ax25_uid.c                         |   12 ++-
 net/bluetooth/hci_event.c                   |   38 +++++--
 net/bluetooth/rfcomm/core.c                 |    2 +
 net/can/af_can.c                            |    4 +-
 net/core/dev.c                              |   13 ++-
 net/ipv4/netfilter/nf_nat_core.c            |    3 +-
 net/ipv4/tcp.c                              |    6 +-
 net/ipv4/tcp_output.c                       |    2 +-
 net/iucv/af_iucv.c                          |   24 +++--
 net/mac80211/Kconfig                        |    7 --
 net/mac80211/main.c                         |    2 +-
 net/mac80211/mlme.c                         |   38 +++++--
 net/mac80211/pm.c                           |   15 +++-
 net/mac80211/rx.c                           |   15 ++-
 net/mac80211/wext.c                         |   43 ++++++--
 net/netfilter/nf_conntrack_helper.c         |    2 +-
 net/netfilter/nf_conntrack_netlink.c        |   14 ++-
 net/netfilter/nf_log.c                      |    4 +
 net/netfilter/nfnetlink.c                   |    2 +-
 net/netlabel/netlabel_addrlist.c            |   26 ++---
 net/netrom/af_netrom.c                      |    6 +-
 net/sched/sch_netem.c                       |    8 ++
 net/wireless/core.h                         |    2 +-
 net/wireless/nl80211.c                      |    4 +-
 net/wireless/reg.c                          |    5 +-
 net/wireless/scan.c                         |   40 ++++++--
 83 files changed, 849 insertions(+), 485 deletions(-)
 create mode 100644 firmware/cis/LA-PCM.cis.ihex
