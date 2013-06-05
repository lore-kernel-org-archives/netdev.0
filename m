From: David Miller <davem@davemloft.net>
Subject: [GIT] Networking
Date: Wed, 05 Jun 2013 02:02:38 -0700 (PDT)
Message-ID: <20130605.020238.455548071532361199.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


1) Fix timeouts with direct mode authentication in mac80211, from
   Stanislaw Gruszka.

2) Aggregation sessions can deadlock in ath9k, from Felix Fietkau.

3) Netfilter's xt_addrtype doesn't work with ipv6 due to route lookups
   creating undesirable cache entries, from Florian Westphal.

4) Fix netfilter's ipt_ULOG from generating non-NULL terminated
   strings.

5) Fix netdev transmit queue crashes in mac80211, from Johannes Berg.

6) Fix copy and paste error in 802.11 stack that broke reporting of
   64-bit station tx statistics, from Felix Fietkau.

7) When qlge_probe fails, it leaks the netdev.  Fix from Wei Yongjun.

8) SKB control block (where we store the IP options information,
   amongst other things) must be cleared properly otherwise ICMP
   sending can crash for IP tunnels.  Fix from Eric Dumazet.

9) Verification of Energy Efficient Ether support was coded wrongly,
   the test was inversed.  Fix from Giuseppe CAVALLARO.

10) TCP handles redirects improperly because the wrong flow key is
    used for the route lookup.  From Michal Kubecek.

11) Don't interpret MSG_CMSG_COMPAT from userspace, fix from
    Andy Lutomirski.

12) The new AF_VSOCK was missing from the lockdep string table,
    fix from Federico Vaga.

13) be2net doesn't handle checksumming of IP fragments properly, from
    Somnath Kotur.

14) Fix several bugs in the device address list code that lead to
    crashes and other misbehaviors.  From Jay Vosburgh.

15) Fix ipv6 segmentation handling of fragmented GRE tunnel traffic,
    from Pravin B Shalr.

16) Fix usage of stale policies in IPSEC layer, from Paul Moore.

17) Fix team driver dump of ports when there are a large number of
    them, from Jiri Pirko.

18) Fix softlockups in UDP ipv4 socket lookup causes by and error
    in the hlist_nulls_for_each_entry_rcu() macro.  From Eric
    Dumazet.

19) Fix several regressions added by the high rate accuracy changes
    to the htb packet scheduler.  From Eric Dumazet.

20) Fix DMA'ing onto the stack in esd_usb2 and peak_usb CAN drivers,
    from Olivier Sobrie and Marc Kleine-Budde.

21) Fix unremovable network devices due to missing route pointer
    installation in the per-device ipv6 address list entries.
    From Gao feng.

22) Apply the tg3 5719 DMA workaround on 5720 chips as well, otherwise
    we get stalls.  From Nithin Sujir.

Please pull, thanks a lot!

The following changes since commit 0e255f1c0c9add2f0c920240ac4cadc28ae2=
74c3:

  Merge git://git.kernel.org/pub/scm/linux/kernel/git/steve/gfs2-3.0-fi=
xes (2013-05-24 08:58:53 -0700)

are available in the git repository at:


  git://git.kernel.org/pub/scm/linux/kernel/git/davem/net master

for you to fetch changes up to 5343a7f8be11951cb3095b91e8e4eb506cfacc0f=
:

  net_sched: htb: do not mix 1ns and 64ns time units (2013-06-04 17:44:=
07 -0700)

----------------------------------------------------------------
Andy Lutomirski (1):
      net: Block MSG_CMSG_COMPAT in send(m)msg and recv(m)msg

Arend van Spriel (3):
      brcmfmac: add additional parameter to brcmf_free_vif()
      brcmfmac: free net device when registration fails
      brcmfmac: use struct net_device::destructor to remove interfaces

Chen Gang (1):
      netfilter: ipt_ULOG: fix non-null terminated string in the nf_log=
 path

Dan Carpenter (1):
      atmel: printing bogus information

David S. Miller (3):
      Merge branch 'master' of git://git.kernel.org/.../pablo/nf
      Merge branch 'for-davem' of git://git.kernel.org/.../linville/wir=
eless
      Merge branch 'fixes-for-3.10' of git://gitorious.org/linux-can/li=
nux-can

Dmitry Kravkov (1):
      bnx2x: fix TCP offload for tunneling ipv4 over ipv6

Emmanuel Grumbach (1):
      iwlwifi: dvm: fix zero LQ CMD sending avoidance

Eric Dumazet (4):
      ip_tunnel: fix kernel panic with icmp_dest_unreach
      net: force a reload of first item in hlist_nulls_for_each_entry_r=
cu
      net_sched: restore "overhead xxx" handling
      net_sched: htb: do not mix 1ns and 64ns time units

=46ederico Vaga (1):
      net/core/sock.c: add missing VSOCK string in af_family_*_key_stri=
ngs

=46elix Fietkau (5):
      ath9k: prevent aggregation session deadlocks
      cfg80211: fix reporting 64-bit station info tx bytes
      ath9k_hw: fix spur mitigation issues on AR934x
      ath9k_hw: fix host interface reset on AR934x
      ath9k_hw: improve performance for AR934x v1.3+

=46lorian Westphal (1):
      netfilter: add nf_ipv6_ops hook to fix xt_addrtype with IPv6

Gabor Juhos (1):
      ath9k: use correct OTP register offsets for AR9550

Gao feng (1):
      ipv6: assign rt6_info to inet6_ifaddr in init_loopback

Giuseppe CAVALLARO (1):
      net: phy: fix a bug when verify the EEE support

Grzegorz Lyczba (1):
      ipvs: Fix reuse connection if real server is dead

Haiyang Zhang (1):
      hyperv: Fix vlan_proto setting in netvsc_recv_callback()

Hante Meuleman (4):
      brcmfmac: Turn off ARP offloading when configured for AP.
      brcmfmac: Fix p2p setup when connected to ap on 5G.
      brcmfmac: Add multi channel support for P2P.
      brcmfmac: Disable powersave mode for P2P link.

Helmut Schaa (1):
      mac80211: Allow single vif mac address change with addr_mask

Jack Morgenstein (1):
      net/mlx4_core: Return -EPROBE_DEFER when a VF is probed before PF=
 is sufficiently initialized

Jan Beulich (1):
      ipvs: ip_vs_sh: fix build

Jason Wang (1):
      tuntap: forbid changing mq flag for persistent device

Jay Vosburgh (4):
      net/core: __hw_addr_create_ex does not initialize sync_cnt
      net/core: __hw_addr_unsync_one "from" address not marked synced
      net/core: __hw_addr_sync_one / _multiple broken
      net/core: dev_mc_sync_multiple calls wrong helper

Jens Renner \(EFE\) (1):
      net: ethernet: xilinx_emaclite: set protocol selector bits when w=
riting ANAR

Jiri Pirko (2):
      list: introduce list_first_entry_or_null
      team: fix port list dump for big number of ports

Johannes Berg (4):
      cfg80211: check wdev->netdev in connection work
      mac80211: fix queue handling crash
      mac80211: assign AP_VLAN hw queues correctly
      mac80211: close AP_VLAN interfaces before unregistering all

John W. Linville (4):
      Samuel Ortiz <sameo@linux.intel.com> says:
      Merge branch 'for-john' of git://git.kernel.org/.../jberg/mac8021=
1
      Merge branch 'for-john' of git://git.kernel.org/.../iwlwifi/iwlwi=
fi-fixes
      Merge branch 'master' of git://git.kernel.org/.../linville/wirele=
ss into for-davem

Jonas Peterson (1):
      net: can: kvaser_usb: fix reception on "USBcan Pro" and "USBcan R=
" type hardware.

Lucas Stach (1):
      net: fec: add fallback to random MAC address

Marc Kleine-Budde (1):
      net: can: peak_usb: Do not do dma on the stack

Michal Kubecek (1):
      ipv4: fix redirect handling for TCP packets

Michal Kube=E8ek (1):
      netfilter: xt_LOG: fix mark logging for IPv6 packets

Nicolas Dichtel (1):
      snmp6: remove IPSTATS_MIB_CSUMERRORS

Nithin Sujir (1):
      tg3: Add read dma workaround for 5720

Olivier Sobrie (1):
      net: can: esd_usb2: Do not do dma on the stack

Or Gerlitz (2):
      net/mlx4_en: Handle unassigned VF MAC address correctly
      net/mlx4_core: Keep VF assigned MAC in the PF admin table

Pablo Neira (1):
      net: fix sk_buff head without data area

Paul Bolle (1):
      NFC: Remove commented out LLCP related Makefile line

Paul Moore (2):
      xfrm: force a garbage collection after deleting a policy
      selinux: fix the labeled xfrm/IPsec reference count handling

Pravin B Shelar (1):
      udp6: Fix udp fragmentation for tunnel traffic.

Sagi Grimberg (1):
      net/mlx4_en: Fix adaptive moderation cq update

Samuel Ortiz (3):
      NFC: mei_phy depends on INTEL_MEI
      NFC: mei_phy: Register event callback when enabling the device
      NFC: mei: Do not disable MEI devices from their remove routine

Somnath Kotur (2):
      be2net: Mark checksum fail for IP fragmented packets
      be2net: Fix crash on 2nd invocation of PCI AER/EEH error_detected=
 hook

Stanislaw Gruszka (1):
      mac80211: fix direct probe auth

Wei Yongjun (2):
      qlge: add missing free_netdev() on error in qlge_probe()
      ptp_pch: fix error handling in pch_probe()

Yuval Mintz (1):
      bnx2x: Fix bridged GSO for 57710/57711 chips

 drivers/net/can/usb/esd_usb2.c                        | 127 ++++++++++=
++++++++++++++++++++++++++++++---------------------------
 drivers/net/can/usb/kvaser_usb.c                      |  64 ++++++++++=
+++++++++++++-----------
 drivers/net/can/usb/peak_usb/pcan_usb_pro.c           |  61 ++++++++++=
+++++++++++-----------
 drivers/net/can/usb/peak_usb/pcan_usb_pro.h           |   1 +
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c       |  16 ++++-----
 drivers/net/ethernet/broadcom/tg3.c                   |  21 +++++++---=
-
 drivers/net/ethernet/broadcom/tg3.h                   |   5 +--
 drivers/net/ethernet/emulex/benet/be.h                |   1 +
 drivers/net/ethernet/emulex/benet/be_cmds.c           |   6 ++--
 drivers/net/ethernet/emulex/benet/be_hw.h             |   2 +-
 drivers/net/ethernet/emulex/benet/be_main.c           |  55 ++++++++++=
+++++--------------
 drivers/net/ethernet/freescale/fec_main.c             |  12 +++++++
 drivers/net/ethernet/mellanox/mlx4/cmd.c              |   2 --
 drivers/net/ethernet/mellanox/mlx4/en_netdev.c        |  17 ++++++---
 drivers/net/ethernet/mellanox/mlx4/fw.c               |  10 ++++--
 drivers/net/ethernet/mellanox/mlx4/main.c             |  20 ++++------=
-
 drivers/net/ethernet/qlogic/qlge/qlge_main.c          |   1 +
 drivers/net/ethernet/xilinx/xilinx_emaclite.c         |   3 +-
 drivers/net/hyperv/netvsc_drv.c                       |   3 +-
 drivers/net/phy/phy.c                                 |   2 +-
 drivers/net/team/team.c                               |   7 ++--
 drivers/net/tun.c                                     |   4 +++
 drivers/net/wireless/ath/ath9k/ar9003_eeprom.h        |   9 +++--
 drivers/net/wireless/ath/ath9k/ar9003_phy.c           |   3 +-
 drivers/net/wireless/ath/ath9k/ath9k.h                |  14 +++-----
 drivers/net/wireless/ath/ath9k/hw.c                   |  25 +++++++++-=
----
 drivers/net/wireless/ath/ath9k/mac.c                  |   2 +-
 drivers/net/wireless/ath/ath9k/main.c                 |   3 +-
 drivers/net/wireless/ath/ath9k/rc.c                   |   5 +--
 drivers/net/wireless/ath/ath9k/reg.h                  |  11 ++++++
 drivers/net/wireless/ath/ath9k/xmit.c                 | 138 ++++++++++=
+++++++++++----------------------------------------------------
 drivers/net/wireless/atmel.c                          |   2 +-
 drivers/net/wireless/brcm80211/brcmfmac/dhd_common.c  |  18 ----------
 drivers/net/wireless/brcm80211/brcmfmac/dhd_linux.c   |  16 +++++----
 drivers/net/wireless/brcm80211/brcmfmac/fweh.c        |   3 +-
 drivers/net/wireless/brcm80211/brcmfmac/fwil_types.h  |   6 ++++
 drivers/net/wireless/brcm80211/brcmfmac/p2p.c         |  74 ++++++++++=
++++++++++++++++++-----------
 drivers/net/wireless/brcm80211/brcmfmac/wl_cfg80211.c |  89 ++++++++++=
+++++++++++++++++++++++++++++--------
 drivers/net/wireless/brcm80211/brcmfmac/wl_cfg80211.h |   3 +-
 drivers/net/wireless/iwlwifi/dvm/sta.c                |   2 +-
 drivers/nfc/Kconfig                                   |   2 +-
 drivers/nfc/mei_phy.c                                 |   9 +++++
 drivers/nfc/microread/mei.c                           |  20 +++-------=
-
 drivers/nfc/pn544/mei.c                               |  20 +++-------=
-
 drivers/ptp/ptp_pch.c                                 |   8 +++--
 include/linux/list.h                                  |  11 ++++++
 include/linux/netfilter_ipv6.h                        |  16 +++++++++
 include/linux/rculist_nulls.h                         |   7 +++-
 include/linux/skbuff.h                                |  15 ++++++++
 include/net/addrconf.h                                |   2 +-
 include/net/sch_generic.h                             |  18 ++++++----
 include/net/xfrm.h                                    |   5 +++
 net/core/dev_addr_lists.c                             |  17 +++++----
 net/core/skbuff.c                                     |   4 +--
 net/core/sock.c                                       |   6 ++--
 net/ipv4/ip_tunnel.c                                  |   2 +-
 net/ipv4/netfilter/ipt_ULOG.c                         |   6 ++--
 net/ipv4/route.c                                      |   7 +++-
 net/ipv6/addrconf.c                                   |   6 ++--
 net/ipv6/netfilter.c                                  |   7 ++++
 net/ipv6/proc.c                                       |   2 +-
 net/ipv6/udp_offload.c                                |  20 ++++++----=
-
 net/key/af_key.c                                      |   4 +++
 net/mac80211/iface.c                                  |  44 ++++++++++=
+++++++++----
 net/mac80211/mlme.c                                   |  12 +++----
 net/netfilter/core.c                                  |   2 ++
 net/netfilter/ipvs/ip_vs_core.c                       |  35 ++++++++++=
+++++++++
 net/netfilter/ipvs/ip_vs_sh.c                         |   2 +-
 net/netfilter/xt_LOG.c                                |   2 +-
 net/netfilter/xt_addrtype.c                           |  27 +++++++++-=
-----
 net/netlink/af_netlink.c                              |   2 +-
 net/nfc/Makefile                                      |   1 -
 net/sched/act_police.c                                |   8 ++---
 net/sched/sch_generic.c                               |   8 +++--
 net/sched/sch_htb.c                                   |  42 ++++++++++=
+-----------
 net/sched/sch_tbf.c                                   |   8 ++---
 net/socket.c                                          |  33 ++++++++++=
++++++--
 net/wireless/nl80211.c                                |   2 +-
 net/wireless/sme.c                                    |   3 ++
 net/xfrm/xfrm_policy.c                                |   3 +-
 net/xfrm/xfrm_user.c                                  |   2 ++
 security/selinux/xfrm.c                               |  34 ++++++++--=
--------
 82 files changed, 836 insertions(+), 511 deletions(-)
