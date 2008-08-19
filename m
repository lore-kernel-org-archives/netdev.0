From: David Miller <davem@davemloft.net>
Subject: [GIT]: Networking
Date: Tue, 19 Aug 2008 04:17:06 -0700 (PDT)
Message-ID: <20080819.041706.261399060.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:36564
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751569AbYHSLRH convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 19 Aug 2008 07:17:07 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


We're still chipping away at the packet scheduler layer locking
issues, but I feel that this is mostly sorted at this point.

Other highlights:

1) Fix for NAT via loopback per regression with GSO by Herbert
   Xu.

2) Merge in wired driver fixes via Jeff Garzik.

3) Bluetooth updates via Marcel Holtmann.

4) Wireless driver updates via John Linville.

5) Fix to namespace handling in ipv6 from Brian Haley.

6) DCCP panic fix from Gerrit Renker.

7) Packet scheduler qdisc return value handling fix which can
   cause TCP crashes.

8) Netfilter bug fixes from Patrick McHardy and co.

Please pull, thanks a lot!

The following changes since commit a7f5aaf36ded825477c4d7167cc6eb1bcdc6=
3191:
  Linus Torvalds (1):
        Merge branch 'x86-fixes-for-linus' of git://git.kernel.org/.../=
tip/linux-2.6-tip

are available in the git repository at:

  master.kernel.org:/pub/scm/linux/kernel/git/davem/net-2.6.git master

Adrian Bunk (2):
      [netdrvr] uninline atl1e_setup_mac_ctrl()
      ath9k: work around gcc ICEs (again)

Anders Grafstr=F6m (1):
      netfilter: ipt_addrtype: Fix matching of inverted destination add=
ress type

Atsushi Nemoto (1):
      [netdrvr] ne: Use CONFIG_MACH_TX49XX

Ben Dooks (1):
      AX88796: Fix locking in ethtool support

Brian Haley (1):
      netns: Add network namespace argument to rt6_fill_node() and ipv6=
_dev_get_saddr()

Brice Goglin (1):
      myri10ge: myri10ge_fw_name also overrides the rss firmware

Bruce Allan (7):
      e1000e: Return 1 instead of a non-zero value for link up indicati=
on
      e1000e: Set InterruptThrottleRate to default when invalid value u=
sed
      e1000e: Use skb_copy_to_linear_data_offset introduced in 2.6.22
      e1000e: Increase Tx timeout factor for 10Mbps
      e1000e: increase minimum frame size allowed
      e1000e: test for unusable MSI support
      e1000e: remove unnecessary snippet missed in prior check_options =
update

Christian Lamparter (3):
      p54: Fix regression due to "net: Delete NETDEVICES_MULTIQUEUE kco=
nfig option"
      p54: move p54_vdcf_init to the right place.
      p54u: reset skb's data/tail pointer on requeue

David Brownell (1):
      Kconfig: HSO driver bugfixes and updates

David S. Miller (18):
      Merge branch 'upstream-davem' of master.kernel.org:/.../jgarzik/n=
etdev-2.6
      loopback: Remove rest of LOOPBACK_TSO code.
      bnx2: Fix build with VLAN_8021Q disabled.
      pkt_sched: Add 'deactivated' state.
      pkt_sched: Simplify dev_deactivate() polling loop.
      pkt_sched: No longer destroy qdiscs from RCU.
      sch_prio: Use NET_XMIT_SUCCESS instead of "0" constant.
      pkt_sched: Fix missed RCU unlock in dev_queue_xmit()
      pkt_sched: Fix return value corruption in HTB and TBF.
      pkt_sched: Never schedule non-root qdiscs.
      pkt_sched: Don't hold qdisc lock over qdisc_destroy().
      Merge branch 'master' of git://git.kernel.org/.../linville/wirele=
ss-2.6
      Revert "pkt_sched: Protect gen estimators under est_lock."
      Revert "pkt_sched: Add BH protection for qdisc_stab_lock."
      Merge branch 'master' of git://git.kernel.org/.../holtmann/blueto=
oth-2.6
      pkt_sched: Prevent livelock in TX queue running.

Dhananjay Phadke (6):
      netxen: fix mac addr setup
      netxen: fix rxbuf leak across driver reload
      netxen: force link update across ifdown/ifup
      netxen: fix dma watchdog
      netxen: cleanup interrupt code
      netxen: update driver version

Gerrit Renker (1):
      dccp: Fix panic caused by too early termination of retransmission=
 mechanism

Greg Kroah-Hartman (2):
      USB: HSO: make tty_operations const
      USB: HSO: minor fixes due to code review

Henrique de Moraes Holschuh (1):
      rfkill: protect suspended rfkill controllers

Herbert Xu (4):
      ipv4: Disable route secret interval on zero interval
      loopback: Enable TSO
      net: Preserve netfilter attributes in skb_gso_segment using __cop=
y_skb_header
      loopback: Drop obsolete ip_summed setting

Holger Schurig (1):
      ssb: allow compilation on systems without PCI

Huang Weiyi (2):
      [netdrvr] remove unnecessary #include
      removed unused #include <version.h>

Ilpo J=E4rvinen (1):
      pkt_sched: remove bogus block (cleanup)

Jarek Poplawski (4):
      pkt_sched: Fix unlocking in tc_ctl_tfilter()
      net: Change handling of the __QDISC_STATE_SCHED flag in net_tx_ac=
tion().
      pkt_sched: Grab correct lock in notify_and_destroy().
      pkt_sched: Add lockdep annotation for qdisc locks

Jesse Brandeburg (1):
      ixgbe: add cx4 device ID

Jiri Slaby (1):
      iwlwifi: fix printk newlines

Jochen Friedrich (1):
      rt2x00: Fix txdone_entry_desc_flags

Jussi Kivilinna (1):
      sch_prio: Use return value from inner qdisc requeue

Larry Finger (2):
      b43: Fix for SPROM coding error in Linksys WMP54G (BCM4306/3)
      b43: Fix for another Bluetooth Coexistence SPROM Programming erro=
r for BCM4306

Luis R. Rodriguez (1):
      mac80211: remove kdoc references to IEEE80211_HW_HOST_GEN_BEACON_=
TEMPLATE

Marcel Holtmann (3):
      [Bluetooth] Add SCO support to btusb driver
      [Bluetooth] Fix userspace breakage due missing class links
      [Bluetooth] Consolidate maintainers information

Mark McLoughlin (1):
      tun: TUNGETIFF interface to query name and flags

Matt Carlson (6):
      tg3: Add APE register access locking
      tg3: Refine APE status check
      tg3: Preserve register settings for DASH
      tg3: Turn off ASF "driver alive" heartbeats for APE
      tg3: Fix firmware event timeouts
      tg3: Update version to 3.94

Michael Chan (4):
      bnx2: Fix logic to setup VLAN rx tagging.
      bnx2: Use proper CONFIG_VLAN_8021Q to compile the VLAN code.
      bnx2: Reinsert VLAN tag when necessary.
      bnx2: Update version to 1.8.0.

Michael Karcher (1):
      ath5k: Don't fiddle with MSI on suspend/resume.

Mikael Pettersson (1):
      ixp4xx_eth: fix dma_mapping_error() compile errors

Olivier Blin (2):
      hso: fix oops in read/write callbacks
      hso: fix refcounting on the ttyHSx devices

Pablo Neira Ayuso (3):
      netfilter: ctnetlink: fix double helper assignation for NAT'ed co=
nntracks
      netfilter: ctnetlink: fix sleep in read-side lock section
      netfilter: ctnetlink: sleepable allocation with spin lock bh

Rafael J. Wysocki (1):
      sky2: Fix suspend/hibernation/shutdown regression with WOL enable=
d (rev. 2)

Robert Fitzsimons (1):
      tlan: Fix two regressions introduced by 64bit conversion.

Ron Rindjunsky (1):
      mac80211: update new sta's rx timestamp

Rusty Russell (2):
      net: skb_copy_datagram_from_iovec()
      tun: fallback if skb_alloc() fails on big packets

Scott Wood (1):
      gianfar: Call gfar_halt_nodisable() from gfar_halt().

Stefan Buehler (1):
      tg3: fix 64 bit counter for ethtool stats

Stephen Hemminger (2):
      bridge: show offload settings
      nf_nat: use secure_ipv4_port_ephemeral() for NAT port randomizati=
on

Vegard Nossum (1):
      au1000_eth: use 'unsigned long' for irqflags

Yang Hongyang (1):
      ipv6: Fix the return interface index when get it while no message=
 is received.

matthieu Barth=E9lemy (1):
      rtl8187: Add USB ID for Netgear WG111V3

roel kluin (1):
      atl1e: WAKE_MCAST 2x. 1st WAKE_UCAST?

 Documentation/rfkill.txt                    |    5 +
 MAINTAINERS                                 |   87 +------
 drivers/bluetooth/Kconfig                   |   10 +-
 drivers/bluetooth/bt3c_cs.c                 |    2 +-
 drivers/bluetooth/btusb.c                   |  282 +++++++++++++++++++=
-
 drivers/bluetooth/hci_ldisc.c               |    2 +-
 drivers/bluetooth/hci_usb.c                 |    2 +-
 drivers/bluetooth/hci_vhci.c                |    2 +-
 drivers/char/random.c                       |    1 +
 drivers/net/Kconfig                         |    2 +-
 drivers/net/acenic.c                        |    1 -
 drivers/net/arm/ixp4xx_eth.c                |    6 +-
 drivers/net/atl1e/atl1e_ethtool.c           |    2 +-
 drivers/net/au1000_eth.c                    |    2 +-
 drivers/net/ax88796.c                       |    4 +-
 drivers/net/bnx2.c                          |   47 +++-
 drivers/net/bnx2x_link.c                    |    1 -
 drivers/net/bnx2x_main.c                    |    1 -
 drivers/net/cpmac.c                         |    1 -
 drivers/net/e1000e/defines.h                |    2 +-
 drivers/net/e1000e/e1000.h                  |    1 +
 drivers/net/e1000e/ethtool.c                |    2 +-
 drivers/net/e1000e/netdev.c                 |  185 ++++++++++++-
 drivers/net/e1000e/param.c                  |   25 ++-
 drivers/net/gianfar.c                       |    6 +-
 drivers/net/gianfar_sysfs.c                 |    1 -
 drivers/net/ipg.h                           |    2 -
 drivers/net/ixgbe/ixgbe_82598.c             |    1 +
 drivers/net/ixgbe/ixgbe_main.c              |    4 +-
 drivers/net/ixgbe/ixgbe_type.h              |    1 +
 drivers/net/loopback.c                      |   67 -----
 drivers/net/myri10ge/myri10ge.c             |    6 +-
 drivers/net/ne.c                            |    4 +-
 drivers/net/netxen/netxen_nic.h             |    7 +-
 drivers/net/netxen/netxen_nic_hw.c          |   59 +++--
 drivers/net/netxen/netxen_nic_init.c        |   28 +-
 drivers/net/netxen/netxen_nic_main.c        |  210 +++++++--------
 drivers/net/netxen/netxen_nic_phan_reg.h    |    2 +
 drivers/net/ppp_mppe.c                      |    1 -
 drivers/net/pppol2tp.c                      |    1 -
 drivers/net/r6040.c                         |    1 -
 drivers/net/sh_eth.c                        |    1 -
 drivers/net/sky2.c                          |    8 +-
 drivers/net/tehuti.h                        |    1 -
 drivers/net/tg3.c                           |  101 ++++++--
 drivers/net/tg3.h                           |    6 +
 drivers/net/tlan.c                          |    8 +-
 drivers/net/tun.c                           |  105 +++++++-
 drivers/net/typhoon.c                       |    1 -
 drivers/net/usb/Kconfig                     |   21 +-
 drivers/net/usb/hso.c                       |   53 +++--
 drivers/net/wireless/ath5k/base.c           |    9 +-
 drivers/net/wireless/ath9k/hw.c             |    6 +-
 drivers/net/wireless/b43/main.c             |    3 +-
 drivers/net/wireless/ipw2100.c              |    1 -
 drivers/net/wireless/ipw2200.c              |    1 -
 drivers/net/wireless/iwlwifi/iwl-3945.c     |    1 -
 drivers/net/wireless/iwlwifi/iwl-4965.c     |    3 +-
 drivers/net/wireless/iwlwifi/iwl-5000.c     |    1 -
 drivers/net/wireless/iwlwifi/iwl-agn.c      |    1 -
 drivers/net/wireless/iwlwifi/iwl-core.c     |    1 -
 drivers/net/wireless/iwlwifi/iwl-eeprom.c   |    7 +-
 drivers/net/wireless/iwlwifi/iwl-hcmd.c     |    1 -
 drivers/net/wireless/iwlwifi/iwl-power.c    |    1 -
 drivers/net/wireless/iwlwifi/iwl-sta.c      |    4 +-
 drivers/net/wireless/iwlwifi/iwl-tx.c       |    4 +-
 drivers/net/wireless/iwlwifi/iwl3945-base.c |    7 +-
 drivers/net/wireless/p54/p54common.c        |   51 ++--
 drivers/net/wireless/p54/p54common.h        |   18 +-
 drivers/net/wireless/p54/p54usb.c           |   10 +
 drivers/net/wireless/rt2x00/rt2x00queue.h   |    8 +-
 drivers/net/wireless/rt2x00/rt2x00usb.c     |    1 +
 drivers/net/wireless/rtl8187_dev.c          |    1 +
 drivers/ssb/main.c                          |    8 +
 include/linux/if_tun.h                      |    1 +
 include/linux/skbuff.h                      |    4 +
 include/net/addrconf.h                      |    3 +-
 include/net/ip6_route.h                     |    1 +
 include/net/mac80211.h                      |   11 +-
 include/net/sch_generic.h                   |    2 +-
 net/bluetooth/af_bluetooth.c                |    2 +-
 net/bluetooth/bnep/core.c                   |    2 +-
 net/bluetooth/hci_sysfs.c                   |  376 ++++++++++++++-----=
--------
 net/bluetooth/l2cap.c                       |    2 +-
 net/bluetooth/rfcomm/core.c                 |    2 +-
 net/bluetooth/sco.c                         |    2 +-
 net/bridge/br_device.c                      |   15 +-
 net/core/datagram.c                         |   87 ++++++
 net/core/dev.c                              |   49 +++--
 net/core/gen_estimator.c                    |    9 +-
 net/core/skbuff.c                           |   12 +-
 net/dccp/input.c                            |   12 +-
 net/ipv4/netfilter/ipt_addrtype.c           |    2 +-
 net/ipv4/netfilter/nf_nat_proto_common.c    |    8 +-
 net/ipv4/route.c                            |   76 +++++-
 net/ipv6/addrconf.c                         |    3 +-
 net/ipv6/fib6_rules.c                       |    3 +-
 net/ipv6/ip6_fib.c                          |    1 +
 net/ipv6/ip6_output.c                       |    2 +-
 net/ipv6/ipv6_sockglue.c                    |    4 +-
 net/ipv6/ndisc.c                            |    2 +-
 net/ipv6/route.c                            |   12 +-
 net/ipv6/xfrm6_policy.c                     |    4 +-
 net/mac80211/mlme.c                         |    2 +
 net/netfilter/nf_conntrack_netlink.c        |   36 ++--
 net/rfkill/rfkill.c                         |   14 +-
 net/sched/cls_api.c                         |    2 +-
 net/sched/sch_api.c                         |   47 ++--
 net/sched/sch_cbq.c                         |    2 +-
 net/sched/sch_generic.c                     |   68 ++----
 net/sched/sch_htb.c                         |    4 +-
 net/sched/sch_prio.c                        |    4 +-
 net/sched/sch_tbf.c                         |   11 +-
 net/sctp/ipv6.c                             |    3 +-
 114 files changed, 1533 insertions(+), 898 deletions(-)
