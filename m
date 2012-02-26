From: David Miller <davem@davemloft.net>
Subject: [GIT] Networking
Date: Sun, 26 Feb 2012 15:02:00 -0500 (EST)
Message-ID: <20120226.150200.798415919193120654.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


1) ICMP sockets leave err uninitialized but we try to return it for
   the unsupported MSG_OOB case, reported by Dave Jones.

2) Add new Zaurus device ID entries, from Dave Jones.

3) Pointer calculation in hso driver memset is wrong, from Dan
   Carpenter.

4) ks8851_probe() checks unsigned value as negative, fix also from
   Dan Carpenter.

5) Fix crashes in atl1c driver due to TX queue handling, from Eric
   Dumazet.  I anticipate some TX side locking fixes coming in the
   near future for this driver as well.

6) The inline directive fix in Bluetooth which was breaking the build
   only with very new versions of GCC, from Johan Hedberg.

7) Fix crashes in the ATP CLIP code due to ARP cleanups this merge
   window, reported by Meelis Roos and fixed by Eric Dumazet.

8) JME driver doesn't flush RX FIFO correctly, from Guo-Fu Tseng.

9) Some ip6_route_output() callers test the return value for NULL,
   but this never happens as the convention is to return a dst
   entry with dst->error set.  Fixes from RonQing Li.

10) Logitech Harmony 900 should be handled by zaurus driver not
    cdc_ether, update white lists and black lists accordingly.
    From Scott Talbert.

11) Receiving from certain kinds of devices there won't be a MAC
    header, so there is no MAC header to fixup in the IPSEC code,
    and if we try to do it we'll crash.  Fix from Eric Dumazet.

12) Port type array indexing off-by-one in mlx4 driver, fix from
    Yevgeny Petrilin.

13) Fix regression in link-down handling in davinci_emac which causes
    all RX descriptors to be freed up and therefore RX to wedge
    completely, from Christian Riesch.

14) It took two attempts, but ctnetlink soft lockups seem to be
    cured now, from Pablo Neira Ayuso.

15) Endianness bug fix in ENIC driver, from Santosh Nayak.

16) The long ago conversion of the PPP fragmentation code over to
    abstracted SKB list handling wasn't perfect, once we get an
    out of sequence SKB we don't flush the rest of them like we
    should.  From Ben McKeegan.

17) Fix regression of ->ip_summed initialization in sfc driver.
    From Ben Hutchings.

18) Bluetooth timeout mistakenly using msecs instead of jiffies,
    from Andrzej Kaczmarek.

19) Using _sync variant of work cancellation results in deadlocks,
    use the non _sync variants instead.  From Andre Guedes.

20) Bluetooth rfcomm code had reference counting problems leading
    to crashes, fix from Octavian Purdila.

21) The conversion of netem over to classful qdisc handling added
    two bugs to netem_dequeue(), fixes from Eric Dumazet.

22) Missing pci_iounmap() in ATM Solos driver.  Fix from Julia Lawall.

23) b44_pci_exit() should not have __exit tag since it's invoked from
    non-__exit code.  From Nikola Pajkovsky.

24) The conversion of the neighbour hash tables over to RCU added a
    race, fixed here by adding the necessary reread of tbl->nht, fix
    from Michel Machado.

25) When we added VF (virtual function) attributes for network device
    dumps, this potentially bloats up the size of the dump of one
    network device such that the dump size is too large for the buffer
    allocated by properly written netlink applications.

    In particular, if you add 255 VFs to a network device, parts of
    GLIBC stop working.

    To fix this, we add an attribute that is used to turn on these
    extended portions of the network device dump.  Sophisticaed
    applications like 'ip' that want to see this stuff  will be changed
    to set the attribute, whereas things like GLIBC that don't care
    about VFs simply will not, and therefore won't be busted by the
    mere presence of VFs on a network device.

    Thanks to the tireless work of Greg Rose on this fix.

Please pull, thanks a lot.

The following changes since commit 3c761ea05a8900a907f32b628611873f6bef24b2:

  Fix autofs compile without CONFIG_COMPAT (2012-02-26 09:44:55 -0800)

are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/davem/net.git master

Amitkumar Karwar (1):
      mwifiex: clear previous security setting during association

Andre Guedes (1):
      Bluetooth: Fix potential deadlock

Andrzej Kaczmarek (2):
      Bluetooth: Fix sk_sndtimeo initialization for L2CAP socket
      Bluetooth: l2cap_set_timer needs jiffies as timeout value

Ben Hutchings (1):
      sfc: Fix assignment of ip_summed for pre-allocated skbs

Ben McKeegan (1):
      ppp: fix 'ppp_mp_reconstruct bad seq' errors

Christian Riesch (1):
      davinci_emac: Do not free all rx dma descriptors during init
p
Dan Carpenter (2):
      net/ethernet: ks8851_mll: signedness bug in ks8851_probe()
      hso: memsetting wrong data in hso_get_count()

Daniel Wagner (1):
      Bluetooth: Don't mark non xfer isoc endpoint URBs with URB_ISO_ASAP

Dave Jones (1):
      zaurus: Add ID for C-750/C-760/C-860/SL-C3000 PDA in MDLM mode

David McKay (1):
      netdev/phy/icplus: Correct broken phy_init code

David S. Miller (5):
      Merge branch 'master' of git://gitorious.org/linux-can/linux-can
      ipv4: ping: Fix recvmsg MSG_OOB error handling.
      Merge branch 'nf' of git://1984.lsi.us.es/net
      Merge branch 'master' of git://1984.lsi.us.es/net
      Merge branch 'sfc-3.3' of git://git.kernel.org/.../bwh/sfc

Eric Dumazet (4):
      netem: fix dequeue
      atl1c: dont use highprio tx queue
      atm: clip: remove clip_tbl
      ipsec: be careful of non existing mac headers

Felix Fietkau (1):
      mac80211: do not call rate control .tx_status before .rate_init

Florian Westphal (1):
      netfilter: nf_queue: fix queueing of bridged gro skbs

Giuseppe CAVALLARO (1):
      phy: IC+101G and PHY_HAS_INTERRUPT flag

Greg Rose (1):
      rtnetlink: Fix problem with buffer allocation

Guo-Fu Tseng (1):
      jme: Fix FIFO flush issue

Jack Morgenstein (1):
      mlx4_core: Do not map BF area if capability is 0

Joerg Willmann (1):
      netfilter: ebtables: fix alignment problem in ppc

Johan Hedberg (2):
      Bluetooth: Remove bogus inline declaration from l2cap_chan_connect
      Bluetooth: Add missing QUIRK_NO_RESET test to hci_dev_do_close

Johannes Berg (1):
      mac80211: call rate control only after init

John W. Linville (1):
      Merge branch 'master' of git://git.kernel.org/.../linville/wireless into for-davem

Jozsef Kadlecsik (2):
      netfilter: ctnetlink: fix soft lockup when netlink adds new entries
      netfilter: ctnetlink: fix soft lockup when netlink adds new entries (v2)

Julia Lawall (1):
      drivers/atm/solos-pci.c: exchange pci_iounmaps

Manoj Iyer (1):
      Bluetooth: btusb: Add vendor specific ID (0a5c 21f3) for BCM20702A0

Michel Machado (1):
      neighbour: Fixed race condition at tbl->nht

Neil Horman (1):
      vmxnet3: cap copy length at size of skb to prevent dropped frames on tx

Nikola Pajkovsky (1):
      b44: remove __exit from b44_pci_exit()

Octavian Purdila (2):
      Bluetooth: silence lockdep warning
      Bluetooth: Fix RFCOMM session reference counting issue

Oliver Hartkopp (1):
      can: sja1000: fix isr hang when hw is unplugged under load

Pablo Neira Ayuso (1):
      Revert "netfilter: ctnetlink: fix soft lockup when netlink adds new entries"

Pavel Roskin (1):
      ath9k: stop on rates with idx -1 in ath9k rate control's .tx_status

Peter Hurley (1):
      Bluetooth: Fix l2cap conn failures for ssp devices

RongQing.Li (3):
      ipv6: ip6_route_output() never returns NULL.
      ethernet/broadcom: ip6_route_output() never returns NULL.
      netfilter: ip6_route_output() never returns NULL.

Santosh Nayak (1):
      enic: Fix endianness bug.

Scott Talbert (1):
      Move Logitech Harmony 900 from cdc_ether to zaurus

Simon Horman (1):
      ipvs: fix matching of fwmark templates during scheduling

Ulisses Furquim (2):
      Bluetooth: Remove usage of __cancel_delayed_work()
      Bluetooth: Fix possible use after free in delete path

Vinicius Costa Gomes (1):
      Bluetooth: Fix using an absolute timeout on hci_conn_put()

Yevgeny Petrilin (3):
      mlx4: Replacing pool_lock with mutex
      mlx4: Setting new port types after all interfaces unregistered
      mlx4_core: Fixing array indexes when setting port types

stephen hemminger (1):
      gre: fix spelling in comments

 drivers/atm/solos-pci.c                         |    4 +-
 drivers/bluetooth/btusb.c                       |    4 +-
 drivers/net/can/sja1000/sja1000.c               |   13 ++++-
 drivers/net/ethernet/atheros/atl1c/atl1c_main.c |    4 -
 drivers/net/ethernet/broadcom/b44.c             |    2 +-
 drivers/net/ethernet/broadcom/cnic.c            |    6 ++-
 drivers/net/ethernet/cisco/enic/cq_enet_desc.h  |    2 +-
 drivers/net/ethernet/cisco/enic/enic_pp.c       |    2 +-
 drivers/net/ethernet/jme.c                      |   10 +---
 drivers/net/ethernet/jme.h                      |    2 +-
 drivers/net/ethernet/mellanox/mlx4/eq.c         |    8 +-
 drivers/net/ethernet/mellanox/mlx4/main.c       |   10 ++-
 drivers/net/ethernet/mellanox/mlx4/mlx4.h       |    2 +-
 drivers/net/ethernet/micrel/ks8851_mll.c        |    2 +-
 drivers/net/ethernet/sfc/rx.c                   |    4 +-
 drivers/net/ethernet/ti/davinci_emac.c          |    6 +-
 drivers/net/phy/icplus.c                        |   55 ++++++++++------
 drivers/net/ppp/ppp_generic.c                   |   23 +++++++
 drivers/net/usb/cdc_ether.c                     |    7 ++
 drivers/net/usb/hso.c                           |    2 +-
 drivers/net/usb/zaurus.c                        |   12 ++++
 drivers/net/vmxnet3/vmxnet3_drv.c               |    4 +-
 drivers/net/wireless/ath/ath9k/rc.c             |    2 +-
 drivers/net/wireless/mwifiex/cfg80211.c         |    8 ++-
 include/linux/if_link.h                         |    1 +
 include/linux/netfilter_bridge/ebtables.h       |    4 +-
 include/linux/rtnetlink.h                       |    3 +
 include/linux/skbuff.h                          |   10 +++
 include/net/bluetooth/bluetooth.h               |    2 +
 include/net/bluetooth/hci_core.h                |    6 +-
 include/net/bluetooth/l2cap.h                   |   12 ++--
 include/net/netfilter/nf_conntrack.h            |    2 +-
 include/net/rtnetlink.h                         |    2 +-
 net/atm/clip.c                                  |   10 ++-
 net/bluetooth/af_bluetooth.c                    |   12 ++--
 net/bluetooth/hci_conn.c                        |    4 +
 net/bluetooth/hci_core.c                        |    3 +-
 net/bluetooth/l2cap_core.c                      |   24 ++++---
 net/bluetooth/l2cap_sock.c                      |    4 +-
 net/bluetooth/rfcomm/core.c                     |   18 ++++--
 net/bluetooth/rfcomm/sock.c                     |    2 +
 net/core/neighbour.c                            |    2 +
 net/core/rtnetlink.c                            |   78 +++++++++++++++++------
 net/ipv4/ip_gre.c                               |   10 ++--
 net/ipv4/ping.c                                 |    1 +
 net/ipv4/xfrm4_mode_beet.c                      |    5 +-
 net/ipv4/xfrm4_mode_tunnel.c                    |    6 +-
 net/ipv6/ip6mr.c                                |    4 +-
 net/ipv6/ndisc.c                                |    5 +-
 net/ipv6/xfrm6_mode_beet.c                      |    6 +--
 net/ipv6/xfrm6_mode_tunnel.c                    |    6 +-
 net/mac80211/debugfs_sta.c                      |    4 +-
 net/mac80211/rate.c                             |    2 +-
 net/mac80211/rate.h                             |    3 +-
 net/mac80211/sta_info.h                         |    2 +
 net/netfilter/ipvs/ip_vs_core.c                 |    2 +-
 net/netfilter/nf_conntrack_core.c               |   38 ++++++++++-
 net/netfilter/nf_conntrack_netlink.c            |   46 +++++---------
 net/netfilter/nf_queue.c                        |   40 +++++++++---
 net/netfilter/xt_TEE.c                          |    5 +-
 net/sched/sch_netem.c                           |    6 +-
 61 files changed, 380 insertions(+), 204 deletions(-)
