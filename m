From: David Miller <davem@davemloft.net>
Subject: [GIT]: Networking
Date: Wed, 27 Aug 2008 16:46:49 -0700 (PDT)
Message-ID: <20080827.164649.87042354.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:44716
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754454AbYH0Xqx convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 27 Aug 2008 19:46:53 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


1) Build fix of 8390 layer from Alan Cox.

2) IGB driver bug fixes from Alexander Duyck:
      a) Incorrect VLAN register programming
      b) Fix RX hang condition by forcing all queues to interrupt every=
 2 secs
      c) ethtool -d accidently masks off interrupts, whoops...
      d) Fix setting of number of TX queues when in MSI-X only mode
      e) Remove 82576 quad adapter PCI IDs, these don't work properly y=
et

3) Add new device ID for MCS7830 USB adapter, from Arnd Bergmann

4) In forcedeth driver, make the checksum feature setting match what th=
e
   hardware can actually do, from Ayaz Abdulla.

5) ibm_newemac calls dev_mc_add() before the device is even registered,
   fix from Benjamin Herrenschmidt.

6) Two atmel wireless driver fixes from Dan Williams:
   a) Try open system authentication when shared key fails.
   b) Return correct error code on request_firmware() failure

7) Two HSO driver fixes from Denis Joseph Barrow
   a) dev_kfree_skb() called twice on same packet during resume
   b) Icon-322 entry in hsi_ids[] table was incorrect

8) Eugene Teo noticed some bogus capability checks in SBNI wan
   driver, it was doing direct checks of current->euid :-)

9) rfkill_claim_show() was missing a line break in output,
   from Felipe Balbi.

10) r8169 DMA mapping leak fix from Francois Romieu, size argument
    to pci_unmap_single() was incorrect.

11) qeth driver should use -EOPNOTSUPP instead of -ENOTSUPP, from
    Ursula Braun.  Also, qeth forgets to post unicast address list
    to the hardware in some circumstances, from Frank Blaschka.

12) fs_enet_rx_napi() crash fix in fs_enet driver from Heiko Schocher.

13) Hugh Dickins fixed a brown paper bag issue in the recent ipv4
    sysctl bits from Al Viro.

14) Missing braces in atl1e driver, fix from Ilpo Jarvinen.

15) MAC80211 layer fix from Jan-Espen Pettersen so that we do not
    emit empty extended rates IE frames.

16) Four packet scheduler layer locking fixes from Jarek Poplawski:
    a) dev_graft_qdisc() locks the wrong qdisc
    b) Same problem in sch_tree_lock()
    c) Some dev_queue->qdisc assignments were missing rcu_assign_pointe=
r()
    d) Wrong qdisc root passed to gen_replace_estimator(), thus wrong
       qdisc being locked by that code.

17) atl1 is showing problems now that TSO was enabled by default, turn
    it back off by default until we know what the problem is, from
    Jay Cliburn.

18) Fix smc91x null pointer deref in resource removal, from Jeff Garzik=
=2E

19) e100 uses plain readX() on iomap memory, from Jiri Slaby

20) Two ath5k bug fixes from Jiri Slaby:
    a) Beacon set and config can race with beacon sendng
    b) bintval needs to be setup earlier to be accurate

21) Lower verbosity of IBSS merge messages, they sometimes happen
    a lot, from John Linville.

22) Two mac80211 bug fixes from Jouni Malinen:
    a) Use IWEVCUSTOM so that we don't hit the 256 byte limit that
       IWEVASSOCREQIE has
    b) Fix debugfs entry corruption due to entries being left
       behind accidently with references to freed memory

23) __mesh_table_free() called with wrong table pointer when
    mesh_table_grow() fails, from Julia Lawall.

24) S390 LCS driver forgets to check CPA state in interrupt handler,
    resulting in incorrect behavior when recovery is driven after cable
    reconnect, fix from Klaus-D. Wacker.

25) mv643xx_eth fixes from Lennert Buytenhek:
    a) Interrupt handler needs to ACK RX irq before processing the ring
       to avoid a race that can get packets wedged and never processed.
    b) accidental double add_timer() in receive OOM handling
    c) Need to use IRQ safe locks in mv643xx_eth_poll or else we deadlo=
ck
    d) fix NULL pointer deref in rxq_process()
    e) chip has 8 byte multiple size restriction for buffers on receive=
,
       but this isn't being enforced everywhere it needs to be

26) Memory leak fix in claw_probe() from Martin Schwidefsky.

27) claw and ctcm drivers were non-functional because they were using
    netdev->priv as a mid-layer private pointer, but that doesn't work
    because netdev->priv is where the generic networking stores the
    private memory allocated at alloc_netdev() time.

    We have a netdev->ml_priv pointer that fits the need here, so we
    convert things to use that to fix this bug, from Peter Tiedemann.

28) TCP header size miscalculation when eliding window scaling, fix
    from Philip Love.

29) ibmveth transmits incorrect UDP checksums, fix from Santiago Leon.

30) gianfar grabs a mutex in softirq context, oops, fix from Sebastian =
Siewior.

31) Two more SCTP overflow fixes from Vlad Yasevich based upon feedback
    from Eugene Teo.  I have to ship these two off to -stable as well.

Please pull, thanks a lot!

The following changes since commit c2d42545774c4bba7232521d836d0793330e=
3a4e:
  Eilon Greenstein (1):
        bnx2x: Version update

are available in the git repository at:

  master.kernel.org:/pub/scm/linux/kernel/git/davem/net-2.6.git master

Alan Cox (1):
      [netdrvr] fix build issue: undefined reference to `NS8390p_init'

Alexander Duyck (5):
      ixgbe: fix vlan filtering
      igb: force all queues to interrupt once every 2 seconds
      igb: ethtool -d reads EICR which is incorrect as it is read on cl=
ear
      igb: fix setting the number of tx queues
      igb: remove 82576 quad adapter

Arnd Bergmann (1):
      net/usb/mcs7830: new device IDs

Ayaz Abdulla (1):
      forcedeth: fix checksum flag

Benjamin Herrenschmidt (1):
      ibm_newemac: Don't call dev_mc_add() before device is registered

Brice Goglin (1):
      myri10ge: update version string to 1.4.3-1.358

Dan Williams (2):
      atmel: return ENOENT on request_firmware failure
      atmel: try open system authentication too

David S. Miller (2):
      Merge branch 'davem-fixes' of master.kernel.org:/.../jgarzik/netd=
ev-2.6
      Merge branch 'no-iwlwifi' of git://git.kernel.org/.../linville/wi=
reless-2.6

Denis Joseph Barrow (2):
      [netdrvr] hso: icon 322 detection fix
      [netdrvr] hso: dev_kfree_skb crash fix

Eugene Teo (1):
      wan: Missing capability checks in sbni_ioctl()

=46elipe Balbi (1):
      net: rfkill: add missing line break

=46rancois Romieu (1):
      r8169: balance pci_map / pci_unmap pair

=46rank Blaschka (2):
      qeth: l2 write unicast list to hardware
      qeth: preallocated header account offset

Heiko Schocher (1):
      fs_enet: Fix SCC Ethernet on CPM2, and crash in fs_enet_rx_napi()

Hugh Dickins (1):
      ipv4: mode 0555 in ipv4_skeleton

Ilpo J=C3=A4rvinen (1):
      atl1e: multistatement if missing braces

Jan-Espen Pettersen (1):
      mac80211: don't send empty extended rates IE

Jarek Poplawski (4):
      pkt_sched: Fix dev_graft_qdisc() locking
      pkt_sched: Use rcu_assign_pointer() to change dev_queue->qdisc
      pkt_sched: Fix gen_estimator locks
      pkt_sched: Fix sch_tree_lock()

Jay Cliburn (1):
      atl1: disable TSO by default

Jeff Garzik (2):
      Merge branch 'for-2.6.27' of git://git.marvell.com/mv643xx_eth in=
to upstream-fixes
      [netdrvr] smc91x: fix resource removal (null ptr deref)

Jiri Slaby (3):
      Ath5k: lock beacons
      Ath5k: fix bintval setup
      e100, fix iomap read

John W. Linville (1):
      mac80211: quiet chatty IBSS merge message

Jouni Malinen (2):
      mac80211: Use IWEVASSOCREQIE instead of IWEVCUSTOM
      mac80211: Fix debugfs file add/del for netdev

Julia Lawall (1):
      net/mac80211/mesh.c: correct the argument to __mesh_table_free

Klaus-D. Wacker (1):
      LCS recovery dumps when cable reconnect

Lennert Buytenhek (6):
      mv643xx_eth: fix NAPI 'rotting packet' issue
      mv643xx_eth: fix double add_timer() on the receive oom timer
      mv643xx_eth: fix inconsistent lock semantics
      mv643xx_eth: fix NULL pointer dereference in rxq_process()
      mv643xx_eth: enforce multiple-of-8-bytes receive buffer size rest=
riction
      mv643xx_eth: bump version to 1.3

Martin Schwidefsky (1):
      claw: fix memory leak in claw_probe.

Mike Frysinger (1):
      Blackfin EMAC Driver: the BF526 also supports the MAC,

Oliver Martin (1):
      net/usb/mcs7830: add set_mac_address

Peter Tiedemann (2):
      claw: netdev->priv vs. netdev->ml_priv
      ctcm: netdev->priv vs. netdev->ml_priv

Philip Love (1):
      tcp: fix tcp header size miscalculation when window scale is unus=
ed

Santiago Leon (1):
      ibmveth: fix bad UDP checksums

Sebastian Siewior (1):
      net: don't grab a mutex within a timer context in gianfar

Takashi Iwai (1):
      drivers/net/skfp/ess.c: fix compile warnings

Ursula Braun (1):
      qeth: use -EOPNOTSUPP instead of -ENOTSUPP.

Vlad Yasevich (2):
      sctp: correct bounds check in sctp_setsockopt_auth_key
      sctp: fix random memory dereference with SCTP_HMAC_IDENT option.

 arch/powerpc/include/asm/cpm2.h    |    5 ++
 drivers/net/Kconfig                |    6 +-
 drivers/net/atl1e/atl1e_main.c     |    3 +-
 drivers/net/atlx/atl1.c            |    1 -
 drivers/net/e100.c                 |    4 +-
 drivers/net/forcedeth.c            |    4 +-
 drivers/net/fs_enet/fs_enet-main.c |    8 ++++
 drivers/net/fs_enet/mac-scc.c      |    8 +++-
 drivers/net/gianfar.c              |   22 ++++++++--
 drivers/net/gianfar.h              |    1 +
 drivers/net/ibm_newemac/core.c     |    6 +-
 drivers/net/ibmveth.c              |    5 +-
 drivers/net/igb/e1000_82575.c      |    1 -
 drivers/net/igb/e1000_hw.h         |    1 -
 drivers/net/igb/igb_ethtool.c      |   17 +++-----
 drivers/net/igb/igb_main.c         |   25 +++++------
 drivers/net/ixgbe/ixgbe_main.c     |    8 ++-
 drivers/net/mv643xx_eth.c          |   35 +++++++++-------
 drivers/net/myri10ge/myri10ge.c    |    2 +-
 drivers/net/r8169.c                |    2 +-
 drivers/net/skfp/ess.c             |    6 +-
 drivers/net/smc91x.c               |    2 +-
 drivers/net/usb/hso.c              |    3 +-
 drivers/net/usb/mcs7830.c          |   47 +++++++++++++++++++++-
 drivers/net/wan/sbni.c             |    8 ++--
 drivers/net/wd.c                   |    2 +-
 drivers/net/wireless/ath5k/base.c  |   23 ++++++++---
 drivers/net/wireless/ath5k/base.h  |    1 +
 drivers/net/wireless/atmel.c       |   51 ++++++++++++++---------
 drivers/s390/net/claw.c            |   79 +++++++++++++++++-----------=
-------
 drivers/s390/net/ctcm_fsms.c       |   56 +++++++++++++-------------
 drivers/s390/net/ctcm_main.c       |   24 +++++-----
 drivers/s390/net/ctcm_main.h       |    9 ++--
 drivers/s390/net/ctcm_mpc.c        |   46 ++++++++++----------
 drivers/s390/net/lcs.c             |    3 +-
 drivers/s390/net/qeth_core.h       |    1 +
 drivers/s390/net/qeth_core_main.c  |    2 +-
 drivers/s390/net/qeth_l2_main.c    |   27 ++++++++++--
 drivers/s390/net/qeth_l3_sys.c     |    2 +-
 include/net/sch_generic.h          |   12 +++++-
 net/ipv4/route.c                   |    4 +-
 net/ipv4/tcp_output.c              |    6 ++-
 net/mac80211/debugfs_netdev.c      |   24 +++++-----
 net/mac80211/ieee80211_i.h         |    6 +++
 net/mac80211/mesh.c                |    2 +-
 net/mac80211/mlme.c                |   52 +++++------------------
 net/rfkill/rfkill.c                |    2 +-
 net/sched/sch_api.c                |   18 ++++++--
 net/sched/sch_cbq.c                |    4 +-
 net/sched/sch_generic.c            |    4 +-
 net/sched/sch_hfsc.c               |    4 +-
 net/sched/sch_htb.c                |    4 +-
 net/sctp/auth.c                    |    3 +
 net/sctp/socket.c                  |    8 ++-
 54 files changed, 413 insertions(+), 296 deletions(-)
