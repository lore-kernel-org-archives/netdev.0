From: David Miller <davem@davemloft.net>
Subject: [GIT] Networking
Date: Thu, 19 Mar 2015 00:59:05 -0400 (EDT)
Message-ID: <20150319.005905.730611236301561049.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=euc-kr
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


1) Fix packet header offset calculation in _decode_session6(), from
   Hajime Tazaki.

2) Fix route leak in error paths of xfrm_lookup(), from Huaibin Wang.

3) Be sure to clear state properly when scans fail in iwlwifi mvm
   code, from Luciano Coelho.

4) iwlwifi tries to stop scans that aren't actually running, also
   from Luciano Coelho.

5) mac80211 should drop mesh frames that are not encrypted, fix
   from Bob Copeland.

6) Add new device ID to b43 wireless driver for BCM432228 chips,
   from Rafa=A9=A9 Mi=A9=A9ecki.

7) Fix accidental addition of members after variable sized array
   in struct tc_u_hnode, from WANG Cong.

8) Don't re-enable interrupts until after we call napi_complete()
   in ibmveth and WIZnet drivers, frm Yongbae Park.

9) Fix regression in vlan tag handling of fec driver, from Fugang
   Duan.

10) If a network namespace change fails during rtnl_newlink(),
    we don't unwind the device registry properly.

11) Fix two TCP regressions, from Neal Cardwell:
	a) Don't allow snd_cwnd_cnt to accumulate huge values
	   due to missing test in tcp_cong_avoid_ai().
	b) Restore CUBIC back to advancing cwnd by 1.5x packets
	   per RTT.

12) Fix performance regression in xne-netback involving push TX
    notifications, from David Vrabel.

13) __skb_tstamp_tx() can be called with a NULL sk pointer, do not
    dereference blindly.  From Willem de Bruijn.

14) Fix potential stack overflow in RDS protocol stack, from Arnd
    Bergmann.

15) VXLAN_VID_MASK used incorrectly in new remote checksum offload
    support of VXLAN driver.  Fix from Alexey Kodanev.

16) Fix too small netlink SKB allocation in inet_diag layer, from
    Eric Dumazet.

17) ieee80211_check_combinations() does not count interfaces
    correctly, from Andrei Otcheretianski.

18) Hardware feature determination in bxn2x driver references a
    piece of software state that actually isn't initialized yet,
    fix from Michal Schmidt.

19) inet_csk_wait_for_connect() needs a sched_annotate_sleep()
    annoation, from Eric Dumazet.

Please pull, thanks a lot!

The following changes since commit affb8172de395a6e1db52ed9790ca0456d8c=
29a9:

  Merge git://git.kernel.org/pub/scm/virt/kvm/kvm (2015-03-09 18:59:50 =
-0700)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/davem/net.git=20

for you to fetch changes up to 8d006e0105978619fb472e150c88b0d49337fe2b=
:

  Revert "net: cx82310_eth: use common match macro" (2015-03-18 22:37:3=
8 -0400)

----------------------------------------------------------------
Ahmed S. Darwish (1):
      can: kvaser_usb: Fix tx queue start/stop race conditions

Al Viro (2):
      caif: fix MSG_OOB test in caif_seqpkt_recvmsg()
      rxrpc: bogus MSG_PEEK test in rxrpc_recvmsg()

Alexey Kodanev (2):
      net: sysctl_net_core: check SNDBUF and RCVBUF for min length
      vxlan: fix wrong usage of VXLAN_VID_MASK

Ameen Ali (1):
      tulip_core.c : out-of-bounds check.

Andrei Otcheretianski (2):
      iwlwifi: mvm: Fix ROC removal
      mac80211: count interfaces correctly for combination checks

Arnd Bergmann (1):
      rds: avoid potential stack overflow

Bob Copeland (1):
      mac80211: drop unencrypted frames in mesh fwding

Dan Carpenter (1):
      isdn: icn: use strlcpy() when parsing setup options

Daniel Borkmann (1):
      act_bpf: allow non-default TC_ACT opcodes as BPF exec outcome

David S. Miller (6):
      Merge tag 'wireless-drivers-for-davem-2015-03-10' of git://git.ke=
rnel.org/.../kvalo/wireless-drivers
      net: Handle unregister properly when netdev namespace change fail=
s.
      Merge tag 'linux-can-fixes-for-4.0-20150314' of git://git.kernel.=
org/.../mkl/linux-can
      Merge branch 'master' of git://git.kernel.org/.../klassert/ipsec
      Merge tag 'mac80211-for-davem-2015-03-16' of git://git.kernel.org=
/.../jberg/mac80211
      Merge branch 'mlx4-net'

David Vrabel (1):
      xen-netback: notify immediately after pushing Tx response.

Emmanuel Grumbach (2):
      iwlwifi: fix max_ht_ampdu_exponent for older devices
      iwlwifi: mvm: BT Coex - fix a NULL pointer exception

Eran Ben Elisha (2):
      net/mlx4_en: Fix off-by-one in ethtool statistics display
      net/mlx4_en: Set statistics bitmap at port init

Eric Dumazet (3):
      xps: must clear sender_cpu before forwarding
      inet_diag: fix possible overflow in inet_diag_dump_one_icsk()
      inet: Clean up inet_csk_wait_for_connect() vs. might_sleep()

Eyal Shapira (2):
      iwlwifi: mvm: rs: fix BT Coex check to look at the correct ant
      iwlwifi: mvm: disable beamformer unless FW supports it

=46abio Estevam (1):
      Revert "net: fec: fix the warning found by dma debug"

Hajime Tazaki (1):
      xfrm6: Fix a offset value for network header in _decode_session6

Hariprasad Shenai (1):
      cxgb4: fix coccinelle warnings

Jason Wang (1):
      virtio-net: correctly delete napi hash

Johannes Berg (3):
      mac80211: ask for ECSA IE to be considered for beacon parse CRC
      nl80211: ignore HT/VHT capabilities without QoS/WMM
      mac80211: ignore CSA to same channel

Kalle Valo (1):
      Merge tag 'iwlwifi-for-kalle-2015-03-05' of https://git.kernel.or=
g/.../iwlwifi/iwlwifi-fixes

Larry Finger (1):
      rtlwifi: Improve handling of IPv6 packets

Luciano Coelho (2):
      iwlwifi: mvm: call ieee80211_scan_completed() even if scan abort =
fails
      iwlwifi: mvm: don't try to stop scans that are not running anymor=
e

Majd Dibbiny (1):
      IB/mlx4: Saturate RoCE port PMA counters in case of overflow

Michal Kazior (1):
      mac80211: disable u-APSD queues by default

Michal Schmidt (1):
      bnx2x: fix encapsulation features on 57710/57711

Michal Simek (1):
      net: can: Enable xilinx driver for ARM64

Moni Shoua (1):
      IB/mlx4: Verify net device validity on port change event

Neal Cardwell (2):
      tcp: fix tcp_cong_avoid_ai() credit accumulation bug with decreas=
es in w
      tcp: restore 1.5x per RTT limit to CUBIC cwnd growth in congestio=
n avoidance

Nicolas Dichtel (2):
      netdevice.h: fix ndo_bridge_* comments
      ip6_tunnel: fix error code when tunnel exists

Nimrod Andy (1):
      net: fec: fix receive VLAN CTAG HW acceleration issue

Oliver Hartkopp (1):
      net: add comment for sock_efree() usage

Ondrej Zary (1):
      Revert "net: cx82310_eth: use common match macro"

Pontus Fuchs (1):
      brcmfmac: Perform bound checking on vendor command buffer

Rafa=A9=A9 Mi=A9=A9ecki (1):
      b43: fix support for 5 GHz only BCM43228 model

Robert Jarzmik (1):
      Revert "smc91x: retrieve IRQ and trigger flags in a modern way"

Steffen Klassert (1):
      xfrm: Fix local error reporting crash with interfamily tunnels

Venkat Venkatsubra (1):
      bridge: reset bridge mtu after deleting an interface

WANG Cong (1):
      net_sched: fix struct tc_u_hnode layout in u32

Willem de Bruijn (1):
      sock: fix possible NULL sk dereference in __skb_tstamp_tx

Yongbae Park (2):
      ibmveth: enable interrupts after napi_complete()
      net: WIZnet drivers: enable interrupts after napi_complete()

chas williams - CONTRACTOR (1):
      MAINTAINERS: Update my email address

huaibin Wang (1):
      xfrm: release dst_orig in case of error in xfrm_lookup()

 MAINTAINERS                                      |  2 +-
 drivers/infiniband/hw/mlx4/mad.c                 | 20 ++++++++++---
 drivers/infiniband/hw/mlx4/main.c                |  6 +++-
 drivers/isdn/icn/icn.c                           |  2 +-
 drivers/net/can/Kconfig                          |  2 +-
 drivers/net/can/usb/kvaser_usb.c                 | 83 ++++++++++++++++=
+++++++++++++++--------------------
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c |  2 +-
 drivers/net/ethernet/chelsio/cxgb4/t4_hw.c       |  2 +-
 drivers/net/ethernet/dec/tulip/tulip_core.c      |  2 +-
 drivers/net/ethernet/freescale/fec_main.c        | 37 ++++++++--------=
-------
 drivers/net/ethernet/ibm/ibmveth.c               |  4 +--
 drivers/net/ethernet/mellanox/mlx4/en_netdev.c   |  4 +--
 drivers/net/ethernet/mellanox/mlx4/mlx4_en.h     |  2 +-
 drivers/net/ethernet/smsc/smc91x.c               | 20 +++++--------
 drivers/net/ethernet/wiznet/w5100.c              |  2 +-
 drivers/net/ethernet/wiznet/w5300.c              |  2 +-
 drivers/net/usb/cx82310_eth.c                    | 11 ++++++-
 drivers/net/virtio_net.c                         |  9 +++---
 drivers/net/vxlan.c                              |  4 +--
 drivers/net/wireless/b43/main.c                  |  1 +
 drivers/net/wireless/brcm80211/brcmfmac/vendor.c | 15 ++++++++--
 drivers/net/wireless/iwlwifi/iwl-1000.c          |  6 ++--
 drivers/net/wireless/iwlwifi/iwl-2000.c          | 13 +++++---
 drivers/net/wireless/iwlwifi/iwl-5000.c          |  6 ++--
 drivers/net/wireless/iwlwifi/iwl-6000.c          | 18 +++++++----
 drivers/net/wireless/iwlwifi/mvm/coex.c          |  3 +-
 drivers/net/wireless/iwlwifi/mvm/coex_legacy.c   |  3 +-
 drivers/net/wireless/iwlwifi/mvm/mac80211.c      | 38 ++++++++++++++++=
+++++--
 drivers/net/wireless/iwlwifi/mvm/rs.c            | 21 ++++++++-----
 drivers/net/wireless/iwlwifi/mvm/scan.c          | 13 ++++----
 drivers/net/wireless/iwlwifi/mvm/time-event.c    |  9 ++----
 drivers/net/wireless/rtlwifi/base.c              |  7 +++--
 drivers/net/xen-netback/netback.c                | 23 +++++++-------
 include/linux/netdevice.h                        |  5 +++-
 include/linux/skbuff.h                           |  7 +++++
 include/net/dst.h                                |  1 +
 include/net/vxlan.h                              |  1 +
 net/bridge/br_if.c                               |  2 ++
 net/caif/caif_socket.c                           |  2 +-
 net/core/rtnetlink.c                             | 26 ++++++++--------
 net/core/skbuff.c                                | 10 +++++--
 net/core/sock.c                                  |  4 +++
 net/core/sysctl_net_core.c                       | 10 ++++---
 net/ipv4/inet_connection_sock.c                  |  1 +
 net/ipv4/inet_diag.c                             | 18 +++++++++--
 net/ipv4/ip_forward.c                            |  1 +
 net/ipv4/tcp_cong.c                              |  6 ++++
 net/ipv4/tcp_cubic.c                             |  6 ++--
 net/ipv4/xfrm4_output.c                          |  2 +-
 net/ipv6/ip6_output.c                            |  1 +
 net/ipv6/ip6_tunnel.c                            | 33 ++++++++++------=
----
 net/ipv6/xfrm6_output.c                          |  2 +-
 net/ipv6/xfrm6_policy.c                          |  1 +
 net/mac80211/ieee80211_i.h                       | 24 +++++++++++----
 net/mac80211/mlme.c                              | 16 +++++++++-
 net/mac80211/rx.c                                |  3 ++
 net/mac80211/util.c                              |  2 +-
 net/rds/iw_rdma.c                                | 40 ++++++++++++++--=
---------
 net/rxrpc/ar-recvmsg.c                           |  2 +-
 net/sched/act_bpf.c                              | 36 ++++++++++++++++=
+-----
 net/sched/cls_u32.c                              |  5 +++-
 net/wireless/nl80211.c                           | 10 +++++++
 net/xfrm/xfrm_policy.c                           | 12 ++++----
 63 files changed, 444 insertions(+), 237 deletions(-)
