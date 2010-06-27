From: David Miller <davem@davemloft.net>
Subject: [GIT] Networking
Date: Sun, 27 Jun 2010 10:30:11 -0700 (PDT)
Message-ID: <20100627.103011.193713615.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46437
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751475Ab0F0RaF convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 27 Jun 2010 13:30:05 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Here are the networking bug fixes that have accumulated while you were =
away,
most notably:

1) Blind ipsec policy dereference leads to OOPS, fixed by Timo Ter=E4s.

2) TEQL devices should not set IFF_XMIT_DST_RELEASE since it is importa=
nt
   to allow the SKB's dst to get referenced post transmit.  Fix from
   Tom Hughes.

3) ipv6 proxy neighbor discovery regression leads to OOPS, fix from
   Stephen Hemminger.

4) RX timestamping improperly programmed in gianfar, breaking some fami=
lies
   of cards.  Regression from 2.6.34, fix from Manfred Rudigier.

5) New ID for pcnet_cs and fix for simultaneous use of lan and modem ca=
rds
   of smc91c92_cs chips, from Ken Kawasaki.

6) Loopback delivery regression fix from John Fastabend, this hit a lot=
 of
   folks.

7) deliver_clone in bridging can crash on OOM, fix from Herbert Xu.

8) UDP Fragment Offload generates illegal packets, also from Herbert Xu=
=2E

9) Fix netdev_mc_count() conversion in lasi82596 driver.  From Helge De=
ller.
   Similar fix to bluetooth driver from Gustavo F. Padovan.

10) ISDN/gigaset bug fixes via Tilman Schmidt.

11) Fix rewriting erroneously rxhash in __copy_skb_header().

12) sky2_phy_reinit() can leave RX/TX disabled, fix from Brandon Philip=
s.
    This cures a hang hit by several users.

13) netxen bug fixes from Amit Kumar Salecha, memory leaks, and imprope=
r
    programming of caching window register.

14) A couple wireless one-liners via John Linville and the wireless cre=
w.

Please pull, thanks a lot!

The following changes since commit 7e27d6e778cd87b6f2415515d7127eba53fe=
5d02:
  Linus Torvalds (1):
        Linux 2.6.35-rc3

are available in the git repository at:

  master.kernel.org:/pub/scm/linux/kernel/git/davem/net-2.6.git master

Amit Kumar Salecha (3):
      netxen: fix memory leaks in error path
      netxen: fix rcv buffer leak
      netxen: fix caching window register

Andy Gospodarek (1):
      ixgbe: fix automatic LRO/RSC settings for low latency

Anirban Chakraborty (1):
      net: add dependency on fw class module to qlcnic and netxen_nic

Anton Vorontsov (1):
      gianfar: Fix oversized packets handling

Bob Copeland (1):
      ath5k: initialize ah->ah_current_channel

Brandon Philips (1):
      sky2: enable rx/tx in sky2_phy_reinit()

Christoph Fritz (1):
      mac80211: fix warn, enum may be used uninitialized

David S. Miller (3):
      Merge branch 'master' of git://git.kernel.org/.../kaber/nf-2.6
      Merge branch 'master' of git://git.kernel.org/.../linville/wirele=
ss-2.6
      Merge branch 'master' of git://git.kernel.org/.../linville/wirele=
ss-2.6

David Woodhouse (1):
      phylib: Add autoload support for the LXT973 phy.

Dmitry Kravkov (1):
      cnic: Disable statistics initialization for eth clients that do n=
ot support statistics

Dominik Brodowski (1):
      pcmcia: dev_node removal bugfix

Don Skidmore (2):
      ixgbe: fix for race with 8259(8|9) during shutdown
      ixgbe: add comment on SFP+ ID for Active DA

Eric Dumazet (2):
      net: rxhash already set in __copy_skb_header
      snmp: fix SNMP_ADD_STATS()

=46UJITA Tomonori (1):
      bnx2: fix dma_get_ops compilation breakage

=46ilip Aben (1):
      hso: remove setting of low_latency flag

=46lorian Fainelli (1):
      cpmac: do not leak struct net_device on phy_connect errors

Gustavo F. Padovan (1):
      Bluetooth: Bring back var 'i' increment

Helge Deller (1):
      lasi82596: fix netdev_mc_count conversion

Herbert Xu (2):
      bridge: Fix OOM crash in deliver_clone
      udp: Fix bogus UFO packet generation

Jan-Bernd Themann (2):
      ehea: fix delayed packet processing
      ehea: Fix kernel deadlock in DLPAR-mem processing

Jiri Slaby (1):
      ISDN: hysdn, fix potential NULL dereference

Joe Perches (1):
      e1000: Fix message logging defect

Joerg Albert (1):
      p54pci: add Symbol AP-300 minipci adapters pciid

John Fastabend (1):
      net: fix deliver_no_wcard regression on loopback device

John W. Linville (1):
      iwlwifi: cancel scan watchdog in iwl_bg_abort_scan

Ken Kawasaki (2):
      pcnet_cs: add new id (TOSHIBA Modem/LAN Card)
      smc91c92_cs: fix the problem that lan & modem does not work simul=
taneously

Manfred Rudigier (1):
      gianfar: Fix setup of RX time stamping

Michal Schmidt (1):
      vxge: fix memory leak in vxge_alloc_msix() error path

Prarit Bhargava (1):
      libertas_tf: Fix warning in lbtf_rx for stats struct

Ralf Baechle (1):
      NET: MIPSsim: Fix modpost warning.

Randy Dunlap (1):
      enic: fix pci_alloc_consistent argument

Reinette Chatre (1):
      iwlwifi: serialize station management actions

Sergey Matyukevich (1):
      ucc_geth: fix for RX skb buffers recycling

Shanyu Zhao (1):
      iwlagn: verify flow id in compressed BA packet

Sven Wegener (1):
      ipvs: Add missing locking during connection table hashing and unh=
ashing

Tilman Schmidt (5):
      isdn/gigaset: honor CAPI application's buffer size request
      isdn/gigaset: correct CAPI voice connection encoding
      isdn/gigaset: correct CAPI DATA_B3 Delivery Confirmation
      isdn/gigaset: encode HLC and BC together
      isdn/gigaset: correct CAPI connection state storage

Tim Gardner (1):
      hostap: Protect against initialization interrupt

Timo Ter=E4s (1):
      xfrm: check bundle policy existance before dereferencing it

Tom Hughes (1):
      Clear IFF_XMIT_DST_RELEASE for teql interfaces

Zhu Yi (1):
      wireless: orphan ipw2x00 drivers

stephen hemminger (2):
      bridge: fdb cleanup runs too often
      ipv6: fix NULL reference in proxy neighbor discovery

 MAINTAINERS                                 |   10 +-
 drivers/isdn/gigaset/asyncdata.c            |   44 +---
 drivers/isdn/gigaset/capi.c                 |  405 +++++++++++++++++++=
--------
 drivers/isdn/gigaset/common.c               |   36 +--
 drivers/isdn/gigaset/ev-layer.c             |    4 +-
 drivers/isdn/gigaset/gigaset.h              |   38 ++-
 drivers/isdn/gigaset/i4l.c                  |   21 ++
 drivers/isdn/gigaset/isocdata.c             |   72 ++---
 drivers/isdn/hysdn/hysdn_net.c              |    3 +-
 drivers/net/Kconfig                         |    2 +
 drivers/net/bnx2.c                          |   11 +-
 drivers/net/cnic.c                          |   55 +++--
 drivers/net/cpmac.c                         |    3 +-
 drivers/net/e1000/e1000_main.c              |   17 +-
 drivers/net/ehea/ehea.h                     |    2 +-
 drivers/net/ehea/ehea_main.c                |    9 +-
 drivers/net/enic/vnic_dev.c                 |    2 +-
 drivers/net/gianfar.c                       |   25 ++-
 drivers/net/ixgbe/ixgbe_ethtool.c           |   37 +--
 drivers/net/ixgbe/ixgbe_main.c              |    4 +
 drivers/net/ixgbe/ixgbe_phy.c               |    2 +
 drivers/net/lib82596.c                      |    2 +-
 drivers/net/mipsnet.c                       |    2 +-
 drivers/net/netxen/netxen_nic_ctx.c         |    3 +-
 drivers/net/netxen/netxen_nic_hw.c          |    4 -
 drivers/net/netxen/netxen_nic_init.c        |   13 +-
 drivers/net/pcmcia/pcnet_cs.c               |    1 +
 drivers/net/pcmcia/smc91c92_cs.c            |   19 +-
 drivers/net/phy/lxt.c                       |    1 +
 drivers/net/sky2.c                          |   19 +-
 drivers/net/ucc_geth.c                      |    2 +
 drivers/net/usb/hso.c                       |    1 -
 drivers/net/vxge/vxge-main.c                |   29 ++-
 drivers/net/wireless/ath/ath5k/attach.c     |    1 +
 drivers/net/wireless/hostap/hostap_cs.c     |   15 +-
 drivers/net/wireless/hostap/hostap_hw.c     |   13 +
 drivers/net/wireless/hostap/hostap_wlan.h   |    2 +-
 drivers/net/wireless/iwlwifi/iwl-agn-tx.c   |    5 +
 drivers/net/wireless/iwlwifi/iwl-agn.c      |    8 +-
 drivers/net/wireless/iwlwifi/iwl-scan.c     |    1 +
 drivers/net/wireless/iwlwifi/iwl-sta.c      |    4 +
 drivers/net/wireless/iwlwifi/iwl3945-base.c |    9 +-
 drivers/net/wireless/libertas_tf/main.c     |    2 +-
 drivers/net/wireless/p54/p54pci.c           |    2 +
 drivers/serial/serial_cs.c                  |    1 +
 include/net/snmp.h                          |    2 +-
 net/bluetooth/bnep/netdev.c                 |    2 +
 net/bridge/br_fdb.c                         |    6 +-
 net/bridge/br_forward.c                     |    4 +-
 net/core/skbuff.c                           |    2 +-
 net/ipv4/ip_output.c                        |    9 +-
 net/ipv6/ndisc.c                            |    2 +-
 net/mac80211/work.c                         |    2 +-
 net/netfilter/ipvs/ip_vs_conn.c             |    4 +
 net/sched/sch_teql.c                        |    1 +
 net/xfrm/xfrm_policy.c                      |    3 +-
 56 files changed, 618 insertions(+), 380 deletions(-)
