From: David Miller <davem@davemloft.net>
Subject: [GIT] Networking
Date: Tue, 25 May 2010 16:59:45 -0700 (PDT)
Message-ID: <20100525.165945.39198480.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:55348
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752272Ab0EYX7g convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 25 May 2010 19:59:36 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


1) dev_get_valid_name can create conditions wherein it becomes impossib=
le
   to rename a device, fixed by Daniel Lezcano.

2) CAIF protocol bug fixes from Sjur Braendeland:

   a) wait_ev*_timeout return value accidently stored in 'int' instead
      of 'long'
   b) By-hand list implementation buggy, use standard kernel lists.
   c) Memory allocation failures not handled correctly.
   d) poll() erroneously returns POLLHUP when connecting
   e) missing spin_unlock in cfmuxl_remove_uplayer()
   f) receive needs to set MSG_TRUNC when user buf size is insufficient

3) Cleanup accidently introduced uninitialized variable in pppoe_flush_=
dev().
   Fix from Dan Carpenter.

4) ISDN fixes from Tilman Schmidt.
   a) ->reset_ctr() op is marked optional, but code doesn't actually
      check for NULL
   b) Dummy stubs for ->reset_ctr() and ->load_firmware() are erroneous
      and cause hangs, delete.

5) Blackfin SIR IRDA device is not harmed by the UART unit bug, so don'=
t
   adjust clock values using the bug workaround adjustment.  From
   Graf Yang.

6) Networking control group is severely limited because it tries to sam=
ple
   the task control group at the time of packet transmission.  This rea=
lly
   can't be done reliably, especially when packets are sent async from
   another context.

   Fix by storing the cgroupid in the socket, sampling it at I/O call
   points (sendmsg, recvmsg, splice_read, sendpage), then use this
   value when we classify via the skb->sk socket.

   Handle special cases like TUN (which call netif_rx() to inject packe=
ts)
   directly.

   All of this work done by Herbert Xu.

7) DCCP stores error codes in a u8, which is insufficient for MIPS whic=
h
   needs a u16, fix from Yoichi Yuasa.

8) BE2NET bug fixes from Sarveshwar Bandi:
   a) Must PHY reset after FW init.
   b) FW upgrade can take a while, use completions instead of polling
      with softirqs disabled.

9) proc_dointvec change that came in via the networking tree for port
   range specifications introduced a regression for procfs files, accid=
ently
   disallowing write("1\n").  Fix from J. R. Okajima.

10) Use after free in Phone socket close, fix from R=E9mi Denis-Courmon=
t.

11) Memory leak in macvlan, from Jiri Pirko.

12) Initial GRO fraglist element's ->gso_size can be bogus, if packet
    hits device not TSO capable but fraglist capable.  Fix from Herbert
    Xu.

13) Add support for some new IXGBE device IDs.

14) Memory leak and alloc failure fixes from Denis Kirjaniv.
    a) sh_mdio_release() leaks memory
    b) check for kzalloc() return value in ieee802154.
    c) bfin_mac leaks miibus->irq memory

15) sja1000.c missing spin_lock_init() on priv->cmdreg_lock, fix from
    Oliver Hartkopp.

16) The batched dequeuing of input_pkt_queue introduced this merge wind=
ow
    added some problems.  Inaccurate packet counting can occur which de=
feats
    the schemes that RFS uses to prevent out-of-order packet processing=
 when
    we want to modify the the target RX cpu for a flow.

    Fix from Tom Herbert.

17) Several wireless fixes via John Linville and the wireless crew.

18) ENIC bug fixes from Scott Feldman.
    a) Fix UUID fmt'ing array type.
    b) port-profile assosciation happens before we have a MAC address
       assigned, use a random one instead of garbage

19) qdisc_notify() can OOPS, because tc_fill_qdisc() can accidently be
    called for a builtin qdisc.  Fix from Eric Dumazet.

20) do_setlink() had some error handling bugs introduced this cycle
    (failure to initialize 'err' in some error paths), fix from David
    Howells.

21) ethoc_probe can deref a NULL pointer, fix from Thomas Chou.


22) netif_vdbg() definition is garbage when VERBOSE_DEBUG is defined.
    Fix from Ben Hutchings.

23) Netfilter fixes via Patrick McHardy:
    a) nf_ct_sip doesn't handle nonlinear packets, but it needs to
    b) __nf_conntrack_confirm() races with nf_ct_get_next_corpse()

24) Fix race in i2400m_rx_edata() resulting in an OOPS on i2400m->rx_ro=
q,
    from Inaky Perez-Gonzalez.

Please pull, thanks a lot!

The following changes since commit ec96e2fe954c23a54bfdf2673437a39e193a=
1822:
  Linus Torvalds (1):
        Merge branch 'devel' of master.kernel.org:/home/rmk/linux-2.6-a=
rm

are available in the git repository at:

  master.kernel.org:/pub/scm/linux/kernel/git/davem/net-2.6.git master

Baruch Siach (1):
      fec: add support for PHY interface platform data

Ben Hutchings (1):
      net: Fix definition of netif_vdbg() when VERBOSE_DEBUG is not def=
ined

Bruno Randolf (1):
      ath5k: consistently use rx_bufsize for RX DMA

Dan Carpenter (4):
      pppoe: uninitialized variable in pppoe_flush_dev()
      ath9k_htc: dereferencing before check in hif_usb_tx_cb()
      ath9k_htc: rare leak in ath9k_hif_usb_alloc_tx_urbs()
      iwlwifi: testing the wrong variable in iwl_add_bssid_station()

Daniel Lezcano (1):
      net-2.6 : V2 - fix dev_get_valid_name

David Howells (1):
      rtnetlink: Fix error handling in do_setlink()

David S. Miller (4):
      Merge branch 'master' of git://git.kernel.org/.../kaber/nf-next-2=
=2E6
      Merge branch 'master' of git://git.kernel.org/.../linville/wirele=
ss-2.6
      Merge branch 'wimax-2.6.35.y' of git://git.kernel.org/.../inaky/w=
imax
      drivers/net/usb/asix.c: Fix pointer cast.

Denis Kirjanov (3):
      sh_eth: Fix memleak in sh_mdio_release
      ieee802154: Fix possible NULL pointer dereference in wpan_phy_all=
oc
      bfin_mac: fix memleak in mii_bus{probe|remove}

Eric Dumazet (1):
      net_sched: Fix qdisc_notify()

=46elix Fietkau (3):
      cfg80211: fix crash in cfg80211_set_freq()
      ath9k: change beacon allocation to prefer the first beacon slot
      ath9k: remove VEOL support for ad-hoc

=46ilip Aben (1):
      hso: add support for new products

Gertjan van Wingerde (2):
      rt2x00: Fix failed SLEEP->AWAKE and AWAKE->SLEEP transitions.
      rt2x00: Fix rt2800usb TX descriptor writing.

Graf Yang (1):
      net/irda: bfin_sir: IRDA is not affected by anomaly 05000230

Helmut Schaa (1):
      rt2x00: don't use to_pci_dev in rt2x00pci_uninitialize

Herbert Xu (4):
      gro: Fix bogus gso_size on the first fraglist entry
      cls_cgroup: Store classid in struct sock
      tun: Update classid on packet injection
      cls_cgroup: Fix build error when built-in

Inaky Perez-Gonzalez (1):
      wimax/i2400m: fix bad race condition check in RX path

J. R. Okajima (1):
      proc_dointvec: write a single value

Jiri Pirko (1):
      macvlan: do proper cleanup in macvlan_common_newlink() V2

Joerg Marx (1):
      netfilter: nf_conntrack: fix a race in __nf_conntrack_confirm aga=
inst nf_ct_get_next_corpse()

Johannes Berg (1):
      cfg80211: add missing braces

John W. Linville (1):
      Revert "ath9k: Group Key fix for VAPs"

Jussi Kivilinna (1):
      rndis_wlan: replace wireless_send_event with cfg80211_disconnecte=
d

Juuso Oikarinen (1):
      wl1271: Fix RX data path frame lengths

Luciano Coelho (1):
      netfilter: fix description of expected checkentry return code on =
xt_target

Luis R. Rodriguez (1):
      ath9k: remove AR9003 from PCI IDs for now

Mallikarjuna R Chilakala (1):
      ixgbe:add support for a new 82599 10G Base-T device

Mike Frysinger (1):
      net-caif: drop redundant Kconfig entries

Oliver Hartkopp (1):
      can: SJA1000 add missing spin_lock_init()

Patrick McHardy (1):
      netfilter: nf_ct_sip: handle non-linear skbs

Randy Dunlap (3):
      wireless: fix mac80211.h kernel-doc warnings
      wireless: fix sta_info.h kernel-doc warnings
      sock.h: fix kernel-doc warning

Reinette Chatre (1):
      iwlwifi: fix internal scan race

R=E9mi Denis-Courmont (1):
      Phonet: fix potential use-after-free in pep_sock_close()

Sarveshwar Bandi (2):
      be2net: Bug fix in init code in probe
      be2net: Bug fix to avoid disabling bottom half during firmware up=
grade.

Scott Feldman (2):
      enic: bug fix: sprintf UUID to string as u8[] rather than u16[] a=
rray
      enic: Use random mac addr when associating port-profile

Sjur Braendeland (6):
      caif: Bugfix - wait_ev*_timeout returns long.
      caif: Bugfix - use standard Linux lists
      caif: Bugfix - handle mem-allocation failures
      caif: Bugfix - Poll can't return POLLHUP while connecting.
      caif: Bugfix - missing spin_unlock
      caif: Bugfix - use MSG_TRUNC in receive

Sujith (1):
      cfg80211: Fix signal_type comparison

Tejun Heo (1):
      wireless: update gfp/slab.h includes

Thomas Chou (1):
      ethoc: fix null dereference in ethoc_probe

Tilman Schmidt (2):
      isdn/capi: make reset_ctr op truly optional
      isdn/gigaset: remove dummy CAPI method implementations

Tom Herbert (1):
      net: fix problem in dequeuing from input_pkt_queue

Vasanthakumar Thiagarajan (1):
      ath9k: Fix rx of mcast/bcast frames in PS mode with auto sleep

Yoichi Yuasa (1):
      net/dccp: expansion of error code size

 drivers/isdn/capi/kcapi.c                  |    6 ++
 drivers/isdn/gigaset/capi.c                |   28 +--------
 drivers/net/benet/be.h                     |    2 +
 drivers/net/benet/be_cmds.c                |   19 +++++-
 drivers/net/benet/be_main.c                |   11 ++-
 drivers/net/bfin_mac.c                     |    2 +
 drivers/net/can/sja1000/sja1000.c          |    2 +
 drivers/net/enic/enic_main.c               |   29 ++++++---
 drivers/net/ethoc.c                        |   34 +++++++++-
 drivers/net/fec.c                          |   22 +++++++
 drivers/net/fec.h                          |    2 +
 drivers/net/irda/bfin_sir.c                |    8 ++-
 drivers/net/ixgbe/ixgbe.h                  |    3 +
 drivers/net/ixgbe/ixgbe_82598.c            |    1 +
 drivers/net/ixgbe/ixgbe_82599.c            |    1 +
 drivers/net/ixgbe/ixgbe_main.c             |   69 ++++++++++++++++++++=
+
 drivers/net/ixgbe/ixgbe_phy.c              |   30 +++++++++
 drivers/net/ixgbe/ixgbe_phy.h              |    3 +
 drivers/net/ixgbe/ixgbe_type.h             |    4 +
 drivers/net/macvlan.c                      |    9 +++-
 drivers/net/pppoe.c                        |    1 +
 drivers/net/sh_eth.c                       |    3 +
 drivers/net/tun.c                          |    2 +
 drivers/net/usb/asix.c                     |    4 +-
 drivers/net/usb/hso.c                      |    3 +
 drivers/net/wimax/i2400m/rx.c              |    4 +-
 drivers/net/wireless/ath/ath5k/base.c      |    7 +-
 drivers/net/wireless/ath/ath9k/beacon.c    |   75 ++++----------------=
---
 drivers/net/wireless/ath/ath9k/hif_usb.c   |   10 +++-
 drivers/net/wireless/ath/ath9k/htc.h       |    1 +
 drivers/net/wireless/ath/ath9k/main.c      |   28 +--------
 drivers/net/wireless/ath/ath9k/pci.c       |    1 -
 drivers/net/wireless/ath/ath9k/recv.c      |   17 ++++--
 drivers/net/wireless/iwlwifi/iwl-agn-ict.c |    1 +
 drivers/net/wireless/iwlwifi/iwl-scan.c    |   21 ++++++-
 drivers/net/wireless/iwlwifi/iwl-sta.c     |    2 +-
 drivers/net/wireless/rndis_wlan.c          |   16 +++--
 drivers/net/wireless/rt2x00/rt2400pci.c    |    9 ++-
 drivers/net/wireless/rt2x00/rt2500pci.c    |    9 ++-
 drivers/net/wireless/rt2x00/rt2800usb.c    |    2 +-
 drivers/net/wireless/rt2x00/rt2x00pci.c    |    2 +-
 drivers/net/wireless/rt2x00/rt61pci.c      |    7 +-
 drivers/net/wireless/rt2x00/rt73usb.c      |    7 +-
 drivers/net/wireless/wl12xx/wl1271_rx.c    |    2 +
 include/linux/fec.h                        |   21 ++++++
 include/linux/netdevice.h                  |   16 ++++-
 include/linux/netfilter/x_tables.h         |    2 +-
 include/net/caif/cfctrl.h                  |    4 +-
 include/net/cls_cgroup.h                   |   63 +++++++++++++++++++
 include/net/mac80211.h                     |    4 +-
 include/net/netfilter/nf_conntrack_core.h  |    2 +-
 include/net/sock.h                         |   12 +++-
 kernel/sysctl.c                            |    4 +-
 net/caif/Kconfig                           |    5 +-
 net/caif/caif_socket.c                     |   91 +++++++++++---------=
--------
 net/caif/cfctrl.c                          |   92 ++++++++------------=
--------
 net/caif/cfmuxl.c                          |    3 +-
 net/caif/cfpkt_skbuff.c                    |   25 +++++---
 net/caif/cfserl.c                          |    3 +-
 net/caif/cfsrvl.c                          |    6 ++
 net/core/dev.c                             |   48 ++++++++------
 net/core/rtnetlink.c                       |    4 +-
 net/core/skbuff.c                          |    1 +
 net/core/sock.c                            |   19 ++++++
 net/dccp/input.c                           |    6 +-
 net/ieee802154/wpan-class.c                |    7 ++-
 net/mac80211/key.c                         |    1 -
 net/mac80211/sta_info.h                    |    2 +-
 net/netfilter/nf_conntrack_core.c          |   10 +++
 net/netfilter/nf_conntrack_sip.c           |   12 +---
 net/phonet/pep.c                           |    2 +
 net/sched/cls_cgroup.c                     |   50 ++++++++++-----
 net/sched/sch_api.c                        |   14 ++--
 net/socket.c                               |    9 +++
 net/wireless/chan.c                        |    2 +-
 net/wireless/nl80211.c                     |    6 +-
 net/wireless/scan.c                        |    4 +-
 77 files changed, 682 insertions(+), 387 deletions(-)
 create mode 100644 include/linux/fec.h
 create mode 100644 include/net/cls_cgroup.h
