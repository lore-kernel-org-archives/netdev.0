From: David Miller <davem@davemloft.net>
Subject: [GIT] Networking
Date: Tue, 17 May 2016 15:11:13 -0400 (EDT)
Message-ID: <20160517.151113.367799295750703003.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49741 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750913AbcEQTLT convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 May 2016 15:11:19 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Highlights:

1) Support SPI based w5100 devices, from Akinobu Mita.

2) Partial Segmentation Offload, from Alexander Duyck.

3) Add GMAC4 support to stmmac driver, from Alexandre TORGUE.

4) Allow cls_flower stats offload, from Amir Vadai.

5) Implement bpf blinding, from Daniel Borkmann.

6) Optimize _ASYNC_ bit twiddling on sockets, unless the socket is
   actually using FASYNC these atomics are superfluous.  From Eric
   Dumazet.

7) Run TCP more preemptibly, also from Eric Dumazet.

8) Support LED blinking, EEPROM dumps, and rxvlan offloading in mlx5e
   driver, from Gal Pressman.

9) Allow creating ppp devices via rtnetlink, from Guillaume Nault.

10) Improve BPF usage documentation, from Jesper Dangaard Brouer.

11) Support tunneling offloads in qed, from Manish Chopra.

12) aRFS offloading in mlx5e, from Maor Gottlieb.

13) Add RFS and RPS support to SCTP protocol, from Marcelo Ricardo
    Leitner.

14) Add MSG_EOR support to TCP, this allows controlling packet
    coalescing on application record boundaries for more accurate
    socket timestamp sampling.  From Martin KaFai Lau.

15) Fix alignment of 64-bit netlink attributes across the board, from
    Nicolas Dichtel.

16) Per-vlan stats in bridging, from Nikolay Aleksandrov.

17) Several conversions of drivers to ethtool ksettings, from Philippe
    Reynes.

18) Checksum neutral ILA in ipv6, from Tom Herbert.

19) Factorize all of the various marvell dsa drivers into one, from
    Vivien Didelot

20) Add VF support to qed driver, from Yuval Mintz.

Please pull, thanks a lot!

The following changes since commit 272911b889f47aa5bc3e004804fc2382f0ac=
6ce6:

  Merge git://git.kernel.org/pub/scm/linux/kernel/git/davem/net (2016-0=
5-14 14:15:06 -0700)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/davem/net-next.git=20

for you to fetch changes up to 917fa5353da05e8a0045b8acacba8d50400d5b12=
:

  Revert "phy dp83867: Fix compilation with CONFIG_OF_MDIO=3Dm" (2016-0=
5-17 14:49:55 -0400)

----------------------------------------------------------------
Aaron Conole (1):
      net/core/dev: Warn on a too-short GRO frame

Ajit Khaparde (2):
      bnxt_en: Add Support for ETHTOOL_GMODULEINFO and ETHTOOL_GMODULEE=
EPRO
      bnxt_en: Report PCIe link speed and width during driver load

Akeem G Abodunrin (2):
      i40e: Move HW flush
      i40e: Correct UDP packet header for non_tunnel-ipv6

Akinobu Mita (10):
      net: w5100: move mmiowb into register access callbacks
      net: w5100: add ability to support other bus interface
      net: w5100: enable to support sleepable register access interface
      net: w5100: support SPI interface mode
      net: w5100: support W5200
      net: w5100: support W5500
      net: w5100: remove unused is_w5200()
      net: w5100: fix MAC filtering for W5500
      net: w5100: increase TX timeout period
      net: w5100-spi: add support to specify MAC address by device tree

Akira Moroo (1):
      cfg80211: fix kernel-doc struct name

Al Viro (1):
      [net] drop 'size' argument of sock_recvmsg()

Alan Cox (1):
      i40evf: remove dead code

Alexander Aring (13):
      6lowpan: iphc: fix handling of link-local compression
      ieee802154: cleanups for ieee802154.h
      ieee802154: add short address helpers
      nl802154: avoid address change while running lowpan
      ieee802154: 6lowpan: fix short addr hash
      6lowpan: change naming for lowpan private data
      6lowpan: move lowpan_802154_dev to 6lowpan
      6lowpan: iphc: rename add lowpan prefix
      6lowpan: iphc: remove unnecessary zero data
      6lowpan: move eui64 uncompress function
      6lowpan: add lowpan_is_ll function
      6lowpan: move mac802154 header
      at86rf230: increase sleep to off timings

Alexander Duyck (44):
      ixgbe: Do not allow PF to add VLVF entry unless it actually needs=
 it
      ixgbe: Avoid adding VLAN 0 twice to VLVF and VFTA
      ixgbe: Add support for generic Tx checksums
      ixgbevf: Add support for generic Tx checksums
      ixgbe: Add support for toggling VLAN filtering flag via ethtool
      i40e/i40evf: Allow up to 12K bytes of data per Tx descriptor inst=
ead of 8K
      i40e/i40evf: Fix handling of boolean logic in polling routines
      i40e/i40evf: Add support for bulk free in Tx cleanup
      i40e/i40evf: Fix TSO checksum pseudo-header adjustment
      igb: Fix sparse warning about passing __beXX into leXX_to_cpup
      igb: Add support for bulk Tx cleanup & cleanup boolean logic
      ixgbe/ixgbevf: Add support for bulk free in Tx cleanup & cleanup =
boolean logic
      ethtool: Add support for toggling any of the GSO offloads
      GSO: Add GSO type for fixed IPv4 ID
      GRO: Add support for TCP with fixed IPv4 ID field, limit tunnel I=
P ID values
      GSO: Support partial segmentation offload
      Documentation: Add documentation for TSO and GSO features
      ip_tunnel_core: iptunnel_handle_offloads returns int and doesn't =
free skb
      ip6gretap: Fix MTU to allow for Ethernet header
      ip6gre: Add support for basic offloads offloads excluding GSO
      GRE: Add support for GRO/GSO of IPv6 GRE traffic
      ip6gre: Add support for GSO
      netdev_features: Add NETIF_F_TSO_MANGLEID to NETIF_F_ALL_TSO
      fm10k: Add support for bulk Tx cleanup & cleanup boolean logic
      netdev_features: Fold NETIF_F_ALL_TSO into NETIF_F_GSO_SOFTWARE
      veth: Update features to include all tunnel GSO types
      net: Add support for IP ID mangling TSO in cases that require enc=
apsulation
      ixgbe/ixgbevf: Add support for GSO partial
      ixgbevf: Move API negotiation function into mac_ops
      i40e/i40evf: Clean up feature flags
      i40e/i40evf: Add support for IPIP and SIT offloads
      i40e/i40evf: Add support for GSO partial with UDP_TUNNEL_CSUM and=
 GRE_CSUM
      ixgbevf: Use mac_ops instead of trying to identify NIC type
      gso: Do not perform partial GSO if number of partial segments is =
1 or less
      gso: Only allow GSO_PARTIAL if we can checksum the inner protocol
      net: Fix netdev_fix_features so that TSO_MANGLEID is only availab=
le with TSO
      net/mlx4_en: Add support for UDP tunnel segmentation with outer c=
hecksum offload
      net/mlx4_en: Add support for inner IPv6 checksum offloads and TSO
      net/mlx5e: Add support for UDP tunnel segmentation with outer che=
cksum offload
      net/mlx5e: Fix IPv6 tunnel checksum offload
      bnxt: Add support for segmentation of tunnels with outer checksum=
s
      udp: Resolve NULL pointer dereference over flow-based vxlan devic=
e
      igb/igbvf: Add support for GSO partial
      ixgbe: Fix VLAN features error

Alexander Gerasiov (1):
      can: sja1000: Fix error location forwarding

Alexander Graf (2):
      phy dp83867: Fix compilation with CONFIG_OF_MDIO=3Dm
      phy dp83867: Make rgmii parameters optional

Alexandre Macabies (3):
      ieee802154: add security bit check function
      mrf24j40: fix security-enabled processing on inbound frames
      mrf24j40: apply the security-enabled bit on secured outbound fram=
es

Alexandre TORGUE (15):
      stmmac: rework get_hw_feature function
      stmmac: rework the routines to show the ring status
      stmmac: rework synopsys id read, moved to dwmac setup
      stmmac: add descriptors function for GMAC 4.xx
      stmmac: add GMAC4 DMA/CORE Header File
      stmmac: add DMA support for GMAC 4.xx
      stmmac: add GMAC4 core support
      stmmac: enhance mmc counter management
      stmmac: add new DT platform entries for GMAC4
      stmmac: support new GMAC4
      Documentation: networking: update stmmac
      stmmac: update version to Jan_2016
      stmmac: update MAINTAINERS
      net: ethernet: stmmac: GMAC4.xx: Fix TX descriptor preparation
      net: ethernet: stmmac: update MDIO support for GMAC4

Alexei Starovoitov (19):
      perf: optimize perf_fetch_caller_regs
      perf: remove unused __addr variable
      perf: split perf_trace_buf_prepare into alloc and update parts
      perf, bpf: allow bpf programs attach to tracepoints
      bpf: register BPF_PROG_TYPE_TRACEPOINT program type
      bpf: support bpf_get_stackid() and bpf_perf_event_output() in tra=
cepoint programs
      bpf: sanitize bpf tracepoint access
      samples/bpf: add tracepoint support to bpf loader
      samples/bpf: tracepoint example
      samples/bpf: add tracepoint vs kprobe performance tests
      bpf: simplify verifier register state assignments
      perf, bpf: minimize the size of perf_trace_() tracepoint handler
      bpf: cleanup verifier code
      bpf: direct packet access
      bpf: improve verifier state equivalence
      bpf: wire in data and data_end for cls_act_bpf
      bpf: add documentation for 'direct packet access'
      samples/bpf: add 'pointer to packet' tests
      samples/bpf: add verifier tests

Amir Vadai (8):
      net/sched: Enable netdev drivers to update statistics of offloade=
d actions
      net/sched: act_gact: Update statistics when offloaded to hardware
      net/sched: cls_flower: Hardware offloaded filters statistics supp=
ort
      net/mlx5_core: Use a macro in mlx5_command_str()
      net/mlx5_core: Firmware commands to support flow counters
      net/mlx5_core: Introduce flow steering destination of type counte=
r
      net/mlx5_core: Flow counters infrastructure
      net/mlx5e: Hardware offloaded flower filter statistics support

Amitkumar Karwar (9):
      mwifiex: fix Tx timeout issue during suspend test
      mwifiex: advertise low priority scan feature
      mwifiex: missing break statement
      mwifiex: fix incorrect ht capability problem
      mwifiex: fix coding style
      mwifiex: report wowlan wakeup reasons correctly
      mwifiex: avoid querying wakeup reason when wowlan is disabled
      mwifiex: disable channel filtering feature in firmware
      mwifiex: increase dwell time for active scan

Amitoj Kaur Chawla (2):
      qlge: Replace create_singlethread_workqueue with alloc_ordered_wo=
rkqueue
      can: mcp251x: Replace create_freezable_workqueue with alloc_workq=
ueue

Amritha Nambiar (2):
      ixgbe: Extend cls_u32 offload to support UDP headers
      ixgbe: Match on multiple headers for cls_u32 offloads

Andreas Fenkart (7):
      mwifiex: scan: simplify dereference of bss_desc fields
      mwifiex: scan: factor out has_ieee_hdr/has_vendor_hdr
      mwifiex: scan: simplify ternary operators using gnu extension
      mwifiex: scan: factor out dbg_security_flags
      mwifiex: scan: replace pointer arithmetic with array access
      mwifiex: factor out mwifiex_cancel_pending_scan_cmd
      mwifiex: make mwifiex_insert_cmd_to_free_q local static

Andreas Gr=F6ger (1):
      can: janz-ican3: error handling for CAL/CANopen firmware

Andrew Lunn (19):
      net: mdio: Fix lockdep falls positive splat
      net: dsa: Pass the dsa device to the switch drivers
      net: dsa: Have the switch driver allocate there own private memor=
y
      net: dsa: Remove allocation of driver private memory
      net: dsa: Keep the mii bus and address in the private structure
      net: dsa: Rename DSA probe function.
      dsa: Rename phys_port_mask to enabled_port_mask
      dsa: mv88e6xxx: Use bus in mv88e6xxx_lookup_name()
      dsa: mv88e6xxx: Kill the REG_READ and REG_WRITE macros
      net: dsa: mv88e6xxx: replace ds with ps where possible
      batman-adv: NETIF_F_NETNS_LOCAL feature to prevent netns moves
      batman-adv: Create batman soft interfaces within correct netns.
      dsa: mv88e6xxx: Initialise the mutex as soon as it is created
      dsa: mv88e6xxx: Rename probe function to fit the normal pattern
      dsa: Add mdio device support to Marvell switches
      dsa: Move gpio reset into switch driver
      dsa: Remove master_dev from switch structure
      dsa: Rename switch chip data to cd
      dsa: mv88e6xxx: Handle eeprom-length property

Andy Gross (1):
      Merge tag 'qcom-soc-for-4.7' into soc-for-4.7-p2

Andy Shevchenko (1):
      ISDN: eicon: replace custom hex_asc_lo() / hex_pack_byte()

Anilkumar Kolli (1):
      ath10k: fix debugfs pktlog_filter write

Anjali Singhai Jain (9):
      i40e: Enable Geneve offload for FW API ver > 1.4 for XL710/X710 d=
evices
      i40e: Patch to support trusted VF
      i40e: Add VF promiscuous mode driver support
      i40evf: Add driver support for promiscuous mode
      i40e: Change the default for VFs to be not privileged
      i40e: Limit the number of MAC and VLAN addresses that can be adde=
d for VFs
      i40e: Prevent falling to promiscuous if the VF is not trusted
      i40e: Add allmulti support for the VF
      i40e: Add vf-true-promisc-support priv flag

Antonio Quartulli (3):
      batman-adv: use static string for table headers
      batman-adv: fix wrong names in kerneldoc
      batman-adv: use batadv_compare_eth when possible

Ard Biesheuvel (1):
      r8169: default to 64-bit DMA on recent PCIe chips

Arend van Spriel (5):
      nl80211: add feature for BSS selection support
      brcmfmac: cleanup ampdu-rx host reorder code
      brcmfmac: revise handling events in receive path
      brcmfmac: create common function for handling brcmf_proto_hdrpull=
()
      brcmfmac: add support for nl80211 BSS_SELECT feature

Arika Chen (1):
      Revert "igb: Fix a deadlock in igb_sriov_reinit"

Arnd Bergmann (9):
      bpf: avoid warning for wrong pointer cast
      net: w5100: don't build spi driver without w5100
      rtl8xxxu: hide unused tables
      ixgbe: use msleep for long delays
      net/mlx5e: avoid stack overflow in mlx5e_open_channels
      gre6: add Kconfig dependency for NET_IPGRE_DEMUX
      i40e: fix misleading indentation
      netfilter: conntrack: remove uninitialized shadow variable
      net: qrtr: fix build problems

Ashish Shah (1):
      i40e: set context to use VSI RSS LUT for SR-IOV

Avinash Dayanand (2):
      i40e: Fix for supported link modes in 10GBaseT PHY's
      i40e/i40evf: Bump patch from 1.5.1 to 1.5.2

Aviya Erenfeld (2):
      iwlwifi: mvm: add LQM vendor command and notification
      iwlwifi: add a debugfs hook for LQM

Avraham Stern (1):
      ieee80211: support parsing Fine Timing Measurement action frame

Ayala Beker (3):
      iwlwifi: mvm: update GSCAN capabilities
      cfg80211: allow userspace to specify client P2P PS support
      mac80211: track and tell driver about GO client P2P PS abilities

Babu Moger (1):
      ixgbevf: Change the relaxed order settings in VF driver for sparc

Ben Greear (1):
      ath10k: Document alloc_frag_desc_for_data_pkt config option.

Bimmy Pujari (1):
      i40e: Bump version from 1.5.10 to 1.5.16

Bjorn Andersson (13):
      soc: qcom: smem_state: Add stubs for disabled smem_state
      soc: qcom: smd: Introduce callback setter
      soc: qcom: smd: Split discovery and state change work
      soc: qcom: smd: Refactor channel open and close handling
      soc: qcom: smd: Support multiple channels per sdev
      soc: qcom: smd: Support opening additional channels
      soc: qcom: smem: Use write-combine remap for SMEM
      soc: qcom: smd: Make callback pass channel reference
      wcn36xx: Delete BSS before idling link
      wcn36xx: Correct remove bss key response encoding
      wcn36xx: Fill in capability list
      soc: qcom: smd: Introduce compile stubs
      Merge tag 'qcom-soc-for-4.7-2' into net-next

Bob Copeland (17):
      ath5k: fix incorrect indentation
      ath9k: fix a misleading indentation
      ath9k_htc: fix up indents with spaces
      mac80211: mesh: move path tables into if_mesh
      mac80211: mesh: don't hash sdata in mpath tables
      mac80211: mesh: factor out common mesh path allocation code
      mac80211: mesh: embed known gates list in struct mesh_path
      rhashtable: accept GFP flags in rhashtable_walk_init
      mac80211: mesh: convert path table to rhashtable
      mac80211: mesh: fix crash in mesh_path_timer
      mac80211: mesh: handle failed alloc for rmc cache
      mac80211: mesh: use hlist for rmc cache
      mac80211: mesh: embed gates hlist head directly
      mac80211: mesh: reorder structure members
      mac80211: mesh: fix mesh path kerneldoc
      mac80211: mesh: fix cleanup for mesh pathtable
      mac80211: mesh: flush paths outside of plink lock

Brian Walsh (1):
      e1000e: Cleanup consistency in ret_val variable usage

Bruce Allan (6):
      fm10k: Move constants to the right of binary operators
      fm10k: cleanup remaining right-bit-shifted 1
      fm10k: demote BUG_ON() to WARN_ON() where appropriate
      fm10k: cleanup SPACE_BEFORE_TAB checkpatch warning
      fm10k: use ether_addr_copy to copy MAC address
      fm10k: prevent possibly uninitialized variable

Carolyn Wyborny (1):
      i40evf: RSS Hash Option parameters

Catherine Sullivan (7):
      i40e/i40evf: Remove I40E_MAX_USER_PRIORITY define
      i40e/i40evf: Bump patch from 1.4.25 to 1.5.1
      i40e: Add new device ID for X722
      i40evf: Fix get_rss_aq
      i40e: Fix uninitialized variable
      i40e: Update device ids for X722
      i40e: Refactor ethtool get_settings

Chaya Rachel Ivgi (2):
      iwlwifi: mvm: handle async temperature notification with unlocked=
 mutex
      iwlwifi: mvm: remove uneeded D0I3 checking

Christian Lamparter (1):
      drivers: net: emac: add Atheros AR8035 phy initialization code

Christophe Ricard (20):
      nfc: st21nfca: Fix static checker warning
      nfc: st-nci: i2c: Change ST_NCI_GPIO_NAME_RESET to match DT
      nfc: st-nci: spi: Change ST_NCI_GPIO_NAME_RESET to match DT
      nfc: st21nfca: i2c: Change ST21NFCA_GPIO_NAME_RESET to match DT
      nfc: st21nfca: set is_ese_present and is_uicc_present properly
      nfc: st-nci: set is_ese_present and is_uicc_present properly
      nfc: st21nfca: Simplify white list building
      nfc: st-nci: Simplify white list building
      nfc: st-nci: A APDU_READER_GATE pipe is unexpected on a UICC
      nfc: st21nfca: A APDU_READER_GATE pipe is unexpected on a UICC
      NFC: st21nfca: Drop two useless checks in ACPI probe path
      NFC: st-nci: i2c: Drop two useless checks in ACPI probe path
      NFC: st-nci: spi: Drop two useless checks in ACPI probe path
      nfc: st-nci: Remove redundant ST_NCI_HCI_HOST_ID_ESE from st-nci.=
h
      nfc: st21nfca: Remove duplicated ST21NFCA_ESE_HOST_ID from se.c
      nfc: nci: Fix nci_core_conn_create to allowing empty destination
      nfc: nci: Fix nci_core_conn_close
      nfc: nci: Add an additional parameter to identify a connection id
      nfc: nci: Add nci_nfcc_loopback to the nci core
      nfc: st-nci: Move loopback usage from HCI to NCI

Chun-Yeow Yeoh (1):
      rt2800lib: enable MFP if hw crypt is disabled

Colin Ian King (6):
      iwlwifi: pcie: remove duplicate assignment of variable isr_stats
      wl12xx: remove redundant null check on wl->scan.ssid
      brcmfmac: sdio: remove unused variable retry_limit
      mwifiex: ie_list is an array, so no need to check if NULL
      rtl8xxxu: fix uninitialized return value in ret
      ath9k: remove duplicate assignment of variable ah

Colin King (1):
      i40e: remove redundant check on vsi->active_vlans

Courtney Cavin (1):
      net: Add Qualcomm IPC router

Craig Gallek (1):
      soreuseport: Resolve merge conflict for v4/v6 ordering fix

Dan Carpenter (13):
      brcmfmac: uninitialized "ret" variable
      udp: fix if statement in SIOCINQ ioctl
      ath10k: add some sanity checks to peer_map_event() functions
      geneve: testing the wrong variable in geneve6_build_skb()
      Bluetooth: ath3k: Silence uninitialized variable warning
      mwifiex: missing error code on allocation failure
      mwifiex: fix loop timeout in mwifiex_prog_fw_w_helper()
      brcmfmac: testing the wrong variable in brcmf_rx_hdrpull()
      tipc: remove an unnecessary NULL check
      usbnet/smsc75xx: silence uninitialized variable warning
      usbnet: smsc95xx: silence an uninitialized variable warning
      i40e: fix an uninitialized variable bug
      qed: Remove a stray tab

Daniel Borkmann (21):
      bpf, verifier: further improve search pruning
      ipv6, token: allow for clearing the current device token
      bpf, verifier: add bpf_call_arg_meta for passing meta data
      bpf, verifier: add ARG_PTR_TO_RAW_STACK type
      bpf: convert relevant helper args to ARG_PTR_TO_RAW_STACK
      bpf, samples: don't zero data when not needed
      bpf, samples: add test cases for raw stack
      bpf, trace: add BPF_F_CURRENT_CPU flag for bpf_perf_event_output
      bpf: add event output helper for notifications/sampling/logging
      bpf: minor cleanups in ebpf code
      bpf: move bpf_jit_enable declaration
      bpf: split HAVE_BPF_JIT into cBPF and eBPF variant
      bpf, x86/arm64: remove useless checks on prog
      bpf: add bpf_patch_insn_single helper
      bpf: prepare bpf_int_jit_compile/bpf_prog_select_runtime apis
      bpf: add generic constant blinding for use in jits
      bpf, x86: add support for constant blinding
      bpf, arm64: add support for constant blinding
      bpf, s390: add support for constant blinding
      net: also make sch_handle_egress() drop monitor ready
      bpf, doc: fix typo on bpf_asm descriptions

Daode Huang (2):
      net: hns: set debug port irq index to 0
      net: hns: sort the header file by alphabetical order

David Ahern (8):
      net: ipv4: Consider failed nexthops in multipath routes
      net: ipv6: Use passed in table for nexthop lookups
      net: vrf: Create FIB tables on link create
      net: l3mdev: Move get_saddr and rt6_dst
      net: l3mdev: Allow send on enslaved interface
      net: l3mdev: Add hook in ip and ipv6
      net: original ingress device index in PKTINFO
      net: vrf: protect changes to private data with rcu

David Howells (9):
      afs: Wait for outstanding async calls before closing rxrpc socket
      rxrpc: Disable a debugging statement that has been left enabled.
      rxrpc: Move some miscellaneous bits out into their own file
      rxrpc: Static arrays of strings should be const char *const[]
      rxrpc: Differentiate local and remote abort codes in structs
      rxrpc: Don't pass gfp around in incoming call handling functions
      rxrpc: Don't assume transport address family and size when using =
it
      rxrpc: Absorb the rxkad security module
      rxrpc: Create a null security type and get rid of conditional cal=
ls

David M=FCller (1):
      rtlwifi: rtl8821ae: Make sure loop counter is signed on all archi=
tectures

David S. Miller (154):
      Merge branch 'stmmac-GMAC4.x'
      Merge branch 'cmsg_timestamp'
      Merge branch 'macb-coding-style'
      Merge branch 'mv88e6131-hw-bridging-6185'
      Merge branch '10GbE' of git://git.kernel.org/.../jkirsher/next-qu=
eue
      Merge branch 'tcp-udp-misc'
      Merge branch 'mlxsw-next'
      Merge branch '100GbE' of git://git.kernel.org/.../jkirsher/next-q=
ueue
      Merge branch 'bnxt_en-next'
      Merge branch '40GbE' of git://git.kernel.org/.../jkirsher/next-qu=
eue
      Merge branch 'udp-peek'
      Merge branch 'bcmgenet-cleanups'
      Merge branch 'vxlan-gpe'
      Merge branch '40GbE' of git://git.kernel.org/.../jkirsher/next-qu=
eue
      Merge branch 'mlxsw-dcb'
      Merge branch '40GbE' of git://git.kernel.org/.../jkirsher/next-qu=
eue
      Merge branch '1GbE' of git://git.kernel.org/.../jkirsher/next-que=
ue
      Merge branch 'sock-lockdep-tightening'
      Merge branch 'gro-in-udp'
      Merge branch 'tipc-next'
      net: Fix build failure due to lockdep_sock_is_held().
      Merge branch 'bpf-tracepoints'
      Merge branch '10GbE' of git://git.kernel.org/.../jkirsher/next-qu=
eue
      Merge branch 'nfp-mtu-buffer-reconfig'
      Merge branch 'mlxsw-next'
      Merge tag 'mac80211-next-for-davem-2016-04-06' of git://git.kerne=
l.org/.../jberg/mac80211-next
      Merge branch 'dsa-voidify-ops'
      Merge git://git.kernel.org/.../davem/net
      Merge tag 'wireless-drivers-next-for-davem-2016-04-11' of git://g=
it.kernel.org/.../kvalo/wireless-drivers-next
      Merge branch 'bnxt_en-next'
      Merge branch 'cpsw-host_port'
      Merge branch 'udp-pull'
      Merge branch 'rprpc-2nd-rewrite-part-1'
      Merge branch 'for-upstream' of git://git.kernel.org/.../bluetooth=
/bluetooth-next
      Merge git://git.kernel.org/.../pablo/nf-next
      Merge branch 'mediatek-stress-test-fixes'
      Merge tag 'mac80211-next-for-davem-2016-04-13' of git://git.kerne=
l.org/.../jberg/mac80211-next
      Merge branch 'dsa-refactoring-set-1'
      Merge branch 'udp-hdrs-fixes'
      Merge branch 'bridge-sysfs-rtnl-notifications'
      Merge branch 'sctp-delayed-wakeups'
      Merge branch 'for-davem' of git://git.kernel.org/.../viro/vfs
      Merge branch 'qed-ethtool-rss'
      Merge branch 'mlxsw-devlink-shared-buffers'
      Merge branch 'gro-fixed-id-gso-partial'
      Merge branch 'bpf-ARG_PTR_TO_RAW_STACK'
      Merge branch 'mlxsw-next'
      Merge branch 'tipc-link-setup-improvements'
      Merge branch 'tcp-synflood-perf'
      Merge branch 'qed-tunneling-offload'
      Merge branch 'mlx5_ifc-updates'
      Merge branch 'sctp-diag'
      Merge branch 'w5100-spi-and-w5200-support'
      Merge branch 'ipv6-gre-offloads'
      Merge branch 'fjes-next'
      Merge branch 'IFF_NO_QUEUE-followups'
      Merge branch 'nfp-next'
      Merge branch 'dsa-mv88e6xxx-switch-factorization'
      Merge branch 'fec-ksettings'
      net: Align IFLA_STATS64 attributes properly on architectures that=
 need it.
      net: Add helpers for 64-bit aligning netlink attributes.
      Merge branch 'bpf_event_output'
      net: nla_align_64bit() needs to test the right pointer.
      Merge branch '100GbE' of git://git.kernel.org/.../jkirsher/next-q=
ueue
      Merge branch 'nlattr_align'
      Merge branch 'bcmsysport-napi-updates'
      Merge branch 'mlx5-next'
      Merge branch 'geneve-vxlan-deps'
      Merge git://git.kernel.org/.../davem/net
      Merge branch 'nla_align-more'
      Merge git://git.kernel.org/.../pablo/nf-next
      Merge branch 'tcp-tcstamp_ack-frag-coalesce'
      Merge branch 'nla_align-set-2'
      Merge branch '10GbE' of git://git.kernel.org/.../jkirsher/next-qu=
eue
      Merge branch 'qed-next'
      Merge branch 'reusable-codel'
      Merge branch 'pskb_extract'
      Merge branch 'hns-debug-dsaf'
      Merge branch 'ila-csum-neutral'
      Merge branch 'nla_align-set-4'
      Merge branch 'for-upstream' of git://git.kernel.org/.../bluetooth=
/bluetooth-next
      Merge branch 'cxgb4-next'
      Merge branch 'qed-bandwidth-config'
      Merge branch 'get_phy_device-retval'
      Merge branch 'netdev_tx_locked-removal'
      infiniband: nes: Kill unused variable in nes_netdev_start_xmit()
      Merge branch 'mlx5-next'
      Merge branch 'sh_eth-next'
      Merge git://git.kernel.org/.../davem/net
      Merge branch '40GbE' of git://git.kernel.org/.../jkirsher/next-qu=
eue
      Merge branch 'snmp-stats-update'
      Merge branch 'socket-space-optimizations'
      Merge branch 'tcp-redundant-checks'
      Merge branch 'tcp-eor'
      Merge branch 'hns-props'
      Merge branch 'cxgb4-mbox-cmd-logging'
      Merge branch 'samples-bpf-user-experience'
      Merge branch 'ppp-rtnetlink'
      Merge branch 'enc28j60-small-improvements'
      Merge branch 'mlx5-aRFS'
      Merge branch '40GbE' of git://git.kernel.org/.../jkirsher/next-qu=
eue
      Merge branch 'qed-selftests'
      Merge branch 'xgene-channel-number'
      Merge branch 'tcp-preempt'
      Merge branch 'ipv6-tunnel-cleanups'
      Merge branch 'bridge-per-vlan-stats'
      Merge tag 'wireless-drivers-next-for-davem-2016-05-02' of git://g=
it.kernel.org/.../kvalo/wireless-drivers-next
      Merge branch 'stmmac-dwmac-socfpga-cleanup'
      Merge branch 'tipc-next'
      Merge git://git.kernel.org/.../davem/net
      Merge branch 'tunnel-features-and-gso-partial'
      Merge branch 'cxgb4-mbox'
      Merge branch 'mlx5-sriov-updates'
      Merge branch 'gre-teb'
      Merge branch 'kill_trans_start'
      Merge tag 'batman-adv-for-davem' of git://git.open-mesh.org/linux=
-merge
      Merge branch '10GbE' of git://git.kernel.org/.../jkirsher/next-qu=
eue
      Merge branch '40GbE' of git://git.kernel.org/.../jkirsher/next-qu=
eue
      Merge branch 'bpf-direct-pkt-access'
      Merge branch 'for-upstream' of git://git.kernel.org/.../bluetooth=
/bluetooth-next
      Merge branch 'sh_eth-sw-reset'
      Merge branch 'dsa-mv88e6xxx-monolithic'
      Merge git://git.kernel.org/.../pablo/nf-next
      Merge git://git.kernel.org/.../davem/net
      mlx5: Fix merge errors.
      Merge branch 'l3mdev-send-enslaved'
      Merge branch 'ip6-tunnel-tx-fixes'
      Merge tag 'linux-can-next-for-4.7-20160509' of git://git.kernel.o=
rg/.../mkl/linux-can-next
      Merge branch 'phy_ksettings'
      Merge tag 'batman-adv-for-davem' of git://git.open-mesh.org/linux=
-merge
      Merge branch 'vrf-pktinfo'
      Merge branch 'more-dsa-probing'
      Merge branch 'mlx5-next'
      Merge tag 'nfc-next-4.7-1' of git://git.kernel.org/.../sameo/nfc-=
next
      Merge branch 'qed-sriov'
      Merge tag 'mac80211-next-for-davem-2016-05-12' of git://git.kerne=
l.org/.../jberg/mac80211-next
      Merge branch '1GbE' of git://git.kernel.org/.../jkirsher/next-que=
ue
      Merge git://git.kernel.org/.../davem/net
      Merge branch 'bnxt_en-next'
      Merge branch '40GbE' of git://git.kernel.org/.../jkirsher/next-qu=
eue
      Merge branch 'hv_netvsc-races'
      Merge branch 'cls_u32_hw_sw'
      Merge branch 'xen-netback-control-ring'
      Merge branch 'pxa168_eth-perf'
      Merge branch 'tc_flower_offload'
      Merge branch 'bpf-blinding'
      Merge branch 'lxt-cleanups'
      Merge branch 'w5100-small-changes'
      Merge branch 'for-upstream' of git://git.kernel.org/.../bluetooth=
/bluetooth-next
      Merge branch 'qed-next'
      Merge branch '10GbE' of git://git.kernel.org/.../jkirsher/next-qu=
eue
      Merge tag 'net-next-qcom-soc-4.7-2-merge' of git://github.com/and=
ersson/kernel
      Revert "phy dp83867: Make rgmii parameters optional"
      Revert "phy dp83867: Fix compilation with CONFIG_OF_MDIO=3Dm"

David Spinadel (2):
      iwlwifi: mvm: set aux STA ID in scan config
      mac80211: remove disconnected APs from BSS table

Dedy Lansky (1):
      wil6210: p2p initial support

Deepthi Kavalur (1):
      i40e: Inserting a HW capability display info

Denys Vlasenko (5):
      net: force inlining of netif_tx_start/stop_queue, sock_hold, __so=
ck_put
      drivers/net/ethernet/jme.c: Deinline jme_reset_mac_processor, sav=
e 2816 bytes
      e1000e: e1000e_cyclecounter_read(): incvalue is 32 bits, not 64
      e1000e: e1000e_cyclecounter_read(): fix er32(SYSTIML) overflow ch=
eck
      e1000e: e1000e_cyclecounter_read(): do overflow check only if nee=
ded

Dinh Nguyen (1):
      stmmac: socfpga: remove extra call to socfpga_dwmac_setup

Don Skidmore (2):
      ixgbe: Place SWFW semaphore in known valid state at probe
      ixgbe: Add work around for empty SFP+ cage crosstalk

Doron Shikmoni (1):
      igb: Garbled output for "ethtool -m"

Emil Tantilov (9):
      ixgbevf: use bit operations for setting and checking resets
      ixgbe: consolidate the configuration of spoof checking
      ixgbe: set VLAN spoof checking unconditionally
      ixgbe: fix default mac->ops.setup_link for X550EM
      ixgbevf: refactor ethtool stats handling
      ixgbevf: add support for per-queue ethtool stats
      ixgbe: add WoL support for some 82599 subdevice IDs
      ixgbe: check EEPROM for WOL support for X540 and above
      ixgbe: use correct mask when enabling sriov

Emmanuel Grumbach (8):
      iwlwifi: pcie: print error value as signed int
      iwlwifi: mvm: modify the max SP to infinite
      iwlwifi: add missing mutex_destroy statements
      iwlwifi: make uapsd_disable module param a bitmap
      iwlwifi: remove IWLWIFI_UAPSD Kconfig
      iwlwifi: remove IWL_*_UCODE_API_OK
      mac80211: Set global RRM capability
      cfg80211: allow finding vendor with OUI without specifying the OU=
I type

Eran Ben Elisha (1):
      net/mlx5e: Add support for RXALL netdev feature

Eric Dumazet (67):
      net: add SOCK_RCU_FREE socket flag
      udp: no longer use SLAB_DESTROY_BY_RCU
      tcp/dccp: remove BH disable/enable in lookup
      tcp/dccp: use rcu locking in inet_diag_find_one_icsk()
      inet: reqsk_alloc() needs to take care of dead listeners
      tcp/dccp: do not touch listener sk_refcnt under synflood
      sock_diag: add SK_MEMINFO_DROPS
      tcp: increment sk_drops for dropped rx packets
      tcp: increment sk_drops for listeners
      ipv4: tcp: set SOCK_USE_WRITE_QUEUE for ip_send_unicast_reply()
      tcp: rate limit ACK sent by SYN_RECV request sockets
      tcp/dccp: fix inet_reuseport_add_sock()
      ipv6: fix inet6_lookup_listener()
      net: bcmgenet: use napi_complete_done()
      net: remove netdevice gso_min_segs
      net: validate_xmit_skb() changes
      tcp: do not mess with listener sk_wmem_alloc
      tcp: remove false sharing in tcp_rcv_state_process()
      net: fix HAVE_EFFICIENT_UNALIGNED_ACCESS typos
      tcp-tso: do not split TSO packets at retransmit time
      sock: relax WARN_ON() in sock_owned_by_user()
      tcp: SYN packets are now simply consumed
      net: better drop monitoring in ip{6}_recv_error()
      net-rfs: fix false sharing accessing sd->input_queue_head
      net: snmp: kill various STATS_USER() helpers
      dccp: rename DCCP_INC_STATS_BH()
      net: rename ICMP_INC_STATS_BH()
      net: udp: rename UDP_INC_STATS_BH()
      net: xfrm: kill XFRM_INC_STATS_BH()
      net: tcp: rename TCP_INC_STATS_BH
      net: icmp: rename ICMPMSGIN_INC_STATS_BH()
      net: sctp: rename SCTP_INC_STATS_BH()
      net: rename IP_INC_STATS_BH()
      net: rename ICMP6_INC_STATS_BH()
      net: rename IP_ADD_STATS_BH()
      net: rename IP_UPD_PO_STATS_BH()
      net: rename NET_{ADD|INC}_STATS_BH()
      ipv6: rename IP6_INC_STATS_BH()
      ipv6: rename IP6_UPD_PO_STATS_BH()
      ipv6: kill ICMP6MSGIN_INC_STATS_BH()
      net: snmp: kill STATS_BH macros
      net: SOCKWQ_ASYNC_NOSPACE optimizations
      net: SOCKWQ_ASYNC_WAITDATA optimizations
      net: snmp: fix 64bit stats on 32bit arches
      tcp: give prequeue mode some care
      tcp: do not assume TCP code is non preemptible
      tcp: do not block bh during prequeue processing
      dccp: do not assume DCCP code is non preemptible
      udp: prepare for non BH masking at backlog processing
      sctp: prepare for socket backlog behavior change
      net: do not block BH while processing socket backlog
      tcp: make tcp_sendmsg() aware of socket backlog
      net: relax expensive skb_unclone() in iptunnel_handle_offloads()
      fq_codel: add batch ability to fq_codel_drop()
      net: add __sock_wfree() helper
      tcp: guarantee forward progress in tcp_sendmsg()
      tcp: fix lockdep splat in tcp_snd_una_update()
      tcp: must block bh in __inet_twsk_hashdance()
      tcp: two more missing bh disable
      ipv4: tcp: ip_send_unicast_reply() is not BH safe
      fq_codel: add memory limitation per queue
      net: make sch_handle_ingress() drop monitor ready
      ifb: support more features
      sunrpc: set SOCK_FASYNC
      sock: propagate __sock_cmsg_send() error
      tcp: minor optimizations around tcp_hdr() usage
      fq_codel: fix memory limitation drift

Eva Rachel Retuya (1):
      iwlwifi: dvm: use alloc_ordered_workqueue()

Ezequiel Garcia (1):
      stmmac: hardware TX COE doesn't work when force_thresh_dma_mode i=
s set

=46abio Estevam (1):
      phy: micrel: Use MICREL_PHY_ID_MASK definition

=46elix Fietkau (4):
      mac80211: do not pass injected frames without a valid rate to the=
 driver
      mac80211: minstrel_ht: improve sample rate skip logic
      mac80211: add A-MSDU tx support
      mac80211: minstrel_ht: set A-MSDU tx limits based on selected max=
_prob_rate

=46lorian Fainelli (6):
      net: bcmgenet: use __napi_schedule_irqoff()
      net: bcmsysport: use __napi_schedule_irqoff()
      net: bcmsysport: use napi_complete_done()
      net: dsa: Provide CPU port statistics to master netdev
      of: of_mdio: Check if MDIO bus controller is available
      net: switchdev: Drop EXPERIMENTAL from description

=46lorian Westphal (57):
      netfilter: conntrack: de-inline nf_conntrack_eventmask_report
      netfilter: conntrack: move expectation event helper to ecache.c
      netfilter: x_tables: don't move to non-existent next rule
      netfilter: x_tables: validate targets of jumps
      netfilter: x_tables: add and use xt_check_entry_offsets
      netfilter: x_tables: kill check_entry helper
      netfilter: x_tables: assert minimum target size
      netfilter: x_tables: add compat version of xt_check_entry_offsets
      netfilter: x_tables: check standard target size too
      netfilter: x_tables: check for bogus target offset
      netfilter: x_tables: validate all offsets and sizes in a rule
      netfilter: ip_tables: simplify translate_compat_table args
      netfilter: ip6_tables: simplify translate_compat_table args
      netfilter: arp_tables: simplify translate_compat_table args
      netfilter: x_tables: xt_compat_match_from_user doesn't need a ret=
val
      netfilter: x_tables: do compat validation via translate_table
      netfilter: x_tables: remove obsolete overflow check for compat ca=
se too
      netfilter: x_tables: remove obsolete check
      netfilter: x_tables: introduce and use xt_copy_counters_from_user
      netfilter: connlabels: move helpers to xt_connlabel
      netfilter: labels: don't emit ct event if labels were not changed
      netfilter: connlabels: change nf_connlabels_get bit arg to 'highe=
st used'
      netfilter: conntrack: don't acquire lock during seq_printf
      netfilter: conntrack: move generation seqcnt out of netns_ct
      netfilter: conntrack: use get_random_once for nat and expectation=
s
      netfilter: conntrack: use get_random_once for conntrack hash seed
      RDMA/nes: remove use of NETDEV_TX_LOCKED
      atl1c: remove private tx lock
      atle1: remove LLTX support and TX_UNLOCKED
      drivers: net: use NETDEV_TX_OK instead of NETDEV_TX_LOCKED
      drivers: net: remove NETDEV_TX_LOCKED
      net: remove NETDEV_TX_LOCKED support
      pch_gbe: fix bogus trylock conversion
      netdevice: shrink size of struct netdev_queue
      dmfe: kill DEVICE define
      drivers: replace dev->trans_start accesses with dev_trans_start
      netdevice: add helper to update trans_start
      treewide: replace dev->trans_start update with helper
      net: remove dev->trans_start
      bonding: update documentation section after dev->trans_start remo=
val
      drivers: fix dev->trans_start removal fallout
      netfilter: nftables: add connlabel set support
      netfilter: conntrack: keep BH enabled during lookup
      netfilter: conntrack: fix lookup race during hash resize
      netfilter: conntrack: don't attempt to iterate over empty table
      netfilter: conntrack: use nf_ct_key_equal() in more places
      netfilter: conntrack: small refactoring of conntrack seq_printf
      netfilter: conntrack: check netns when comparing conntrack object=
s
      netfilter: conntrack: make netns address part of hash
      netfilter: conntrack: use a single hashtable for all namespaces
      netfilter: conntrack: consider ct netns in early_drop logic
      netfilter: conntrack: check netns when walking expect hash
      netfilter: conntrack: make netns address part of expect hash
      netfilter: conntrack: use a single expectation table for all name=
spaces
      netfilter: conntrack: make netns address part of nat bysrc hash
      netfilter: conntrack: use a single nat bysource table for all nam=
espaces
      netfilter: conntrack: use single slab cache

=46rancesco Ruggeri (2):
      macvlan: fix failure during registration v3
      macvtap: check minor when unregistering

=46ranky Lin (1):
      brcmfmac: screening firmware event packet

Gal Pressman (9):
      net/mlx5e: Report additional error statistics in get stats ndo
      net/mlx5e: Statistics handling refactoring
      net/mlx5e: Rename VPort counters
      net/mlx5e: Add per priority group to PPort counters
      net/mlx5e: Add link down events counter
      net/mlx5e: Improve set features ndo resiliency
      net/mlx5e: Add ethtool support for interface identify (LED blinki=
ng)
      net/mlx5e: Add ethtool support for dump module EEPROM
      net/mlx5e: Add ethtool support for rxvlan-offload (vlan stripping=
)

Ganapathi Bhat (2):
      mwifiex: add support for GTK rekey offload
      mwifiex: add support for wakeup on GTK rekey failure

Geert Uytterhoeven (2):
      mwifiex: Spelling s/minmum/minimum/, s/bandwidth/bandwith/
      ravb: Add missing free_irq() calls to ravb_close()

Geliang Tang (6):
      ipw2x00: use to_pci_dev()
      wlcore: use to_delayed_work()
      wl1251: use to_delayed_work()
      rtlwifi: use to_delayed_work()
      batman-adv: use list_for_each_entry_safe
      batman-adv: use to_delayed_work

Glenn Ruben Bakke (1):
      Bluetooth: 6lowpan: Fix memory corruption of ipv6 destination add=
ress

Golan Ben-Ami (2):
      iwlwifi: mvm: support dumping UMAC internal txfifos
      iwlwifi: store fw memory segments length and addresses in run-tim=
e

Govindarajulu Varadarajan (1):
      enic: set netdev->vlan_features

Greg Rose (2):
      i40e: Remove zero check
      i40e: Add promiscuous on VLAN support

Grygorii Strashko (2):
      drivers: net: cpsw: fix port_mask parameters in ale calls
      drivers: net: cpsw: drop host_port field from struct cpsw_priv

Grzegorz Bajorski (1):
      ath10k: deliver mgmt frames from htt to monitor vifs only

Guillaume Nault (2):
      ppp: define reusable device creation functions
      ppp: add rtnetlink device creation support

Haggai Abramovsky (1):
      net/mlx4: Avoid wrong virtual mappings

Haim Dreyfuss (2):
      iwlwifi: 9000: update device id and FW serial number
      iwlwifi: pcie: Fix index iteration on free_irq in MSIX mode

Haishuang Yan (4):
      netlink: use nla_get_in_addr and nla_put_in_addr for ipv4 address
      netfilter: ipv6: unnecessary to check whether ip6_route_output() =
returns NULL
      ip6_gre: Fix get_size calculation for gre6 tunnel
      gre: Fix wrong tpi->proto in WCCP

Haiyang Zhang (1):
      hv_netvsc: Fix the list processing for network change event

Hamad Kadmany (1):
      wil6210: Set permanent MAC address to wiphy

Hannes Frederic Sowa (14):
      sock: fix lockdep annotation in release_sock
      net: introduce lockdep_is_held and update various places to use i=
t
      tun: use socket locks for sk_{attach,detatch}_filter
      sock: make lockdep_sock_is_held static inline
      sock: tigthen lockdep checks for sock_owned_by_user
      vxlan: synchronously and race-free destruction of vxlan sockets
      vxlan: reduce usage of synchronize_net in ndo_stop
      benet: be_resume needs to protect be_open with rtnl_lock
      fm10k: protect fm10k_open in fm10k_io_resume with rtnl_lock
      mlx4: protect mlx4_en_start_port in mlx4_en_restart with rtnl_loc=
k
      ixgbe: protect vxlan_get_rx_port in ixgbe_service_task with rtnl_=
lock
      qlcnic: protect qlicnic_attach_func with rtnl_lock
      vxlan: break dependency with netdev drivers
      geneve: break dependency with netdev drivers

Hante Meuleman (4):
      brcmfmac: clear eventmask array before using it
      brcmfmac: fix clearing wowl wake indicators
      brcmfmac: insert default boardrev in nvram data if missing
      brcmfmac: fix p2p scan abort null pointer exception

Hariprasad Shenai (14):
      cxgb4/cxgb4vf: Deprecate module parameter dflt_msg_enable
      cxgb4: add new routine to get adapter info
      cxgb4: Add llseek operation for flash debugfs entry
      cxgb4: Avoids race and deadlock while freeing tx descriptor
      cxgb4: Properly decode port module type
      cxgb4: Refactor t4_port_init function
      cxgb4: DCB message handler needs to use correct portid to netdev =
mapping
      cxgb4: Don't assume FW_PORT_CMD reply is always port info msg
      cxgb4: Decode link down reason code obtained from firmware
      cxgb4: Add support to enable logging of firmware mailbox commands
      cxgb4vf: Add support to enable logging of firmware mailbox comman=
ds for VF
      cxgb4: Don't sleep when mbox cmd is issued from interrupt context
      cxgb4: Check for firmware errors in the mailbox command loop
      cxgb4: Reset dcb state machine and tx queue prio only if dcb is e=
nabled

Harshitha Ramamurthy (2):
      i40e/i40evf: Bump patch from 1.5.2 to 1.5.5
      i40e/i40evf : Bump driver version from 1.5.5 to 1.5.10

Harvey Hunt (1):
      drivers: net: Don't print unpopulated net_device name

Herbert Xu (1):
      netlink: Fix dump skb leak/double free

Ido Schimmel (20):
      mlxsw: spectrum: Reduce number of supported 802.1D bridges
      switchdev: Use switch ID in suggested udev rule
      mlxsw: spectrum: Add support for physical port names
      mlxsw: reg: Add Port Prio To Buffer register
      mlxsw: spectrum: Map all switch priorities to priority group 0
      mlxsw: spectrum: Add bytes to cells helper
      mlxsw: spectrum: Correctly configure headroom size
      mlxsw: reg: Use correct PBMC register length
      mlxsw: spectrum: Set port's shared buffer size to 0
      mlxsw: reg: Add QoS ETS Element Configuration register
      mlxsw: reg: Add QoS Switch Traffic Class Table register
      mlxsw: spectrum: Initialize egress scheduling
      mlxsw: spectrum: Introduce support for Data Center Bridging (DCB)
      mlxsw: spectrum: Add IEEE 802.1Qaz ETS support
      mlxsw: spectrum: Allow setting maximum rate for a TC
      mlxsw: reg: Add Port Flow Control Configuration register
      mlxsw: reg: Add lossless settings for PBMC register
      mlxsw: spectrum: Add support for PAUSE frames
      mlxsw: reg: Introduce per priority counters
      mlxsw: spectrum: Add IEEE 802.1Qbb PFC support

Ivan Safonov (1):
      ath9k: Remove unnecessary ?: operator

Iyappan Subramanian (3):
      drivers: net: xgene: Get channel number from device binding
      Documentation: dtb: xgene: Add channel property
      dtb: xgene: Add channel property

Jacob Keller (37):
      fm10k: prevent null pointer dereference of msix_entries table
      fm10k: don't initialize service task until later in probe
      fm10k: base queue scheme covered by RSS
      fm10k: print error message when stop_hw fails
      fm10k: free MBX IRQ before clearing interrupt scheme
      fm10k: add helper functions to set strings and data for ethtool s=
tats
      fm10k: correctly clean up when init_queueing_scheme fails
      fm10k: fix a minor typo in some comments
      fm10k: use ethtool_rxfh_indir_default for default redirection tab=
le
      fm10k: add helper functions to set strings and data for ethtool s=
tats
      fm10k: remove debug-statistics support
      fm10k: use DRV_SUMMARY to reduce code duplication
      fm10k: prevent RCU issues during AER events
      fm10k: drop 1588 support
      fm10k: correctly handle LPORT_MAP error
      fm10k: do not disable PCI device in fm10k_io_error_detected
      fm10k: fix documentation of fm10k_tlv_parse_attr
      fm10k: use 8bit notation instead of 10bit notation for diagram
      fm10k: use different name than FM10K_VLAN_CLEAR for override bit
      fm10k: update comment regarding reserved bits check
      fm10k: fix possible null pointer deref after kcalloc
      fm10k: consistently use Intel(R) for driver names
      fm10k: fix incorrect IPv6 extended header checksum
      ixgbe: use BIT() macro
      ixgbe: resolve shift of negative value warning
      ixgbevf: make use of BIT() macro to avoid shift of signed values
      i40e/i40evf: fix I40E_MASK signed shift overflow warnings
      i40e: make use of BIT() macro to prevent left shift of signed val=
ues
      i40evf: make use of BIT() macro to avoid signed left shift
      igb: use BIT() macro or unsigned prefix
      igb: make igb_update_pf_vlvf static
      igbvf: remove unused variable and dead code
      igbvf: use BIT() macro instead of shifts
      e1000e: use BIT() macro for bit defines
      e1000e: mark shifted values as unsigned
      e1000e: don't modify SYSTIM registers during SIOCSHWTSTAMP ioctl
      i40e: change Rx hang message into a WARN_ONCE

Jakub Kicinski (21):
      nfp: correct RX buffer length calculation
      nfp: move link state interrupt request/free calls
      nfp: break up nfp_net_{alloc|free}_rings
      nfp: make *x_ring_init do all the init
      nfp: allocate ring SW structs dynamically
      nfp: cleanup tx ring flush and rename to reset
      nfp: reorganize initial filling of RX rings
      nfp: preallocate RX buffers early in .ndo_open
      nfp: move filling ring information to FW config
      nfp: slice .ndo_open() and .ndo_stop() up
      nfp: sync ring state during FW reconfiguration
      nfp: propagate list buffer size in struct rx_ring
      nfp: convert .ndo_change_mtu() to prepare/commit paradigm
      nfp: pass ring count as function parameter
      nfp: allow ring size reconfiguration at runtime
      nfp: check the right pointer for errors
      nfp: remove unnecessary static
      nfp: correct names of constants in comments
      nfp: remove unused suspicious mask defines
      nfp: remove buggy RX buffer length validation
      nfp: add async reconfiguration mechanism

Jason Wang (1):
      tuntap: calculate rps hash only when needed

Jeff Kirsher (1):
      MAINTAINERS: Cleanup Intel Wired LAN maintainers list

Jes Sorensen (85):
      rtl8xxxu: Change name of struct tx_desc to be more decriptive
      rtl8xxxu: Rename TX descriptor bits to map them to 32/40 byte des=
criptors
      rtl8xxxu: Correct txdesc40 gid definition
      rtl8xxxu: TXDESC_SHORT_GI is txdesc32 only
      rtl8xxxu: 8192eu uses txdesc40
      rtl8xxxu: Update some register definitions
      rtl8xxxu: Use enums for chip version numbers
      rtl8xxxu: Identify 8192eu rev A/B parts correctly
      rtl8xxxu: Use correct H2C calls for 8192eu
      rtl8xxxu: Do not set LDOA15 / LDOV12 on 8192eu
      rtl8xxxu: Add MAC init table for 8192eu
      rtl8xxxu: Do not mess with AFE_XTAL_CTRL on 8192eu
      rtl8xxxu: Set TX page boundaries for 8192eu
      rtl8xxxu: Add radio init tables for 8192eu
      rtl8xxxu: Add 8192eu AGC tables
      rtl8xxxu: Add 8192eu PHY init table
      rtl8xxxu: Pick PHY init table based on chip version first
      rtl8xxxu: Correctly parse 8192eu efuse
      rtl8xxxu: Handle BB init for 8192eu
      rtl8xxxu: Provide special handling when writing RF regs on 8192eu
      rtl8xxxu: Handle XTAL value setting on 8192eu
      rtl8xxxu: Set correct interrupt masking registers on 8192eu
      rtl8xxxu: Set REG_USB_HRPWM for 8192eu
      rtl8xxxu: Fix LDPC RX hang issue on 8192eu
      rtl8xxxu: Implement 8192eu device specific quirks
      rtl8xxxu: Use proper register name for REG_PAD_CTRL1
      rtl8xxxu: Implement IQK calibration for 8192eu
      rtl8xxxu: Adjust AFE crystal value on 8192eu
      rtl8xxxu: Reorder parts of init code to match the 8192eu vendor c=
ode flow
      rtl8xxxu: Reorg more code to match the flow of the 8192eu vendor =
driver
      rtl8xxxu: Implement generic init_queue_reserved_page() function
      rtl8xxxu: Reorder chip quirks to follow flow of 8192eu driver
      rtl8xxxu: Do not set REG_PBP on 8192eu
      rtl8xxxu: Do not init FPGA0_TX_INFO on 8192eu
      rtl8xxxu: Do not try to set REG_LEDCFG2 on 8192eu
      rtl8xxxu: Implment rtl8192e_set_tx_power()
      rtl8xxxu: Use has_s0s1 for REG_S0S1 issues only
      rtl8xxxu: byteswap the entire RX descriptor for 24 byte RX descri=
ptors
      rtl8xxxu: Name RX descriptor types rxdesc16/rxdesc24
      rtl8xxxu: Remove misleading warning from rtl8192eu_phy_iqcalibrat=
e()
      rtl8xxxu: Remove unused 8723bu path B IQ calibration code
      rtl8xxxu: Correctly mask what was read from REG_CCK0_AFE_SETTING
      rtl8xxxu: Use descriptive bits for setting RX paths for 1T2R part=
s
      rtl8xxxu: Split rtl8xxxu_init_phy_bb() into device specific funct=
ions
      rtl8xxxu: Load AGC table before patching for 1T2R parts
      rtl8xxxu: Move loading of AGC table to device specific function
      rtl8xxxu: REG_LDOA15_CTRL is only used on gen1 parts
      rtl8xxxu: Store device specific TRXFF boundary in the fileops
      rtl8xxxu: Do not backup RF_MODE_AG when it's never being used
      rtl8xxxu: Make PBP tuning a fileops parameter
      rtl8xxxu: Split USB quirks into gen1 and gen2 quirks
      rtl8xxxu: Remove unneeded 8192eu hack
      rtl8xxxu: 8192eu Fix bug in LDPC RX hang fix
      Re-enable 8192eu support
      rtl8xxxu: Mark 0x050d:0x1004 as tested
      rtl8xxxu: Move PHY RF init into device specific functions
      rtl8xxxu: For devices with external PA (8188RU), limit CCK TX pow=
er
      rtl8xxxu: Apply 8188RU workaround for UMC B cut parts correctly
      rtl8xxxu: Use rtl_chip =3D=3D RTL8188R to identify high PA parts
      rtl8xxxu: Match 8723bu power down sequence to vendor driver
      rtl8xxxu: Unregister from mac80211 before shutting down the devic=
e
      rtl8xxxu: Update copyright statement to include 2016
      rtl8xxxu: Set register 0xfe10 on rtl8192cu based parts
      rtl8xxxu: Add TX power base values for gen1 parts
      rtl8xxxu: Fix 8188RU support
      rtl8xxxu: Fix OOPS if user tries to add device via /sys
      rtl8xxxu: Implement rtl8192e_enable_rf()
      rtl8xxxu: Pause TX before calling disable_rf()
      rtl8xxxu: MAINTAINERS: Update to point to the active devel branch
      rtl8xxxu: Rename rtl8723bu_update_rate_mask() to rtl8xxxu_gen2_up=
date_rate_mask()
      rtl8xxxu: Rename rtl8723bu_report_connect() to rtl8xxxu_gen2_repo=
rt_connect()
      rtl8xxxu: Rename rtl8723au_report_connect() to rtl8xxxu_gen1_repo=
rt_connect()
      rtl8xxxu: Rename rtl8723bu_config_channel() to rtl8xxxu_gen2_conf=
ig_channel()
      rtl8xxxu: Rename rtl8723b_disable_rf() to rtl8xxxu_gen2_disable_r=
f()
      rtl8xxxu: Rename rtl8723a_disable_rf() to rtl8xxxu_gen1_disable_r=
f()
      rtl8xxxu: Rename rtl8723au_config_channel() to rtl8xxxu_gen1_conf=
ig_channel()
      rtl8xxxu: Rename rtl8723au_update_rate_mask() to rtl8xxxu_update_=
rate_mask()
      rtl8xxxu: Rename rtl8723au_phy_iq_calibrate() to rtl8xxxu_gen1_ph=
y_iq_calibrate()
      rtl8xxxu: Rename rtl8723au_init_phy_bb() to rtl8xxxu_gen1_init_ph=
y_bb()
      rtl8xxxu: Rename rtl8723a_set_tx_power() to rtl8xxxu_gen1_set_tx_=
power()
      rtl8xxxu: Rename rtl8723a_enable_rf() to rtl8xxxu_gen1_enable_rf(=
)
      rtl8xxxu: Rename rtl8723a_mac_init_table to rtl8xxxu_gen1_mac_ini=
t_table
      rtl8xxxu: Rename rtl8723b_channel_to_group()
      rtl8xxxu: Rename rtl8723bu_simularity_compare()
      rtl8xxxu: Rename rtl8723au_iqk_phy_iq_bb_reg

Jesper Dangaard Brouer (5):
      samples/bpf: add back functionality to redefine LLC command
      samples/bpf: Makefile verify LLVM compiler avail and bpf target i=
s supported
      samples/bpf: add a README file to get users started
      samples/bpf: allow make to be run from samples/bpf/ directory
      samples/bpf: like LLC also verify and allow redefining CLANG comm=
and

Jesse Brandeburg (17):
      i40e/i40evf: Fix casting in transmit code
      i40e: Fix up return code
      i40e/i40evf: Move stack var deeper
      i40e/i40evf: Drop unused tx_ring argument
      i40e/i40evf: Faster RX via avoiding FCoE
      i40e/i40evf: Only offload VLAN tag if enabled
      i40e: PTP - avoid aggregate return warnings
      i40e: Use consistent type for vf_id
      i40e: Drop extra copy of function
      i40e/i40evf: Refactor tunnel interpretation
      i40e: Drop packet split receive routine
      i40e/i40evf: Remove reference to ring->dtype
      i40e: Refactor receive routine
      i40evf: Drop packet split receive routine
      i40evf: refactor receive routine
      i40e/i40evf: Remove unused hardware receive descriptor code
      i40e: Test memory before ethtool alloc succeeds

Jia-Ju Bai (5):
      iwl4965: Fix a null pointer dereference in il_tx_queue_free and i=
l_cmd_queue_free
      b43: Fix memory leaks in b43_bus_dev_ssb_init and b43_bus_dev_bcm=
a_init
      rtl818x_pci: Disable pci device in error handling code
      iwl4965: Fix a memory leak in error handling code of __il4965_up
      rtl818x_pci: Fix a memory leak in rtl8180_init_rx_ring

Jiri Benc (13):
      vxlan: move Ethernet initialization to a separate function
      vxlan: move fdb code to common location in vxlan_xmit
      ip_tunnel: implement __iptunnel_pull_header
      vxlan: implement GPE
      net: intel: remove dead links
      vxlan: fix incorrect type
      route: move lwtunnel state to a single place
      vxlan: fix initialization with custom link parameters
      gre: change gre_parse_header to return the header length
      gre: remove superfluous pskb_may_pull
      gre: move iptunnel_pull_header down to ipgre_rcv
      gre: receive also TEB packets for lwtunnels
      vxlan: set mac_header correctly in GPE mode

Jiri Pirko (30):
      devlink: remove implicit type set in port register
      mlxsw: Move devlink port registration into common core code
      mlxsw: Pass mlxsw_core as a param of mlxsw_core_skb_transmit*
      mlxsw: Do not pass around driver_priv directly
      mlxsw: reg: Share direction enum between SBPR, SBCM, SBPM
      mlxsw: reg: Fix SBPM register name
      devlink: share user_ptr pointer for both devlink and devlink_port
      devlink: add shared buffer configuration
      devlink: implement shared buffer occupancy monitoring interface
      mlxsw: core: Add devlink shared buffer callbacks
      mlxsw: spectrum_buffers: Push out shared buffer register writes
      mlxsw: spectrum_buffers: Push out indexes and direction out of SB=
 structs
      mlxsw: spectrum_buffers: Rename "pool" to "pr" in initialization
      mlxsw: spectrum_buffers: Cache shared buffer configuration
      mlxsw: spectrum_buffers: Remove eg pool 3 default init and CPU po=
rt TC binding to it
      mlxsw: spectrum_buffers: Change initialization of PG 9
      mlxsw: spectrum_buffers: Get max_buff defaults into limits expose=
d to user
      mlxsw: core: Add mlxsw_core_port_driver_priv helper
      mlxsw: spectrum_buffers: Implement shared buffer configuration
      mlxsw: core: Add devlink shared buffer occupancy callbacks
      mlxsw: reg: Add Shared Buffer Status register definition
      mlxsw: reg: Extend SBPM register for occupancy control
      mlxsw: core: Add mlxsw specific workqueue and use it for FDB noti=
f. processing
      mlxsw: core: Introduce support for asynchronous EMAD register acc=
ess
      mlxsw: spectrum_buffers: Implement occupancy monitoring
      devlink: fix sb register stub in case devlink is disabled
      mlxsw: spectrum_buffers: Use designated initializers for mlxsw_sp=
_pbs
      mlxsw: spectrum_buffers: Use MLXSW_SP_PB_UNUSED define for unused=
 pb
      mlxsw: spectrum: Fix ordering in mlxsw_sp_fini
      switchdev: pass pointer to fib_info instead of copy

Jiri Slaby (3):
      Bluetooth: vhci: fix open_timeout vs. hdev race
      Bluetooth: vhci: purge unhandled skbs
      Bluetooth: fix power_on vs close race

Jisheng Zhang (2):
      net: pxa168_eth: use {readl|writel}_relaxed instead of readl/writ=
el
      net: pxa168_eth: Use dma_wmb/rmb where appropriate

Joachim Eastwood (6):
      stmmac: let remove/resume/suspend functions take device pointer
      stmmac: dwmac-socfpga: add PM ops and resume function
      stmmac: dwmac-socfpga: keep a copy of stmmac_rst in driver priv d=
ata
      stmmac: dwmac-socfpga: call phy_resume() only in resume callback
      stmmac: dwmac-socfpga: kill init() and rename setup() to set_phy_=
mode()
      stmmac: dwmac-socfpga: make socfpga_dwmac_pm_ops static

Joe Perches (1):
      rtlwifi: btcoexist: Convert BTC_PRINTK to btc_<foo>_dbg

Johan Hedberg (3):
      Bluetooth: Fix setting NO_BREDR advertising flag
      Bluetooth: Ignore unknown advertising packet types
      Bluetooth: Add defines for SPI and I2C

Johannes Berg (25):
      iwlwifi: mvm: remove is_data_qos variable in TX
      wext: unregister_pernet_subsys() on notifier registration failure
      mac80211: allow drivers to report CLOCK_BOOTTIME for scan results
      mac80211: remove sta_info debugfs sub-struct
      mac80211: don't start dynamic PS timer if not needed
      mac80211: clean up station flags debugfs
      mac80211: fix cipher scheme function name
      mac80211: avoid useless memory write on each frame RX
      mac80211: allow passing transmitter station on RX
      mac80211: count MSDUs in A-MSDU properly
      mac80211: move semicolon out of CALL_RXH macro
      mac80211: move averaged values out of rx_stats
      mac80211: remove rx_stats.last_rx update after sta alloc
      mac80211: add separate last_ack variable
      mac80211: fix last RX rate data consistency
      mac80211: fix RX u64 stats consistency on 32-bit platforms
      mac80211: add fast-rx path
      mac80211: enable collecting station statistics per-CPU
      cfg80211: remove enum ieee80211_band
      nl80211: add missing kerneldoc for new *_PAD attributes
      nl80211: use nla_put_u64_64bit() for the remaining u64 attributes
      wext: remove a/b/g/n from SIOCGIWNAME
      cfg80211: remove erroneous comment
      cfg80211: make wdev_list accessible to drivers
      mac80211: allow software PS-Poll/U-APSD with AP_LINK_PS

John Allen (1):
      ibmvnic: Enable use of multiple tx/rx scrqs

John Crispin (8):
      net: mediatek: watchdog_timeo was not set
      net: mediatek: mtk_cal_txd_req() returns bad value
      net: mediatek: remove superfluous reset call
      net: mediatek: fix stop and wakeup of queue
      net: mediatek: fix TX locking
      net: mediatek: fix mtk_pending_work
      net: mediatek: move the pending_work struct to the device generic=
 struct
      net: mediatek: do not set the QID field in the TX DMA descriptors

John Holland (1):
      igb: allow setting MAC address on i211 using a device tree blob

John Stultz (1):
      asix: Fix offset calculation in asix_rx_fixup() causing slow tran=
smissions

Jon Maxwell (1):
      cnic: call cp->stop_hw() in cnic_start_hw() on allocation failure

Jon Paul Maloy (13):
      tipc: eliminate buffer leak in bearer layer
      tipc: stricter filtering of packets in bearer layer
      tipc: remove remnants of old broadcast code
      tipc: guarantee peer bearer id exchange after reboot
      tipc: reduce transmission rate of reset messages when link is dow=
n
      tipc: refactor function tipc_link_timeout()
      tipc: ensure that first packets on link are sent in order
      tipc: let first message on link be a state message
      tipc: set 'active' state correctly for first established link
      tipc: re-enable compensation for socket receive buffer double cou=
nting
      tipc: propagate peer node capabilities to socket layer
      tipc: redesign connection-level flow control
      tipc: eliminate risk of double link_up events

Joseph Salisbury (1):
      ath5k: Change led pin configuration for compaq c700 laptop

Jouni Malinen (6):
      cfg80211: Allow a scan request for a specific BSSID
      mac80211: Support a scan request for a specific BSSID
      mac80211_hwsim: Support a hw scan request for a specific BSSID
      cfg80211: Add option to specify previous BSSID for Connect comman=
d
      cfg80211: Allow reassociation to be requested with internal SME
      cfg80211: Improve Connect/Associate command documentation

Jo=E3o Paulo Rechi Vita (1):
      rfkill: Use switch to demux userspace operations

Julia Lawall (6):
      qdisc: constify meta_type_ops structures
      arcnet: com90xx: add __init attribute
      net: tsi108: use NULL for pointer-typed argument
      drivers: net: xgene: constify xgene_cle_ops structure
      VSOCK: constify vsock_transport structure
      i40e: constify i40e_client_ops structure

Julian Calaby (1):
      iwl4965: Fix more memory leaks in __il4965_up()

KY Srinivasan (3):
      hv_netvsc: Implement support for VF drivers on Hyper-V
      ixgbevf: Add the device ID's presented while running on Hyper-V
      ixgbevf: Support Windows hosts (Hyper-V)

Kalle Valo (16):
      Merge tag 'iwlwifi-next-for-kalle-2016-03-30' of https://git.kern=
el.org/.../iwlwifi/iwlwifi-next
      Merge ath-next from ath.git
      ath10k: fix checkpatch warnings related to spaces
      ath10k: prefer kernel type 'u64' over 'u_int64_t'
      ath10k: prefer ether_addr_equal() or ether_addr_equal_unaligned()=
 over memcmp()
      ath10k: prefer ether_addr_copy() over memcpy()
      ath10k: fix parenthesis alignment
      ath10k: remove deprecated firmware API 1 support
      ath10k: refactor firmware images to struct ath10k_fw_components
      ath10k: move fw_version inside struct ath10k_fw_file
      ath10k: move fw_features to struct ath10k_fw_file
      ath10k: move wmi_op_version to struct ath10k_fw_file
      ath10k: move htt_op_version to struct ath10k_fw_file
      ath10k: switch testmode to use ath10k_core_fetch_firmware_api_n()
      ath10k: remove enum ath10k_swap_code_seg_bin_type
      Merge ath-next from ath.git

Kamil Krawczyk (1):
      i40e: Add DeviceID for X722 QSFP+

Kanchanapally, Vidyullatha (1):
      cfg80211: Add option to report the bss entry in connect result

Kazuya Mizuguchi (2):
      ravb: Add dma queue interrupt support
      ravb: Remove rx buffer ALIGN

Kevin Scott (2):
      i40e: Save off VSI resource count when updating VSI
      i40e: Add support for disabling all link and change bits needed f=
or PHY interactions

Kiran Patil (1):
      i40e: Input set mask constants for RSS, flow director, and flex b=
ytes

Konstantin Khlebnikov (2):
      net/ipv6/addrconf: simplify sysctl registration
      net/ipv6/addrconf: fix sysctl table indentation

Krzysztof Kozlowski (1):
      nfc: Drop owner assignment from i2c_driver

Larry Finger (11):
      rtlwifi: rtl8723be: Add antenna select module parameter
      rtlwifi: btcoexist: Implement antenna selection
      rtlwifi: Fix Smatch warnings
      rtlwifi: btcoexist: Fix Smatch warning
      rtlwifi: rtl8188ee: Fix Smatch warnings
      rtlwifi: rtl8192c-common: Fix Smatch warning
      rtlwifi: rtl8192ee: Fix Smatch warning
      rtlwifi: rtl8192se: Fix Smatch warning
      rtlwifi: rtl8723ae: Fix Smatch warning
      rtlwifi: rtl8723be: Fix Smatch warnings
      rtlwifi: rtl8821ae: Fix Smatch warnings

Lauro Costa (1):
      Bluetooth: Add USB ID 13D3:3487 to ath3k

Lawrence Brakmo (2):
      tcp: refactor struct tcp_skb_cb
      tcp: replace cnt & rtt with struct in pkts_acked()

Liad Kaufman (7):
      iwlwifi: mvm: support bss dynamic alloc/dealloc of queues
      iwlwifi: trans: fix iwl_trans_txq_scd_cfg.sta_id sign
      iwlwifi: mvm: use bss client queue for bss station
      iwlwifi: mvm: set sta_id in SCD_QUEUE_CONFIG cmd
      iwlwifi: mvm: allocate dedicated queue for cab in dqa mode
      iwlwifi: mvm: move cmd queue to be #0 in dqa mode
      iwlwifi: mvm: fix inconsistent lock in dqa mode

Lina Iyer (1):
      drivers: qcom: spm: avoid module usage in non-modular SPM driver

Lior David (10):
      wil6210: add support for discovery mode during scan
      wil6210: switch to generated wmi.h
      wil6210: basic PBSS/PCP support
      wil6210: P2P_DEVICE virtual interface support
      wil6210: fix race conditions in p2p listen and search
      wil6210: clean ioctl debug message
      wil6210: fix no_fw_recovery mode with change_virtual_intf
      wil6210: pass is_go flag to firmware
      wil6210: add oob_mode module parameter
      wil6210: allow empty WMI commands in debugfs wmi_send

Liping Zhang (2):
      netfilter: ip6t_SYNPROXY: remove magic number for hop_limit
      netfilter: ip6t_SYNPROXY: unnecessary to check whether ip6_route_=
output returns NULL

Lisheng (1):
      net: hns: add support of pause frame ctrl for HNS V2

Loic Poulain (3):
      Bluetooth: hci_bcm: Add BCM2E71 ACPI ID
      Bluetooth: hci_ldisc: Fix null pointer derefence in case of early=
 data
      Bluetooth: hci_intel: Fix null gpio desc pointer dereference

Lorenzo Bianconi (1):
      mac80211: parse VHT info in injected frames

Luca Coelho (4):
      iwlwifi: pcie: refcounting is not necessary anymore
      iwlwifi: mvm: add a scan timeout for regular scans
      iwlwifi: mvm: allow setting the thermal state in D0i3
      iwlwifi: fix fw version reading for DVM devices

Mahesh Bandewar (1):
      ipvlan: Fix failure path in dev registration during link creation

Manish Chopra (10):
      qed: Add infrastructure support for tunneling
      qed/qede: Add VXLAN tunnel slowpath configuration support
      qed/qede: Add GENEVE tunnel slowpath configuration support
      qed: Enable GRE tunnel slowpath configuration
      qede: Add fastpath support for tunneling
      qed: Add vport WFQ configuration APIs
      qed: Add PF max bandwidth configuration support
      qed: Add PF min bandwidth configuration support
      qed: Apply tunnel configurations after PF start
      qed: Reset link on IOV disable

Maor Gottlieb (11):
      net/mlx5: Introduce modify flow rule destination
      net/mlx5: Set number of allowed levels in priority
      net/mlx5: Add user chosen levels when allocating flow tables
      net/mlx5: Support different attributes for priorities in namespac=
e
      net/mlx5e: Refactor mlx5e flow steering structs
      net/mlx5e: Split the main flow steering table
      net/mlx5: Initializing CPU reverse mapping
      net/mlx5e: Create aRFS flow tables
      net/mlx5e: Add accelerated RFS support
      net/mlx5e: Enabling aRFS mechanism
      net/mlx5e: Fix aRFS compilation dependency

Marc Angel (1):
      macvtap: add namespace support to the sysfs device class

Marcelo Ricardo Leitner (5):
      sctp: compress bit-wide flags to a bitfield on sctp_sock
      sctp: delay calls to sk_data_ready() as much as possible
      sctp: add support for RPS and RFS
      sctp: simplify sk_receive_queue locking
      sctp: signal sk_data_ready earlier on data chunks reception

Marco Angaroni (4):
      ipvs: handle connections started by real-servers
      ipvs: optimize release of connections in OPS mode
      ipvs: don't alter conntrack in OPS mode
      ipvs: make drop_entry protection effective for SIP-pe

Marek Lindner (1):
      batman-adv: replace ethertype variable with ETH_P_BATMAN for read=
ability

Marek Vasut (7):
      mdio_bus: Fix MDIO bus scanning in __mdiobus_register()
      can: ifi: Start NAPI poll on bus warning too
      can: ifi: Update timing configuration code
      can: ifi: Unify timing constants
      can: ifi: Treat CAN_CTRLMODE_FD_NON_ISO correctly
      can: ifi: Increment TX counters only on real transmission
      can: ifi: Add more detailed error reporting

Mark Rustad (21):
      ixgbe: Make all unchanging ops structures const
      ixgbe: Fix flow control for Xeon D KR backplane
      ixgbe: Delete some unused register definitions
      ixgbe: Change the lan_id and func fields to a u8 to avoid casts
      ixgbe: Correct length check for round up
      ixgbe: Clean up interface for firmware commands
      ixgbe: Take manageability semaphore for firmware commands
      ixgbe: Add support for single-port X550 device
      ixgbe: Add definitions for x550em_a 10G MAC
      ixgbe: Use method pointer to access IOSF devices
      ixgbe: Add support for x550em_a 10G MAC type
      ixgbe: Use new methods for PHY access
      ixgbe: Read and set instance id
      ixgbe: Read and parse NW_MNG_IF_SEL register
      ixgbe: Introduce function to control MDIO speed
      ixgbe: Add support for SFPs with retimer
      ixgbe: Add support for SGMII backplane interface
      ixgbe: Add KR backplane support for x550em_a
      ixgbe: Bump version number
      ixgbe: Add register wait for slow links
      ixgbe: Use correct FC setup function for x550em_a

Markus Elfring (7):
      ath9k_htc: Delete unnecessary variable initialisation
      brcmfmac: Delete unnecessary variable initialisation
      iwlegacy: Return directly if allocation fails in il_eeprom_init()
      rsi: Delete unnecessary variable initialisation
      rsi: Delete unnecessary variable initialisation
      rsi: Move variable initialisation into error code
      ath9k_htc: Replace a variable initialisation by an assignment in =
ath9k_htc_set_channel()

Martin KaFai Lau (5):
      tcp: Carry txstamp_ack in tcp_fragment_tstamp
      tcp: Merge txstamp_ack in tcp_skb_collapse_tstamp
      tcp: Make use of MSG_EOR in tcp_sendmsg
      tcp: Handle eor bit when coalescing skb
      tcp: Handle eor bit when fragmenting a skb

Marty Faltesek (3):
      mwifiex: bridged packets cause wmm_tx_pending counter to go negat=
ive
      mwifiex: fw download does not release sdio bus during failure
      mwifiex: transmit packet stats incorrect.

Masanari Iida (1):
      Doc: networking: Fix typo in dsa

Matthew Finlay (1):
      net/mlx5e: Call vxlan_get_rx_port() with rtnl lock

Matti Gottlieb (2):
      iwlwifi: mvm: Decrease size of the paging download buffer
      iwlwifi: mvm: make sure FW contains the right amount of paging se=
ctions

Maxim Zhukov (1):
      Bluetooth: hci_bcsp: fix code style

Maximilian Schneider (1):
      can: gs_usb: modify the usb device table to use only the first us=
b interface

Maya Erez (3):
      wil6210: remove BACK RX and TX workers
      wil6210: AP: prevent connecting to already connected station
      wil6210: add support for platform specific notification events

Miaoqing Pan (23):
      ath9k: Update QCA953x initvals
      ath9k: Update AR9003 2.2 initvals
      ath9k: Update AR933x initvals
      ath9k: Update AR9340 initvals
      ath9k: Update AR9462 initvals
      ath9k: Update AR9485 initvals
      ath9k: Update AR955x initvals
      ath9k: Update AR9565 initvals
      ath9k: Update QCA956x initvals
      ath9k: Update AR9580 initvals
      ath9k: enable manual peak cal for all ar9300 chips
      ath9k: use AR_SREV_9003_PCOEM to identify PCOEM chips
      ath9k: set correct peak detect threshold
      ath9k: define correct GPIO numbers and bits mask
      ath9k: make GPIO API to support both of WMAC and SOC
      ath9k: free GPIO resource for SOC GPIOs
      ath9k: cleanup led_pin initial
      ath9k: Allow platform override BTCoex pin
      ath9k: add bits definition of BTCoex MODE2/3 for SOC chips
      ath9k: fix BTCoex access invalid registers for SOC chips
      ath9k: fix BTCoex configuration for SOC chips
      ath9k: fix reg dump data bus error
      ath9k: fix rng high cpu load

Michael Chan (19):
      bnxt_en: Update to Firmware 1.2.2 spec.
      bnxt_en: Improve flow control autoneg with Firmware 1.2.1 interfa=
ce.
      bnxt_en: Add basic EEE support.
      bnxt_en: Add EEE setup code.
      bnxt_en: Add get_eee() and set_eee() ethtool support.
      bnxt_en: Set async event bits when registering with the firmware.
      bnxt_en: Add unsupported SFP+ module warnings.
      bnxt_en: Check for valid forced speed during ethtool -s.
      bnxt_en: Improve ethtool .get_settings().
      bnxt_en: Disallow forced speed for 10GBaseT devices.
      bnxt_en: Shutdown link when device is closed.
      bnxt_en: Call firmware to approve VF MAC address change.
      bnxt_en: Add async event handling for speed config changes.
      bnxt_en: Reduce maximum ring pages if page size is 64K.
      bnxt_en: Improve the delay logic for firmware response.
      bnxt_en: Fix length value in dmesg log firmware error message.
      bnxt_en: Simplify and improve unsupported SFP+ module reporting.
      bnxt_en: Add BCM57314 device ID.
      bnxt_en: Use dma_rmb() instead of rmb().

Michael Heimpold (2):
      net: ethernet: enc28j60: support half-duplex SPI controllers
      net: ethernet: enc28j60: add device tree support

Michael Thalmeier (10):
      NFC: pn533: Send ATR_REQ only if NFC_PROTO_NFC_DEP bit is set
      NFC: pn533: Fix socket deadlock
      NFC: pn533: Separate physical layer from the core implementation
      NFC: pn533: add I2C phy driver
      nfc: pn533: Add device tree documentation for i2c phy
      NFC: pn533: i2c: free irq on driver remove
      NFC: pn533: fix order of initialization
      NFC: pn533: i2c: do not call pn533_recv_frame with aborted comman=
ds
      NFC: pn533: reset poll modulation list before calling targets_fou=
nd
      NFC: pn533: handle interrupted commands in pn533_recv_frame

Michal Kazior (20):
      ath10k: refactor tx code
      ath10k: unify txpath decision
      ath10k: refactor tx pending management
      ath10k: maintain peer_id for each sta and vif
      ath10k: add fast peer_map lookup
      ath10k: add new htt message generation/parsing logic
      ath10k: implement wake_tx_queue
      ath10k: implement updating shared htt txq state
      ath10k: store txq in skb_cb
      ath10k: keep track of queue depth per txq
      ath10k: implement push-pull tx
      ath10k: fix HTT Tx CE ring size
      ath10k: change htt tx desc/qcache peer limit config
      ath10k: fix tx hang
      ath10k: fix pull-push tx threshold handling
      ath10k: fix null deref if device crashes early
      codel: generalize the implementation
      codel: split into multiple files
      fq: add fair queuing framework
      fq: split out backlog update logic

Michal Kosiarz (1):
      i40e: Add device capability which defines if update is available

Mitch Williams (18):
      i40e: Notify VFs of all resets
      i40e: Added code to prevent double resets
      i40evf: Add additional check for reset
      i40e: Change comment to reflect correct function name
      i40e: Remove unused variable
      i40evf: Fix VLAN features
      i40e: Make VF resets more reliable
      i40evf: Add longer wait after remove module
      i40e: Lower some message levels
      i40e: Add RSS configuration to virtual channel
      i40evf: properly handle VLAN features
      i40e: Add support for configuring VF RSS
      i40evf: Don't Panic
      i40evf: Allow PF driver to configure RSS
      i40evf: Allocate Rx buffers properly
      i40e: lie to the VF
      i40e/i40evf: properly report Rx packet hash
      i40e: don't add broadcast filter for VFs

Mohamad Haj Yahia (11):
      net/mlx5: Flow steering, Add vport ACL support
      net/mlx5: E-Switch, Replace vport spin lock with synchronize_irq(=
)
      net/mlx5: E-Switch, Fix error flow memory leak
      net/mlx5: E-Switch, Introduce VST vport ingress/egress ACLs
      net/mlx5: E-Switch, Vport ingress/egress ACLs rules for VST mode
      net/mlx5: E-Switch, Vport ingress/egress ACLs rules for spoofchk
      net/mlx5: E-Switch, Enable/disable ACL tables on demand
      net/mlx5: E-Switch, Use vport event handler for vport cleanup
      net/mlx5: E-Switch, Add promiscuous and allmulti FDB flowtable gr=
oups
      net/mlx5: E-Switch, Implement promiscuous rx modes vf request han=
dling
      net/mlx5: E-Switch, Implement trust vf ndo

Mohammed Shafi Shajakhan (5):
      ath10k: enable debugfs provision to enable Peer Stats feature
      ath10k: enable parsing per station rx duration for 10.4
      mac80211: Remove unused variable in per STA debugfs struct
      ath10k: fix return value for btcoex and peer stats debugfs
      cfg80211/nl80211: Add support for NL80211_STA_INFO_RX_DURATION

Moritz Fischer (5):
      net: macb: Fix coding style error message
      net: macb: Fix coding style warnings
      net: macb: Fix coding style suggestions
      net: macb: Use ether_addr_copy over memcpy
      net: macb: Fix simple typo

Muhammad Falak R Wani (1):
      net/hsr: Use setup_timer and mod_timer.

Nathan Sullivan (1):
      igb: adjust PTP timestamps for Tx/Rx latency

Neerav Parikh (1):
      i40e: Remove HMC AQ API implementation

Ngai-Mint Kwan (2):
      fm10k: Fix multicast mode sync issues
      fm10k: Reset multicast mode when deleting lport

Nicolas Dichtel (34):
      libnl: add more helpers to align attributes on 64-bit
      rtnl: use the new API to align IFLA_STATS*
      ipmr: align RTA_MFC_STATS on 64-bit
      ip6mr: align RTA_MFC_STATS on 64-bit
      libnl: fix help of _64bit functions
      libnl: nla_put_le64(): align on a 64-bit area
      libnl: nla_put_be64(): align on a 64-bit area
      libnl: nla_put_net64(): align on a 64-bit area
      libnl: nla_put_s64(): align on a 64-bit area
      libnl: nla_put_msecs(): align on a 64-bit area
      libnl: add nla_put_u64_64bit() helper
      xfrm: align nlattr properly when needed
      taskstats: use the libnl API to align nlattr on 64-bit
      rtnl: use nla_put_u64_64bit()
      sched: use nla_put_u64_64bit()
      ipv6: use nla_put_u64_64bit()
      ovs: use nla_put_u64_64bit()
      bridge: use nla_put_u64_64bit()
      l2tp: use nla_put_u64_64bit()
      ieee802154: use nla_put_u64_64bit()
      netfilter/ipvs: use nla_put_u64_64bit()
      wireless: use nla_put_u64_64bit()
      macsec: use nla_put_u64_64bit()
      drivers/wireless: use nla_put_u64_64bit()
      fs/quota: use nla_put_u64_64bit()
      sock_diag: align nlattr properly when needed
      ovs: align nlattr properly when needed
      rtnl: align nlattr properly when needed
      neigh: align nlattr properly when needed
      sched: align nlattr properly when needed
      taskstats: fix nl parsing in accounting/getdelays.c
      block/drbd: align properly u64 in nl messages
      ipv6: fix 4in6 tunnel receive path
      netlink: kill nla_put_u64()

Nikita Edward Baruzdin (1):
      can: sja1000: plx_pci: Add support for Marathon CAN-bus-PCIe card

Nikolay Aleksandrov (5):
      net: constify is_skb_forwardable's arguments
      net: rtnetlink: allow rtnl_fill_statsinfo to save private state c=
ounter
      net: rtnetlink: add linkxstats callbacks and attribute
      bridge: vlan: learn to count
      bridge: netlink: export per-vlan stats

Oliver Hartkopp (1):
      can: fix handling of unmodifiable configuration options

Oliver Neukum (3):
      brcm80211: correct speed testing
      usbnet: correct speed testing
      rtl8152: correct speed testing

Oren Givon (1):
      iwlwifi: edit the 9000 series PCI IDs

Pablo Neira (3):
      gtp: add initial driver for datapath of GPRS Tunneling Protocol (=
GTP-U)
      gtp: reload GTPv1 header after pskb_may_pull()
      gtp: put back reference to netns when not required anymore

Pablo Neira Ayuso (16):
      netfilter: ctnetlink: remove unnecessary inlining
      netfilter: ctnetlink: restore inlining for netlink message size c=
alculation
      netfilter: nf_tables: introduce nft_setelem_parse_flags() helper
      netfilter: nf_tables: parse element flags from nft_del_setelem()
      netfilter: nft_rbtree: introduce nft_rbtree_interval_end() helper
      netfilter: nft_rbtree: allow adjacent intervals with dynamic upda=
tes
      netfilter: nf_ct_helper: disable automatic helper assignment
      Merge tag 'ipvs-for-v4.7' of https://git.kernel.org/.../horms/ipv=
s-next
      netfilter: fix IS_ERR_VALUE usage
      netfilter: conntrack: __nf_ct_l4proto_find() always returns valid=
 pointer
      netfilter: conntrack: introduce nf_ct_acct_update()
      netfilter: conntrack: introduce clash resolution on insertion rac=
e
      openvswitch: __nf_ct_l{3,4}proto_find() always return a valid poi=
nter
      netfilter: x_tables: get rid of old and inconsistent debugging
      netfilter: nf_tables: allow set names up to 32 bytes
      Merge tag 'ipvs2-for-v4.7' of https://git.kernel.org/.../horms/ip=
vs-next

Paolo Abeni (2):
      tun: use per cpu variables for stats accounting
      tun: don't require serialization lock on tx

Parthasarathy Bhuvaragan (2):
      tipc: fix a race condition leading to subscriber refcnt bug
      tipc: fix stale links after re-enabling bearer

Patrik Flykt (1):
      Bluetooth: Allow setting BT_SECURITY_FIPS with setsockopt

Paul Durrant (4):
      xen-netback: add control ring boilerplate
      xen-netback: add control protocol implementation
      xen-netback: pass hash value to the frontend
      xen-netback: use hash value from the frontend

Pavel Tikhomirov (1):
      ixgbe: on recv increment rx.ring->stats.yields

Per Forlin (1):
      brcmf: Fix null pointer exception in bcdc_hdrpull

Peter Heise (3):
      net/hsr: Added support for HSR v1
      net/hsr: Fixed version field in ENUM
      NLA_BINARY misuse bug in HSR

Peter Oh (5):
      ath10k: set MAC timestamp in management Rx frame
      ath10k: parse Rx MAC timestamp in mgmt frame for FW 10.4
      ath10k: add a support of set_tsf on vdev interface
      ath10k: update 10.4 WMI vdev parameters
      ath10k: enable set_tsf vdev command to WMI 10.4

Petri Gynther (4):
      net: bcmgenet: cleanup for bcmgenet_xmit()
      net: bcmgenet: cleanup for bcmgenet_xmit_frag()
      net: bcmgenet: cleanup for dmadesc_set()
      net: bcmgenet: add BQL support

Phil Sutter (3):
      staging: rtl8188eu: Convert to using IFF_NO_QUEUE
      openvswitch: Convert to using IFF_NO_QUEUE
      macsec: Convert to using IFF_NO_QUEUE

Philippe Reynes (18):
      net: ethtool: export conversion function between u32 and link mod=
e
      phy: add generic function to support ksetting support
      fec: move to new ethtool api {get|set}_link_ksettings
      net: ethernet: gianfar: move to new ethtool api {get|set}_link_ks=
ettings
      net: ethernet: ucc: move to new ethtool api {get|set}_link_ksetti=
ngs
      net: ethernet: fs-enet: move to new ethtool api {get|set}_link_ks=
ettings
      net: ethernet: fec_mpc52xx: move to new ethtool api {get|set}_lin=
k_ksettings
      net: phy: add phy_ethtool_{get|set}_link_ksettings
      net: ethernet: fec: use phydev from struct net_device
      net: ethernet: fec: use phy_ethtool_{get|set}_link_ksettings
      net: ethernet: gianfar: use phydev from struct net_device
      net: ethernet: gianfar: use phy_ethtool_{get|set}_link_ksettings
      net: ethernet: ftgmac100: use phydev from struct net_device
      net: ethernet: ftgmac100: use phy_ethtool_{get|set}_link_ksetting=
s
      net: ethernet: fs-enet: use phydev from struct net_device
      net: ethernet: fs-enet: use phy_ethtool_{get|set}_link_ksettings
      net: ethernet: fec-mpc52xx: use phydev from struct net_device
      net: ethernet: fec-mpc52xx: use phy_ethtool_{get|set}_link_ksetti=
ngs

Pontus Fuchs (15):
      wcn36xx: Clean up wcn36xx_smd_send_beacon
      wcn36xx: Pad TIM PVM if needed
      wcn36xx: Add helper macros to cast vif to private vif and vice ve=
rsa
      wcn36xx: Use consistent name for private vif
      wcn36xx: Use define for invalid index and fix typo
      wcn36xx: Add helper macros to cast sta to priv
      wcn36xx: Fetch private sta data from sta entry instead of from vi=
f
      wcn36xx: Remove sta pointer in private vif struct
      wcn36xx: Parse trigger_ba response properly
      wcn36xx: Copy all members in config_sta v1 conversion
      wcn36xx: Use allocated self sta index instead of hard coded
      wcn36xx: Clear encrypt_type when deleting bss key
      wcn36xx: Track association state
      wcn36xx: Implement multicast filtering
      wcn36xx: Use correct command struct for EXIT_BMPS_REQ

Preethi Banala (3):
      ixgbe: Remove duplicate and unused device ID definitions
      ixgbe: Return 64 bit stats values
      ixgbe: Revise populating few registers and macro definitions

Rahul Verma (1):
      qed*: remove version dependency

Raja Mani (7):
      ath10k: free cached fw bin contents when get board id fails
      dt: bindings: add new dt entry for pre calibration in qcom, ath10=
k.txt
      ath10k: pass cal data location as an argument to ath10k_download_=
cal_{file|dt}
      ath10k: move cal data len to hw_params
      ath10k: incorporate qca4019 cal data download sequence
      ath10k: introduce Extended Resource Config support for 10.4
      ath10k: add dynamic tx mode switch config support for qca4019

Rajkumar Manoharan (17):
      ath10k: fix firmware assert in monitor mode
      ath10k: handle channel change htt event
      ath10k: move mgmt descriptor limit handle under mgmt_tx
      ath10k: speedup htt rx descriptor processing for tx completion
      ath10k: copy tx fetch indication message
      ath10k: remove unused fw_desc processing
      ath10k: cleanup amsdu processing for rx indication
      ath10k: speedup htt rx descriptor processing for rx_ind
      ath10k: register ath10k_htt_htc_t2h_msg_handler
      ath10k: cleanup copy engine receive next completion
      ath10k: reuse copy engine 5 (htt rx) descriptors
      ath10k: combine txrx and replenish task
      ath10k: fix calibration init sequence of qca99x0
      ath10k: remove unnecessary warning for probe response drops
      ath10k: fix unconditional num_mpdus_ready subtraction
      ath10k: remove MSI range support
      ath10k: fix rx_channel during hw reconfigure

Rana Shahout (1):
      net/mlx5e: Allocate set of queue counters per netdev

Richard Alpe (2):
      tipc: check nl sock before parsing nested attributes
      tipc: fix nametable publication field in nl compat

Roopa Prabhu (2):
      rtnetlink: rtnl_fill_stats: avoid an unnecssary stats copy
      rtnetlink: add new RTM_GETSTATS message to dump link stats

Rostislav Pehlivanov (1):
      ixgbe: add a callback to set the maximum transmit bitrate

Saeed Mahameed (4):
      net/mlx5: Update mlx5_ifc hardware features
      net/mlx5e: Delay skb->data access
      net/mlx5e: Fix checksum handling for non-stripped vlan packets
      net/mlx5e: Enable CQE compression when PCI is slower than link

Samudrala, Sridhar (2):
      net: sched: Move TCA_CLS_FLAGS_SKIP_HW to uapi header file.
      net: cls_u32: Add support for skip-sw flag to tc u32 classifier.

Sara Sharon (16):
      iwlwifi: pcie: clear trans reference on queue stop
      iwlwifi: pcie: fix global table size
      iwlwifi: pcie: enable interrupts explicitly on resume
      iwlwifi: pcie: do not pad QoS AMSDU
      iwlwifi: mvm: add support for new TX CMD API
      iwlwifi: pcie: write to legacy register also in MQ
      iwlwifi: remove support for fw older than -16.ucode
      iwlwifi: mvm: report checksum is done also for IPv6 packets
      iwlwifi: pcie: request one more interrupt vector
      iwlwifi: mvm: improve RSS configuration
      iwlwifi: mvm: enable TCP/UDP checksum support for 9000 family
      mac80211: allow not sending MIC up from driver for HW crypto
      mac80211: synchronize driver rx queues before removing a station
      mac80211: add NETIF_F_RXCSUM to features white list
      mac80211: enable starting BA session with custom timeout
      mac80211: allow same PN for AMSDU sub-frames

Satish Baddipadige (1):
      bnxt_en: Fix invalid max channel parameter in ethtool -l.

Sergei Shtylyov (16):
      ravb: make ravb_ptp_interrupt() *void*
      of_mdio: make of_mdiobus_register_{device|phy}() *void*
      sh_eth: get rid of the 2nd parameter to sh_eth_dev_init()
      phylib: don't return NULL from get_phy_device()
      xgene: get_phy_device() doesn't return NULL anymore
      fixed_phy: get_phy_device() doesn't return NULL anymore
      mdio_bus: get_phy_device() doesn't return NULL anymore
      of_mdio: get_phy_device() doesn't return NULL anymore
      sh_eth: use EDMR_SRST_GETHER in sh_eth_check_reset()
      sh_eth: rename ARSTR register bit
      mdio_bus: don't return NULL from mdiobus_scan()
      pxa168_eth: mdiobus_scan() doesn't return NULL anymore
      sh_eth: call sh_eth_tsu_write() from sh_eth_chip_reset_giga()
      sh_eth: reuse sh_eth_chip_reset()
      lxt: simplify lxt97[01]_config_intr()
      lxt: simplify lxt970_config_init()

Shannon Nelson (13):
      i40e: Remove MSIx only if created
      i40e: Assure that adminq is alive in debug mode
      i40e: Remove timer and task only if created
      i40e: Change unknown event error msg to ignore message
      i40e: Disable link polling
      i40e: Request PHY media event at reset time
      i40e: Leave debug_mask cleared at init
      i40e: Restrict VF poll mode to only single function mode devices
      i40e: Move NVM variable out of AQ struct
      i40e: Move NVM event wait check to NVM code
      i40e: Code cleanup in i40e_add_fdir_ethtool
      i40e: Specify AQ event opcode to wait for
      i40e: Implement the API function for aq_set_switch_config

Shengzhen Li (3):
      mwifiex: check revision id while choosing PCIe firmware
      mwifiex: add pcie usb/uart firmware download support
      mwifiex: add default setting for pcie firmware download

Simon Horman (1):
      irda: sh_irda: remove driver

Simon Wunderlich (5):
      batman-adv: Start new development cycle
      batman-adv: fix debuginfo macro style issue
      batman-adv: move and restructure batadv_v_ogm_forward
      batman-adv: Merge batadv_v_ogm_orig_update into batadv_v_ogm_rout=
e_update
      batman-adv: add detection for complex bridge loops

Soheil Hassas Yeganeh (9):
      tcp: accept SOF_TIMESTAMPING_OPT_ID for passive TFO
      tcp: use one bit in TCP_SKB_CB to mark ACK timestamps
      sock: accept SO_TIMESTAMPING flags in socket cmsg
      ipv4: process socket-level control messages in IPv4
      ipv6: process socket-level control messages in IPv6
      sock: enable timestamping using control messages
      sock: document timestamping via cmsg in Documentation
      tcp: remove an unnecessary check in tcp_tx_timestamp
      tcp: remove SKBTX_ACK_TSTAMP since it is redundant

Sowmini Varadhan (4):
      ixgbe: use eth_platform_get_mac_address()
      skbuff: Add pskb_extract() helper function
      RDS: TCP: Call pskb_extract() helper function
      skbuff: remove unused variable `doff'

Sridhar Samudrala (3):
      ixgbe: make 'action' field in struct ixgbe_fdir_filter a u64 valu=
e
      net_sched: act_mirred: add helper inlines to access tcf_mirred in=
fo
      ixgbe: Add support for redirect action to cls_u32 offloads

Srinivas Kandagatla (2):
      MAINTAINERS: add qcom i2c and spi drivers to list
      MAINTAINERS: add qcom clocks to the maintainers list

Stefan Assmann (3):
      i40e: call ndo_stop() instead of dev_close() when running offline=
 selftest
      e1000e: call ndo_stop() instead of dev_close() when running offli=
ne selftest
      e1000: call ndo_stop() instead of dev_close() when running offlin=
e selftest

Stefan Schmidt (4):
      ieee802154: atusb: implement .set_csma_params ops callback
      ieee802154: atusb: implement .set_cca_ed_level ops callback
      ieee802154: atusb: implement .set_cca_mode ops callback
      ieee802154: atusb: update my copyright years for this driver

Stephane Bryant (3):
      netfilter: bridge: add nf_afinfo to enable queuing to userspace
      netfilter: bridge: pass L2 header and VLAN as netlink attributes =
in queues to userspace
      netfilter: bridge: nf queue verdict to use NFQA_VLAN and NFQA_L2H=
DR

Steve Shih (1):
      e1000e: fix ethtool autoneg off for non-copper

Steve deRosier (1):
      ath6kl: ignore WMI_TXE_NOTIFY_EVENTID based on fw capability flag=
s

Sudarsana Reddy Kalluru (7):
      qed: add Rx flow hash/indirection support.
      qede: add Rx flow hash/indirection support.
      qed: add support for link pause configuration.
      qed: add infrastructure for device self tests.
      qede: add support for selftests.
      qede: add implementation for internal loopback test.
      qed: add support for dcbx.

Sudip Mukherjee (1):
      ieee802154/adf7242: fix memory leak of firmware

Sven Eckelmann (21):
      mac80211: document only injected *_RADIOTAP_* flags
      mac80211: fix parsing of 40Mhz in injected radiotap header
      MAINTAINERS: Mark BATMAN ADVANCED mailing list as moderated
      MAINTAINERS: Add BATMAN ADVANCED documentation files
      batman-adv: Fix checkpatch warning about 'unsigned' type
      batman-adv: Fix kerneldoc for batadv_compare_claim
      batman-adv: Add kernel-doc for batadv_interface_rx
      batman-adv: Fix function names on new line starting with '*'
      batman-adv: Split batadv_iv_ogm_orig_del_if function
      batman-adv: Remove unused parameter recv_if of batadv_interface_r=
x
      batman-adv: Remove hdr_size skb size check in batadv_interface_rx
      batman-adv: Check hard_iface refcnt before calling function
      batman-adv: Check hard_iface refcnt when receiving skb
      batman-adv: Increase hard_iface refcnt for ptype
      batman-adv: Use kref_get for batadv_tvlv_container_get
      batman-adv: Use kref_get for batadv_nc_get_nc_node
      batman-adv: Use kref_get for batadv_gw_select
      batman-adv: Use kref_get for batadv_gw_node_add
      batman-adv: Use kref_get for hard_iface subfunctions
      batman-adv: Use kref_get for _batadv_update_route
      batman-adv: Use bool as return type for boolean functions

Takashi Iwai (1):
      Bluetooth: vhci: Fix race at creating hci device

Taku Izumi (7):
      fjes: optimize timeout value
      fjes: fix incorrect statistics information in fjes_xmit_frame()
      fjes: fix bitwise check bug in fjes_raise_intr_rxdata_task
      fjes: Enhance changing MTU related work
      fjes: Introduce spinlock for rx_status
      fjes: Update fjes driver version : 1.1
      fjes: Fix unnecessary spinlock_irqsave

Tariq Toukan (14):
      net/mlx5: Fix mlx5 ifc cmd_hca_cap bad offsets
      net/mlx5: Introduce device queue counters
      net/mlx5e: Use only close NUMA node for default RSS
      net/mlx5e: Use function pointers for RX data path handling
      net/mlx5e: Support RX multi-packet WQE (Striding RQ)
      net/mlx5e: Added ICO SQs
      net/mlx5e: Add fragmented memory support for RX multi packet WQE
      net/mlx5e: Use napi_alloc_skb for RX SKB allocations
      net/mlx5e: Remove redundant barrier
      net/mlx5e: Add ethtool counter for RX buffer allocation failures
      net/mlx5e: Direct TIR per RQ
      net/mlx5e: CQE compression
      net/mlx5e: Expand WQE stride when CQE compression is enabled
      net/mlx4_core: Fix access to uninitialized index

Tedd Ho-Jeong An (1):
      Bluetooth: Add support for Intel Bluetooth device 8265 [8087:0a2b=
]

Thomas Falcon (2):
      ibmvnic: map L2/L3/L4 header descriptors to firmware
      ibmvnic: enable RX checksum offload

Tina Ruchandani (1):
      prism54: isl_38xx: Replace 'struct timeval'

Tom Herbert (24):
      net: Checks skb_dst to be NULL in inet_iif
      udp: Add udp6_lib_lookup_skb and udp4_lib_lookup_skb
      udp: Add GRO functions to UDP socket
      udp: Add socket based GRO and config
      vxlan: change vxlan to use UDP socket GRO
      fou: change to use UDP socket GRO
      geneve: change to use UDP socket GRO
      udp: Remove udp_offloads
      ila: Add struct definitions and helpers
      ila: xlat changes
      ila: add checksum neutral ILA translations
      ipv6: Cleanup IPv6 tunnel receive path
      gre: Move utility functions to common headers
      gre6: Cleanup GREv6 receive path, call common GRE functions
      ipv6: Create ip6_tnl_xmit
      gre: Create common functions for transmit
      ipv6: Generic tunnel cleanup
      gre6: Cleanup GREv6 transmit path, call common GRE functions
      ip6_gre: Fix MTU setting
      gre6: Fix flag translations
      ip6_gre: Set inner protocol correctly in __gre6_xmit
      ip6: Don't set transport header in IPv6 tunneling
      ip6_gre: Use correct flags for reading TUNNEL_SEQ
      ila: ipv6/ila: fix nlsize calculation for lwtunnel

Tony Nguyen (1):
      ixgbevf: Remove unused parameter

Usha Ketineni (1):
      ixgbe: Disable DCB and FCoE for X550EM_x and x550em_a

Uwe Kleine-K=F6nig (1):
      phy: add support for a reset-gpio specification

Vaishali Thakkar (1):
      net: fjes: Use resource_size

Vasanthakumar Thiagarajan (1):
      ath10k: advertise force AP scan feature

Vishal Thanki (2):
      rt2x00usb: Use usb anchor to manage URB
      mwifiex: fix the incorrect WARN_ON during suspend

Vitaly Kuznetsov (6):
      hv_netvsc: move start_remove flag to net_device_context
      hv_netvsc: use start_remove flag to protect netvsc_link_change()
      hv_netvsc: untangle the pointer mess
      hv_netvsc: get rid of struct net_device pointer in struct netvsc_=
device
      hv_netvsc: synchronize netvsc_change_mtu()/netvsc_set_channels() =
with netvsc_remove()
      hv_netvsc: set nvdev link after populating chn_table

Vittorio Gambaletta (VittGam) (2):
      ath9k: Add a module parameter to invert LED polarity.
      ath9k: Fix LED polarity for some Mini PCI AR9220 MB92 cards.

Vivien Didelot (45):
      net: dsa: mv88e6xxx: protect SID register access
      net: dsa: mv88e6xxx: protect FID registers access
      net: dsa: mv88e6xxx: variable number of databases
      net: dsa: mv88e6xxx: support 256 databases
      net: dsa: mv88e6xxx: map destination addresses for 6185
      net: dsa: mv88e6131: enable hardware bridging
      net: dsa: document missing functions
      net: dsa: make the STP state function return void
      net: dsa: make the FDB add function return void
      net: dsa: make the VLAN add function return void
      net: dsa: constify probed name
      net: dsa: mv88e6xxx: drop double ds assignment
      net: dsa: mv88e6xxx: drop revision probing
      net: dsa: mv88e6xxx: read switch ID in probe
      net: dsa: mv88e6xxx: add switch info
      net: dsa: mv88e6xxx: add family to info
      net: dsa: mv88e6xxx: add number of ports to info
      net: dsa: mv88e6xxx: add number of db to info
      net: dsa: mv88e6xxx: remove switch ID from ps
      net: dsa: kill circular reference with slave priv
      net: dsa: remove tag_protocol from dsa_switch
      net: dsa: mv88e6xxx: add flags to info
      net: dsa: mv88e6xxx: factorize PHY access with PPU
      net: dsa: mv88e6xxx: factorize PHY indirect access
      net: dsa: mv88e6xxx: factorize EEPROM access
      net: dsa: mv88e6xxx: factorize temperature access
      net: dsa: mv88e6xxx: factorize MAC address setting
      net: dsa: mv88e6xxx: factorize EEE access
      net: dsa: mv88e6131: add registers access
      net: dsa: mv88e6xxx: factorize bridge support
      net: dsa: mv88e6xxx: factorize VTU access
      net: dsa: mv88e6xxx: factorize ATU access
      net: dsa: mv88e6xxx: factorize switch reset
      net: dsa: mv88e6xxx: factorize global setup
      net: dsa: mv88e6xxx: factorize GLOBAL_CONTROL setup
      net: dsa: mv88e6131: drop VLAN Ethertype setup
      net: dsa: mv88e6xxx: factorize GLOBAL_MONITOR_CONTROL setup
      net: dsa: mv88e6xxx: factorize GLOBAL_CONTROL_2 setup
      net: dsa: mv88e6131: drop frames priorities setup
      net: dsa: mv88e6xxx: factorize switch setup
      net: dsa: mv88e6131: use EDSA tag protocol
      net: dsa: mv88e6xxx: factorize the switch driver
      net: dsa: mv88e6xxx: abstract VTU/STU data access
      net: dsa: mv88e6xxx: add STU capability
      net: dsa: mv88e6xxx: remove bridge work

Vladimir Kondratiev (1):
      wil6210: replay attack detection

WANG Cong (1):
      net_sched: close another race condition in tcf_mirred_release()

Wei Wang (1):
      ipv6: add new struct ipcm6_cookie

Wei-Ning Huang (1):
      mwifiex: fix NULL pointer dereference error

Weongyo Jeong (2):
      netfilter: nf_conntrack: Uses pr_fmt() for logging.
      packet: uses kfree_skb() for errors.

Willem de Bruijn (6):
      sock: break up sock_cmsg_snd into __sock_cmsg_snd and loop
      sock: convert sk_peek_offset functions to WRITE_ONCE
      sunrpc: do not pull udp headers on receive
      rxrpc: do not pull udp headers on receive
      udp: do not expect udp headers on ioctl SIOCINQ
      udp: do not expect udp headers in recv cmsg IP_CMSG_CHECKSUM

Xin Long (14):
      bridge: simplify the flush_store by calling store_bridge_parm
      bridge: simplify the forward_delay_store by calling store_bridge_=
parm
      bridge: simplify the stp_state_store by calling store_bridge_parm
      bridge: a netlink notification should be sent when those attribut=
es are changed by br_sysfs_br
      bridge: a netlink notification should be sent when those attribut=
es are changed by br_sysfs_if
      bridge: a netlink notification should be sent when those attribut=
es are changed by ioctl
      sctp: add sctp_info dump api for sctp_diag
      sctp: export some apis or variables for sctp_diag and reuse some =
for proc
      sctp: export some functions for sctp_diag in inet_diag
      sctp: add the sctp_diag.c file
      sctp: merge the seq_start/next/exits in remaddrs and assocs
      sctp: fix some rhashtable functions using in sctp proc/diag
      net: use jiffies_to_msecs to replace EXPIRES_IN_MS in inet/sctp_d=
iag
      sctp: sctp_diag should fill RMEM_ALLOC with asoc->rmem_alloc when=
 rcvbuf_policy is set

Xinming Hu (10):
      mwifiex: remove redundant GFP_DMA flag
      mwifiex: schedule main workqueue for transmitting bridge packets
      mwifiex: AMSDU Rx frame handling in AP mode
      mwifiex: dump pcie scratch registers
      mwifiex: do not wait on semaphore during card removal
      dt: bindings: add MARVELL's sd8xxx wireless device
      mwifiex: add platform specific wakeup interrupt support
      mwifiex: stop background scan when net device closed
      dt: bindings: add MARVELL's bt-sd8xxx wireless device
      btmrvl: add platform specific wakeup interrupt support

Yang Shi (1):
      bpf: arm64: remove callee-save registers use for tmp registers

Yisen.Zhuang\(Zhuangyuzeng\) (15):
      net: hns: add a new dsaf mode for debug port
      net: hns: add attribute port-idx-in-ae in enet node.
      net: hns: add attribute reset-field-offset for dsaf node
      net: hns: add syscon operation for dsaf
      net: hns: separate debug dsaf device from service dsaf device
      net: hns: add attribute cpld_ctrl for dsaf port node
      net: hns: add attribute port-rst-offset for dsaf port node
      net: hns: add attribute port-mode-offset for dsaf port node
      Documentation: Bindings: Update DT binding for separating dsaf de=
v support
      Documentation: Bindings: add port-idx-in-ae for enet node
      dts: hisi: update hns dst for separating dsaf dev support
      net: hns: remove cpld-ctrl-reg and add cell in the cpld-syscon pr=
operty
      net: hns: change port-id property to reg property in dsaf port no=
de
      Documentation: Bindings: Update DT binding for hns dsaf node
      dts: hisi: update hns dst for changing property port-id to reg

Yuchung Cheng (1):
      tcp: remove cwnd moderation after recovery

Yuval Mintz (22):
      qed* - bump driver versions to 8.7.1.20
      qed*: Align statistics names
      qede: Add support for ethtool private flags
      qed*: Conditions for changing link
      qed: Add CONFIG_QED_SRIOV
      qed: Add VF->PF channel infrastructure
      qed: Introduce VFs
      qed: IOV configure and FLR
      qed: IOV l2 functionality
      qed: Bulletin and Link
      qed: Align TLVs
      qede: Add VF support
      qed*: Support PVID configuration
      qed*: Support forced MAC
      qed*: IOV link control
      qed*: IOV support spoof-checking
      qed*: support ndo_get_vf_config
      qed*: Tx-switching configuration
      qed: Correct PF-sanity check
      qed: Improve VF interrupt reset
      qed: Allow more than 16 VFs
      qed: VFs gracefully accept lack of PM

Zefir Kurtisi (1):
      ath9k: interpret requested txpower in EIRP domain

chas williams (1):
      ixgbe: Extend trust to allow guest to set unicast address

fran=E7ois romieu (1):
      pch_gbe: replace private tx ring lock with common netif_tx_lock

samanthakumar (2):
      udp: remove headers from UDP packets before queueing
      udp: enable MSG_PEEK at non-zero offset

stephen hemminger (1):
      gre: eliminate holes in ip_tunnel

wangweidong (1):
      phy: make some bits preserved while setup forced mode

 Documentation/DocBook/80211.tmpl                   |    2 +-
 Documentation/accounting/getdelays.c               |    5 +-
 Documentation/devicetree/bindings/btmrvl.txt       |   29 -
 .../devicetree/bindings/net/apm-xgene-enet.txt     |    2 +
 Documentation/devicetree/bindings/net/dsa/dsa.txt  |    2 -
 .../devicetree/bindings/net/dsa/marvell.txt        |   35 +
 .../devicetree/bindings/net/hisilicon-hns-dsaf.txt |   57 +-
 .../devicetree/bindings/net/hisilicon-hns-nic.txt  |   30 +-
 .../devicetree/bindings/net/marvell-bt-sd8xxx.txt  |   56 +
 .../devicetree/bindings/net/microchip,enc28j60.txt |   59 +
 .../devicetree/bindings/net/nfc/pn533-i2c.txt      |   31 +
 Documentation/devicetree/bindings/net/phy.txt      |    3 +
 Documentation/devicetree/bindings/net/stmmac.txt   |    2 +
 .../bindings/net/wireless/marvell-sd8xxx.txt       |   63 +
 .../bindings/net/wireless/qcom,ath10k.txt          |   23 +-
 Documentation/networking/bonding.txt               |    4 +-
 Documentation/networking/dsa/bcm_sf2.txt           |    2 +-
 Documentation/networking/dsa/dsa.txt               |   20 +-
 Documentation/networking/filter.txt                |  101 +-
 Documentation/networking/gen_stats.txt             |    6 +-
 Documentation/networking/ip-sysctl.txt             |   10 +
 Documentation/networking/mac80211-injection.txt    |   17 +-
 Documentation/networking/netdev-features.txt       |   10 +-
 Documentation/networking/netdevices.txt            |    9 +-
 Documentation/networking/segmentation-offloads.txt |  130 +
 Documentation/networking/stmmac.txt                |   44 +-
 Documentation/networking/switchdev.txt             |   28 +-
 Documentation/networking/timestamping.txt          |   48 +-
 Documentation/sysctl/net.txt                       |   11 +
 MAINTAINERS                                        |   18 +-
 arch/arm/Kconfig                                   |    2 +-
 arch/arm/configs/multi_v5_defconfig                |    5 +-
 arch/arm/configs/mvebu_v7_defconfig                |    2 +-
 arch/arm/configs/orion5x_defconfig                 |    3 +-
 arch/arm64/Kconfig                                 |    2 +-
 arch/arm64/boot/dts/apm/apm-shadowcat.dtsi         |    1 +
 arch/arm64/boot/dts/apm/apm-storm.dtsi             |    1 +
 arch/arm64/boot/dts/hisilicon/hip05_hns.dtsi       |   74 +-
 arch/arm64/net/bpf_jit_comp.c                      |   90 +-
 arch/mips/Kconfig                                  |    2 +-
 arch/powerpc/Kconfig                               |    2 +-
 arch/s390/Kconfig                                  |    2 +-
 arch/s390/net/bpf_jit_comp.c                       |   77 +-
 arch/sparc/Kconfig                                 |    2 +-
 arch/tile/configs/tilegx_defconfig                 |    3 +-
 arch/tile/configs/tilepro_defconfig                |    3 +-
 arch/um/drivers/net_kern.c                         |    4 +-
 arch/x86/Kconfig                                   |    2 +-
 arch/x86/net/bpf_jit_comp.c                        |   70 +-
 arch/xtensa/platforms/iss/network.c                |    2 +-
 drivers/block/drbd/drbd_nl.c                       |   28 +-
 drivers/bluetooth/ath3k.c                          |    8 +-
 drivers/bluetooth/btmrvl_drv.h                     |   11 +
 drivers/bluetooth/btmrvl_main.c                    |   35 +-
 drivers/bluetooth/btmrvl_sdio.c                    |   79 +
 drivers/bluetooth/btmrvl_sdio.h                    |    6 +
 drivers/bluetooth/btusb.c                          |   12 +-
 drivers/bluetooth/hci_bcm.c                        |    1 +
 drivers/bluetooth/hci_bcsp.c                       |   57 +-
 drivers/bluetooth/hci_intel.c                      |    6 +-
 drivers/bluetooth/hci_ldisc.c                      |   11 +-
 drivers/bluetooth/hci_uart.h                       |    1 +
 drivers/bluetooth/hci_vhci.c                       |   28 +-
 drivers/char/pcmcia/synclink_cs.c                  |    4 +-
 drivers/firewire/net.c                             |    2 +-
 drivers/infiniband/hw/i40iw/i40iw_main.c           |    2 +-
 drivers/infiniband/hw/mlx4/qp.c                    |   27 +-
 drivers/infiniband/hw/mlx5/main.c                  |    3 +-
 drivers/infiniband/hw/nes/nes_nic.c                |   16 +-
 drivers/infiniband/ulp/ipoib/ipoib_cm.c            |    2 +-
 drivers/infiniband/ulp/ipoib/ipoib_ib.c            |    2 +-
 drivers/infiniband/ulp/ipoib/ipoib_main.c          |    2 +-
 drivers/isdn/hardware/eicon/message.c              |   21 +-
 drivers/isdn/hysdn/hysdn_net.c                     |    2 +-
 drivers/isdn/i4l/isdn_net.c                        |    4 +-
 drivers/isdn/i4l/isdn_x25iface.c                   |    2 +-
 drivers/message/fusion/mptlan.c                    |    2 +-
 drivers/net/Kconfig                                |   17 +
 drivers/net/Makefile                               |    1 +
 drivers/net/appletalk/cops.c                       |    2 +-
 drivers/net/arcnet/com90xx.c                       |    2 +-
 drivers/net/can/dev.c                              |   56 +-
 drivers/net/can/ifi_canfd/ifi_canfd.c              |  187 +-
 drivers/net/can/janz-ican3.c                       |  104 +-
 drivers/net/can/m_can/m_can.c                      |    2 +-
 drivers/net/can/mscan/mscan.c                      |    4 +-
 drivers/net/can/sja1000/plx_pci.c                  |   64 +-
 drivers/net/can/sja1000/sja1000.c                  |    6 +-
 drivers/net/can/spi/mcp251x.c                      |    3 +-
 drivers/net/can/usb/ems_usb.c                      |    4 +-
 drivers/net/can/usb/esd_usb2.c                     |    4 +-
 drivers/net/can/usb/gs_usb.c                       |    3 +-
 drivers/net/can/usb/peak_usb/pcan_usb_core.c       |    4 +-
 drivers/net/cris/eth_v10.c                         |    2 +-
 drivers/net/dsa/Kconfig                            |   45 +-
 drivers/net/dsa/Makefile                           |   15 +-
 drivers/net/dsa/bcm_sf2.c                          |   62 +-
 drivers/net/dsa/mv88e6060.c                        |   47 +-
 drivers/net/dsa/mv88e6060.h                        |   11 +
 drivers/net/dsa/mv88e6123.c                        |  124 -
 drivers/net/dsa/mv88e6131.c                        |  177 -
 drivers/net/dsa/mv88e6171.c                        |  123 -
 drivers/net/dsa/mv88e6352.c                        |  345 --
 drivers/net/dsa/mv88e6xxx.c                        | 2280 +++++++-----
 drivers/net/dsa/mv88e6xxx.h                        |  381 ++-
 drivers/net/ethernet/3com/3c509.c                  |    2 +-
 drivers/net/ethernet/3com/3c515.c                  |    2 +-
 drivers/net/ethernet/3com/3c574_cs.c               |    2 +-
 drivers/net/ethernet/3com/3c589_cs.c               |    2 +-
 drivers/net/ethernet/3com/3c59x.c                  |    2 +-
 drivers/net/ethernet/8390/axnet_cs.c               |    6 +-
 drivers/net/ethernet/8390/lib8390.c                |    4 +-
 drivers/net/ethernet/adaptec/starfire.c            |    2 +-
 drivers/net/ethernet/adi/bfin_mac.c                |    2 +-
 drivers/net/ethernet/agere/et131x.c                |    4 +-
 drivers/net/ethernet/allwinner/sun4i-emac.c        |    6 +-
 drivers/net/ethernet/amd/7990.c                    |   12 +-
 drivers/net/ethernet/amd/a2065.c                   |    9 +-
 drivers/net/ethernet/amd/atarilance.c              |    2 +-
 drivers/net/ethernet/amd/au1000_eth.c              |    2 +-
 drivers/net/ethernet/amd/declance.c                |    2 +-
 drivers/net/ethernet/amd/lance.c                   |    2 +-
 drivers/net/ethernet/amd/ni65.c                    |    4 +-
 drivers/net/ethernet/amd/nmclan_cs.c               |    2 +-
 drivers/net/ethernet/amd/pcnet32.c                 |    4 +-
 drivers/net/ethernet/amd/sunlance.c                |    2 +-
 drivers/net/ethernet/apm/xgene/xgene_enet_cle.c    |    2 +-
 drivers/net/ethernet/apm/xgene/xgene_enet_cle.h    |    2 +-
 drivers/net/ethernet/apm/xgene/xgene_enet_hw.c     |    2 +-
 drivers/net/ethernet/apm/xgene/xgene_enet_main.c   |   15 +-
 drivers/net/ethernet/apm/xgene/xgene_enet_main.h   |    2 +-
 drivers/net/ethernet/atheros/alx/main.c            |    2 +-
 drivers/net/ethernet/atheros/atl1c/atl1c.h         |    3 +-
 drivers/net/ethernet/atheros/atl1c/atl1c_main.c    |   11 -
 drivers/net/ethernet/atheros/atl1e/atl1e.h         |    1 -
 drivers/net/ethernet/atheros/atl1e/atl1e_main.c    |   12 +-
 drivers/net/ethernet/broadcom/bcmsysport.c         |    8 +-
 drivers/net/ethernet/broadcom/bnxt/bnxt.c          |  349 +-
 drivers/net/ethernet/broadcom/bnxt/bnxt.h          |   35 +-
 drivers/net/ethernet/broadcom/bnxt/bnxt_ethtool.c  |  300 +-
 drivers/net/ethernet/broadcom/bnxt/bnxt_ethtool.h  |    4 +-
 drivers/net/ethernet/broadcom/bnxt/bnxt_fw_hdr.h   |    2 +-
 drivers/net/ethernet/broadcom/bnxt/bnxt_hsi.h      |  467 ++-
 drivers/net/ethernet/broadcom/bnxt/bnxt_nvm_defs.h |    2 +-
 drivers/net/ethernet/broadcom/bnxt/bnxt_sriov.c    |   44 +-
 drivers/net/ethernet/broadcom/bnxt/bnxt_sriov.h    |    3 +-
 drivers/net/ethernet/broadcom/cnic.c               |    5 +-
 drivers/net/ethernet/broadcom/genet/bcmgenet.c     |   54 +-
 drivers/net/ethernet/broadcom/sb1250-mac.c         |    2 +-
 drivers/net/ethernet/broadcom/tg3.c                |    2 +-
 drivers/net/ethernet/cadence/macb.c                |  152 +-
 drivers/net/ethernet/cavium/liquidio/lio_main.c    |    4 +-
 drivers/net/ethernet/cavium/octeon/octeon_mgmt.c   |    2 +-
 drivers/net/ethernet/cavium/thunder/nicvf_main.c   |    2 +-
 drivers/net/ethernet/chelsio/cxgb/sge.c            |    3 +-
 drivers/net/ethernet/chelsio/cxgb4/cxgb4.h         |   40 +
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_dcb.c     |    2 +-
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_debugfs.c |  100 +
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c    |  147 +-
 drivers/net/ethernet/chelsio/cxgb4/sge.c           |    2 +
 drivers/net/ethernet/chelsio/cxgb4/t4_hw.c         |  330 +-
 drivers/net/ethernet/chelsio/cxgb4/t4_hw.h         |    7 +
 drivers/net/ethernet/chelsio/cxgb4/t4fw_api.h      |    5 +
 drivers/net/ethernet/chelsio/cxgb4vf/adapter.h     |    4 +
 .../net/ethernet/chelsio/cxgb4vf/cxgb4vf_main.c    |  115 +-
 drivers/net/ethernet/chelsio/cxgb4vf/sge.c         |    2 +-
 drivers/net/ethernet/chelsio/cxgb4vf/t4vf_common.h |   29 +
 drivers/net/ethernet/chelsio/cxgb4vf/t4vf_hw.c     |   72 +-
 drivers/net/ethernet/cisco/enic/enic_main.c        |    1 +
 drivers/net/ethernet/davicom/dm9000.c              |   15 +-
 drivers/net/ethernet/dec/tulip/de4x5.c             |   11 +-
 drivers/net/ethernet/dec/tulip/dmfe.c              |   45 +-
 drivers/net/ethernet/dec/tulip/pnic.c              |    6 +-
 drivers/net/ethernet/dec/tulip/tulip_core.c        |    2 +-
 drivers/net/ethernet/dec/tulip/uli526x.c           |    4 +-
 drivers/net/ethernet/dec/tulip/winbond-840.c       |    2 +-
 drivers/net/ethernet/dlink/dl2k.c                  |    2 +-
 drivers/net/ethernet/dlink/sundance.c              |    2 +-
 drivers/net/ethernet/emulex/benet/be_main.c        |   10 +-
 drivers/net/ethernet/faraday/ftgmac100.c           |   36 +-
 drivers/net/ethernet/fealnx.c                      |    2 +-
 drivers/net/ethernet/freescale/fec.h               |    1 -
 drivers/net/ethernet/freescale/fec_main.c          |   71 +-
 drivers/net/ethernet/freescale/fec_mpc52xx.c       |   57 +-
 .../net/ethernet/freescale/fs_enet/fs_enet-main.c  |   45 +-
 drivers/net/ethernet/freescale/fs_enet/fs_enet.h   |    1 -
 drivers/net/ethernet/freescale/fs_enet/mac-fcc.c   |    4 +-
 drivers/net/ethernet/freescale/fs_enet/mac-fec.c   |    6 +-
 drivers/net/ethernet/freescale/fs_enet/mac-scc.c   |    2 +-
 drivers/net/ethernet/freescale/gianfar.c           |   44 +-
 drivers/net/ethernet/freescale/gianfar.h           |    1 -
 drivers/net/ethernet/freescale/gianfar_ethtool.c   |   52 +-
 drivers/net/ethernet/freescale/ucc_geth_ethtool.c  |   17 +-
 drivers/net/ethernet/fujitsu/fmvj18x_cs.c          |    2 +-
 drivers/net/ethernet/hisilicon/hix5hd2_gmac.c      |    2 +-
 drivers/net/ethernet/hisilicon/hns/hns_ae_adapt.c  |   93 +-
 drivers/net/ethernet/hisilicon/hns/hns_dsaf_mac.c  |  260 +-
 drivers/net/ethernet/hisilicon/hns/hns_dsaf_mac.h  |   12 +-
 drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.c |  209 +-
 drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.h |   21 +-
 drivers/net/ethernet/hisilicon/hns/hns_dsaf_misc.c |  171 +-
 drivers/net/ethernet/hisilicon/hns/hns_dsaf_ppe.c  |   67 +-
 drivers/net/ethernet/hisilicon/hns/hns_dsaf_ppe.h  |    1 -
 drivers/net/ethernet/hisilicon/hns/hns_dsaf_rcb.c  |  187 +-
 drivers/net/ethernet/hisilicon/hns/hns_dsaf_rcb.h  |    2 +-
 drivers/net/ethernet/hisilicon/hns/hns_dsaf_reg.h  |   44 +-
 drivers/net/ethernet/hisilicon/hns/hns_enet.c      |   23 +-
 drivers/net/ethernet/hisilicon/hns/hns_enet.h      |    3 +
 drivers/net/ethernet/hp/hp100.c                    |    2 +-
 drivers/net/ethernet/i825xx/82596.c                |    2 +-
 drivers/net/ethernet/i825xx/lib82596.c             |    2 +-
 drivers/net/ethernet/i825xx/sun3_82586.c           |    4 +-
 drivers/net/ethernet/ibm/emac/core.c               |    4 +-
 drivers/net/ethernet/ibm/emac/phy.c                |   26 +
 drivers/net/ethernet/ibm/ibmvnic.c                 |  251 +-
 drivers/net/ethernet/ibm/ibmvnic.h                 |    4 +
 drivers/net/ethernet/intel/Kconfig                 |   80 +-
 drivers/net/ethernet/intel/e1000/e1000.h           |    2 +
 drivers/net/ethernet/intel/e1000/e1000_ethtool.c   |    4 +-
 drivers/net/ethernet/intel/e1000/e1000_main.c      |    8 +-
 drivers/net/ethernet/intel/e1000e/80003es2lan.c    |   12 +-
 drivers/net/ethernet/intel/e1000e/82571.c          |   30 +-
 drivers/net/ethernet/intel/e1000e/e1000.h          |  111 +-
 drivers/net/ethernet/intel/e1000e/ethtool.c        |   61 +-
 drivers/net/ethernet/intel/e1000e/ich8lan.c        |   44 +-
 drivers/net/ethernet/intel/e1000e/ich8lan.h        |    8 +-
 drivers/net/ethernet/intel/e1000e/mac.c            |    2 +-
 drivers/net/ethernet/intel/e1000e/netdev.c         |  163 +-
 drivers/net/ethernet/intel/e1000e/nvm.c            |    2 +-
 drivers/net/ethernet/intel/e1000e/phy.c            |    4 +-
 drivers/net/ethernet/intel/e1000e/phy.h            |   10 +-
 drivers/net/ethernet/intel/e1000e/ptp.c            |    2 +
 drivers/net/ethernet/intel/fm10k/Makefile          |    7 +-
 drivers/net/ethernet/intel/fm10k/fm10k.h           |   51 +-
 drivers/net/ethernet/intel/fm10k/fm10k_common.c    |    4 +-
 drivers/net/ethernet/intel/fm10k/fm10k_common.h    |    4 +-
 drivers/net/ethernet/intel/fm10k/fm10k_dcbnl.c     |    4 +-
 drivers/net/ethernet/intel/fm10k/fm10k_debugfs.c   |    4 +-
 drivers/net/ethernet/intel/fm10k/fm10k_ethtool.c   |  352 +-
 drivers/net/ethernet/intel/fm10k/fm10k_iov.c       |    8 +-
 drivers/net/ethernet/intel/fm10k/fm10k_main.c      |  150 +-
 drivers/net/ethernet/intel/fm10k/fm10k_mbx.c       |    4 +-
 drivers/net/ethernet/intel/fm10k/fm10k_mbx.h       |    4 +-
 drivers/net/ethernet/intel/fm10k/fm10k_netdev.c    |   50 +-
 drivers/net/ethernet/intel/fm10k/fm10k_pci.c       |  226 +-
 drivers/net/ethernet/intel/fm10k/fm10k_pf.c        |  141 +-
 drivers/net/ethernet/intel/fm10k/fm10k_pf.h        |   21 +-
 drivers/net/ethernet/intel/fm10k/fm10k_ptp.c       |  462 ---
 drivers/net/ethernet/intel/fm10k/fm10k_tlv.c       |   44 +-
 drivers/net/ethernet/intel/fm10k/fm10k_tlv.h       |    4 +-
 drivers/net/ethernet/intel/fm10k/fm10k_type.h      |   28 +-
 drivers/net/ethernet/intel/fm10k/fm10k_vf.c        |   63 +-
 drivers/net/ethernet/intel/fm10k/fm10k_vf.h        |   14 +-
 drivers/net/ethernet/intel/i40e/i40e.h             |   33 +-
 drivers/net/ethernet/intel/i40e/i40e_adminq.c      |   37 +-
 drivers/net/ethernet/intel/i40e/i40e_adminq.h      |    1 -
 drivers/net/ethernet/intel/i40e/i40e_adminq_cmd.h  |   82 +-
 drivers/net/ethernet/intel/i40e/i40e_client.h      |    2 +-
 drivers/net/ethernet/intel/i40e/i40e_common.c      |  168 +-
 drivers/net/ethernet/intel/i40e/i40e_debugfs.c     |   36 +-
 drivers/net/ethernet/intel/i40e/i40e_devids.h      |    2 +
 drivers/net/ethernet/intel/i40e/i40e_ethtool.c     |  386 ++-
 drivers/net/ethernet/intel/i40e/i40e_fcoe.c        |   14 +-
 drivers/net/ethernet/intel/i40e/i40e_hmc.c         |    2 +-
 drivers/net/ethernet/intel/i40e/i40e_main.c        |  284 +-
 drivers/net/ethernet/intel/i40e/i40e_nvm.c         |   86 +-
 drivers/net/ethernet/intel/i40e/i40e_prototype.h   |   20 +-
 drivers/net/ethernet/intel/i40e/i40e_ptp.c         |    7 +-
 drivers/net/ethernet/intel/i40e/i40e_txrx.c        | 1065 +++---
 drivers/net/ethernet/intel/i40e/i40e_txrx.h        |  114 +-
 drivers/net/ethernet/intel/i40e/i40e_type.h        |   42 +-
 drivers/net/ethernet/intel/i40e/i40e_virtchnl.h    |   45 +-
 drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c |  509 ++-
 drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.h |   11 +-
 drivers/net/ethernet/intel/i40evf/i40e_adminq.h    |    1 -
 .../net/ethernet/intel/i40evf/i40e_adminq_cmd.h    |   70 +-
 drivers/net/ethernet/intel/i40evf/i40e_common.c    |    2 +
 drivers/net/ethernet/intel/i40evf/i40e_devids.h    |    2 +
 drivers/net/ethernet/intel/i40evf/i40e_txrx.c      | 1021 +++---
 drivers/net/ethernet/intel/i40evf/i40e_txrx.h      |  114 +-
 drivers/net/ethernet/intel/i40evf/i40e_type.h      |   51 +-
 drivers/net/ethernet/intel/i40evf/i40e_virtchnl.h  |   45 +-
 drivers/net/ethernet/intel/i40evf/i40evf.h         |   49 +-
 drivers/net/ethernet/intel/i40evf/i40evf_ethtool.c |  329 +-
 drivers/net/ethernet/intel/i40evf/i40evf_main.c    |  503 ++-
 .../net/ethernet/intel/i40evf/i40evf_virtchnl.c    |  145 +-
 drivers/net/ethernet/intel/igb/e1000_82575.c       |    8 +-
 drivers/net/ethernet/intel/igb/e1000_82575.h       |   30 +-
 drivers/net/ethernet/intel/igb/e1000_defines.h     |  108 +-
 drivers/net/ethernet/intel/igb/e1000_mac.c         |   10 +-
 drivers/net/ethernet/intel/igb/e1000_mbx.c         |    4 +-
 drivers/net/ethernet/intel/igb/e1000_nvm.c         |    2 +-
 drivers/net/ethernet/intel/igb/e1000_phy.h         |    6 +-
 drivers/net/ethernet/intel/igb/igb.h               |   40 +-
 drivers/net/ethernet/intel/igb/igb_ethtool.c       |   21 +-
 drivers/net/ethernet/intel/igb/igb_main.c          |  221 +-
 drivers/net/ethernet/intel/igb/igb_ptp.c           |   42 +-
 drivers/net/ethernet/intel/igbvf/defines.h         |    2 +-
 drivers/net/ethernet/intel/igbvf/ethtool.c         |    3 +-
 drivers/net/ethernet/intel/igbvf/igbvf.h           |    4 +-
 drivers/net/ethernet/intel/igbvf/netdev.c          |  196 +-
 drivers/net/ethernet/intel/igbvf/vf.c              |    2 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe.h           |   99 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_82598.c     |   18 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_82599.c     |   29 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_common.c    |  161 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_common.h    |    9 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_dcb.c       |   10 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_dcb_82598.c |    2 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_dcb_82599.c |    2 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_dcb_nl.c    |    6 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c   |   50 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_lib.c       |    3 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c      | 1052 +++---
 drivers/net/ethernet/intel/ixgbe/ixgbe_mbx.c       |   46 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_mbx.h       |    4 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_model.h     |   14 +
 drivers/net/ethernet/intel/ixgbe/ixgbe_phy.h       |    8 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_ptp.c       |   10 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c     |  117 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.h     |    1 +
 drivers/net/ethernet/intel/ixgbe/ixgbe_type.h      |  302 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_x540.c      |   35 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_x540.h      |    1 +
 drivers/net/ethernet/intel/ixgbe/ixgbe_x550.c      |  693 +++-
 drivers/net/ethernet/intel/ixgbevf/defines.h       |   29 +-
 drivers/net/ethernet/intel/ixgbevf/ethtool.c       |  230 +-
 drivers/net/ethernet/intel/ixgbevf/ixgbevf.h       |   37 +-
 drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c  |  298 +-
 drivers/net/ethernet/intel/ixgbevf/mbx.c           |   11 +
 drivers/net/ethernet/intel/ixgbevf/vf.c            |  224 +-
 drivers/net/ethernet/intel/ixgbevf/vf.h            |    6 +-
 drivers/net/ethernet/jme.c                         |    2 +-
 drivers/net/ethernet/korina.c                      |    8 +-
 drivers/net/ethernet/lantiq_etop.c                 |    4 +-
 drivers/net/ethernet/marvell/pxa168_eth.c          |   16 +-
 drivers/net/ethernet/marvell/sky2.c                |    2 +-
 drivers/net/ethernet/mediatek/mtk_eth_soc.c        |  106 +-
 drivers/net/ethernet/mediatek/mtk_eth_soc.h        |    4 +-
 drivers/net/ethernet/mellanox/mlx4/alloc.c         |   93 +-
 drivers/net/ethernet/mellanox/mlx4/en_cq.c         |    9 +-
 drivers/net/ethernet/mellanox/mlx4/en_netdev.c     |   42 +-
 drivers/net/ethernet/mellanox/mlx4/en_resources.c  |   31 -
 drivers/net/ethernet/mellanox/mlx4/en_rx.c         |   11 +-
 drivers/net/ethernet/mellanox/mlx4/en_tx.c         |   29 +-
 drivers/net/ethernet/mellanox/mlx4/mcg.c           |    4 +-
 drivers/net/ethernet/mellanox/mlx4/mlx4_en.h       |    2 -
 drivers/net/ethernet/mellanox/mlx5/core/Kconfig    |    7 -
 drivers/net/ethernet/mellanox/mlx5/core/Makefile   |    5 +-
 drivers/net/ethernet/mellanox/mlx5/core/cmd.c      |  309 +-
 drivers/net/ethernet/mellanox/mlx5/core/en.h       |  580 ++--
 drivers/net/ethernet/mellanox/mlx5/core/en_arfs.c  |  752 ++++
 drivers/net/ethernet/mellanox/mlx5/core/en_clock.c |    4 +
 drivers/net/ethernet/mellanox/mlx5/core/en_dcbnl.c |    6 +
 .../net/ethernet/mellanox/mlx5/core/en_ethtool.c   |  341 +-
 drivers/net/ethernet/mellanox/mlx5/core/en_fs.c    | 1060 +++---
 drivers/net/ethernet/mellanox/mlx5/core/en_main.c  | 1238 +++++--
 drivers/net/ethernet/mellanox/mlx5/core/en_rx.c    |  736 +++-
 drivers/net/ethernet/mellanox/mlx5/core/en_stats.h |  367 ++
 drivers/net/ethernet/mellanox/mlx5/core/en_tc.c    |  113 +-
 drivers/net/ethernet/mellanox/mlx5/core/en_tc.h    |    5 +-
 drivers/net/ethernet/mellanox/mlx5/core/en_tx.c    |    6 +-
 drivers/net/ethernet/mellanox/mlx5/core/en_txrx.c  |   59 +-
 drivers/net/ethernet/mellanox/mlx5/core/eswitch.c  |  978 +++++-
 drivers/net/ethernet/mellanox/mlx5/core/eswitch.h  |   43 +-
 drivers/net/ethernet/mellanox/mlx5/core/fs_cmd.c   |  135 +-
 drivers/net/ethernet/mellanox/mlx5/core/fs_cmd.h   |    7 +
 drivers/net/ethernet/mellanox/mlx5/core/fs_core.c  |  289 +-
 drivers/net/ethernet/mellanox/mlx5/core/fs_core.h  |   35 +-
 .../net/ethernet/mellanox/mlx5/core/fs_counters.c  |  226 ++
 drivers/net/ethernet/mellanox/mlx5/core/main.c     |   18 +
 .../net/ethernet/mellanox/mlx5/core/mlx5_core.h    |    2 +
 drivers/net/ethernet/mellanox/mlx5/core/port.c     |  138 +
 drivers/net/ethernet/mellanox/mlx5/core/qp.c       |   68 +
 drivers/net/ethernet/mellanox/mlx5/core/vxlan.h    |    8 +-
 drivers/net/ethernet/mellanox/mlxsw/Kconfig        |    8 +
 drivers/net/ethernet/mellanox/mlxsw/Makefile       |    1 +
 drivers/net/ethernet/mellanox/mlxsw/core.c         |  736 ++--
 drivers/net/ethernet/mellanox/mlxsw/core.h         |   82 +-
 drivers/net/ethernet/mellanox/mlxsw/reg.h          |  667 +++-
 drivers/net/ethernet/mellanox/mlxsw/spectrum.c     |  392 ++-
 drivers/net/ethernet/mellanox/mlxsw/spectrum.h     |  134 +-
 .../net/ethernet/mellanox/mlxsw/spectrum_buffers.c | 1001 ++++--
 drivers/net/ethernet/mellanox/mlxsw/spectrum_dcb.c |  480 +++
 .../ethernet/mellanox/mlxsw/spectrum_switchdev.c   |    4 +-
 drivers/net/ethernet/mellanox/mlxsw/switchx2.c     |   45 +-
 drivers/net/ethernet/micrel/ks8695net.c            |    7 +-
 drivers/net/ethernet/micrel/ksz884x.c              |    4 +-
 drivers/net/ethernet/microchip/enc28j60.c          |   34 +-
 drivers/net/ethernet/microchip/encx24j600.c        |    4 +-
 drivers/net/ethernet/moxa/moxart_ether.c           |    2 +-
 drivers/net/ethernet/natsemi/natsemi.c             |    2 +-
 drivers/net/ethernet/natsemi/sonic.c               |    2 +-
 drivers/net/ethernet/neterion/s2io.c               |    9 +-
 drivers/net/ethernet/netronome/nfp/nfp_net.h       |   22 +-
 .../net/ethernet/netronome/nfp/nfp_net_common.c    | 1101 ++++--
 drivers/net/ethernet/netronome/nfp/nfp_net_ctrl.h  |   10 +-
 .../net/ethernet/netronome/nfp/nfp_net_debugfs.c   |   24 +-
 .../net/ethernet/netronome/nfp/nfp_net_ethtool.c   |   30 +-
 drivers/net/ethernet/netx-eth.c                    |   12 +-
 drivers/net/ethernet/nuvoton/w90p910_ether.c       |    4 +-
 drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe.h    |    2 -
 .../net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c   |   12 +-
 drivers/net/ethernet/packetengines/hamachi.c       |    2 +-
 drivers/net/ethernet/packetengines/yellowfin.c     |    2 +-
 drivers/net/ethernet/qlogic/Kconfig                |   31 +
 .../net/ethernet/qlogic/netxen/netxen_nic_main.c   |    2 +-
 drivers/net/ethernet/qlogic/qed/Makefile           |    4 +-
 drivers/net/ethernet/qlogic/qed/qed.h              |   84 +-
 drivers/net/ethernet/qlogic/qed/qed_cxt.c          |  186 +-
 drivers/net/ethernet/qlogic/qed/qed_cxt.h          |   13 +
 drivers/net/ethernet/qlogic/qed/qed_dcbx.c         |  562 +++
 drivers/net/ethernet/qlogic/qed/qed_dcbx.h         |   80 +
 drivers/net/ethernet/qlogic/qed/qed_dev.c          |  740 +++-
 drivers/net/ethernet/qlogic/qed/qed_dev_api.h      |   33 +-
 drivers/net/ethernet/qlogic/qed/qed_hsi.h          |  147 +-
 drivers/net/ethernet/qlogic/qed/qed_hw.c           |   67 +-
 drivers/net/ethernet/qlogic/qed/qed_hw.h           |   10 +
 .../net/ethernet/qlogic/qed/qed_init_fw_funcs.c    |  167 +
 drivers/net/ethernet/qlogic/qed/qed_init_ops.c     |    4 +
 drivers/net/ethernet/qlogic/qed/qed_int.c          |  160 +-
 drivers/net/ethernet/qlogic/qed/qed_int.h          |   36 +-
 drivers/net/ethernet/qlogic/qed/qed_l2.c           |  717 ++--
 drivers/net/ethernet/qlogic/qed/qed_l2.h           |  239 ++
 drivers/net/ethernet/qlogic/qed/qed_main.c         |  282 +-
 drivers/net/ethernet/qlogic/qed/qed_mcp.c          |  356 +-
 drivers/net/ethernet/qlogic/qed/qed_mcp.h          |   80 +-
 drivers/net/ethernet/qlogic/qed/qed_reg_addr.h     |   53 +
 drivers/net/ethernet/qlogic/qed/qed_selftest.c     |   76 +
 drivers/net/ethernet/qlogic/qed/qed_selftest.h     |   40 +
 drivers/net/ethernet/qlogic/qed/qed_sp.h           |   36 +-
 drivers/net/ethernet/qlogic/qed/qed_sp_commands.c  |  322 +-
 drivers/net/ethernet/qlogic/qed/qed_spq.c          |   19 +-
 drivers/net/ethernet/qlogic/qed/qed_sriov.c        | 3613 ++++++++++++=
++++++++
 drivers/net/ethernet/qlogic/qed/qed_sriov.h        |  386 +++
 drivers/net/ethernet/qlogic/qed/qed_vf.c           | 1102 ++++++
 drivers/net/ethernet/qlogic/qed/qed_vf.h           |  990 ++++++
 drivers/net/ethernet/qlogic/qede/qede.h            |   45 +-
 drivers/net/ethernet/qlogic/qede/qede_ethtool.c    |  625 +++-
 drivers/net/ethernet/qlogic/qede/qede_main.c       |  501 ++-
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c   |   10 +-
 drivers/net/ethernet/qlogic/qlge/qlge_main.c       |    2 +-
 drivers/net/ethernet/qualcomm/qca_spi.c            |    4 +-
 drivers/net/ethernet/realtek/atp.c                 |    2 +-
 drivers/net/ethernet/realtek/r8169.c               |   44 +-
 drivers/net/ethernet/renesas/ravb.h                |  206 +-
 drivers/net/ethernet/renesas/ravb_main.c           |  289 +-
 drivers/net/ethernet/renesas/ravb_ptp.c            |   26 +-
 drivers/net/ethernet/renesas/sh_eth.c              |   39 +-
 drivers/net/ethernet/renesas/sh_eth.h              |    2 +-
 drivers/net/ethernet/rocker/rocker_ofdpa.c         |    4 +-
 drivers/net/ethernet/seeq/sgiseeq.c                |    4 +-
 drivers/net/ethernet/sgi/meth.c                    |    4 +-
 drivers/net/ethernet/sis/sis900.c                  |    2 +-
 drivers/net/ethernet/smsc/epic100.c                |    2 +-
 drivers/net/ethernet/smsc/smc911x.c                |    6 +-
 drivers/net/ethernet/smsc/smc9194.c                |    4 +-
 drivers/net/ethernet/smsc/smc91c92_cs.c            |    4 +-
 drivers/net/ethernet/smsc/smc91x.c                 |    4 +-
 drivers/net/ethernet/stmicro/stmmac/Makefile       |    3 +-
 drivers/net/ethernet/stmicro/stmmac/common.h       |   64 +-
 .../net/ethernet/stmicro/stmmac/dwmac-socfpga.c    |  113 +-
 .../net/ethernet/stmicro/stmmac/dwmac1000_core.c   |    7 +-
 .../net/ethernet/stmicro/stmmac/dwmac1000_dma.c    |   35 +-
 .../net/ethernet/stmicro/stmmac/dwmac100_core.c    |    5 +-
 drivers/net/ethernet/stmicro/stmmac/dwmac4.h       |  255 ++
 drivers/net/ethernet/stmicro/stmmac/dwmac4_core.c  |  407 +++
 drivers/net/ethernet/stmicro/stmmac/dwmac4_descs.c |  389 +++
 drivers/net/ethernet/stmicro/stmmac/dwmac4_descs.h |  129 +
 drivers/net/ethernet/stmicro/stmmac/dwmac4_dma.c   |  354 ++
 drivers/net/ethernet/stmicro/stmmac/dwmac4_dma.h   |  202 ++
 drivers/net/ethernet/stmicro/stmmac/dwmac4_lib.c   |  225 ++
 drivers/net/ethernet/stmicro/stmmac/enh_desc.c     |   21 +
 drivers/net/ethernet/stmicro/stmmac/mmc.h          |    4 +
 drivers/net/ethernet/stmicro/stmmac/mmc_core.c     |  349 +-
 drivers/net/ethernet/stmicro/stmmac/norm_desc.c    |   21 +
 drivers/net/ethernet/stmicro/stmmac/stmmac.h       |   13 +-
 .../net/ethernet/stmicro/stmmac/stmmac_ethtool.c   |    7 +-
 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c  |  653 +++-
 drivers/net/ethernet/stmicro/stmmac/stmmac_mdio.c  |  102 +-
 drivers/net/ethernet/stmicro/stmmac/stmmac_pci.c   |   24 +-
 .../net/ethernet/stmicro/stmmac/stmmac_platform.c  |   13 +-
 drivers/net/ethernet/sun/niu.c                     |    2 +-
 drivers/net/ethernet/sun/sungem.c                  |    2 +-
 drivers/net/ethernet/synopsys/dwc_eth_qos.c        |    4 +-
 drivers/net/ethernet/tehuti/tehuti.c               |   10 +-
 drivers/net/ethernet/ti/cpsw.c                     |   54 +-
 drivers/net/ethernet/ti/netcp_core.c               |    4 +-
 drivers/net/ethernet/ti/tlan.c                     |    2 +-
 drivers/net/ethernet/tile/tilepro.c                |    4 +-
 drivers/net/ethernet/toshiba/spider_net.c          |    2 +-
 drivers/net/ethernet/tundra/tsi108_eth.c           |    3 +-
 drivers/net/ethernet/via/via-rhine.c               |    2 +-
 drivers/net/ethernet/wiznet/Kconfig                |   14 +
 drivers/net/ethernet/wiznet/Makefile               |    1 +
 drivers/net/ethernet/wiznet/w5100-spi.c            |  466 +++
 drivers/net/ethernet/wiznet/w5100.c                | 1076 ++++--
 drivers/net/ethernet/wiznet/w5100.h                |   37 +
 drivers/net/ethernet/wiznet/w5300.c                |    2 +-
 drivers/net/ethernet/xilinx/ll_temac_main.c        |    2 +-
 drivers/net/ethernet/xilinx/xilinx_axienet_main.c  |    2 +-
 drivers/net/ethernet/xilinx/xilinx_emaclite.c      |    4 +-
 drivers/net/ethernet/xircom/xirc2ps_cs.c           |    2 +-
 drivers/net/fjes/fjes_hw.c                         |   30 +-
 drivers/net/fjes/fjes_hw.h                         |    9 +-
 drivers/net/fjes/fjes_main.c                       |  137 +-
 drivers/net/geneve.c                               |   91 +-
 drivers/net/gtp.c                                  | 1375 ++++++++
 drivers/net/hamradio/baycom_epp.c                  |    6 +-
 drivers/net/hamradio/hdlcdrv.c                     |    6 +-
 drivers/net/hamradio/mkiss.c                       |    4 +-
 drivers/net/hamradio/scc.c                         |    2 +-
 drivers/net/hamradio/yam.c                         |    2 +-
 drivers/net/hyperv/hyperv_net.h                    |   29 +-
 drivers/net/hyperv/netvsc.c                        |  161 +-
 drivers/net/hyperv/netvsc_drv.c                    |  428 ++-
 drivers/net/hyperv/rndis_filter.c                  |   88 +-
 drivers/net/ieee802154/adf7242.c                   |    2 +
 drivers/net/ieee802154/at86rf230.c                 |    6 +-
 drivers/net/ieee802154/atusb.c                     |   91 +-
 drivers/net/ieee802154/mrf24j40.c                  |   14 +-
 drivers/net/ifb.c                                  |    3 +
 drivers/net/ipvlan/ipvlan_main.c                   |   19 +-
 drivers/net/irda/Kconfig                           |    7 -
 drivers/net/irda/Makefile                          |    1 -
 drivers/net/irda/ali-ircc.c                        |    8 +-
 drivers/net/irda/bfin_sir.c                        |    2 +-
 drivers/net/irda/irda-usb.c                        |    4 +-
 drivers/net/irda/nsc-ircc.c                        |    8 +-
 drivers/net/irda/sh_irda.c                         |  875 -----
 drivers/net/irda/smsc-ircc2.c                      |    2 +-
 drivers/net/irda/stir4200.c                        |    2 +-
 drivers/net/irda/via-ircc.c                        |    8 +-
 drivers/net/macsec.c                               |  117 +-
 drivers/net/macvlan.c                              |   10 +-
 drivers/net/macvtap.c                              |   39 +-
 drivers/net/phy/fixed_phy.c                        |    2 +-
 drivers/net/phy/lxt.c                              |   22 +-
 drivers/net/phy/mdio-mux.c                         |   10 +-
 drivers/net/phy/mdio_bus.c                         |   10 +-
 drivers/net/phy/micrel.c                           |   34 +-
 drivers/net/phy/phy.c                              |  105 +
 drivers/net/phy/phy_device.c                       |   13 +-
 drivers/net/ppp/ppp_generic.c                      |  315 +-
 drivers/net/rionet.c                               |    6 +-
 drivers/net/slip/slip.c                            |    2 +-
 drivers/net/tun.c                                  |  118 +-
 drivers/net/usb/asix_common.c                      |    2 +-
 drivers/net/usb/catc.c                             |    4 +-
 drivers/net/usb/kaweth.c                           |    2 +-
 drivers/net/usb/lan78xx.c                          |    4 +-
 drivers/net/usb/pegasus.c                          |    2 +-
 drivers/net/usb/r8152.c                            |    3 +-
 drivers/net/usb/rtl8150.c                          |    4 +-
 drivers/net/usb/smsc75xx.c                         |    4 +-
 drivers/net/usb/smsc95xx.c                         |    4 +-
 drivers/net/usb/usbnet.c                           |    5 +-
 drivers/net/veth.c                                 |    7 +-
 drivers/net/vrf.c                                  |  272 +-
 drivers/net/vxlan.c                                |  297 +-
 drivers/net/wan/cosa.c                             |    2 +-
 drivers/net/wan/farsync.c                          |    6 +-
 drivers/net/wan/lmc/lmc_main.c                     |    2 +-
 drivers/net/wan/sbni.c                             |    8 +-
 drivers/net/wimax/i2400m/netdev.c                  |    2 +-
 drivers/net/wireless/admtek/adm8211.c              |    4 +-
 drivers/net/wireless/ath/ar5523/ar5523.c           |    4 +-
 drivers/net/wireless/ath/ath.h                     |    2 +-
 drivers/net/wireless/ath/ath10k/ce.c               |   50 +-
 drivers/net/wireless/ath/ath10k/ce.h               |   17 +-
 drivers/net/wireless/ath/ath10k/core.c             |  472 +--
 drivers/net/wireless/ath/ath10k/core.h             |  114 +-
 drivers/net/wireless/ath/ath10k/debug.c            |  136 +-
 drivers/net/wireless/ath/ath10k/debug.h            |    2 +-
 drivers/net/wireless/ath/ath10k/htc.h              |    4 +-
 drivers/net/wireless/ath/ath10k/htt.c              |    6 +-
 drivers/net/wireless/ath/ath10k/htt.h              |   60 +-
 drivers/net/wireless/ath/ath10k/htt_rx.c           |  718 ++--
 drivers/net/wireless/ath/ath10k/htt_tx.c           |  300 +-
 drivers/net/wireless/ath/ath10k/hw.h               |   18 +-
 drivers/net/wireless/ath/ath10k/mac.c              |  702 +++-
 drivers/net/wireless/ath/ath10k/mac.h              |    7 +
 drivers/net/wireless/ath/ath10k/pci.c              |  271 +-
 drivers/net/wireless/ath/ath10k/pci.h              |   17 +-
 drivers/net/wireless/ath/ath10k/swap.c             |   44 +-
 drivers/net/wireless/ath/ath10k/swap.h             |    9 +-
 drivers/net/wireless/ath/ath10k/targaddrs.h        |    2 +-
 drivers/net/wireless/ath/ath10k/testmode.c         |  197 +-
 drivers/net/wireless/ath/ath10k/thermal.h          |    2 +-
 drivers/net/wireless/ath/ath10k/txrx.c             |   55 +-
 drivers/net/wireless/ath/ath10k/txrx.h             |    4 +-
 drivers/net/wireless/ath/ath10k/wmi-ops.h          |   23 +
 drivers/net/wireless/ath/ath10k/wmi-tlv.c          |    1 +
 drivers/net/wireless/ath/ath10k/wmi-tlv.h          |    4 +-
 drivers/net/wireless/ath/ath10k/wmi.c              |  162 +-
 drivers/net/wireless/ath/ath10k/wmi.h              |  102 +-
 drivers/net/wireless/ath/ath10k/wow.c              |    7 +-
 drivers/net/wireless/ath/ath5k/ani.c               |    2 +-
 drivers/net/wireless/ath/ath5k/ath5k.h             |   10 +-
 drivers/net/wireless/ath/ath5k/attach.c            |    8 +-
 drivers/net/wireless/ath/ath5k/base.c              |   32 +-
 drivers/net/wireless/ath/ath5k/debug.c             |    6 +-
 drivers/net/wireless/ath/ath5k/led.c               |    2 +-
 drivers/net/wireless/ath/ath5k/pcu.c               |    6 +-
 drivers/net/wireless/ath/ath5k/phy.c               |   32 +-
 drivers/net/wireless/ath/ath5k/qcu.c               |    8 +-
 drivers/net/wireless/ath/ath5k/reset.c             |   10 +-
 drivers/net/wireless/ath/ath6kl/cfg80211.c         |   22 +-
 drivers/net/wireless/ath/ath6kl/core.h             |    2 +-
 drivers/net/wireless/ath/ath6kl/wmi.c              |   27 +-
 drivers/net/wireless/ath/ath6kl/wmi.h              |    2 +-
 .../net/wireless/ath/ath9k/ar9003_2p2_initvals.h   |    4 +-
 drivers/net/wireless/ath/ath9k/ar9003_calib.c      |   44 +-
 drivers/net/wireless/ath/ath9k/ar9003_eeprom.c     |   10 +-
 drivers/net/wireless/ath/ath9k/ar9003_mci.c        |   39 +-
 drivers/net/wireless/ath/ath9k/ar9003_phy.c        |   10 +-
 .../net/wireless/ath/ath9k/ar9330_1p1_initvals.h   |    4 +-
 .../net/wireless/ath/ath9k/ar9330_1p2_initvals.h   |    4 +-
 drivers/net/wireless/ath/ath9k/ar9340_initvals.h   |    4 +-
 .../net/wireless/ath/ath9k/ar9462_2p0_initvals.h   |    4 +-
 .../net/wireless/ath/ath9k/ar9462_2p1_initvals.h   |    4 +-
 drivers/net/wireless/ath/ath9k/ar9485_initvals.h   |    4 +-
 drivers/net/wireless/ath/ath9k/ar953x_initvals.h   |    4 +-
 .../net/wireless/ath/ath9k/ar955x_1p0_initvals.h   |    2 +-
 .../net/wireless/ath/ath9k/ar9565_1p0_initvals.h   |    2 +-
 drivers/net/wireless/ath/ath9k/ar956x_initvals.h   |    2 +-
 .../net/wireless/ath/ath9k/ar9580_1p0_initvals.h   |    4 +-
 drivers/net/wireless/ath/ath9k/ath9k.h             |    4 -
 drivers/net/wireless/ath/ath9k/btcoex.c            |  138 +-
 drivers/net/wireless/ath/ath9k/btcoex.h            |    2 +
 drivers/net/wireless/ath/ath9k/calib.c             |    6 +-
 drivers/net/wireless/ath/ath9k/channel.c           |    8 +-
 drivers/net/wireless/ath/ath9k/common-init.c       |   28 +-
 drivers/net/wireless/ath/ath9k/common.c            |    4 +-
 drivers/net/wireless/ath/ath9k/debug.c             |   24 +-
 drivers/net/wireless/ath/ath9k/debug_sta.c         |    6 +-
 drivers/net/wireless/ath/ath9k/dynack.c            |    2 +-
 drivers/net/wireless/ath/ath9k/gpio.c              |   69 +-
 drivers/net/wireless/ath/ath9k/hif_usb.c           |    2 +-
 drivers/net/wireless/ath/ath9k/htc_drv_gpio.c      |    8 +-
 drivers/net/wireless/ath/ath9k/htc_drv_init.c      |   22 +-
 drivers/net/wireless/ath/ath9k/htc_drv_main.c      |   19 +-
 drivers/net/wireless/ath/ath9k/htc_drv_txrx.c      |    2 +-
 drivers/net/wireless/ath/ath9k/hw.c                |  277 +-
 drivers/net/wireless/ath/ath9k/hw.h                |   11 +-
 drivers/net/wireless/ath/ath9k/init.c              |   22 +-
 drivers/net/wireless/ath/ath9k/main.c              |   13 +-
 drivers/net/wireless/ath/ath9k/pci.c               |   10 +
 drivers/net/wireless/ath/ath9k/reg.h               |   90 +-
 drivers/net/wireless/ath/ath9k/rng.c               |   20 +-
 drivers/net/wireless/ath/ath9k/xmit.c              |    4 +-
 drivers/net/wireless/ath/carl9170/mac.c            |   12 +-
 drivers/net/wireless/ath/carl9170/main.c           |    6 +-
 drivers/net/wireless/ath/carl9170/phy.c            |   18 +-
 drivers/net/wireless/ath/carl9170/rx.c             |    2 +-
 drivers/net/wireless/ath/carl9170/tx.c             |    8 +-
 drivers/net/wireless/ath/regd.c                    |   16 +-
 drivers/net/wireless/ath/regd.h                    |    2 +-
 drivers/net/wireless/ath/wcn36xx/debug.c           |   12 +-
 drivers/net/wireless/ath/wcn36xx/hal.h             |   55 +-
 drivers/net/wireless/ath/wcn36xx/main.c            |  145 +-
 drivers/net/wireless/ath/wcn36xx/pmc.c             |    4 +-
 drivers/net/wireless/ath/wcn36xx/smd.c             |  228 +-
 drivers/net/wireless/ath/wcn36xx/smd.h             |   12 +-
 drivers/net/wireless/ath/wcn36xx/txrx.c            |   12 +-
 drivers/net/wireless/ath/wcn36xx/wcn36xx.h         |   20 +-
 drivers/net/wireless/ath/wil6210/Makefile          |    1 +
 drivers/net/wireless/ath/wil6210/cfg80211.c        |  336 +-
 drivers/net/wireless/ath/wil6210/debugfs.c         |   59 +-
 drivers/net/wireless/ath/wil6210/interrupt.c       |    6 +-
 drivers/net/wireless/ath/wil6210/ioctl.c           |   11 +-
 drivers/net/wireless/ath/wil6210/main.c            |   81 +-
 drivers/net/wireless/ath/wil6210/netdev.c          |    9 +-
 drivers/net/wireless/ath/wil6210/p2p.c             |  253 ++
 drivers/net/wireless/ath/wil6210/pcie_bus.c        |    1 +
 drivers/net/wireless/ath/wil6210/rx_reorder.c      |  204 +-
 drivers/net/wireless/ath/wil6210/trace.h           |   19 +-
 drivers/net/wireless/ath/wil6210/txrx.c            |   67 +-
 drivers/net/wireless/ath/wil6210/txrx.h            |   12 +-
 drivers/net/wireless/ath/wil6210/wil6210.h         |  110 +-
 drivers/net/wireless/ath/wil6210/wil_platform.h    |    8 +-
 drivers/net/wireless/ath/wil6210/wmi.c             |  136 +-
 drivers/net/wireless/ath/wil6210/wmi.h             | 1264 ++++---
 drivers/net/wireless/atmel/at76c50x-usb.c          |    6 +-
 drivers/net/wireless/atmel/atmel.c                 |    2 +-
 drivers/net/wireless/broadcom/b43/b43.h            |    4 +-
 drivers/net/wireless/broadcom/b43/main.c           |   34 +-
 drivers/net/wireless/broadcom/b43/phy_ac.c         |    2 +-
 drivers/net/wireless/broadcom/b43/phy_common.c     |    2 +-
 drivers/net/wireless/broadcom/b43/phy_ht.c         |   16 +-
 drivers/net/wireless/broadcom/b43/phy_lcn.c        |   10 +-
 drivers/net/wireless/broadcom/b43/phy_lp.c         |   30 +-
 drivers/net/wireless/broadcom/b43/phy_n.c          |  176 +-
 drivers/net/wireless/broadcom/b43/tables_lpphy.c   |   14 +-
 drivers/net/wireless/broadcom/b43/tables_nphy.c    |   16 +-
 drivers/net/wireless/broadcom/b43/tables_phy_lcn.c |    2 +-
 drivers/net/wireless/broadcom/b43/xmit.c           |    8 +-
 drivers/net/wireless/broadcom/b43legacy/main.c     |   12 +-
 drivers/net/wireless/broadcom/b43legacy/xmit.c     |    2 +-
 .../wireless/broadcom/brcm80211/brcmfmac/bcdc.c    |   10 +-
 .../wireless/broadcom/brcm80211/brcmfmac/bcmsdh.c  |    2 +-
 .../net/wireless/broadcom/brcm80211/brcmfmac/bus.h |    4 +-
 .../broadcom/brcm80211/brcmfmac/cfg80211.c         |  141 +-
 .../wireless/broadcom/brcm80211/brcmfmac/common.c  |   38 +-
 .../wireless/broadcom/brcm80211/brcmfmac/core.c    |  247 +-
 .../wireless/broadcom/brcm80211/brcmfmac/core.h    |    5 +-
 .../broadcom/brcm80211/brcmfmac/firmware.c         |   30 +-
 .../wireless/broadcom/brcm80211/brcmfmac/fweh.c    |    1 +
 .../wireless/broadcom/brcm80211/brcmfmac/fwil.h    |    1 +
 .../broadcom/brcm80211/brcmfmac/fwsignal.c         |  209 ++
 .../broadcom/brcm80211/brcmfmac/fwsignal.h         |    1 +
 .../wireless/broadcom/brcm80211/brcmfmac/msgbuf.c  |   46 +-
 .../net/wireless/broadcom/brcm80211/brcmfmac/p2p.c |   10 +-
 .../wireless/broadcom/brcm80211/brcmfmac/proto.h   |   16 +
 .../wireless/broadcom/brcm80211/brcmfmac/sdio.c    |   37 +-
 .../net/wireless/broadcom/brcm80211/brcmfmac/usb.c |    6 +-
 .../wireless/broadcom/brcm80211/brcmsmac/channel.c |   10 +-
 .../broadcom/brcm80211/brcmsmac/mac80211_if.c      |   16 +-
 .../wireless/broadcom/brcm80211/brcmsmac/main.c    |    4 +-
 drivers/net/wireless/cisco/airo.c                  |   12 +-
 drivers/net/wireless/intel/ipw2x00/ipw2100.c       |   10 +-
 drivers/net/wireless/intel/ipw2x00/ipw2200.c       |   18 +-
 drivers/net/wireless/intel/iwlegacy/3945-mac.c     |   30 +-
 drivers/net/wireless/intel/iwlegacy/3945-rs.c      |   22 +-
 drivers/net/wireless/intel/iwlegacy/3945.c         |   20 +-
 drivers/net/wireless/intel/iwlegacy/4965-mac.c     |   41 +-
 drivers/net/wireless/intel/iwlegacy/4965-rs.c      |   22 +-
 drivers/net/wireless/intel/iwlegacy/4965.c         |    6 +-
 drivers/net/wireless/intel/iwlegacy/4965.h         |    2 +-
 drivers/net/wireless/intel/iwlegacy/common.c       |   92 +-
 drivers/net/wireless/intel/iwlegacy/common.h       |   30 +-
 drivers/net/wireless/intel/iwlegacy/debug.c        |    4 +-
 drivers/net/wireless/intel/iwlwifi/Kconfig         |   10 -
 drivers/net/wireless/intel/iwlwifi/dvm/agn.h       |    8 +-
 drivers/net/wireless/intel/iwlwifi/dvm/debugfs.c   |    4 +-
 drivers/net/wireless/intel/iwlwifi/dvm/dev.h       |    6 +-
 drivers/net/wireless/intel/iwlwifi/dvm/devices.c   |    4 +-
 drivers/net/wireless/intel/iwlwifi/dvm/lib.c       |    6 +-
 drivers/net/wireless/intel/iwlwifi/dvm/mac80211.c  |   12 +-
 drivers/net/wireless/intel/iwlwifi/dvm/main.c      |    6 +-
 drivers/net/wireless/intel/iwlwifi/dvm/rs.c        |   22 +-
 drivers/net/wireless/intel/iwlwifi/dvm/rs.h        |    2 +-
 drivers/net/wireless/intel/iwlwifi/dvm/rx.c        |    4 +-
 drivers/net/wireless/intel/iwlwifi/dvm/rxon.c      |   10 +-
 drivers/net/wireless/intel/iwlwifi/dvm/scan.c      |   38 +-
 drivers/net/wireless/intel/iwlwifi/dvm/sta.c       |    2 +-
 drivers/net/wireless/intel/iwlwifi/dvm/tx.c        |    4 +-
 drivers/net/wireless/intel/iwlwifi/iwl-1000.c      |   12 +-
 drivers/net/wireless/intel/iwlwifi/iwl-2000.c      |   20 +-
 drivers/net/wireless/intel/iwlwifi/iwl-5000.c      |   13 +-
 drivers/net/wireless/intel/iwlwifi/iwl-6000.c      |   22 +-
 drivers/net/wireless/intel/iwlwifi/iwl-7000.c      |   30 +-
 drivers/net/wireless/intel/iwlwifi/iwl-8000.c      |   15 +-
 drivers/net/wireless/intel/iwlwifi/iwl-9000.c      |   19 +-
 drivers/net/wireless/intel/iwlwifi/iwl-config.h    |    9 +-
 drivers/net/wireless/intel/iwlwifi/iwl-drv.c       |   82 +-
 .../net/wireless/intel/iwlwifi/iwl-eeprom-parse.c  |   38 +-
 .../net/wireless/intel/iwlwifi/iwl-eeprom-parse.h  |    6 +-
 .../net/wireless/intel/iwlwifi/iwl-fw-error-dump.h |    1 +
 drivers/net/wireless/intel/iwlwifi/iwl-fw-file.h   |   41 +-
 drivers/net/wireless/intel/iwlwifi/iwl-fw.h        |    2 +
 drivers/net/wireless/intel/iwlwifi/iwl-modparams.h |   10 +-
 drivers/net/wireless/intel/iwlwifi/iwl-nvm-parse.c |   26 +-
 drivers/net/wireless/intel/iwlwifi/iwl-prph.h      |   12 +
 drivers/net/wireless/intel/iwlwifi/iwl-trans.h     |    4 +-
 drivers/net/wireless/intel/iwlwifi/mvm/Makefile    |    2 +-
 drivers/net/wireless/intel/iwlwifi/mvm/coex.c      |   52 +-
 .../net/wireless/intel/iwlwifi/mvm/coex_legacy.c   | 1315 -------
 drivers/net/wireless/intel/iwlwifi/mvm/constants.h |    1 -
 drivers/net/wireless/intel/iwlwifi/mvm/d3.c        |    2 +-
 .../net/wireless/intel/iwlwifi/mvm/debugfs-vif.c   |   91 +-
 drivers/net/wireless/intel/iwlwifi/mvm/debugfs.c   |  169 +-
 drivers/net/wireless/intel/iwlwifi/mvm/fw-api-rx.h |   15 +-
 drivers/net/wireless/intel/iwlwifi/mvm/fw-api-tx.h |   35 +-
 drivers/net/wireless/intel/iwlwifi/mvm/fw-api.h    |  108 +-
 drivers/net/wireless/intel/iwlwifi/mvm/fw-dbg.c    |  140 +-
 drivers/net/wireless/intel/iwlwifi/mvm/fw.c        |   56 +-
 drivers/net/wireless/intel/iwlwifi/mvm/mac-ctxt.c  |   57 +-
 drivers/net/wireless/intel/iwlwifi/mvm/mac80211.c  |   91 +-
 drivers/net/wireless/intel/iwlwifi/mvm/mvm.h       |   53 +-
 drivers/net/wireless/intel/iwlwifi/mvm/ops.c       |   34 +-
 drivers/net/wireless/intel/iwlwifi/mvm/phy-ctxt.c  |    2 +-
 drivers/net/wireless/intel/iwlwifi/mvm/power.c     |    2 +-
 drivers/net/wireless/intel/iwlwifi/mvm/rs.c        |   28 +-
 drivers/net/wireless/intel/iwlwifi/mvm/rs.h        |    4 +-
 drivers/net/wireless/intel/iwlwifi/mvm/rx.c        |    4 +-
 drivers/net/wireless/intel/iwlwifi/mvm/rxmq.c      |   15 +-
 drivers/net/wireless/intel/iwlwifi/mvm/scan.c      |   58 +-
 drivers/net/wireless/intel/iwlwifi/mvm/sf.c        |    8 +-
 drivers/net/wireless/intel/iwlwifi/mvm/sta.c       |  262 +-
 drivers/net/wireless/intel/iwlwifi/mvm/sta.h       |   87 +-
 drivers/net/wireless/intel/iwlwifi/mvm/tdls.c      |    2 +-
 drivers/net/wireless/intel/iwlwifi/mvm/tt.c        |   15 -
 drivers/net/wireless/intel/iwlwifi/mvm/tx.c        |  201 +-
 drivers/net/wireless/intel/iwlwifi/mvm/utils.c     |  165 +-
 drivers/net/wireless/intel/iwlwifi/pcie/drv.c      |   16 +-
 drivers/net/wireless/intel/iwlwifi/pcie/internal.h |    6 +-
 drivers/net/wireless/intel/iwlwifi/pcie/rx.c       |   12 +-
 drivers/net/wireless/intel/iwlwifi/pcie/trans.c    |   35 +-
 drivers/net/wireless/intel/iwlwifi/pcie/tx.c       |   80 +-
 drivers/net/wireless/intersil/hostap/hostap_hw.c   |    2 +-
 drivers/net/wireless/intersil/orinoco/cfg.c        |    6 +-
 drivers/net/wireless/intersil/orinoco/hw.c         |    2 +-
 drivers/net/wireless/intersil/orinoco/main.c       |    2 +-
 .../net/wireless/intersil/orinoco/orinoco_usb.c    |    2 +-
 drivers/net/wireless/intersil/orinoco/scan.c       |    4 +-
 drivers/net/wireless/intersil/p54/eeprom.c         |   32 +-
 drivers/net/wireless/intersil/p54/main.c           |    4 +-
 drivers/net/wireless/intersil/p54/p54.h            |    2 +-
 drivers/net/wireless/intersil/p54/txrx.c           |    4 +-
 drivers/net/wireless/intersil/prism54/isl_38xx.c   |   35 +-
 drivers/net/wireless/mac80211_hwsim.c              |   21 +-
 drivers/net/wireless/mac80211_hwsim.h              |    1 +
 drivers/net/wireless/marvell/libertas/cfg.c        |   10 +-
 drivers/net/wireless/marvell/libertas/cmd.c        |    4 +-
 drivers/net/wireless/marvell/libertas_tf/main.c    |    4 +-
 .../net/wireless/marvell/mwifiex/11n_rxreorder.c   |    5 +-
 drivers/net/wireless/marvell/mwifiex/cfg80211.c    |   74 +-
 drivers/net/wireless/marvell/mwifiex/cfp.c         |   12 +-
 drivers/net/wireless/marvell/mwifiex/cmdevt.c      |  127 +-
 drivers/net/wireless/marvell/mwifiex/fw.h          |   11 +
 drivers/net/wireless/marvell/mwifiex/init.c        |    2 +-
 drivers/net/wireless/marvell/mwifiex/main.c        |   24 +-
 drivers/net/wireless/marvell/mwifiex/main.h        |   20 +-
 drivers/net/wireless/marvell/mwifiex/pcie.c        |  115 +-
 drivers/net/wireless/marvell/mwifiex/pcie.h        |   21 +-
 drivers/net/wireless/marvell/mwifiex/scan.c        |  202 +-
 drivers/net/wireless/marvell/mwifiex/sdio.c        |   87 +-
 drivers/net/wireless/marvell/mwifiex/sdio.h        |    7 +
 drivers/net/wireless/marvell/mwifiex/sta_cmd.c     |   42 +-
 drivers/net/wireless/marvell/mwifiex/sta_cmdresp.c |   15 +-
 drivers/net/wireless/marvell/mwifiex/sta_event.c   |    3 +
 drivers/net/wireless/marvell/mwifiex/sta_ioctl.c   |   47 +-
 drivers/net/wireless/marvell/mwifiex/tdls.c        |    2 +-
 drivers/net/wireless/marvell/mwifiex/txrx.c        |   13 +-
 drivers/net/wireless/marvell/mwifiex/uap_cmd.c     |    4 +-
 drivers/net/wireless/marvell/mwifiex/uap_txrx.c    |   96 +
 drivers/net/wireless/marvell/mwifiex/usb.c         |   11 +-
 drivers/net/wireless/marvell/mwl8k.c               |   88 +-
 drivers/net/wireless/mediatek/mt7601u/init.c       |    4 +-
 drivers/net/wireless/ralink/rt2x00/rt2800lib.c     |   34 +-
 drivers/net/wireless/ralink/rt2x00/rt2x00.h        |    7 +-
 drivers/net/wireless/ralink/rt2x00/rt2x00dev.c     |   43 +-
 drivers/net/wireless/ralink/rt2x00/rt2x00usb.c     |   21 +-
 drivers/net/wireless/ralink/rt2x00/rt61pci.c       |   22 +-
 drivers/net/wireless/ralink/rt2x00/rt73usb.c       |   22 +-
 drivers/net/wireless/realtek/rtl818x/rtl8180/dev.c |   16 +-
 drivers/net/wireless/realtek/rtl818x/rtl8187/dev.c |    4 +-
 drivers/net/wireless/realtek/rtl8xxxu/rtl8xxxu.c   | 2761 +++++++++++-=
---
 drivers/net/wireless/realtek/rtl8xxxu/rtl8xxxu.h   |  220 +-
 .../net/wireless/realtek/rtl8xxxu/rtl8xxxu_regs.h  |   46 +-
 drivers/net/wireless/realtek/rtlwifi/base.c        |   44 +-
 .../realtek/rtlwifi/btcoexist/halbtc8192e2ant.c    |  847 +++--
 .../realtek/rtlwifi/btcoexist/halbtc8723b1ant.c    |  611 ++--
 .../realtek/rtlwifi/btcoexist/halbtc8723b2ant.c    |  865 +++--
 .../realtek/rtlwifi/btcoexist/halbtc8821a1ant.c    |  652 ++--
 .../realtek/rtlwifi/btcoexist/halbtc8821a2ant.c    |  851 +++--
 .../realtek/rtlwifi/btcoexist/halbtcoutsrc.c       |   31 +-
 .../realtek/rtlwifi/btcoexist/halbtcoutsrc.h       |   19 +-
 .../wireless/realtek/rtlwifi/btcoexist/rtl_btc.c   |    5 +-
 drivers/net/wireless/realtek/rtlwifi/pci.c         |   39 +-
 drivers/net/wireless/realtek/rtlwifi/regd.c        |   16 +-
 .../net/wireless/realtek/rtlwifi/rtl8188ee/dm.c    |    2 +-
 .../net/wireless/realtek/rtlwifi/rtl8188ee/phy.c   |    3 +-
 .../wireless/realtek/rtlwifi/rtl8192c/dm_common.c  |    2 +-
 .../net/wireless/realtek/rtlwifi/rtl8192ee/trx.c   |    2 +-
 .../net/wireless/realtek/rtlwifi/rtl8192se/phy.c   |    2 +-
 .../wireless/realtek/rtlwifi/rtl8723ae/hal_btc.c   |    6 +-
 .../net/wireless/realtek/rtlwifi/rtl8723be/hw.c    |    5 +
 .../net/wireless/realtek/rtlwifi/rtl8723be/phy.c   |   10 +-
 .../net/wireless/realtek/rtlwifi/rtl8723be/rf.c    |    4 +-
 .../net/wireless/realtek/rtlwifi/rtl8723be/sw.c    |    3 +
 .../net/wireless/realtek/rtlwifi/rtl8821ae/dm.c    |    6 +-
 .../net/wireless/realtek/rtlwifi/rtl8821ae/phy.c   |    8 +-
 drivers/net/wireless/realtek/rtlwifi/wifi.h        |    7 +-
 drivers/net/wireless/rndis_wlan.c                  |    4 +-
 drivers/net/wireless/rsi/rsi_91x_mac80211.c        |  100 +-
 drivers/net/wireless/rsi/rsi_91x_mgmt.c            |    8 +-
 drivers/net/wireless/rsi/rsi_91x_pkt.c             |   24 +-
 drivers/net/wireless/rsi/rsi_main.h                |    2 +-
 drivers/net/wireless/st/cw1200/main.c              |   10 +-
 drivers/net/wireless/st/cw1200/scan.c              |    2 +-
 drivers/net/wireless/st/cw1200/sta.c               |    6 +-
 drivers/net/wireless/st/cw1200/txrx.c              |    2 +-
 drivers/net/wireless/st/cw1200/wsm.c               |    4 +-
 drivers/net/wireless/ti/wl1251/main.c              |    2 +-
 drivers/net/wireless/ti/wl1251/ps.c                |    2 +-
 drivers/net/wireless/ti/wl1251/rx.c                |    2 +-
 drivers/net/wireless/ti/wl12xx/main.c              |    8 +-
 drivers/net/wireless/ti/wl12xx/scan.c              |   22 +-
 drivers/net/wireless/ti/wl18xx/cmd.c               |    6 +-
 drivers/net/wireless/ti/wl18xx/event.c             |    6 +-
 drivers/net/wireless/ti/wl18xx/main.c              |   22 +-
 drivers/net/wireless/ti/wl18xx/scan.c              |    8 +-
 drivers/net/wireless/ti/wl18xx/tx.c                |    2 +-
 drivers/net/wireless/ti/wlcore/cmd.c               |   36 +-
 drivers/net/wireless/ti/wlcore/cmd.h               |    6 +-
 drivers/net/wireless/ti/wlcore/main.c              |   42 +-
 drivers/net/wireless/ti/wlcore/ps.c                |    6 +-
 drivers/net/wireless/ti/wlcore/rx.c                |    4 +-
 drivers/net/wireless/ti/wlcore/rx.h                |    2 +-
 drivers/net/wireless/ti/wlcore/scan.c              |   16 +-
 drivers/net/wireless/ti/wlcore/tx.c                |    2 +-
 drivers/net/wireless/ti/wlcore/tx.h                |    4 +-
 drivers/net/wireless/ti/wlcore/wlcore.h            |    4 +-
 drivers/net/wireless/ti/wlcore/wlcore_i.h          |    2 +-
 drivers/net/wireless/wl3501_cs.c                   |    4 +-
 drivers/net/wireless/zydas/zd1201.c                |    2 +-
 drivers/net/wireless/zydas/zd1211rw/zd_mac.c       |    4 +-
 drivers/net/xen-netback/Makefile                   |    2 +-
 drivers/net/xen-netback/common.h                   |   74 +-
 drivers/net/xen-netback/hash.c                     |  384 +++
 drivers/net/xen-netback/interface.c                |  134 +-
 drivers/net/xen-netback/netback.c                  |  249 +-
 drivers/net/xen-netback/xenbus.c                   |   79 +-
 drivers/nfc/Kconfig                                |   11 +-
 drivers/nfc/Makefile                               |    2 +-
 drivers/nfc/fdp/fdp.c                              |    3 +-
 drivers/nfc/nxp-nci/i2c.c                          |    1 -
 drivers/nfc/pn533/Kconfig                          |   27 +
 drivers/nfc/pn533/Makefile                         |    9 +
 drivers/nfc/pn533/i2c.c                            |  281 ++
 drivers/nfc/{ =3D> pn533}/pn533.c                    | 1220 ++-----
 drivers/nfc/pn533/pn533.h                          |  238 ++
 drivers/nfc/pn533/usb.c                            |  597 ++++
 drivers/nfc/pn544/i2c.c                            |    1 -
 drivers/nfc/st-nci/i2c.c                           |   33 +-
 drivers/nfc/st-nci/se.c                            |   28 +-
 drivers/nfc/st-nci/spi.c                           |   32 +-
 drivers/nfc/st-nci/st-nci.h                        |   14 +-
 drivers/nfc/st-nci/vendor_cmds.c                   |   62 +-
 drivers/nfc/st21nfca/core.c                        |   13 +-
 drivers/nfc/st21nfca/i2c.c                         |   39 +-
 drivers/nfc/st21nfca/se.c                          |    2 -
 drivers/of/of_mdio.c                               |   27 +-
 drivers/s390/net/ctcm_main.c                       |    6 +-
 drivers/s390/net/ctcm_mpc.c                        |    2 +-
 drivers/s390/net/netiucv.c                         |    2 +-
 drivers/s390/net/qeth_core_main.c                  |    2 +-
 drivers/soc/qcom/smd-rpm.c                         |    9 +-
 drivers/soc/qcom/smd.c                             |  247 +-
 drivers/soc/qcom/smem.c                            |    3 +-
 drivers/soc/qcom/spm.c                             |    8 +-
 drivers/soc/qcom/wcnss_ctrl.c                      |    8 +-
 drivers/staging/rtl8188eu/os_dep/mon.c             |    2 +-
 drivers/staging/rtl8192e/rtl8192e/rtl_core.c       |    2 +-
 drivers/staging/rtl8192e/rtllib_softmac.c          |    2 +-
 .../staging/rtl8192u/ieee80211/ieee80211_softmac.c |    8 +-
 drivers/staging/rtl8192u/r8192U_core.c             |    4 +-
 drivers/staging/rtl8723au/core/rtw_mlme_ext.c      |    4 +-
 drivers/staging/rtl8723au/include/ieee80211.h      |    2 +-
 drivers/staging/rtl8723au/os_dep/ioctl_cfg80211.c  |   54 +-
 drivers/staging/vt6655/channel.c                   |    4 +-
 drivers/staging/vt6655/device_main.c               |    4 +-
 drivers/staging/vt6655/rxtx.c                      |    2 +-
 drivers/staging/vt6656/channel.c                   |    4 +-
 drivers/staging/vt6656/int.c                       |    2 +-
 drivers/staging/vt6656/main_usb.c                  |    2 +-
 drivers/staging/vt6656/rxtx.c                      |    2 +-
 drivers/staging/wilc1000/wilc_wfi_cfgoperations.c  |   10 +-
 drivers/staging/wlan-ng/cfg80211.c                 |    6 +-
 drivers/staging/wlan-ng/p80211netdev.c             |    2 +-
 drivers/target/iscsi/iscsi_target_util.c           |    5 +-
 drivers/tty/n_gsm.c                                |    2 +-
 drivers/tty/synclink.c                             |    4 +-
 drivers/tty/synclink_gt.c                          |    4 +-
 drivers/tty/synclinkmp.c                           |    4 +-
 drivers/usb/gadget/function/u_ether.c              |    2 +-
 fs/afs/rxrpc.c                                     |   30 +-
 fs/cifs/connect.c                                  |    4 +-
 fs/gfs2/glock.c                                    |    4 +-
 fs/quota/netlink.c                                 |   12 +-
 include/linux/ath9k_platform.h                     |    4 +
 include/linux/bpf.h                                |    9 +
 include/linux/can/dev.h                            |   22 +-
 include/linux/ethtool.h                            |    7 +
 include/linux/filter.h                             |   72 +-
 include/linux/genl_magic_struct.h                  |    7 +-
 include/linux/ieee80211.h                          |   24 +
 include/linux/ieee802154.h                         |   45 +-
 include/linux/ipv6.h                               |   20 +-
 include/linux/mdio.h                               |   11 +
 include/linux/mlx4/device.h                        |    4 +-
 include/linux/mlx5/device.h                        |  104 +-
 include/linux/mlx5/driver.h                        |   28 +-
 include/linux/mlx5/fs.h                            |   23 +-
 include/linux/mlx5/mlx5_ifc.h                      |  354 +-
 include/linux/mlx5/port.h                          |   25 +
 include/linux/mlx5/qp.h                            |    6 +
 include/linux/net.h                                |    3 +-
 include/linux/netdev_features.h                    |   17 +-
 include/linux/netdevice.h                          |   87 +-
 include/linux/netfilter/ipset/ip_set.h             |    9 +-
 include/linux/netfilter/x_tables.h                 |   18 +-
 include/linux/nl802154.h                           |    2 +
 include/linux/perf_event.h                         |    4 +-
 include/linux/phy.h                                |    8 +
 include/linux/qed/common_hsi.h                     |   62 +
 include/linux/qed/qed_eth_if.h                     |   22 +-
 include/linux/qed/qed_if.h                         |  117 +-
 include/linux/qed/qed_iov_if.h                     |   34 +
 include/linux/rculist.h                            |   36 +
 include/linux/rhashtable.h                         |    3 +-
 include/linux/sctp.h                               |   67 +
 include/linux/skbuff.h                             |   52 +-
 include/linux/soc/qcom/smd.h                       |   61 +-
 include/linux/soc/qcom/smem_state.h                |   35 +
 include/linux/socket.h                             |    4 +-
 include/linux/stmmac.h                             |    2 +
 include/linux/trace_events.h                       |   14 +-
 include/linux/u64_stats_sync.h                     |   14 +
 include/linux/udp.h                                |   16 +-
 include/net/6lowpan.h                              |   37 +-
 include/net/act_api.h                              |   12 +
 include/net/af_rxrpc.h                             |    4 +-
 include/net/bluetooth/hci.h                        |    2 +
 include/net/cfg80211.h                             |  158 +-
 include/net/codel.h                                |  217 +-
 include/net/codel_impl.h                           |  255 ++
 include/net/codel_qdisc.h                          |   73 +
 include/net/devlink.h                              |   61 +
 include/net/dsa.h                                  |   48 +-
 include/net/dst.h                                  |    5 +-
 include/net/fq.h                                   |   95 +
 include/net/fq_impl.h                              |  277 ++
 include/net/gen_stats.h                            |    6 +-
 include/net/geneve.h                               |    6 +-
 include/net/gre.h                                  |  104 +
 include/net/gtp.h                                  |   34 +
 include/net/icmp.h                                 |    4 +-
 include/net/inet6_hashtables.h                     |   12 +-
 include/net/inet_hashtables.h                      |   47 +-
 include/net/ip.h                                   |   16 +-
 include/net/ip6_tunnel.h                           |   11 +-
 include/net/ip_tunnels.h                           |   21 +-
 include/net/ip_vs.h                                |   17 +
 include/net/ipv6.h                                 |   68 +-
 include/net/l3mdev.h                               |   68 +-
 include/net/mac80211.h                             |   94 +-
 include/net/mac802154.h                            |   10 +
 include/net/netfilter/nf_conntrack.h               |    2 -
 include/net/netfilter/nf_conntrack_core.h          |    1 +
 include/net/netfilter/nf_conntrack_ecache.h        |  108 +-
 include/net/netfilter/nf_conntrack_expect.h        |    1 +
 include/net/netfilter/nf_conntrack_l4proto.h       |    3 +
 include/net/netfilter/nf_conntrack_labels.h        |    5 +-
 include/net/netfilter/nf_tables.h                  |    2 +-
 include/net/netlink.h                              |  121 +-
 include/net/netns/conntrack.h                      |   10 -
 include/net/netns/ipv4.h                           |    3 +
 include/net/nfc/nci_core.h                         |   17 +-
 include/net/nl802154.h                             |    6 +
 include/net/pkt_cls.h                              |   21 +-
 include/net/protocol.h                             |    3 -
 include/net/request_sock.h                         |   31 +-
 include/net/route.h                                |    7 +-
 include/net/rtnetlink.h                            |    7 +
 include/net/sch_generic.h                          |   20 +-
 include/net/sctp/sctp.h                            |   38 +-
 include/net/sctp/structs.h                         |   13 +-
 include/net/snmp.h                                 |   40 +-
 include/net/sock.h                                 |  161 +-
 include/net/switchdev.h                            |    2 +-
 include/net/tc_act/tc_mirred.h                     |   15 +
 include/net/tcp.h                                  |   81 +-
 include/net/transp_v6.h                            |    4 +-
 include/net/udp.h                                  |   56 +-
 include/net/udp_tunnel.h                           |   10 +-
 include/net/vxlan.h                                |   77 +-
 include/net/xfrm.h                                 |    4 -
 include/rxrpc/packet.h                             |    2 -
 include/trace/perf.h                               |   16 +-
 include/trace/trace_events.h                       |    3 -
 include/uapi/linux/Kbuild                          |    1 +
 include/uapi/linux/bpf.h                           |    7 +
 include/uapi/linux/devlink.h                       |   63 +
 include/uapi/linux/fib_rules.h                     |    1 +
 include/uapi/linux/gen_stats.h                     |    1 +
 include/uapi/linux/gtp.h                           |   33 +
 include/uapi/linux/if_bridge.h                     |   18 +
 include/uapi/linux/if_ether.h                      |    1 +
 include/uapi/linux/if_link.h                       |   62 +
 include/uapi/linux/if_macsec.h                     |    6 +
 include/uapi/linux/ila.h                           |    8 +
 include/uapi/linux/inet_diag.h                     |    6 +-
 include/uapi/linux/ip_vs.h                         |    1 +
 include/uapi/linux/l2tp.h                          |    2 +
 include/uapi/linux/lwtunnel.h                      |    2 +
 include/uapi/linux/neighbour.h                     |    2 +
 include/uapi/linux/net_tstamp.h                    |   10 +
 include/uapi/linux/netfilter/ipset/ip_set.h        |    1 +
 include/uapi/linux/netfilter/nf_tables.h           |    9 +
 include/uapi/linux/netfilter/nfnetlink_acct.h      |    1 +
 include/uapi/linux/netfilter/nfnetlink_conntrack.h |    3 +
 include/uapi/linux/netfilter/nfnetlink_queue.h     |   10 +
 include/uapi/linux/nl80211.h                       |  110 +-
 include/uapi/linux/openvswitch.h                   |    4 +
 include/uapi/linux/pkt_cls.h                       |    6 +
 include/uapi/linux/pkt_sched.h                     |    7 +
 include/uapi/linux/qrtr.h                          |   12 +
 include/uapi/linux/quota.h                         |    1 +
 include/uapi/linux/rtnetlink.h                     |    7 +
 include/uapi/linux/sock_diag.h                     |    1 +
 include/uapi/linux/tc_act/tc_bpf.h                 |    1 +
 include/uapi/linux/tc_act/tc_connmark.h            |    1 +
 include/uapi/linux/tc_act/tc_csum.h                |    1 +
 include/uapi/linux/tc_act/tc_defact.h              |    1 +
 include/uapi/linux/tc_act/tc_gact.h                |    1 +
 include/uapi/linux/tc_act/tc_ife.h                 |    1 +
 include/uapi/linux/tc_act/tc_ipt.h                 |    1 +
 include/uapi/linux/tc_act/tc_mirred.h              |    1 +
 include/uapi/linux/tc_act/tc_nat.h                 |    1 +
 include/uapi/linux/tc_act/tc_pedit.h               |    1 +
 include/uapi/linux/tc_act/tc_skbedit.h             |    1 +
 include/uapi/linux/tc_act/tc_vlan.h                |    1 +
 include/uapi/linux/tcp_metrics.h                   |    1 +
 include/uapi/linux/udp.h                           |    3 +-
 include/uapi/linux/xfrm.h                          |    1 +
 kernel/bpf/core.c                                  |  306 +-
 kernel/bpf/helpers.c                               |   17 +-
 kernel/bpf/stackmap.c                              |    2 +-
 kernel/bpf/syscall.c                               |    2 +-
 kernel/bpf/verifier.c                              |  729 +++-
 kernel/events/core.c                               |   45 +-
 kernel/taskstats.c                                 |   37 +-
 kernel/trace/bpf_trace.c                           |  129 +-
 kernel/trace/trace_event_perf.c                    |   40 +-
 kernel/trace/trace_events.c                        |   18 +
 kernel/trace/trace_kprobe.c                        |   10 +-
 kernel/trace/trace_syscalls.c                      |   13 +-
 kernel/trace/trace_uprobe.c                        |    5 +-
 lib/nlattr.c                                       |  103 +
 lib/rhashtable.c                                   |    6 +-
 lib/test_bpf.c                                     |    5 +-
 lib/test_rhashtable.c                              |    2 +-
 net/6lowpan/6lowpan_i.h                            |    9 +
 net/6lowpan/core.c                                 |    8 +-
 net/6lowpan/debugfs.c                              |   22 +-
 net/6lowpan/iphc.c                                 |  122 +-
 net/6lowpan/nhc_udp.c                              |    2 +-
 net/Kconfig                                        |   22 +-
 net/Makefile                                       |    1 +
 net/atm/lec.c                                      |    4 +-
 net/batman-adv/bat_iv_ogm.c                        |  171 +-
 net/batman-adv/bat_v.c                             |    9 +-
 net/batman-adv/bat_v_ogm.c                         |  219 +-
 net/batman-adv/bitarray.c                          |   16 +-
 net/batman-adv/bitarray.h                          |   15 +-
 net/batman-adv/bridge_loop_avoidance.c             |  333 +-
 net/batman-adv/bridge_loop_avoidance.h             |   43 +-
 net/batman-adv/debugfs.c                           |   21 +-
 net/batman-adv/distributed-arp-table.c             |   14 +-
 net/batman-adv/fragmentation.c                     |   12 +-
 net/batman-adv/gateway_client.c                    |   12 +-
 net/batman-adv/hard-interface.c                    |   34 +-
 net/batman-adv/hard-interface.h                    |    3 +-
 net/batman-adv/hash.h                              |    6 +-
 net/batman-adv/icmp_socket.c                       |   24 +-
 net/batman-adv/main.c                              |   26 +-
 net/batman-adv/main.h                              |   11 +-
 net/batman-adv/multicast.c                         |   11 +-
 net/batman-adv/network-coding.c                    |   45 +-
 net/batman-adv/originator.c                        |   43 +-
 net/batman-adv/originator.h                        |    2 +-
 net/batman-adv/packet.h                            |    3 +-
 net/batman-adv/routing.c                           |   50 +-
 net/batman-adv/routing.h                           |    6 +-
 net/batman-adv/send.c                              |   10 +-
 net/batman-adv/soft-interface.c                    |   52 +-
 net/batman-adv/soft-interface.h                    |   10 +-
 net/batman-adv/sysfs.c                             |    9 +-
 net/batman-adv/translation-table.c                 |   46 +-
 net/batman-adv/types.h                             |    8 +
 net/bluetooth/6lowpan.c                            |   93 +-
 net/bluetooth/af_bluetooth.c                       |    2 +-
 net/bluetooth/bnep/netdev.c                        |    2 +-
 net/bluetooth/hci_core.c                           |    4 +-
 net/bluetooth/hci_event.c                          |   13 +
 net/bluetooth/hci_request.c                        |    6 +-
 net/bluetooth/l2cap_sock.c                         |    2 +-
 net/bridge/br_ioctl.c                              |   40 +-
 net/bridge/br_netfilter_hooks.c                    |    6 +-
 net/bridge/br_netfilter_ipv6.c                     |   10 +-
 net/bridge/br_netlink.c                            |  140 +-
 net/bridge/br_private.h                            |   18 +
 net/bridge/br_sysfs_br.c                           |  101 +-
 net/bridge/br_sysfs_if.c                           |    5 +-
 net/bridge/br_vlan.c                               |  135 +-
 net/bridge/netfilter/nf_tables_bridge.c            |   47 +-
 net/can/raw.c                                      |    2 +-
 net/core/datagram.c                                |    9 +-
 net/core/dev.c                                     |  112 +-
 net/core/devlink.c                                 | 1250 ++++++-
 net/core/ethtool.c                                 |   25 +-
 net/core/fib_rules.c                               |    4 +-
 net/core/filter.c                                  |  185 +-
 net/core/gen_stats.c                               |   35 +-
 net/core/neighbour.c                               |   22 +-
 net/core/net-procfs.c                              |    3 +-
 net/core/pktgen.c                                  |    1 -
 net/core/rtnetlink.c                               |  264 +-
 net/core/skbuff.c                                  |  272 +-
 net/core/sock.c                                    |  150 +-
 net/core/sock_diag.c                               |    3 +-
 net/core/sysctl_net_core.c                         |    9 +
 net/dccp/dccp.h                                    |    6 +-
 net/dccp/input.c                                   |    2 +-
 net/dccp/ipv4.c                                    |   33 +-
 net/dccp/ipv6.c                                    |   33 +-
 net/dccp/minisocks.c                               |    2 +-
 net/dccp/options.c                                 |    2 +-
 net/dccp/timer.c                                   |    8 +-
 net/dsa/dsa.c                                      |   62 +-
 net/dsa/dsa_priv.h                                 |    5 -
 net/dsa/slave.c                                    |  168 +-
 net/hsr/Kconfig                                    |    5 +-
 net/hsr/hsr_device.c                               |   91 +-
 net/hsr/hsr_device.h                               |    2 +-
 net/hsr/hsr_forward.c                              |   43 +-
 net/hsr/hsr_framereg.c                             |   30 +-
 net/hsr/hsr_main.h                                 |   13 +-
 net/hsr/hsr_netlink.c                              |   17 +-
 net/hsr/hsr_slave.c                                |    4 +-
 net/ieee802154/6lowpan/6lowpan_i.h                 |   14 +-
 net/ieee802154/6lowpan/core.c                      |    6 +-
 net/ieee802154/6lowpan/tx.c                        |   14 +-
 net/ieee802154/nl-mac.c                            |   17 +-
 net/ieee802154/nl802154.c                          |   26 +-
 net/ipv4/af_inet.c                                 |   73 +-
 net/ipv4/arp.c                                     |    2 +-
 net/ipv4/cipso_ipv4.c                              |    3 +-
 net/ipv4/fib_frontend.c                            |    1 +
 net/ipv4/fib_semantics.c                           |   34 +-
 net/ipv4/fou.c                                     |   64 +-
 net/ipv4/gre_demux.c                               |   61 +
 net/ipv4/gre_offload.c                             |   41 +-
 net/ipv4/icmp.c                                    |   18 +-
 net/ipv4/inet_connection_sock.c                    |    9 +-
 net/ipv4/inet_diag.c                               |   98 +-
 net/ipv4/inet_hashtables.c                         |   86 +-
 net/ipv4/inet_timewait_sock.c                      |   10 +-
 net/ipv4/ip_forward.c                              |    6 +-
 net/ipv4/ip_fragment.c                             |   14 +-
 net/ipv4/ip_gre.c                                  |  259 +-
 net/ipv4/ip_input.c                                |   42 +-
 net/ipv4/ip_sockglue.c                             |   34 +-
 net/ipv4/ip_tunnel_core.c                          |   41 +-
 net/ipv4/ipip.c                                    |    7 +-
 net/ipv4/ipmr.c                                    |    4 +-
 net/ipv4/netfilter/arp_tables.c                    |  522 +--
 net/ipv4/netfilter/ip_tables.c                     |  573 +---
 net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c     |    2 +-
 .../netfilter/nf_conntrack_l3proto_ipv4_compat.c   |   47 +-
 net/ipv4/ping.c                                    |    7 +-
 net/ipv4/raw.c                                     |   13 +-
 net/ipv4/route.c                                   |   10 +-
 net/ipv4/syncookies.c                              |    4 +-
 net/ipv4/sysctl_net_ipv4.c                         |   11 +
 net/ipv4/tcp.c                                     |   65 +-
 net/ipv4/tcp_bic.c                                 |    6 +-
 net/ipv4/tcp_cdg.c                                 |   34 +-
 net/ipv4/tcp_cubic.c                               |   26 +-
 net/ipv4/tcp_fastopen.c                            |   14 +-
 net/ipv4/tcp_htcp.c                                |   10 +-
 net/ipv4/tcp_illinois.c                            |   21 +-
 net/ipv4/tcp_input.c                               |  249 +-
 net/ipv4/tcp_ipv4.c                                |  144 +-
 net/ipv4/tcp_lp.c                                  |    6 +-
 net/ipv4/tcp_metrics.c                             |    6 +-
 net/ipv4/tcp_minisocks.c                           |   19 +-
 net/ipv4/tcp_offload.c                             |   30 +-
 net/ipv4/tcp_output.c                              |  165 +-
 net/ipv4/tcp_recovery.c                            |    4 +-
 net/ipv4/tcp_timer.c                               |   28 +-
 net/ipv4/tcp_vegas.c                               |    6 +-
 net/ipv4/tcp_vegas.h                               |    2 +-
 net/ipv4/tcp_veno.c                                |    7 +-
 net/ipv4/tcp_westwood.c                            |    7 +-
 net/ipv4/tcp_yeah.c                                |    7 +-
 net/ipv4/udp.c                                     |  428 +--
 net/ipv4/udp_diag.c                                |   18 +-
 net/ipv4/udp_offload.c                             |  140 +-
 net/ipv4/udp_tunnel.c                              |    2 +
 net/ipv6/Kconfig                                   |    1 +
 net/ipv6/Makefile                                  |    5 +-
 net/ipv6/addrconf.c                                |  667 ++--
 net/ipv6/af_inet6.c                                |    9 +
 net/ipv6/datagram.c                                |   29 +-
 net/ipv6/exthdrs.c                                 |   66 +-
 net/ipv6/icmp.c                                    |   42 +-
 net/ipv6/ila/ila.h                                 |   79 +-
 net/ipv6/ila/ila_common.c                          |   81 +-
 net/ipv6/ila/ila_lwt.c                             |   54 +-
 net/ipv6/ila/ila_xlat.c                            |  167 +-
 net/ipv6/inet6_hashtables.c                        |   64 +-
 net/ipv6/ip6_fib.c                                 |    1 +
 net/ipv6/ip6_flowlabel.c                           |    7 +-
 net/ipv6/ip6_gre.c                                 |  450 +--
 net/ipv6/ip6_input.c                               |   39 +-
 net/ipv6/ip6_offload.c                             |   23 +-
 net/ipv6/ip6_offload.h                             |    3 +-
 net/ipv6/ip6_output.c                              |   79 +-
 net/ipv6/ip6_tunnel.c                              |  268 +-
 net/ipv6/ip6mr.c                                   |   12 +-
 net/ipv6/ipv6_sockglue.c                           |   13 +-
 net/ipv6/netfilter/ip6_tables.c                    |  551 +--
 net/ipv6/netfilter/ip6t_SYNPROXY.c                 |   58 +-
 net/ipv6/netfilter/nf_reject_ipv6.c                |    2 +-
 net/ipv6/ping.c                                    |   13 +-
 net/ipv6/raw.c                                     |   34 +-
 net/ipv6/reassembly.c                              |   32 +-
 net/ipv6/route.c                                   |   42 +-
 net/ipv6/sit.c                                     |   14 +-
 net/ipv6/syncookies.c                              |    4 +-
 net/ipv6/tcp_ipv6.c                                |   78 +-
 net/ipv6/udp.c                                     |  358 +-
 net/ipv6/udp_offload.c                             |   11 +-
 net/irda/irlan/irlan_eth.c                         |    2 +-
 net/l2tp/l2tp_ip6.c                                |   31 +-
 net/l2tp/l2tp_netlink.c                            |   83 +-
 net/l3mdev/l3mdev.c                                |   63 +
 net/llc/llc_proc.c                                 |    2 +-
 net/mac80211/agg-tx.c                              |    5 +
 net/mac80211/cfg.c                                 |   32 +-
 net/mac80211/debugfs.c                             |    3 +
 net/mac80211/debugfs_netdev.c                      |   12 +-
 net/mac80211/debugfs_sta.c                         |  134 +-
 net/mac80211/driver-ops.h                          |   15 +
 net/mac80211/ibss.c                                |   27 +-
 net/mac80211/ieee80211_i.h                         |   45 +-
 net/mac80211/iface.c                               |    4 +-
 net/mac80211/key.c                                 |    1 +
 net/mac80211/main.c                                |   10 +-
 net/mac80211/mesh.c                                |   48 +-
 net/mac80211/mesh.h                                |   71 +-
 net/mac80211/mesh_hwmp.c                           |    4 +
 net/mac80211/mesh_pathtbl.c                        |  965 ++----
 net/mac80211/mesh_plink.c                          |   23 +-
 net/mac80211/mlme.c                                |   35 +-
 net/mac80211/ocb.c                                 |    2 -
 net/mac80211/rate.c                                |    2 +-
 net/mac80211/rate.h                                |    4 +-
 net/mac80211/rc80211_minstrel.c                    |    6 +-
 net/mac80211/rc80211_minstrel_ht.c                 |   81 +-
 net/mac80211/rx.c                                  |  555 ++-
 net/mac80211/scan.c                                |   20 +-
 net/mac80211/spectmgmt.c                           |    4 +-
 net/mac80211/sta_info.c                            |  289 +-
 net/mac80211/sta_info.h                            |  130 +-
 net/mac80211/status.c                              |    4 +-
 net/mac80211/tdls.c                                |   18 +-
 net/mac80211/trace.h                               |   18 +-
 net/mac80211/tx.c                                  |  211 +-
 net/mac80211/util.c                                |   29 +-
 net/mac80211/vht.c                                 |    4 +-
 net/mac80211/wpa.c                                 |   42 +-
 net/mpls/mpls_gso.c                                |    1 +
 net/netfilter/ipvs/ip_vs_conn.c                    |   51 +-
 net/netfilter/ipvs/ip_vs_core.c                    |  162 +-
 net/netfilter/ipvs/ip_vs_ctl.c                     |   82 +-
 net/netfilter/ipvs/ip_vs_nfct.c                    |    4 +
 net/netfilter/ipvs/ip_vs_pe_sip.c                  |   15 +
 net/netfilter/ipvs/ip_vs_xmit.c                    |    6 +-
 net/netfilter/nf_conntrack_core.c                  |  432 +--
 net/netfilter/nf_conntrack_ecache.c                |   84 +
 net/netfilter/nf_conntrack_expect.c                |   83 +-
 net/netfilter/nf_conntrack_helper.c                |   12 +-
 net/netfilter/nf_conntrack_labels.c                |   44 +-
 net/netfilter/nf_conntrack_netlink.c               |  166 +-
 net/netfilter/nf_conntrack_proto_dccp.c            |    4 +-
 net/netfilter/nf_conntrack_proto_sctp.c            |    8 +-
 net/netfilter/nf_conntrack_proto_tcp.c             |    8 +-
 net/netfilter/nf_conntrack_proto_udp.c             |    2 +
 net/netfilter/nf_conntrack_proto_udplite.c         |    2 +
 net/netfilter/nf_conntrack_standalone.c            |   13 +-
 net/netfilter/nf_nat_core.c                        |   39 +-
 net/netfilter/nf_tables_api.c                      |  102 +-
 net/netfilter/nf_tables_trace.c                    |    5 +-
 net/netfilter/nfnetlink_acct.c                     |    9 +-
 net/netfilter/nfnetlink_cttimeout.c                |    6 +-
 net/netfilter/nfnetlink_queue.c                    |  105 +
 net/netfilter/nft_counter.c                        |    6 +-
 net/netfilter/nft_ct.c                             |   32 +
 net/netfilter/nft_dynset.c                         |    3 +-
 net/netfilter/nft_hash.c                           |    4 +-
 net/netfilter/nft_limit.c                          |    6 +-
 net/netfilter/nft_rbtree.c                         |   49 +-
 net/netfilter/x_tables.c                           |  245 +-
 net/netfilter/xt_connlabel.c                       |   14 +-
 net/netfilter/xt_socket.c                          |    6 +-
 net/netlink/af_netlink.c                           |   10 +-
 net/nfc/nci/core.c                                 |  117 +-
 net/nfc/nci/ntf.c                                  |    2 +-
 net/nfc/nci/rsp.c                                  |   23 +-
 net/openvswitch/conntrack.c                        |   10 +-
 net/openvswitch/datapath.c                         |   30 +-
 net/openvswitch/flow_netlink.c                     |    5 +-
 net/openvswitch/vport-internal_dev.c               |    3 +-
 net/packet/af_packet.c                             |   44 +-
 net/qrtr/Kconfig                                   |   24 +
 net/qrtr/Makefile                                  |    4 +
 net/qrtr/qrtr.c                                    | 1007 ++++++
 net/qrtr/qrtr.h                                    |   31 +
 net/qrtr/smd.c                                     |  120 +
 net/rds/tcp_recv.c                                 |   14 +-
 net/rfkill/core.c                                  |   36 +-
 net/rxrpc/Kconfig                                  |    2 +-
 net/rxrpc/Makefile                                 |    7 +-
 net/rxrpc/af_rxrpc.c                               |    9 +
 net/rxrpc/ar-accept.c                              |    4 +-
 net/rxrpc/ar-ack.c                                 |   81 +-
 net/rxrpc/ar-call.c                                |   11 +-
 net/rxrpc/ar-connection.c                          |   14 +-
 net/rxrpc/ar-connevent.c                           |   27 +-
 net/rxrpc/ar-input.c                               |   22 +-
 net/rxrpc/ar-internal.h                            |   70 +-
 net/rxrpc/ar-output.c                              |    6 +-
 net/rxrpc/ar-proc.c                                |    2 +-
 net/rxrpc/ar-recvmsg.c                             |   18 +-
 net/rxrpc/ar-security.c                            |  166 +-
 net/rxrpc/insecure.c                               |   83 +
 net/rxrpc/misc.c                                   |   89 +
 net/rxrpc/rxkad.c                                  |   61 +-
 net/sched/act_api.c                                |    7 +-
 net/sched/act_bpf.c                                |    5 +-
 net/sched/act_connmark.c                           |    3 +-
 net/sched/act_csum.c                               |    2 +-
 net/sched/act_gact.c                               |   17 +-
 net/sched/act_ife.c                                |    2 +-
 net/sched/act_ipt.c                                |    2 +-
 net/sched/act_mirred.c                             |    7 +-
 net/sched/act_nat.c                                |    2 +-
 net/sched/act_pedit.c                              |    2 +-
 net/sched/act_simple.c                             |    2 +-
 net/sched/act_skbedit.c                            |    2 +-
 net/sched/act_vlan.c                               |    2 +-
 net/sched/cls_bpf.c                                |    2 +
 net/sched/cls_flower.c                             |   21 +
 net/sched/cls_u32.c                                |   52 +-
 net/sched/em_meta.c                                |    8 +-
 net/sched/sch_api.c                                |    6 +-
 net/sched/sch_codel.c                              |   22 +-
 net/sched/sch_fq_codel.c                           |  111 +-
 net/sched/sch_generic.c                            |   44 +-
 net/sched/sch_htb.c                                |    6 +-
 net/sched/sch_netem.c                              |    3 +-
 net/sched/sch_tbf.c                                |    6 +-
 net/sctp/Kconfig                                   |    4 +
 net/sctp/Makefile                                  |    1 +
 net/sctp/chunk.c                                   |    2 +-
 net/sctp/input.c                                   |   16 +-
 net/sctp/inqueue.c                                 |    5 +
 net/sctp/ipv6.c                                    |    2 +-
 net/sctp/proc.c                                    |  104 +-
 net/sctp/sctp_diag.c                               |  500 +++
 net/sctp/sm_sideeffect.c                           |    6 +
 net/sctp/socket.c                                  |  223 +-
 net/sctp/ulpqueue.c                                |   26 +-
 net/socket.c                                       |   36 +-
 net/sunrpc/socklib.c                               |    2 +-
 net/sunrpc/svcsock.c                               |    8 +-
 net/sunrpc/xprtsock.c                              |   15 +-
 net/switchdev/Kconfig                              |    2 +-
 net/switchdev/switchdev.c                          |    6 +-
 net/tipc/bearer.c                                  |  101 +-
 net/tipc/bearer.h                                  |   15 -
 net/tipc/core.c                                    |    8 +-
 net/tipc/discover.c                                |    7 +-
 net/tipc/discover.h                                |    2 +-
 net/tipc/link.c                                    |   52 +-
 net/tipc/link.h                                    |    2 +-
 net/tipc/msg.h                                     |   29 +-
 net/tipc/netlink_compat.c                          |    2 +-
 net/tipc/node.c                                    |   33 +-
 net/tipc/node.h                                    |    6 +-
 net/tipc/server.c                                  |   19 +-
 net/tipc/server.h                                  |    4 +-
 net/tipc/socket.c                                  |  147 +-
 net/tipc/socket.h                                  |   17 +-
 net/tipc/subscr.c                                  |    7 +-
 net/vmw_vsock/vmci_transport.c                     |    2 +-
 net/wireless/chan.c                                |    4 +-
 net/wireless/core.c                                |   32 +-
 net/wireless/core.h                                |    6 +-
 net/wireless/debugfs.c                             |    4 +-
 net/wireless/ibss.c                                |    6 +-
 net/wireless/mesh.c                                |    4 +-
 net/wireless/mlme.c                                |    2 +-
 net/wireless/nl80211.c                             |  342 +-
 net/wireless/rdev-ops.h                            |    2 +-
 net/wireless/reg.c                                 |   32 +-
 net/wireless/reg.h                                 |    2 +-
 net/wireless/scan.c                                |   24 +-
 net/wireless/sme.c                                 |   54 +-
 net/wireless/sysfs.c                               |    2 +-
 net/wireless/trace.h                               |   26 +-
 net/wireless/util.c                                |   46 +-
 net/wireless/wext-compat.c                         |   45 +-
 net/wireless/wext-core.c                           |    5 +-
 net/xfrm/xfrm_user.c                               |   10 +-
 samples/bpf/Makefile                               |   44 +-
 samples/bpf/README.rst                             |   66 +
 samples/bpf/bpf_load.c                             |   26 +-
 samples/bpf/offwaketime_kern.c                     |   36 +-
 samples/bpf/parse_ldabs.c                          |   41 +
 samples/bpf/parse_simple.c                         |   48 +
 samples/bpf/parse_varlen.c                         |  153 +
 samples/bpf/test_cls_bpf.sh                        |   37 +
 samples/bpf/test_overhead_kprobe_kern.c            |   41 +
 samples/bpf/test_overhead_tp_kern.c                |   36 +
 samples/bpf/test_overhead_user.c                   |  162 +
 samples/bpf/test_verifier.c                        |  348 ++
 samples/bpf/tracex1_kern.c                         |    4 +-
 samples/bpf/tracex2_kern.c                         |    4 +-
 samples/bpf/tracex5_kern.c                         |    6 +-
 security/selinux/nlmsgtab.c                        |    4 +-
 1516 files changed, 76546 insertions(+), 34299 deletions(-)
 delete mode 100644 Documentation/devicetree/bindings/btmrvl.txt
 create mode 100644 Documentation/devicetree/bindings/net/dsa/marvell.t=
xt
 create mode 100644 Documentation/devicetree/bindings/net/marvell-bt-sd=
8xxx.txt
 create mode 100644 Documentation/devicetree/bindings/net/microchip,enc=
28j60.txt
 create mode 100644 Documentation/devicetree/bindings/net/nfc/pn533-i2c=
=2Etxt
 create mode 100644 Documentation/devicetree/bindings/net/wireless/marv=
ell-sd8xxx.txt
 create mode 100644 Documentation/networking/segmentation-offloads.txt
 delete mode 100644 drivers/net/dsa/mv88e6123.c
 delete mode 100644 drivers/net/dsa/mv88e6131.c
 delete mode 100644 drivers/net/dsa/mv88e6171.c
 delete mode 100644 drivers/net/dsa/mv88e6352.c
 delete mode 100644 drivers/net/ethernet/intel/fm10k/fm10k_ptp.c
 create mode 100644 drivers/net/ethernet/mellanox/mlx5/core/en_arfs.c
 create mode 100644 drivers/net/ethernet/mellanox/mlx5/core/en_stats.h
 create mode 100644 drivers/net/ethernet/mellanox/mlx5/core/fs_counters=
=2Ec
 create mode 100644 drivers/net/ethernet/mellanox/mlxsw/spectrum_dcb.c
 create mode 100644 drivers/net/ethernet/qlogic/qed/qed_dcbx.c
 create mode 100644 drivers/net/ethernet/qlogic/qed/qed_dcbx.h
 create mode 100644 drivers/net/ethernet/qlogic/qed/qed_l2.h
 create mode 100644 drivers/net/ethernet/qlogic/qed/qed_selftest.c
 create mode 100644 drivers/net/ethernet/qlogic/qed/qed_selftest.h
 create mode 100644 drivers/net/ethernet/qlogic/qed/qed_sriov.c
 create mode 100644 drivers/net/ethernet/qlogic/qed/qed_sriov.h
 create mode 100644 drivers/net/ethernet/qlogic/qed/qed_vf.c
 create mode 100644 drivers/net/ethernet/qlogic/qed/qed_vf.h
 create mode 100644 drivers/net/ethernet/stmicro/stmmac/dwmac4.h
 create mode 100644 drivers/net/ethernet/stmicro/stmmac/dwmac4_core.c
 create mode 100644 drivers/net/ethernet/stmicro/stmmac/dwmac4_descs.c
 create mode 100644 drivers/net/ethernet/stmicro/stmmac/dwmac4_descs.h
 create mode 100644 drivers/net/ethernet/stmicro/stmmac/dwmac4_dma.c
 create mode 100644 drivers/net/ethernet/stmicro/stmmac/dwmac4_dma.h
 create mode 100644 drivers/net/ethernet/stmicro/stmmac/dwmac4_lib.c
 create mode 100644 drivers/net/ethernet/wiznet/w5100-spi.c
 create mode 100644 drivers/net/ethernet/wiznet/w5100.h
 create mode 100644 drivers/net/gtp.c
 delete mode 100644 drivers/net/irda/sh_irda.c
 create mode 100644 drivers/net/wireless/ath/wil6210/p2p.c
 delete mode 100644 drivers/net/wireless/intel/iwlwifi/mvm/coex_legacy.=
c
 create mode 100644 drivers/net/xen-netback/hash.c
 create mode 100644 drivers/nfc/pn533/Kconfig
 create mode 100644 drivers/nfc/pn533/Makefile
 create mode 100644 drivers/nfc/pn533/i2c.c
 rename drivers/nfc/{ =3D> pn533}/pn533.c (67%)
 create mode 100644 drivers/nfc/pn533/pn533.h
 create mode 100644 drivers/nfc/pn533/usb.c
 create mode 100644 include/linux/qed/qed_iov_if.h
 create mode 100644 include/net/codel_impl.h
 create mode 100644 include/net/codel_qdisc.h
 create mode 100644 include/net/fq.h
 create mode 100644 include/net/fq_impl.h
 create mode 100644 include/net/gtp.h
 create mode 100644 include/uapi/linux/gtp.h
 create mode 100644 include/uapi/linux/qrtr.h
 create mode 100644 net/qrtr/Kconfig
 create mode 100644 net/qrtr/Makefile
 create mode 100644 net/qrtr/qrtr.c
 create mode 100644 net/qrtr/qrtr.h
 create mode 100644 net/qrtr/smd.c
 create mode 100644 net/rxrpc/insecure.c
 create mode 100644 net/rxrpc/misc.c
 create mode 100644 net/sctp/sctp_diag.c
 create mode 100644 samples/bpf/README.rst
 create mode 100644 samples/bpf/parse_ldabs.c
 create mode 100644 samples/bpf/parse_simple.c
 create mode 100644 samples/bpf/parse_varlen.c
 create mode 100755 samples/bpf/test_cls_bpf.sh
 create mode 100644 samples/bpf/test_overhead_kprobe_kern.c
 create mode 100644 samples/bpf/test_overhead_tp_kern.c
 create mode 100644 samples/bpf/test_overhead_user.c
