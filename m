From: David Miller <davem@davemloft.net>
Subject: [GIT]: Networking
Date: Wed, 14 May 2008 04:06:02 -0700 (PDT)
Message-ID: <20080514.040602.199714279.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: akpm@linux-foundation.org, jgarzik@pobox.com,
	linville@tuxdriver.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1762214AbYENLGZ@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


1) The mac80211 layer and drivers using it had this awful
   problem on TX that causes basically every packet to be
   copied before we give it to the device.

   Thanks to some detective work by Johannes Berg we were
   able to fix up the bulk of these problems.

   The solution is two fold:

   i) First we adjust LL_MAX_HEADER properly for wireless
      cases

   ii) We let the driver indicate any extra header and tail
       room it might need, beyond netdev->hard_header_len,
       in the netdev struct.  Then mac80211 is updated to
       set this as appropriate.

   The other wireless stack we have (ieee80211) and bare wireless
   drivers still have some similar issues, but with this
   infrastructure they should be quite easy to fix.

2) Fix syncppp back up by providing a proper mid-layer private
   pointer in the netdev struct, which is what this thing
   wanted from the beginning.  Thus, we can remove the BROKEN
   tag in Kconfig

3) Misalignment fix in irda from Graf Yang, use get_unaligned().

4) Ilpo fixed the bad TCP inteactions with some weird printers.

   They only will accept data in-order, and with FRTO (which is
   enabled by default) we could get into a wedged state and stop
   making forward progress after loss.

   I very much appreciate all of the effort he and the bug reporter
   put into diagnosing this problem and coming up with a fix.

5) Uninitialized pointer fix in SCTP by Patrick McHardy

6) CIPSO calculates it's hash function imporperly, fix from
   Pavel Emelyanov

7) PPP frees registered netdevices in error path, also from
   Pavel Emelyanov

8) Netfilter xt_iprange is missing module aliases, fix from
   Phil Oester

9) Two SCTP fixes from Wei Yongjun

10) Wireless updates and fixes from John Linville and the rest
    of the wireless crew.

11) Wired driver updates from Jeff Garzik and co.

    You will notice the larger bits for the SFQ driver in
    here, but that driver is new and thus these changes
    cannot cause regressions so I think they are appropriate
    to add at this time. If you disagree just let us know. :)

    Also of note is that Auke has passed the Intel ethernet
    driver torch on to another crazy fool :-)

Please pull, thanks a lot!

The following changes since commit 36ca34cc3b8335eb1fe8bd9a1d0a2592980c=
3f02:
  David S. Miller (1):
        sit: Add missing kfree_skb() on pskb_may_pull() failure.

are available in the git repository at:

  master.kernel.org:/pub/scm/linux/kernel/git/davem/net-2.6.git master

Andy Fleming (1):
      gianfar: Fix a bug where the pointer never moves for dma_unmap...

Auke Kok (1):
      New maintainer for Intel ethernet adapters

Ben Dooks (1):
      DM9000: Use delayed work to update MII PHY state

Ben Hutchings (9):
      [netdrvr] sfc: Add TSO support
      [netdrvr] sfc: Add phy_flash_cfg module parameter and implementat=
ion
      [netdrvr] sfc: Removed bogus 'fall-thru' comments
      [netdrvr] sfc: Remove garbage from comment
      [netdrvr] sfc: Remove kernel-doc comments for removed members of =
struct efx_nic
      [netdrvr] sfc: Fix code formatting
      [netdrvr] sfc: Remove unused macro EFX_XAUI_RETRAIN_MAX
      [netdrvr] sfc: Increment rx_reset when reported as driver event
      [netdrvr] sfc: sfc: Add self-test support

Brice Goglin (11):
      myri10ge: update firmware headers
      myri10ge: fix module parameter descriptions
      myri10ge: increase and fix handoff timeout
      myri10ge: properly align scratch buffers
      myri10ge: report FIBER in ethtool for XFP based NIC
      myri10ge: add barrier in myri10ge_send_cmd
      myri10ge: trivial formatting fix
      myri10ge: fix potential infinite loop in enable_ecrc
      myri10ge: move data structures into a single slice
      myri10ge: cleanup retrieving of firmware capabilities
      myri10ge: fix the number of interrupt slots

David S. Miller (5):
      syncppp: Fix crashes.
      Merge branch 'master' of git://git.kernel.org/.../linville/wirele=
ss-2.6
      net: Set LL_MAX_HEADER properly for wireless.
      mac80211: Use skb_header_cloned() on TX path.
      Merge branch 'upstream-davem' of master.kernel.org:/.../jgarzik/n=
etdev-2.6

Divy Le Ray (2):
      cxgb3 - fix port up/down error path
      cxgb3 - fix EEH

Emmanuel Grumbach (1):
      iwlwifi: Fix frequency in rx_status fill

Enrico Scholz (2):
      DM9000: Add __devinit and __devexit attributes to probe and remov=
e
      DM9000: Update and fix driver debugging messages

Eric Leblond (1):
      netfilter: ctnetlink: dump conntrack ID in event messages

Graf Yang (1):
      irda: Fix a misalign access issue. (v2)

Hannes Hering (3):
      memory: Introduce exports for memory notifiers
      ehea: Add dependency to Kconfig
      ehea: Add DLPAR memory remove support

Helmut Schaa (1):
      mac80211: fix association with some APs

Ilpo J=E4rvinen (2):
      tcp FRTO: Fix fallback to conventional recovery
      tcp FRTO: work-around inorder receivers

Ivo van Doorn (4):
      rt2x00: Don't use pskb_expand_head()
      rt2x00: Fix broken recover-on-error path
      rt2x00: Clean up error handling of PCI queue DMA allocation.
      mac80211: Don't encrypt beacons

Jay Cliburn (4):
      atl1: add PHY power save mode
      atl1: fix broken suspend and resume
      atl1: add shutdown callback
      atl1: bump version number

Jesse Brandeburg (1):
      sky2: fix simple define thinko

Johannes Berg (4):
      mac80211: fix debugfs default key oops
      zd1211rw: fix potential use-after-free bug
      net: Allow netdevices to specify needed head/tailroom
      mac80211: assign needed_headroom/tailroom for netdevs

John W. Linville (1):
      wavelan: avoid index past end of array if DEBUG_SHOW_UNUSED is de=
fined

Julia Lawall (1):
      pppol2tp: Remove null pointer dereference.

Luis Carlos Cobo (2):
      mac80211: fix incorrect mesh header length
      mac80211: fix access to null skb

Luis R. Rodriguez (1):
      prism54: fix regression with missing carrier in AP-mode

Masakazu Mokuno (1):
      PS3: gelic: fix memory leak

Matheos Worku (1):
      niu: Determine the # of ports from the card's VPD data

Patrick McHardy (2):
      mac80211: mesh hwmp: fix kfree(skb)
      sctp: Fix use of uninitialized pointer

Pavel Emelyanov (5):
      Fix GFP_KERNEL allocation under read lock.
      Fix not checked kmalloc() result.
      Fix potential scheduling while atomic in mesh_path_add.
      cipso: Relax too much careful cipso hash function.
      ppp: Do not free not yet unregistered net device.

Pavel Roskin (1):
      mac80211: add missing newlines in printk()

Phil Oester (1):
      netfilter: xt_iprange: module aliases for xt_iprange

Rami Rosen (1):
      net: Fix typo in net/core/sock.c.

Steven Rostedt (1):
      fix irq flags in mac80211 code

Wei Yongjun (2):
      sctp: Do not enable peer IPv6 address support on PF_INET socket
      sctp: Add address type check while process paramaters of ASCONF c=
hunk

Zhu Yi (1):
      iwlwifi: fix compile error when CONFIG_MAC80211_DEBUGFS is not se=
lected

 MAINTAINERS                                    |    6 +-
 drivers/base/memory.c                          |    2 +
 drivers/net/Kconfig                            |    2 +-
 drivers/net/atlx/atl1.c                        |  157 ++++--
 drivers/net/atlx/atl1.h                        |    2 +-
 drivers/net/atlx/atlx.c                        |    2 +-
 drivers/net/atlx/atlx.h                        |    7 +-
 drivers/net/cxgb3/adapter.h                    |    1 +
 drivers/net/cxgb3/common.h                     |    1 +
 drivers/net/cxgb3/cxgb3_main.c                 |   40 +-
 drivers/net/cxgb3/regs.h                       |    8 +
 drivers/net/cxgb3/sge.c                        |   29 +-
 drivers/net/cxgb3/t3_hw.c                      |   28 +
 drivers/net/dm9000.c                           |   37 ++-
 drivers/net/ehea/ehea.h                        |   27 +-
 drivers/net/ehea/ehea_main.c                   |   25 +
 drivers/net/ehea/ehea_qmr.c                    |  286 +++++++---
 drivers/net/gianfar.c                          |    2 +
 drivers/net/myri10ge/myri10ge.c                |  730 +++++++++++++---=
-------
 drivers/net/myri10ge/myri10ge_mcp.h            |   56 ++-
 drivers/net/myri10ge/myri10ge_mcp_gen_header.h |   39 +-
 drivers/net/niu.c                              |   53 +-
 drivers/net/niu.h                              |    9 +
 drivers/net/ppp_generic.c                      |    1 +
 drivers/net/pppol2tp.c                         |   13 +-
 drivers/net/ps3_gelic_wireless.c               |    2 +
 drivers/net/sfc/Makefile                       |    4 +-
 drivers/net/sfc/boards.h                       |    2 +
 drivers/net/sfc/efx.c                          |    4 +-
 drivers/net/sfc/enum.h                         |   49 ++
 drivers/net/sfc/ethtool.c                      |  259 +++++++++-
 drivers/net/sfc/falcon.c                       |    8 +-
 drivers/net/sfc/falcon_hwdefs.h                |   16 +-
 drivers/net/sfc/falcon_xmac.c                  |   82 +++-
 drivers/net/sfc/mdio_10g.c                     |   78 +++
 drivers/net/sfc/mdio_10g.h                     |   24 +-
 drivers/net/sfc/net_driver.h                   |   28 +-
 drivers/net/sfc/rx.c                           |   11 +-
 drivers/net/sfc/selftest.c                     |  717 ++++++++++++++++=
+++++++
 drivers/net/sfc/selftest.h                     |   50 ++
 drivers/net/sfc/sfe4001.c                      |   14 +
 drivers/net/sfc/tenxpress.c                    |   91 +++-
 drivers/net/sfc/tx.c                           |  664 ++++++++++++++++=
+++++
 drivers/net/sfc/xfp_phy.c                      |   36 ++
 drivers/net/sky2.h                             |    4 +-
 drivers/net/wan/Kconfig                        |    4 +-
 drivers/net/wan/cosa.c                         |   14 +-
 drivers/net/wan/hdlc_ppp.c                     |    2 +-
 drivers/net/wan/hostess_sv11.c                 |   12 +-
 drivers/net/wan/lmc/lmc_main.c                 |    1 +
 drivers/net/wan/sealevel.c                     |    1 +
 drivers/net/wireless/iwlwifi/iwl-3945.c        |    2 +-
 drivers/net/wireless/iwlwifi/iwl-4965-rs.c     |    2 +-
 drivers/net/wireless/iwlwifi/iwl-4965.c        |    2 +-
 drivers/net/wireless/prism54/islpci_dev.c      |   11 +-
 drivers/net/wireless/rt2x00/rt2x00dev.c        |   11 +-
 drivers/net/wireless/rt2x00/rt2x00pci.c        |    5 +-
 drivers/net/wireless/rt2x00/rt61pci.c          |   31 +-
 drivers/net/wireless/wavelan.c                 |    4 +-
 drivers/net/wireless/wavelan_cs.c              |    6 +-
 drivers/net/wireless/zd1211rw/zd_usb.c         |    6 +-
 include/linux/netdevice.h                      |   35 +-
 include/net/irda/discovery.h                   |    3 -
 include/net/syncppp.h                          |    2 +-
 net/core/netpoll.c                             |    2 +-
 net/core/sock.c                                |    2 +-
 net/econet/af_econet.c                         |    2 +-
 net/ipv4/arp.c                                 |    2 +-
 net/ipv4/cipso_ipv4.c                          |    4 +-
 net/ipv4/igmp.c                                |    4 +-
 net/ipv4/ipconfig.c                            |    6 +-
 net/ipv4/raw.c                                 |   10 +-
 net/ipv4/tcp_input.c                           |   17 +-
 net/ipv6/ip6_output.c                          |    2 +-
 net/ipv6/mcast.c                               |    4 +-
 net/ipv6/ndisc.c                               |    4 +-
 net/ipv6/raw.c                                 |   10 +-
 net/irda/discovery.c                           |    8 +-
 net/irda/irlmp.c                               |    5 +-
 net/irda/irnet/irnet_irda.c                    |    4 +-
 net/mac80211/debugfs_key.c                     |   15 +-
 net/mac80211/iface.c                           |    9 +
 net/mac80211/mesh.c                            |    2 +-
 net/mac80211/mesh_hwmp.c                       |    2 +-
 net/mac80211/mesh_pathtbl.c                    |   17 +-
 net/mac80211/mlme.c                            |   64 ++-
 net/mac80211/rc80211_pid_debugfs.c             |    4 +-
 net/mac80211/rx.c                              |   12 +-
 net/mac80211/tx.c                              |    5 +-
 net/mac80211/util.c                            |   10 +-
 net/mac80211/wme.c                             |    3 +-
 net/netfilter/nf_conntrack_netlink.c           |    3 +
 net/netfilter/xt_iprange.c                     |    2 +
 net/packet/af_packet.c                         |    2 +-
 net/sctp/sm_make_chunk.c                       |   16 +-
 net/xfrm/xfrm_output.c                         |    6 +-
 96 files changed, 3380 insertions(+), 738 deletions(-)
 create mode 100644 drivers/net/sfc/selftest.c
 create mode 100644 drivers/net/sfc/selftest.h
