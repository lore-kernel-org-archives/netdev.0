From: David Miller <davem@davemloft.net>
Subject: [GIT] Networking
Date: Fri, 22 Sep 2017 22:03:14 -0700 (PDT)
Message-ID: <20170922.220314.863947456405461896.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


1) Fix NAPI poll list corruption in enic driver, from Christian
   Lamparter.

2) Fix route use after free, from Eric Dumazet.

3) Fix regression in reuseaddr handling, from Josef Bacik.

4) Assert the size of control messages in compat handling since we
   copy it in from userspace twice.  From Meng Xu.

5) SMC layer bug fixes (missing RCU locking, bad refcounting, etc.)
   from Ursula Braun.

6) Fix races in AF_PACKET fanout handling, from Willem de Bruijn.

7) Don't use ARRAY_SIZE on spinlock array which might have zero
   entries, from Geert Uytterhoeven.

8) Fix miscomputation of checksum in ipv6 udp code, from Subash
   Abhinov Kasiviswanathan.

9) Push the ipv6 header properly in ipv6 GRE tunnel driver, from
   Xin Long.

Please pull, thanks a lot.

The following changes since commit 2bd6bf03f4c1c59381d62c61d03f6cc3fe71f66e:

  Linux 4.14-rc1 (2017-09-16 15:47:51 -0700)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/davem/net 

for you to fetch changes up to 4e683f499a15cd777d3cb51aaebe48d72334c852:

  Merge branch 'net-fix-reuseaddr-regression' (2017-09-22 20:33:18 -0700)

----------------------------------------------------------------
Alex Ng (1):
      hv_netvsc: fix send buffer failure on MTU change

Andreas Gruenbacher (1):
      rhashtable: Documentation tweak

Ariel Elior (1):
      MAINTAINERS: Remove Yuval Mintz from maintainers list

Christian Lamparter (1):
      net: emac: Fix napi poll list corruption

Cong Wang (1):
      net_sched: remove cls_flower idr on failure

Daniel Borkmann (1):
      bpf: fix ri->map_owner pointer on bpf_prog_realloc

David S. Miller (8):
      Merge tag 'mac80211-for-davem-2017-11-19' of git://git.kernel.org/.../jberg/mac80211
      Merge branch 'hns3-bug-fixes'
      Merge git://git.kernel.org/.../pablo/nf
      Merge branch 'hns3-tm-fixes'
      Merge branch 'phylib-xcvr-type'
      Merge branch 'lan78xx-fixes'
      Merge branch 'smc-bug-fixes'
      Merge branch 'net-fix-reuseaddr-regression'

Davide Caratti (1):
      net/sched: cls_matchall: fix crash when used with classful qdisc

Edward Cree (1):
      net: change skb->mac_header when Generic XDP calls adjust_head

Eric Dumazet (4):
      8139too: revisit napi_complete_done() usage
      bpf: do not disable/enable BH in bpf_map_free_id()
      tcp: fastopen: fix on syn-data transmit failure
      net: prevent dst uses after free

Fahad Kunnathadi (1):
      net: phy: Fix mask value write on gmii2rgmii converter speed register

Florian Fainelli (3):
      net: systemport: Fix 64-bit statistics dependency
      net: ethtool: Add back transceiver type
      net: phy: Keep reporting transceiver type

Geert Uytterhoeven (2):
      netfilter: nat: Do not use ARRAY_SIZE() on spinlocks to fix zero div
      net: phy: Fix truncation of large IRQ numbers in phy_attached_print()

Hans Wippel (2):
      net/smc: add missing dev_put
      net/smc: add receive timeout check

Jerome Brunet (1):
      net: phy: Kconfig: Fix PHY infrastructure menu in menuconfig

Johannes Berg (1):
      nl80211: fix null-ptr dereference on invalid mesh configuration

Josef Bacik (3):
      net: set tb->fast_sk_family
      net: use inet6_rcv_saddr to compare sockets
      inet: fix improper empty comparison

Konstantin Khlebnikov (2):
      net_sched: always reset qdisc backlog in qdisc_reset()
      net_sched/hfsc: fix curve activation in hfsc_change_class()

Lipeng (6):
      net: hns3: Fixes initialization of phy address from firmware
      net: hns3: Fixes the command used to unmap ring from vector
      net: hns3: Fixes ring-to-vector map-and-unmap command
      net: hns3: Fixes the initialization of MAC address in hardware
      net: hns3: Fixes the default VLAN-id of PF
      net: hns3: Fixes the premature exit of loop when matching clients

Matteo Croce (1):
      ipv6: fix net.ipv6.conf.all interface DAD handlers

Meng Xu (2):
      net: compat: assert the size of cmsg copied in is as expected
      isdn/i4l: fetch the ppp_write buffer in one shot

Mike Manning (1):
      net: ipv6: fix regression of no RTM_DELADDR sent after DAD failure

Nisar Sayed (3):
      lan78xx: Fix for eeprom read/write when device auto suspend
      lan78xx: Allow EEPROM write for less than MAX_EEPROM_SIZE
      lan78xx: Use default values loaded from EEPROM/OTP after reset

Randy Dunlap (1):
      Documentation: networking: fix ASCII art in switchdev.txt

Salil Mehta (1):
      net: hns3: Fixes the ether address copy with appropriate API

Sathya Perla (1):
      bnxt_en: check for ingress qdisc in flower offload

Stefan Schmidt (1):
      MAINTAINERS: update git tree locations for ieee802154 subsystem

Subash Abhinov Kasiviswanathan (1):
      udpv6: Fix the checksum computation when HW checksum does not apply

Thomas Meyer (1):
      net: stmmac: Cocci spatch "of_table"

Timur Tabi (1):
      net: qcom/emac: add software control for pause frame mode

Tobias Klauser (1):
      bpf: devmap: pass on return value of bpf_map_precharge_memlock

Troy Kisky (3):
      net: fec: only check queue 0 if RXF_0/TXF_0 interrupt is set
      net: fec: remove unused interrupt FEC_ENET_TS_TIMER
      net: fec: return IRQ_HANDLED if fec_ptp_check_pps_event handled it

Ursula Braun (7):
      net/smc: take RCU read lock for routing cache lookup
      net/smc: adjust net_device refcount
      net/smc: adapt send request completion notification
      net/smc: longer delay for client link group removal
      net/smc: terminate link group if out-of-sync is received
      net/smc: introduce a delay
      net/smc: no close wait in case of process shut down

Vishwanath Pai (1):
      netfilter: ipset: ipset list may return wrong member count for set with timeout

Vladis Dronov (1):
      nl80211: check for the required netlink attributes presence

Willem de Bruijn (2):
      packet: hold bind lock when rebinding to fanout hook
      net: orphan frags on stand-alone ptype in dev_queue_xmit_nit

Xin Long (2):
      ip6_gre: skb_push ipv6hdr before packing the header in ip6gre_header
      ip6_tunnel: do not allow loading ip6_tunnel if ipv6 is disabled in cmdline

Yonghong Song (1):
      bpf: one perf event close won't free bpf program attached by another perf event

Yuchung Cheng (1):
      tcp: remove two unused functions

Yunsheng Lin (9):
      net: hns3: Cleanup for ROCE capability flag in ae_dev
      net: hns3: Fix initialization when cmd is not supported
      net: hns3: Fix for DEFAULT_DV when dev doesn't support DCB
      net: hns3: Fix for not setting rx private buffer size to zero
      net: hns3: Fix for rx_priv_buf_alloc not setting rx shared buffer
      net: hns3: Fix for rx priv buf allocation when DCB is not supported
      net: hns3: Fix typo error for feild in hclge_tm
      net: hns3: Fix for setting rss_size incorrectly
      net: hns3: Fix for pri to tc mapping in TM

 Documentation/networking/ip-sysctl.txt                  |  18 +++++++---
 Documentation/networking/switchdev.txt                  |  68 ++++++++++++++++++-------------------
 MAINTAINERS                                             |   6 ++--
 drivers/isdn/i4l/isdn_ppp.c                             |  37 +++++++++++++-------
 drivers/net/ethernet/broadcom/bcmsysport.c              |  52 +++++++++++++++++-----------
 drivers/net/ethernet/broadcom/bnxt/bnxt_tc.c            |   4 +++
 drivers/net/ethernet/freescale/fec.h                    |   4 +--
 drivers/net/ethernet/freescale/fec_main.c               |   8 ++---
 drivers/net/ethernet/hisilicon/hns3/hnae3.c             |  43 +++++------------------
 drivers/net/ethernet/hisilicon/hns3/hnae3.h             |  15 ++++++--
 drivers/net/ethernet/hisilicon/hns3/hns3pf/hclge_cmd.h  |  12 +++++--
 drivers/net/ethernet/hisilicon/hns3/hns3pf/hclge_main.c | 183 ++++++++++++++++++++++++++++++++++++++++++++++++++++++++------------------------------------------
 drivers/net/ethernet/hisilicon/hns3/hns3pf/hclge_main.h |   3 +-
 drivers/net/ethernet/hisilicon/hns3/hns3pf/hclge_tm.c   |  41 ++++++++++++----------
 drivers/net/ethernet/hisilicon/hns3/hns3pf/hclge_tm.h   |   4 +--
 drivers/net/ethernet/hisilicon/hns3/hns3pf/hns3_enet.c  |  23 ++++++++-----
 drivers/net/ethernet/ibm/emac/mal.c                     |   3 +-
 drivers/net/ethernet/qualcomm/emac/emac-ethtool.c       |  30 ++++++++++++++++
 drivers/net/ethernet/qualcomm/emac/emac-mac.c           |  22 ++++++++++++
 drivers/net/ethernet/qualcomm/emac/emac.c               |   3 ++
 drivers/net/ethernet/qualcomm/emac/emac.h               |   3 ++
 drivers/net/ethernet/realtek/8139too.c                  |   5 +--
 drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c   |   1 +
 drivers/net/hyperv/hyperv_net.h                         |   2 ++
 drivers/net/hyperv/netvsc.c                             |   7 ++--
 drivers/net/hyperv/netvsc_drv.c                         |   8 +++++
 drivers/net/phy/Kconfig                                 |  18 +++++-----
 drivers/net/phy/phy.c                                   |   3 +-
 drivers/net/phy/phy_device.c                            |   2 +-
 drivers/net/phy/xilinx_gmii2rgmii.c                     |   2 +-
 drivers/net/usb/lan78xx.c                               |  34 +++++++++++++------
 include/linux/trace_events.h                            |   1 +
 include/net/dst.h                                       |  22 +++---------
 include/net/route.h                                     |   2 +-
 include/net/sock.h                                      |   2 +-
 include/net/tcp.h                                       |   1 -
 include/uapi/linux/ethtool.h                            |   6 +++-
 kernel/bpf/devmap.c                                     |   6 ++--
 kernel/bpf/syscall.c                                    |   6 ++--
 kernel/bpf/verifier.c                                   |   7 +++-
 kernel/events/core.c                                    |   3 +-
 lib/rhashtable.c                                        |   9 ++---
 net/compat.c                                            |   7 ++++
 net/core/dev.c                                          |   9 +++--
 net/core/ethtool.c                                      |   2 ++
 net/core/filter.c                                       |  24 ++++++++-----
 net/ipv4/inet_connection_sock.c                         |   6 ++--
 net/ipv4/tcp_output.c                                   |  43 +++++------------------
 net/ipv6/addrconf.c                                     |  32 ++++++++++++-----
 net/ipv6/ip6_gre.c                                      |  21 ++++++------
 net/ipv6/ip6_tunnel.c                                   |   3 ++
 net/ipv6/udp.c                                          |   1 +
 net/netfilter/ipset/ip_set_hash_gen.h                   |  14 +++++++-
 net/netfilter/nf_nat_core.c                             |  12 +++----
 net/packet/af_packet.c                                  |  16 ++++++---
 net/sched/cls_flower.c                                  |  15 ++++----
 net/sched/cls_matchall.c                                |   1 +
 net/sched/sch_generic.c                                 |   1 +
 net/sched/sch_hfsc.c                                    |  23 ++++++++++---
 net/smc/af_smc.c                                        |  16 +++++----
 net/smc/smc.h                                           |   2 +-
 net/smc/smc_clc.c                                       |  10 +++---
 net/smc/smc_clc.h                                       |   3 +-
 net/smc/smc_close.c                                     |  27 ++++++++-------
 net/smc/smc_core.c                                      |  16 ++++++---
 net/smc/smc_ib.c                                        |   1 +
 net/smc/smc_pnet.c                                      |   4 ++-
 net/smc/smc_rx.c                                        |   2 ++
 net/smc/smc_tx.c                                        |  12 ++++---
 net/smc/smc_wr.c                                        |   2 +-
 net/wireless/nl80211.c                                  |   6 ++++
 71 files changed, 646 insertions(+), 414 deletions(-)
