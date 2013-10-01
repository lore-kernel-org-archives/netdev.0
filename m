From: David Miller <davem@davemloft.net>
Subject: [GIT] Networking
Date: Tue, 01 Oct 2013 13:57:33 -0400 (EDT)
Message-ID: <20131001.135733.872488913164157407.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


1) Multiply in netfilter IPVS can overflow when calculating destination
   weight.  From Simon Kirby.

2) Use after free fixes in IPVS from Julian Anastasov.

3) SFC driver bug fixes from Daniel Pieczko.

4) Memory leak in pcan_usb_core failure paths, from Alexey Khoroshilov.

5) Locking and encapsulation fixes to serial line CAN driver, from
   Andrew Naujoks.

6) Duplex and VF handling fixes to bnx2x driver from Yaniv Rosner,
   Eilon Greenstein, and Ariel Elior.

7) In lapb, if no other packets are outstanding, T1 timeouts actually
   stall things and no packet gets sent.  Fix from Josselin Costanzi.

8) ICMP redirects should not make it to the socket error queues, from
   Duan Jiong.

9) Fix bugs in skge DMA mapping error handling, from Nikulas Patocka.

10) Fix setting of VLAN priority field on via-rhine driver, from
    Roget Luethi.

11) Fix TX stalls and VLAN promisc programming in be2net driver from
    Ajit Khaparde.

12) Packet padding doesn't get handled correctly in new usbnet SG
    support code, from Ming Lei.

13) Fix races in netdevice teardown wrt. network namespace closing.
    From Eric W. Biederman.

14) Fix potential missed initialization of net_secret if not TCP
    connections are openned.  From Eric Dumazet.

15) Cinterion PLXX product ID in qmi_wwan driver is wrong, from
    Aleksander Morgado.

16) skb_cow_head() can change skb->data and thus packet header pointers,
    don't use stale ip_hdr reference in ip_tunnel code.

17) Backend state transition handling fixes in xen-netback, from Paul
    Durrant.

18) Packet offset for AH protocol is handled wrong in flow dissector,
    from Eric Dumazet.

19) Taking down an fq packet scheduler instance can leave stale packets
    in the queues, fix from Eric Dumazet.

20) Fix performance regressions introduced by TCP Small Queues.  From
    Eric Dumazet.

21) IPV6 GRE tunneling code calculates max_headroom incorrectly, from
    Hannes Frederic Sowa.

22) Multicast timer handlers in ipv4 and ipv6 can be the last and final
    reference to the ipv4/ipv6 specific network device state, so use
    the reference put that will check and release the object if the
    reference hits zero.  From Salam Noureddine.

23) Fix memory corruption in ip_tunnel driver, and use skb_push() instead
    of __skb_push() so that similar bugs are less hard to find.  From
    Steffen Klassert.

24) Add forgotten hookup of rtnl_ops in SIT and ip6tnl drivers, from
    Nicolas Dichtel.

25) fq scheduler doesn't accurately rate limit in certain circumstances,
    from Eric Dumazet.

Please pull, thanks a lot!

The following changes since commit dcb30e659287a6b40dafed1362532da42ec27229:

  Merge tag 'arm64-stable' of git://git.kernel.org/pub/scm/linux/kernel/git/cmarinas/linux-aarch64 (2013-09-20 08:18:51 -0500)

are available in the git repository at:


  git://git.kernel.org/pub/scm/linux/kernel/git/davem/net master

for you to fetch changes up to 0eab5eb7a3a9a6ccfcdecbffff00d60a86a004bb:

  pkt_sched: fq: rate limiting improvements (2013-10-01 13:00:38 -0400)

----------------------------------------------------------------
Aida Mynzhasova (2):
      powerpc/83xx: gianfar_ptp: select 1588 clock source through dts file
      powerpc/83xx: gianfar_ptp: select 1588 clock source through dts file

Ajit Khaparde (7):
      be2net: Fix to prevent Tx stall on SH-R when packet size < 32
      be2net: Fix the size of be_nic_res_desc structure
      be2net: Fix VLAN promiscuous mode programming
      be2net: Fix number of VLANs supported in UMC mode for BE3-R.
      be2net: Fix to allow VLAN configuration on VF interfaces.
      be2net: Fix to configure VLAN priority for a VF interface.
      be2net: Fix to display the VLAN priority for a VF

Aleksander Morgado (1):
      net: qmi_wwan: fix Cinterion PLXX product ID

Alexey Khoroshilov (2):
      can: pcan_usb_core: fix memory leak on failure paths in peak_usb_start()
      p54usb: fix leak at failure path in p54u_load_firmware()

Amitkumar Karwar (1):
      mwifiex: fix hang issue for USB chipsets

Andre Guedes (2):
      Bluetooth: Fix security level for peripheral role
      Bluetooth: Fix encryption key size for peripheral role

Andre Naujoks (3):
      slip/slcan: added locking in wakeup function
      lib: introduce upper case hex ascii helpers
      slcan: rewrite of slc_bump and slc_encaps

Arend van Spriel (3):
      brcmfmac: obtain platform data upon module initialization
      bcma: make bcma_core_pci_{up,down}() callable from atomic context
      brcmsmac: call bcma_core_pci_power_save() from non-atomic context

Ariel Elior (3):
      bnx2x: Fix support for VFs on some PFs
      bnx2x: add missing VF resource allocation during init
      bnx2x: handle known but unsupported VF messages

Bartlomiej Zolnierkiewicz (1):
      ethernet: moxa: fix incorrect placement of __initdata tag

Bing Zhao (2):
      mwifiex: fix PCIe hs_cfg cancel cmd timeout
      mwifiex: fix NULL pointer dereference in usb suspend handler

Catalin\(ux\) M. BOIE (1):
      IPv6 NAT: Do not drop DNATed 6to4/6rd packets

Christian Lamparter (1):
      p54usb: add USB ID for Corega WLUSB2GTST USB adapter

Daniel Pieczko (2):
      sfc: Wait for MC reboot to complete before scheduling driver reset
      sfc: Increase MCDI status timeout to 250ms

David S. Miller (9):
      Merge branch 'sfc-3.12' of git://git.kernel.org/.../bwh/sfc
      Merge branch 'bnx2x'
      Merge branch 'fixes-for-3.12' of git://gitorious.org/linux-can/linux-can
      Merge branch 'master' of git://git.kernel.org/.../jkirsher/net
      Merge branch 'for-davem' of git://git.kernel.org/.../linville/wireless
      Revert "powerpc/83xx: gianfar_ptp: select 1588 clock source through dts file"
      Merge branch 'fixes-for-3.12' of git://gitorious.org/linux-can/linux-can
      Merge branch 'master' of git://git.kernel.org/.../pablo/nf
      Merge branch 'ip_tunnel'

Duan Jiong (2):
      net: udp: do not report ICMP redirects to user space
      net: raw: do not report ICMP redirects to user space

Eilon Greenstein (1):
      bnx2x: Prevent mistaken hangup between driver & FW

Eric Dumazet (5):
      net: net_secret should not depend on TCP
      net: flow_dissector: fix thoff for IPPROTO_AH
      pkt_sched: fq: qdisc dismantle fixes
      tcp: TSQ can use a dynamic limit
      pkt_sched: fq: rate limiting improvements

Eric W. Biederman (1):
      net: Delay default_device_exit_batch until no devices are unregistering v2

Felix Fietkau (4):
      ath9k: fix stale flag handling on buffer clone
      ath9k: do not link bf_next across multiple A-MPDUs
      ath9k: don't use BAW tracking on PS responses for non-AMPDU packets
      ath9k: add txq locking for ath_tx_aggr_start

Gianluca Anzolin (1):
      Bluetooth: don't release the port in rfcomm_dev_state_change()

Hannes Frederic Sowa (2):
      ipv6: udp packets following an UFO enqueued packet need also be handled by UFO
      ipv6: gre: correct calculation of max_headroom

Jesse Brandeburg (5):
      i40e: use common failure flow
      i40e: small clean ups from review
      i40e: convert ret to aq_ret
      i40e: better return values
      i40e: clean up coccicheck reported errors

Johan Hedberg (2):
      Bluetooth: Introduce a new HCI_RFKILLED flag
      Bluetooth: Fix rfkill functionality during the HCI setup stage

John W. Linville (2):
      Merge branch 'master' of git://git.kernel.org/.../bluetooth/bluetooth
      Merge branch 'master' of git://git.kernel.org/.../linville/wireless into for-davem

Julian Anastasov (4):
      ipvs: make the service replacement more robust
      ipvs: do not use dest after ip_vs_dest_put in LBLC
      ipvs: do not use dest after ip_vs_dest_put in LBLCR
      ipvs: stats should not depend on CPU 0

Ken O'Brien (1):
      Bluetooth: btusb: Add support for Belkin F8065bf

Larry Finger (1):
      rtlwifi: Align private space in rtl_priv struct

Manish Chopra (1):
      qlcnic: Fix SR-IOV configuration

Marc Kleine-Budde (1):
      can: flexcan: fix flexcan_chip_start() on imx6

Mikulas Patocka (1):
      skge: fix invalid value passed to pci_unmap_sigle

Ming Lei (1):
      USBNET: fix handling padding packet

Neil Horman (1):
      bonding: Fix broken promiscuity reference counting issue

Nicolas Dichtel (3):
      skbuff: size of hole is wrong in a comment
      sit: allow to use rtnl ops on fb tunnel
      ip6tnl: allow to use rtnl ops on fb tunnel

Noel Burton-Krahn (1):
      mrp: add periodictimer to allow retries when packets get lost

Patrick McHardy (1):
      netfilter: synproxy: fix BUG_ON triggered by corrupt TCP packets

Paul Durrant (1):
      xen-netback: Handle backend state transitions in a more robust way

Paul Marks (1):
      ipv6: Fix preferred_lft not updating in some cases

Peng Chen (1):
      Bluetooth: Add a new PID/VID 0cf3/e005 for AR3012.

Peter Korsgaard (1):
      dm9601: fix IFF_ALLMULTI handling

Pravin B Shelar (2):
      vxlan: Use RCU apis to access sk_user_data.
      ip_tunnel: Do not use stale inner_iph pointer.

Raphael Kubo da Costa (1):
      Bluetooth: Add support for BCM20702A0 [0b05, 17cb]

Ricardo Ribalda (1):
      ll_temac: Reset dma descriptors indexes on ndo_open

Roger Luethi (1):
      via-rhine: fix VLAN priority field (PCP, IEEE 802.1p)

Salam Noureddine (2):
      ipv4 igmp: use in_dev_put in timer handlers instead of __in_dev_put
      ipv6 mcast: use in6_dev_put in timer handlers instead of __in6_dev_put

Simon Kirby (1):
      ipvs: fix overflow on dest weight multiply

Solomon Peachy (2):
      Revert "cw1200: Don't perform SPI transfers in interrupt context"
      cw1200: Use a threaded oneshot irq handler for cw1200_spi

Steffen Klassert (4):
      ip_tunnel: Fix a memory corruption in ip_tunnel_xmit
      ip_tunnel: Add fallback tunnels to the hash lists
      ip_tunnel_core: Change __skb_push back to skb_push
      ip_tunnel: Remove double unregister of the fallback device

Sucheta Chakraborty (1):
      qlcnic: Fix register device in FAILED state for 82xx.

Sujith Manoharan (1):
      ath9k: Fix regression in LNA diversity

Syam Sidhardhan (1):
      Bluetooth: Fix ACL alive for long in case of non pariable devices

Todd Fujinaka (1):
      igb: Fix ethtool loopback test for 82580 copper

Wei Liu (1):
      MAINTAINERS: add myself as maintainer of xen-netback

Yaniv Rosner (5):
      bnx2x: Generalize KR work-around
      bnx2x: KR2 disablement fix
      bnx2x: 57840 non-external loopback test fail on 1G
      bnx2x: Specific Active-DAC is not detected on 57810
      bnx2x: Fix 848xx duplex settings

Yuval Mintz (2):
      bnx2x: prevent masking error from cnic
      bnx2x: prevent masked MCP parities from appearing

josselin.costanzi@mobile-devices.fr (1):
      net/lapb: re-send packets on timeout

malahal@us.ibm.com (1):
      qlge: call ql_core_dump() only if dump memory was allocated.

 Documentation/devicetree/bindings/net/fsl-tsec-phy.txt |  18 +++++-
 MAINTAINERS                                            |   1 +
 drivers/bcma/driver_pci.c                              |  49 ++++++++-------
 drivers/bluetooth/ath3k.c                              |   2 +
 drivers/bluetooth/btusb.c                              |   5 ++
 drivers/net/bonding/bond_main.c                        |  13 +++-
 drivers/net/can/flexcan.c                              |  12 ----
 drivers/net/can/slcan.c                                | 139 ++++++++++++++++++++++++++---------------
 drivers/net/can/usb/peak_usb/pcan_usb_core.c           |  15 +++--
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c        |   3 +-
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c       | 189 +++++++++++++++++++++++++++++---------------------------
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c       |  24 ++++---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.c      |   5 +-
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_vfpf.c       |  50 +++++++--------
 drivers/net/ethernet/emulex/benet/be.h                 |   2 +
 drivers/net/ethernet/emulex/benet/be_cmds.c            |   9 +++
 drivers/net/ethernet/emulex/benet/be_cmds.h            |   4 +-
 drivers/net/ethernet/emulex/benet/be_main.c            |  76 ++++++++++++++---------
 drivers/net/ethernet/freescale/gianfar_ptp.c           |   4 +-
 drivers/net/ethernet/intel/i40e/i40e_adminq.c          |   7 +--
 drivers/net/ethernet/intel/i40e/i40e_common.c          |   2 +-
 drivers/net/ethernet/intel/i40e/i40e_main.c            | 162 ++++++++++++++++++++++++------------------------
 drivers/net/ethernet/intel/igb/igb_ethtool.c           |   3 +
 drivers/net/ethernet/marvell/skge.c                    |   9 ++-
 drivers/net/ethernet/moxa/moxart_ether.c               |   2 +-
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_ethtool.c    |   8 +++
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c       |  39 +++++++++++-
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_sriov_pf.c   |   8 ++-
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_sysfs.c      |  12 ++++
 drivers/net/ethernet/qlogic/qlge/qlge_dbg.c            |   4 +-
 drivers/net/ethernet/qlogic/qlge/qlge_mpi.c            |   2 +-
 drivers/net/ethernet/sfc/mcdi.c                        |  10 +--
 drivers/net/ethernet/via/via-rhine.c                   |   9 ++-
 drivers/net/ethernet/xilinx/ll_temac_main.c            |   6 ++
 drivers/net/slip/slip.c                                |   3 +
 drivers/net/usb/dm9601.c                               |   2 +-
 drivers/net/usb/qmi_wwan.c                             |   2 +-
 drivers/net/usb/usbnet.c                               |  27 ++++++--
 drivers/net/vxlan.c                                    |   9 +--
 drivers/net/wireless/ath/ath9k/recv.c                  |   7 ---
 drivers/net/wireless/ath/ath9k/xmit.c                  |  17 ++++-
 drivers/net/wireless/brcm80211/brcmfmac/bcmsdh_sdmmc.c |  28 ++++-----
 drivers/net/wireless/brcm80211/brcmfmac/dhd_bus.h      |   3 +-
 drivers/net/wireless/brcm80211/brcmfmac/dhd_linux.c    |  14 +++--
 drivers/net/wireless/brcm80211/brcmfmac/usb.c          |   2 +-
 drivers/net/wireless/brcm80211/brcmsmac/mac80211_if.c  |   4 ++
 drivers/net/wireless/cw1200/cw1200_spi.c               |  26 +++-----
 drivers/net/wireless/cw1200/fwio.c                     |   2 +-
 drivers/net/wireless/cw1200/hwbus.h                    |   1 -
 drivers/net/wireless/cw1200/hwio.c                     |  15 -----
 drivers/net/wireless/mwifiex/11n_aggr.c                |   3 +-
 drivers/net/wireless/mwifiex/11n_aggr.h                |   2 +-
 drivers/net/wireless/mwifiex/cmdevt.c                  |   5 +-
 drivers/net/wireless/mwifiex/usb.c                     |   7 ---
 drivers/net/wireless/mwifiex/wmm.c                     |   3 +-
 drivers/net/wireless/p54/p54usb.c                      |   2 +
 drivers/net/wireless/rtlwifi/wifi.h                    |   2 +-
 drivers/net/xen-netback/xenbus.c                       | 148 +++++++++++++++++++++++++++++++++++---------
 include/linux/bcma/bcma_driver_pci.h                   |   1 +
 include/linux/kernel.h                                 |  11 ++++
 include/linux/skbuff.h                                 |   2 +-
 include/linux/usb/usbnet.h                             |   1 +
 include/net/addrconf.h                                 |   4 ++
 include/net/bluetooth/hci.h                            |   1 +
 include/net/ip_vs.h                                    |   9 +--
 include/net/mrp.h                                      |   1 +
 include/net/net_namespace.h                            |   1 +
 include/net/netfilter/nf_conntrack_synproxy.h          |   2 +-
 include/net/secure_seq.h                               |   1 -
 include/net/sock.h                                     |   5 ++
 lib/hexdump.c                                          |   2 +
 net/802/mrp.c                                          |  27 ++++++++
 net/bluetooth/hci_core.c                               |  26 ++++++--
 net/bluetooth/hci_event.c                              |   6 +-
 net/bluetooth/l2cap_core.c                             |   7 +++
 net/bluetooth/rfcomm/tty.c                             |  35 +----------
 net/core/dev.c                                         |  49 ++++++++++++++-
 net/core/flow_dissector.c                              |   4 +-
 net/core/secure_seq.c                                  |  27 +++++++-
 net/ipv4/af_inet.c                                     |   4 +-
 net/ipv4/igmp.c                                        |   4 +-
 net/ipv4/ip_tunnel.c                                   |  22 +++----
 net/ipv4/ip_tunnel_core.c                              |   2 +-
 net/ipv4/netfilter/ipt_SYNPROXY.c                      |  10 ++-
 net/ipv4/raw.c                                         |   4 +-
 net/ipv4/tcp_output.c                                  |  17 +++--
 net/ipv4/udp.c                                         |   2 +-
 net/ipv6/addrconf.c                                    |  79 ++++++++++++-----------
 net/ipv6/ip6_gre.c                                     |   4 +-
 net/ipv6/ip6_output.c                                  |  53 +++++++---------
 net/ipv6/ip6_tunnel.c                                  |   3 +-
 net/ipv6/mcast.c                                       |   6 +-
 net/ipv6/netfilter/ip6t_SYNPROXY.c                     |  10 ++-
 net/ipv6/raw.c                                         |   4 +-
 net/ipv6/sit.c                                         |  86 +++++++++++++++++++++-----
 net/ipv6/udp.c                                         |   4 +-
 net/lapb/lapb_timer.c                                  |   1 +
 net/netfilter/ipvs/ip_vs_core.c                        |  12 +++-
 net/netfilter/ipvs/ip_vs_ctl.c                         |  86 +++++++++++---------------
 net/netfilter/ipvs/ip_vs_est.c                         |   4 +-
 net/netfilter/ipvs/ip_vs_lblc.c                        |  72 ++++++++++-----------
 net/netfilter/ipvs/ip_vs_lblcr.c                       |  62 ++++++++-----------
 net/netfilter/ipvs/ip_vs_nq.c                          |   8 +--
 net/netfilter/ipvs/ip_vs_sed.c                         |   8 +--
 net/netfilter/ipvs/ip_vs_wlc.c                         |   6 +-
 net/netfilter/nf_synproxy_core.c                       |  12 ++--
 net/sched/sch_fq.c                                     | 102 ++++++++++++++++++------------
 107 files changed, 1301 insertions(+), 845 deletions(-)
