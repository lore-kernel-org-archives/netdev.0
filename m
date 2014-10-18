From: David Miller <davem@davemloft.net>
Subject: [GIT] Networking
Date: Sat, 18 Oct 2014 00:18:44 -0400 (EDT)
Message-ID: <20141018.001844.1317443518545745039.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:44473 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750791AbaJRESq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 18 Oct 2014 00:18:46 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


1) Include fixes for netrom and dsa (Fabian Frederick and Florian
   Fainelli)

2) Fix FIXED_PHY support in stmmac, from Giuseppe CAVALLARO.

3) Several SKB use after free fixes (vxlan, openvswitch, vxlan,	
   ip_tunnel, fou), from Li ROngQing.

4) fec driver PTP support fixes from Luwei Zhou and Nimrod Andy.

5) Use after free in virtio_net, from MichaelS. Tsirkin.

6) Fix flow mask handling for megaflows in openvswitch, from
   Pravin B. Shelar.

7) ISDN gigaset and capi bug fixes from Tilman Schmidt.

8) Fix route leak in ip_send_unicast_reply(), from Vasily Averin.

9) Fix two eBPF JIT bugs on x86, from Alexei Starovoitov.

10) TCP_SKB_CB() reorganization caused a few regressions, fixed
    by Cong Wang and Eric Dumazet.

11) Don't overwrite end of SKB when parsing malformed sctp ASCONF
    chunks, from Daniel Borkmann.

12) Don't call sock_kfree_s() with NULL pointers, this function also
    has the side effect of adjusting the socket memory usage.  From
    Cong Wang.

Please pull, thanks a lot.

The following changes since commit 01d2d484e49e9bc0ed9b5fdaf345a0e2bf35ffed:

  Merge branch 'bcmgenet_systemport' (2014-10-10 15:39:22 -0400)

are available in the git repository at:


  git://git.kernel.org/pub/scm/linux/kernel/git/davem/net.git master

for you to fetch changes up to f2d9da1a8375cbe53df5b415d059429013a3a79f:

  bna: fix skb->truesize underestimation (2014-10-17 23:56:33 -0400)

----------------------------------------------------------------
Alexander Aring (1):
      skbuff: fix ftrace handling in skb_unshare

Alexander Duyck (1):
      fm10k: Add skb->xmit_more support

Alexei Starovoitov (2):
      x86: bpf_jit: fix two bugs in eBPF JIT compiler
      net: filter: move common defines into bpf_common.h

Andy Zhou (1):
      fm10k: Add CONFIG_FM10K_VXLAN configuration option

Anish Bhatt (5):
      cxgb4i : Remove duplicated CLIP handling code
      cxgb4 : Fix build failure in cxgb4 when ipv6 is disabled/not in-built
      cxgb4i : Fix -Wunused-function warning
      cxgb4i: Remove duplicate call to dst_neigh_lookup()
      cxgb4i : Fix -Wmaybe-uninitialized warning.

Bruno Thomsen (1):
      phy/micrel: KSZ8031RNL RMII clock reconfiguration bug

Claudiu Manoil (1):
      gianfar: Add FCS to rx buffer size (fix)

Cong Wang (4):
      rds: avoid calling sock_kfree_s() on allocation failure
      ipv4: call __ip_options_echo() in cookie_v4_check()
      ipv4: share tcp_v4_save_options() with cookie_v4_check()
      ipv4: clean up cookie_v4_check()

Daniel Borkmann (3):
      net: sctp: fix skb_over_panic when receiving malformed ASCONF chunks
      net: sctp: fix panic on duplicate ASCONF chunks
      net: sctp: fix remote memory pressure from excessive queueing

David S. Miller (9):
      Merge branch 'sctp'
      Merge branch 'fec-ptp'
      Merge branch 'isdn'
      Merge branch 'xgene'
      Merge branch 'stmmac'
      net: Trap attempts to call sock_kfree_s() with a NULL pointer.
      Merge branch 'qlcnic'
      Merge branch 'cxgb4'
      Merge branch 'master' of git://git.kernel.org/.../jkirsher/net

Edward Cree (1):
      sfc: add support for skb->xmit_more

Emil Tantilov (1):
      ixgbe: check for vfs outside of sriov_num_vfs before dereference

Eric Dumazet (5):
      tcp: fix ooo_okay setting vs Small Queues
      tcp: fix tcp_ack() performance problem
      tcp: TCP Small Queues and strange attractors
      ipv6: introduce tcp_v6_iif()
      bna: fix skb->truesize underestimation

Fabian Frederick (6):
      caif: replace kmalloc/memset 0 by kzalloc
      caif_usb: remove redundant memory message
      caif_usb: use target structure member in memset
      openvswitch: kerneldoc warning fix
      openvswitch: use vport instead of p
      netrom: use linux/uaccess.h

Florian Fainelli (1):
      net: dsa: add includes for ethtool and phy_fixed definitions

Giuseppe CAVALLARO (4):
      stmmac: platform: fix FIXED_PHY support.
      stmmac: make the STi Layer compatible to STiH407
      stmmac: dwmac-sti: review the glue-logic for STi4xx and STiD127 SoCs
      stmmac: fix sti compatibililies

Guenter Roeck (2):
      dsa: mv88e6171: Fix tag_protocol check
      dsa: Fix conversion from host device to mii bus

Haiyang Zhang (1):
      hyperv: Add handling of IP header with option field in netvsc_set_hash()

Hariprasad Shenai (1):
      cxgb4: Fix FW flash logic using ethtool

Iyappan Subramanian (4):
      dtb: Add SGMII based 1GbE node to APM X-Gene SoC device tree
      drivers: net: xgene: Preparing for adding SGMII based 1GbE
      drivers: net: xgene: Add SGMII based 1GbE support
      drivers: net: xgene: Add SGMII based 1GbE ethtool support

Jiri Pirko (1):
      ipv4: fix nexthop attlen check in fib_nh_match

Jon Paul Maloy (1):
      tipc: fix bug in bundled buffer reception

Li RongQing (7):
      ipv6: remove aca_lock spinlock from struct ifacaddr6
      vxlan: fix a use after free in vxlan_encap_bypass
      vxlan: using pskb_may_pull as early as possible
      openvswitch: fix a use after free
      vxlan: fix a free after use
      ipv4: fix a potential use after free in ip_tunnel_core.c
      ipv4: fix a potential use after free in fou.c

Luwei Zhou (3):
      net: fec: ptp: Use the 31-bit ptp timer.
      net: fec: ptp: Use hardware algorithm to adjust PTP counter.
      net: fec: ptp: Enable PPS output based on ptp clock

Mark Rustad (1):
      genl_magic: Resolve logical-op warnings

Matthew Vick (2):
      fm10k: Check the host state when bringing the interface up
      fm10k: Unlock mailbox on VLAN addition failures

Michael Opdenacker (1):
      atm: simplify lanai.c by using module_pci_driver

Michael S. Tsirkin (1):
      virtio_net: fix use after free

Mugunthan V N (3):
      drivers: net: davinci_cpdma: remove kfree on objects allocated with devm_* apis
      drivers: net: davinci_cpdma: remove spinlock as SOFTIRQ-unsafe lock order detected
      drivers: net: cpsw: remove child devices while driver detach

Nicolas Dichtel (1):
      netlink: fix description of portid

Nimrod Andy (2):
      net: fec: Fix sparse warnings with different lock contexts for basic block
      net: fec: ptp: fix convergence issue to support LinuxPTP stack

Prashant Sreedharan (1):
      tg3: Add skb->xmit_more support

Pravin B Shelar (2):
      openvswitch: Create right mask with disabled megaflows
      openvswitch: Set flow-key members.

Rajesh Borundia (2):
      qlcnic: Fix programming number of arguments in a command.
      qlcnic: Fix number of arguments in destroy tx context command

Tilman Schmidt (12):
      isdn/gigaset: missing break in do_facility_req
      isdn/gigaset: make sure controller name is null terminated
      isdn/gigaset: limit raw CAPI message dump length
      isdn/gigaset: fix NULL pointer dereference
      isdn/gigaset: fix non-heap pointer deallocation
      isdn/capi: correct capi20_manufacturer argument type mismatch
      isdn/capi: prevent index overrun from command_2_index()
      isdn/capi: refactor command/subcommand table accesses
      isdn/capi: prevent NULL pointer dereference on invalid CAPI command
      isdn/capi: handle CAPI 2.0 message parser failures
      isdn/capi: don't return NULL from capi_cmd2str()
      isdn/gigaset: fix usb_gigaset write_cmd result race

Tom Herbert (1):
      net: Add ndo_gso_check

Vasily Averin (1):
      ipv4: dst_entry leak in ip_send_unicast_reply()

Vince Bridgers (1):
      MAINTAINERS: Update contact information for Vince Bridgers

hayeswang (1):
      r8152: return -EBUSY for runtime suspend

 Documentation/devicetree/bindings/net/sti-dwmac.txt   |  91 +++++++------
 MAINTAINERS                                           |   2 +-
 arch/arm64/boot/dts/apm-mustang.dts                   |   4 +
 arch/arm64/boot/dts/apm-storm.dtsi                    |  24 ++++
 arch/x86/net/bpf_jit_comp.c                           |  25 +++-
 drivers/atm/lanai.c                                   |  22 +---
 drivers/isdn/capi/capidrv.c                           |  24 +++-
 drivers/isdn/capi/capiutil.c                          |  41 +++++-
 drivers/isdn/capi/kcapi.c                             |   4 +-
 drivers/isdn/gigaset/capi.c                           | 155 ++++++++++++++++++----
 drivers/isdn/gigaset/ev-layer.c                       | 116 +++++++++++------
 drivers/isdn/gigaset/usb-gigaset.c                    |   4 +-
 drivers/net/dsa/mv88e6060.c                           |  16 ++-
 drivers/net/dsa/mv88e6171.c                           |   2 +-
 drivers/net/dsa/mv88e6xxx.c                           |  14 +-
 drivers/net/ethernet/apm/xgene/Makefile               |   2 +-
 drivers/net/ethernet/apm/xgene/xgene_enet_ethtool.c   |  25 ++--
 drivers/net/ethernet/apm/xgene/xgene_enet_hw.c        |   1 -
 drivers/net/ethernet/apm/xgene/xgene_enet_hw.h        |   4 +-
 drivers/net/ethernet/apm/xgene/xgene_enet_main.c      |  18 ++-
 drivers/net/ethernet/apm/xgene/xgene_enet_main.h      |  12 +-
 drivers/net/ethernet/apm/xgene/xgene_enet_sgmac.c     | 389 +++++++++++++++++++++++++++++++++++++++++++++++++++++++
 drivers/net/ethernet/apm/xgene/xgene_enet_sgmac.h     |  41 ++++++
 drivers/net/ethernet/apm/xgene/xgene_enet_xgmac.c     |   3 +-
 drivers/net/ethernet/apm/xgene/xgene_enet_xgmac.h     |   4 -
 drivers/net/ethernet/broadcom/tg3.c                   |  10 +-
 drivers/net/ethernet/brocade/bna/bnad.c               |   2 +-
 drivers/net/ethernet/chelsio/Kconfig                  |   2 +-
 drivers/net/ethernet/chelsio/cxgb4/cxgb4.h            |   2 +
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c       |  29 ++++-
 drivers/net/ethernet/chelsio/cxgb4/t4_hw.c            |   6 +-
 drivers/net/ethernet/freescale/fec.h                  |  60 +++++++++
 drivers/net/ethernet/freescale/fec_main.c             |  69 +++-------
 drivers/net/ethernet/freescale/fec_ptp.c              | 277 ++++++++++++++++++++++++++++++++++++---
 drivers/net/ethernet/freescale/gianfar.c              |   2 +-
 drivers/net/ethernet/intel/Kconfig                    |  11 ++
 drivers/net/ethernet/intel/fm10k/fm10k_main.c         |  65 +++++-----
 drivers/net/ethernet/intel/fm10k/fm10k_netdev.c       |  13 +-
 drivers/net/ethernet/intel/fm10k/fm10k_pci.c          |   1 +
 drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c        |   3 +
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_ctx.c       |   6 +-
 drivers/net/ethernet/sfc/nic.h                        |  29 ++++-
 drivers/net/ethernet/sfc/tx.c                         |  43 +++---
 drivers/net/ethernet/stmicro/stmmac/dwmac-sti.c       | 374 ++++++++++++++++++++++++++++------------------------
 drivers/net/ethernet/stmicro/stmmac/stmmac.h          |   3 +-
 drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c |  20 ++-
 drivers/net/ethernet/ti/cpsw.c                        |  10 ++
 drivers/net/ethernet/ti/davinci_cpdma.c               |   5 -
 drivers/net/hyperv/netvsc_drv.c                       |  26 ++--
 drivers/net/macvtap.c                                 |   2 +-
 drivers/net/phy/micrel.c                              |   4 +-
 drivers/net/usb/r8152.c                               |  22 +++-
 drivers/net/virtio_net.c                              |   4 +-
 drivers/net/vxlan.c                                   |  15 ++-
 drivers/net/xen-netfront.c                            |   2 +-
 drivers/scsi/cxgbi/cxgb4i/cxgb4i.c                    | 148 ++-------------------
 drivers/scsi/cxgbi/libcxgbi.c                         |   2 +
 include/linux/genl_magic_func.h                       |   4 +-
 include/linux/kernelcapi.h                            |   2 +-
 include/linux/netdevice.h                             |  12 +-
 include/linux/skbuff.h                                |   7 +-
 include/net/dsa.h                                     |   1 +
 include/net/if_inet6.h                                |   1 -
 include/net/inet6_hashtables.h                        |   5 +-
 include/net/netlink.h                                 |   2 +-
 include/net/sctp/sctp.h                               |   5 +
 include/net/sctp/sm.h                                 |   6 +-
 include/net/tcp.h                                     |  32 ++++-
 include/uapi/linux/Kbuild                             |   1 +
 include/uapi/linux/bpf.h                              |   1 +
 include/uapi/linux/bpf_common.h                       |  55 ++++++++
 include/uapi/linux/filter.h                           |  56 +-------
 net/caif/caif_usb.c                                   |   7 +-
 net/caif/cfmuxl.c                                     |   4 +-
 net/core/dev.c                                        |   2 +-
 net/core/sock.c                                       |   2 +
 net/dccp/ipv6.c                                       |   3 +-
 net/dsa/slave.c                                       |   1 +
 net/ipv4/fib_semantics.c                              |   2 +-
 net/ipv4/fou.c                                        |   3 +
 net/ipv4/ip_output.c                                  |  12 +-
 net/ipv4/ip_tunnel_core.c                             |   3 +-
 net/ipv4/syncookies.c                                 |  16 +--
 net/ipv4/tcp_input.c                                  |  36 +++--
 net/ipv4/tcp_ipv4.c                                   |  22 +---
 net/ipv4/tcp_output.c                                 |  34 +++--
 net/ipv6/anycast.c                                    |   1 -
 net/ipv6/syncookies.c                                 |   2 +-
 net/ipv6/tcp_ipv6.c                                   |  26 ++--
 net/netrom/af_netrom.c                                |   2 +-
 net/netrom/nr_dev.c                                   |   2 +-
 net/netrom/nr_in.c                                    |   2 +-
 net/netrom/nr_out.c                                   |   2 +-
 net/netrom/nr_route.c                                 |   2 +-
 net/netrom/nr_subr.c                                  |   2 +-
 net/netrom/nr_timer.c                                 |   2 +-
 net/openvswitch/flow.c                                |   9 +-
 net/openvswitch/flow_netlink.c                        |  93 ++++++++++---
 net/openvswitch/vport-geneve.c                        |   2 +-
 net/openvswitch/vport.c                               |   4 +-
 net/rds/rdma.c                                        |   7 +-
 net/sctp/associola.c                                  |   2 +
 net/sctp/inqueue.c                                    |  33 +----
 net/sctp/sm_make_chunk.c                              |  99 +++++++-------
 net/sctp/sm_statefuns.c                               |  21 +--
 net/tipc/link.c                                       |   7 +-
 106 files changed, 2010 insertions(+), 957 deletions(-)
 create mode 100644 drivers/net/ethernet/apm/xgene/xgene_enet_sgmac.c
 create mode 100644 drivers/net/ethernet/apm/xgene/xgene_enet_sgmac.h
 create mode 100644 include/uapi/linux/bpf_common.h
