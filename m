From: David Miller <davem@davemloft.net>
Subject: [GIT] Networking
Date: Thu, 15 Jun 2017 00:18:48 -0400 (EDT)
Message-ID: <20170615.001848.512933632792812526.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: 8BIT
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


1) The netlink attribute passed in to dev_set_alias() is not
   necessarily NULL terminated, don't use strlcpy() on it.
   From Alexander Potapenko.

2) Fix implementation of atomics in arm64 bpf JIT, from Daniel
   Borkmann.

3) Correct the release of netdevs and driver private data in
   certain circumstances.

4) Sanitize netlink message length properly in decnet, from
   Mateusz Jurczyk.

5) Don't leak kernel data in rtnl_fill_vfinfo() netlink blobs.
   From Yuval Mintz.

6) Hash secret is never initialized in ipv6 ILA translation code, from
   Arnd Bergmann.  I guess those clang warnings about unused inline
   functions are useful for something!

7) Fix endian selection in bpf_endian.h, from Daniel Borkmann.

8) Sanitize sockaddr length before dereferncing any fields in
   AF_UNIX and CAIF.  From Mateusz Jurczyk.

9) Fix timestamping for GMAC3 chips in stmmac driver, from Mario
   Molitor.

10) Do not leak netdev on dev_alloc_name() errors in mac80211, from
    Johannes Berg.

11) Fix locking in sctp_for_each_endpoint(), from Xin Long.

12) Fix wrong memset size on 32-bit in snmp6, from Christian Perle.

13) Fix use after free in ip_mc_clear_src(), from WANG Cong.

14) Fix regressions caused by ICMP rate limiting changes in 4.11,
    from Jesper Dangaard Brouer.

Please pull, thanks a lot!

The following changes since commit b29794ec95c6856b316c2295904208bf11ffddd9:

  Merge git://git.kernel.org/pub/scm/linux/kernel/git/davem/net (2017-06-06 14:30:17 -0700)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/davem/net.git 

for you to fetch changes up to 640f93cc6ea7327588be3cc0849d1342aac0393a:

  i40e: Fix a sleep-in-atomic bug (2017-06-14 23:45:22 -0400)

----------------------------------------------------------------
Alexander Potapenko (1):
      net: don't call strlen on non-terminated string in dev_set_alias()

Andreas Pape (1):
      batman-adv: fix memory leak when dropping packet from other gateway

Antoine Tenart (1):
      net: mvpp2: do not bypass the mvpp22_port_mii_set function

Arnd Bergmann (1):
      ila_xlat: add missing hash secret initialization

Ashwanth Goli (1):
      net: rps: fix uninitialized symbol warning

Avraham Stern (1):
      mac80211: Fix incorrect condition when checking rx timestamp

Bjørn Mork (1):
      qmi_wwan: new Telewell and Sierra device IDs

Christian Lamparter (2):
      net: emac: fix reset timeout with AR8035 phy
      net: emac: fix and unify emac_mdio functions

Christian Perle (1):
      proc: snmp6: Use correct type in memset

Dan Carpenter (1):
      net/act_pedit: fix an error code

Daniel Borkmann (2):
      bpf, arm64: use separate register for state in stxr
      bpf, tests: fix endianness selection

David Ahern (2):
      net: ipv6: Release route when device is unregistering
      net: vrf: Make add_fib_rules per network namespace flag

David S. Miller (13):
      net: Fix inconsistent teardown and release of private netdev state.
      hsi: Fix build regression due to netdev destructor fix.
      Revert "decnet: dn_rtmsg: Improve input length sanitization in dnrmg_receive_user_skb"
      Merge branch 'netvsc-bug-fixes'
      net: Fix build regression in rtl8723bs staging driver.
      Merge tag 'linux-can-fixes-for-4.12-20170609' of git://git.kernel.org/.../mkl/linux-can
      Merge branch 'bnx2x-Fix-malicious-VFs-indication'
      Revert "net: fec: Add a fec_enet_clear_ethtool_stats() stub for CONFIG_M5272"
      Merge branch 'mvpp2-fixes'
      Merge branch 'ena-fixes'
      Merge tag 'mlx5-fixes-2017-06-11' of git://git.kernel.org/.../saeed/linux
      Merge tag 'mac80211-for-davem-2017-06-13' of git://git.kernel.org/.../jberg/mac80211
      Merge tag 'batadv-net-for-davem-20170613' of git://git.open-mesh.org/linux-merge

Dominik Heidler (1):
      l2tp: cast l2tp traffic counter to unsigned

Donald Sharp (1):
      net: ipmr: Fix some mroute forwarding issues in vrf's

Emmanuel Grumbach (2):
      mac80211: don't look at the PM bit of BAR frames
      mac80211: don't send SMPS action frame in AP mode when not needed

Fabio Estevam (1):
      net: fec: Add a fec_enet_clear_ethtool_stats() stub for CONFIG_M5272

Florian Fainelli (1):
      net: phy: Fix MDIO_THUNDER dependencies

Huy Nguyen (1):
      net/mlx5: Remove several module events out of ethtool stats

Jacob Keller (1):
      i40e: fix handling of HW ATR eviction

Jason A. Donenfeld (1):
      mac80211/wpa: use constant time memory comparison for MACs

Jesper Dangaard Brouer (1):
      net: don't global ICMP rate limit packets originating from loopback

Jia-Ju Bai (3):
      net: caif: Fix a sleep-in-atomic bug in cfpkt_create_pfx
      net: tipc: Fix a sleep-in-atomic bug in tipc_msg_reverse
      i40e: Fix a sleep-in-atomic bug

Joe Perches (2):
      net: phy: add missing SPEED_14000
      netconsole: Remove duplicate "netconsole: " logging prefix

Johan Hovold (1):
      can: peak_usb: fix product-id endianness in error message

Johannes Berg (3):
      mac80211: free netdev on dev_alloc_name() error
      mac80211: remove 5/10 MHz rate code from station MLME
      mac80211: set bss_info data before configuring the channel

John Allen (1):
      ibmvnic: Return failure on attempted mtu change

Karicheri, Muralidharan (1):
      hsr: fix incorrect warning

Krister Johansen (1):
      Fix an intermittent pr_emerg warning about lo becoming free.

Magnus Damm (1):
      net: update undefined ->ndo_change_mtu() comment

Majd Dibbiny (1):
      net/mlx5: Enable 4K UAR only when page size is bigger than 4K

Marc Kleine-Budde (3):
      can: dev: make can_change_state() robust to be called with cf == NULL
      can: gs_usb: fix memory leak in gs_cmd_reset()
      can: af_can: namespace support: fix lockdep splat: properly initialize spin_lock

Mario Molitor (2):
      stmmac: fix ptp header for GMAC3 hw timestamp
      stmmac: fix for hw timestamp of GMAC3 unit

Mateusz Jurczyk (4):
      decnet: dn_rtmsg: Improve input length sanitization in dnrmg_receive_user_skb
      decnet: dn_rtmsg: Improve input length sanitization in dnrmg_receive_user_skb
      af_unix: Add sockaddr length checks before accessing sa_family in bind and connect handlers
      caif: Add sockaddr length check before accessing sa_family in connect handler

Michael S. Tsirkin (1):
      net: fix up hash documentation

Michal Schmidt (1):
      bnx2x: fix pf2vf bulletin DMA mapping leak

Mintz, Yuval (3):
      net: Zero ifla_vf_info in rtnl_fill_vfinfo()
      bnx2x: Allow vfs to disable txvlan offload
      bnx2x: Don't post statistics to malicious VFs

Mohamad Haj Yahia (2):
      net/mlx5: Fix create vport flow table flow
      net/mlx5: Continue health polling until it is explicitly stopped

Netanel Belgazal (9):
      net: ena: fix rare uncompleted admin command false alarm
      net: ena: fix bug that might cause hang after consecutive open/close interface.
      net: ena: add missing return when ena_com_get_io_handlers() fails
      net: ena: fix race condition between submit and completion admin command
      net: ena: add missing unmap bars on device removal
      net: ena: fix theoretical Rx hang on low memory systems
      net: ena: disable admin msix while working in polling mode
      net: ena: bug fix in lost tx packets detection mechanism
      net: ena: update ena driver to version 1.1.7

Nicolas Dichtel (3):
      openvswitch: warn about missing first netlink attribute
      bonding: fix 802.3ad support for 14G speed
      ethtool.h: remind to update 802.3ad when adding new speeds

Oliver Hartkopp (1):
      can: enable CAN FD for virtual CAN devices by default

Oliver Neukum (1):
      r8152: give the device version

Philippe Reynes (1):
      net: aquantia: atlantic: remove declaration of hw_atl_utils_hw_set_power

Stephane Grosjean (1):
      can: peak_canfd: fix uninitialized symbol warnings

Stephen Rothwell (1):
      net: s390: fix up for "Fix inconsistent teardown and release of private netdev state"

Sven Eckelmann (1):
      batman-adv: Fix rx packet/bytes stats on local ARP reply

Tal Gilboa (2):
      net/mlx5e: Added BW check for DIM decision mechanism
      net/mlx5e: Fix wrong indications in DIM due to counter wraparound

Tayar, Tomer (1):
      qed: fix dump of context data

Thibaut Collet (1):
      bonding: fix 802.3ad support for 5G and 50G speeds

Thomas Petazzoni (2):
      net: mvpp2: remove mvpp2_bm_cookie_{build,pool_get}
      net: mvpp2: use {get, put}_cpu() instead of smp_processor_id()

WANG Cong (2):
      igmp: acquire pmc lock for ip_mc_clear_src()
      net_sched: move tcf_lock down after gen_replace_estimator()

Xin Long (1):
      sctp: disable BH in sctp_for_each_endpoint

ashwanth@codeaurora.org (1):
      net: rps: send out pending IPI's on CPU hotplug

stephen hemminger (3):
      netvsc: fix rcu dereference warning from ethtool
      netvsc: fix net poll mode
      netvsc: move filter setting to rndis_device

 Documentation/networking/scaling.txt                         |   2 +-
 arch/arm64/net/bpf_jit_comp.c                                |   7 ++-
 drivers/hsi/clients/ssi_protocol.c                           |   2 +-
 drivers/net/bonding/bond_3ad.c                               |  27 +++++++++
 drivers/net/bonding/bond_main.c                              |   6 +-
 drivers/net/caif/caif_hsi.c                                  |   2 +-
 drivers/net/caif/caif_serial.c                               |   2 +-
 drivers/net/caif/caif_spi.c                                  |   2 +-
 drivers/net/caif/caif_virtio.c                               |   2 +-
 drivers/net/can/dev.c                                        |   3 +
 drivers/net/can/peak_canfd/peak_canfd.c                      |   2 +-
 drivers/net/can/slcan.c                                      |   7 +--
 drivers/net/can/usb/gs_usb.c                                 |   2 +
 drivers/net/can/usb/peak_usb/pcan_usb_core.c                 |   4 +-
 drivers/net/can/vcan.c                                       |   4 +-
 drivers/net/can/vxcan.c                                      |   4 +-
 drivers/net/dummy.c                                          |   4 +-
 drivers/net/ethernet/amazon/ena/ena_com.c                    |  35 ++++++-----
 drivers/net/ethernet/amazon/ena/ena_ethtool.c                |   2 +-
 drivers/net/ethernet/amazon/ena/ena_netdev.c                 | 179 +++++++++++++++++++++++++++++++++++++++++---------------
 drivers/net/ethernet/amazon/ena/ena_netdev.h                 |  18 +++++-
 drivers/net/ethernet/aquantia/atlantic/hw_atl/hw_atl_utils.h |   3 -
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c              |  19 ++++--
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.c            |  15 ++++-
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.h            |   1 +
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c              |   2 +-
 drivers/net/ethernet/ibm/emac/core.c                         |  67 ++++++++++++---------
 drivers/net/ethernet/ibm/ibmvnic.c                           |   6 ++
 drivers/net/ethernet/intel/i40e/i40e.h                       |   1 +
 drivers/net/ethernet/intel/i40e/i40e_ethtool.c               |   4 +-
 drivers/net/ethernet/intel/i40e/i40e_main.c                  |   7 ++-
 drivers/net/ethernet/intel/i40e/i40e_txrx.c                  |   4 +-
 drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c           |   2 +
 drivers/net/ethernet/marvell/mvpp2.c                         |  76 +++++++++++-------------
 drivers/net/ethernet/mellanox/mlx5/core/en.h                 |   8 ++-
 drivers/net/ethernet/mellanox/mlx5/core/en_rx_am.c           |  45 ++++++++------
 drivers/net/ethernet/mellanox/mlx5/core/en_stats.h           |  11 +---
 drivers/net/ethernet/mellanox/mlx5/core/fs_core.c            |   2 +-
 drivers/net/ethernet/mellanox/mlx5/core/health.c             |  11 ++--
 drivers/net/ethernet/mellanox/mlx5/core/main.c               |   6 +-
 drivers/net/ethernet/qlogic/qed/qed_debug.c                  |   2 +-
 drivers/net/ethernet/stmicro/stmmac/dwmac4_descs.c           |  11 ++--
 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c            |  25 +++++---
 drivers/net/ethernet/stmicro/stmmac/stmmac_ptp.h             |   3 +-
 drivers/net/geneve.c                                         |   2 +-
 drivers/net/gtp.c                                            |   2 +-
 drivers/net/hamradio/6pack.c                                 |   2 +-
 drivers/net/hamradio/bpqether.c                              |   2 +-
 drivers/net/hyperv/hyperv_net.h                              |   5 +-
 drivers/net/hyperv/netvsc_drv.c                              |  54 ++++++-----------
 drivers/net/hyperv/rndis_filter.c                            |  30 +++++++++-
 drivers/net/ifb.c                                            |   4 +-
 drivers/net/ipvlan/ipvlan_main.c                             |   2 +-
 drivers/net/loopback.c                                       |   4 +-
 drivers/net/macsec.c                                         |   4 +-
 drivers/net/macvlan.c                                        |   2 +-
 drivers/net/netconsole.c                                     |   2 +-
 drivers/net/nlmon.c                                          |   2 +-
 drivers/net/phy/Kconfig                                      |   1 +
 drivers/net/phy/phy.c                                        |   2 +
 drivers/net/slip/slip.c                                      |   7 +--
 drivers/net/team/team.c                                      |   4 +-
 drivers/net/tun.c                                            |   4 +-
 drivers/net/usb/cdc-phonet.c                                 |   2 +-
 drivers/net/usb/qmi_wwan.c                                   |   6 +-
 drivers/net/usb/r8152.c                                      |   2 +
 drivers/net/veth.c                                           |   4 +-
 drivers/net/vrf.c                                            |  38 ++++++++++--
 drivers/net/vsockmon.c                                       |   2 +-
 drivers/net/vxlan.c                                          |   2 +-
 drivers/net/wan/dlci.c                                       |   2 +-
 drivers/net/wan/hdlc_fr.c                                    |   2 +-
 drivers/net/wan/lapbether.c                                  |   2 +-
 drivers/net/wireless/ath/ath6kl/main.c                       |   2 +-
 drivers/net/wireless/broadcom/brcm80211/brcmfmac/cfg80211.c  |   1 -
 drivers/net/wireless/broadcom/brcm80211/brcmfmac/core.c      |   3 +-
 drivers/net/wireless/intersil/hostap/hostap_main.c           |   2 +-
 drivers/net/wireless/mac80211_hwsim.c                        |   2 +-
 drivers/net/wireless/marvell/mwifiex/main.c                  |   2 +-
 drivers/s390/net/netiucv.c                                   |   4 +-
 drivers/staging/rtl8188eu/os_dep/mon.c                       |   2 +-
 drivers/staging/rtl8723bs/os_dep/ioctl_cfg80211.c            |   3 +-
 drivers/staging/rtl8723bs/os_dep/os_intfs.c                  |   2 -
 drivers/usb/gadget/function/f_phonet.c                       |   2 +-
 include/linux/netdevice.h                                    |  15 +++--
 include/uapi/linux/ethtool.h                                 |   6 +-
 include/uapi/linux/openvswitch.h                             |   1 +
 net/8021q/vlan_dev.c                                         |   4 +-
 net/batman-adv/distributed-arp-table.c                       |   5 +-
 net/batman-adv/routing.c                                     |   2 +-
 net/batman-adv/soft-interface.c                              |   5 +-
 net/bluetooth/6lowpan.c                                      |   2 +-
 net/bridge/br_device.c                                       |   2 +-
 net/caif/caif_socket.c                                       |   4 ++
 net/caif/cfpkt_skbuff.c                                      |   6 +-
 net/caif/chnl_net.c                                          |   4 +-
 net/can/af_can.c                                             |   3 +-
 net/core/dev.c                                               |  42 +++++++++----
 net/core/dst.c                                               |  14 +++++
 net/core/rtnetlink.c                                         |   3 +-
 net/decnet/netfilter/dn_rtmsg.c                              |   4 +-
 net/hsr/hsr_device.c                                         |   4 +-
 net/hsr/hsr_forward.c                                        |   3 +-
 net/hsr/hsr_framereg.c                                       |   9 ++-
 net/hsr/hsr_framereg.h                                       |   2 +-
 net/ieee802154/6lowpan/core.c                                |   2 +-
 net/ipv4/icmp.c                                              |   8 ++-
 net/ipv4/igmp.c                                              |  21 ++++---
 net/ipv4/ip_tunnel.c                                         |   4 +-
 net/ipv4/ipmr.c                                              |  34 +++++------
 net/ipv6/icmp.c                                              |   2 +-
 net/ipv6/ila/ila_xlat.c                                      |   1 +
 net/ipv6/ip6_gre.c                                           |   9 +--
 net/ipv6/ip6_tunnel.c                                        |   8 +--
 net/ipv6/ip6_vti.c                                           |   8 +--
 net/ipv6/ip6mr.c                                             |   2 +-
 net/ipv6/proc.c                                              |   2 +-
 net/ipv6/route.c                                             |   1 +
 net/ipv6/sit.c                                               |   6 +-
 net/irda/irlan/irlan_eth.c                                   |   2 +-
 net/l2tp/l2tp_eth.c                                          |  15 ++---
 net/mac80211/cfg.c                                           |   2 +
 net/mac80211/ieee80211_i.h                                   |   2 +-
 net/mac80211/iface.c                                         |   7 ++-
 net/mac80211/mlme.c                                          |  62 ++++++++++----------
 net/mac80211/rx.c                                            |   6 +-
 net/mac80211/wpa.c                                           |   9 +--
 net/mac802154/iface.c                                        |   7 +--
 net/openvswitch/vport-internal_dev.c                         |   4 +-
 net/phonet/pep-gprs.c                                        |   2 +-
 net/sched/act_pedit.c                                        |   4 +-
 net/sched/act_police.c                                       |   8 +--
 net/sctp/socket.c                                            |   4 +-
 net/tipc/msg.c                                               |   2 +-
 net/unix/af_unix.c                                           |   7 ++-
 tools/testing/selftests/bpf/bpf_endian.h                     |  41 +++++++++----
 136 files changed, 810 insertions(+), 491 deletions(-)
