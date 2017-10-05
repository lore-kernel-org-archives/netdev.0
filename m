From: David Miller <davem@davemloft.net>
Subject: [GIT] Networking
Date: Wed, 04 Oct 2017 22:14:23 -0700 (PDT)
Message-ID: <20171004.221423.1419083256570555794.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


1) Check iwlwifi 9000 reorder buffer out-of-space condition properly,
   from Sara Sharon.

2) Fix RCU splat in qualcomm rmnet driver, from Subash Abhinov
   Kasiviswanathan.

3) Fix session and tunnel release races in l2tp, from Guillaume Nault
   and Sabrina Dubroca.

4) Fix endian bug in sctp_diag_dump(), from Dan Carpenter.

5) Several mlx5 driver fixes from the Mellanox folks (max flow
   counters cap check, invalid memory access in IPoIB support, etc.)

6) tun_get_user() should bail if skb->len is zero, from Alexander
   Potapenko.

7) Fix RCU lookups in inetpeer, from Eric Dumazet.

8) Fix locking in packet_do_bund().

9) Handle cb->start() error properly in netlink dump code, from
   Jason A. Donenfeld.

10) Handle multicast properly in UDP socket early demux code.
    From Paolo Abeni.

11) Several erspan bug fixes in ip_gre, from Xin Long.

12) Fix use-after-free in socket filter code, in order to handle the
    face that listener lock is no longer taken during the three-way
    TCP handshake.  From Eric Dumazet.

13) Fix infoleak in RTM_GETSTATS, from Nikolay Aleksandrov.

14) Fix tail call generation in x86-64 BPF JIT, from Alexei
    Starovoitov.

Please pull, thanks a lot!

The following changes since commit cd4175b11685b11c40e31a03e05084cc212b0649:

  Merge branch 'parisc-4.14-2' of git://git.kernel.org/pub/scm/linux/kernel/git/deller/parisc-linux (2017-09-23 06:14:06 -1000)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/davem/net.git 

for you to fetch changes up to e769fcec6bc4bdd1b0e2cf817680148f9c40b1c4:

  net: 8021q: skip packets if the vlan is down (2017-10-04 18:16:48 -0700)

----------------------------------------------------------------
Aleksander Morgado (1):
      rndis_host: support Novatel Verizon USB730L

Alexander Potapenko (1):
      tun: bail out from tun_get_user() if the skb is empty

Alexei Starovoitov (1):
      bpf: fix bpf_tail_call() x64 JIT

Alexey Kodanev (1):
      vti: fix use after free in vti_tunnel_xmit/vti6_tnl_xmit

Andrew Lunn (1):
      net: dsa: mv88e6xxx: Allow dsa and cpu ports in multiple vlans

Antoine Tenart (1):
      net: mvpp2: do not select the internal source clock

Arend Van Spriel (2):
      brcmfmac: add length check in brcmf_cfg80211_escan_handler()
      brcmfmac: setup passive scan if requested by user-space

Arnd Bergmann (3):
      ath10k: mark PM functions as __maybe_unused
      rocker: fix rocker_tlv_put_* functions for KASAN
      netlink: fix nla_put_{u8,u16,u32} for KASAN

Avraham Stern (2):
      iwlwifi: mvm: send all non-bufferable frames on the probe queue
      iwlwifi: mvm: wake the correct mac80211 queue

Christoph Paasch (1):
      net: Set sk_prot_creator when cloning sockets to the right proto

Christophe JAILLET (2):
      cnic: Fix an error handling path in 'cnic_alloc_bnx2x_resc()'
      net: hns3: Fix an error handling path in 'hclge_rss_init_hw()'

Dan Carpenter (1):
      sctp: Fix a big endian bug in sctp_diag_dump()

David S. Miller (8):
      Merge branch 'l2tp-fix-some-races-in-session-deletion'
      Merge branch 'aquantia-fixes'
      Merge tag 'wireless-drivers-for-davem-2017-09-25' of git://git.kernel.org/.../kvalo/wireless-drivers
      Merge branch 'mvpp2-various-fixes'
      Merge tag 'mlx5-fixes-2017-09-28' of git://git.kernel.org/.../saeed/linux
      Merge branch 'udp-fix-early-demux-for-mcast-packets'
      Merge branch 'erspan-fixes'
      Merge branch 'mlxsw-gre-fixes'

David Spinadel (1):
      iwlwifi: mvm: Flush non STA TX queues

David Wu (1):
      net: stmmac: dwmac-rk: Add RK3128 GMAC support

Ed Blake (2):
      net: stmmac: dwc-qos: Add suspend / resume support
      net: stmmac: dwmac4: Re-enable MAC Rx before powering down

Eric Dumazet (2):
      inetpeer: fix RCU lookup() again
      socket, bpf: fix possible use after free

Florian Fainelli (1):
      net: dsa: Fix network device registration order

Gal Pressman (3):
      net/mlx5e: Print netdev features correctly in error message
      net/mlx5e: Don't add/remove 802.1ad rules when changing 802.1Q VLAN filter
      net/mlx5e: Fix calculated checksum offloads counters

Grant Grundler (1):
      r8152: add Linksys USB3GIGV1 id

Gregory CLEMENT (1):
      net: mvpp2: Fix clock resource by adding an optional bus clock

Guillaume Nault (4):
      l2tp: ensure sessions are freed after their PPPOL2TP socket
      l2tp: fix race between l2tp_session_delete() and l2tp_tunnel_closeall()
      ppp: fix __percpu annotation
      l2tp: fix l2tp_eth module loading

Igor Russkikh (3):
      aquantia: Setup max_mtu in ndev to enable jumbo frames
      aquantia: Fix Tx queue hangups
      aquantia: Fix transient invalid link down/up indications

Inbar Karmy (1):
      net/mlx5: Fix FPGA capability location

Jason A. Donenfeld (1):
      netlink: do not proceed if dump's start() errs

Kalle Valo (2):
      Merge tag 'iwlwifi-for-kalle-2017-09-15' of git://git.kernel.org/.../iwlwifi/iwlwifi-fixes
      Merge ath-current from ath.git

Luca Coelho (4):
      iwlwifi: mvm: use IWL_HCMD_NOCOPY for MCAST_FILTER_CMD
      iwlwifi: mvm: handle FIF_ALLMULTI when setting multicast addresses
      iwlwifi: mvm: initialize status in iwl_mvm_add_int_sta_common()
      iwlwifi: mvm: set status before calling iwl_mvm_send_cmd_status()

Matan Barak (1):
      net/mlx5: Fix static checker warning on steering tracepoints code

Matt Chen (1):
      iwlwifi: mvm: fix wowlan resume failed to load INIT ucode

Naftali Goldstein (1):
      iwlwifi: mvm: change state when queueing agg start work

Nikolay Aleksandrov (1):
      net: rtnetlink: fix info leak in RTM_GETSTATS call

Or Gerlitz (2):
      net/mlx5e: Disallow TC offloading of unsupported match/action combinations
      net/mlx5: Fix wrong indentation in enable SRIOV code

Paolo Abeni (2):
      IPv4: early demux can return an error code
      udp: perform source validation for mcast early demux

Parthasarathy Bhuvaragan (1):
      tipc: use only positive error codes in messages

Paul Blakey (1):
      net/mlx5e: Fix erroneous freeing of encap header buffer

Pavel Belous (1):
      atlantic: fix iommu errors

Petr Machata (2):
      mlxsw: spectrum_router: Move VRF refcounting
      mlxsw: spectrum_router: Track RIF of IPIP next hops

Raed Salem (1):
      net/mlx5: Check device capability for maximum flow counters

Roi Dayan (1):
      net/mlx5e: IPoIB, Fix access to invalid memory address

Sabrina Dubroca (1):
      l2tp: fix race condition in l2tp_tunnel_delete

Sara Sharon (1):
      iwlwifi: mvm: fix reorder buffer for 9000 devices

Sergey Matyukevich (2):
      qtnfmac: lock access to h/w in tx path
      qtnfmac: cancel scans on wireless interface changes

Stefan Chulski (1):
      net: mvpp2: fix parsing fragmentation detection

Subash Abhinov Kasiviswanathan (1):
      net: qualcomm: rmnet: Fix rcu splat in rmnet_is_real_dev_registered

Timur Tabi (1):
      net: qcom/emac: specify the correct size when mapping a DMA buffer

Vishakha Narvekar (1):
      net: 8021q: skip packets if the vlan is down

Vivien Didelot (1):
      net: dsa: mv88e6xxx: lock mutex when freeing IRQs

Vlad Buslov (1):
      net/mlx5e: Check encap entry state when offloading tunneled flows

Willem de Bruijn (2):
      packet: in packet_do_bind, test fanout with bind_lock held
      packet: only test po->has_vnet_hdr once in packet_snd

Xin Long (7):
      ip_gre: ipgre_tap device should keep dst
      ip6_gre: ip6gre_tap device should keep dst
      ip6_tunnel: update mtu properly for ARPHRD_ETHER tunnel device in tx path
      ip_gre: get key from session_id correctly in erspan_rcv
      ip_gre: check packet length and mtu correctly in erspan_xmit
      ip_gre: set tunnel hlen properly in erspan_tunnel_init
      ip_gre: erspan device should keep dst

Yan Markman (1):
      net: mvpp2: fix port list indexing

 Documentation/devicetree/bindings/net/marvell-pp2.txt              |  10 +++--
 Documentation/devicetree/bindings/net/rockchip-dwmac.txt           |   1 +
 arch/x86/net/bpf_jit_comp.c                                        |   4 +-
 drivers/net/dsa/mv88e6xxx/chip.c                                   |   6 +++
 drivers/net/ethernet/aquantia/atlantic/aq_cfg.h                    |   4 ++
 drivers/net/ethernet/aquantia/atlantic/aq_nic.c                    | 145 ++++++++++++++++++++++++++++++++-------------------------------------
 drivers/net/ethernet/aquantia/atlantic/aq_nic.h                    |   2 -
 drivers/net/ethernet/aquantia/atlantic/aq_ring.c                   |  53 +++++++++++++++++++++----
 drivers/net/ethernet/aquantia/atlantic/aq_ring.h                   |  10 ++++-
 drivers/net/ethernet/aquantia/atlantic/aq_vec.c                    |   8 +---
 drivers/net/ethernet/aquantia/atlantic/hw_atl/hw_atl_b0_internal.h |   2 +-
 drivers/net/ethernet/aquantia/atlantic/hw_atl/hw_atl_utils.c       |   3 +-
 drivers/net/ethernet/broadcom/cnic.c                               |   2 +-
 drivers/net/ethernet/hisilicon/hns3/hns3pf/hclge_main.c            |   3 +-
 drivers/net/ethernet/marvell/mvpp2.c                               |  46 ++++++++++++++++------
 drivers/net/ethernet/mellanox/mlx5/core/diag/fs_tracepoint.h       |   4 +-
 drivers/net/ethernet/mellanox/mlx5/core/en_fs.c                    |   4 +-
 drivers/net/ethernet/mellanox/mlx5/core/en_main.c                  |  13 +++----
 drivers/net/ethernet/mellanox/mlx5/core/en_rx.c                    |   3 ++
 drivers/net/ethernet/mellanox/mlx5/core/en_stats.h                 |   6 +++
 drivers/net/ethernet/mellanox/mlx5/core/en_tc.c                    |  91 +++++++++++++++++++++++++++++++++++++++----
 drivers/net/ethernet/mellanox/mlx5/core/en_tx.c                    |   1 +
 drivers/net/ethernet/mellanox/mlx5/core/fpga/cmd.c                 |   4 +-
 drivers/net/ethernet/mellanox/mlx5/core/fpga/cmd.h                 |   2 +-
 drivers/net/ethernet/mellanox/mlx5/core/fpga/core.c                |   3 +-
 drivers/net/ethernet/mellanox/mlx5/core/fs_cmd.c                   |   8 ++++
 drivers/net/ethernet/mellanox/mlx5/core/fs_core.h                  |  11 ++++++
 drivers/net/ethernet/mellanox/mlx5/core/ipoib/ipoib.c              |   3 +-
 drivers/net/ethernet/mellanox/mlx5/core/sriov.c                    |   2 +-
 drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c              |  18 +++++++--
 drivers/net/ethernet/qualcomm/emac/emac-mac.c                      |   3 +-
 drivers/net/ethernet/qualcomm/rmnet/rmnet_config.c                 |   5 +--
 drivers/net/ethernet/rocker/rocker_tlv.h                           |  48 ++++++++++++++---------
 drivers/net/ethernet/stmicro/stmmac/dwmac-dwc-qos-eth.c            |   1 +
 drivers/net/ethernet/stmicro/stmmac/dwmac-rk.c                     | 112 +++++++++++++++++++++++++++++++++++++++++++++++++++++
 drivers/net/ethernet/stmicro/stmmac/dwmac4_core.c                  |   7 ++++
 drivers/net/ppp/ppp_generic.c                                      |   2 +-
 drivers/net/tun.c                                                  |   8 ++--
 drivers/net/usb/cdc_ether.c                                        |  21 +++++++++-
 drivers/net/usb/r8152.c                                            |   2 +
 drivers/net/usb/rndis_host.c                                       |   4 ++
 drivers/net/wireless/ath/ath10k/pci.c                              |   7 +---
 drivers/net/wireless/broadcom/brcm80211/brcmfmac/cfg80211.c        |  37 +++++++++---------
 drivers/net/wireless/broadcom/brcm80211/brcmfmac/fwil_types.h      |   5 +++
 drivers/net/wireless/intel/iwlwifi/mvm/d3.c                        |   2 +-
 drivers/net/wireless/intel/iwlwifi/mvm/mac80211.c                  |  62 ++++++++++++++++++++++++++++--
 drivers/net/wireless/intel/iwlwifi/mvm/rs.c                        |   3 +-
 drivers/net/wireless/intel/iwlwifi/mvm/rxmq.c                      |   7 ++--
 drivers/net/wireless/intel/iwlwifi/mvm/scan.c                      |   2 +-
 drivers/net/wireless/intel/iwlwifi/mvm/sta.c                       |   8 ++--
 drivers/net/wireless/intel/iwlwifi/mvm/sta.h                       |   2 +
 drivers/net/wireless/intel/iwlwifi/mvm/tt.c                        |   1 +
 drivers/net/wireless/intel/iwlwifi/mvm/tx.c                        |  10 ++---
 drivers/net/wireless/quantenna/qtnfmac/cfg80211.c                  |   9 +++--
 drivers/net/wireless/quantenna/qtnfmac/cfg80211.h                  |   3 ++
 drivers/net/wireless/quantenna/qtnfmac/event.c                     |   2 -
 drivers/net/wireless/quantenna/qtnfmac/pearl/pcie.c                |   9 ++++-
 drivers/net/wireless/quantenna/qtnfmac/pearl/pcie_bus_priv.h       |   2 +
 include/linux/mlx5/device.h                                        |   5 +--
 include/linux/mlx5/driver.h                                        |   1 +
 include/linux/mlx5/mlx5_ifc.h                                      |   3 +-
 include/net/netlink.h                                              |  73 ++++++++++++++++++++++++++---------
 include/net/protocol.h                                             |   4 +-
 include/net/route.h                                                |   4 +-
 include/net/tcp.h                                                  |   2 +-
 include/net/udp.h                                                  |   2 +-
 include/uapi/linux/bpf.h                                           |   2 +-
 kernel/bpf/core.c                                                  |   2 +-
 net/8021q/vlan_core.c                                              |   6 +++
 net/core/filter.c                                                  |  12 ++++--
 net/core/rtnetlink.c                                               |   3 ++
 net/core/sock.c                                                    |   7 +++-
 net/dsa/slave.c                                                    |  31 ++++++++-------
 net/ipv4/inetpeer.c                                                |   4 +-
 net/ipv4/ip_gre.c                                                  |  12 +++---
 net/ipv4/ip_input.c                                                |  25 +++++++-----
 net/ipv4/ip_vti.c                                                  |   3 +-
 net/ipv4/route.c                                                   |  46 ++++++++++++----------
 net/ipv4/tcp_ipv4.c                                                |   9 +++--
 net/ipv4/udp.c                                                     |  24 +++++++++---
 net/ipv6/ip6_gre.c                                                 |   1 +
 net/ipv6/ip6_tunnel.c                                              |   5 ++-
 net/ipv6/ip6_vti.c                                                 |   3 +-
 net/l2tp/l2tp_core.c                                               |  16 +++++---
 net/l2tp/l2tp_core.h                                               |   6 ++-
 net/l2tp/l2tp_eth.c                                                |  51 +-----------------------
 net/l2tp/l2tp_ppp.c                                                |   8 ++--
 net/netlink/af_netlink.c                                           |   7 +++-
 net/packet/af_packet.c                                             |  12 ++++--
 net/sctp/sctp_diag.c                                               |   4 +-
 net/tipc/msg.c                                                     |   2 +-
 91 files changed, 863 insertions(+), 388 deletions(-)
