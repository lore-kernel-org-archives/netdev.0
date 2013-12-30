From: Or Gerlitz <or.gerlitz@gmail.com>
Subject: Re: [GIT] Networking
Date: Mon, 30 Dec 2013 14:50:09 +0200
Message-ID: <CAJZOPZLciJ=X9_h9eqd0KrdkrOT6tKw93wFnmDKY6cQfG_4ZTw@mail.gmail.com>
References: <20131229.230224.1652891996387193020.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Alexei Starovoitov <ast@plumgrid.com>,
	Wei-Chun Chao <weichunc@plumgrid.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f47.google.com ([209.85.160.47]:48505 "EHLO
	mail-pb0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754487Ab3L3MuK convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Dec 2013 07:50:10 -0500
Received: by mail-pb0-f47.google.com with SMTP id um1so11503540pbc.34
        for <netdev@vger.kernel.org>; Mon, 30 Dec 2013 04:50:10 -0800 (PST)
In-Reply-To: <20131229.230224.1652891996387193020.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Dec 30, 2013 at 6:02 AM, David Miller <davem@davemloft.net> wro=
te:

> Some holiday bug fixes for 3.13... There is still one bug I'd like to=
 get fixed
> before 3.13-final.

Hi Dave,

Just wanted to check with you re this fix which makes hw offloaded
vxlan gso traffic from VMs to actually work...
http://patchwork.ozlabs.org/patch/303025
I would say we really want it for 3.13 and after spending some time
there into -stable down to 3.10.y where the offloaded gso was
introduced - makes sense?


Or.

>
>
> The vlan code erroneously assignes the header ops of the underlying r=
eal device
> to the VLAN device above it when the real device can hardware offload=
 VLAN
> handling.  That's completely bogus because header ops are tied to the=
 device
> type, so they only expect to see a 'dev' argument compatible with the=
ir ops.
>
> The fix is the have the VLAN code use a special set of header ops tha=
t does
> the pass-thru correctly, by calling the underlying real device's head=
er ops
> but _also_ passing in the real device instead of the VLAN device.
>
> That fix is currently waiting some testing.
>
> Anyways, of note here:
>
> 1) Fix bitmap edge case in radiotap, from Johannes Berg.
>
> 2) Fix oops on driver unload in rtlwifi, from Larry Finger.
>
> 3) Bonding doesn't do locking correctly during speed/duplex/link chan=
ges,
>    from Ding Tianhong.
>
> 4) Fix header parsing in GRE code, this bug has been around for a few
>    releases.  From Timo Ter=E4s.
>
> 5) SIT tunnel driver MTU check needs to take GSO into account, from
>    Eric Dumazet.
>
> 6) Minor info leak in inet_diag, from Daniel Borkmann.
>
> 7) Info leak in YAM hamradio driver, from Salva Peir=F3.
>
> 8) Fix route expiration state handling in ipv6 routing code, from Li
>    RongQing.
>
> 9) DCCP probe module does not check request_module()'s return value,
>    from Wang Weidong.
>
> 10) cpsw driver passes NULL device names to request_irq(), from
>     Mugunthan V N.
>
> 11) Prevent a NULL splat in RDS binding code, from Sasha Levin.
>
> 12) Fix 4G overflow test in tg3 driver, from Nithin Sujir.
>
> 13) Cure use after free in arc_emac and fec driver's software
>     timestamp handling, from Eric Dumazet.
>
> 14) SIT driver can fail to release the route when
>     iptunnel_handle_offloads() throws an error.  From Li RongQing.
>
> 15) Several batman-adv fixes from Simon Wunderlich and Antonio Quartu=
lli.
>
> 16) Fix deadlock during TIPC socket release, from Ying Xue.
>
> 17) Fix regression in ROSE protocol recvmsg() msg_name handling, from
>     Florian Westphal.
>
> 18) stmmac PTP support releases wrong spinlock, from Vince Bridgers.
>
> Please pull, thanks a lot!
>
> The following changes since commit 35eecf052250f663f07a4cded7d3503fd1=
b50729:
>
>   Merge branch 'drm-fixes' of git://people.freedesktop.org/~airlied/l=
inux (2013-12-17 16:59:59 -0800)
>
> are available in the git repository at:
>
>
>   git://git.kernel.org/pub/scm/linux/kernel/git/davem/net.git master
>
> for you to fetch changes up to 7cd013992335b1c5156059248ee765fb3b14d1=
54:
>
>   stmmac: Fix incorrect spinlock release and PTP cap detection. (2013=
-12-29 22:37:00 -0500)
>
> ----------------------------------------------------------------
> Antonio Quartulli (4):
>       batman-adv: fix size of batadv_icmp_header
>       batman-adv: fix alignment for batadv_tvlv_tt_change
>       batman-adv: clean nf state when removing protocol header
>       batman-adv: fix vlan header access
>
> Betty Dall (1):
>       atl1c: Check return from pci_find_ext_capability() in atl1c_res=
et_pcie()
>
> Daniel Borkmann (2):
>       net: inet_diag: zero out uninitialized idiag_{src,dst} fields
>       netfilter: nft_exthdr: call ipv6_find_hdr() with explicitly ini=
tialized offset
>
> David Ertman (3):
>       e1000e: fix compiler warnings
>       e1000e: fix compiler warning (maybe-unitialized variable)
>       e1000e: Fix a compile flag mis-match for suspend/resume
>
> David Gibson (1):
>       netxen: Correct off-by-one errors in bounds checks
>
> David S. Miller (7):
>       Merge branch 'bond_locking'
>       Merge branch 'master' of git://git.kernel.org/.../jkirsher/net
>       Merge branch 'for-davem' of git://git.kernel.org/.../linville/w=
ireless
>       Merge branch 'cxgb4'
>       net: Add some clarification to skb_tx_timestamp() comment.
>       Merge branch 'master' of git://git.kernel.org/.../pablo/nf
>       Merge tag 'batman-adv-fix-for-davem' of git://git.open-mesh.org=
/linux-merge
>
> Don Skidmore (1):
>       ixgbe: fix for unused variable warning with certain config
>
> Eric Dumazet (3):
>       ipv6: sit: update mtu check to take care of gso packets
>       net: fec: fix potential use after free
>       arc_emac: fix potential use after free
>
> Fabio Estevam (1):
>       fec: Do not assume that PHY reset is active low
>
> Florian Westphal (2):
>       macvlan: fix netdev feature propagation from lower device
>       net: rose: restore old recvmsg behavior
>
> Gao feng (1):
>       netfilter: nfnetlink_log: unset nf_loggers for netns when unloa=
ding module
>
> Haiyang Zhang (1):
>       hyperv: Fix race between probe and open calls
>
> Hannes Frederic Sowa (2):
>       ipv6: pmtudisc setting not respected with UFO/CORK
>       ipv4: consistent reporting of pmtu data in case of corking
>
> Helmut Schaa (1):
>       netfilter: nf_ct_timestamp: Fix BUG_ON after netns deletion
>
> Jamal Hadi Salim (1):
>       net_sched: act: Dont increment refcnt on replace
>
> Jesper Dangaard Brouer (2):
>       netfilter: WARN about wrong usage of sequence number adjustment=
s
>       ipvs: correct usage/allocation of seqadj ext in ipvs
>
> Johannes Berg (1):
>       radiotap: fix bitmap-end-finding buffer overrun
>
> John Fastabend (1):
>       net: allow netdev_all_upper_get_next_dev_rcu with rtnl lock hel=
d
>
> John W. Linville (3):
>       Merge branch 'for-john' of git://git.kernel.org/.../jberg/mac80=
211
>       Merge branch 'for-upstream' of git://git.kernel.org/.../bluetoo=
th/bluetooth
>       Merge branch 'master' of git://git.kernel.org/.../linville/wire=
less into for-davem
>
> Kumar Sanghvi (8):
>       cxgb4: Reserve stid 0 for T4/T5 adapters
>       cxgb4: Include TCP as protocol when creating server filters
>       cxgb4: Assign filter server TIDs properly
>       cxgb4: Account for stid entries properly in case of IPv6
>       cxgb4: Add API to correctly calculate tuple fields
>       RDMA/cxgb4: Calculate the filter server TID properly
>       RDMA/cxgb4: Server filters are supported only for IPv4
>       RDMA/cxgb4: Use cxgb4_select_ntuple to correctly calculate ntup=
le fields
>
> Larry Finger (1):
>       rtlwifi: pci: Fix oops on driver unload
>
> Leigh Brown (1):
>       net: mvmdio: fix interrupt timeout handling
>
> Li RongQing (2):
>       ipv6: always set the new created dst's from in ip6_rt_copy
>       ipv6: release dst properly in ipip6_tunnel_xmit
>
> Marcel Holtmann (1):
>       Bluetooth: Fix HCI User Channel permission check in hci_sock_se=
ndmsg
>
> Marco Piazza (1):
>       Bluetooth: Add support for Toshiba Bluetooth device [0930:0220]
>
> Mathy Vanhoef (1):
>       ath9k_htc: properly set MAC address and BSSID mask
>
> Michal Schmidt (1):
>       bnx2x: downgrade "valid ME register value" message level
>
> Mugunthan V N (2):
>       drivers: net cpsw: Enable In Band mode in cpsw for 10 mbps
>       drivers: net : cpsw: pass proper device name while requesting i=
rq
>
> Nithin Sujir (1):
>       tg3: Expand 4g_overflow_test workaround to skb fragments of any=
 size.
>
> Pablo Neira Ayuso (3):
>       netfilter: nf_tables: fix dumping with large number of sets
>       netfilter: nf_tables: fix oops when updating table with user ch=
ains
>       netfilter: nf_tables: fix wrong datatype in nft_validate_data_l=
oad()
>
> Paul Durrant (1):
>       xen-netback: fix guest-receive-side array sizes
>
> Peter Korsgaard (4):
>       dm9601: add support for dm9621a based dongle
>       dm9601: fix reception of full size ethernet frames on dm9620/dm=
9621a
>       dm9601: make it clear that dm9620/dm9621a are also supported
>       dm9601: work around tx fifo sync issue on dm962x
>
> Salva Peir=F3 (1):
>       hamradio/yam: fix info leak in ioctl
>
> Sasha Levin (1):
>       rds: prevent dereference of a NULL device
>
> Sergei Shtylyov (1):
>       phy: IRQ cannot be shared
>
> Simon Wunderlich (3):
>       batman-adv: fix alignment for batadv_coded_packet
>       batman-adv: fix header alignment by unrolling batadv_header
>       batman-adv: fix size of batadv_bla_claim_dst
>
> Sujith Manoharan (1):
>       ath9k: Fix interrupt handling for the AR9002 family
>
> Timo Ter=E4s (1):
>       ip_gre: fix msg_name parsing for recvfrom/recvmsg
>
> Ujjal Roy (1):
>       cfg80211: fix WARN_ON for re-association to the expired BSS
>
> Vince Bridgers (1):
>       stmmac: Fix incorrect spinlock release and PTP cap detection.
>
> Wang Weidong (1):
>       dccp: catch failed request_module call in dccp_probe init
>
> Wei Yongjun (1):
>       xen-netback: fix some error return code
>
> Wenliang Fan (1):
>       drivers/net/hamradio: Integer overflow in hdlcdrv_ioctl()
>
> Ying Xue (1):
>       tipc: fix deadlock during socket release
>
> dingtianhong (3):
>       bonding: protect port for bond_3ad_adapter_speed_changed()
>       bonding: protect port for bond_3ad_adapter_duplex_changed()
>       bonding: protect port for bond_3ad_handle_link_change()
>
>  drivers/bluetooth/ath3k.c                            |   2 +
>  drivers/bluetooth/btusb.c                            |   1 +
>  drivers/infiniband/hw/cxgb4/cm.c                     |  78 +++++++++=
-------------------------
>  drivers/net/bonding/bond_3ad.c                       |  45 +++++++++=
+++++------
>  drivers/net/ethernet/arc/emac_main.c                 |   4 +-
>  drivers/net/ethernet/atheros/atl1c/atl1c_main.c      |   8 ++--
>  drivers/net/ethernet/broadcom/bnx2x/bnx2x_vfpf.c     |   2 +-
>  drivers/net/ethernet/broadcom/tg3.c                  |   2 +-
>  drivers/net/ethernet/chelsio/cxgb4/cxgb4.h           |  21 +++++++++=
+
>  drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c      |  59 +++++++++=
++++++++---------
>  drivers/net/ethernet/chelsio/cxgb4/cxgb4_uld.h       |   9 +++-
>  drivers/net/ethernet/chelsio/cxgb4/l2t.c             |  35 +++++++++=
+++++++
>  drivers/net/ethernet/chelsio/cxgb4/l2t.h             |   3 +-
>  drivers/net/ethernet/chelsio/cxgb4/t4_hw.c           | 103 +++++++++=
++++++++++++++++++++++++++++++++++++
>  drivers/net/ethernet/chelsio/cxgb4/t4_regs.h         |  73 +++++++++=
+++++++++++++++++++++++
>  drivers/net/ethernet/freescale/fec_main.c            |  18 +++++---
>  drivers/net/ethernet/intel/e1000e/80003es2lan.c      |   7 +++-
>  drivers/net/ethernet/intel/e1000e/netdev.c           |   4 +-
>  drivers/net/ethernet/intel/e1000e/phy.c              |  10 +++--
>  drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c       |   2 +
>  drivers/net/ethernet/marvell/mvmdio.c                |   6 +++
>  drivers/net/ethernet/qlogic/netxen/netxen_nic_init.c |   4 +-
>  drivers/net/ethernet/stmicro/stmmac/stmmac_main.c    |  20 ++++-----
>  drivers/net/ethernet/stmicro/stmmac/stmmac_ptp.c     |   4 +-
>  drivers/net/ethernet/ti/cpsw.c                       |   4 +-
>  drivers/net/hamradio/hdlcdrv.c                       |   2 +
>  drivers/net/hamradio/yam.c                           |   1 +
>  drivers/net/hyperv/netvsc_drv.c                      |  20 ++++-----
>  drivers/net/macvlan.c                                |  16 +++++--
>  drivers/net/phy/phy.c                                |   6 +--
>  drivers/net/usb/Kconfig                              |   6 +--
>  drivers/net/usb/dm9601.c                             |  44 +++++++++=
+++++------
>  drivers/net/wireless/ath/ath9k/ar9002_mac.c          |  52 +++++++++=
++++++++++----
>  drivers/net/wireless/ath/ath9k/htc_drv_main.c        |  25 +++++++--=
--
>  drivers/net/wireless/ath/ath9k/main.c                |   5 ++-
>  drivers/net/wireless/rtlwifi/pci.c                   |   4 +-
>  drivers/net/xen-netback/common.h                     |  19 ++++++---
>  drivers/net/xen-netback/interface.c                  |  10 +++++
>  drivers/net/xen-netback/netback.c                    |  18 +++++---
>  include/linux/rtnetlink.h                            |   5 +++
>  include/linux/skbuff.h                               |   9 ++++
>  net/batman-adv/bat_iv_ogm.c                          |  36 ++++++++-=
-------
>  net/batman-adv/distributed-arp-table.c               |   6 +--
>  net/batman-adv/fragmentation.c                       |   8 ++--
>  net/batman-adv/icmp_socket.c                         |   6 +--
>  net/batman-adv/main.c                                |  16 +++----
>  net/batman-adv/network-coding.c                      |  22 +++++----=
-
>  net/batman-adv/packet.h                              | 124 +++++++++=
++++++++++++++++++++++++++++++++--------------
>  net/batman-adv/routing.c                             |  30 +++++++--=
-----
>  net/batman-adv/send.c                                |  10 ++---
>  net/batman-adv/soft-interface.c                      |  18 +++++---
>  net/batman-adv/translation-table.c                   |   6 ++-
>  net/bluetooth/hci_sock.c                             |  26 +++++++--=
---
>  net/core/dev.c                                       |   2 +-
>  net/dccp/probe.c                                     |  19 ++++-----
>  net/ipv4/inet_diag.c                                 |  16 +++++++
>  net/ipv4/ip_gre.c                                    |   1 +
>  net/ipv4/ip_output.c                                 |   5 ++-
>  net/ipv6/ip6_output.c                                |  36 +++++++++=
+++----
>  net/ipv6/route.c                                     |   4 +-
>  net/ipv6/sit.c                                       |   6 ++-
>  net/netfilter/ipvs/ip_vs_nfct.c                      |   6 +++
>  net/netfilter/nf_conntrack_seqadj.c                  |   5 +++
>  net/netfilter/nf_conntrack_timestamp.c               |   1 -
>  net/netfilter/nf_tables_api.c                        |  26 +++++++++=
---
>  net/netfilter/nfnetlink_log.c                        |   1 +
>  net/netfilter/nft_exthdr.c                           |   2 +-
>  net/rds/ib.c                                         |   3 +-
>  net/rose/af_rose.c                                   |  16 ++-----
>  net/sched/act_csum.c                                 |  10 ++---
>  net/sched/act_gact.c                                 |   7 ++--
>  net/sched/act_ipt.c                                  |   8 ++--
>  net/sched/act_nat.c                                  |  10 ++---
>  net/sched/act_pedit.c                                |   8 ++--
>  net/sched/act_police.c                               |   4 +-
>  net/sched/act_simple.c                               |   9 ++--
>  net/sched/act_skbedit.c                              |   7 ++--
>  net/tipc/port.c                                      |  45 +++++++--=
-----------
>  net/tipc/port.h                                      |   6 +--
>  net/tipc/socket.c                                    |  46 +++++++++=
+++++-------
>  net/wireless/radiotap.c                              |   4 ++
>  net/wireless/sme.c                                   |  22 +++++----=
-
>  82 files changed, 967 insertions(+), 442 deletions(-)
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
