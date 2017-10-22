From: David Miller <davem@davemloft.net>
Subject: [GIT] Networking
Date: Sun, 22 Oct 2017 03:34:24 +0100 (WEST)
Message-ID: <20171022.033424.1274146439446752804.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: 8BIT
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:57878 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750736AbdJVCe3 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 21 Oct 2017 22:34:29 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


A little more than usual this time around.  Been travelling, so that is
part of it.

Anyways, here are the highlights:

1) Deal with memcontrol races wrt. listener dismantle, from Eric
   Dumazet.

2) Handle page allocation failures properly in nfp driver, from
   Jaku Kicinski.

3) Fix memory leaks in macsec, from Sabrina Dubroca.

4) Fix crashes in pppol2tp_session_ioctl(), from Guillaume Nault.

5) Several fixes in bnxt_en driver, including preventing potential NVRAM
   parameter corruption from Michael Chan.

6) Fix for KRACK attacks in wireless, from Johannes Berg.

7) rtnetlink event generation fixes from Xin Long.

8) Deadlock in mlxsw driver, from Ido Schimmel.

9) Disallow arithmetic operations on context pointers in bpf, from
   Jakub Kicinski.

10) Missing sock_owned_by_user() check in sctp_icmp_redirect(), from
    Xin Long.

11) Only TCP is supported for sockmap, make that explicit with a check,
    from John Fastabend.

12) Fix IP options state races in DCCP and TCP, from Eric Dumazet.

13) Fix panic in packet_getsockopt(), also from Eric Dumazet.

14) Add missing locked in hv_sock layer, from Dexuan Cui.

15) Various aquantia bug fixes, including several statistics handling
    cures.  From Igor Russkikh et al.

16) Fix arithmetic overflow in devmap code, from John Fastabend.

17) Fix busted socket memory accounting when we get a fault in the tcp
    zero copy paths.  From Willem de Bruijn.

18) Don't leave opt->tot_len uninitialized in ipv6, from Eric Dumazet.

Please pull, thanks a lot!

The following changes since commit 529a86e063e9ff625c4ff247d8aa17d8072444fb:

  Merge branch 'ppc-bundle' (bundle from Michael Ellerman) (2017-10-09 19:08:32 -0700)

are available in the git repository at:

  https://git.kernel.org/pub/scm/linux/kernel/git/davem/net.git 

for you to fetch changes up to 8d5f4b07174976c55a5f5d6967777373c6826944:

  stmmac: Don't access tx_q->dirty_tx before netif_tx_lock (2017-10-22 03:24:43 +0100)

----------------------------------------------------------------
Alexander Duyck (1):
      i40e: Fix memory leak related filter programming status

Arnd Bergmann (2):
      brcmsmac: make some local variables 'static const' to reduce stack size
      liquidio: fix timespec64_to_ns typo

Behan Webster (1):
      wimax/i2400m: Remove VLAIS

Bernd Edlinger (1):
      stmmac: Don't access tx_q->dirty_tx before netif_tx_lock

Chaya Rachel Ivgi (1):
      iwlwifi: nvm: set the correct offsets to 3168 series

Colin Ian King (1):
      can: bcm: check for null sk before deferencing it via the call to sock_net

Cong Wang (1):
      tun: call dev_get_valid_name() before register_netdevice()

Craig Gallek (1):
      soreuseport: fix initialization race

Daniel Borkmann (6):
      mm, percpu: add support for __GFP_NOWARN flag
      bpf: fix splat for illegal devmap percpu allocation
      bpf: do not test for PCPU_MIN_UNIT_SIZE before percpu allocations
      bpf: fix off by one for range markings with L{T, E} patterns
      bpf: fix pattern matches for direct packet access
      bpf: add test cases to bpf selftests to cover all access tests

Daniel Drake (1):
      r8169: only enable PCI wakeups when WOL is active

David Howells (1):
      rxrpc: Don't release call mutex on error pointer

David S. Miller (14):
      Merge branch '40GbE' of git://git.kernel.org/.../jkirsher/net-queue
      Merge branch 'nfp-fix-ethtool-stats-and-page-allocation'
      Merge tag 'wireless-drivers-for-davem-2017-10-13' of git://git.kernel.org/.../kvalo/wireless-drivers
      Merge branch 'bnxt_en-fixes'
      Merge branch 'rtnetlink-dev-notification-fixes'
      Merge tag 'mac80211-for-davem-2017-10-16' of git://git.kernel.org/.../jberg/mac80211
      Merge branch 'ena-fixes'
      Merge branch 'bpf-Fix-for-BPF-devmap-percpu-allocation-splat'
      Merge branch 'sockmap-fixes'
      Merge tag 'linux-can-fixes-for-4.14-20171019' of git://git.kernel.org/.../mkl/linux-can
      Merge branch 'aquantia-fixes'
      Merge branch 'bpf-range-marking-fixes'
      Merge branch 'mlxsw-fixes'
      Merge branch 'stmmac-hw-tstamp-fixes'

Dexuan Cui (1):
      hv_sock: add locking in the open/close/release code paths

Emiliano Ingrassia (1):
      net: stmmac: dwmac_lib: fix interchanged sleep/timeout values in DMA reset function

Eric Dumazet (7):
      net: memcontrol: defer call to mem_cgroup_sk_alloc()
      net: defer call to cgroup_sk_alloc()
      Revert "net: defer call to cgroup_sk_alloc()"
      net: call cgroup_sk_alloc() earlier in sk_clone_lock()
      tcp/dccp: fix ireq->opt races
      packet: avoid panic in packet_getsockopt()
      ipv6: flowlabel: do not leave opt->tot_len with garbage

Gavin Shan (3):
      net/ncsi: Disable HWA mode when no channels are found
      net/ncsi: Enforce failover on link monitor timeout
      net/ncsi: Fix length of GVI response packet

Geert Uytterhoeven (1):
      of_mdio: Fix broken PHY IRQ in case of probe deferral

Golan Ben Ami (1):
      iwlwifi: stop dbgc recording before stopping DMA

Guillaume Nault (1):
      l2tp: check ps->sock before running pppol2tp_session_ioctl()

Ido Schimmel (1):
      mlxsw: core: Fix possible deadlock

Igor Russkikh (7):
      net: aquantia: Reset nic statistics on interface up/down
      net: aquantia: Add queue restarts stats counter
      net: aquantia: Fixed transient link up/down/up notification
      net: aquantia: Limit number of MSIX irqs to the number of cpus
      net: aquantia: mmio unmap was not performed on driver removal
      net: aquantia: Enable coalescing management via ethtool interface
      net: aquantia: Bad udp rate on default interrupt coalescing

Jakub Kicinski (3):
      nfp: fix ethtool stats gather retry
      nfp: handle page allocation failures
      bpf: disallow arithmetic operations on context pointer

Johannes Berg (3):
      iwlwifi: nvm-parse: unify channel flags printing
      mac80211: accept key reinstall without changing anything
      netlink: fix netlink_ack() extack race

John Fastabend (6):
      bpf: enforce TCP only support for sockmap
      bpf: avoid preempt enable/disable in sockmap using tcp_skb_cb region
      bpf: remove mark access for SK_SKB program types
      bpf: require CAP_NET_ADMIN when using sockmap maps
      bpf: require CAP_NET_ADMIN when using devmap
      bpf: devmap fix arithmetic overflow in bitmap_size calculation

Jose Abreu (3):
      net: stmmac: Add missing call to dev_kfree_skb()
      net: stmmac: Fix stmmac_get_rx_hwtstamp()
      net: stmmac: Prevent infinite loop in get_rx_timestamp_status()

Kalle Valo (1):
      Merge tag 'iwlwifi-for-kalle-2017-10-06' of git://git.kernel.org/.../iwlwifi/iwlwifi-fixes

Kevin Cernekee (1):
      brcmfmac: Add check for short event packets

Larry Finger (1):
      rtlwifi: rtl8821ae: Fix connection lost problem

Luca Coelho (1):
      iwlwifi: mvm: return -ENODATA when reading the temperature with the FW down

Marc Kleine-Budde (2):
      can: af_can: do not access proto_tab directly use rcu_access_pointer instead
      can: af_can: can_pernet_init(): add missing error handling for kzalloc returning NULL

Matteo Croce (1):
      udp: make some messages more descriptive

Michael Chan (4):
      bnxt_en: Improve VF/PF link change logic.
      bnxt_en: Don't use rtnl lock to protect link change logic in workqueue.
      bnxt_en: Fix VF resource checking.
      bnxt_en: Fix possible corrupted NVRAM parameters from firmware response.

Netanel Belgazal (3):
      net: ena: reduce the severity of some printouts
      net: ena: fix rare kernel crash when bar memory remap fails
      net: ena: fix wrong max Tx/Rx queues on ethtool

Nicolas Dichtel (1):
      net: enable interface alias removal via rtnl

Niklas Söderlund (1):
      net: ethtool: remove error check for legacy setting transceiver type

Nikolay Aleksandrov (1):
      net: bridge: fix returning of vlan range op errors

Or Gerlitz (1):
      net/sched: cls_flower: Set egress_dev mark when calling into the HW driver

Petr Machata (2):
      mlxsw: reg: Add Tunneling IPinIP General Configuration Register
      mlxsw: spectrum_router: Configure TIGCR on init

Randy Dunlap (1):
      textsearch: fix typos in library helpers

Sabrina Dubroca (1):
      macsec: fix memory leaks when skb_to_sgvec fails

Samuel Mendoza-Jonas (3):
      net/ncsi: Don't limit vids based on hot_channel
      net/ncsi: Fix AEN HNCDSC packet length
      net/ncsi: Stop monitor if channel times out or is inactive

Sankar Patchineelam (1):
      bnxt_en: Fix possible corruption in DCB parameters from firmware.

Shaul Triebitz (1):
      iwlwifi: mvm: do not print security error in monitor mode

Stefan Mätje (1):
      can: esd_usb2: Fix can_dlc value for received RTR, frames

Stefano Brivio (2):
      i40e: Fix comment about locking for __i40e_read_nvm_word()
      geneve: Fix function matching VNI and tunnel ID on big-endian

Stephen Hemminger (1):
      ip: update policy routing config help

Thomas Falcon (1):
      ibmvnic: Fix calculation of number of TX header descriptors

Vasundhara Volam (1):
      bnxt_en: Fix VF PCIe link speed and width logic.

Vivien Didelot (1):
      net: dsa: mv88e6060: fix switch MAC address

Wenhua Shi (1):
      net: fix typo in skbuff.c

Willem de Bruijn (1):
      sock: correct sk_wmem_queued accounting on efault in tcp zerocopy

Wolfgang Grandegger (1):
      can: gs_usb: fix busy loop if no more TX context is available

Xin Long (9):
      rtnetlink: bring NETDEV_CHANGEMTU event process back in rtnetlink_event
      rtnetlink: bring NETDEV_CHANGE_TX_QUEUE_LEN event process back in rtnetlink_event
      rtnetlink: bring NETDEV_POST_TYPE_CHANGE event process back in rtnetlink_event
      rtnetlink: bring NETDEV_CHANGEUPPER event process back in rtnetlink_event
      rtnetlink: check DO_SETLINK_NOTIFY correctly in do_setlink
      rtnetlink: do not set notification for tx_queue_len in do_setlink
      dev_ioctl: add missing NETDEV_CHANGE_TX_QUEUE_LEN event notification
      sctp: do not peel off an assoc from one netns to another one
      sctp: add the missing sock_owned_by_user check in sctp_icmp_redirect

ZHU Yi (ST-FIR/ENG1-Zhu) (6):
      can: flexcan: fix state transition regression
      can: flexcan: rename legacy error state quirk
      can: flexcan: implement error passive state quirk
      can: flexcan: fix i.MX6 state transition issue
      can: flexcan: fix i.MX28 state transition issue
      can: flexcan: fix p1010 state transition issue

 drivers/net/can/flexcan.c                                          |  91 +++++++--
 drivers/net/can/usb/esd_usb2.c                                     |   2 +-
 drivers/net/can/usb/gs_usb.c                                       |  10 +-
 drivers/net/dsa/mv88e6060.c                                        |  10 +-
 drivers/net/ethernet/amazon/ena/ena_ethtool.c                      |   4 +-
 drivers/net/ethernet/amazon/ena/ena_netdev.c                       |   7 +-
 drivers/net/ethernet/aquantia/atlantic/aq_cfg.h                    |   8 +-
 drivers/net/ethernet/aquantia/atlantic/aq_ethtool.c                | 157 ++++++++------
 drivers/net/ethernet/aquantia/atlantic/aq_hw.h                     |   5 +-
 drivers/net/ethernet/aquantia/atlantic/aq_nic.c                    |  39 +++-
 drivers/net/ethernet/aquantia/atlantic/aq_nic.h                    |   4 +-
 drivers/net/ethernet/aquantia/atlantic/aq_pci_func.c               |  14 +-
 drivers/net/ethernet/aquantia/atlantic/aq_vec.c                    |   3 +
 drivers/net/ethernet/aquantia/atlantic/hw_atl/hw_atl_a0.c          |  21 +-
 drivers/net/ethernet/aquantia/atlantic/hw_atl/hw_atl_b0.c          |  89 ++++----
 drivers/net/ethernet/aquantia/atlantic/hw_atl/hw_atl_b0_internal.h |   3 +
 drivers/net/ethernet/aquantia/atlantic/hw_atl/hw_atl_utils.c       |  69 +++++--
 drivers/net/ethernet/aquantia/atlantic/hw_atl/hw_atl_utils.h       |  18 +-
 drivers/net/ethernet/broadcom/bnxt/bnxt.c                          |  99 ++++++---
 drivers/net/ethernet/broadcom/bnxt/bnxt.h                          |   5 +
 drivers/net/ethernet/broadcom/bnxt/bnxt_dcb.c                      |  23 ++-
 drivers/net/ethernet/broadcom/bnxt/bnxt_ethtool.c                  |   8 +-
 drivers/net/ethernet/broadcom/bnxt/bnxt_sriov.c                    |  11 +-
 drivers/net/ethernet/cavium/liquidio/lio_main.c                    |   2 +-
 drivers/net/ethernet/ibm/ibmvnic.c                                 |  16 +-
 drivers/net/ethernet/intel/i40e/i40e_nvm.c                         |   2 +-
 drivers/net/ethernet/intel/i40e/i40e_txrx.c                        |  63 +++---
 drivers/net/ethernet/mellanox/mlxsw/core.c                         |  11 +-
 drivers/net/ethernet/mellanox/mlxsw/reg.h                          |  31 +++
 drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c              |  11 +-
 drivers/net/ethernet/netronome/nfp/nfp_net_common.c                |  20 +-
 drivers/net/ethernet/netronome/nfp/nfp_net_ethtool.c               |   8 +-
 drivers/net/ethernet/realtek/r8169.c                               |   2 -
 drivers/net/ethernet/stmicro/stmmac/dwmac4_descs.c                 |   2 +-
 drivers/net/ethernet/stmicro/stmmac/dwmac_lib.c                    |   2 +-
 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c                  |  17 +-
 drivers/net/geneve.c                                               |   6 -
 drivers/net/macsec.c                                               |   2 +
 drivers/net/tun.c                                                  |   3 +
 drivers/net/wimax/i2400m/fw.c                                      |   2 +-
 drivers/net/wireless/broadcom/brcm80211/brcmfmac/fweh.c            |   3 +-
 drivers/net/wireless/broadcom/brcm80211/brcmsmac/phy/phy_n.c       | 197 +++++++++---------
 drivers/net/wireless/intel/iwlwifi/cfg/7000.c                      |   1 +
 drivers/net/wireless/intel/iwlwifi/cfg/8000.c                      |   2 +-
 drivers/net/wireless/intel/iwlwifi/cfg/9000.c                      |   2 +-
 drivers/net/wireless/intel/iwlwifi/cfg/a000.c                      |   2 +-
 drivers/net/wireless/intel/iwlwifi/fw/api/nvm-reg.h                |   2 +
 drivers/net/wireless/intel/iwlwifi/fw/dbg.c                        |   7 +-
 drivers/net/wireless/intel/iwlwifi/fw/dbg.h                        |  15 ++
 drivers/net/wireless/intel/iwlwifi/iwl-config.h                    |  16 +-
 drivers/net/wireless/intel/iwlwifi/iwl-nvm-parse.c                 | 137 ++++++-------
 drivers/net/wireless/intel/iwlwifi/mvm/mac80211.c                  |   7 +
 drivers/net/wireless/intel/iwlwifi/mvm/mvm.h                       |   5 +-
 drivers/net/wireless/intel/iwlwifi/mvm/nvm.c                       |  21 +-
 drivers/net/wireless/intel/iwlwifi/mvm/rx.c                        |   4 +-
 drivers/net/wireless/intel/iwlwifi/mvm/rxmq.c                      |   4 +-
 drivers/net/wireless/intel/iwlwifi/mvm/tt.c                        |   2 +-
 drivers/net/wireless/realtek/rtlwifi/rtl8821ae/hw.c                |   2 +-
 drivers/of/of_mdio.c                                               |  39 ++--
 include/linux/filter.h                                             |   2 +-
 include/linux/netdevice.h                                          |   3 +
 include/net/inet_sock.h                                            |   2 +-
 include/net/tcp.h                                                  |   5 +
 kernel/bpf/arraymap.c                                              |   2 +-
 kernel/bpf/devmap.c                                                |  10 +-
 kernel/bpf/hashtab.c                                               |   4 -
 kernel/bpf/sockmap.c                                               |  28 ++-
 kernel/bpf/verifier.c                                              |  65 ++++--
 lib/ts_fsm.c                                                       |   2 +-
 lib/ts_kmp.c                                                       |   2 +-
 mm/memcontrol.c                                                    |  15 --
 mm/percpu.c                                                        |  15 +-
 net/bridge/br_netlink.c                                            |   2 +-
 net/can/af_can.c                                                   |  20 +-
 net/can/bcm.c                                                      |   5 +-
 net/core/dev.c                                                     |   6 +-
 net/core/dev_ioctl.c                                               |  13 +-
 net/core/ethtool.c                                                 |   5 +-
 net/core/filter.c                                                  |  31 +--
 net/core/rtnetlink.c                                               |  13 +-
 net/core/skbuff.c                                                  |   6 +-
 net/core/sock.c                                                    |   8 +-
 net/core/sock_reuseport.c                                          |  12 +-
 net/dccp/ipv4.c                                                    |  13 +-
 net/ipv4/Kconfig                                                   |   8 +-
 net/ipv4/cipso_ipv4.c                                              |  24 +--
 net/ipv4/inet_connection_sock.c                                    |   9 +-
 net/ipv4/inet_hashtables.c                                         |   5 +-
 net/ipv4/syncookies.c                                              |   2 +-
 net/ipv4/tcp_input.c                                               |   2 +-
 net/ipv4/tcp_ipv4.c                                                |  22 +-
 net/ipv4/udp.c                                                     |   9 +-
 net/ipv6/ip6_flowlabel.c                                           |   1 +
 net/ipv6/ip6_output.c                                              |   4 +-
 net/l2tp/l2tp_ppp.c                                                |   3 +
 net/mac80211/key.c                                                 |  21 +-
 net/ncsi/internal.h                                                |   1 +
 net/ncsi/ncsi-aen.c                                                |   2 +-
 net/ncsi/ncsi-manage.c                                             |  52 +++--
 net/ncsi/ncsi-rsp.c                                                |   2 +-
 net/netlink/af_netlink.c                                           |   8 +-
 net/packet/af_packet.c                                             |  24 ++-
 net/rxrpc/af_rxrpc.c                                               |   5 +-
 net/sched/cls_flower.c                                             |   2 +
 net/sctp/input.c                                                   |   2 +-
 net/sctp/socket.c                                                  |   4 +
 net/vmw_vsock/hyperv_transport.c                                   |  22 +-
 samples/sockmap/sockmap_kern.c                                     |   2 +-
 tools/include/uapi/linux/bpf.h                                     |   3 +-
 tools/testing/selftests/bpf/bpf_helpers.h                          |   2 +-
 tools/testing/selftests/bpf/sockmap_verdict_prog.c                 |   4 +-
 tools/testing/selftests/bpf/test_maps.c                            |  12 +-
 tools/testing/selftests/bpf/test_verifier.c                        | 510 +++++++++++++++++++++++++++++++++++++++++++++-
 113 files changed, 1735 insertions(+), 689 deletions(-)
