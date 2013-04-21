From: David Miller <davem@davemloft.net>
Subject: [GIT] Networking
Date: Sat, 20 Apr 2013 21:16:31 -0400 (EDT)
Message-ID: <20130420.211631.2225441203953104357.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=euc-kr
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:37424 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750874Ab3DUBQd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 20 Apr 2013 21:16:33 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


1) ax88796 does 64-bit divides which causes link errors on ARM, fix
   from Arnd Bergmann.

2) Once an improper offload setting is detected on an SKB we don't
   rate limit the log message so we can very easily live lock.  From
   Ben Greear.

3) Openvswitch cannot report vport configuration changes reliably
   because it didn't preallocate the netlink notification message
   before changing state.  From Jesse Gross.

4) The effective UID/GID SCM credentials fix, from Linus.

5) When a user explicitly asks for wireless authentication, cfg80211
   isn't told about the AP detachment leaving inconsistent state.  Fix
   from Johannes Berg.

6) Fix self-MAC checks in batman-adv on multi-mesh nodes, from Antonio
   Quartulli.

7) Revert build_skb() change sin IGB driver, can result in memory
   corruption.  From Alexander Duyck.

8) Fix setting VLANs on virtual functions in IXGBE, from Greg Rose.

9) Fix TSO races in qlcnic driver, from Sritej Velaga.

10) In bnx2x the kernel driver and UNDI firmware can try to program
    the chip at the same time, resulting in corruption.  Add proper
    synchronization.  From Dmitry Kravkov.

11) Fix corruption of status block in firmware ram in bxn2x, from
    Ariel Elior.

12) Fix load balancing hash regression of bonding driver in forwarding
    configurations, from Eric Dumazet.

13) Fix TS ECR regression in TCP by calling tcp_replace_ts_recent() in
    all the right spots, from Eric Dumazet.

14) Fix several bonding bugs having to do with address manintainence,
    including not removing address when configuration operations encoun=
ter
    errors, missed locking on the address lists, missing refcounting on
    VLAN objects, etc.  All from Nikolay Aleksandrov.

15) Add workarounds for firmware bugs in LTE qmi_wwan devices, wherein
    the devices fail to add a proper ethernet header while on LTE
    networks but otherwise properly do so on 2G and 3G ones.  From
    Bj=A9=AArn Mork.

Please pull, thanks a lot!

The following changes since commit 96d8683483b7eb194609edd1afe9143a0467=
b7d3:

  Merge branch 'for-linus' of git://git.kernel.org/pub/scm/linux/kernel=
/git/sage/ceph-client (2013-04-17 12:52:02 -0700)

are available in the git repository at:


  git://git.kernel.org/pub/scm/linux/kernel/git/davem/net.git master

for you to fetch changes up to 83f1b4ba917db5dc5a061a44b3403ddb6e783494=
:

  net: fix incorrect credentials passing (2013-04-20 16:56:42 -0400)

----------------------------------------------------------------
Alexander Duyck (1):
      igb: Revert support for build_skb in igb

Antonio Quartulli (1):
      batman-adv: make is_my_mac() check for the current mesh only

Arend van Spriel (2):
      brcmfmac: remove advertising P2P device support
      brcmsmac: request firmware in .start() callback

Ariel Elior (1):
      bnx2x: Fix status blocks configuration

Arnd Bergmann (1):
      net: ax88796: avoid 64 bit arithmetic

Ben Greear (1):
      net: rate-limit warn-bad-offload splats.

Bj=A9=AArn Mork (3):
      net: qmi_wwan: fixup missing ethernet header (firmware bug workar=
ound)
      net: qmi_wwan: fixup destination address (firmware bug workaround=
)
      net: qmi_wwan: prevent duplicate mac address on link (firmware bu=
g workaround)

Dan Carpenter (1):
      irda: small read past the end of array in debug code

David S. Miller (7):
      Merge branch 'fixes' of git://git.kernel.org/.../jesse/openvswitc=
h
      Merge tag 'batman-adv-fix-for-davem' of git://git.open-mesh.org/l=
inux-merge
      Merge branch 'qlogic'
      Merge branch 'for-davem' of git://git.kernel.org/.../linville/wir=
eless
      Merge branch 'master' of git://git.kernel.org/.../pablo/nf
      Merge branch 'bonding'
      Merge branch 'qmi_wwan'

Dmitry Kravkov (1):
      bnx2x: Prevent UNDI FW illegal host access

Eric Dumazet (2):
      bonding: fix l23 and l34 load balancing in forwarding path
      tcp: call tcp_replace_ts_recent() from tcp_ack()

=46elix Fietkau (2):
      ath9k_htc: accept 1.x firmware newer than 1.3
      ath9k_hw: change AR9580 initvals to fix a stability issue

=46lorian Westphal (1):
      netfilter: xt_rpfilter: skip locally generated broadcast/multicas=
t, too

Greg Rose (1):
      ixgbe: Fix a bug in setting VF VLAN via PF

Hong Zhiguo (1):
      openvswitch: correct an invalid BUG_ON

Jesse Gross (1):
      openvswitch: Preallocate reply skb in ovs_vport_cmd_set().

Jitendra Kalsaria (3):
      qlcnic: Stop traffic before performing loopback test
      qlge: Fix ethtool autoneg advertising.
      qlge: Update version to 1.00.00.32.

Johannes Berg (2):
      mac80211: fix LED in idle handling
      mac80211: fix cfg80211 interaction on auth/assoc request

John W. Linville (3):
      Merge branch 'for-john' of git://git.kernel.org/.../jberg/mac8021=
1
      Merge branch 'for-john' of git://x-git.kernel.org/.../jberg/mac80=
211
      Merge branch 'master' of git://git.kernel.org/.../linville/wirele=
ss into for-davem

Jozsef Kadlecsik (1):
      netfilter: ipset: bitmap:ip,mac: fix listing with timeout

Linus Torvalds (1):
      net: fix incorrect credentials passing

Rafa=A9=A9 Mi=A9=A9ecki (1):
      ssb: implement spurious tone avoidance

Shahed Shaikh (1):
      qlcnic: Fix typo in logs

Sritej Velaga (2):
      qlcnic: fix TSO race condition
      qlge: Fix receive path to drop error frames

Wei Yongjun (1):
      pkt_sched: fix error return code in fw_change_attrs()

Zefir Kurtisi (1):
      ath9k: fix DFS detector called in softirq context

nikolay@redhat.com (5):
      bonding: mc addresses don't get deleted on enslave failure
      bonding: vlans don't get deleted on enslave failure
      bonding: primary_slave & curr_active_slave are not cleaned on ens=
lave failure
      bonding: disable netpoll on enslave failure
      bonding: in bond_mc_swap() bond's mc addr list is walked without =
lock

 drivers/net/bonding/bond_main.c                       |  76 ++++++++++=
+------
 drivers/net/ethernet/8390/ax88796.c                   |   2 +-
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c       |   7 +-
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c      |   4 +
 drivers/net/ethernet/intel/igb/igb.h                  |   8 --
 drivers/net/ethernet/intel/igb/igb_main.c             | 110 +---------=
---------------
 drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c        |   6 ++
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.c   |  15 ++--
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_io.c        |   3 +-
 drivers/net/ethernet/qlogic/qlge/qlge.h               |   2 +-
 drivers/net/ethernet/qlogic/qlge/qlge_ethtool.c       |   2 +-
 drivers/net/ethernet/qlogic/qlge/qlge_main.c          |  36 ++++++--
 drivers/net/usb/qmi_wwan.c                            | 104 ++++++++++=
+++++++++++++
 drivers/net/wireless/ath/ath9k/ar9580_1p0_initvals.h  |   2 +-
 drivers/net/wireless/ath/ath9k/dfs_pattern_detector.c |   4 +-
 drivers/net/wireless/ath/ath9k/dfs_pri_detector.c     |   4 +-
 drivers/net/wireless/ath/ath9k/htc_drv_init.c         |   2 +-
 drivers/net/wireless/b43/phy_n.c                      |   3 +-
 drivers/net/wireless/brcm80211/brcmfmac/wl_cfg80211.c |   7 +-
 drivers/net/wireless/brcm80211/brcmsmac/mac80211_if.c | 264 ++++++++++=
+++++++++++++++++++------------------------------
 drivers/ssb/driver_chipcommon_pmu.c                   |  29 +++++++
 include/linux/ssb/ssb_driver_chipcommon.h             |   2 +
 include/net/irda/irlmp.h                              |   3 +-
 include/net/scm.h                                     |   4 +-
 net/batman-adv/main.c                                 |   5 +-
 net/batman-adv/main.h                                 |   2 +-
 net/batman-adv/routing.c                              |  38 +++++----
 net/batman-adv/translation-table.c                    |   2 +-
 net/batman-adv/vis.c                                  |   4 +-
 net/core/dev.c                                        |   3 +
 net/ipv4/netfilter/ipt_rpfilter.c                     |   8 +-
 net/ipv4/tcp_input.c                                  |  64 +++++++---=
-----
 net/ipv6/netfilter/ip6t_rpfilter.c                    |   8 +-
 net/irda/iriap.c                                      |   3 +-
 net/irda/irlmp.c                                      |  10 ++-
 net/mac80211/iface.c                                  |  27 ++++--
 net/mac80211/mlme.c                                   |  24 +++++-
 net/netfilter/ipset/ip_set_bitmap_ipmac.c             |   6 +-
 net/openvswitch/datapath.c                            |  30 ++++---
 net/openvswitch/flow.c                                |   2 +-
 net/sched/cls_fw.c                                    |   2 +-
 41 files changed, 544 insertions(+), 393 deletions(-)
