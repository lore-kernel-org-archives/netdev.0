From: David Miller <davem@davemloft.net>
Subject: [GIT] Networking
Date: Tue, 05 Sep 2017 21:41:43 -0700 (PDT)
Message-ID: <20170905.214143.826912481689443792.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: 8BIT
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


This pull request is dedicated to the memory of David Stevens,
may he rest in peace.

There is a merge conflict involving the SMP call single data changes
in your tree against the liquidio driver.  A piece of code got moved
around in my tree, which got a one-line change in your's.
Specifically it's just a "s/struct
call_single_data/call_single_data_t/" edit and the relevant part of
the merge diff looks like:

diff --cc drivers/net/ethernet/cavium/liquidio/lio_core.c
index adde7745d069,0e7896cdb295..23f6b60030c5
--- a/drivers/net/ethernet/cavium/liquidio/lio_core.c
+++ b/drivers/net/ethernet/cavium/liquidio/lio_core.c
@@@ -364,3 -366,723 +366,723 @@@ void cleanup_rx_oom_poll_fn(struct net_
 ...
+ static void liquidio_napi_drv_callback(void *arg)
+ {
 ...
+ 	} else {
 -		struct call_single_data *csd = &droq->csd;
++		call_single_data_t *csd = &droq->csd;
 ...

It's pretty easy to resolve.

Highlights:

1) Support ipv6 checksum offload in sunvnet driver, from Shannon Nelson.

2) Move to RB-tree instead of custom AVL code in inetpeer, from Eric
   Dumazet.

3) Allow generic XDP to work on virtual devices, from John Fastabend.

4) Add bpf device maps and XDP_REDIRECT, which can be used to build
   arbitrary switching frameworks using XDP.  From John Fastabend.

5) Remove UFO offloads from the tree, gave us little other than bugs.

6) Remove the IPSEC flow cache, from Florian Westphal.

7) Support ipv6 route offload in mlxsw driver.

8) Support VF representors in bnxt_en, from Sathya Perla.

9) Add support for forward error correction modes to ethtool, from
   Vidya Sagar Ravipati.

10) Add time filter for packet scheduler action dumping, from Jamal
    Hadi Salim.

11) Extend the zerocopy sendmsg() used by virtio and tap to regular
    sockets via MSG_ZEROCOPY.  From Willem de Bruijn.

12) Significantly rework value tracking in the BPF verifier, from
    Edward Cree.

13) Add new jump instructions to eBPF, from Daniel Borkmann.

14) Rework rtnetlink plumbing so that operations can be run without
    taking the RTNL semaphore.  From Florian Westphal.

15) Support XDP in tap driver, from Jason Wang.

16) Add 32-bit eBPF JIT for ARM, from Shubham Bansal.

17) Add Huawei hinic ethernet driver.

18) Allow to report MD5 keys in TCP inet_diag dumps, from Ivan
    Delalande.

Please pull, thanks a lot!

The following changes since commit 138e4ad67afd5c6c318b056b4d17c17f2c0ca5c0:

  epoll: fix race between ep_poll_callback(POLLFREE) and ep_free()/ep_remove() (2017-09-01 13:07:35 -0700)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/davem/net-next.git 

for you to fetch changes up to 66bed8465a808400eb14562510e26c8818082cb8:

  Merge branch '40GbE' of git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/net-queue (2017-09-05 20:03:40 -0700)

----------------------------------------------------------------
Aaron Conole (1):
      netfilter: convert hook list to an array

Ahmed Abdelsalam (1):
      ipv6: sr: fix get_srh() to comply with IPv6 standard "RFC 8200"

Akeem G Abodunrin (1):
      i40e: Use correct flag to enable egress traffic for unicast promisc

Alan Brady (2):
      i40evf: use netdev variable in reset task
      i40e: prevent changing ITR if adaptive-rx/tx enabled

Alexander Aring (3):
      if_ether: add forces ife lfb type
      act_ife: use registered ife_type as fallback
      tc-testing: add test for testing ife type

Alexandru Gagniuc (2):
      net: stmmac: Add Adaptrum Anarion GMAC glue layer
      dt-bindings: net: Document bindings for anarion-gmac

Alexei Starovoitov (1):
      selftests/bpf: add a test for a pruning bug in the verifier

Alexey Khoroshilov (2):
      wan: dscc4: add checks for dma mapping errors
      wan: dscc4: convert to plain DMA API

Alvaro G. M (1):
      net: axienet: add support for standard phy-mode binding

Amitkumar Karwar (5):
      rsi: use BUILD_BUG_ON check for fsm_state
      rsi: correct the logic of deriving queue number
      rsi: use macro for allocating USB buffer
      rsi: check length before USB read/write register
      rsi: fix static checker warning

Amitoj Kaur Chawla (2):
      atm: adummy: constify attribute_group structure
      atm: solos-pci: constify attribute_group structures

Andrew Lunn (9):
      net: fec: Issue error for missing but expected PHY
      net: fec: Allow reception of frames bigger than 1522 bytes
      net: phy: marvell: tabification
      net: phy: marvell: Use core genphy_soft_reset()
      net: phy: marvell: consolidate RGMII delay code
      net: phy: marvell: Consolidate setting the phy-mode
      net: phy: marvell: Refactor m88e1121 RGMII delay configuration
      net: phy: marvell: Use the set_polarity helper
      net: phy: marvell: Refactor setting downshift into a helper

Andrew Pilloud (1):
      mvneta: Driver and hardware supports IPv6 offload, so enable it

Andrii (1):
      net: dccp: Add handling of IPV6_PKTOPTIONS to dccp_v6_do_rcv()

Andy Gospodarek (1):
      samples/bpf: add option for native and skb mode for redirect apps

Andy Shevchenko (2):
      ISDN: eicon: switch to use native bitmaps
      ath10k: switch to use new generic UUID API

Anjali Singhai Jain (3):
      i40e: Fix a bug with VMDq RSS queue allocation
      i40e: Detect ATR HW Evict NVM issue and disable the feature
      i40e: avoid NVM acquire deadlock during NVM update

Antoine Tenart (26):
      net: mvpp2: unify register definitions coding style
      net: mvpp2: fix the synchronization module bypass macro name
      net: mvpp2: move the mii configuration in the ndo_open path
      net: mvpp2: initialize the GMAC when using a port
      net: mvpp2: initialize the XLG MAC when using a port
      net: mvpp2: initialize the GoP
      Documentation/bindings: net: marvell-pp2: add the system controller
      net: define the TSO header size in net/tso.h
      net: mvpp2: unify the txq size define use
      net: mvpp2: software tso support
      net: mvpp2: fix the packet size configuration for 10G
      phy: add sgmii and 10gkr modes to the phy_mode enum
      phy: add the mvebu cp110 comphy driver
      Documentation/bindings: phy: document the Marvell comphy driver
      net: mvpp2: initialize the comphy
      net: mvpp2: simplify the link_event function
      net: mvpp2: improve the link management function
      net: mvpp2: do not set GMAC autoneg when using XLG MAC
      net: mvpp2: dynamic reconfiguration of the comphy/GoP/MAC
      net: mvpp2: take advantage of the is_rgmii helper
      net: mvpp2: make the phy optional
      net: mvpp2: use the GoP interrupt for link status changes
      Documentation/bindings: net: marvell-pp2: add the link interrupt
      net: mvpp2: move the mac retrieval/copy logic into its own function
      net: mvpp2: fix use of the random mac address for PPv2.2
      net: mvpp2: fallback using h/w and random mac if the dt one isn't valid

Arjun Vynipadath (2):
      cxgb4: Update register ranges of T4/T5/T6 adapters
      cxgb4: Clear On FLASH config file after a FW upgrade

Arkadi Sharshevsky (47):
      mlxsw: spectrum: Add support for IPv6 MLDv1/2 traps
      mlxsw: spectrum: Improve IPv6 unregistered multicast flooding
      mlxsw: spectrum_router: Enable IPv6 router
      mlxsw: reg: Enable IPv6 on router interfaces
      mlxsw: spectrum: Add support for IPv6 traps
      mlxsw: spectrum_router: Configure RIFs based on IPv6 addresses
      mlxsw: reg: Update RAUHT register with IPv6 support
      mlxsw: spectrum_router: Reflect IPv6 neighbours to the device
      mlxsw: reg: Update RAUHTD register with IPv6 support
      mlxsw: spectrum_router: Periodically dump active IPv6 neighbours
      mlxsw: spectrum_router: Set activity interval according to both neighbour tables
      net: dsa: Change DSA slave FDB API to be switchdev independent
      net: dsa: Remove prepare phase for FDB
      net: dsa: Remove switchdev dependency from DSA switch notifier chain
      net: dsa: Add support for learning FDB through notification
      net: dsa: Move FDB add/del implementation inside DSA
      net: dsa: Add support for querying supported bridge flags
      net: dsa: Remove support for vlan dump from DSA's drivers
      net: dsa: Remove support for bypass bridge port attributes/vlan set
      net: dsa: Remove support for MDB dump from DSA's drivers
      net: dsa: Remove redundant MDB dump support
      net: dsa: Move FDB dump implementation inside DSA
      net: bridge: Remove FDB deletion through switchdev object
      net: switchdev: Remove bridge bypass support from switchdev
      mlxsw: spectrum_router: Prepare nexthop group's hash table for IPv6
      mlxsw: spectrum_router: Add support for nexthop group consolidation for IPv6
      devlink: Add Ethernet header for dpipe
      devlink: Add IPv4 header for dpipe
      mlxsw: spectrum_dpipe: Fix erif table op name space
      devlink: Add support for dynamic table size
      devlink: Move dpipe entry clear function into devlink
      mlxsw: spectrum_router: Add helpers for neighbor access
      mlxsw: spectrum_dpipe: Fix label name
      mlxsw: spectrum_dpipe: Add IPv4 host table initial support
      mlxsw: reg: Make flow counter set type enum to be shared
      mlxsw: spectrum_router: Add support for setting counters on neighbors
      mlxsw: spectrum_dpipe: Add support for IPv4 host table dump
      mlxsw: spectrum_dpipe: Add support for controlling neighbor counters
      mlxsw: spectrum_dpipe: Fix host table dump
      devlink: Add IPv6 header for dpipe
      mlxsw: spectrum_router: Export IPv6 link local address check helper
      mlxsw: spectrum_dpipe: Add IPv6 host table initial support
      mlxsw: spectrum_router: Add IPv6 neighbor access helper
      mlxsw: spectrum_dpipe: Make host entry fill handler more generic
      mlxsw: spectrum_dpipe: Add support for IPv6 host table dump
      mlxsw: spectrum_router: Add support for setting counters on IPv6 neighbors
      mlxsw: spectrum_dpipe: Add support for controlling IPv6 neighbor counters

Arnd Bergmann (7):
      virtio-net: mark PM functions as __maybe_unused
      hamradio: dmascc: avoid -Wformat-overflow warning
      net: bcmgenet: drop COMPILE_TEST dependency
      hns3: fix unused function warning
      ipv6: fix false-postive maybe-uninitialized warning
      net/ncsi: fix ncsi_vlan_rx_{add,kill}_vid references
      soc: ti/knav_dma: include dmaengine header

Arvind Yadav (83):
      atm: iphase: constify pci_device_id.
      atm: ambassador: constify pci_device_id.
      atm: fore200e: constify pci_device_id.
      atm: nicstar: constify pci_device_id.
      atm: he: constify pci_device_id.
      atm: horizon: constify pci_device_id.
      atm: solos-pci: constify pci_device_id.
      atm: lanai: constify pci_device_id.
      atm: zatm: constify pci_device_id.
      atm: firestream: constify pci_device_id.
      atm: eni: constify pci_device_id.
      atm: idt77252: constify pci_device_id.
      net: cadence: macb: constify pci_device_id.
      net: ec_bhf: constify pci_device_id.
      net: cdc_ncm: constify attribute_group structures.
      net: can: at91_can: constify attribute_group structures.
      net: can: janz-ican3: constify attribute_group structures.
      wireless: ipw2200: constify attribute_group structures.
      wireless: ipw2100: constify attribute_group structures.
      wireless: iwlegacy: constify attribute_group structures.
      wireless: iwlegacy: Constify attribute_group structures.
      arcnet: com20020-pci: constify attribute_group structures.
      net: bonding: constify attribute_group structures.
      net: chelsio: cxgb3: constify attribute_group structures.
      brcmfmac: constify pci_device_id
      rtlwifi: rtl8192de: constify pci_device_id.
      rtlwifi: rtl8192se: constify pci_device_id.
      rtlwifi: rtl8821ae: constify pci_device_id.
      rtlwifi: rtl8723ae: constify pci_device_id.
      rtlwifi: rtl8723be: constify pci_device_id.
      rtlwifi: rtl8188ee: constify pci_device_id.
      rtlwifi: rtl8192ee: constify pci_device_id.
      net: qtnfmac: constify pci_device_id.
      net: irda: irda-usb: constify usb_device_id
      net: irda: kingsun: constify usb_device_id
      net: irda: ks959: constify usb_device_id
      net: irda: ksdazzle: constify usb_device_id
      net: irda: mcs7780: constify usb_device_id
      net: irda: stir4200: constify usb_device_id
      net: usb: catc: constify usb_device_id and fix space before '[' error
      net: usb: cdc-phonet: constify usb_device_id
      net: usb: ipheth: constify usb_device_id
      net: usb: kaweth: constify usb_device_id
      net: usb: r8152: constify usb_device_id
      net: usb: rtl8150: constify usb_device_id
      isdn: hisax: hfc_usb: constify usb_device_id
      isdn: hfcsusb: constify usb_device_id
      ar5523: constify usb_device_id
      carl9170: constify usb_device_id
      at76c50x: constify usb_device_id
      orinoco: constify usb_device_id
      p54: constify usb_device_id
      libertas: constify usb_device_id
      libertas_tf: constify usb_device_id
      mwifiex: constify usb_device_id
      mt7601u: constify usb_device_id
      rt2500usb: constify usb_device_id
      rt2800usb: constify usb_device_id
      rt73usb: constify usb_device_id
      rtl8187: constify usb_device_id
      rtl8xxxu: constify usb_device_id
      rtl8192cu: constify usb_device_id
      zd1201: constify usb_device_id
      zd1211rw: constify usb_device_id
      brcm80211: constify usb_device_id
      ath6kl: constify usb_device_id
      ath9k: constify usb_device_id
      can: constify platform_device_id
      net: dpaa_eth: constify platform_device_id
      net: sh_eth: constify platform_device_id
      net: ti: cpsw:: constify platform_device_id
      net: 3c509: constify pnp_device_id
      net: ibm: ibmveth: constify vio_device_id
      net: ibm: ibmvnic: constify vio_device_id
      net: 3c509: constify eisa_device_id
      net: 3c59x: constify eisa_device_id
      net: de4x5: constify eisa_device_id
      net: hp100: constify eisa_device_id
      net: defxx: constify eisa_device_id
      net: amd: constify zorro_device_id
      net: tipc: constify genl_ops
      net: rsi: mac80211: constify ieee80211_ops
      net: stmmac: constify clk_div_table

Aviad Krawczyk (24):
      net-next/hinic: Initialize hw interface
      net-next/hinic: Initialize hw device components
      net-next/hinic: Initialize api cmd resources
      net-next/hinic: Initialize api cmd hw
      net-next/hinic: Add management messages
      net-next/hinic: Add api cmd commands
      net-next/hinic: Add aeqs
      net-next/hinic: Add port management commands
      net-next/hinic: Add Rx mode and link event handler
      net-next/hinic: Add logical Txq and Rxq
      net-next/hinic: Add wq
      net-next/hinic: Add qp resources
      net-next/hinic: Set qp context
      net-next/hinic: Initialize cmdq
      net-next/hinic: Add ceqs
      net-next/hinic: Add cmdq commands
      net-next/hinic: Add cmdq completion handler
      net-next/hinic: Add Rx handler
      net-next/hinic: Add Tx operation
      net-next/hinic: Add ethtool and stats
      net-next/hinic: Add netpoll
      net-next/hinic: Add Maintainer
      net-next/hinic: Fix MTU limitation
      net-next/hinic: fix comparison of a uint16_t type with -1

Avraham Stern (1):
      iwlwifi: mvm: remove session protection to allow channel switch

Baolin Wang (1):
      net: rxrpc: Replace time_t type with time64_t type

Bhumika Goyal (28):
      qlcnic: add const to bin_attribute structure
      hamradio: baycom: make hdlcdrv_ops const
      isdn: kcapi: make capi_version const
      ath9k: make ath_ps_ops structures as const
      wlcore: add const to bin_attribute structure
      rtlwifi: constify rate_control_ops structure
      iwlwifi: mvm: add const to thermal_cooling_device_ops structure
      net: dsa: make dsa_switch_ops const
      atm: make atmdev_ops const
      net: atm: make atmdev_ops const
      mlxsw: make mlxsw_config_profile const
      Bluetooth: make device_type const
      net: dsa: mv88e6xxx: make irq_chip const
      qlogic: make device_attribute const
      net: ethernet: make ptp_clock_info const
      ptp: make ptp_clock_info const
      net: ethernet: ax88796: make mdiobb_ops const
      net: ethernet: freescale: fs_enet: make mdiobb_ops const
      net: mdio-gpio: make mdiobb_ops const
      wireless: ipw2x00: make iw_handler_def const
      net/mlx4_core: make mlx4_profile const
      net/mlx5e: make mlx5e_profile const
      ieee802154: 6lowpan: make header_ops const
      bridge: make ebt_table const
      ipv4: make net_protocol const
      RDS: make rhashtable_params const
      net: dsa: make some structures const
      net: bcm63xx_enet: make bcm_enetsw_ethtool_ops const

Biju Das (2):
      dt-bindings: net: ravb : Add support for r8a7743 SoC
      dt-bindings: net: ravb : Add support for r8a7745 SoC

Bjorn Andersson (1):
      wcn36xx: Introduce mutual exclusion of fw configuration

Bjørn Mork (1):
      qmi_wwan: fix NULL deref on disconnect

Brian Norris (22):
      mwifiex: correct channel stat buffer overflows
      mwifiex: reunite copy-and-pasted remove/reset code
      mwifiex: reset interrupt status across device reset
      mwifiex: pcie: don't allow cmd buffer reuse after reset
      mwifiex: re-register wiphy across reset
      mwifiex: unregister wiphy before freeing resources
      mwifiex: don't short-circuit netdev notifiers on interface deletion
      mwifiex: fixup init_channel_scan_gap error case
      mwifiex: ensure "disable auto DS" struct is initialized
      mwifiex: fix misnomers in mwifiex_free_lock_list()
      mwifiex: make mwifiex_free_cmd_buffer() return void
      mwifiex: utilize netif_tx_{wake,stop}_all_queues()
      mwifiex: don't open-code ARRAY_SIZE()
      mwifiex: drop 'add_tail' param from mwifiex_insert_cmd_to_pending_q()
      mwifiex: pcie: remove unnecessary masks
      mwifiex: pcie: unify MSI-X / non-MSI-X interrupt process
      mwifiex: debugfs: allow card_reset() to cancel things
      mwifiex: pcie: disable device DMA before unmapping/freeing buffers
      mwifiex: pcie: remove unnecessary 'pdev' check
      mwifiex: keep mwifiex_cancel_pending_ioctl() static
      mwifiex: drop num CPU notice
      Bluetooth: btusb: add ID for LiteOn 04ca:3016

Carolyn Wyborny (2):
      i40e: Fix for trace found with S4 state
      i40e: Fix for unused value issue found by static analysis

Casey Leedom (2):
      cxgb4: core hardware/firmware support for Forward Error Correction on a link
      cxgb4: ethtool forward error correction management support

Chaya Rachel Ivgi (2):
      iwlwifi: mvm: add debugfs to force CT-kill
      iwlwifi: mvm: set the default cTDP budget

Chi-Hsien Lin (1):
      brcmfmac: Add support for CYW4373 SDIO/USB chipset

Chopra, Manish (2):
      qede: Add getter APIs support for RX flow classification
      qed/qede: Add setter APIs support for RX flow classification

Chris Mi (4):
      net/sched: Fix the logic error to decide the ingress qdisc
      idr: Add new APIs to support unsigned long
      net/sched: Change cls_flower to use IDR
      net/sched: Change act_api and act_xxx modules to use IDR

Christoph Fritz (1):
      ath9k: fix debugfs file permission

Christophe JAILLET (2):
      mrf24j40: Fix en error handling path in 'mrf24j40_probe()'
      ieee802154: ca8210: Fix a potential NULL pointer dereference

Christophe Jaillet (2):
      net: ibm: emac: Fix some error handling path in 'emac_probe()'
      mt7601u: check memory allocation failure

Chung-Hsien Hsu (1):
      brcmfmac: add setting carrier state ON for successful roaming

Claudiu Manoil (1):
      gianfar: Fix Tx flow control deactivation

Cliff Spradlin (1):
      igb: protect TX timestamping from API misuse

Colin Ian King (30):
      rtlwifi: kfree entry until after entry->bssid has been accessed
      mwifiex: usb: fix spelling mistake: "aggreataon"-> "aggregation"
      mwifiex: fix spelling mistake: "Insuffient" -> "Insufficient"
      zd1211rw: fix spelling mistake 'hybernate' -> 'hibernate'
      wl3501_cs: fix spelling mistake: "Insupported" -> "Unsupported"
      batman-adv: fix various spelling mistakes
      net: hns3: fix spelling mistake: "capabilty" -> "capability"
      net: phy: mdio-bcm-unimac: fix unsigned wrap-around when decrementing timeout
      Bluetooth: kfree tmp rather than an alias to it
      virtio-net: make array guest_offloads static
      tap: make struct tap_fops static
      net/mlx4: fix spelling mistake: "availible" -> "available"
      liquidio: fix spelling mistake: "interuupt" -> "interrupt"
      net: hns3: ensure media_type is unitialized
      mlx5: ensure 0 is returned when vport is zero
      net: hns3: fix a handful of spelling mistakes
      bnxt_en: fix spelling mistake: "swtichdev" -> "switchdev"
      MIPS,bpf: fix missing break in switch statement
      net: hinic: make functions set_ctrl0 and set_ctrl1 static
      gre: remove duplicated assignment of iph
      rtlwifi: rtl8821ae: fix spelling mistake: "faill" -> "failed"
      netfilter: ebtables: fix indent on if statements
      qed: fix spelling mistake: "calescing" -> "coalescing"
      bpf: test_maps: fix typos, "conenct" and "listeen"
      qlcnic: remove redundant zero check on retries counter
      fsl/fman: make arrays port_ids static, reduces object code size
      net: phy: bcm7xxx: make array bcm7xxx_suspend_cfg static, reduces object code size
      net: qualcomm: rmnet: remove unused variable priv
      net/mlx4_core: fix memory leaks on error exit path
      net/mlx4_core: fix incorrect size allocation for dev->caps.spec_qps

Cong Wang (2):
      wl1251: add a missing spin_lock_init()
      net_sched: add reverse binding for tc class

Corentin Labbe (6):
      net: mdio-mux: Fix NULL Comparison style
      net: mdio-mux: Remove unnecessary 'out of memory' message
      net: mdio-mux: printing driver version is useless
      net: mdio-mux-mmioreg: Can handle 8/16/32 bits registers
      net: mdio-mux: fix unbalanced put_device
      net: mdio-mux: add mdio_mux parameter to mdio_mux_init()

Corinna Vinschen (1):
      igb: Remove incorrect "unexpected SYS WRAP" log message

Craig Gallek (1):
      dsa: fix flow disector null pointer

Dan Carpenter (16):
      bpf: dev_map_alloc() shouldn't return NULL
      mwifiex: usb: unlock on error in mwifiex_usb_tx_aggr_tmo()
      rtlwifi: rtl8821ae: Fix HW_VAR_NAV_UPPER operation
      Bluetooth: btrtl: Fix a error code in rtl_load_config()
      net: phy: marvell: logical vs bitwise OR typo
      phylink: Fix an uninitialized variable bug
      hns3pf: fix hns3_del_tunnel_port()
      hns3pf: Fix some harmless copy and paste bugs
      bpf: fix a return in sockmap_get_from_fd()
      ethernet: xircom: small clean up in setup_xirc2ps_cs()
      rtlwifi: make a couple arrays larger
      hinic: uninitialized variable in hinic_api_cmd_init()
      hinic: skb_pad() frees on error
      bpf: fix oops on allocation failure
      rsi: update some comments
      rsi: missing unlocks on error paths

Dan Williams (1):
      ipw2100: don't return positive values to PCI probe on error

Daniel Borkmann (21):
      i40e: report BPF prog id during XDP_QUERY_PROG
      bpf: add BPF_J{LT,LE,SLT,SLE} instructions
      bpf, x86: implement jiting of BPF_J{LT,LE,SLT,SLE}
      bpf, arm64: implement jiting of BPF_J{LT, LE, SLT, SLE}
      bpf, sparc64: implement jiting of BPF_J{LT, LE, SLT, SLE}
      bpf, s390x: implement jiting of BPF_J{LT, LE, SLT, SLE}
      bpf, ppc64: implement jiting of BPF_J{LT, LE, SLT, SLE}
      bpf, nfp: implement jiting of BPF_J{LT,LE}
      bpf: enable BPF_J{LT, LE, SLT, SLE} opcodes in verifier
      bpf: add test cases for new BPF_J{LT, LE, SLT, SLE} instructions
      bpf: fix liveness propagation to parent in spilled stack slots
      bpf: no need to nullify ri->map in xdp_do_redirect
      bpf: don't enable preemption twice in smap_do_verdict
      bpf: reuse tc bpf prologue for sk skb progs
      bpf: make htab inlining more robust wrt assumptions
      bpf: inline map in map lookup functions for array and htab
      bpf: fix double free from dev_map_notification()
      bpf: fix map value attribute for hash of maps
      bpf: misc xdp redirect cleanups
      bpf: minor cleanups for dev_map
      bpf: netdev is never null in __dev_map_flush

Dave Jiang (1):
      net: remove dmaengine.h inclusion from netdevice.h

David Ahern (26):
      net: ipv4: add second dif to udp socket lookups
      net: ipv4: add second dif to inet socket lookups
      net: ipv4: add second dif to raw socket lookups
      net: ipv4: add second dif to multicast source filter
      net: ipv6: add second dif to udp socket lookups
      net: ipv6: add second dif to inet6 socket lookups
      net: ipv6: add second dif to raw socket lookups
      net: vrf: Add extack messages for newlink failures
      net: ipv6: lower ndisc notifier priority below addrconf
      net: ipv4: set orig_oif based on fib result for local traffic
      net: ipv4: remove unnecessary check on orig_oif
      net: vrf: Drop local rtable and rt6_info
      net: ipv4: add check for l3slave for index returned in IP_PKTINFO
      net: ipv6: put host and anycast routes on device with address
      Revert "ipv4: make net_protocol const"
      net: Add comment that early_demux can change via sysctl
      ipv6: Use rt6i_idev index for echo replies to a local address
      devlink: Maintain consistency in mac field name
      bpf: Add mark and priority to sock options that can be set
      bpf: Allow cgroup sock filters to use get_current_uid_gid helper
      samples/bpf: Update sock test to allow setting mark and priority
      samples/bpf: Add detach option to test_cgrp2_sock
      samples/bpf: Add option to dump socket settings
      samples/bpf: Update cgrp2 socket tests
      samples/bpf: Update cgroup socket examples to use uid gid helper
      bpf: Collapse offset checks in sock_filter_is_valid_access

David Daney (3):
      MIPS,bpf: Fix using smp_processor_id() in preemptible splat.
      MIPS, bpf: Implement JLT, JLE, JSLT and JSLE ops in the eBPF JIT.
      MIPS,bpf: Cache value of BPF_OP(insn->code) in eBPF JIT.

David Herrmann (1):
      net/unix: drop obsolete fd-recursion limits

David Howells (9):
      rxrpc: Expose UAPI definitions to userspace
      rxrpc: Move the packet.h include file into net/rxrpc/
      rxrpc: Use correct timestamp from Kerberos 5 ticket
      rxrpc: Fix IPv6 support
      rxrpc: Don't negate call->error before returning it
      rxrpc: Remove some excess whitespace
      rxrpc: Add notification of end-of-Tx phase
      rxrpc: Allow failed client calls to be retried
      rxrpc: Make service connection lookup always check for retry

David Lamparter (1):
      net: check type when freeing metadata dst

David Lebrun (10):
      ipv6: sr: allow SRH insertion with arbitrary segments_left value
      ipv6: sr: export SRH insertion functions
      ipv6: sr: define core operations for seg6local lightweight tunnel
      ipv6: sr: add rtnetlink functions for seg6local action parameters
      ipv6: sr: implement several seg6local actions
      ipv6: sr: add support for ip4ip6 encapsulation
      ipv6: sr: add support for encapsulation of L2 frames
      ipv6: sr: enforce IPv6 packets for seg6local lwt
      ipv6: sr: add helper functions for seg6local
      ipv6: sr: implement additional seg6local actions

David S. Miller (198):
      Merge branch 'atm-constify-atm-pci_device_id'
      Merge branch 'sctp-typedef-remove-part-2'
      Merge branch 'mlxsw-ttl-tos'
      Merge branch 'mlxsw-traps'
      Merge branch 'xdp-redirect'
      s2io: Remove UFO support.
      macb: Remove bogus reference to NETIF_F_UFO.
      ipvlan: Stop advertising NETIF_F_UFO support.
      macvlan/macvtap: Remove NETIF_F_UFO advertisement.
      tun/tap: Remove references to NETIF_F_UFO.
      dummy: Remove references to NETIF_F_UFO.
      virtio_net: Remove references to NETIF_F_UFO.
      net: Remove references to NETIF_F_UFO in netdev_fix_features().
      net: Remove references to NETIF_F_UFO from ethtool.
      inet: Stop generating UFO packets.
      net: Remove all references to SKB_GSO_UDP.
      inet: Remove software UFO fragmenting code.
      net: Kill NETIF_F_UFO and SKB_GSO_UDP.
      Merge branch 'net-ufo-remove'
      Merge branch 'dsa-mv88e6xxx-cleanup-capabilities'
      Merge branch 'xfrm-remove-flow-cache'
      Merge branch 'mlxsw-Preparations-for-IPv6-UC-router'
      Merge branch 'net-attribute_group-const'
      Merge branch 'liquidio-lowmem-fixes'
      Merge branch 'dev_close-void'
      Merge branch 'netvsc-lockdep-and-related-fixes'
      Merge git://git.kernel.org/.../davem/net
      Merge branch 'virtio_net-xdp-refine'
      Merge branch 'udp-tunnel-offloads-toggle'
      Merge branch 'sctp-remove-typedefs-from-structures-part-3'
      Merge tag 'rxrpc-rewrite-20170721' of git://git.kernel.org/.../dhowells/linux-fs
      Merge branch 'bnxt_en-updates'
      Merge branch 'netvsc-minor-fixes'
      bnxt_en: Use SWITCHDEV_SET_OPS().
      Merge branch 'net-warnings'
      Merge branch 'bnxt_en-Fix-kbuild-errors-and-rename-phys_port_name'
      Merge branch '10GbE' of git://git.kernel.org/.../jkirsher/next-queue
      Merge branch '40GbE' of git://git.kernel.org/.../jkirsher/next-queue
      Merge branch 'qed-next'
      Merge branch 'nfp-extend-firmware-request-logic'
      Merge branch 'liquidio-standardization-and-cleanup'
      Merge branch 'inet6_protocol-const'
      Merge branch 'smc-get-rid-of-unsafe_global_rkey'
      Merge branch 'moxa-Fix-style-issues'
      Merge branch 'netvsc-minor-fixes-and-optimization'
      Merge branch 'ethtool-fec'
      Merge branch 'dsa-lan9303-Fix-MDIO-issues'
      Merge branch 'net-sched-actions-improve-dump-performance'
      Merge branch 'tcp-remove-prequeue-and-header-prediction'
      Merge branch 'bcmgenet-utilize-MDIO-unimac-driver'
      Merge branch 'mlxsw-Various-small-fixes'
      Merge branch 'marvell-phy-refactor-and-cleanup'
      Merge branch 'revert-ipv6-const'
      Merge git://git.kernel.org/.../davem/net
      Merge branch 'kzproxy-next'
      Merge branch 'mediatek-next'
      Merge branch 'for-upstream' of git://git.kernel.org/.../bluetooth/bluetooth-next
      Merge branch 'ravb-wol-magic-packet'
      Merge branch 'dsa-rework-EEE-support'
      Merge branch 'netvsc-transparent-VF-support'
      Merge branch 'per-nexthop-offload'
      Merge tag 'batadv-next-for-davem-20170802' of git://git.open-mesh.org/linux-merge
      Merge branch 'ibmvnic-ethtool'
      Merge branch 'sctp-remove-typedefs-from-structures-part-4'
      Merge branch 'hns3-ethernet-driver'
      Merge branch 'mvpp2-add-TX-interrupts-support'
      Merge branch 'mlxsw-Support-for-IPv6-UC-router'
      Merge branch 'socket-sendmsg-zerocopy'
      Merge branch 'net-sched-summer-cleanup-part-1-mainly-in-exts-area'
      Merge branch 'IP-cleanup-LSRR-option-processing'
      Merge branch 'phylink-and-sfp-support'
      Merge branch 'tcp-cwnd-undo-refactor'
      Merge branch 'sctp-remove-typedefs-from-structures-part-5'
      Merge branch 'net-sched-summer-cleanup-part-2-ndo_setup_tc'
      Merge tag 'mlx5-shared-2017-08-07' of git://git.kernel.org/.../mellanox/linux
      Merge tag 'wireless-drivers-next-for-davem-2017-08-07' of git://git.kernel.org/.../kvalo/wireless-drivers-next
      Merge branch 'net-l3mdev-Support-for-sockets-bound-to-enslaved-device'
      Merge branch 'bpf-add-support-for-sys-enter-exit-tracepoints'
      Merge branch 'net_sched-clean-up-filter-handle'
      Merge branch 'ipv6-sr-add-support-for-advanced-local-segment-processing'
      Merge branch 'Refactor-lan9303_xxx_packet_processing'
      Merge branch 'net-dsa-remove-useless-arguments'
      Merge branch 'Update-DSAs-FDB-API-and-perform-switchdev-cleanup'
      Merge branch 'bpf-rewrite-value-tracking-in-verifier'
      Merge git://git.kernel.org/.../davem/net
      Merge branch '1GbE' of git://git.kernel.org/.../jkirsher/next-queue
      Merge branch 'net-zerocopy-fixes'
      Merge branch 'bpf-new-branches'
      Merge branch 'rtnetlink-allow-selected-handlers-to-run-without-rtnl'
      Merge branch 'mediatek-bring-up-QDMA-RX-ring-0'
      Merge branch 'dsa-flow-dissection'
      Merge branch 'rtnetlink-fix-initial-rtnl-pushdown-fallout'
      Merge git://git.kernel.org/.../davem/net
      Merge branch 'sctp-remove-typedefs-from-structures-part-6'
      Merge branch 'net-sched-let-the-offloader-decide-what-to-offload'
      Merge branch 'netvsc-minor-fixes-and-improvements'
      Merge branch 'rockchip-internal-phy'
      Merge branch 'tap-XDP-support'
      Merge branch 'vrf-Support-for-local-traffic-with-sockets-bound-to-enslaved-devices'
      Merge branch 'mlxsw-spectrum_router-Increase-VRF-scale'
      Merge branch 'mlnx-i2c'
      Merge branch 'liquidio-adding-support-for-ethtool-set-ring-feature'
      Merge branch 'mlxsw-Add-support-for-nexthop-group-consolidation-for-IPv6'
      Merge branch 's390-next'
      Merge branch 'getroute-no-rtnl'
      Merge git://git.kernel.org/.../davem/net
      Merge branch 'liquidio-adding-support-for-ethtool-set-channels-feature'
      Merge branch 'net-sizeof-cleanups'
      Merge branch 'bpf-sockmap'
      Merge branch 'nfp-process-MTU-updates-from-firmware-flower-app'
      Merge branch 'sockmap-build-fixes'
      tcp: Export tcp_{sendpage,sendmsg}_locked() for ipv6.
      Merge branch 'vmbus-sendpacket-cleanups'
      Merge branch 'bpf-smap-followups'
      Merge branch 'liquidio-initialization-fixes-for-embedded-firmware'
      Merge branch 's390-qeth-next'
      Merge branch 'hns3-bug-fixes'
      Merge branch 'for-upstream' of git://git.kernel.org/.../bluetooth/bluetooth-next
      Merge branch 'xdp-adjust-xdp-redirect-tracepoint'
      Merge branch 'amd-xgbe-next'
      Merge branch 'net-sysfs-related-cleanups'
      Merge branch 'nfp-add-basic-ethtool-callbacks-to-representors'
      Merge branch 'net-const-eisa_device_id'
      Merge branch 'bpf-Allow-selecting-numa-node-during-map-creation'
      Merge branch 'BPF-inline-improvements'
      bpf: linux/bpf.h needs linux/numa.h
      Merge tag 'mlx5-updates-2017-08-17-V2' of git://git.kernel.org/.../saeed/linux
      Merge branch 'master' of git://git.kernel.org/.../klassert/ipsec-next
      Merge branch 'bpf-mips-jit-improvements'
      Merge git://git.kernel.org/.../davem/net
      Merge branch 'Huawei-HiNIC-Ethernet-Driver'
      Merge branch 'liquidio-VF-driver-will-notify-NIC-firmware-of-MTU-change'
      Merge branch 'hv_netvsc-Ethtool-handler-to-change-UDP-hash-levels'
      Merge branch 'tcp_conn_request-cleanup'
      Merge branch 'net-mvpp2-MAC-GoP-configuration'
      Merge branch 'bpf-minor-cleanups'
      Merge branch 'tcp-sw-rx-timestamps'
      Merge branch 'mvpp2-software-TSO-support'
      Merge branch 'mlxsw-multichain-tc-offload'
      Merge branch 'bpf-verifier-fixes'
      Merge branch 'mlxsw-ipv4-host-dpipe-table'
      Merge branch 'xdp-more-work-on-xdp-tracepoints'
      devlink: Fix devlink_dpipe_table_register() stub signature.
      Merge branch 'ipv6-Route-ICMPv6-errors-with-the-flow-when-ECMP-in-use'
      Merge tag 'mlx5-updates-2017-08-24' of git://git.kernel.org/.../saeed/linux
      Merge branch 'ipv6-sr-updates'
      Merge branch 'net_sched-clean-up-tc-classes-and-u32-filter'
      Merge branch 'nfp-SR-IOV-ndos-support'
      Merge branch '40GbE' of git://git.kernel.org/.../jkirsher/next-queue
      Merge branch 'sockmap-uapi-updates-and-fixes'
      Merge branch 'gre-add-collect_md-mode-for-ERSPAN-tunnel'
      Merge branch 'mlxsw-dpipe-fixes'
      Merge branch 'dpaa_eth-rss'
      Merge branch 'irda-move-to-staging'
      Merge branch '40GbE' of git://git.kernel.org/.../jkirsher/next-queue
      Merge branch 'NCSI-vlan-filtering'
      Merge branch 'bnxt_en-next'
      Merge branch 'addrlabel-no-rtnl-locking'
      Merge tag 'rxrpc-next-20170829' of git://git.kernel.org/.../dhowells/linux-fs
      Merge branch 'XDP-redirect-tracepoints'
      Merge tag 'wireless-drivers-next-for-davem-2017-08-28' of git://git.kernel.org/.../kvalo/wireless-drivers-next
      Merge branch 'systemport-sf2-mdio-endian'
      Merge branch 'mlx4-misc-patches'
      Merge branch 'ife-ethertype'
      Merge branch 'nsh-headers-GSO'
      Merge branch 'tcp-readd-hp'
      Merge branch 'add-rmnet-driver'
      Merge branch 'net_sched-idr'
      Merge branch 'mvpp2-comphy'
      Merge tag 'mlx5-GRE-Offload' of git://git.kernel.org/.../saeed/linux
      Merge branch 'mlxsw-Add-IPv6-host-dpipe-table'
      Merge branch 'bpf-Add-option-to-set-mark-and-priority-in-cgroup-sock-programs'
      Merge branch 'master' of git://git.kernel.org/.../klassert/ipsec-next
      Merge branch 'bpf-Improve-LRU-map-lookup-performance'
      Merge branch 'mlxsw-next-fixes'
      Merge branch 'mvpp2-optional-PHYs-and-GoP-link-irq'
      Merge branch 'mdio-mux-Misc-fix'
      Merge tag 'wireless-drivers-next-for-davem-2017-09-01' of git://git.kernel.org/.../kvalo/wireless-drivers-next
      Merge git://git.kernel.org/.../davem/net
      Merge branch 'inet_diag-TCP-MD5'
      Merge branch 'net-ubuf_info-refcnt-conversion'
      Merge branch 'netvsc-vf-cleanups'
      Merge branch 'hv_netvsc-channel-settings-cleanups-and-fixes'
      Merge branch 'net-revert-lib-percpu_counter-API-for-fragmentation-mem-accounting'
      Merge branch 'l2tp-session-creation-fixes'
      Merge git://git.kernel.org/.../pablo/nf-next
      Merge branch 'mvpp2-improve-the-mac-address-retrieval-logic'
      Merge branch 'mlxsw-Offloading-GRE-tunnels'
      Merge tag 'mlx5-updates-2017-09-03' of git://git.kernel.org/.../saeed/linux
      Merge branch 'nfp-refactor-app-init-and-minor-flower-fixes'
      Merge branch 'qualcomm-rmnet-Fix-comments-on-initial-patchset'
      Merge branch 'for-upstream' of git://git.kernel.org/.../bluetooth/bluetooth-next
      Merge git://git.kernel.org/.../pablo/nf-next
      Merge branch 'flow_dissector-fixes'
      Merge branch 'dsa-tx-queues'
      Merge branch 'xgene-Misc-bug-fixes'
      Merge git://git.kernel.org/.../davem/net
      Merge branch '40GbE' of git://git.kernel.org/.../jkirsher/net-queue

David Spinadel (1):
      iwlwifi: mvm: Avoid deferring non bufferable frames

David Wu (13):
      net: phy: Add rockchip PHY driver support
      multi_v7_defconfig: Make rockchip PHY built-in
      arm64: defconfig: Enable CONFIG_ROCKCHIP_PHY
      net: stmmac: dwmac-rk: Remove unwanted code for rk3328_set_to_rmii()
      Documentation: net: phy: Add phy-is-integrated binding
      net: stmmac: dwmac-rk: Add integrated PHY support
      net: stmmac: dwmac-rk: Add integrated PHY support for rk3228
      net: stmmac: dwmac-rk: Add integrated PHY supprot for rk3328
      ARM: dts: rk3228-evb: Enable the integrated PHY for gmac
      ARM64: dts: rockchip: Add gmac2phy node support for rk3328
      ARM64: dts: rockchip: Enable gmac2phy for rk3328-evb
      net: ethernet: stmmac: dwmac-rk: Add rv1108 gmac support
      ARM: dts: rk3228-evb: Fix the compiling error

Davide Caratti (1):
      netfilter: conntrack: remove unused code in nf_conntrack_proto_generic.c

Dedy Lansky (4):
      wil6210: support FW RSSI reporting
      wil6210: store FW RF calibration result
      wil6210: move pre-FW configuration to separate function
      wil6210: clear PAL_UNIT_ICR part of device reset

Derek Chickles (3):
      liquidio: set sriov_totalvfs correctly
      liquidio: fix misspelled firmware image filenames
      liquidio: fix issues with fw_type module parameter

Derek Robson (1):
      Bluetooth: Style fix - align block comments

Dexuan Cui (1):
      hv_sock: implements Hyper-V transport for Virtual Sockets (AF_VSOCK)

Dimitris Michailidis (1):
      macvlan: add offload features for encapsulation

Dirk van der Merwe (1):
      nfp: set config bit (ifup/ifdown) on netdev open/close

Dmitry Tunin (2):
      Bluetooth: btusb: Add support of all Foxconn (105b) Broadcom devices
      Bluetooth: Add support of 13d3:3494 RTL8723BE device

Edward Cree (17):
      bpf/verifier: rework value tracking
      bpf/verifier: track signed and unsigned min/max values
      bpf/verifier: more concise register state logs for constant var_off
      selftests/bpf: change test_verifier expectations
      selftests/bpf: rewrite test_align
      selftests/bpf: add a test to test_align
      selftests/bpf: add test for bogus operations on pointers
      selftests/bpf: don't try to access past MAX_PACKET_OFF in test_verifier
      selftests/bpf: add tests for subtraction & negative numbers
      selftests/bpf: variable offset negative tests
      Documentation: describe the new eBPF verifier value tracking behaviour
      bpf/verifier: increase complexity limit to 128k
      bpf/verifier: track liveness for pruning
      selftests/bpf: add a test for a bug in liveness-based pruning
      bpf/verifier: when pruning a branch, ignore its write marks
      bpf/verifier: remove varlen_map_value_access flag
      bpf/verifier: document liveness analysis

Egil Hjelmeland (10):
      net: dsa: lan9303: Fix lan9303_detect_phy_setup() for MDIO
      net: dsa: lan9303: Multiply by 4 to get MDIO register
      net: dsa: lan9303: Renamed indirect phy access functions
      net: dsa: lan9303: MDIO access phy registers directly
      net: dsa: lan9303: Change lan9303_xxx_packet_processing() port param.
      net: dsa: lan9303: define LAN9303_NUM_PORTS 3
      net: dsa: lan9303: Simplify lan9303_xxx_packet_processing() usage
      net: dsa: lan9303: Rename lan9303_xxx_packet_processing()
      net: dsa: lan9303: refactor lan9303_get_ethtool_stats
      net: dsa: lan9303: Only allocate 3 ports

Emmanuel Grumbach (14):
      iwlwifi: mvm: fix the FIFO numbers in A000 devices
      iwlwifi: pcie: fix A-MSDU on gen2 devices
      iwlwifi: mvm: don't retake the pointer to skb's CB
      iwlwifi: pcie: don't init a Tx queue with an SSN > size of the queue
      iwlwifi: pcie: free the TSO page when a Tx queue is unmapped on A000 devices
      iwlwifi: mvm: fix the coex firmware API
      iwlwifi: mvm: remove the corunning support
      iwlwifi: mvm: support new Coex firmware API
      iwlwifi: pcie: support short Tx queues for A000 device family
      iwlwifi: mvm: add command name for FRAME_RELEASE
      iwlwifi: mvm: include more debug data when we get an unexpected baid
      iwlwifi: mvm: update the firmware API in TX
      iwlwifi: mvm: don't send BAR on flushed frames
      iwlwifi: mvm: bump API to 34 for 8000 and up

Eran Ben Elisha (3):
      net/mlx5e: Send PAOS command on interface up/down
      net/mlx5e: Add outbound PCI buffer overflow counter
      net/mlx4_core: Dynamically allocate structs at mlx4_slave_cap

Erez Shitrit (1):
      net/mlx5: Delay events till ib registration ends

Eric Biggers (1):
      strparser: initialize all callbacks

Eric Dumazet (13):
      inetpeer: remove AVL implementation in favor of RB tree
      tcp: tcp_data_queue() cleanup
      tun: make tun_build_skb() thread safe
      ipv4: convert dst_metrics.refcnt from atomic_t to refcount_t
      net: sched: use kvmalloc() for class hash tables
      tcp: fix hang in tcp_sendpage_locked()
      neigh: increase queue_len_bytes to match wmem_default
      xen-netfront: be more drop monitor friendly
      x86: bpf_jit: small optimization in emit_bpf_tail_call()
      inetpeer: fix RCU lookup()
      net: prepare (struct ubuf_info)->refcnt conversion
      net: convert (struct ubuf_info)->refcnt to refcount_t
      bpf: fix numa_node validation

Erik Stromdahl (4):
      ath10k: various usb related definitions
      ath10k: add initial USB support
      ath10k: sdio: fix compile warning
      ath10k: sdio: remove unused struct member

Fabio Estevam (1):
      mdio_bus: Remove unneeded gpiod NULL check

Felix Manlunas (2):
      liquidio: bump up driver version to match newer NIC firmware
      liquidio: change manner of detecting whether or not NIC firmware is loaded

Feras Daoud (1):
      net/mlx5e: IPoIB, Fix driver name retrieved by ethtool

Florian Fainelli (27):
      bcma: gpio: Correct number of GPIOs for BCM53573
      net: phy: Remove stale comments referencing timer
      net: phy: mdio-bcm-unimac: factor busy polling loop
      net: phy: mdio-bcm-unimac: create unique bus names
      net: phy: mdio-bcm-unimac: Add debug print for PHY workaround
      net: phy: mdio-bcm-unimac: Allow specifying platform data
      net: bcmgenet: utilize generic Broadcom UniMAC MDIO controller driver
      net: bcmgenet: Drop legacy MDIO code
      net: bcmgenet: Utilize bcmgenet_mii_exit() for error path
      net: bcmgenet: Add dependency on HAS_IOMEM && OF
      net: dsa: Add support for 64-bit statistics
      net: dsa: User per-cpu 64-bit statistics
      tg3: Be drop monitor friendly
      net: mv643xx_eth: Be drop monitor friendly
      net: systemport: Use correct I/O accessors
      net: dsa: bcm_sf2: Use correct I/O accessors
      net: systemport: Set correct RSB endian bits based on host
      net: phy: mdio-bcm-unimac: Use correct I/O accessors
      Documentation: networking: Add blurb about patches in patchwork
      net: bcmgenet: Use correct I/O accessors
      net: bcmgenet: Do not return from void function
      net: systemport: Correctly set TSB endian for host
      net: dsa: loop: Do not unregister invalid fixed PHY
      net: dsa: Allow switch drivers to indicate number of TX queues
      net: dsa: tag_brcm: Set output queue from skb queue mapping
      net: dsa: bcm_sf2: Advertise number of egress queues
      net: dsa: bcm_sf2: Configure IMP port TC2QOS mapping

Florian Westphal (66):
      net: Revert "net: add function to allocate sk_buff head without data area"
      drivers: net: add missing interrupt.h include
      vti: revert flush x-netns xfrm cache when vti interface is removed
      net: xfrm: revert to lower xfrm dst gc limit
      xfrm_policy: bypass flow_cache_lookup
      xfrm_policy: remove always true/false branches
      xfrm_policy: kill flow to policy dir conversion
      xfrm_policy: remove xfrm_policy_lookup
      xfrm_policy: make xfrm_bundle_lookup return xfrm dst object
      xfrm: remove flow cache
      xfrm: add xdst pcpu cache
      netfilter: expect: add to hash table after expect init
      skbuff: re-add check for NULL skb->head in kfree_skb path
      netfilter: expect: add and use nf_ct_expect_iterate helpers
      netfilter: add and use nf_ct_unconfirmed_destroy
      netfilter: conntrack: destroy functions need to free queued packets
      netfilter: nfnetlink_queue: don't queue dying conntracks to userspace
      netfilter: nf_hook_ops structs can be const
      netfilter: nft_set_rbtree: use seqcount to avoid lock in most cases
      netfilter: conntrack: do not enable connection tracking unless needed
      tcp: remove prequeue support
      tcp: reindent two spots after prequeue removal
      tcp: remove low_latency sysctl
      tcp: remove header prediction
      tcp: remove CA_ACK_SLOWPATH
      tcp: remove unused mib counters
      xfrm: check that cached bundle is still valid
      rtnetlink: call rtnl_calcit directly
      rtnetlink: make rtnl_register accept a flags parameter
      rtnetlink: add reference counting to prevent module unload while dump is in progress
      rtnetlink: small rtnl lock pushdown
      rtnetlink: protect handler table with rcu
      rtnetlink: add RTNL_FLAG_DOIT_UNLOCKED
      net: call newid/getid without rtnl mutex held
      rtnetlink: use rcu_dereference_raw to silence rcu splat
      rtnetlink: do not use RTM_GETLINK directly
      rtnetlink: switch rtnl_link_get_slave_info_data_size to rcu
      rtnetlink: init handler refcounts to 1
      rtnetlink: fallback to UNSPEC if current family has no doit callback
      selftests: add rtnetlink test script
      selftests: add 'ip get' to rtnetlink.sh
      ipv6: route: make rtm_getroute not assume rtnl is locked
      ipv6: route: set ipv6 RTM_GETROUTE to not use rtnl
      ipv4: route: set ipv4 RTM_GETROUTE to not use rtnl
      netfilter: exthdr: factor out tcp option access
      netfilter: exthdr: split netlink dump function
      netfilter: exthdr: tcp option set support
      netfilter: rt: add support to fetch path mss
      dsa: remove unused net_device arg from handlers
      netfilter: conntrack: compute l3proto nla size at compile time
      netfilter: conntrack: remove protocol name from l3proto struct
      netfilter: conntrack: remove protocol name from l4proto struct
      netfilter: conntrack: reduce size of l4protocol trackers
      netfilter: conntrack: place print_tuple in procfs part
      netfilter: conntrack: print_conntrack only needed if CONFIG_NF_CONNTRACK_PROCFS
      netfilter: conntrack: make protocol tracker pointers const
      netfilter: fix a few (harmless) sparse warnings
      netfilter: debug: check for sorted array
      netfilter: core: batch nf_unregister_net_hooks synchronize_net calls
      netfilter: conntrack: don't log "invalid" icmpv6 connections
      netfilter: rt: account for tcp header size too
      selftests: add addrlabel add/delete to rtnetlink.sh
      addrlabel: add/delete/get can run without rtnl
      tcp: Revert "tcp: remove CA_ACK_SLOWPATH"
      tcp: Revert "tcp: remove header prediction"
      netfilter: remove unused hooknum arg from packet functions

Florinel Iordache (1):
      fsl/fman: implement several errata workarounds

Gabriel Craciunescu (1):
      ath10k: ath10k_htt_rx_amsdu_allowed() use ath10k_dbg()

Gal Pressman (11):
      net/mlx5: Add PCIe outbound stalls counters infrastructure
      net/mlx5e: Add PCIe outbound stalls counters
      net/mlx5: Add RX buffer fullness counters infrastructure
      net/mlx5e: Add RX buffer fullness counters
      net/mlx5e: Use kernel types instead of uint*_t in ethtool callbacks
      net/mlx5e: Use size_t to store byte offset in statistics descriptors
      net/mlx5: Remove a leftover unused variable
      net/mlx5e: Fix wrong code indentation in conditional statement
      net/mlx5e: Use IP version matching to classify IP traffic
      net/mlx5e: Support TSO and TX checksum offloads for GRE tunnels
      net/mlx5e: Support RSS for GRE tunneled packets

Ganapathi Bhat (3):
      mwifiex: replace netif_carrier_on/off by netif_device_attach/dettach
      mwifiex: do not use random MAC for pre-association scanning
      mwifiex: check for NL80211_SCAN_FLAG_RANDOM_ADDR during hidden SSID scan

Ganesh Goudar (5):
      cxgb4: display serial config and vpd versions
      cxgb4/cxgbvf: Handle 32-bit fw port capabilities
      cxgb4: fix memory leak
      cxgb4: Fix pause frame count in t4_get_port_stats
      cxgb4: Ignore MPS_TX_INT_CAUSE[Bubble] for T6

Gangfeng Huang (1):
      igb: Fix error of RX network flow classification

Gao Feng (2):
      net: sched: Add the invalid handle check in qdisc_class_find
      sched: sfq: drop packets after root qdisc lock is released

Geliang Tang (1):
      netfilter: use audit_log()

Gidon Studinski (2):
      wil6210: move vring_idle_trsh definition to wil6210_priv
      wil6210: make debugfs compilation optional

Girish Moodalbail (3):
      geneve: add rtnl changelink support
      geneve: use netlink_ext_ack for error reporting in rtnl operations
      vxlan: change vxlan_[config_]validate() to use netlink_ext_ack for error reporting

Golan Ben-Ami (2):
      iwlwifi: dump smem configuration when firmware crashes
      iwlwifi: fix nmi triggering from host

Govind Singh (2):
      ath10k: make CE layer bus agnostic
      ath10k: add copy engine register MAP for wcn3990 target

Greg Edwards (6):
      igb: add argument names to mailbox op function declarations
      igb: expose mailbox unlock method
      igb: do not drop PF mailbox lock after read of VF message
      igbvf: add lock around mailbox ops
      igbvf: after mailbox write, wait for reply
      igbvf: convert msleep to mdelay in atomic context

Greg KH (1):
      staging: irda: fix init level for irda core

Greg Kroah-Hartman (5):
      irda: move net/irda/ to drivers/staging/irda/net/
      irda: move drivers/net/irda to drivers/staging/irda/drivers
      irda: move include/net/irda into staging subdirectory
      staging: irda: add a TODO file.
      staging: irda: update MAINTAINERS

Gregory Greenman (1):
      iwlwifi: mvm: change open and close criteria of a BA session

Guillaume Nault (2):
      l2tp: prevent creation of sessions on terminated tunnels
      l2tp: pass tunnel pointer to ->session_create()

Gustavo A R Silva (2):
      i40e: fix incorrect variable assignment
      e1000e: add check on e1e_wphy() return value

Gustavo A. R. Silva (12):
      wireless: airo: remove unnecessary static in writerids()
      rtlwifi: remove useless code
      net: tulip: remove useless code in tulip_init_one()
      qlcnic: remove unnecessary static in qlcnic_dump_fw()
      net: ethernet: mediatek: remove useless code in mtk_poll_tx()
      liquidio: lio_vf_main: remove unnecessary static in setup_io_queues()
      liquidio: lio_main: remove unnecessary static in setup_io_queues()
      Bluetooth: btwilink: remove unnecessary static in bt_ti_probe()
      liquidio: fix duplicated code for different branches
      qlge: fix duplicated code for different branches
      rtlwifi: btcoex: 23b 1ant: fix duplicated code for different branches
      rtlwifi: rtl8723be: fix duplicated code for different branches

Haim Dreyfuss (1):
      iwlwifi: mvm: support new beacon template command

Haiyang Zhang (10):
      hv_netvsc: Clean up unused parameter from netvsc_get_hash()
      hv_netvsc: Clean up unused parameter from netvsc_get_rss_hash_opts()
      hv_netvsc: Add ethtool handler to set and get UDP hash levels
      hv_netvsc: Update netvsc Document for UDP hash level setting
      hv_netvsc: Fix rndis_filter_close error during netvsc_remove
      hv_netvsc: Fix typos in the document of UDP hashing
      hv_netvsc: Clean up an unused parameter in rndis_filter_set_rss_param()
      hv_netvsc: Simplify num_chn checking in rndis_filter_device_add()
      hv_netvsc: Simplify the limit check in netvsc_set_channels()
      hv_netvsc: Fix the channel limit in netvsc_set_rxfh()

Hamad Kadmany (2):
      wil6210: protect against invalid length of tx management frame
      wil6210: fix interface-up check

Hans de Goede (1):
      brcmfmac: Log chip id and revision

Hauke Mehrtens (1):
      ath10k: activate user space firmware loading again

Himanshu Jha (2):
      net: ethernet: broadcom: Remove null check before kfree
      rsi: remove memset before memcpy

Håkon Bugge (1):
      rds: Fix non-atomic operation on shared flag variable

Ian Molton (5):
      Bluetooth: hci_nokia: prevent crash on module removal
      Bluetooth: hci_nokia: remove duplicate call to pm_runtime_disable()
      Bluetooth: hci_serdev: Introduce hci_uart_unregister_device()
      Bluetooth: hci_nokia: Use new hci_uart_unregister_device() function
      Bluetooth: hci_ll: Use new hci_uart_unregister_device() function

Ido Schimmel (54):
      mlxsw: spectrum: Mark packets trapped in router
      mlxsw: spectrum: Trap IPv4 packets with Router Alert option
      mlxsw: spectrum_router: Flood unregistered multicast packets to router
      mlxsw: spectrum_router: Don't assume neighbour type
      mlxsw: spectrum_router: Don't create FIB node during lookup
      mlxsw: spectrum_router: Make FIB node retrieval family agnostic
      mlxsw: spectrum_router: Extend virtual routers with IPv6 support
      mlxsw: reg: Update RALUE register with IPv6 support
      mlxsw: spectrum_router: Allow IPv6 routes to be programmed
      mlxsw: spectrum_router: Set abort trap for IPv6
      mlxsw: spectrum_router: Create IPv4 specific entry struct
      mlxsw: spectrum_router: Mark IPv4 specific function accordingly
      mlxsw: spectrum_router: Drop unnecessary parameter
      mlxsw: spectrum_router: Rename functions to add / delete a FIB entry
      mlxsw: spectrum_router: Update prefix count for IPv6
      mlxsw: spectrum_router: Don't batch neighbour deletion
      mlxsw: spectrum_router: Fix build when IPv6 isn't enabled
      mlxsw: core: Use correct EMAD transaction ID in debug message
      ipv4: fib: Set offload indication according to nexthop flags
      rocker: Provide offload indication using nexthop flags
      mlxsw: spectrum_router: Provide offload indication using nexthop flags
      mlxsw: spectrum_router: Don't check state when refreshing offload indication
      mlxsw: spectrum_router: Refresh offload indication upon group refresh
      ipv4: fib: Remove unused functions
      net: core: Make the FIB notification chain generic
      mlxsw: spectrum_router: Ignore address families other than IPv4
      rocker: Ignore address families other than IPv4
      net: fib_rules: Implement notification logic in core
      ipv6: fib_rules: Check if rule is a default rule
      ipv6: fib: Add FIB notifiers callbacks
      ipv6: fib: Add in-kernel notifications for route add / delete
      ipv6: fib_rules: Dump rules during registration to FIB chain
      ipv6: fib: Dump tables during registration to FIB chain
      ipv6: fib: Add offload indication to routes
      ipv6: fib: Don't assume only nodes hold a reference on routes
      ipv6: fib: Unlink replaced routes from their nodes
      ipv6: Regenerate host route according to node pointer upon loopback up
      ipv6: Regenerate host route according to node pointer upon interface up
      ipv6: fib: Add helpers to hold / drop a reference on rt6_info
      mlxsw: spectrum_router: Demultiplex FIB event based on family
      mlxsw: spectrum_router: Sanitize IPv6 FIB rules
      mlxsw: spectrum_router: Add support for IPv6 routes addition / deletion
      mlxsw: spectrum_router: Add support for route replace
      mlxsw: spectrum_router: Abort on source-specific routes
      mlxsw: spectrum_router: Don't ignore IPv6 notifications
      mlxsw: spectrum_router: Return void from deletion functions
      mlxsw: spectrum_router: Pass argument explicitly
      mlxsw: spectrum_router: Use one LPM tree for all virtual routers
      ipv6: fib: Provide offload indication using nexthop flags
      mlxsw: spectrum_router: Use correct config option
      mlxsw: spectrum_router: Trap packets hitting anycast routes
      mlxsw: spectrum_router: Set abort trap in all virtual routers
      net: Add module reference to FIB notifiers
      bridge: switchdev: Use an helper to clear forward mark

Ilan Peer (1):
      iwlwifi: mvm: Fix channel switch in case of count <= 1

Ilan Tayari (4):
      esp4: Support RX checksum with crypto offload
      esp6: Support RX checksum with crypto offload
      xfrm: Auto-load xfrm offload modules
      xfrm: Clear RX SKB secpath xfrm_offload

Intiyaz Basha (20):
      liquidio: add missing strings in oct_dev_state_str array
      liquidio: moved console_bitmask module param to lio_main.c
      liquidio: fix wrong info about vf rx/tx ring parameters reported to ethtool
      liquidio: napi cleanup
      liquidio: rx/tx queue cleanup
      liquidio: removed check for queue size alignment
      liquidio: moved ptp_enable to octeon_device structure
      liquidio: moved wait_for_pending_requests to octeon_network.h
      liquidio: moved update_txq_status to lio_core.c
      liquidio: moved octeon_setup_droq to lio_core.c
      liquidio: moved liquidio_push_packet to lio_core.c
      liquidio: moved liquidio_napi_drv_callback to lio_core.c
      liquidio: moved liquidio_napi_poll to lio_core.c
      liquidio: moved liquidio_setup_io_queues to lio_core.c
      liquidio: added support for ethtool --set-ring feature
      liquidio: moved liquidio_msix_intr_handler to lio_core.c
      liquidio: moved liquidio_legacy_intr_handler to lio_core.c
      liquidio: moved octeon_setup_interrupt to lio_core.c
      liquidio: added support for ethtool --set-channels feature
      liquidio: fix Smatch error

Iordache Florinel-R70177 (1):
      fsl/fman: enable FMan Keygen

Ivan Delalande (2):
      inet_diag: allow protocols to provide additional data
      tcp_diag: report TCP MD5 signing keys and addresses

Iyappan Subramanian (2):
      drivers: net: xgene: Read tx/rx delay for ACPI
      drivers: net: xgene: Remove return statement from void function

Jacob Keller (17):
      i40e: remove WQ_UNBOUND and the task limit of our workqueue
      i40e: display correct UDP tunnel type name
      i40e: separate hw_features from runtime changing flags
      i40e: remove workaround for Open Firmware MAC address
      i40e/i40evf: use cmpxchg64 when updating private flags in ethtool
      i40e: move check for avoiding VID=0 filters into i40e_vsi_add_vlan
      i40e: use cpumask_copy instead of direct assignment
      i40e: prevent snprintf format specifier truncation
      i40evf: fix possible snprintf truncation of q_vector->name
      i40e: force VMDQ device name truncation
      i40e: remove workaround for resetting XPS
      i40e: move enabling icr0 into i40e_update_enable_itr
      i40e: initialize our affinity_mask based on cpu_possible_mask
      i40e: invert logic for checking incorrect cpu vs irq affinity
      i40e/i40evf: remove ULTRA latency mode
      i40e/i40evf: avoid dynamic ITR updates when polling or low packet rate
      i40e: point wb_desc at the nvm_wb_desc during i40e_read_nvm_aq

Jakub Kicinski (24):
      bpf: install libbpf headers on 'make install'
      nfp: remove the probe deferral when FW not present
      nfp: look for firmware image by device serial number and PCI name
      nfp: only use direct firmware requests
      nfp: link basic ethtool ops to representors
      nfp: provide ethtool_drvinfo on representors
      nfp: allow retreiving management FW logs on representors
      nfp: don't report standard netdev statistics in ethtool
      nfp: add helper for printing ethtool strings
      nfp: split software and hardware vNIC statistics
      nfp: store pointer to MAC statistics in nfp_port
      nfp: report MAC statistics in ethtool
      nfp: add pointer to vNIC config memory to nfp_port structure
      nfp: add ethtool statistics for representors
      nfp: fix copy paste in names and messages regarding vNICs
      nfp: don't reuse pointers in ring dumping
      selftests/bpf: check the instruction dumps are populated
      nfp: separate app vNIC init/clean from alloc/free
      nfp: flower: base lifetime of representors on existence of lower vNIC
      nfp: move the start/stop app callbacks back
      nfp: be drop monitor friendly
      nfp: build the flower offload by default
      nfp: flower: restore RTNL locking around representor updates
      net: sched: don't use GFP_KERNEL under spin lock

Jakub Sitnicki (7):
      ipv6: Avoid going through ->sk_net to access the netns
      rtnelink: Move link dump consistency check out of the loop
      ipv6: Add sysctl for per namespace flow label reflection
      net: Extend struct flowi6 with multipath hash
      ipv6: Compute multipath hash for ICMP errors from offending packet
      ipv6: Fold rt6_info_hash_nhsfn() into its only caller
      ipv6: Use multipath hash from flow info if available

Jamal Hadi Salim (4):
      net netlink: Add new type NLA_BITFIELD32
      net sched actions: Use proper root attribute table for actions
      net sched actions: dump more than TCA_ACT_MAX_PRIO actions per batch
      net sched actions: add time filter for action dumping

Jason Wang (11):
      virtio_ring: allow to store zero as the ctx
      virtio-net: pack headroom into ctx for mergeable buffers
      virtio-net: switch to use new ctx API for small buffer
      virtio-net: do not reset during XDP set
      virtio-net: switch off offloads on demand if possible on XDP set
      tap: use build_skb() for small packet
      net: export some generic xdp helpers
      tap: XDP support
      tun: reserve extra headroom only when XDP is set
      tun: rename generic_xdp to skb_xdp
      vhost_net: correctly check tx avail during rx busy polling

Jeffy Chen (2):
      Bluetooth: btusb: Fix memory leak in play_deferred
      mwifiex: uninit wakeup info in the error handling

Jesper Dangaard Brouer (17):
      qdisc: add tracepoint qdisc:qdisc_dequeue for dequeued SKBs
      ixgbe: change ndo_xdp_xmit return code on xmit errors
      xdp: adjust xdp redirect tracepoint to include return error code
      xdp: remove bpf_warn_invalid_xdp_redirect
      xdp: make generic xdp redirect use tracepoint trace_xdp_redirect
      ixgbe: use return codes from ndo_xdp_xmit that are distinguishable
      xdp: remove net_device names from xdp_redirect tracepoint
      xdp: get tracepoints xdp_exception and xdp_redirect in sync
      xdp: remove redundant argument to trace_xdp_redirect
      xdp: tracepoint xdp_redirect also need a map argument
      xdp: make xdp tracepoints report bpf prog id instead of prog_tag
      xdp: separate xdp_redirect tracepoint in error case
      xdp: separate xdp_redirect tracepoint in map case
      samples/bpf: xdp_redirect load XDP dummy prog on TX device
      samples/bpf: xdp_monitor tool based on tracepoints
      Revert "net: use lib/percpu_counter API for fragmentation mem accounting"
      Revert "net: fix percpu memory leaks"

Jesse Brandeburg (5):
      i40e: fix up 32 bit timespec references
      i40e: fix odd formatting and indent
      i40e/i40evf: make IPv6 ATR code clearer
      i40e/i40evf: remove mismatched type warnings
      i40evf: add some missing includes

Jiri Benc (3):
      ether: add NSH ethertype
      vxlan: factor out VXLAN-GPE next protocol
      nsh: add GSO support

Jiri Pirko (48):
      net: sched: sch_atm: use Qdisc_class_common structure
      net: sched: remove unneeded tcf_em_tree_change
      net: sched: change names of action number helpers to be aligned with the rest
      net: sched: use tcf_exts_has_actions in tcf_exts_exec
      net: sched: remove redundant helpers tcf_exts_is_predicative and tcf_exts_is_available
      net: sched: fix return value of tcf_exts_exec
      net: sched: remove check for number of actions in tcf_exts_exec
      net: sched: use tcf_exts_has_actions instead of exts->nr_actions
      net: sched: cls_bpf: rename cls_bpf_modify_existing function
      net: sched: cls_fw: rename fw_change_attrs function
      net: sched: cls_flower: no need to call tcf_exts_change for newly allocated struct
      net: sched: cls_fw: no need to call tcf_exts_change for newly allocated struct
      net: sched: cls_matchall: no need to call tcf_exts_change for newly allocated struct
      net: sched: cls_basic: no need to call tcf_exts_change for newly allocated struct
      net: sched: cls_bpf: no need to call tcf_exts_change for newly allocated struct
      net: sched: cls_cgroup: no need to call tcf_exts_change for newly allocated struct
      net: sched: cls_flow: no need to call tcf_exts_change for newly allocated struct
      net: sched: cls_route: no need to call tcf_exts_change for newly allocated struct
      net: sched: cls_u32: no need to call tcf_exts_change for newly allocated struct
      net: sched: avoid atomic swap in tcf_exts_change
      net: sched: make type an argument for ndo_setup_tc
      net: sched: rename TC_SETUP_MATCHALL to TC_SETUP_CLSMATCHALL
      net: sched: make egress_dev flag part of flower offload struct
      cxgb4: push cls_u32 setup_tc processing into a separate function
      ixgbe: push cls_u32 and mqprio setup_tc processing into separate functions
      mlx5e: push cls_flower and mqprio setup_tc processing into separate functions
      mlx5e_rep: push cls_flower setup_tc processing into a separate function
      mlxsw: spectrum: push cls_flower and cls_matchall setup_tc processing into separate functions
      mlxsw: spectrum: rename cls arg in matchall processing
      dsa: push cls_matchall setup_tc processing into a separate function
      nfp: change flows in apps that offload ndo_setup_tc
      hns3pf: don't check handle during mqprio offload
      net: sched: push cls related args into cls_common structure
      net: sched: move prio into cls_common
      net: sched: change return value of ndo_setup_tc for driver supporting mqprio only
      net: sched: get rid of struct tc_to_netdev
      net: sched: Add helpers to identify classids
      net: sched: propagate classid down to offload drivers
      net: sched: use newly added classid identity helpers
      net: sched: remove handle propagation down to the drivers
      net: sched: remove cops->tcf_cl_offload
      net: sched: cls_flower: fix ndo_setup_tc type for stats call
      mlxsw: spectrum: Offload multichain TC rules
      net: sched: add couple of goto_chain helpers
      mlxsw: spectrum_acl: Allow to get group_id value for a ruleset
      mlxsw: spectrum_acl: Provide helper to lookup ruleset
      mlxsw: spectrum_flower: Offload goto_chain termination action
      mlxsw: spectrum: compile-in dpipe support only if devlink is enabled

Joan Jani (1):
      Bluetooth: btqca: Fixed a coding style error

Joe Perches (3):
      batman-adv: Remove unnecessary length qualifier in %14pM
      hyperv: netvsc: Neaten netvsc_send_pkt by using a temporary
      openvswitch: Remove unnecessary newlines from OVS_NLERR uses

Johannes Berg (15):
      iwlwifi: refactor out paging code
      iwlwifi: refactor shared mem parsing
      iwlwifi: track current firmware image in common code
      iwlwifi: refactor firmware debug code
      iwlwifi: reorganize firmware API
      iwlwifi: fw api: fix various kernel-doc warnings
      iwlwifi: mvm: add and use iwl_mvm_has_unified_ucode()
      iwlwifi: mvm: check family instead of new TX API for workarounds
      iwlwifi: mvm: byte-swap constant instead of variable
      iwlwifi: pcie: rename iwl_trans_check_hw_rf_kill() to pcie
      iwlwifi: mvm: require AP_LINK_PS for TVQM
      iwlwifi: mvm: simplify bufferable MMPDU check
      iwlwifi: mvm: remove non-DQA mode
      iwlwifi: mvm: remove useless condition in LED code
      iwlwifi: mvm: use firmware LED command where applicable

John Allen (6):
      ibmvnic: Check for transport event on driver resume
      ibmvnic: Implement per-queue statistics reporting
      ibmvnic: Convert vnic server reported statistics to cpu endian
      ibmvnic: Implement .get_ringparam
      ibmvnic: Implement .get_channels
      ibmvnic: Report rx buffer return codes as netdev_dbg

John Crispin (7):
      net-next: mediatek: fix typos inside the header file
      net-next: mediatek: bring up QDMA RX ring 0
      net-next: dsa: move struct dsa_device_ops to the global header file
      net-next: dsa: add flow_dissect callback to struct dsa_device_ops
      net-next: tag_mtk: add flow_dissect callback to the ops struct
      net-next: dsa: fix flow dissection
      net: core: fix compile error inside flow_dissector due to new dsa callback

John Fastabend (39):
      ixgbe: NULL xdp_tx rings on resource cleanup
      net: xdp: support xdp generic on virtual devices
      xdp: add bpf_redirect helper function
      xdp: sample program for new bpf_redirect helper
      net: implement XDP_REDIRECT for xdp generic
      ixgbe: add initial support for xdp redirect
      xdp: add trace event for xdp redirect
      bpf: add devmap, a map for storing net device references
      bpf: add bpf_redirect_map helper routine
      xdp: Add batching support to redirect map
      net: add notifier hooks for devmap bpf map
      xdp: bpf redirect with map sample program
      net: fix build error in devmap helper calls
      bpf: testing: fix devmap tests
      net: comment fixes against BPF devmap helper calls
      bpf: devmap fix mutex in rcu critical section
      net: early init support for strparser
      net: add sendmsg_locked and sendpage_locked to af_inet6
      net: fixes for skb_send_sock
      bpf: introduce new program type for skbs on sockets
      bpf: export bpf_prog_inc_not_zero
      bpf: sockmap with sk redirect support
      bpf: add access to sock fields and pkt data from sk_skb programs
      bpf: sockmap sample program
      bpf: selftests: add tests for new __sk_buff members
      bpf: selftests add sockmap tests
      bpf: devmap: remove unnecessary value size check
      bpf: sockmap state change warning fix
      bpf: sock_map fixes for !CONFIG_BPF_SYSCALL and !STREAM_PARSER
      bpf: convert sockmap field attach_bpf_fd2 to type
      bpf: sockmap, remove STRPARSER map_flags and add multi-map support
      bpf: sockmap add missing rcu_read_(un)lock in smap_data_ready
      bpf: additional sockmap self tests
      bpf: more SK_SKB selftests
      bpf: harden sockmap program attach to ensure correct map type
      bpf: sockmap indicate sock events to listeners
      bpf: sockmap requires STREAM_PARSER add Kconfig entry
      bpf: test_maps add sockmap stress test
      bpf: sockmap update/simplify memory accounting scheme

John W Linville (1):
      igb: support BCM54616 PHY

Jon Paul Maloy (1):
      tipc: don't reset stale broadcast send link

João Paulo Rechi Vita (1):
      iwlwifi: Demote messages about fw flags size to info

Julia Lawall (7):
      ipv6: constify inet6_protocol structures
      l2tp: constify inet6_protocol structures
      Revert "ipv6: constify inet6_protocol structures"
      Revert "l2tp: constify inet6_protocol structures"
      netfilter: constify nf_conntrack_l3/4proto parameters
      netfilter: constify nf_loginfo structures
      X25: constify null_x25_address

Julian Wiedmann (16):
      s390/qeth: don't access skb after transmission
      s390/qeth: remove extra L2 adapterparms query
      s390/qeth: remove extra L3 adapterparms query
      s390/qeth: simplify fragment type selection
      s390/qeth: straighten out fill_buffer() interface
      s390/qeth: clean up fill_buffer() offset logic
      s390/qeth: make more use of skb API
      s390/net: reduce inlining
      s390/qeth: extract bridgeport cmd builder
      s390/qeth: split L2 xmit paths
      s390/qeth: pass full data length to l2_fill_header()
      s390/qeth: pass TSO header length to fill_buffer()
      s390/qeth: pass TSO data offset to fill_buffer()
      s390/qeth: pass full IQD header length to fill_buffer()
      s390/qeth: unify code to build header elements
      s390/qeth: use skb_cow_head() for L2 OSA xmit

Kalle Valo (9):
      ath10k: fix indenting in ath10k_wmi_update_noa()
      Merge ath-next from git://git.kernel.org/.../kvalo/ath.git
      Merge tag 'iwlwifi-next-for-kalle-2017-08-01' of git://git.kernel.org/.../iwlwifi/iwlwifi-next
      Merge tag 'iwlwifi-next-for-kalle-2017-08-11' of git://git.kernel.org/.../iwlwifi/iwlwifi-next
      Merge tag 'iwlwifi-next-for-kalle-2017-08-18' of git://git.kernel.org/.../iwlwifi/iwlwifi-next
      Merge ath-next from git://git.kernel.org/.../kvalo/ath.git
      Merge git://git.kernel.org/.../kvalo/wireless-drivers.git
      Merge tag 'iwlwifi-next-for-kalle-2017-08-30' of git://git.kernel.org/.../iwlwifi/iwlwifi-next
      Merge ath-next from git://git.kernel.org/.../kvalo/ath.git

Karun Eagalapati (19):
      rsi: fix sdio card reset problem
      rsi: chip reset for SDIO interface
      rsi: correct SDIO disconnect path handling
      rsi: card reset for USB interface
      rsi: USB tx headroom cleanup
      rsi: rename USB endpoint macros
      rsi: choose correct endpoint based on queue.
      rsi: set immediate wakeup bit
      rsi: rename variable in_sdio_litefi_irq
      rsi: Optimise sdio claim and release host
      rsi: SDIO Rx packet processing enhancement
      rsi: use separate mutex lock for receive thread
      rsi: Rename mutex tx_rxlock to the tx_lock.
      rsi: add support for legacy power save
      rsi: add support for U-APSD power save
      rsi: rename sdio_read_buffer_status_register
      rsi: buffer full check optimization
      rsi: buffer available interrupt handling
      rsi: RTS threshold configuration

Kittipon Meesompop (3):
      s390/qeth: reject multicast rxip addresses
      s390/qeth: fix trace-messages for deleting rxip addresses
      s390/qeth: fix using of ref counter for rxip addresses

Konstantin Khlebnikov (2):
      net_sched: call qlen_notify only if child qdisc is empty
      net_sched/hfsc: opencode trivial set_active() and set_passive()

Lazar Alexei (1):
      wil6210: align to latest auto generated wmi.h

Leif Liddy (1):
      Bluetooth: btusb: fix QCA Rome suspend/resume

Lendacky, Thomas (13):
      amd-xgbe: Set the MDIO mode for 10000Base-T configuration
      amd-xgbe: Set the MII control width for the MAC interface
      amd-xgbe: Be sure driver shuts down cleanly on module removal
      amd-xgbe: Update TSO packet statistics accuracy
      amd-xgbe: Add support to handle device renaming
      amd-xgbe: Add additional dynamic debug messages
      amd-xgbe: Optimize DMA channel interrupt enablement
      amd-xgbe: Add hardware features debug output
      amd-xgbe: Add per queue Tx and Rx statistics
      net: ethtool: Add macro to clear a link mode setting
      amd-xgbe: Convert to using the new link mode settings
      amd-xgbe: Add support for VXLAN offload capabilities
      amd-xgbe: Add additional ethtool statistics

Leon Romanovsky (1):
      net/mlx4_core: Make explicit conversion to 64bit value

Levin, Alexander (Sasha Levin) (1):
      net: inet: diag: expose sockets cgroup classid

Liad Kaufman (3):
      iwlwifi: mvm: support fw reading empty OTP
      iwlwifi: fix a000 RF_ID define
      iwlwifi: fix long debug print

Lin Yun Sheng (2):
      net: hns: Add self-adaptive interrupt coalesce support in hns driver
      net: hns: Fix for __udivdi3 compiler error

Lior David (3):
      wil6210: ratelimit errors in TX/RX interrupts
      wil6210: increase connect timeout
      wil6210: ensure P2P device is stopped before removing interface

Loic Poulain (5):
      Bluetooth: hci_bcm: Make bcm_request_irq fail if no IRQ resource
      Bluetooth: hci_uart: Fix uninitialized alignment value
      Bluetooth: hci_bcm: Add serdev support
      dt-bindings: net: bluetooth: Add broadcom-bluetooth
      Bluetooth: make baswap src const

Lorenzo Colitti (1):
      net: xfrm: support setting an output mark.

Luca Coelho (16):
      iwlwifi: mvm: refactor beacon template command code
      iwlwifi: mvm: rename p2p-specific sta functions to include p2p in the names
      iwlwifi: fix a few instances of misaligned kerneldoc parameters
      iwlwifi: remove references to unsupported HW
      iwlwifi: mvm: consider RFKILL during INIT as success
      iwlwifi: call iwl_remove_notification from iwl_wait_notification
      iwlwifi: mvm: group all dummy SAR function declarations together
      iwlwifi: mvm: use mvmsta consistently in rs.c
      iwlwifi: move BT_MBOX_PRINT macro to common header
      iwlwifi: pci: add new PCI ID for 7265D
      iwlwifi: update channel flags parser
      iwlwifi: add workaround to disable wide channels in 5GHz
      iwlwifi: fw: fix lar_enabled endian problem in iwl_fw_get_nvm
      iwlwifi: mvm: remove useless argument in iwl_nvm_init()
      iwlwifi: mvm: remove useless check for mvm->cfg in iwl_parse_nvm_section()
      iwlwifi: use big-endian for the hw section of the nvm

Madalin Bucur (6):
      fsl/fman: move struct fman to header file
      dpaa_eth: use multiple Rx frame queues
      dpaa_eth: enable Rx hashing control
      dpaa_eth: add NETIF_F_RXHASH
      Documentation: networking: add RSS information
      dpaa_eth: check allocation result

Malcolm Priestley (1):
      rtlwifi: rtl_pci_probe: Fix fail path of _rtl_pci_find_adapter

Manikanta Pubbisetty (3):
      ath10k: extend wmi service map to accommodate new services
      ath10k: add tdls support for 10.4 firmwares
      ath10k: push peer type to target for TDLS peers

Marc Gonzalez (1):
      net: phy: Log only PHY state transitions

Marcel Holtmann (6):
      Bluetooth: hci_nokia: select BT_BCM for btbcm_set_bdaddr()
      Bluetooth: btusb: Add workaround for Broadcom devices without product id
      Bluetooth: hci_bcm: Use operation speed of 4Mbps only for ACPI devices
      Bluetooth: btbcm: Consolidate the controller information commands
      Bluetooth: hci_bcm: Handle empty packet after firmware loading
      Bluetooth: Add option for disabling legacy ioctl interfaces

Mariusz Stachura (3):
      i40e: Store the requested FEC information
      i40e/i40evf: support for VF VLAN tag stripping control
      i40e: 25G FEC status improvements

Martin Habets (1):
      sfc: Add ethtool -m support for QSFP modules

Martin KaFai Lau (6):
      bpf: Fix map-in-map checking in the verifier
      bpf: Allow selecting numa node during map creation
      bpf: Allow numa selection in INNER_LRU_HASH_PREALLOC test of map_perf_test
      bpf: Add lru_hash_lookup performance test
      bpf: Inline LRU map lookup
      bpf: Only set node->ref = 1 if it has not been set

Matan Barak (5):
      net/mlx5: Convert linear search for free index to ida
      net/mlx5: Don't store reserved part in FTEs and FGs
      net/mlx5: Add hash table to search FTEs in a flow-group
      net/mlx5: Add hash table for flow groups in flow table
      net/mlx5: Add tracepoints

Matt Chen (1):
      iwlwifi: mvm: don't send CTDP commands via debugfs if not supported

Matthias Frei (1):
      ath10k: set a-mpdu receiver reference number

Matvejchikov Ilya (1):
      tcp: remove redundant argument from tcp_rcv_established()

Maxim Uvarov (2):
      drivers: net: davinci_mdio: remove busy loop on wait user access
      drivers: net: davinci_mdio: print bus frequency

Maya Erez (3):
      wil6210: check no_fw_recovery in resume failure recovery
      wil6210: add statistics for suspend time
      wil6210: notify wiphy on wowlan support

Michael Chan (11):
      bnxt_en: Update firmware interface spec to 1.8.0.
      bnxt_en: Retrieve the hardware bridge mode from the firmware.
      bnxt_en: Implement ndo_bridge_{get|set}link methods.
      bnxt_en: Add bnxt_get_num_stats() to centrally get the number of ethtool stats.
      bnxt_en: Allow the user to set ethtool stats-block-usecs to 0.
      bnxt_en: Report firmware DCBX agent.
      bnxt_en: Set ETS min_bw parameter for older firmware.
      bnxt_en: Update firmware interface spec. to 1.8.1.4.
      bnxt_en: Improve tx ring reservation logic.
      bnxt_en: Improve -ENOMEM logic in NAPI poll loop.
      bnxt_en: Reduce default rings on multi-port cards.

Michael Skeffington (1):
      rt2x00: Fix MMIC Countermeasures

Michal Simek (1):
      net: phy: Use tab for indentation in Kconfig

Mickaël Salaün (2):
      bpf: Move check_uarg_tail_zero() upward
      bpf: Extend check_uarg_tail_zero() checks

Mike Maloney (2):
      tcp: Extend SOF_TIMESTAMPING_RX_SOFTWARE to TCP recvmsg
      selftests/net: Add a test to validate behavior of rx timestamps

Mitch Williams (1):
      i40e/i40evf: adjust packet size to account for double VLANs

Mohammed Gamal (1):
      netvsc: Remove redundant use of ipv6_hdr()

Mordechai Goodstein (1):
      iwlwifi: implement fseq version mismatch warning

Moshe Shemesh (1):
      net/mlx4: Add user mac FW update support

Nathan Fontenot (3):
      ibmvnic: Clean up resources on probe failure
      ibmvnic: Add netdev_dbg output for debugging
      ibmvnic: Correct 'unused variable' warning in build.

Neal Cardwell (1):
      tcp: remove extra POLL_OUT added for finished active connect()

Nick Desaulniers (1):
      netfilter: nf_nat_h323: fix logical-not-parentheses warning

Niklas Söderlund (2):
      ravb: add wake-on-lan support via magic packet
      ravb: add workaround for clock when resuming with WoL enabled

Ohad Oz (2):
      Allow Mellanox switch devices to be configured if only I2C bus is set
      Change Kconfig description

Ondrej Zary (3):
      Bluetooth: bluecard: Always enable LEDs (fix for Anycom CF-300)
      Bluetooth: bluecard: fix LED behavior
      Bluetooth: bluecard: blink LED during continuous activity

Or Gerlitz (11):
      mlxsw: acl: Add ip ttl acl element
      mlxsw: spectrum: Add ttl to the ipv4 acl block
      mlxsw: spectrum_flower: Add support for ip ttl
      mlxsw: acl: Add ip tos acl element
      mlxsw: spectrum: Add tos to the ipv4 acl block
      mlxsw: spectrum_flower: Add support for ip tos
      net/mlx5: Avoid blank lines after/before open/close brace
      net/mlx5: Add a blank line after declarations
      net/mlx5e: Properly indent within conditional statements
      net/mlx5e: Avoid using multiple blank lines
      net/mlx5e: Place constants on the right side of comparisons

Pablo Cascón (1):
      nfp: add basic SR-IOV ndo functions

Pablo M. Bermudo Garay (5):
      netfilter: nf_tables: fib: use skb_header_pointer
      netfilter: nf_tables: add fib expression to the netdev family
      netfilter: nf_tables: add select_ops for stateful objects
      netfilter: nft_limit: replace pkt_bytes with bytes
      netfilter: nft_limit: add stateful object type

Pablo Neira Ayuso (6):
      netfilter: nf_tables: keep chain counters away from hot path
      netfilter: nf_tables: add nf_tables_updchain()
      netfilter: nf_tables: add nf_tables_addchain()
      netlink: add NLM_F_NONREC flag for deletion requests
      netfilter: nf_tables: use NLM_F_NONREC for deletion requests
      netfilter: nf_tables: support for recursive chain deletion

Paolo Abeni (5):
      IP: do not modify ingress packet IP option in ip_options_echo()
      ip/options: explicitly provide net ns to __ip_options_echo()
      Revert "ipv4: keep skb->dst around in presence of IP options"
      udp: no need to preserve skb->dst
      net/sock: allow the user to set negative peek offset

Paul Gortmaker (1):
      liquidio: fix implicit irq include causing build failures

Paul M Stillwell Jr (1):
      i40e: Handle admin Q timeout when releasing NVM

Pavani Muthyala (6):
      rsi: management frame descriptor preparation cleanup
      rsi: data packet descriptor code cleanup
      rsi: data packet descriptor enhancements
      rsi: separate function for data packet descriptor
      rsi: add support for rf-kill functionality
      rsi: update set_antenna command frame

Pavel Belous (1):
      aquantia: Switch to use napi_gro_receive

Pavel Machek (1):
      Bluetooth: document config options

Petr Machata (29):
      mlxsw: spectrum_acl: Fix a typo
      mlxsw: reg.h: Fix a typo
      mlxsw: spectrum_router: Fix a typo
      mlxsw: Update specification of reg_ritr_type
      mlxsw: reg.h: Namespace IP2ME registers
      mlxsw: spectrum_router: Simplify a piece of code
      mlxsw: spectrum_router: Clarify a piece of code
      mlxsw: spectrum_router: Simplify a piece of code
      mlxsw: reg: Update RITR to support loopback device
      mlxsw: reg: Update RATR to support IP-in-IP tunnels
      mlxsw: reg: Move enum mlxsw_reg_ratr_trap_id
      mlxsw: reg: Add mlxsw_reg_ralue_act_ip2me_tun_pack()
      mlxsw: reg: Add Routing Tunnel Decap Properties Register
      mlxsw: reg: Extract mlxsw_reg_ritr_mac_pack()
      mlxsw: reg: Give mlxsw_reg_ratr_pack a type parameter
      mlxsw: spectrum_router: Publish mlxsw_sp_l3proto
      mlxsw: spectrum_router: Add mlxsw_sp_ipip_ops
      mlxsw: spectrum_router: Support FID-less RIFs
      mlxsw: spectrum_router: Introduce loopback RIFs
      mlxsw: spectrum_router: Extract mlxsw_sp_fi_is_gateway()
      mlxsw: spectrum_router: Extract mlxsw_sp_rt6_is_gateway()
      mlxsw: spectrum_router: Make nexthops typed
      mlxsw: spectrum_router: Support IPv4 overlay encap
      mlxsw: spectrum_router: Support IPv6 overlay encap
      mlxsw: spectrum_router: Support IPv4 underlay decap
      mlxsw: spectrum_router: Use existing decap route
      mlxsw: spectrum: Register for IPIP_DECAP_ERROR trap
      mlxsw: spectrum_router: Add loopback accessors
      mlxsw: spectrum_router: Support GRE tunnels

Phil Sutter (7):
      netfilter: nf_tables: Attach process info to NFT_MSG_NEWGEN notifications
      netfilter: nf_tables: No need to check chain existence when tracing
      netlink: Introduce nla_strdup()
      netfilter: nf_tables: Allow table names of up to 255 chars
      netfilter: nf_tables: Allow chain name of up to 255 chars
      netfilter: nf_tables: Allow set names of up to 255 chars
      netfilter: nf_tables: Allow object names of up to 255 chars

Philipp Zabel (1):
      ath10k: explicitly request exclusive reset control

Ping-Ke Shih (8):
      rtlwifi: Fill in_4way field by driver
      rtlwifi: Add BT_MP_INFO to c2h handler.
      rtlwifi: Add board type for 8723be and 8192ee
      rtlwifi: add amplifier type for 8812ae
      rtlwifi: Update 8723be new phy parameters and its parser.
      rtlwifi: Rename rtl_desc92_rate to rtl_desc_rate
      rtlwifi: Uses addr1 instead DA to determine broadcast and multicast addr.
      rtlwifi: move IS_HARDWARE_TYPE_xxx checker to wifi.h

Prameela Rani Garnepudi (31):
      rsi: changes in eeprom read frame
      rsi: separate function for management packet descriptor
      rsi: add common structures needed for command packets
      rsi: immediate wakeup bit and priority for TX command packets
      rsi: Update in tx command frame radio capabilities
      rsi: remove unnecessary check for 802.11 management packet
      rsi: Update peer notify command frame
      rsi: Update aggregation parameters command frame
      rsi: Update baseband RF programming frame
      rsi: update set_channel command frame
      rsi: update vap capabilities command frame
      rsi: update set_key command frame
      rsi: set_key enhancements
      rsi: update autorate request command frame
      rsi: block/unblock data queues as per connection status
      rsi: update tx command frame block/unblock data
      rsi: Remove internal header from Tx status skb
      rsi: Send rx filter frame to device when interface is down
      rsi: regulatory enhancements
      rsi: fix uninitialized descriptor pointer issue
      rsi: advertise ap mode support
      rsi: add interface changes for ap mode
      rsi: remove interface changes for AP mode
      rsi: add beacon changes for AP mode
      rsi: handle station connection in AP mode
      rsi: handle station disconnection in AP mode
      rsi: data and managemet path changes for AP mode
      rsi: use common descriptor for auto rate frame
      rsi: update tx auto rate command frame for AP mode
      rsi: aggregation parameters frame for AP mode
      rsi: security enhancements for AP mode

Quan Nguyen (1):
      drivers: net: xgene: Configure tx/rx delay for ACPI

Rabie Loulou (2):
      net/mlx5: Fix counter list hardware structure
      net/mlx5: Increase the maximum flow counters supported

Rahul Verma (3):
      qed: Add support for vf coalesce configuration.
      qed: Read per queue coalesce from hardware
      qed: enhanced per queue max coalesce value.

Rakesh Pillai (1):
      ath10k: fix memory leak in rx ring buffer allocation

Rami Rosen (1):
      net: fix two typos in net_device_ops documentation.

Ray Jui (1):
      bnxt: Add PCIe device IDs for bcm58802/bcm58808

Reizer, Eyal (1):
      wlcore: add missing nvs file name info for wilink8

Rick Farrington (12):
      liquidio: support new firmware statistic fw_err_pki
      liquidio: lowmem: init allocated memory to 0
      liquidio: lowmem: do not dereference null ptr
      liquidio: lowmem: init allocated memory to 0
      liquidio: standardization: use min_t instead of custom macro
      liquidio: cleanup: removed cryptic and misleading macro
      liquidio: update debug console logging mechanism
      liquidio: with embedded f/w, don't reload f/w, issue pf flr at exit
      liquidio: with embedded f/w, issue droq credits before enablement
      liquidio: remove support for deprecated f/w cmd OCTNET_CMD_RESET_PF
      liquidio: fix use of pf in pass-through mode in a virtual machine
      liquidio: fix crash in presence of zeroed-out base address regs

Rob Clark (1):
      wcn36xx: check dma_mapping_error()

Rob Herring (1):
      net: Convert to using %pOF instead of full_name

Robin Murphy (1):
      qtnfmac: Tidy up DMA mask setting

Romain Perier (3):
      net: arc_emac: Add support for ndo_do_ioctl net_device_ops operation
      wireless: ipw2200: Replace PCI pool old API
      net: stmmac: Delete dead code for MDIO registration

Roopa Prabhu (3):
      lwtunnel: replace EXPORT_SYMBOL with EXPORT_SYMBOL_GPL
      bridge: fdb add and delete tracepoints
      bridge: add tracepoint in br_fdb_update

Rosen Penev (1):
      ath9k: Add Dell Wireless 1802 with wowlan capability

Rosen, Rami (1):
      net/packet: remove unused PGV_FROM_VMALLOC definition.

Russell King (13):
      net: phy: allow settings table to support more than 32 link modes
      net: phy: split out PHY speed and duplex string generation
      net: phy: move phy_lookup_setting() and guts of phy_supported_speeds() to phy-core
      net: phy: add 1000Base-X to phy settings table
      net: phy: provide a hook for link up/link down events
      net: phy: export phy_start_machine() for phylink
      net: phy: add I2C mdio bus
      phylink: add phylink infrastructure
      sfp: add sfp-bus to bridge between network devices and sfp cages
      phylink: add module EEPROM support
      phylink: add support for MII ioctl access to Clause 45 PHYs
      phylink: add in-band autonegotiation support for 10GBase-KR mode.
      sfp: add SFP module support

Ryan Hsu (3):
      ath10k: fix napi_poll budget overflow
      ath10k: add the PCI PM core suspend/resume ops
      ath10k: configure and enable the wakeup capability

SZ Lin (6):
      net: moxa: Remove braces from single-line body
      net: moxa: Prefer 'unsigned int' to bare use of 'unsigned'
      net: moxa: Fix comparison to NULL could be written with !
      net: moxa: Remove extra space after a cast
      net: moxa: Fix for typo in comment to function moxart_mac_setup_desc_ring()
      net: moxa: Add spaces preferred around that '{+,-}'

Sabrina Dubroca (6):
      net: add new netdevice feature for offload of RX port for UDP tunnels
      net: check UDP tunnel RX port offload feature before calling tunnel ndo ndo
      net: add infrastructure to un-offload UDP tunnel port
      net: call udp_tunnel_get_rx_info when NETIF_F_RX_UDP_TUNNEL_PORT is toggled
      geneve/vxlan: add support for NETDEV_UDP_TUNNEL_DROP_INFO
      geneve/vxlan: offload ports on register/unregister events

Saeed Mahameed (6):
      net/mlx5e: Rearrange netdevice ops structures
      net/mlx5e: NIC netdev init flow cleanup
      net/mlx5: Unify vport manager capability check
      net/mlx5: Separate between E-Switch and MPFS
      net/mlx5: Add CONFIG_MLX5_ESWITCH Kconfig
      net/mlx5: Add a blank line after declarations V2

Salil (12):
      net: hns3: Add support of HNS3 Ethernet Driver for hip08 SoC
      net: hns3: Add support of the HNAE3 framework
      net: hns3: Add HNS3 IMP(Integrated Mgmt Proc) Cmd Interface Support
      net: hns3: Add HNS3 Acceleration Engine & Compatibility Layer Support
      net: hns3: Add support of TX Scheduler & Shaper to HNS3 driver
      net: hns3: Add MDIO support to HNS3 Ethernet driver for hip08 SoC
      net: hns3: Add Ethtool support to HNS3 driver
      net: hns3: Add HNS3 driver to kernel build framework & MAINTAINERS
      net: hns3: Fixes the missing u64_stats_fetch_begin_irq in 64-bit stats fetch
      net: hns3: Fixes the static checker error warning in hns3_get_link_ksettings()
      net: hns3: Fixes the static check warning due to missing unsupp L3 proto check
      net: hns3: Add support to change MTU in HNS3 hardware

Salil Mehta (1):
      net: hns3: Fixes the wrong IS_ERR check on the returned phydev value

Samuel Mendoza-Jonas (3):
      net/ncsi: Fix several packet definitions
      net/ncsi: Configure VLAN tag filter
      ftgmac100: Support NCSI VLAN filtering when available

Sasha Neftin (1):
      e1000e: Initial Support for IceLake

Sathya Perla (12):
      bnxt_en: add support to enable VF-representors
      bnxt_en: add vf-rep RX/TX and netdev implementation
      bnxt_en: add support for port_attr_get and and get_phys_port_name
      bnxt_en: include bnxt_vfr.c code under CONFIG_BNXT_SRIOV switch
      bnxt_en: use SWITCHDEV_SET_OPS() for setting vf_rep_switchdev_ops
      bnxt_en: fix switchdev port naming for external-port-rep and vf-reps
      bnxt_re: add MAY_USE_DEVLINK dependency
      bnxt_en: fix clearing devlink ptr from bnxt struct
      bnxt_en: bnxt: add TC flower filter offload support
      bnxt_en: add TC flower offload flow_alloc/free FW cmds
      bnxt_en: add code to query TC flower offload stats
      bnxt_en: add a dummy definition for bnxt_vf_rep_get_fid()

Scott Branden (1):
      bnxt: initialize board_info values with proper enums

Sean Wang (4):
      dt-bindings: net: mediatek: add support for MediaTek MT7623 and MT7622 SoC
      net-next: mediatek: add platform data to adapt into various hardware
      net-next: mediatek: add support for MediaTek MT7622 SoC
      MAINTAINERS: add Sean/Nelson as MediaTek ethernet maintainers

Seraphime Kirkovski (1):
      iwlwifi: dvm: remove unused defines

Sergei Shtylyov (3):
      of_mdio: kill useless variable in of_phy_register_fixed_link()
      of_mdio: use of_property_read_u32_array()
      of_mdio: merge branch tails in of_phy_register_fixed_link()

Sergey Matyukevich (25):
      qtnfmac: updates for regulatory support
      qtnfmac: regulatory configuration for self-managed setup
      qtnfmac: add missing bus lock
      qtnfmac: implement cfg80211 dump_survey handler
      qtnfmac: implement reporting current channel
      qtnfmac: fix station leave reason endianness
      qtnfmac: move current channel info from vif to mac
      qtnfmac: implement cfg80211 channel_switch handler
      qtnfmac: implement scan timeout
      qtnfmac: fix handling of iftype mask reported by firmware
      qtnfmac: remove function qtnf_cmd_skb_put_action
      qtnfmac: prepare for AP_VLAN interface type support
      qtnfmac: remove unused qtnf_rx_frame declaration
      qtnfmac: switch to napi_gro_receive
      qtnfmac: use __netdev_alloc_skb_ip_align
      qtnfmac: skb2rbd_attach cleanup
      qtnfmac: decrease default Tx queue size
      qtnfmac: switch to kernel circ_buf implementation
      qtnfmac: introduce counter for Rx underflow events
      qtnfmac: modify tx reclaim locking
      qtnfmac: drop -D__CHECK_ENDIAN from cflags
      qtnfmac: module param sanity check
      qtnfmac: modify qtnf_map_bar not to return NULL
      qtnfmac: fix free_xfer_buffer cleanup
      qtnfmac: implement 64-bit dma support

Shalom Lagziel (1):
      net/mlx5e: IPoIB, Add support for get_link_ksettings in ethtool

Shannon Nelson (1):
      sunvnet: add support for IPv6 checksum offloads

Sharon Dvir (2):
      iwlwifi: mvm: fix uninitialized var while waiting for queues to empty
      iwlwifi: change functions that can only return 0 to void

Shaul Triebitz (2):
      iwlwifi: mvm: move a000 device NVM retrieval to a common place
      iwlwifi: mvm: add station before allocating a queue

Shawn Lin (1):
      mwifiex: fix compile warning of unused variable

Shubham Bansal (2):
      arm: eBPF JIT compiler
      bpf, doc: Add arm32 as arch supporting eBPF JIT

Simon Horman (4):
      nfp: send control message when MAC representors are created
      nfp: process control messages in workqueue in flower app
      nfp: process MTU updates from firmware flower app
      nfp: add basic SR-IOV ndo functions to representors

Simon Wunderlich (1):
      batman-adv: Start new development cycle

Souptick Joarder (4):
      rtlwifi: remove dummy function call
      rtlwifi: Remove unused dummy function
      rtlwifi: Fix memory leak when firmware request fails
      rtlwifi: Replace hardcode value with macro

Sowmini Varadhan (2):
      rds: cancel send/recv work before queuing connection shutdown
      rds: reduce memory footprint for RDS when transport is RDMA

Stanislaw Gruszka (1):
      rt2800: fix TX_PIN_CFG setting for non MT7620 chips

Stefan Assmann (2):
      i40e: handle setting administratively set MAC address back to zero
      i40e/i40evf: rename vf_offload_flags to vf_cap_flags in struct virtchnl_vf_resource

Stefan Chulski (1):
      net: mvpp2: set maximum packet size for 10G ports

Stefan Sørensen (1):
      dp83640: don't hold spinlock while calling netif_rx_ni

Stefano Brivio (2):
      hostap: Fix outdated comment about dev->destructor
      ipv4: Don't override return code from ip_route_input_noref()

Steffen Klassert (2):
      net: Allow IPsec GSO for local sockets
      xfrm: Fix return value check of copy_sec_ctx.

Stephen Hemminger (2):
      netvsc: cleanup datapath switch
      netvsc: allow driver to be removed even if VF is present

Subash Abhinov Kasiviswanathan (10):
      netfilter: conntrack: Change to deferable work queue
      net: ether: Add support for multiplexing and aggregation type
      net: arp: Add support for raw IP device
      drivers: net: ethernet: qualcomm: rmnet: Initial implementation
      net: qualcomm: rmnet: Fix memory corruption if mux_id is greater than 32
      net: qualcomm: rmnet: Remove the unused endpoint -1
      net: qualcomm: rmnet: Move the device creation log
      net: qualcomm: rmnet: Refactor the new rmnet dev creation
      net: qualcomm: rmnet: Implement ndo_get_iflink
      net: qualcomm: rmnet: Rename real_dev_info to port

Sudarsana Reddy Kalluru (2):
      qed: Add support for Energy efficient ethernet.
      qede: Add ethtool support for Energy efficient ethernet.

Sudheer Mogilappagari (3):
      i40evf: prevent VF close returning before state transitions to DOWN
      i40e: synchronize nvmupdate command and adminq subtask
      i40e: Update state variable for adminq subtask

Sukumar Ghorai (1):
      Bluetooth: btusb: driver to enable the usb-wakeup feature

Sven Eckelmann (3):
      batman-adv: Remove too short %pM printk field width
      batman-adv: Remove variable deprecated by skb_put_data
      batman-adv: Convert batman-adv.txt to reStructuredText

Sven Joachim (1):
      rtlwifi: Fix fallback firmware loading

Taehee Yoo (4):
      netfilter: Remove duplicated rcu_read_lock.
      netfilter: xtables: Remove unused variable in compat_copy_entry_from_user()
      netfilter: connlimit: merge root4 and root6.
      netfilter: remove prototype of netfilter_queue_init

Tamizh chelvam (1):
      ath10k: increase buffer len to print all wmi services

Tariq Toukan (19):
      net/mlx4_core: Fix misplaced brackets of sizeof
      samples/bpf: Fix compilation issue in redirect dummy program
      net/mlx5e: Reorganize struct mlx5e_rq
      net/mlx5e: Replace multiplication by stride size with a shift
      net/mlx5e: Remove unnecessary wqe_sz field from RQ buffer
      net/mlx5e: Use memset to init skbs_frags array to zeros
      net/mlx5e: Small enhancements for RX MPWQE allocation and free
      net/mlx5e: NAPI busy-poll when UMR post is in progress
      net/mlx5e: Early-return on empty completion queues
      net/mlx5e: Refactor data-path lro header function
      net/mlx5e: Non-atomic indicator for ring enabled state
      net/mlx5e: Non-atomic RQ state indicator for UMR WQE in progress
      net/mlx5e: Type-specific optimizations for RX post WQEs function
      net/mlx5e: Remove unnecessary fields in ICO SQ
      net/mlx5e: Don't recycle page if moved to far NUMA
      net/mlx5e: Slightly increase RX page-cache size
      net/mlx5e: Use kernel's mechanism to avoid missing NAPIs
      net/mlx5e: Stop NAPI when irq balancer changes affinity
      net/mlx5e: Distribute RSS table among all RX rings

Thomas Meyer (2):
      ipv6: sr: Use ARRAY_SIZE macro
      net/mlx4_core: Use ARRAY_SIZE macro

Thomas Petazzoni (7):
      net: mvpp2: fix MVPP21_ISR_RXQ_GROUP_REG definition
      net: mvpp2: remove RX queue group reset code
      net: mvpp2: introduce per-port nrxqs/ntxqs variables
      net: mvpp2: move from cpu-centric naming to "software thread" naming
      net: mvpp2: introduce queue_vector concept
      net: mvpp2: add support for TX interrupts and RX queue distribution modes
      dt-bindings: net: marvell-pp2: update interrupt-names with TX interrupts

Tom Herbert (5):
      proto_ops: Add locked held versions of sendmsg and sendpage
      skbuff: Function to send an skbuf on a socket
      strparser: Generalize strparser
      flow_dissector: Cleanup control flow
      flow_dissector: Add limit for number of headers to dissect

Tom Lendacky (1):
      amd-xgbe: Interrupt summary bits are h/w version dependent

Tonghao Zhang (7):
      openvswitch: Optimize updating for OvS flow_stats.
      openvswitch: Optimize operations for OvS flow_stats.
      drivers/net: Fix ptr_ret.cocci warnings.
      ipv4: Introduce ipip_offload_init helper function.
      net: skb_needs_check() removes CHECKSUM_UNNECESSARY check for tx.
      tcp: Get a proper dst before checking it.
      tcp: Remove the unused parameter for tcp_try_fastopen.

Tony Nguyen (5):
      ixgbe: Ensure MAC filter was added before setting MACVLAN
      ixgbe: Enable LASI interrupts for X552 devices
      ixgbe: Update NW_MNG_IF_SEL support for X553
      ixgbe: Do not support flow control autonegotiation for X553
      ixgbe: Disable flow control for XFI

Tushar Dave (2):
      i40evf: Use le32_to_cpu before evaluating HW desc fields
      i40evf: remove unnecessary __packed

Tzipi Peres (2):
      iwlwifi: add support of FPGA fw
      iwlwifi: distinguish different RF modules in A000 devices

Ursula Braun (10):
      net/smc: serialize connection creation in all cases
      net/smc: shorten local bufsize variables
      net/smc: introduce sg-logic for RMBs
      net/smc: use separate memory regions for RMBs
      net/smc: register RMB-related memory region
      net/smc: remove Kconfig warning
      net/smc: introduce sg-logic for send buffers
      net/smc: common functions for RMBs and send buffers
      net/smc: cleanup function __smc_buf_create()
      net/smc: synchronize buffer usage with device

Varsha Rao (3):
      netfilter: Remove NFDEBUG()
      net: Replace NF_CT_ASSERT() with WARN_ON().
      net: Remove CONFIG_NETFILTER_DEBUG and _ASSERT() macros.

Vasundhara Volam (1):
      bnxt_en: assign CPU affinity hints to bnxt_en IRQs

Veerasenareddy Burru (3):
      liquidio: update VF's netdev->max_mtu if there's a change in PF's MTU
      liquidio: move macro definition to a proper place
      liquidio: make VF driver notify NIC firmware of MTU change

Vidya Sagar Ravipati (1):
      net: ethtool: add support for forward error correction modes

Vincent Bernat (2):
      ip6: fix PMTU discovery when using /127 subnets
      net: ipv6: avoid overhead when no custom FIB rules are installed

Vincent Legoll (1):
      bcma: make BCMA a menuconfig to ease disabling it all

Vishwanath Pai (1):
      netfilter: xt_hashlimit: add rate match mode

Vitaly Kuznetsov (1):
      hinic: don't build the module by default

Vivien Didelot (28):
      net: dsa: mv88e6xxx: remove unneeded dsa header
      net: dsa: mv88e6xxx: remove LED control register
      net: dsa: mv88e6xxx: fix 88E6321 family comment
      net: dsa: mv88e6xxx: remove unused capabilities
      net: dsa: mv88e6xxx: remove 88E6185 G2 interrupt
      net: dsa: mv88e6xxx: add number of Global 2 IRQs
      net: dsa: mv88e6xxx: distinguish Global 2 Rsvd2CPU
      net: dsa: mv88e6xxx: add POT flag to 88E6390
      net: dsa: mv88e6xxx: add POT operation
      net: dsa: mv88e6xxx: add a global2_addr info flag
      net: dsa: mv88e6xxx: add Energy Detect ops
      net: dsa: mv88e6xxx: add a multi_chip info flag
      net: dsa: unexport dsa_is_port_initialized
      net: dsa: PHY device is mandatory for EEE
      net: dsa: qca8k: fix EEE init
      net: dsa: qca8k: enable EEE once
      net: dsa: qca8k: do not cache unneeded EEE fields
      net: dsa: qca8k: empty qca8k_get_eee
      net: dsa: bcm_sf2: remove unneeded supported flags
      net: dsa: mv88e6xxx: call phy_init_eee
      net: dsa: call phy_init_eee in DSA layer
      net: dsa: remove PHY device argument from .set_eee
      net: dsa: mv88e6xxx: remove EEE support
      net: dsa: rename switch EEE ops
      net: dsa: bcm_sf2: dst in not an array
      net: dsa: remove useless argument in legacy setup
      net: dsa: remove useless args of dsa_cpu_dsa_setup
      net: dsa: remove useless args of dsa_slave_create

WANG Cong (8):
      flow_dissector: remove unused functions
      net_sched: refactor notification code for RTM_DELTFILTER
      net_sched: use void pointer for filter handle
      net_sched: get rid of some forward declarations
      net_sched: get rid of more forward declarations
      net_sched: introduce tclass_del_notify()
      net_sched: remove tc class reference counting
      net_sched: kill u32_node pointer in Qdisc

Wei Wang (2):
      tcp: extract the function to compute delivery rate
      tcp: add related fields into SCM_TIMESTAMPING_OPT_STATS

Weilin Chang (1):
      liquidio: show NIC's U-Boot version in a dev_info() message

Willem de Bruijn (16):
      net: add skb_frag_foreach_page and use with kmap_atomic
      sock: allocate skbs from optmem
      sock: skb_copy_ubufs support for compound pages
      sock: add MSG_ZEROCOPY
      sock: add SOCK_ZEROCOPY sockopt
      sock: enable MSG_ZEROCOPY
      sock: MSG_ZEROCOPY notification coalescing
      sock: ulimit on MSG_ZEROCOPY pages
      tcp: enable MSG_ZEROCOPY
      test: add msg_zerocopy test
      sock: fix zerocopy panic in mem accounting
      sock: fix zerocopy_success regression with msg_zerocopy
      udp: remove unreachable ufo branches
      xen-netback: update ubuf_info initialization to anonymous union
      doc: document MSG_ZEROCOPY
      selftests: correct define in msg_zerocopy.c

William Tu (8):
      bpf: fix the printing of ifindex
      selftests: bpf: add a test for XDP redirect
      selftests: bpf: add check for ip XDP redirect
      gre: introduce native tunnel support for ERSPAN
      gre: fix goto statement typo
      gre: refactor the gre_fb_xmit
      gre: add collect_md mode to ERSPAN tunnel
      samples/bpf: extend test_tunnel_bpf.sh with ERSPAN

Wright Feng (2):
      brcmfmac: set wpa_auth to WPA_AUTH_DISABLED in AP/OPEN security mode
      brcmfmac: fix wrong num_different_channels when mchan feature enabled

Wu Fengguang (1):
      netvsc: fix ptr_ret.cocci warnings

Xin Long (65):
      sctp: remove the typedef sctp_ipv4addr_param_t
      sctp: remove the typedef sctp_ipv6addr_param_t
      sctp: remove the typedef sctp_cookie_preserve_param_t
      sctp: remove the typedef sctp_hostname_param_t
      sctp: remove the typedef sctp_supported_addrs_param_t
      sctp: remove struct sctp_ecn_capable_param
      sctp: remove the typedef sctp_adaptation_ind_param_t
      sctp: remove the typedef sctp_supported_ext_param_t
      sctp: remove the typedef sctp_random_param_t
      sctp: remove the typedef sctp_chunks_param_t
      sctp: remove the typedef sctp_hmac_algo_param_t
      sctp: remove the typedef sctp_initack_chunk_t
      sctp: remove the typedef sctp_cookie_param_t
      sctp: remove the typedef sctp_unrecognized_param_t
      sctp: remove the typedef sctp_gap_ack_block_t
      sctp: remove the typedef sctp_dup_tsn_t
      sctp: remove the typedef sctp_sack_variable_t
      sctp: remove the typedef sctp_sackhdr_t
      sctp: remove the typedef sctp_sack_chunk_t
      sctp: remove the typedef sctp_heartbeathdr_t
      sctp: remove the typedef sctp_heartbeat_chunk_t
      sctp: remove the typedef sctp_abort_chunk_t
      sctp: remove the typedef sctp_shutdownhdr_t
      sctp: fix the name of struct sctp_shutdown_chunk_t
      sctp: remove the typedef sctp_errhdr_t
      sctp: remove the typedef sctp_operr_chunk_t
      sctp: remove the typedef sctp_error_t
      sctp: remove the typedef sctp_ecnehdr_t
      sctp: remove the typedef sctp_ecne_chunk_t
      sctp: remove the typedef sctp_cwrhdr_t
      sctp: remove the typedef sctp_cwr_chunk_t
      sctp: remove the typedef sctp_addip_param_t
      sctp: remove the typedef sctp_addiphdr_t
      sctp: remove the typedef sctp_addip_chunk_t
      sctp: remove the typedef sctp_authhdr_t
      sctp: remove the typedef sctp_auth_chunk_t
      sctp: remove the typedef sctp_lower_cwnd_t
      sctp: remove the typedef sctp_retransmit_reason_t
      sctp: remove the typedef sctp_scope_policy_t
      sctp: remove the typedef sctp_scope_t
      sctp: remove the typedef sctp_transport_cmd_t
      sctp: remove the typedef sctp_sock_state_t
      sctp: remove the typedef sctp_xmit_t
      sctp: remove the typedef sctp_ierror_t
      sctp: remove the typedef sctp_state_t
      sctp: remove the typedef sctp_event_primitive_t
      sctp: remove the typedef sctp_event_other_t
      sctp: remove the typedef sctp_event_timeout_t
      sctp: remove the typedef sctp_event_t
      sctp: remove the typedef sctp_subtype_t
      sctp: remove the unused typedef sctp_packet_phandler_t
      sctp: remove the typedef sctp_sender_hb_info_t
      sctp: remove the typedef sctp_endpoint_type_t
      sctp: remove the typedef sctp_cmsgs_t
      sctp: remove the typedef sctp_dbg_objcnt_entry_t
      sctp: remove the typedef sctp_socket_type_t
      sctp: remove the typedef sctp_cmd_t
      sctp: remove the typedef sctp_cmd_seq_t
      sctp: remove the typedef sctp_arg_t
      sctp: remove the typedef sctp_verb_t
      sctp: remove the unused typedef sctp_sm_command_t
      sctp: remove the typedef sctp_sm_table_entry_t
      sctp: remove the typedef sctp_disposition_t
      sctp: fix some indents in sm_make_chunk.c
      ipv4: do metrics match when looking up and deleting a route

Xinming Hu (8):
      mwifiex: disable uapsd in tdls config
      mwifiex: correct IE parse during association
      mwifiex: make addba request command clean
      mwifiex: pcie: compatible with wifi-only image while extract wifi-part fw
      mwifiex: Do not change bss_num in change_virtual_intf
      mwifiex: wrapper wps ie in pass through tlv
      mwifiex: p2p: use separate device address
      mwifiex: uap: enable 11d based on userspace configruation

Yi Yang (1):
      net: add NSH header structures and helpers

Yonghong Song (2):
      bpf: add support for sys_enter_* and sys_exit_* tracepoints
      bpf: add a test case for syscalls/sys_{enter|exit}_* tracepoints

Yossi Kuperman (3):
      xfrm6: Fix CHECKSUM_COMPLETE after IPv6 header push
      esp6: Fix RX checksum after header pull
      xfrm: Add support for network devices capable of removing the ESP trailer

Yuchung Cheng (3):
      tcp: adjust tail loss probe timeout
      tcp: fix cwnd undo in Reno and HTCP congestion controls
      tcp: consolidate congestion control undo functions

Zahari Doychev (1):
      rocker: fix kcalloc parameter order

Zamir, Roee (1):
      iwlwifi: mvm: add compile-time option to disable EBS

Zhu Yanjun (5):
      mlx4_en: remove unnecessary returned value
      mlx4_en: remove unnecessary error check
      forcedeth: replace init_timer_deferrable with setup_deferrable_timer
      mlx4: remove unnecessary pci_set_drvdata()
      mlx5: remove unnecessary pci_set_drvdata()

kiki good (1):
      net: systemport: Support 64bit statistics

linzhang (1):
      skbuff: optimize the pull_pages code in __pskb_pull_tail()

sixiao@microsoft.com (1):
      tools: hv: ignore a NIC if it has been configured

stephen hemminger (61):
      bluetooth: 6lowpan dev_close never returns error
      hns: remove useless void cast
      net: make dev_close and related functions void
      netvsc: force link update after MTU change
      netvsc: add some rtnl_dereference annotations
      netvsc: change order of steps in setting queues
      netvsc: change logic for change mtu and set_queues
      netvsc: use ERR_PTR to avoid dereference issues
      netvsc: need rcu_derefence when accessing internal device info
      netvsc: save pointer to parent netvsc_device in channel table
      netvsc: add rtnl annotations in rndis
      netvsc: remove bogus rtnl_unlock
      netvsc: prefetch the first incoming ring element
      netvsc: fix netvsc_set_channels
      netvsc: include rtnetlink.h
      netvsc: remove no longer used max_num_rss queues
      bnxt: fix unsigned comparsion with 0
      bnxt: fix unused variable warnings
      benet: fix set but not used warning
      netfilter: remove unused variable
      socket: fix set not used warning
      6lowpan: fix set not used warning
      netvsc: fix return value for set_channels
      netvsc: fix warnings reported by lockdep
      netvsc: don't print pointer value in error message
      netvsc: remove unnecessary indirection of page_buffer
      netvsc: optimize receive completions
      netvsc: fix error unwind on device setup failure
      netvsc: signal host if receive ring is emptied
      netvsc: transparent VF management
      netvsc: add documentation
      netvsc: remove bonding setup script
      netvsc: fix rtnl deadlock on unregister of vf
      netvsc: make sure and unregister datapath
      netvsc: delay setup of VF device
      netvsc: don't signal host twice if empty
      netvsc: propagate MAC address change to VF slave
      netvsc: check error return when restoring channels and mtu
      netvsc: no need to allocate send/receive on numa node
      netvsc: whitespace cleanup
      netvsc: remove unnecessary cast of void pointer
      netvsc: remove unnecessary check for NULL hdr
      netvsc: allow controlling send/recv buffer size
      netvsc: keep track of some non-fatal overload conditions
      tun/tap: use paren's with sizeof
      virtio: put paren around sizeof
      skge: add paren around sizeof arg
      mlx4: sizeof style usage
      vmbus: remove unused vmbus_sendpacket_multipagebuffer
      vmbus: remove unused vmubs_sendpacket_pagebuffer_ctl
      vmbus: remove unused vmbus_sendpacket_ctl
      net: don't decrement kobj reference count on init failure
      net: constify netdev_class_file
      net: make net_class ro_after_init
      net: constify net_ns_type_operations
      net: make net sysfs attributes ro_after_init
      net: drop unused attribute argument from sysfs queue funcs
      net: make BQL sysfs attributes ro_after_init
      net: make queue attributes ro_after_init
      net: mark receive queue attributes ro_after_init
      net: style cleanups

 Documentation/devicetree/bindings/net/anarion-gmac.txt                    |   25 +
 Documentation/devicetree/bindings/net/broadcom-bluetooth.txt              |   35 +
 Documentation/devicetree/bindings/net/marvell-pp2.txt                     |   29 +-
 Documentation/devicetree/bindings/net/mediatek-net.txt                    |   12 +-
 Documentation/devicetree/bindings/net/phy.txt                             |    5 +
 Documentation/devicetree/bindings/net/renesas,ravb.txt                    |   30 +-
 Documentation/devicetree/bindings/net/rockchip-dwmac.txt                  |    1 +
 Documentation/devicetree/bindings/net/xilinx_axienet.txt                  |   55 +
 Documentation/devicetree/bindings/phy/phy-mvebu-comphy.txt                |   43 +
 Documentation/networking/00-INDEX                                         |    2 -
 Documentation/networking/batman-adv.rst                                   |  220 ++++
 Documentation/networking/batman-adv.txt                                   |  215 ----
 Documentation/networking/dpaa.txt                                         |   68 +-
 Documentation/networking/filter.txt                                       |  130 ++-
 Documentation/networking/hinic.txt                                        |  125 +++
 Documentation/networking/index.rst                                        |    1 +
 Documentation/networking/ip-sysctl.txt                                    |   29 +-
 Documentation/networking/msg_zerocopy.rst                                 |  257 +++++
 Documentation/networking/netdev-FAQ.txt                                   |    8 +
 Documentation/networking/netvsc.txt                                       |   75 ++
 Documentation/networking/nf_conntrack-sysctl.txt                          |   11 -
 Documentation/networking/rmnet.txt                                        |   82 ++
 Documentation/networking/rxrpc.txt                                        |   57 +-
 Documentation/networking/strparser.txt                                    |  209 ++--
 Documentation/sysctl/net.txt                                              |    2 +-
 MAINTAINERS                                                               |   28 +-
 arch/alpha/include/uapi/asm/socket.h                                      |    2 +
 arch/arm/Kconfig                                                          |    2 +-
 arch/arm/boot/dts/rk3228-evb.dts                                          |   34 +
 arch/arm/configs/multi_v7_defconfig                                       |    1 +
 arch/arm/net/bpf_jit_32.c                                                 | 2448 ++++++++++++++++++++++++++++--------------
 arch/arm/net/bpf_jit_32.h                                                 |  108 +-
 arch/arm64/boot/dts/rockchip/rk3328-evb.dts                               |   17 +
 arch/arm64/boot/dts/rockchip/rk3328.dtsi                                  |   39 +
 arch/arm64/configs/defconfig                                              |    1 +
 arch/arm64/net/bpf_jit.h                                                  |    4 +
 arch/arm64/net/bpf_jit_comp.c                                             |   20 +
 arch/frv/include/uapi/asm/socket.h                                        |    2 +
 arch/ia64/include/uapi/asm/socket.h                                       |    2 +
 arch/m32r/include/uapi/asm/socket.h                                       |    2 +
 arch/mips/include/uapi/asm/socket.h                                       |    2 +
 arch/mips/net/ebpf_jit.c                                                  |  163 +--
 arch/mn10300/include/uapi/asm/socket.h                                    |    2 +
 arch/parisc/configs/c3000_defconfig                                       |    1 -
 arch/parisc/include/uapi/asm/socket.h                                     |    2 +
 arch/powerpc/net/bpf_jit.h                                                |    1 +
 arch/powerpc/net/bpf_jit_comp64.c                                         |   20 +
 arch/s390/include/uapi/asm/socket.h                                       |    2 +
 arch/s390/net/bpf_jit_comp.c                                              |   24 +
 arch/sh/configs/se7751_defconfig                                          |    1 -
 arch/sparc/include/uapi/asm/socket.h                                      |    2 +
 arch/sparc/net/bpf_jit_comp_64.c                                          |   34 +
 arch/x86/net/bpf_jit_comp.c                                               |   35 +-
 arch/xtensa/include/uapi/asm/socket.h                                     |    2 +
 drivers/atm/adummy.c                                                      |    4 +-
 drivers/atm/ambassador.c                                                  |    2 +-
 drivers/atm/atmtcp.c                                                      |    2 +-
 drivers/atm/eni.c                                                         |    2 +-
 drivers/atm/firestream.c                                                  |    2 +-
 drivers/atm/fore200e.c                                                    |    2 +-
 drivers/atm/he.c                                                          |    4 +-
 drivers/atm/horizon.c                                                     |    2 +-
 drivers/atm/idt77252.c                                                    |    4 +-
 drivers/atm/iphase.c                                                      |    2 +-
 drivers/atm/lanai.c                                                       |    2 +-
 drivers/atm/nicstar.c                                                     |    4 +-
 drivers/atm/solos-pci.c                                                   |    8 +-
 drivers/atm/zatm.c                                                        |    2 +-
 drivers/bcma/Kconfig                                                      |    9 +-
 drivers/bcma/driver_gpio.c                                                |    1 +
 drivers/bluetooth/Kconfig                                                 |    2 +
 drivers/bluetooth/ath3k.c                                                 |    3 +-
 drivers/bluetooth/bluecard_cs.c                                           |   58 +-
 drivers/bluetooth/bt3c_cs.c                                               |    8 +-
 drivers/bluetooth/btbcm.c                                                 |   69 +-
 drivers/bluetooth/btmrvl_sdio.c                                           |    6 +-
 drivers/bluetooth/btqca.c                                                 |    2 +-
 drivers/bluetooth/btrtl.c                                                 |    2 +
 drivers/bluetooth/btsdio.c                                                |    3 +-
 drivers/bluetooth/btuart_cs.c                                             |    8 +-
 drivers/bluetooth/btusb.c                                                 |   68 +-
 drivers/bluetooth/btwilink.c                                              |    8 +-
 drivers/bluetooth/hci_bcm.c                                               |  133 ++-
 drivers/bluetooth/hci_h4.c                                                |    2 +-
 drivers/bluetooth/hci_ldisc.c                                             |    3 +-
 drivers/bluetooth/hci_ll.c                                                |   11 +-
 drivers/bluetooth/hci_nokia.c                                             |   10 +-
 drivers/bluetooth/hci_serdev.c                                            |   13 +
 drivers/bluetooth/hci_uart.h                                              |    1 +
 drivers/hv/channel.c                                                      |  129 +--
 drivers/infiniband/hw/bnxt_re/Kconfig                                     |    1 +
 drivers/infiniband/hw/mlx4/qp.c                                           |   26 +-
 drivers/isdn/capi/kcapi.c                                                 |    2 +-
 drivers/isdn/hardware/eicon/divacapi.h                                    |   16 +-
 drivers/isdn/hardware/eicon/message.c                                     |  247 +----
 drivers/isdn/hardware/mISDN/hfcsusb.h                                     |    2 +-
 drivers/isdn/hisax/hfc_usb.c                                              |    2 +-
 drivers/net/Makefile                                                      |    1 -
 drivers/net/appletalk/ipddp.c                                             |    4 +-
 drivers/net/arcnet/arcdevice.h                                            |    2 +-
 drivers/net/arcnet/com20020-pci.c                                         |    2 +-
 drivers/net/bonding/bond_sysfs.c                                          |    2 +-
 drivers/net/can/at91_can.c                                                |    2 +-
 drivers/net/can/c_can/c_can_platform.c                                    |    2 +-
 drivers/net/can/janz-ican3.c                                              |    2 +-
 drivers/net/dsa/b53/b53_common.c                                          |   83 +-
 drivers/net/dsa/b53/b53_priv.h                                            |   16 +-
 drivers/net/dsa/bcm_sf2.c                                                 |   48 +-
 drivers/net/dsa/bcm_sf2.h                                                 |   12 +-
 drivers/net/dsa/bcm_sf2_regs.h                                            |    3 +
 drivers/net/dsa/dsa_loop.c                                                |   42 +-
 drivers/net/dsa/lan9303-core.c                                            |  137 +--
 drivers/net/dsa/lan9303.h                                                 |   11 +
 drivers/net/dsa/lan9303_i2c.c                                             |    2 +
 drivers/net/dsa/lan9303_mdio.c                                            |   23 +
 drivers/net/dsa/microchip/ksz_common.c                                    |  124 +--
 drivers/net/dsa/mt7530.c                                                  |   43 +-
 drivers/net/dsa/mv88e6xxx/chip.c                                          |  416 +++-----
 drivers/net/dsa/mv88e6xxx/chip.h                                          |  146 +--
 drivers/net/dsa/mv88e6xxx/global2.c                                       |  104 +-
 drivers/net/dsa/mv88e6xxx/global2.h                                       |   41 +-
 drivers/net/dsa/mv88e6xxx/phy.c                                           |    1 -
 drivers/net/dsa/mv88e6xxx/port.h                                          |    3 -
 drivers/net/dsa/qca8k.c                                                   |  112 +-
 drivers/net/dsa/qca8k.h                                                   |    1 -
 drivers/net/dummy.c                                                       |    2 +-
 drivers/net/ethernet/3com/3c509.c                                         |    4 +-
 drivers/net/ethernet/3com/3c59x.c                                         |    2 +-
 drivers/net/ethernet/8390/ax88796.c                                       |    2 +-
 drivers/net/ethernet/Kconfig                                              |    1 +
 drivers/net/ethernet/Makefile                                             |    1 +
 drivers/net/ethernet/adi/bfin_mac.c                                       |    2 +-
 drivers/net/ethernet/amd/a2065.c                                          |    2 +-
 drivers/net/ethernet/amd/ariadne.c                                        |    2 +-
 drivers/net/ethernet/amd/xgbe/xgbe-common.h                               |   33 +-
 drivers/net/ethernet/amd/xgbe/xgbe-debugfs.c                              |   25 +
 drivers/net/ethernet/amd/xgbe/xgbe-dev.c                                  |  207 +++-
 drivers/net/ethernet/amd/xgbe/xgbe-drv.c                                  |  501 ++++++++-
 drivers/net/ethernet/amd/xgbe/xgbe-ethtool.c                              |   86 +-
 drivers/net/ethernet/amd/xgbe/xgbe-main.c                                 |   97 +-
 drivers/net/ethernet/amd/xgbe/xgbe-mdio.c                                 |   81 +-
 drivers/net/ethernet/amd/xgbe/xgbe-pci.c                                  |    4 +
 drivers/net/ethernet/amd/xgbe/xgbe-phy-v1.c                               |   54 +-
 drivers/net/ethernet/amd/xgbe/xgbe-phy-v2.c                               |  352 +++---
 drivers/net/ethernet/amd/xgbe/xgbe.h                                      |   92 +-
 drivers/net/ethernet/apm/xgene/xgene_enet_hw.c                            |    7 +-
 drivers/net/ethernet/apm/xgene/xgene_enet_main.c                          |    6 +-
 drivers/net/ethernet/apple/mace.c                                         |    8 +-
 drivers/net/ethernet/aquantia/atlantic/aq_ring.c                          |    7 +-
 drivers/net/ethernet/aquantia/atlantic/aq_ring.h                          |    5 +-
 drivers/net/ethernet/aquantia/atlantic/aq_vec.c                           |    1 +
 drivers/net/ethernet/arc/emac_main.c                                      |   13 +
 drivers/net/ethernet/broadcom/Kconfig                                     |   12 +
 drivers/net/ethernet/broadcom/bcm63xx_enet.c                              |    2 +-
 drivers/net/ethernet/broadcom/bcmsysport.c                                |  111 +-
 drivers/net/ethernet/broadcom/bcmsysport.h                                |   24 +-
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c                           |   14 +-
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.h                           |    4 +-
 drivers/net/ethernet/broadcom/bnxt/Makefile                               |    2 +-
 drivers/net/ethernet/broadcom/bnxt/bnxt.c                                 |  437 ++++++--
 drivers/net/ethernet/broadcom/bnxt/bnxt.h                                 |   95 +-
 drivers/net/ethernet/broadcom/bnxt/bnxt_dcb.c                             |   17 +-
 drivers/net/ethernet/broadcom/bnxt/bnxt_dcb.h                             |    1 +
 drivers/net/ethernet/broadcom/bnxt/bnxt_ethtool.c                         |   38 +-
 drivers/net/ethernet/broadcom/bnxt/bnxt_hsi.h                             |  500 ++++++++-
 drivers/net/ethernet/broadcom/bnxt/bnxt_sriov.c                           |   15 +-
 drivers/net/ethernet/broadcom/bnxt/bnxt_tc.c                              |  834 +++++++++++++++
 drivers/net/ethernet/broadcom/bnxt/bnxt_tc.h                              |  158 +++
 drivers/net/ethernet/broadcom/bnxt/bnxt_vfr.c                             |  513 +++++++++
 drivers/net/ethernet/broadcom/bnxt/bnxt_vfr.h                             |   89 ++
 drivers/net/ethernet/broadcom/bnxt/bnxt_xdp.c                             |    4 +-
 drivers/net/ethernet/broadcom/genet/bcmgenet.c                            |   75 +-
 drivers/net/ethernet/broadcom/genet/bcmgenet.h                            |   14 +-
 drivers/net/ethernet/broadcom/genet/bcmmii.c                              |  256 ++---
 drivers/net/ethernet/broadcom/sb1250-mac.c                                |   12 +-
 drivers/net/ethernet/broadcom/tg3.c                                       |    8 +-
 drivers/net/ethernet/cadence/macb_main.c                                  |    2 +-
 drivers/net/ethernet/cadence/macb_pci.c                                   |    2 +-
 drivers/net/ethernet/cadence/macb_ptp.c                                   |    2 +-
 drivers/net/ethernet/cavium/liquidio/cn23xx_pf_device.c                   |   82 +-
 drivers/net/ethernet/cavium/liquidio/cn23xx_pf_device.h                   |    2 -
 drivers/net/ethernet/cavium/liquidio/cn23xx_vf_device.h                   |    2 -
 drivers/net/ethernet/cavium/liquidio/lio_core.c                           |  728 ++++++++++++-
 drivers/net/ethernet/cavium/liquidio/lio_ethtool.c                        |  352 +++++-
 drivers/net/ethernet/cavium/liquidio/lio_main.c                           |  956 ++++-------------
 drivers/net/ethernet/cavium/liquidio/lio_vf_main.c                        |  598 ++---------
 drivers/net/ethernet/cavium/liquidio/liquidio_common.h                    |   11 +-
 drivers/net/ethernet/cavium/liquidio/octeon_config.h                      |   13 +-
 drivers/net/ethernet/cavium/liquidio/octeon_console.c                     |  153 ++-
 drivers/net/ethernet/cavium/liquidio/octeon_device.c                      |   27 +-
 drivers/net/ethernet/cavium/liquidio/octeon_device.h                      |   20 +-
 drivers/net/ethernet/cavium/liquidio/octeon_droq.c                        |   10 +-
 drivers/net/ethernet/cavium/liquidio/octeon_main.h                        |    6 +
 drivers/net/ethernet/cavium/liquidio/octeon_network.h                     |   35 +
 drivers/net/ethernet/cavium/liquidio/request_manager.c                    |   11 +-
 drivers/net/ethernet/cavium/thunder/nicvf_queues.h                        |    1 -
 drivers/net/ethernet/chelsio/cxgb3/cxgb3_main.c                           |    8 +-
 drivers/net/ethernet/chelsio/cxgb4/cxgb4.h                                |   58 +-
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_ethtool.c                        |  192 +++-
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c                           |  188 ++--
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_tc_u32.c                         |    9 +-
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_tc_u32.h                         |    6 +-
 drivers/net/ethernet/chelsio/cxgb4/sched.c                                |    6 +-
 drivers/net/ethernet/chelsio/cxgb4/t4_hw.c                                |  972 ++++++++++++++---
 drivers/net/ethernet/chelsio/cxgb4/t4fw_api.h                             |  177 +++-
 drivers/net/ethernet/chelsio/cxgb4vf/cxgb4vf_main.c                       |   50 +-
 drivers/net/ethernet/chelsio/cxgb4vf/t4vf_common.h                        |   86 +-
 drivers/net/ethernet/chelsio/cxgb4vf/t4vf_hw.c                            |  456 ++++++--
 drivers/net/ethernet/dec/tulip/de4x5.c                                    |    2 +-
 drivers/net/ethernet/dec/tulip/tulip_core.c                               |    2 -
 drivers/net/ethernet/ec_bhf.c                                             |    2 +-
 drivers/net/ethernet/emulex/benet/be_roce.c                               |    3 -
 drivers/net/ethernet/faraday/ftgmac100.c                                  |    5 +
 drivers/net/ethernet/freescale/dpaa/dpaa_eth.c                            |   95 +-
 drivers/net/ethernet/freescale/dpaa/dpaa_eth.h                            |    2 +
 drivers/net/ethernet/freescale/dpaa/dpaa_eth_sysfs.c                      |    3 +
 drivers/net/ethernet/freescale/dpaa/dpaa_ethtool.c                        |  118 +++
 drivers/net/ethernet/freescale/fec_main.c                                 |   13 +-
 drivers/net/ethernet/freescale/fec_mpc52xx.c                              |    4 +-
 drivers/net/ethernet/freescale/fman/Makefile                              |    2 +-
 drivers/net/ethernet/freescale/fman/fman.c                                |  114 +-
 drivers/net/ethernet/freescale/fman/fman.h                                |   77 ++
 drivers/net/ethernet/freescale/fman/fman_dtsec.c                          |  118 ++-
 drivers/net/ethernet/freescale/fman/fman_keygen.c                         |  783 ++++++++++++++
 drivers/net/ethernet/freescale/fman/fman_keygen.h                         |   46 +
 drivers/net/ethernet/freescale/fman/fman_port.c                           |   63 +-
 drivers/net/ethernet/freescale/fman/fman_port.h                           |    7 +
 drivers/net/ethernet/freescale/fman/mac.c                                 |   50 +-
 drivers/net/ethernet/freescale/fs_enet/mii-bitbang.c                      |    2 +-
 drivers/net/ethernet/freescale/fsl_pq_mdio.c                              |   20 +-
 drivers/net/ethernet/freescale/gianfar.c                                  |    2 +-
 drivers/net/ethernet/freescale/gianfar_ptp.c                              |    2 +-
 drivers/net/ethernet/hisilicon/Kconfig                                    |   27 +
 drivers/net/ethernet/hisilicon/Makefile                                   |    1 +
 drivers/net/ethernet/hisilicon/hns/hnae.c                                 |    1 +
 drivers/net/ethernet/hisilicon/hns/hnae.h                                 |   15 +
 drivers/net/ethernet/hisilicon/hns/hns_ae_adapt.c                         |    1 +
 drivers/net/ethernet/hisilicon/hns/hns_enet.c                             |  135 ++-
 drivers/net/ethernet/hisilicon/hns/hns_enet.h                             |    2 +-
 drivers/net/ethernet/hisilicon/hns/hns_ethtool.c                          |    9 +-
 drivers/net/ethernet/hisilicon/hns3/Makefile                              |    7 +
 drivers/net/ethernet/hisilicon/hns3/hnae3.c                               |  300 ++++++
 drivers/net/ethernet/hisilicon/hns3/hnae3.h                               |  444 ++++++++
 drivers/net/ethernet/hisilicon/hns3/hns3pf/Makefile                       |   11 +
 drivers/net/ethernet/hisilicon/hns3/hns3pf/hclge_cmd.c                    |  356 +++++++
 drivers/net/ethernet/hisilicon/hns3/hns3pf/hclge_cmd.h                    |  740 +++++++++++++
 drivers/net/ethernet/hisilicon/hns3/hns3pf/hclge_main.c                   | 4265 +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
 drivers/net/ethernet/hisilicon/hns3/hns3pf/hclge_main.h                   |  519 +++++++++
 drivers/net/ethernet/hisilicon/hns3/hns3pf/hclge_mdio.c                   |  213 ++++
 drivers/net/ethernet/hisilicon/hns3/hns3pf/hclge_mdio.h                   |   17 +
 drivers/net/ethernet/hisilicon/hns3/hns3pf/hclge_tm.c                     | 1015 ++++++++++++++++++
 drivers/net/ethernet/hisilicon/hns3/hns3pf/hclge_tm.h                     |  106 ++
 drivers/net/ethernet/hisilicon/hns3/hns3pf/hns3_enet.c                    | 2891 ++++++++++++++++++++++++++++++++++++++++++++++++++
 drivers/net/ethernet/hisilicon/hns3/hns3pf/hns3_enet.h                    |  593 +++++++++++
 drivers/net/ethernet/hisilicon/hns3/hns3pf/hns3_ethtool.c                 |  493 +++++++++
 drivers/net/ethernet/hp/hp100.c                                           |    2 +-
 drivers/net/ethernet/huawei/Kconfig                                       |   19 +
 drivers/net/ethernet/huawei/Makefile                                      |    5 +
 drivers/net/ethernet/huawei/hinic/Kconfig                                 |   12 +
 drivers/net/ethernet/huawei/hinic/Makefile                                |    6 +
 drivers/net/ethernet/huawei/hinic/hinic_common.c                          |   80 ++
 drivers/net/ethernet/huawei/hinic/hinic_common.h                          |   38 +
 drivers/net/ethernet/huawei/hinic/hinic_dev.h                             |   64 ++
 drivers/net/ethernet/huawei/hinic/hinic_hw_api_cmd.c                      |  978 +++++++++++++++++
 drivers/net/ethernet/huawei/hinic/hinic_hw_api_cmd.h                      |  208 ++++
 drivers/net/ethernet/huawei/hinic/hinic_hw_cmdq.c                         |  946 +++++++++++++++++
 drivers/net/ethernet/huawei/hinic/hinic_hw_cmdq.h                         |  187 ++++
 drivers/net/ethernet/huawei/hinic/hinic_hw_csr.h                          |  149 +++
 drivers/net/ethernet/huawei/hinic/hinic_hw_dev.c                          | 1013 ++++++++++++++++++
 drivers/net/ethernet/huawei/hinic/hinic_hw_dev.h                          |  239 +++++
 drivers/net/ethernet/huawei/hinic/hinic_hw_eqs.c                          |  886 ++++++++++++++++
 drivers/net/ethernet/huawei/hinic/hinic_hw_eqs.h                          |  265 +++++
 drivers/net/ethernet/huawei/hinic/hinic_hw_if.c                           |  351 ++++++
 drivers/net/ethernet/huawei/hinic/hinic_hw_if.h                           |  272 +++++
 drivers/net/ethernet/huawei/hinic/hinic_hw_io.c                           |  533 ++++++++++
 drivers/net/ethernet/huawei/hinic/hinic_hw_io.h                           |   97 ++
 drivers/net/ethernet/huawei/hinic/hinic_hw_mgmt.c                         |  597 +++++++++++
 drivers/net/ethernet/huawei/hinic/hinic_hw_mgmt.h                         |  153 +++
 drivers/net/ethernet/huawei/hinic/hinic_hw_qp.c                           |  887 ++++++++++++++++
 drivers/net/ethernet/huawei/hinic/hinic_hw_qp.h                           |  201 ++++
 drivers/net/ethernet/huawei/hinic/hinic_hw_qp_ctxt.h                      |  214 ++++
 drivers/net/ethernet/huawei/hinic/hinic_hw_wq.c                           |  878 +++++++++++++++
 drivers/net/ethernet/huawei/hinic/hinic_hw_wq.h                           |  117 ++
 drivers/net/ethernet/huawei/hinic/hinic_hw_wqe.h                          |  368 +++++++
 drivers/net/ethernet/huawei/hinic/hinic_main.c                            | 1112 +++++++++++++++++++
 drivers/net/ethernet/huawei/hinic/hinic_port.c                            |  379 +++++++
 drivers/net/ethernet/huawei/hinic/hinic_port.h                            |  198 ++++
 drivers/net/ethernet/huawei/hinic/hinic_rx.c                              |  509 +++++++++
 drivers/net/ethernet/huawei/hinic/hinic_rx.h                              |   55 +
 drivers/net/ethernet/huawei/hinic/hinic_tx.c                              |  504 +++++++++
 drivers/net/ethernet/huawei/hinic/hinic_tx.h                              |   62 ++
 drivers/net/ethernet/ibm/ehea/ehea_main.c                                 |    5 +-
 drivers/net/ethernet/ibm/emac/core.c                                      |   63 +-
 drivers/net/ethernet/ibm/emac/core.h                                      |    1 -
 drivers/net/ethernet/ibm/emac/debug.h                                     |    2 +-
 drivers/net/ethernet/ibm/emac/mal.c                                       |    8 +-
 drivers/net/ethernet/ibm/emac/rgmii.c                                     |   18 +-
 drivers/net/ethernet/ibm/emac/tah.c                                       |   12 +-
 drivers/net/ethernet/ibm/emac/zmii.c                                      |   17 +-
 drivers/net/ethernet/ibm/ibmveth.c                                        |    2 +-
 drivers/net/ethernet/ibm/ibmvnic.c                                        |  214 +++-
 drivers/net/ethernet/ibm/ibmvnic.h                                        |   17 +
 drivers/net/ethernet/intel/e1000e/hw.h                                    |    4 +
 drivers/net/ethernet/intel/e1000e/ich8lan.c                               |    2 +
 drivers/net/ethernet/intel/e1000e/netdev.c                                |    4 +
 drivers/net/ethernet/intel/fm10k/fm10k_netdev.c                           |   14 +-
 drivers/net/ethernet/intel/i40e/i40e.h                                    |   44 +-
 drivers/net/ethernet/intel/i40e/i40e_common.c                             |    8 +-
 drivers/net/ethernet/intel/i40e/i40e_ethtool.c                            |  160 +--
 drivers/net/ethernet/intel/i40e/i40e_main.c                               |  318 +++---
 drivers/net/ethernet/intel/i40e/i40e_nvm.c                                |  134 ++-
 drivers/net/ethernet/intel/i40e/i40e_prototype.h                          |    2 -
 drivers/net/ethernet/intel/i40e/i40e_ptp.c                                |   11 +-
 drivers/net/ethernet/intel/i40e/i40e_txrx.c                               |   96 +-
 drivers/net/ethernet/intel/i40e/i40e_txrx.h                               |    5 +-
 drivers/net/ethernet/intel/i40e/i40e_type.h                               |    1 +
 drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c                        |  124 ++-
 drivers/net/ethernet/intel/i40evf/i40e_common.c                           |    6 +-
 drivers/net/ethernet/intel/i40evf/i40e_osdep.h                            |    4 +-
 drivers/net/ethernet/intel/i40evf/i40e_txrx.c                             |   75 +-
 drivers/net/ethernet/intel/i40evf/i40e_txrx.h                             |    7 +-
 drivers/net/ethernet/intel/i40evf/i40e_type.h                             |    1 +
 drivers/net/ethernet/intel/i40evf/i40evf.h                                |   31 +-
 drivers/net/ethernet/intel/i40evf/i40evf_ethtool.c                        |   45 +-
 drivers/net/ethernet/intel/i40evf/i40evf_main.c                           |  116 +-
 drivers/net/ethernet/intel/i40evf/i40evf_virtchnl.c                       |   44 +-
 drivers/net/ethernet/intel/igb/e1000_82575.c                              |    6 +
 drivers/net/ethernet/intel/igb/e1000_defines.h                            |    1 +
 drivers/net/ethernet/intel/igb/e1000_hw.h                                 |   18 +-
 drivers/net/ethernet/intel/igb/e1000_mbx.c                                |   57 +-
 drivers/net/ethernet/intel/igb/e1000_mbx.h                                |   14 +-
 drivers/net/ethernet/intel/igb/igb_main.c                                 |   23 +-
 drivers/net/ethernet/intel/igbvf/ethtool.c                                |    4 +
 drivers/net/ethernet/intel/igbvf/mbx.c                                    |    4 +
 drivers/net/ethernet/intel/igbvf/netdev.c                                 |   47 +
 drivers/net/ethernet/intel/igbvf/vf.c                                     |   12 +-
 drivers/net/ethernet/intel/igbvf/vf.h                                     |    1 +
 drivers/net/ethernet/intel/ixgbe/ixgbe_common.c                           |   30 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_lib.c                              |    8 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c                             |  132 ++-
 drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c                            |    9 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_type.h                             |    4 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_x550.c                             |  102 +-
 drivers/net/ethernet/marvell/mv643xx_eth.c                                |    6 +-
 drivers/net/ethernet/marvell/mvneta.c                                     |    5 +-
 drivers/net/ethernet/marvell/mvpp2.c                                      | 1601 ++++++++++++++++++++++------
 drivers/net/ethernet/marvell/skge.c                                       |    2 +-
 drivers/net/ethernet/mediatek/Kconfig                                     |    6 +-
 drivers/net/ethernet/mediatek/mtk_eth_soc.c                               |  183 +++-
 drivers/net/ethernet/mediatek/mtk_eth_soc.h                               |   80 +-
 drivers/net/ethernet/mellanox/Kconfig                                     |    5 +-
 drivers/net/ethernet/mellanox/mlx4/alloc.c                                |    2 +-
 drivers/net/ethernet/mellanox/mlx4/cmd.c                                  |   20 +-
 drivers/net/ethernet/mellanox/mlx4/en_cq.c                                |    4 +-
 drivers/net/ethernet/mellanox/mlx4/en_main.c                              |    9 +-
 drivers/net/ethernet/mellanox/mlx4/en_netdev.c                            |   40 +-
 drivers/net/ethernet/mellanox/mlx4/en_resources.c                         |    2 +-
 drivers/net/ethernet/mellanox/mlx4/en_rx.c                                |    2 +-
 drivers/net/ethernet/mellanox/mlx4/en_tx.c                                |    2 +-
 drivers/net/ethernet/mellanox/mlx4/eq.c                                   |   20 +-
 drivers/net/ethernet/mellanox/mlx4/fw.c                                   |   26 +-
 drivers/net/ethernet/mellanox/mlx4/fw.h                                   |    6 +-
 drivers/net/ethernet/mellanox/mlx4/fw_qos.c                               |    6 +-
 drivers/net/ethernet/mellanox/mlx4/fw_qos.h                               |   10 +-
 drivers/net/ethernet/mellanox/mlx4/icm.c                                  |    2 +-
 drivers/net/ethernet/mellanox/mlx4/icm.h                                  |    4 +-
 drivers/net/ethernet/mellanox/mlx4/intf.c                                 |    2 +-
 drivers/net/ethernet/mellanox/mlx4/main.c                                 |  260 ++---
 drivers/net/ethernet/mellanox/mlx4/mcg.c                                  |   12 +-
 drivers/net/ethernet/mellanox/mlx4/mlx4.h                                 |    2 +
 drivers/net/ethernet/mellanox/mlx4/mlx4_en.h                              |    2 +-
 drivers/net/ethernet/mellanox/mlx4/mr.c                                   |   10 +-
 drivers/net/ethernet/mellanox/mlx4/port.c                                 |   25 +
 drivers/net/ethernet/mellanox/mlx4/qp.c                                   |   31 +-
 drivers/net/ethernet/mellanox/mlx4/resource_tracker.c                     |   24 +-
 drivers/net/ethernet/mellanox/mlx5/core/Kconfig                           |   21 +
 drivers/net/ethernet/mellanox/mlx5/core/Makefile                          |   16 +-
 drivers/net/ethernet/mellanox/mlx5/core/alloc.c                           |    1 +
 drivers/net/ethernet/mellanox/mlx5/core/cmd.c                             |    1 -
 drivers/net/ethernet/mellanox/mlx5/core/dev.c                             |   73 ++
 drivers/net/ethernet/mellanox/mlx5/core/diag/Makefile                     |    1 +
 drivers/net/ethernet/mellanox/mlx5/core/diag/fs_tracepoint.c              |  261 +++++
 drivers/net/ethernet/mellanox/mlx5/core/diag/fs_tracepoint.h              |  282 +++++
 drivers/net/ethernet/mellanox/mlx5/core/en.h                              |   67 +-
 drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c                      |   78 +-
 drivers/net/ethernet/mellanox/mlx5/core/en_fs.c                           |  298 +++++-
 drivers/net/ethernet/mellanox/mlx5/core/en_main.c                         |  328 +++---
 drivers/net/ethernet/mellanox/mlx5/core/en_rep.c                          |   80 +-
 drivers/net/ethernet/mellanox/mlx5/core/en_rep.h                          |    9 +
 drivers/net/ethernet/mellanox/mlx5/core/en_rx.c                           |  227 ++--
 drivers/net/ethernet/mellanox/mlx5/core/en_stats.h                        |   50 +-
 drivers/net/ethernet/mellanox/mlx5/core/en_tc.c                           |    6 +-
 drivers/net/ethernet/mellanox/mlx5/core/en_tc.h                           |   11 +-
 drivers/net/ethernet/mellanox/mlx5/core/en_tx.c                           |   18 +-
 drivers/net/ethernet/mellanox/mlx5/core/en_txrx.c                         |   88 +-
 drivers/net/ethernet/mellanox/mlx5/core/eq.c                              |    9 +-
 drivers/net/ethernet/mellanox/mlx5/core/eswitch.c                         |  211 +---
 drivers/net/ethernet/mellanox/mlx5/core/eswitch.h                         |   78 +-
 drivers/net/ethernet/mellanox/mlx5/core/eswitch_offloads.c                |    6 +-
 drivers/net/ethernet/mellanox/mlx5/core/fs_cmd.c                          |   14 +-
 drivers/net/ethernet/mellanox/mlx5/core/fs_cmd.h                          |   10 +-
 drivers/net/ethernet/mellanox/mlx5/core/fs_core.c                         |  476 ++++++---
 drivers/net/ethernet/mellanox/mlx5/core/fs_core.h                         |   25 +-
 drivers/net/ethernet/mellanox/mlx5/core/fs_counters.c                     |   13 +-
 drivers/net/ethernet/mellanox/mlx5/core/ipoib/ethtool.c                   |  135 ++-
 drivers/net/ethernet/mellanox/mlx5/core/lib/mpfs.c                        |  201 ++++
 drivers/net/ethernet/mellanox/mlx5/core/lib/mpfs.h                        |   95 ++
 drivers/net/ethernet/mellanox/mlx5/core/main.c                            |   40 +-
 drivers/net/ethernet/mellanox/mlx5/core/mlx5_core.h                       |    4 +
 drivers/net/ethernet/mellanox/mlx5/core/sriov.c                           |   15 +-
 drivers/net/ethernet/mellanox/mlxsw/Kconfig                               |    1 +
 drivers/net/ethernet/mellanox/mlxsw/Makefile                              |    5 +-
 drivers/net/ethernet/mellanox/mlxsw/core.c                                |    2 +-
 drivers/net/ethernet/mellanox/mlxsw/core_acl_flex_keys.h                  |    6 +
 drivers/net/ethernet/mellanox/mlxsw/reg.h                                 |  422 +++++++-
 drivers/net/ethernet/mellanox/mlxsw/spectrum.c                            |  194 ++--
 drivers/net/ethernet/mellanox/mlxsw/spectrum.h                            |   15 +-
 drivers/net/ethernet/mellanox/mlxsw/spectrum_acl.c                        |   80 +-
 drivers/net/ethernet/mellanox/mlxsw/spectrum_acl_flex_keys.h              |    3 +
 drivers/net/ethernet/mellanox/mlxsw/spectrum_acl_tcam.c                   |   18 +
 drivers/net/ethernet/mellanox/mlxsw/spectrum_dpipe.c                      |  578 +++++++++-
 drivers/net/ethernet/mellanox/mlxsw/spectrum_dpipe.h                      |   17 +
 drivers/net/ethernet/mellanox/mlxsw/spectrum_fid.c                        |    2 +-
 drivers/net/ethernet/mellanox/mlxsw/spectrum_flower.c                     |   78 +-
 drivers/net/ethernet/mellanox/mlxsw/spectrum_ipip.c                       |  214 ++++
 drivers/net/ethernet/mellanox/mlxsw/spectrum_ipip.h                       |   79 ++
 drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c                     | 5367 +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++---------------------------
 drivers/net/ethernet/mellanox/mlxsw/spectrum_router.h                     |   51 +
 drivers/net/ethernet/mellanox/mlxsw/switchib.c                            |    2 +-
 drivers/net/ethernet/mellanox/mlxsw/switchx2.c                            |    2 +-
 drivers/net/ethernet/mellanox/mlxsw/trap.h                                |   26 +-
 drivers/net/ethernet/moxa/moxart_ether.c                                  |   15 +-
 drivers/net/ethernet/moxa/moxart_ether.h                                  |    8 +-
 drivers/net/ethernet/neterion/s2io.c                                      |   45 -
 drivers/net/ethernet/netronome/Kconfig                                    |    1 +
 drivers/net/ethernet/netronome/nfp/Makefile                               |    1 +
 drivers/net/ethernet/netronome/nfp/bpf/jit.c                              |   24 +
 drivers/net/ethernet/netronome/nfp/bpf/main.c                             |   30 +-
 drivers/net/ethernet/netronome/nfp/bpf/offload.c                          |    4 +-
 drivers/net/ethernet/netronome/nfp/bpf/verifier.c                         |   24 +-
 drivers/net/ethernet/netronome/nfp/flower/cmsg.c                          |   77 +-
 drivers/net/ethernet/netronome/nfp/flower/cmsg.h                          |   22 +
 drivers/net/ethernet/netronome/nfp/flower/main.c                          |  144 ++-
 drivers/net/ethernet/netronome/nfp/flower/main.h                          |   11 +-
 drivers/net/ethernet/netronome/nfp/flower/offload.c                       |   15 +-
 drivers/net/ethernet/netronome/nfp/nfp_app.c                              |   22 +-
 drivers/net/ethernet/netronome/nfp/nfp_app.h                              |   45 +-
 drivers/net/ethernet/netronome/nfp/nfp_app_nic.c                          |    4 +-
 drivers/net/ethernet/netronome/nfp/nfp_main.c                             |   48 +-
 drivers/net/ethernet/netronome/nfp/nfp_main.h                             |    4 +
 drivers/net/ethernet/netronome/nfp/nfp_net.h                              |    2 -
 drivers/net/ethernet/netronome/nfp/nfp_net_common.c                       |   18 +-
 drivers/net/ethernet/netronome/nfp/nfp_net_ctrl.h                         |    1 +
 drivers/net/ethernet/netronome/nfp/nfp_net_debugfs.c                      |   13 +-
 drivers/net/ethernet/netronome/nfp/nfp_net_ethtool.c                      |  593 +++++++----
 drivers/net/ethernet/netronome/nfp/nfp_net_main.c                         |   68 +-
 drivers/net/ethernet/netronome/nfp/nfp_net_repr.c                         |   88 +-
 drivers/net/ethernet/netronome/nfp/nfp_net_sriov.c                        |  243 +++++
 drivers/net/ethernet/netronome/nfp/nfp_net_sriov.h                        |   86 ++
 drivers/net/ethernet/netronome/nfp/nfp_port.c                             |   39 +-
 drivers/net/ethernet/netronome/nfp/nfp_port.h                             |   60 +-
 drivers/net/ethernet/netronome/nfp/nfpcore/nfp_nsp_eth.c                  |   18 +-
 drivers/net/ethernet/netronome/nfp/nic/main.c                             |   14 +-
 drivers/net/ethernet/nvidia/forcedeth.c                                   |    5 +-
 drivers/net/ethernet/qlogic/netxen/netxen_nic_main.c                      |    4 +-
 drivers/net/ethernet/qlogic/qed/qed_dev.c                                 |  145 ++-
 drivers/net/ethernet/qlogic/qed/qed_dev_api.h                             |   43 +-
 drivers/net/ethernet/qlogic/qed/qed_hsi.h                                 |   49 +
 drivers/net/ethernet/qlogic/qed/qed_l2.c                                  |  115 ++
 drivers/net/ethernet/qlogic/qed/qed_l2.h                                  |   18 +-
 drivers/net/ethernet/qlogic/qed/qed_main.c                                |   58 +-
 drivers/net/ethernet/qlogic/qed/qed_mcp.c                                 |   66 ++
 drivers/net/ethernet/qlogic/qed/qed_mcp.h                                 |   37 +-
 drivers/net/ethernet/qlogic/qed/qed_sriov.c                               |  157 +++
 drivers/net/ethernet/qlogic/qed/qed_sriov.h                               |    3 +
 drivers/net/ethernet/qlogic/qed/qed_vf.c                                  |   75 ++
 drivers/net/ethernet/qlogic/qed/qed_vf.h                                  |   53 +-
 drivers/net/ethernet/qlogic/qede/qede.h                                   |   19 +-
 drivers/net/ethernet/qlogic/qede/qede_ethtool.c                           |  205 +++-
 drivers/net/ethernet/qlogic/qede/qede_filter.c                            |  483 ++++++++-
 drivers/net/ethernet/qlogic/qede/qede_main.c                              |    9 +-
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_init.c                          |   10 +-
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_minidump.c                      |    2 +-
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_sysfs.c                         |    8 +-
 drivers/net/ethernet/qlogic/qlge/qlge_dbg.c                               |   47 +-
 drivers/net/ethernet/qualcomm/Kconfig                                     |    2 +
 drivers/net/ethernet/qualcomm/Makefile                                    |    2 +
 drivers/net/ethernet/qualcomm/rmnet/Kconfig                               |   12 +
 drivers/net/ethernet/qualcomm/rmnet/Makefile                              |   10 +
 drivers/net/ethernet/qualcomm/rmnet/rmnet_config.c                        |  356 +++++++
 drivers/net/ethernet/qualcomm/rmnet/rmnet_config.h                        |   55 +
 drivers/net/ethernet/qualcomm/rmnet/rmnet_handlers.c                      |  271 +++++
 drivers/net/ethernet/qualcomm/rmnet/rmnet_handlers.h                      |   26 +
 drivers/net/ethernet/qualcomm/rmnet/rmnet_map.h                           |   86 ++
 drivers/net/ethernet/qualcomm/rmnet/rmnet_map_command.c                   |  106 ++
 drivers/net/ethernet/qualcomm/rmnet/rmnet_map_data.c                      |  104 ++
 drivers/net/ethernet/qualcomm/rmnet/rmnet_private.h                       |   44 +
 drivers/net/ethernet/qualcomm/rmnet/rmnet_vnd.c                           |  174 +++
 drivers/net/ethernet/qualcomm/rmnet/rmnet_vnd.h                           |   29 +
 drivers/net/ethernet/renesas/ravb.h                                       |    2 +
 drivers/net/ethernet/renesas/ravb_main.c                                  |  131 ++-
 drivers/net/ethernet/renesas/sh_eth.c                                     |    2 +-
 drivers/net/ethernet/rocker/rocker_main.c                                 |    5 +
 drivers/net/ethernet/rocker/rocker_ofdpa.c                                |   10 +-
 drivers/net/ethernet/sfc/efx.h                                            |    4 +-
 drivers/net/ethernet/sfc/falcon/efx.h                                     |    4 +-
 drivers/net/ethernet/sfc/falcon/tx.c                                      |   13 +-
 drivers/net/ethernet/sfc/mcdi_port.c                                      |  224 +++-
 drivers/net/ethernet/sfc/tx.c                                             |   13 +-
 drivers/net/ethernet/stmicro/stmmac/Kconfig                               |    9 +
 drivers/net/ethernet/stmicro/stmmac/Makefile                              |    1 +
 drivers/net/ethernet/stmicro/stmmac/dwmac-anarion.c                       |  152 +++
 drivers/net/ethernet/stmicro/stmmac/dwmac-meson8b.c                       |    2 +-
 drivers/net/ethernet/stmicro/stmmac/dwmac-rk.c                            |  193 +++-
 drivers/net/ethernet/stmicro/stmmac/stmmac_mdio.c                         |   16 -
 drivers/net/ethernet/stmicro/stmmac/stmmac_ptp.c                          |    2 +-
 drivers/net/ethernet/sun/ldmvsw.c                                         |    2 +-
 drivers/net/ethernet/sun/niu.c                                            |   24 +-
 drivers/net/ethernet/sun/sunvnet.c                                        |    2 +-
 drivers/net/ethernet/sun/sunvnet_common.c                                 |   90 +-
 drivers/net/ethernet/synopsys/dwc-xlgmac-net.c                            |    1 +
 drivers/net/ethernet/ti/cpsw.c                                            |   10 +-
 drivers/net/ethernet/ti/cpts.c                                            |    2 +-
 drivers/net/ethernet/ti/davinci_emac.c                                    |    4 +-
 drivers/net/ethernet/ti/davinci_mdio.c                                    |   10 +-
 drivers/net/ethernet/ti/netcp_core.c                                      |   13 +-
 drivers/net/ethernet/tile/tilegx.c                                        |    2 +-
 drivers/net/ethernet/xilinx/ll_temac_main.c                               |    2 +-
 drivers/net/ethernet/xilinx/xilinx_axienet.h                              |    4 +-
 drivers/net/ethernet/xilinx/xilinx_axienet_main.c                         |   48 +-
 drivers/net/ethernet/xircom/xirc2ps_cs.c                                  |    2 +-
 drivers/net/fddi/defxx.c                                                  |    2 +-
 drivers/net/geneve.c                                                      |  322 ++++--
 drivers/net/hamradio/baycom_par.c                                         |    2 +-
 drivers/net/hamradio/baycom_ser_fdx.c                                     |    2 +-
 drivers/net/hamradio/baycom_ser_hdx.c                                     |    2 +-
 drivers/net/hamradio/dmascc.c                                             |    2 +-
 drivers/net/hyperv/hyperv_net.h                                           |   74 +-
 drivers/net/hyperv/netvsc.c                                               |  459 ++++----
 drivers/net/hyperv/netvsc_drv.c                                           |  816 ++++++++++----
 drivers/net/hyperv/rndis_filter.c                                         |  162 +--
 drivers/net/ieee802154/ca8210.c                                           |    6 +-
 drivers/net/ieee802154/mrf24j40.c                                         |    3 +-
 drivers/net/ipvlan/ipvlan_main.c                                          |    4 +-
 drivers/net/ipvlan/ipvtap.c                                               |    2 +-
 drivers/net/macvlan.c                                                     |    5 +-
 drivers/net/macvtap.c                                                     |    2 +-
 drivers/net/phy/Kconfig                                                   |   74 +-
 drivers/net/phy/Makefile                                                  |    7 +
 drivers/net/phy/bcm7xxx.c                                                 |    2 +-
 drivers/net/phy/dp83640.c                                                 |    7 +-
 drivers/net/phy/marvell.c                                                 |  320 +++---
 drivers/net/phy/mdio-bcm-unimac.c                                         |  103 +-
 drivers/net/phy/mdio-gpio.c                                               |    2 +-
 drivers/net/phy/mdio-i2c.c                                                |  109 ++
 drivers/net/phy/mdio-i2c.h                                                |   19 +
 drivers/net/phy/mdio-mux-bcm-iproc.c                                      |    2 +-
 drivers/net/phy/mdio-mux-gpio.c                                           |    2 +-
 drivers/net/phy/mdio-mux-mmioreg.c                                        |   21 +-
 drivers/net/phy/mdio-mux.c                                                |   34 +-
 drivers/net/phy/mdio_bus.c                                                |    6 +-
 drivers/net/phy/phy-core.c                                                |  180 ++++
 drivers/net/phy/phy.c                                                     |  235 +---
 drivers/net/phy/phy_device.c                                              |   37 +-
 drivers/net/phy/phylink.c                                                 | 1462 +++++++++++++++++++++++++
 drivers/net/phy/rockchip.c                                                |  233 ++++
 drivers/net/phy/sfp-bus.c                                                 |  475 +++++++++
 drivers/net/phy/sfp.c                                                     |  915 ++++++++++++++++
 drivers/net/phy/sfp.h                                                     |   28 +
 drivers/net/tap.c                                                         |   11 +-
 drivers/net/tun.c                                                         |  267 ++++-
 drivers/net/usb/catc.c                                                    |    2 +-
 drivers/net/usb/cdc-phonet.c                                              |    2 +-
 drivers/net/usb/cdc_ncm.c                                                 |    2 +-
 drivers/net/usb/ipheth.c                                                  |    2 +-
 drivers/net/usb/kaweth.c                                                  |    2 +-
 drivers/net/usb/r8152.c                                                   |    2 +-
 drivers/net/usb/rtl8150.c                                                 |    2 +-
 drivers/net/virtio_net.c                                                  |  350 +++---
 drivers/net/vrf.c                                                         |  139 +--
 drivers/net/vxlan.c                                                       |  162 +--
 drivers/net/wan/dscc4.c                                                   |  129 ++-
 drivers/net/wireless/ath/ar5523/ar5523.c                                  |    2 +-
 drivers/net/wireless/ath/ath10k/Kconfig                                   |    7 +
 drivers/net/wireless/ath/ath10k/Makefile                                  |    3 +
 drivers/net/wireless/ath/ath10k/ahb.c                                     |   18 +-
 drivers/net/wireless/ath/ath10k/ce.c                                      |  299 +++---
 drivers/net/wireless/ath/ath10k/ce.h                                      |   30 +-
 drivers/net/wireless/ath/ath10k/core.c                                    |   29 +-
 drivers/net/wireless/ath/ath10k/core.h                                    |    9 +-
 drivers/net/wireless/ath/ath10k/debug.c                                   |    8 +-
 drivers/net/wireless/ath/ath10k/debug.h                                   |    2 +
 drivers/net/wireless/ath/ath10k/htt_rx.c                                  |   31 +-
 drivers/net/wireless/ath/ath10k/hw.c                                      |  150 +++
 drivers/net/wireless/ath/ath10k/hw.h                                      |   14 +
 drivers/net/wireless/ath/ath10k/mac.c                                     |    6 +-
 drivers/net/wireless/ath/ath10k/pci.c                                     |  105 +-
 drivers/net/wireless/ath/ath10k/pci.h                                     |   14 +-
 drivers/net/wireless/ath/ath10k/sdio.c                                    |   12 +-
 drivers/net/wireless/ath/ath10k/sdio.h                                    |    2 -
 drivers/net/wireless/ath/ath10k/usb.c                                     | 1106 +++++++++++++++++++
 drivers/net/wireless/ath/ath10k/usb.h                                     |  128 +++
 drivers/net/wireless/ath/ath10k/wmi.c                                     |  166 ++-
 drivers/net/wireless/ath/ath10k/wmi.h                                     |  271 ++++-
 drivers/net/wireless/ath/ath10k/wow.c                                     |   14 +
 drivers/net/wireless/ath/ath10k/wow.h                                     |    1 +
 drivers/net/wireless/ath/ath6kl/usb.c                                     |    2 +-
 drivers/net/wireless/ath/ath9k/debug.c                                    |    2 +-
 drivers/net/wireless/ath/ath9k/hif_usb.c                                  |    2 +-
 drivers/net/wireless/ath/ath9k/htc_drv_init.c                             |    2 +-
 drivers/net/wireless/ath/ath9k/init.c                                     |    2 +-
 drivers/net/wireless/ath/ath9k/pci.c                                      |    5 +
 drivers/net/wireless/ath/carl9170/usb.c                                   |    2 +-
 drivers/net/wireless/ath/wcn36xx/dxe.c                                    |    5 +
 drivers/net/wireless/ath/wcn36xx/main.c                                   |   52 +-
 drivers/net/wireless/ath/wcn36xx/wcn36xx.h                                |    3 +
 drivers/net/wireless/ath/wil6210/Kconfig                                  |   12 +
 drivers/net/wireless/ath/wil6210/Makefile                                 |    2 +-
 drivers/net/wireless/ath/wil6210/cfg80211.c                               |   84 +-
 drivers/net/wireless/ath/wil6210/debugfs.c                                |   27 +-
 drivers/net/wireless/ath/wil6210/interrupt.c                              |   14 +-
 drivers/net/wireless/ath/wil6210/main.c                                   |   42 +-
 drivers/net/wireless/ath/wil6210/pcie_bus.c                               |    3 +
 drivers/net/wireless/ath/wil6210/pm.c                                     |   27 +-
 drivers/net/wireless/ath/wil6210/txrx.c                                   |    6 +-
 drivers/net/wireless/ath/wil6210/wil6210.h                                |   20 +-
 drivers/net/wireless/ath/wil6210/wmi.c                                    |   14 +-
 drivers/net/wireless/ath/wil6210/wmi.h                                    |  720 ++++++++-----
 drivers/net/wireless/atmel/at76c50x-usb.c                                 |    2 +-
 drivers/net/wireless/broadcom/brcm80211/brcmfmac/bcmsdh.c                 |    1 +
 drivers/net/wireless/broadcom/brcm80211/brcmfmac/cfg80211.c               |   18 +-
 drivers/net/wireless/broadcom/brcm80211/brcmfmac/chip.c                   |    2 +
 drivers/net/wireless/broadcom/brcm80211/brcmfmac/debug.c                  |    5 +-
 drivers/net/wireless/broadcom/brcm80211/brcmfmac/firmware.c               |    3 +
 drivers/net/wireless/broadcom/brcm80211/brcmfmac/pcie.c                   |    2 +-
 drivers/net/wireless/broadcom/brcm80211/brcmfmac/sdio.c                   |    4 +-
 drivers/net/wireless/broadcom/brcm80211/brcmfmac/usb.c                    |   11 +-
 drivers/net/wireless/broadcom/brcm80211/include/brcm_hw_ids.h             |    3 +
 drivers/net/wireless/cisco/airo.c                                         |    2 +-
 drivers/net/wireless/intel/ipw2x00/ipw2100.c                              |   34 +-
 drivers/net/wireless/intel/ipw2x00/ipw2200.c                              |   17 +-
 drivers/net/wireless/intel/iwlegacy/3945-mac.c                            |    2 +-
 drivers/net/wireless/intel/iwlegacy/4965-mac.c                            |    2 +-
 drivers/net/wireless/intel/iwlwifi/Makefile                               |    2 +
 drivers/net/wireless/intel/iwlwifi/cfg/8000.c                             |    4 +-
 drivers/net/wireless/intel/iwlwifi/cfg/9000.c                             |    2 +-
 drivers/net/wireless/intel/iwlwifi/cfg/a000.c                             |   44 +-
 drivers/net/wireless/intel/iwlwifi/dvm/commands.h                         |   24 +-
 drivers/net/wireless/intel/iwlwifi/fw/api/alive.h                         |  206 ++++
 drivers/net/wireless/intel/iwlwifi/fw/api/binding.h                       |  144 +++
 drivers/net/wireless/intel/iwlwifi/fw/{api.h => api/cmdhdr.h}             |   78 +-
 drivers/net/wireless/intel/iwlwifi/{mvm/fw-api-coex.h => fw/api/coex.h}   |   73 +-
 drivers/net/wireless/intel/iwlwifi/fw/api/commands.h                      |  657 ++++++++++++
 drivers/net/wireless/intel/iwlwifi/fw/api/config.h                        |  184 ++++
 drivers/net/wireless/intel/iwlwifi/fw/api/context.h                       |   94 ++
 drivers/net/wireless/intel/iwlwifi/{mvm/fw-api-d3.h => fw/api/d3.h}       |   11 +-
 drivers/net/wireless/intel/iwlwifi/fw/api/datapath.h                      |  127 +++
 drivers/net/wireless/intel/iwlwifi/fw/api/debug.h                         |  345 ++++++
 drivers/net/wireless/intel/iwlwifi/fw/api/filter.h                        |  183 ++++
 drivers/net/wireless/intel/iwlwifi/fw/api/led.h                           |   71 ++
 drivers/net/wireless/intel/iwlwifi/fw/api/mac-cfg.h                       |  152 +++
 drivers/net/wireless/intel/iwlwifi/{mvm/fw-api-mac.h => fw/api/mac.h}     |   33 +-
 drivers/net/wireless/intel/iwlwifi/fw/api/nvm-reg.h                       |  386 +++++++
 drivers/net/wireless/intel/iwlwifi/fw/api/offload.h                       |  101 ++
 drivers/net/wireless/intel/iwlwifi/fw/api/paging.h                        |  108 ++
 drivers/net/wireless/intel/iwlwifi/fw/api/phy-ctxt.h                      |  164 +++
 drivers/net/wireless/intel/iwlwifi/fw/api/phy.h                           |  258 +++++
 drivers/net/wireless/intel/iwlwifi/{mvm/fw-api-power.h => fw/api/power.h} |   13 +-
 drivers/net/wireless/intel/iwlwifi/{mvm/fw-api-rs.h => fw/api/rs.h}       |   13 +-
 drivers/net/wireless/intel/iwlwifi/{mvm/fw-api-rx.h => fw/api/rx.h}       |   31 +-
 drivers/net/wireless/intel/iwlwifi/{mvm/fw-api-scan.h => fw/api/scan.h}   |   11 +-
 drivers/net/wireless/intel/iwlwifi/fw/api/sf.h                            |  138 +++
 drivers/net/wireless/intel/iwlwifi/{mvm/fw-api-sta.h => fw/api/sta.h}     |   15 +-
 drivers/net/wireless/intel/iwlwifi/{mvm/fw-api-stats.h => fw/api/stats.h} |   13 +-
 drivers/net/wireless/intel/iwlwifi/fw/api/tdls.h                          |  208 ++++
 drivers/net/wireless/intel/iwlwifi/fw/api/time-event.h                    |  386 +++++++
 drivers/net/wireless/intel/iwlwifi/{mvm/fw-api-tof.h => fw/api/tof.h}     |    9 +-
 drivers/net/wireless/intel/iwlwifi/{mvm/fw-api-tx.h => fw/api/tx.h}       |   66 +-
 drivers/net/wireless/intel/iwlwifi/fw/api/txq.h                           |  163 +++
 drivers/net/wireless/intel/iwlwifi/fw/common_rx.c                         |   88 ++
 drivers/net/wireless/intel/iwlwifi/{mvm/fw-dbg.c => fw/dbg.c}             |  474 +++++----
 drivers/net/wireless/intel/iwlwifi/{mvm/fw-dbg.h => fw/dbg.h}             |  125 ++-
 drivers/net/wireless/intel/iwlwifi/fw/error-dump.h                        |   30 +
 drivers/net/wireless/intel/iwlwifi/fw/file.h                              |    4 +
 drivers/net/wireless/intel/iwlwifi/fw/init.c                              |   75 ++
 drivers/net/wireless/intel/iwlwifi/fw/notif-wait.c                        |   25 +-
 drivers/net/wireless/intel/iwlwifi/fw/nvm.c                               |  162 +++
 drivers/net/wireless/intel/iwlwifi/fw/paging.c                            |  414 ++++++++
 drivers/net/wireless/intel/iwlwifi/fw/runtime.h                           |  158 +++
 drivers/net/wireless/intel/iwlwifi/fw/smem.c                              |  155 +++
 drivers/net/wireless/intel/iwlwifi/iwl-config.h                           |    3 +
 drivers/net/wireless/intel/iwlwifi/iwl-csr.h                              |   11 +-
 drivers/net/wireless/intel/iwlwifi/iwl-drv.c                              |   36 +-
 drivers/net/wireless/intel/iwlwifi/iwl-io.c                               |   14 +-
 drivers/net/wireless/intel/iwlwifi/iwl-nvm-parse.c                        |  123 ++-
 drivers/net/wireless/intel/iwlwifi/iwl-nvm-parse.h                        |    5 +-
 drivers/net/wireless/intel/iwlwifi/iwl-prph.h                             |   13 +-
 drivers/net/wireless/intel/iwlwifi/iwl-trans.h                            |    3 +-
 drivers/net/wireless/intel/iwlwifi/mvm/Makefile                           |    2 +-
 drivers/net/wireless/intel/iwlwifi/mvm/coex.c                             |  310 +-----
 drivers/net/wireless/intel/iwlwifi/mvm/constants.h                        |    4 +-
 drivers/net/wireless/intel/iwlwifi/mvm/debugfs-vif.c                      |    2 +-
 drivers/net/wireless/intel/iwlwifi/mvm/debugfs.c                          |   75 +-
 drivers/net/wireless/intel/iwlwifi/mvm/fw-api.h                           | 2846 +------------------------------------------------
 drivers/net/wireless/intel/iwlwifi/mvm/fw.c                               |  553 ++--------
 drivers/net/wireless/intel/iwlwifi/mvm/led.c                              |   59 +-
 drivers/net/wireless/intel/iwlwifi/mvm/mac-ctxt.c                         |  413 +++-----
 drivers/net/wireless/intel/iwlwifi/mvm/mac80211.c                         |  217 ++--
 drivers/net/wireless/intel/iwlwifi/mvm/mvm.h                              |  158 +--
 drivers/net/wireless/intel/iwlwifi/mvm/nvm.c                              |  200 +---
 drivers/net/wireless/intel/iwlwifi/mvm/ops.c                              |  157 +--
 drivers/net/wireless/intel/iwlwifi/mvm/phy-ctxt.c                         |    2 +-
 drivers/net/wireless/intel/iwlwifi/mvm/power.c                            |   25 +-
 drivers/net/wireless/intel/iwlwifi/mvm/rs.c                               |  142 +--
 drivers/net/wireless/intel/iwlwifi/mvm/rx.c                               |   11 +-
 drivers/net/wireless/intel/iwlwifi/mvm/rxmq.c                             |    9 +-
 drivers/net/wireless/intel/iwlwifi/mvm/scan.c                             |    4 +-
 drivers/net/wireless/intel/iwlwifi/mvm/sta.c                              |  558 +++-------
 drivers/net/wireless/intel/iwlwifi/mvm/sta.h                              |   25 +-
 drivers/net/wireless/intel/iwlwifi/mvm/time-event.c                       |   54 +-
 drivers/net/wireless/intel/iwlwifi/mvm/tof.c                              |    2 +-
 drivers/net/wireless/intel/iwlwifi/mvm/tof.h                              |    2 +-
 drivers/net/wireless/intel/iwlwifi/mvm/tt.c                               |   10 +-
 drivers/net/wireless/intel/iwlwifi/mvm/tx.c                               |  164 +--
 drivers/net/wireless/intel/iwlwifi/mvm/utils.c                            |   18 +-
 drivers/net/wireless/intel/iwlwifi/pcie/ctxt-info.c                       |    2 +-
 drivers/net/wireless/intel/iwlwifi/pcie/drv.c                             |   28 +-
 drivers/net/wireless/intel/iwlwifi/pcie/internal.h                        |   17 +-
 drivers/net/wireless/intel/iwlwifi/pcie/rx.c                              |    2 +-
 drivers/net/wireless/intel/iwlwifi/pcie/trans-gen2.c                      |    4 +-
 drivers/net/wireless/intel/iwlwifi/pcie/trans.c                           |   30 +-
 drivers/net/wireless/intel/iwlwifi/pcie/tx-gen2.c                         |   63 +-
 drivers/net/wireless/intel/iwlwifi/pcie/tx.c                              |   22 +-
 drivers/net/wireless/intersil/hostap/hostap_main.c                        |    4 +-
 drivers/net/wireless/intersil/orinoco/orinoco_usb.c                       |    2 +-
 drivers/net/wireless/intersil/p54/p54usb.c                                |    2 +-
 drivers/net/wireless/marvell/libertas/if_usb.c                            |    2 +-
 drivers/net/wireless/marvell/libertas_tf/if_usb.c                         |    2 +-
 drivers/net/wireless/marvell/mwifiex/11n.c                                |    2 +
 drivers/net/wireless/marvell/mwifiex/cfg80211.c                           |   35 +-
 drivers/net/wireless/marvell/mwifiex/cfp.c                                |    4 +-
 drivers/net/wireless/marvell/mwifiex/cmdevt.c                             |   15 +-
 drivers/net/wireless/marvell/mwifiex/debugfs.c                            |    2 -
 drivers/net/wireless/marvell/mwifiex/init.c                               |   32 +-
 drivers/net/wireless/marvell/mwifiex/join.c                               |    2 +-
 drivers/net/wireless/marvell/mwifiex/main.c                               |  173 ++-
 drivers/net/wireless/marvell/mwifiex/main.h                               |   14 +-
 drivers/net/wireless/marvell/mwifiex/pcie.c                               |  126 +--
 drivers/net/wireless/marvell/mwifiex/scan.c                               |   15 +-
 drivers/net/wireless/marvell/mwifiex/sdio.c                               |    3 +-
 drivers/net/wireless/marvell/mwifiex/sta_cmd.c                            |   19 +-
 drivers/net/wireless/marvell/mwifiex/sta_cmdresp.c                        |    5 +-
 drivers/net/wireless/marvell/mwifiex/sta_ioctl.c                          |  121 +--
 drivers/net/wireless/marvell/mwifiex/tdls.c                               |    2 +-
 drivers/net/wireless/marvell/mwifiex/uap_cmd.c                            |   34 +-
 drivers/net/wireless/marvell/mwifiex/usb.c                                |    5 +-
 drivers/net/wireless/mediatek/mt7601u/dma.c                               |    5 +
 drivers/net/wireless/mediatek/mt7601u/usb.c                               |    2 +-
 drivers/net/wireless/quantenna/qtnfmac/Makefile                           |    4 -
 drivers/net/wireless/quantenna/qtnfmac/bus.h                              |    1 -
 drivers/net/wireless/quantenna/qtnfmac/cfg80211.c                         |  315 ++++--
 drivers/net/wireless/quantenna/qtnfmac/cfg80211.h                         |    4 +
 drivers/net/wireless/quantenna/qtnfmac/commands.c                         |  486 ++++++++-
 drivers/net/wireless/quantenna/qtnfmac/commands.h                         |    5 +
 drivers/net/wireless/quantenna/qtnfmac/core.c                             |    5 +
 drivers/net/wireless/quantenna/qtnfmac/core.h                             |   27 +-
 drivers/net/wireless/quantenna/qtnfmac/event.c                            |   67 +-
 drivers/net/wireless/quantenna/qtnfmac/pearl/pcie.c                       |  408 ++++---
 drivers/net/wireless/quantenna/qtnfmac/pearl/pcie_bus_priv.h              |   15 +-
 drivers/net/wireless/quantenna/qtnfmac/pearl/pcie_ipc.h                   |   11 +-
 drivers/net/wireless/quantenna/qtnfmac/pearl/pcie_regs_pearl.h            |    2 +
 drivers/net/wireless/quantenna/qtnfmac/qlink.h                            |  202 +++-
 drivers/net/wireless/quantenna/qtnfmac/qlink_util.c                       |   26 +-
 drivers/net/wireless/quantenna/qtnfmac/qlink_util.h                       |   10 +-
 drivers/net/wireless/ralink/rt2x00/rt2500usb.c                            |    2 +-
 drivers/net/wireless/ralink/rt2x00/rt2800lib.c                            |    5 +-
 drivers/net/wireless/ralink/rt2x00/rt2800mmio.c                           |   13 +-
 drivers/net/wireless/ralink/rt2x00/rt2800usb.c                            |   17 +-
 drivers/net/wireless/ralink/rt2x00/rt73usb.c                              |    2 +-
 drivers/net/wireless/realtek/rtl818x/rtl8187/dev.c                        |    2 +-
 drivers/net/wireless/realtek/rtl8xxxu/rtl8xxxu_core.c                     |    2 +-
 drivers/net/wireless/realtek/rtlwifi/base.c                               |   22 +-
 drivers/net/wireless/realtek/rtlwifi/base.h                               |    2 +
 drivers/net/wireless/realtek/rtlwifi/btcoexist/halbt_precomp.h            |   16 -
 drivers/net/wireless/realtek/rtlwifi/btcoexist/halbtc8723b1ant.c          |   10 +-
 drivers/net/wireless/realtek/rtlwifi/btcoexist/halbtcoutsrc.c             |   17 +-
 drivers/net/wireless/realtek/rtlwifi/btcoexist/rtl_btc.c                  |   28 +
 drivers/net/wireless/realtek/rtlwifi/btcoexist/rtl_btc.h                  |    1 +
 drivers/net/wireless/realtek/rtlwifi/core.c                               |    2 +
 drivers/net/wireless/realtek/rtlwifi/pci.c                                |    4 +-
 drivers/net/wireless/realtek/rtlwifi/rc.c                                 |    2 +-
 drivers/net/wireless/realtek/rtlwifi/rtl8188ee/sw.c                       |    4 +-
 drivers/net/wireless/realtek/rtlwifi/rtl8192ce/sw.c                       |    2 +
 drivers/net/wireless/realtek/rtlwifi/rtl8192cu/hw.c                       |    5 -
 drivers/net/wireless/realtek/rtlwifi/rtl8192cu/mac.c                      |    3 +-
 drivers/net/wireless/realtek/rtlwifi/rtl8192cu/sw.c                       |    8 +-
 drivers/net/wireless/realtek/rtlwifi/rtl8192cu/trx.c                      |   12 -
 drivers/net/wireless/realtek/rtlwifi/rtl8192cu/trx.h                      |    3 -
 drivers/net/wireless/realtek/rtlwifi/rtl8192de/sw.c                       |    4 +-
 drivers/net/wireless/realtek/rtlwifi/rtl8192ee/fw.c                       |    9 +-
 drivers/net/wireless/realtek/rtlwifi/rtl8192ee/hw.c                       |    5 +
 drivers/net/wireless/realtek/rtlwifi/rtl8192ee/sw.c                       |    4 +-
 drivers/net/wireless/realtek/rtlwifi/rtl8192ee/trx.c                      |    6 -
 drivers/net/wireless/realtek/rtlwifi/rtl8192se/sw.c                       |    4 +-
 drivers/net/wireless/realtek/rtlwifi/rtl8723ae/sw.c                       |    4 +-
 drivers/net/wireless/realtek/rtlwifi/rtl8723be/dm.c                       |    8 +-
 drivers/net/wireless/realtek/rtlwifi/rtl8723be/fw.c                       |    9 +-
 drivers/net/wireless/realtek/rtlwifi/rtl8723be/hw.c                       |    7 +
 drivers/net/wireless/realtek/rtlwifi/rtl8723be/phy.c                      |  365 +++----
 drivers/net/wireless/realtek/rtlwifi/rtl8723be/sw.c                       |   17 +-
 drivers/net/wireless/realtek/rtlwifi/rtl8723be/table.c                    |  192 ++--
 drivers/net/wireless/realtek/rtlwifi/rtl8723be/table.h                    |   10 +-
 drivers/net/wireless/realtek/rtlwifi/rtl8821ae/fw.c                       |   15 +-
 drivers/net/wireless/realtek/rtlwifi/rtl8821ae/hw.c                       |   43 +-
 drivers/net/wireless/realtek/rtlwifi/rtl8821ae/phy.c                      |    5 +-
 drivers/net/wireless/realtek/rtlwifi/rtl8821ae/sw.c                       |   21 +-
 drivers/net/wireless/realtek/rtlwifi/wifi.h                               |   49 +-
 drivers/net/wireless/rsi/Makefile                                         |    1 +
 drivers/net/wireless/rsi/rsi_91x_core.c                                   |   80 +-
 drivers/net/wireless/rsi/rsi_91x_debugfs.c                                |    3 +
 drivers/net/wireless/rsi/rsi_91x_hal.c                                    |  368 +++++--
 drivers/net/wireless/rsi/rsi_91x_mac80211.c                               |  495 +++++++--
 drivers/net/wireless/rsi/rsi_91x_main.c                                   |    5 +-
 drivers/net/wireless/rsi/rsi_91x_mgmt.c                                   |  741 ++++++++-----
 drivers/net/wireless/rsi/rsi_91x_ps.c                                     |  146 +++
 drivers/net/wireless/rsi/rsi_91x_sdio.c                                   |  157 ++-
 drivers/net/wireless/rsi/rsi_91x_sdio_ops.c                               |   84 +-
 drivers/net/wireless/rsi/rsi_91x_usb.c                                    |  138 ++-
 drivers/net/wireless/rsi/rsi_91x_usb_ops.c                                |    6 +-
 drivers/net/wireless/rsi/rsi_common.h                                     |    1 +
 drivers/net/wireless/rsi/rsi_hal.h                                        |   66 ++
 drivers/net/wireless/rsi/rsi_main.h                                       |   88 +-
 drivers/net/wireless/rsi/rsi_mgmt.h                                       |  258 ++++-
 drivers/net/wireless/rsi/rsi_ps.h                                         |   64 ++
 drivers/net/wireless/rsi/rsi_sdio.h                                       |    7 +-
 drivers/net/wireless/rsi/rsi_usb.h                                        |    6 +-
 drivers/net/wireless/ti/wlcore/main.c                                     |   23 +
 drivers/net/wireless/ti/wlcore/sdio.c                                     |    1 +
 drivers/net/wireless/ti/wlcore/spi.c                                      |    1 +
 drivers/net/wireless/ti/wlcore/sysfs.c                                    |    2 +-
 drivers/net/wireless/ti/wlcore/wlcore.h                                   |    3 +
 drivers/net/wireless/wl3501_cs.c                                          |    2 +-
 drivers/net/wireless/zydas/zd1201.c                                       |    2 +-
 drivers/net/wireless/zydas/zd1211rw/zd_rf_rf2959.c                        |    2 +-
 drivers/net/wireless/zydas/zd1211rw/zd_usb.c                              |    2 +-
 drivers/net/xen-netback/interface.c                                       |    4 +-
 drivers/net/xen-netfront.c                                                |    2 +-
 drivers/of/of_mdio.c                                                      |   39 +-
 drivers/phy/marvell/Kconfig                                               |   11 +
 drivers/phy/marvell/Makefile                                              |    1 +
 drivers/phy/marvell/phy-mvebu-cp110-comphy.c                              |  644 +++++++++++
 drivers/ptp/ptp_dte.c                                                     |    2 +-
 drivers/ptp/ptp_ixp46x.c                                                  |    2 +-
 drivers/ptp/ptp_kvm.c                                                     |    2 +-
 drivers/ptp/ptp_pch.c                                                     |    2 +-
 drivers/s390/net/ctcm_main.c                                              |    2 +-
 drivers/s390/net/lcs.c                                                    |   28 +-
 drivers/s390/net/netiucv.c                                                |    4 +-
 drivers/s390/net/qeth_core.h                                              |   17 +-
 drivers/s390/net/qeth_core_main.c                                         |  205 ++--
 drivers/s390/net/qeth_core_sys.c                                          |    2 +-
 drivers/s390/net/qeth_l2_main.c                                           |  343 +++---
 drivers/s390/net/qeth_l3_main.c                                           |   67 +-
 drivers/s390/net/qeth_l3_sys.c                                            |   17 +
 drivers/staging/Kconfig                                                   |    2 +
 drivers/staging/Makefile                                                  |    2 +
 drivers/staging/irda/TODO                                                 |    4 +
 drivers/{net/irda => staging/irda/drivers}/Kconfig                        |    0
 drivers/{net/irda => staging/irda/drivers}/Makefile                       |    2 +
 drivers/{net/irda => staging/irda/drivers}/act200l-sir.c                  |    0
 drivers/{net/irda => staging/irda/drivers}/actisys-sir.c                  |    0
 drivers/{net/irda => staging/irda/drivers}/ali-ircc.c                     |    0
 drivers/{net/irda => staging/irda/drivers}/ali-ircc.h                     |    0
 drivers/{net/irda => staging/irda/drivers}/au1k_ir.c                      |    0
 drivers/{net/irda => staging/irda/drivers}/bfin_sir.c                     |    0
 drivers/{net/irda => staging/irda/drivers}/bfin_sir.h                     |    0
 drivers/{net/irda => staging/irda/drivers}/donauboe.c                     |    0
 drivers/{net/irda => staging/irda/drivers}/donauboe.h                     |    0
 drivers/{net/irda => staging/irda/drivers}/esi-sir.c                      |    0
 drivers/{net/irda => staging/irda/drivers}/girbil-sir.c                   |    0
 drivers/{net/irda => staging/irda/drivers}/irda-usb.c                     |    2 +-
 drivers/{net/irda => staging/irda/drivers}/irda-usb.h                     |    0
 drivers/{net/irda => staging/irda/drivers}/irtty-sir.c                    |    0
 drivers/{net/irda => staging/irda/drivers}/irtty-sir.h                    |    0
 drivers/{net/irda => staging/irda/drivers}/kingsun-sir.c                  |    2 +-
 drivers/{net/irda => staging/irda/drivers}/ks959-sir.c                    |    2 +-
 drivers/{net/irda => staging/irda/drivers}/ksdazzle-sir.c                 |    2 +-
 drivers/{net/irda => staging/irda/drivers}/litelink-sir.c                 |    0
 drivers/{net/irda => staging/irda/drivers}/ma600-sir.c                    |    0
 drivers/{net/irda => staging/irda/drivers}/mcp2120-sir.c                  |    0
 drivers/{net/irda => staging/irda/drivers}/mcs7780.c                      |    2 +-
 drivers/{net/irda => staging/irda/drivers}/mcs7780.h                      |    0
 drivers/{net/irda => staging/irda/drivers}/nsc-ircc.c                     |    0
 drivers/{net/irda => staging/irda/drivers}/nsc-ircc.h                     |    0
 drivers/{net/irda => staging/irda/drivers}/old_belkin-sir.c               |    0
 drivers/{net/irda => staging/irda/drivers}/pxaficp_ir.c                   |    0
 drivers/{net/irda => staging/irda/drivers}/sa1100_ir.c                    |    0
 drivers/{net/irda => staging/irda/drivers}/sh_sir.c                       |    0
 drivers/{net/irda => staging/irda/drivers}/sir-dev.h                      |    0
 drivers/{net/irda => staging/irda/drivers}/sir_dev.c                      |    0
 drivers/{net/irda => staging/irda/drivers}/sir_dongle.c                   |    0
 drivers/{net/irda => staging/irda/drivers}/smsc-ircc2.c                   |    0
 drivers/{net/irda => staging/irda/drivers}/smsc-ircc2.h                   |    0
 drivers/{net/irda => staging/irda/drivers}/smsc-sio.h                     |    0
 drivers/{net/irda => staging/irda/drivers}/stir4200.c                     |    2 +-
 drivers/{net/irda => staging/irda/drivers}/tekram-sir.c                   |    0
 drivers/{net/irda => staging/irda/drivers}/toim3232-sir.c                 |    0
 drivers/{net/irda => staging/irda/drivers}/via-ircc.c                     |    0
 drivers/{net/irda => staging/irda/drivers}/via-ircc.h                     |    0
 drivers/{net/irda => staging/irda/drivers}/vlsi_ir.c                      |    0
 drivers/{net/irda => staging/irda/drivers}/vlsi_ir.h                      |    0
 drivers/{net/irda => staging/irda/drivers}/w83977af.h                     |    0
 drivers/{net/irda => staging/irda/drivers}/w83977af_ir.c                  |    0
 drivers/{net/irda => staging/irda/drivers}/w83977af_ir.h                  |    0
 {include => drivers/staging/irda/include}/net/irda/af_irda.h              |    0
 {include => drivers/staging/irda/include}/net/irda/crc.h                  |    0
 {include => drivers/staging/irda/include}/net/irda/discovery.h            |    0
 {include => drivers/staging/irda/include}/net/irda/ircomm_core.h          |    0
 {include => drivers/staging/irda/include}/net/irda/ircomm_event.h         |    0
 {include => drivers/staging/irda/include}/net/irda/ircomm_lmp.h           |    0
 {include => drivers/staging/irda/include}/net/irda/ircomm_param.h         |    0
 {include => drivers/staging/irda/include}/net/irda/ircomm_ttp.h           |    0
 {include => drivers/staging/irda/include}/net/irda/ircomm_tty.h           |    0
 {include => drivers/staging/irda/include}/net/irda/ircomm_tty_attach.h    |    0
 {include => drivers/staging/irda/include}/net/irda/irda.h                 |    0
 {include => drivers/staging/irda/include}/net/irda/irda_device.h          |    0
 {include => drivers/staging/irda/include}/net/irda/iriap.h                |    0
 {include => drivers/staging/irda/include}/net/irda/iriap_event.h          |    0
 {include => drivers/staging/irda/include}/net/irda/irias_object.h         |    0
 {include => drivers/staging/irda/include}/net/irda/irlan_client.h         |    0
 {include => drivers/staging/irda/include}/net/irda/irlan_common.h         |    0
 {include => drivers/staging/irda/include}/net/irda/irlan_eth.h            |    0
 {include => drivers/staging/irda/include}/net/irda/irlan_event.h          |    0
 {include => drivers/staging/irda/include}/net/irda/irlan_filter.h         |    0
 {include => drivers/staging/irda/include}/net/irda/irlan_provider.h       |    0
 {include => drivers/staging/irda/include}/net/irda/irlap.h                |    0
 {include => drivers/staging/irda/include}/net/irda/irlap_event.h          |    0
 {include => drivers/staging/irda/include}/net/irda/irlap_frame.h          |    0
 {include => drivers/staging/irda/include}/net/irda/irlmp.h                |    0
 {include => drivers/staging/irda/include}/net/irda/irlmp_event.h          |    0
 {include => drivers/staging/irda/include}/net/irda/irlmp_frame.h          |    0
 {include => drivers/staging/irda/include}/net/irda/irmod.h                |    0
 {include => drivers/staging/irda/include}/net/irda/irqueue.h              |    0
 {include => drivers/staging/irda/include}/net/irda/irttp.h                |    0
 {include => drivers/staging/irda/include}/net/irda/parameters.h           |    0
 {include => drivers/staging/irda/include}/net/irda/qos.h                  |    0
 {include => drivers/staging/irda/include}/net/irda/timer.h                |    0
 {include => drivers/staging/irda/include}/net/irda/wrapper.h              |    0
 {net/irda => drivers/staging/irda/net}/Kconfig                            |    8 +-
 {net/irda => drivers/staging/irda/net}/Makefile                           |    2 +
 {net/irda => drivers/staging/irda/net}/af_irda.c                          |    0
 {net/irda => drivers/staging/irda/net}/discovery.c                        |    0
 {net/irda => drivers/staging/irda/net}/ircomm/Kconfig                     |    0
 {net/irda => drivers/staging/irda/net}/ircomm/Makefile                    |    0
 {net/irda => drivers/staging/irda/net}/ircomm/ircomm_core.c               |    0
 {net/irda => drivers/staging/irda/net}/ircomm/ircomm_event.c              |    0
 {net/irda => drivers/staging/irda/net}/ircomm/ircomm_lmp.c                |    0
 {net/irda => drivers/staging/irda/net}/ircomm/ircomm_param.c              |    0
 {net/irda => drivers/staging/irda/net}/ircomm/ircomm_ttp.c                |    0
 {net/irda => drivers/staging/irda/net}/ircomm/ircomm_tty.c                |    0
 {net/irda => drivers/staging/irda/net}/ircomm/ircomm_tty_attach.c         |    0
 {net/irda => drivers/staging/irda/net}/ircomm/ircomm_tty_ioctl.c          |    0
 {net/irda => drivers/staging/irda/net}/irda_device.c                      |    0
 {net/irda => drivers/staging/irda/net}/iriap.c                            |    0
 {net/irda => drivers/staging/irda/net}/iriap_event.c                      |    0
 {net/irda => drivers/staging/irda/net}/irias_object.c                     |    0
 {net/irda => drivers/staging/irda/net}/irlan/Kconfig                      |    0
 {net/irda => drivers/staging/irda/net}/irlan/Makefile                     |    0
 {net/irda => drivers/staging/irda/net}/irlan/irlan_client.c               |    0
 {net/irda => drivers/staging/irda/net}/irlan/irlan_client_event.c         |    0
 {net/irda => drivers/staging/irda/net}/irlan/irlan_common.c               |    0
 {net/irda => drivers/staging/irda/net}/irlan/irlan_eth.c                  |    0
 {net/irda => drivers/staging/irda/net}/irlan/irlan_event.c                |    0
 {net/irda => drivers/staging/irda/net}/irlan/irlan_filter.c               |    0
 {net/irda => drivers/staging/irda/net}/irlan/irlan_provider.c             |    0
 {net/irda => drivers/staging/irda/net}/irlan/irlan_provider_event.c       |    0
 {net/irda => drivers/staging/irda/net}/irlap.c                            |    0
 {net/irda => drivers/staging/irda/net}/irlap_event.c                      |    0
 {net/irda => drivers/staging/irda/net}/irlap_frame.c                      |    0
 {net/irda => drivers/staging/irda/net}/irlmp.c                            |    0
 {net/irda => drivers/staging/irda/net}/irlmp_event.c                      |    0
 {net/irda => drivers/staging/irda/net}/irlmp_frame.c                      |    0
 {net/irda => drivers/staging/irda/net}/irmod.c                            |    2 +-
 {net/irda => drivers/staging/irda/net}/irnet/Kconfig                      |    0
 {net/irda => drivers/staging/irda/net}/irnet/Makefile                     |    0
 {net/irda => drivers/staging/irda/net}/irnet/irnet.h                      |    0
 {net/irda => drivers/staging/irda/net}/irnet/irnet_irda.c                 |    0
 {net/irda => drivers/staging/irda/net}/irnet/irnet_irda.h                 |    0
 {net/irda => drivers/staging/irda/net}/irnet/irnet_ppp.c                  |    0
 {net/irda => drivers/staging/irda/net}/irnet/irnet_ppp.h                  |    0
 {net/irda => drivers/staging/irda/net}/irnetlink.c                        |    0
 {net/irda => drivers/staging/irda/net}/irproc.c                           |    0
 {net/irda => drivers/staging/irda/net}/irqueue.c                          |    0
 {net/irda => drivers/staging/irda/net}/irsysctl.c                         |    0
 {net/irda => drivers/staging/irda/net}/irttp.c                            |    0
 {net/irda => drivers/staging/irda/net}/parameters.c                       |    0
 {net/irda => drivers/staging/irda/net}/qos.c                              |    0
 {net/irda => drivers/staging/irda/net}/timer.c                            |    0
 {net/irda => drivers/staging/irda/net}/wrapper.c                          |    0
 drivers/vhost/net.c                                                       |    8 +-
 drivers/virtio/virtio_ring.c                                              |    2 +-
 fs/afs/misc.c                                                             |    1 -
 fs/afs/rxrpc.c                                                            |   47 +-
 include/keys/rxrpc-type.h                                                 |   23 +
 include/linux/avf/virtchnl.h                                              |    9 +-
 include/linux/bpf.h                                                       |   93 +-
 include/linux/bpf_types.h                                                 |    7 +
 include/linux/bpf_verifier.h                                              |   78 +-
 include/linux/ethtool.h                                                   |   15 +
 include/linux/filter.h                                                    |   17 +
 include/linux/hyperv.h                                                    |   21 -
 include/linux/idr.h                                                       |   69 +-
 include/linux/igmp.h                                                      |    3 +-
 include/linux/inet_diag.h                                                 |    7 +
 include/linux/ipv6.h                                                      |   10 +
 include/linux/mdio-mux.h                                                  |    9 +
 include/linux/mlx4/device.h                                               |   16 +-
 include/linux/mlx5/device.h                                               |    4 +-
 include/linux/mlx5/driver.h                                               |    7 +-
 include/linux/mlx5/mlx5_ifc.h                                             |   53 +-
 include/linux/mmc/sdio_ids.h                                              |    1 +
 include/linux/net.h                                                       |   12 +
 include/linux/netdev_features.h                                           |    6 +-
 include/linux/netdevice.h                                                 |   67 +-
 include/linux/netfilter.h                                                 |   45 +-
 include/linux/netfilter/xt_hashlimit.h                                    |    3 +-
 include/linux/netfilter_ingress.h                                         |    4 +-
 include/linux/phy.h                                                       |   21 +
 include/linux/phy/phy.h                                                   |    2 +
 include/linux/phylink.h                                                   |  148 +++
 include/linux/platform_data/mdio-bcm-unimac.h                             |   13 +
 include/linux/qed/qed_eth_if.h                                            |    1 +
 include/linux/qed/qed_if.h                                                |   37 +-
 include/linux/radix-tree.h                                                |   21 +-
 include/linux/sched/user.h                                                |    3 +-
 include/linux/sctp.h                                                      |  171 ++-
 include/linux/seg6_local.h                                                |    6 +
 include/linux/sfp.h                                                       |  434 ++++++++
 include/linux/skbuff.h                                                    |  201 +++-
 include/linux/soc/ti/knav_dma.h                                           |    2 +
 include/linux/socket.h                                                    |    1 +
 include/linux/syscalls.h                                                  |   12 +
 include/linux/tcp.h                                                       |   11 +-
 include/linux/tnum.h                                                      |   81 ++
 include/linux/virtio_net.h                                                |    5 -
 include/net/act_api.h                                                     |   76 +-
 include/net/af_rxrpc.h                                                    |   21 +-
 include/net/af_unix.h                                                     |    1 -
 include/net/bluetooth/bluetooth.h                                         |    2 +-
 include/net/devlink.h                                                     |   19 +-
 include/net/dsa.h                                                         |   53 +-
 include/net/dst.h                                                         |    3 +-
 include/net/erspan.h                                                      |   61 ++
 include/net/fib_notifier.h                                                |   46 +
 include/net/fib_rules.h                                                   |    9 +
 include/net/flow.h                                                        |   35 +-
 include/net/flow_dissector.h                                              |    8 +
 include/net/flowcache.h                                                   |   25 -
 include/net/inet6_hashtables.h                                            |   22 +-
 include/net/inet_frag.h                                                   |   35 +-
 include/net/inet_hashtables.h                                             |   31 +-
 include/net/inetpeer.h                                                    |   11 +-
 include/net/ip.h                                                          |   19 +-
 include/net/ip6_fib.h                                                     |   53 +
 include/net/ip6_route.h                                                   |   13 +-
 include/net/ip_fib.h                                                      |   67 +-
 include/net/ip_tunnels.h                                                  |    7 +-
 include/net/ncsi.h                                                        |   12 +
 include/net/net_namespace.h                                               |    1 +
 include/net/netfilter/nf_conntrack.h                                      |   11 +-
 include/net/netfilter/nf_conntrack_expect.h                               |    5 +
 include/net/netfilter/nf_conntrack_l3proto.h                              |   45 +-
 include/net/netfilter/nf_conntrack_l4proto.h                              |   37 +-
 include/net/netfilter/nf_conntrack_timeout.h                              |    4 +-
 include/net/netfilter/nf_queue.h                                          |    2 +-
 include/net/netfilter/nf_tables.h                                         |   45 +-
 include/net/netfilter/nf_tables_core.h                                    |    2 +
 include/net/netlink.h                                                     |   17 +
 include/net/netns/ipv4.h                                                  |    1 +
 include/net/netns/ipv6.h                                                  |    3 +
 include/net/netns/netfilter.h                                             |    2 +-
 include/net/netns/xfrm.h                                                  |   11 -
 include/net/nsh.h                                                         |  307 ++++++
 include/net/pkt_cls.h                                                     |  145 ++-
 include/net/pkt_sched.h                                                   |   14 +
 include/net/raw.h                                                         |    2 +-
 include/net/rawv6.h                                                       |    2 +-
 include/net/route.h                                                       |    7 +-
 include/net/rtnetlink.h                                                   |    9 +-
 include/net/sch_generic.h                                                 |   17 +-
 include/net/sctp/command.h                                                |   70 +-
 include/net/sctp/constants.h                                              |   89 +-
 include/net/sctp/sctp.h                                                   |   20 +-
 include/net/sctp/sm.h                                                     |  205 ++--
 include/net/sctp/structs.h                                                |   74 +-
 include/net/seg6.h                                                        |    5 +
 include/net/sock.h                                                        |   17 +
 include/net/strparser.h                                                   |  121 ++-
 include/net/switchdev.h                                                   |   87 --
 include/net/tc_act/tc_gact.h                                              |   20 +-
 include/net/tcp.h                                                         |   57 +-
 include/net/tso.h                                                         |    2 +
 include/net/tun_proto.h                                                   |   49 +
 include/net/udp.h                                                         |    4 +-
 include/net/udp_tunnel.h                                                  |    8 +
 include/net/vxlan.h                                                       |    6 -
 include/net/xfrm.h                                                        |   42 +-
 include/trace/events/bridge.h                                             |  129 +++
 include/trace/events/qdisc.h                                              |   50 +
 include/trace/events/xdp.h                                                |  118 ++-
 include/uapi/asm-generic/socket.h                                         |    2 +
 include/uapi/linux/bpf.h                                                  |   74 +-
 include/uapi/linux/devlink.h                                              |   18 +
 include/uapi/linux/errqueue.h                                             |    3 +
 include/uapi/linux/ethtool.h                                              |   48 +-
 include/uapi/linux/if_arp.h                                               |    1 +
 include/uapi/linux/if_ether.h                                             |    6 +
 include/uapi/linux/if_tunnel.h                                            |    1 +
 include/uapi/linux/inet_diag.h                                            |    2 +
 include/uapi/linux/lwtunnel.h                                             |    1 +
 include/uapi/linux/netfilter/nf_tables.h                                  |   20 +-
 include/uapi/linux/netfilter/xt_hashlimit.h                               |   36 +-
 include/uapi/linux/netlink.h                                              |   20 +
 include/uapi/linux/rtnetlink.h                                            |   23 +-
 include/{ => uapi}/linux/rxrpc.h                                          |   57 +-
 include/uapi/linux/seg6_iptunnel.h                                        |   18 +-
 include/uapi/linux/seg6_local.h                                           |   68 ++
 include/uapi/linux/snmp.h                                                 |    7 -
 include/uapi/linux/tcp.h                                                  |   17 +
 include/uapi/linux/xfrm.h                                                 |    1 +
 kernel/bpf/Makefile                                                       |    8 +-
 kernel/bpf/arraymap.c                                                     |   33 +-
 kernel/bpf/bpf_lru_list.h                                                 |    3 +-
 kernel/bpf/core.c                                                         |   61 ++
 kernel/bpf/devmap.c                                                       |  409 +++++++
 kernel/bpf/hashtab.c                                                      |   60 +-
 kernel/bpf/lpm_trie.c                                                     |    9 +-
 kernel/bpf/sockmap.c                                                      |  873 +++++++++++++++
 kernel/bpf/stackmap.c                                                     |    8 +-
 kernel/bpf/syscall.c                                                      |  129 ++-
 kernel/bpf/tnum.c                                                         |  180 ++++
 kernel/bpf/verifier.c                                                     | 2450 +++++++++++++++++++++++++-----------------
 kernel/events/core.c                                                      |   10 +-
 kernel/trace/trace_syscalls.c                                             |   53 +-
 lib/idr.c                                                                 |   66 +-
 lib/nlattr.c                                                              |   54 +
 lib/radix-tree.c                                                          |    6 +-
 lib/test_bpf.c                                                            |  364 +++++++
 net/Kconfig                                                               |   21 +-
 net/Makefile                                                              |    2 +-
 net/atm/clip.c                                                            |    2 +-
 net/atm/lec.c                                                             |    2 +-
 net/atm/mpc.c                                                             |    2 +-
 net/atm/signaling.c                                                       |    2 +-
 net/batman-adv/bat_iv_ogm.c                                               |    6 +-
 net/batman-adv/bat_v_ogm.c                                                |   16 +-
 net/batman-adv/distributed-arp-table.c                                    |    2 +-
 net/batman-adv/main.h                                                     |    2 +-
 net/batman-adv/send.c                                                     |    2 +-
 net/bluetooth/6lowpan.c                                                   |    9 +-
 net/bluetooth/Kconfig                                                     |   22 +
 net/bluetooth/hci_sock.c                                                  |    6 +
 net/bluetooth/hci_sysfs.c                                                 |    4 +-
 net/bluetooth/lib.c                                                       |    6 +-
 net/bluetooth/selftest.c                                                  |    2 +-
 net/bridge/br_device.c                                                    |    4 +-
 net/bridge/br_fdb.c                                                       |   30 +-
 net/bridge/br_mdb.c                                                       |    6 +-
 net/bridge/br_netfilter_hooks.c                                           |   21 +-
 net/bridge/br_private.h                                                   |    9 +
 net/bridge/netfilter/ebt_ip.c                                             |    4 +-
 net/bridge/netfilter/ebt_ip6.c                                            |    2 +-
 net/bridge/netfilter/ebtable_filter.c                                     |    2 +-
 net/bridge/netfilter/ebtable_nat.c                                        |    4 +-
 net/bridge/netfilter/ebtables.c                                           |   33 +-
 net/can/gw.c                                                              |    6 +-
 net/core/Makefile                                                         |    4 +-
 net/core/datagram.c                                                       |   55 +-
 net/core/dev.c                                                            |  307 +++---
 net/core/devlink.c                                                        |   85 +-
 net/core/dst.c                                                            |    9 +-
 net/core/ethtool.c                                                        |   42 +-
 net/core/fib_notifier.c                                                   |  173 +++
 net/core/fib_rules.c                                                      |   69 +-
 net/core/filter.c                                                         |  478 ++++++++-
 net/core/flow.c                                                           |  516 ---------
 net/core/flow_dissector.c                                                 |  301 +++---
 net/core/lwtunnel.c                                                       |   28 +-
 net/core/neighbour.c                                                      |   10 +-
 net/core/net-sysfs.c                                                      |  222 ++--
 net/core/net-traces.c                                                     |    8 +
 net/core/net_namespace.c                                                  |    5 +-
 net/core/rtnetlink.c                                                      |  249 +++--
 net/core/skbuff.c                                                         |  560 ++++++++--
 net/core/sock.c                                                           |   84 +-
 net/dcb/dcbnl.c                                                           |    4 +-
 net/dccp/ipv4.c                                                           |    4 +-
 net/dccp/ipv6.c                                                           |   51 +-
 net/decnet/dn_dev.c                                                       |    6 +-
 net/decnet/dn_fib.c                                                       |    4 +-
 net/decnet/dn_neigh.c                                                     |    2 +-
 net/decnet/dn_route.c                                                     |    4 +-
 net/decnet/netfilter/dn_rtmsg.c                                           |    2 +-
 net/dsa/dsa.c                                                             |   42 +-
 net/dsa/dsa2.c                                                            |    6 +-
 net/dsa/dsa_priv.h                                                        |   44 +-
 net/dsa/legacy.c                                                          |   40 +-
 net/dsa/port.c                                                            |   51 +-
 net/dsa/slave.c                                                           |  419 ++++++--
 net/dsa/switch.c                                                          |   21 +-
 net/dsa/tag_brcm.c                                                        |    6 +-
 net/dsa/tag_dsa.c                                                         |    3 +-
 net/dsa/tag_edsa.c                                                        |    3 +-
 net/dsa/tag_ksz.c                                                         |    3 +-
 net/dsa/tag_lan9303.c                                                     |    5 +-
 net/dsa/tag_mtk.c                                                         |   17 +-
 net/dsa/tag_qca.c                                                         |    3 +-
 net/dsa/tag_trailer.c                                                     |    3 +-
 net/ieee802154/6lowpan/core.c                                             |    2 +-
 net/ieee802154/6lowpan/reassembly.c                                       |   11 +-
 net/ipv4/af_inet.c                                                        |   28 +-
 net/ipv4/arp.c                                                            |    2 +-
 net/ipv4/devinet.c                                                        |    8 +-
 net/ipv4/esp4.c                                                           |   64 +-
 net/ipv4/esp4_offload.c                                                   |    5 +-
 net/ipv4/fib_frontend.c                                                   |   23 +-
 net/ipv4/fib_lookup.h                                                     |    1 +
 net/ipv4/fib_notifier.c                                                   |  101 +-
 net/ipv4/fib_rules.c                                                      |   44 +-
 net/ipv4/fib_semantics.c                                                  |   49 +-
 net/ipv4/fib_trie.c                                                       |    8 +-
 net/ipv4/gre_offload.c                                                    |   14 +-
 net/ipv4/icmp.c                                                           |    4 +-
 net/ipv4/igmp.c                                                           |    6 +-
 net/ipv4/inet_diag.c                                                      |   33 +-
 net/ipv4/inet_fragment.c                                                  |    4 +-
 net/ipv4/inet_hashtables.c                                                |   27 +-
 net/ipv4/inetpeer.c                                                       |  431 ++------
 net/ipv4/ip_fragment.c                                                    |   12 +-
 net/ipv4/ip_gre.c                                                         |  421 +++++++-
 net/ipv4/ip_options.c                                                     |    9 +-
 net/ipv4/ip_output.c                                                      |   92 +-
 net/ipv4/ip_sockglue.c                                                    |   19 +-
 net/ipv4/ip_vti.c                                                         |   31 -
 net/ipv4/ipmr.c                                                           |    8 +-
 net/ipv4/netfilter/arp_tables.c                                           |    2 -
 net/ipv4/netfilter/ip_tables.c                                            |   16 +-
 net/ipv4/netfilter/ipt_CLUSTERIP.c                                        |    2 +-
 net/ipv4/netfilter/ipt_SYNPROXY.c                                         |    2 +-
 net/ipv4/netfilter/iptable_nat.c                                          |    2 +-
 net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c                            |   40 +-
 net/ipv4/netfilter/nf_conntrack_proto_icmp.c                              |   15 +-
 net/ipv4/netfilter/nf_defrag_ipv4.c                                       |    2 +-
 net/ipv4/netfilter/nf_log_arp.c                                           |    2 +-
 net/ipv4/netfilter/nf_log_ipv4.c                                          |    2 +-
 net/ipv4/netfilter/nf_nat_h323.c                                          |   57 +-
 net/ipv4/netfilter/nf_nat_l3proto_ipv4.c                                  |    6 +-
 net/ipv4/netfilter/nf_nat_masquerade_ipv4.c                               |    8 +-
 net/ipv4/netfilter/nft_fib_ipv4.c                                         |   20 +-
 net/ipv4/proc.c                                                           |    7 -
 net/ipv4/raw.c                                                            |   18 +-
 net/ipv4/raw_diag.c                                                       |    4 +-
 net/ipv4/route.c                                                          |   15 +-
 net/ipv4/syncookies.c                                                     |    2 +-
 net/ipv4/sysctl_net_ipv4.c                                                |    3 +
 net/ipv4/tcp.c                                                            |  287 ++---
 net/ipv4/tcp_bic.c                                                        |   14 +-
 net/ipv4/tcp_cdg.c                                                        |   12 +-
 net/ipv4/tcp_cong.c                                                       |    2 +-
 net/ipv4/tcp_cubic.c                                                      |   13 +-
 net/ipv4/tcp_diag.c                                                       |  109 +-
 net/ipv4/tcp_fastopen.c                                                   |    6 +-
 net/ipv4/tcp_highspeed.c                                                  |   11 +-
 net/ipv4/tcp_htcp.c                                                       |    3 +-
 net/ipv4/tcp_illinois.c                                                   |   11 +-
 net/ipv4/tcp_input.c                                                      |  170 ++-
 net/ipv4/tcp_ipv4.c                                                       |   82 +-
 net/ipv4/tcp_minisocks.c                                                  |    1 -
 net/ipv4/tcp_nv.c                                                         |   13 +-
 net/ipv4/tcp_output.c                                                     |   17 +-
 net/ipv4/tcp_probe.c                                                      |    5 +-
 net/ipv4/tcp_recovery.c                                                   |    2 +-
 net/ipv4/tcp_scalable.c                                                   |   16 +-
 net/ipv4/tcp_timer.c                                                      |   12 -
 net/ipv4/tcp_veno.c                                                       |   11 +-
 net/ipv4/tcp_yeah.c                                                       |   11 +-
 net/ipv4/udp.c                                                            |   81 +-
 net/ipv4/udp_diag.c                                                       |   10 +-
 net/ipv4/udp_offload.c                                                    |   64 +-
 net/ipv4/udp_tunnel.c                                                     |   25 +-
 net/ipv4/xfrm4_policy.c                                                   |   25 +-
 net/ipv6/Kconfig                                                          |   16 +-
 net/ipv6/Makefile                                                         |    4 +-
 net/ipv6/addrconf.c                                                       |   60 +-
 net/ipv6/addrlabel.c                                                      |   22 +-
 net/ipv6/af_inet6.c                                                       |    5 +-
 net/ipv6/esp6.c                                                           |   61 +-
 net/ipv6/esp6_offload.c                                                   |    5 +-
 net/ipv6/exthdrs.c                                                        |    4 +-
 net/ipv6/fib6_notifier.c                                                  |   63 ++
 net/ipv6/fib6_rules.c                                                     |   69 +-
 net/ipv6/icmp.c                                                           |   27 +-
 net/ipv6/ila/ila_xlat.c                                                   |    2 +-
 net/ipv6/inet6_hashtables.c                                               |   28 +-
 net/ipv6/ip6_fib.c                                                        |  134 ++-
 net/ipv6/ip6_output.c                                                     |   77 --
 net/ipv6/ip6_vti.c                                                        |   31 -
 net/ipv6/ip6mr.c                                                          |    2 +-
 net/ipv6/ndisc.c                                                          |    3 +-
 net/ipv6/netfilter/ip6_tables.c                                           |   14 +-
 net/ipv6/netfilter/ip6t_SYNPROXY.c                                        |    2 +-
 net/ipv6/netfilter/ip6table_nat.c                                         |    2 +-
 net/ipv6/netfilter/nf_conntrack_l3proto_ipv6.c                            |   42 +-
 net/ipv6/netfilter/nf_conntrack_proto_icmpv6.c                            |   25 +-
 net/ipv6/netfilter/nf_conntrack_reasm.c                                   |   12 +-
 net/ipv6/netfilter/nf_defrag_ipv6_hooks.c                                 |    2 +-
 net/ipv6/netfilter/nf_log_ipv6.c                                          |    2 +-
 net/ipv6/netfilter/nf_nat_l3proto_ipv6.c                                  |    6 +-
 net/ipv6/netfilter/nf_nat_masquerade_ipv6.c                               |    4 +-
 net/ipv6/netfilter/nft_fib_ipv6.c                                         |   29 +-
 net/ipv6/raw.c                                                            |   13 +-
 net/ipv6/reassembly.c                                                     |   12 +-
 net/ipv6/route.c                                                          |  138 ++-
 net/ipv6/seg6.c                                                           |    7 +-
 net/ipv6/seg6_hmac.c                                                      |    7 +-
 net/ipv6/seg6_iptunnel.c                                                  |   82 +-
 net/ipv6/seg6_local.c                                                     |  938 ++++++++++++++++
 net/ipv6/sysctl_net_ipv6.c                                                |    8 +
 net/ipv6/tcp_ipv6.c                                                       |   23 +-
 net/ipv6/udp.c                                                            |   50 +-
 net/ipv6/udp_offload.c                                                    |  100 +-
 net/ipv6/xfrm6_input.c                                                    |    4 +-
 net/ipv6/xfrm6_policy.c                                                   |   20 +-
 net/kcm/kcmproc.c                                                         |   34 +-
 net/kcm/kcmsock.c                                                         |   49 +-
 net/key/af_key.c                                                          |    6 -
 net/l2tp/l2tp_core.c                                                      |   41 +-
 net/l2tp/l2tp_core.h                                                      |    8 +-
 net/l2tp/l2tp_eth.c                                                       |   11 +-
 net/l2tp/l2tp_netlink.c                                                   |    8 +-
 net/l2tp/l2tp_ppp.c                                                       |   19 +-
 net/mpls/af_mpls.c                                                        |    8 +-
 net/ncsi/internal.h                                                       |   11 +
 net/ncsi/ncsi-cmd.c                                                       |   10 +-
 net/ncsi/ncsi-manage.c                                                    |  310 +++++-
 net/ncsi/ncsi-pkt.h                                                       |    2 +-
 net/ncsi/ncsi-rsp.c                                                       |   12 +-
 net/netfilter/Kconfig                                                     |    9 +
 net/netfilter/Makefile                                                    |    1 +
 net/netfilter/core.c                                                      |  351 ++++--
 net/netfilter/ipvs/ip_vs_core.c                                           |   10 +-
 net/netfilter/ipvs/ip_vs_ctl.c                                            |    3 -
 net/netfilter/ipvs/ip_vs_ftp.c                                            |    2 -
 net/netfilter/ipvs/ip_vs_proto_sctp.c                                     |   11 +-
 net/netfilter/ipvs/ip_vs_proto_tcp.c                                      |   10 +-
 net/netfilter/ipvs/ip_vs_proto_udp.c                                      |   10 +-
 net/netfilter/ipvs/ip_vs_xmit.c                                           |   46 +-
 net/netfilter/nf_conntrack_broadcast.c                                    |    2 -
 net/netfilter/nf_conntrack_core.c                                         |   57 +-
 net/netfilter/nf_conntrack_expect.c                                       |   70 +-
 net/netfilter/nf_conntrack_extend.c                                       |    2 +-
 net/netfilter/nf_conntrack_helper.c                                       |   34 +-
 net/netfilter/nf_conntrack_l3proto_generic.c                              |    7 -
 net/netfilter/nf_conntrack_netlink.c                                      |  106 +-
 net/netfilter/nf_conntrack_pptp.c                                         |    2 -
 net/netfilter/nf_conntrack_proto.c                                        |   90 +-
 net/netfilter/nf_conntrack_proto_dccp.c                                   |   20 +-
 net/netfilter/nf_conntrack_proto_generic.c                                |   21 -
 net/netfilter/nf_conntrack_proto_gre.c                                    |   16 +-
 net/netfilter/nf_conntrack_proto_sctp.c                                   |   20 +-
 net/netfilter/nf_conntrack_proto_tcp.c                                    |   20 +-
 net/netfilter/nf_conntrack_proto_udp.c                                    |   18 -
 net/netfilter/nf_conntrack_sip.c                                          |    6 +-
 net/netfilter/nf_conntrack_standalone.c                                   |  103 +-
 net/netfilter/nf_internals.h                                              |   10 +-
 net/netfilter/nf_nat_core.c                                               |    4 +-
 net/netfilter/nf_nat_redirect.c                                           |    6 +-
 net/netfilter/nf_queue.c                                                  |   68 +-
 net/netfilter/nf_sockopt.c                                                |    2 +-
 net/netfilter/nf_tables_api.c                                             |  515 +++++----
 net/netfilter/nf_tables_core.c                                            |   28 +-
 net/netfilter/nf_tables_trace.c                                           |   42 +-
 net/netfilter/nfnetlink_cttimeout.c                                       |   22 +-
 net/netfilter/nfnetlink_log.c                                             |    2 +-
 net/netfilter/nfnetlink_queue.c                                           |   21 +-
 net/netfilter/nft_counter.c                                               |   20 +-
 net/netfilter/nft_ct.c                                                    |   18 +-
 net/netfilter/nft_exthdr.c                                                |  213 +++-
 net/netfilter/nft_fib_netdev.c                                            |   87 ++
 net/netfilter/nft_limit.c                                                 |  148 ++-
 net/netfilter/nft_objref.c                                                |    7 +-
 net/netfilter/nft_payload.c                                               |    2 +-
 net/netfilter/nft_quota.c                                                 |   20 +-
 net/netfilter/nft_rt.c                                                    |   73 +-
 net/netfilter/nft_set_rbtree.c                                            |   49 +-
 net/netfilter/x_tables.c                                                  |   14 +-
 net/netfilter/xt_CT.c                                                     |    2 +-
 net/netfilter/xt_NETMAP.c                                                 |    8 +-
 net/netfilter/xt_TCPMSS.c                                                 |    2 -
 net/netfilter/xt_TPROXY.c                                                 |   10 +-
 net/netfilter/xt_addrtype.c                                               |    3 -
 net/netfilter/xt_connlimit.c                                              |   26 +-
 net/netfilter/xt_hashlimit.c                                              |  285 ++++-
 net/netfilter/xt_nat.c                                                    |   20 +-
 net/netfilter/xt_osf.c                                                    |    2 -
 net/netfilter/xt_recent.c                                                 |    2 +-
 net/nsh/Kconfig                                                           |    9 +
 net/nsh/Makefile                                                          |    1 +
 net/nsh/nsh.c                                                             |   91 ++
 net/openvswitch/conntrack.c                                               |   18 +-
 net/openvswitch/datapath.c                                                |   14 -
 net/openvswitch/flow.c                                                    |   16 +-
 net/openvswitch/flow.h                                                    |    2 +
 net/openvswitch/flow_netlink.c                                            |    2 +-
 net/openvswitch/flow_table.c                                              |    4 +-
 net/packet/af_packet.c                                                    |    2 -
 net/phonet/pn_netlink.c                                                   |   12 +-
 net/qrtr/qrtr.c                                                           |    2 +-
 net/rds/bind.c                                                            |    2 +-
 net/rds/connection.c                                                      |   50 +-
 net/rds/rds.h                                                             |    4 +-
 net/rds/send.c                                                            |    4 +-
 net/rds/tcp.c                                                             |    2 +-
 net/rds/tcp_connect.c                                                     |    4 +-
 net/rds/tcp_send.c                                                        |    2 +-
 net/rds/threads.c                                                         |    2 +-
 net/rxrpc/af_rxrpc.c                                                      |   75 +-
 net/rxrpc/ar-internal.h                                                   |   27 +-
 net/rxrpc/call_accept.c                                                   |    2 +-
 net/rxrpc/call_object.c                                                   |  102 +-
 net/rxrpc/conn_client.c                                                   |   17 +-
 net/rxrpc/conn_object.c                                                   |    2 +-
 net/rxrpc/conn_service.c                                                  |    3 +-
 net/rxrpc/key.c                                                           |   22 +-
 net/rxrpc/local_event.c                                                   |    2 +-
 net/rxrpc/output.c                                                        |    2 +-
 net/rxrpc/peer_event.c                                                    |    6 +-
 include/rxrpc/packet.h => net/rxrpc/protocol.h                            |   45 -
 net/rxrpc/rxkad.c                                                         |   22 +-
 net/rxrpc/sendmsg.c                                                       |   62 +-
 net/rxrpc/utils.c                                                         |   23 +-
 net/sched/act_api.c                                                       |  321 +++---
 net/sched/act_bpf.c                                                       |   17 +-
 net/sched/act_connmark.c                                                  |   16 +-
 net/sched/act_csum.c                                                      |   22 +-
 net/sched/act_gact.c                                                      |   16 +-
 net/sched/act_ife.c                                                       |   35 +-
 net/sched/act_ipt.c                                                       |   26 +-
 net/sched/act_mirred.c                                                    |   19 +-
 net/sched/act_nat.c                                                       |   16 +-
 net/sched/act_pedit.c                                                     |   18 +-
 net/sched/act_police.c                                                    |   18 +-
 net/sched/act_sample.c                                                    |   17 +-
 net/sched/act_simple.c                                                    |   20 +-
 net/sched/act_skbedit.c                                                   |   18 +-
 net/sched/act_skbmod.c                                                    |   18 +-
 net/sched/act_tunnel_key.c                                                |   20 +-
 net/sched/act_vlan.c                                                      |   22 +-
 net/sched/cls_api.c                                                       |  228 ++--
 net/sched/cls_basic.c                                                     |   48 +-
 net/sched/cls_bpf.c                                                       |   99 +-
 net/sched/cls_cgroup.c                                                    |   30 +-
 net/sched/cls_flow.c                                                      |   71 +-
 net/sched/cls_flower.c                                                    |  163 ++-
 net/sched/cls_fw.c                                                        |   69 +-
 net/sched/cls_matchall.c                                                  |   74 +-
 net/sched/cls_route.c                                                     |   67 +-
 net/sched/cls_rsvp.h                                                      |   37 +-
 net/sched/cls_tcindex.c                                                   |   53 +-
 net/sched/cls_u32.c                                                       |  213 ++--
 net/sched/sch_api.c                                                       |  520 +++++----
 net/sched/sch_atm.c                                                       |   42 +-
 net/sched/sch_cbq.c                                                       |   44 +-
 net/sched/sch_drr.c                                                       |   33 +-
 net/sched/sch_dsmark.c                                                    |   17 +-
 net/sched/sch_fq_codel.c                                                  |    9 +-
 net/sched/sch_generic.c                                                   |    8 +-
 net/sched/sch_hfsc.c                                                      |   81 +-
 net/sched/sch_htb.c                                                       |   36 +-
 net/sched/sch_ingress.c                                                   |   32 +-
 net/sched/sch_mq.c                                                        |    9 +-
 net/sched/sch_mqprio.c                                                    |   25 +-
 net/sched/sch_multiq.c                                                    |   11 +-
 net/sched/sch_netem.c                                                     |    9 +-
 net/sched/sch_prio.c                                                      |   11 +-
 net/sched/sch_qfq.c                                                       |   33 +-
 net/sched/sch_red.c                                                       |    9 +-
 net/sched/sch_sfb.c                                                       |    9 +-
 net/sched/sch_sfq.c                                                       |   29 +-
 net/sched/sch_tbf.c                                                       |    9 +-
 net/sctp/associola.c                                                      |   21 +-
 net/sctp/auth.c                                                           |   13 +-
 net/sctp/bind_addr.c                                                      |   20 +-
 net/sctp/chunk.c                                                          |    4 +-
 net/sctp/debug.c                                                          |    8 +-
 net/sctp/endpointola.c                                                    |   12 +-
 net/sctp/input.c                                                          |    2 +-
 net/sctp/ipv6.c                                                           |    8 +-
 net/sctp/objcnt.c                                                         |    2 +-
 net/sctp/output.c                                                         |   60 +-
 net/sctp/outqueue.c                                                       |   20 +-
 net/sctp/primitive.c                                                      |    4 +-
 net/sctp/probe.c                                                          |   13 +-
 net/sctp/protocol.c                                                       |    8 +-
 net/sctp/sm_make_chunk.c                                                  |  524 +++++----
 net/sctp/sm_sideeffect.c                                                  |  154 +--
 net/sctp/sm_statefuns.c                                                   | 1555 ++++++++++++++-------------
 net/sctp/sm_statetable.c                                                  |   59 +-
 net/sctp/socket.c                                                         |   20 +-
 net/sctp/sysctl.c                                                         |    2 +-
 net/sctp/transport.c                                                      |    2 +-
 net/sctp/ulpevent.c                                                       |   10 +-
 net/smc/Kconfig                                                           |    4 -
 net/smc/af_smc.c                                                          |   64 +-
 net/smc/smc_clc.c                                                         |   12 +-
 net/smc/smc_core.c                                                        |  388 +++----
 net/smc/smc_core.h                                                        |   31 +-
 net/smc/smc_ib.c                                                          |  128 ++-
 net/smc/smc_ib.h                                                          |   19 +-
 net/smc/smc_rx.c                                                          |    3 +
 net/smc/smc_tx.c                                                          |    9 +-
 net/smc/smc_wr.c                                                          |   63 ++
 net/smc/smc_wr.h                                                          |    1 +
 net/socket.c                                                              |   33 +-
 net/strparser/strparser.c                                                 |  315 +++---
 net/switchdev/switchdev.c                                                 |  519 ---------
 net/tipc/bearer.c                                                         |   24 -
 net/tipc/bearer.h                                                         |    1 -
 net/tipc/link.c                                                           |   23 +-
 net/tipc/netlink_compat.c                                                 |    2 +-
 net/tipc/node.c                                                           |   14 +-
 net/unix/af_unix.c                                                        |   24 +-
 net/vmw_vsock/Kconfig                                                     |   12 +
 net/vmw_vsock/Makefile                                                    |    3 +
 net/vmw_vsock/hyperv_transport.c                                          |  904 ++++++++++++++++
 net/x25/af_x25.c                                                          |    2 +-
 net/xfrm/xfrm_device.c                                                    |    9 +-
 net/xfrm/xfrm_input.c                                                     |    7 +
 net/xfrm/xfrm_output.c                                                    |    3 +
 net/xfrm/xfrm_policy.c                                                    |  435 +++-----
 net/xfrm/xfrm_state.c                                                     |   21 +-
 net/xfrm/xfrm_user.c                                                      |   16 +-
 samples/bpf/Makefile                                                      |   16 +
 samples/bpf/bpf_load.c                                                    |   29 +-
 samples/bpf/bpf_load.h                                                    |    1 +
 samples/bpf/map_perf_test_kern.c                                          |   46 +-
 samples/bpf/map_perf_test_user.c                                          |   89 +-
 samples/bpf/sock_flags_kern.c                                             |    5 +
 samples/bpf/syscall_tp_kern.c                                             |   62 ++
 samples/bpf/syscall_tp_user.c                                             |   71 ++
 samples/bpf/tcbpf2_kern.c                                                 |   63 +-
 samples/bpf/test_cgrp2_sock.c                                             |  255 ++++-
 samples/bpf/test_cgrp2_sock.sh                                            |  162 ++-
 samples/bpf/test_tunnel_bpf.sh                                            |   29 +
 samples/bpf/xdp_monitor_kern.c                                            |   88 ++
 samples/bpf/xdp_monitor_user.c                                            |  295 ++++++
 samples/bpf/xdp_redirect_kern.c                                           |   90 ++
 samples/bpf/xdp_redirect_map_kern.c                                       |   92 ++
 samples/bpf/xdp_redirect_map_user.c                                       |  145 +++
 samples/bpf/xdp_redirect_user.c                                           |  143 +++
 samples/sockmap/Makefile                                                  |   78 ++
 samples/sockmap/sockmap_kern.c                                            |  108 ++
 samples/sockmap/sockmap_user.c                                            |  294 +++++
 security/selinux/hooks.c                                                  |    2 +-
 security/selinux/include/xfrm.h                                           |    4 +-
 security/smack/smack_netfilter.c                                          |    2 +-
 tools/hv/bondvf.sh                                                        |  232 ----
 tools/include/uapi/linux/bpf.h                                            |   60 +-
 tools/lib/bpf/Makefile                                                    |    4 +
 tools/lib/bpf/bpf.c                                                       |   32 +-
 tools/lib/bpf/bpf.h                                                       |    6 +
 tools/lib/bpf/libbpf.c                                                    |   29 +
 tools/lib/bpf/libbpf.h                                                    |    2 +
 tools/testing/selftests/bpf/Makefile                                      |    4 +-
 tools/testing/selftests/bpf/bpf_helpers.h                                 |    9 +
 tools/testing/selftests/bpf/sockmap_parse_prog.c                          |   38 +
 tools/testing/selftests/bpf/sockmap_verdict_prog.c                        |   68 ++
 tools/testing/selftests/bpf/test_align.c                                  |  462 ++++++--
 tools/testing/selftests/bpf/test_maps.c                                   |  393 +++++++
 tools/testing/selftests/bpf/test_progs.c                                  |   71 +-
 tools/testing/selftests/bpf/test_verifier.c                               | 1166 +++++++++++++++-----
 tools/testing/selftests/bpf/test_xdp_redirect.c                           |   28 +
 tools/testing/selftests/bpf/test_xdp_redirect.sh                          |   59 ++
 tools/testing/selftests/net/.gitignore                                    |    1 +
 tools/testing/selftests/net/Makefile                                      |    4 +-
 tools/testing/selftests/net/msg_zerocopy.c                                |  697 ++++++++++++
 tools/testing/selftests/net/msg_zerocopy.sh                               |  112 ++
 tools/testing/selftests/net/rtnetlink.sh                                  |  272 +++++
 tools/testing/selftests/networking/timestamping/.gitignore                |    1 +
 tools/testing/selftests/networking/timestamping/Makefile                  |    4 +-
 tools/testing/selftests/networking/timestamping/rxtimestamp.c             |  389 +++++++
 tools/testing/selftests/tc-testing/tc-tests/actions/tests.json            |   50 +
 1592 files changed, 100338 insertions(+), 31576 deletions(-)
 create mode 100644 Documentation/devicetree/bindings/net/anarion-gmac.txt
 create mode 100644 Documentation/devicetree/bindings/net/broadcom-bluetooth.txt
 create mode 100644 Documentation/devicetree/bindings/net/xilinx_axienet.txt
 create mode 100644 Documentation/devicetree/bindings/phy/phy-mvebu-comphy.txt
 create mode 100644 Documentation/networking/batman-adv.rst
 delete mode 100644 Documentation/networking/batman-adv.txt
 create mode 100644 Documentation/networking/hinic.txt
 create mode 100644 Documentation/networking/msg_zerocopy.rst
 create mode 100644 Documentation/networking/netvsc.txt
 create mode 100644 Documentation/networking/rmnet.txt
 create mode 100644 drivers/net/ethernet/broadcom/bnxt/bnxt_tc.c
 create mode 100644 drivers/net/ethernet/broadcom/bnxt/bnxt_tc.h
 create mode 100644 drivers/net/ethernet/broadcom/bnxt/bnxt_vfr.c
 create mode 100644 drivers/net/ethernet/broadcom/bnxt/bnxt_vfr.h
 create mode 100644 drivers/net/ethernet/freescale/fman/fman_keygen.c
 create mode 100644 drivers/net/ethernet/freescale/fman/fman_keygen.h
 create mode 100644 drivers/net/ethernet/hisilicon/hns3/Makefile
 create mode 100644 drivers/net/ethernet/hisilicon/hns3/hnae3.c
 create mode 100644 drivers/net/ethernet/hisilicon/hns3/hnae3.h
 create mode 100644 drivers/net/ethernet/hisilicon/hns3/hns3pf/Makefile
 create mode 100644 drivers/net/ethernet/hisilicon/hns3/hns3pf/hclge_cmd.c
 create mode 100644 drivers/net/ethernet/hisilicon/hns3/hns3pf/hclge_cmd.h
 create mode 100644 drivers/net/ethernet/hisilicon/hns3/hns3pf/hclge_main.c
 create mode 100644 drivers/net/ethernet/hisilicon/hns3/hns3pf/hclge_main.h
 create mode 100644 drivers/net/ethernet/hisilicon/hns3/hns3pf/hclge_mdio.c
 create mode 100644 drivers/net/ethernet/hisilicon/hns3/hns3pf/hclge_mdio.h
 create mode 100644 drivers/net/ethernet/hisilicon/hns3/hns3pf/hclge_tm.c
 create mode 100644 drivers/net/ethernet/hisilicon/hns3/hns3pf/hclge_tm.h
 create mode 100644 drivers/net/ethernet/hisilicon/hns3/hns3pf/hns3_enet.c
 create mode 100644 drivers/net/ethernet/hisilicon/hns3/hns3pf/hns3_enet.h
 create mode 100644 drivers/net/ethernet/hisilicon/hns3/hns3pf/hns3_ethtool.c
 create mode 100644 drivers/net/ethernet/huawei/Kconfig
 create mode 100644 drivers/net/ethernet/huawei/Makefile
 create mode 100644 drivers/net/ethernet/huawei/hinic/Kconfig
 create mode 100644 drivers/net/ethernet/huawei/hinic/Makefile
 create mode 100644 drivers/net/ethernet/huawei/hinic/hinic_common.c
 create mode 100644 drivers/net/ethernet/huawei/hinic/hinic_common.h
 create mode 100644 drivers/net/ethernet/huawei/hinic/hinic_dev.h
 create mode 100644 drivers/net/ethernet/huawei/hinic/hinic_hw_api_cmd.c
 create mode 100644 drivers/net/ethernet/huawei/hinic/hinic_hw_api_cmd.h
 create mode 100644 drivers/net/ethernet/huawei/hinic/hinic_hw_cmdq.c
 create mode 100644 drivers/net/ethernet/huawei/hinic/hinic_hw_cmdq.h
 create mode 100644 drivers/net/ethernet/huawei/hinic/hinic_hw_csr.h
 create mode 100644 drivers/net/ethernet/huawei/hinic/hinic_hw_dev.c
 create mode 100644 drivers/net/ethernet/huawei/hinic/hinic_hw_dev.h
 create mode 100644 drivers/net/ethernet/huawei/hinic/hinic_hw_eqs.c
 create mode 100644 drivers/net/ethernet/huawei/hinic/hinic_hw_eqs.h
 create mode 100644 drivers/net/ethernet/huawei/hinic/hinic_hw_if.c
 create mode 100644 drivers/net/ethernet/huawei/hinic/hinic_hw_if.h
 create mode 100644 drivers/net/ethernet/huawei/hinic/hinic_hw_io.c
 create mode 100644 drivers/net/ethernet/huawei/hinic/hinic_hw_io.h
 create mode 100644 drivers/net/ethernet/huawei/hinic/hinic_hw_mgmt.c
 create mode 100644 drivers/net/ethernet/huawei/hinic/hinic_hw_mgmt.h
 create mode 100644 drivers/net/ethernet/huawei/hinic/hinic_hw_qp.c
 create mode 100644 drivers/net/ethernet/huawei/hinic/hinic_hw_qp.h
 create mode 100644 drivers/net/ethernet/huawei/hinic/hinic_hw_qp_ctxt.h
 create mode 100644 drivers/net/ethernet/huawei/hinic/hinic_hw_wq.c
 create mode 100644 drivers/net/ethernet/huawei/hinic/hinic_hw_wq.h
 create mode 100644 drivers/net/ethernet/huawei/hinic/hinic_hw_wqe.h
 create mode 100644 drivers/net/ethernet/huawei/hinic/hinic_main.c
 create mode 100644 drivers/net/ethernet/huawei/hinic/hinic_port.c
 create mode 100644 drivers/net/ethernet/huawei/hinic/hinic_port.h
 create mode 100644 drivers/net/ethernet/huawei/hinic/hinic_rx.c
 create mode 100644 drivers/net/ethernet/huawei/hinic/hinic_rx.h
 create mode 100644 drivers/net/ethernet/huawei/hinic/hinic_tx.c
 create mode 100644 drivers/net/ethernet/huawei/hinic/hinic_tx.h
 create mode 100644 drivers/net/ethernet/mellanox/mlx5/core/diag/Makefile
 create mode 100644 drivers/net/ethernet/mellanox/mlx5/core/diag/fs_tracepoint.c
 create mode 100644 drivers/net/ethernet/mellanox/mlx5/core/diag/fs_tracepoint.h
 create mode 100644 drivers/net/ethernet/mellanox/mlx5/core/lib/mpfs.c
 create mode 100644 drivers/net/ethernet/mellanox/mlx5/core/lib/mpfs.h
 create mode 100644 drivers/net/ethernet/mellanox/mlxsw/spectrum_ipip.c
 create mode 100644 drivers/net/ethernet/mellanox/mlxsw/spectrum_ipip.h
 create mode 100644 drivers/net/ethernet/netronome/nfp/nfp_net_sriov.c
 create mode 100644 drivers/net/ethernet/netronome/nfp/nfp_net_sriov.h
 create mode 100644 drivers/net/ethernet/qualcomm/rmnet/Kconfig
 create mode 100644 drivers/net/ethernet/qualcomm/rmnet/Makefile
 create mode 100644 drivers/net/ethernet/qualcomm/rmnet/rmnet_config.c
 create mode 100644 drivers/net/ethernet/qualcomm/rmnet/rmnet_config.h
 create mode 100644 drivers/net/ethernet/qualcomm/rmnet/rmnet_handlers.c
 create mode 100644 drivers/net/ethernet/qualcomm/rmnet/rmnet_handlers.h
 create mode 100644 drivers/net/ethernet/qualcomm/rmnet/rmnet_map.h
 create mode 100644 drivers/net/ethernet/qualcomm/rmnet/rmnet_map_command.c
 create mode 100644 drivers/net/ethernet/qualcomm/rmnet/rmnet_map_data.c
 create mode 100644 drivers/net/ethernet/qualcomm/rmnet/rmnet_private.h
 create mode 100644 drivers/net/ethernet/qualcomm/rmnet/rmnet_vnd.c
 create mode 100644 drivers/net/ethernet/qualcomm/rmnet/rmnet_vnd.h
 create mode 100644 drivers/net/ethernet/stmicro/stmmac/dwmac-anarion.c
 create mode 100644 drivers/net/phy/mdio-i2c.c
 create mode 100644 drivers/net/phy/mdio-i2c.h
 create mode 100644 drivers/net/phy/phylink.c
 create mode 100644 drivers/net/phy/rockchip.c
 create mode 100644 drivers/net/phy/sfp-bus.c
 create mode 100644 drivers/net/phy/sfp.c
 create mode 100644 drivers/net/phy/sfp.h
 create mode 100644 drivers/net/wireless/ath/ath10k/usb.c
 create mode 100644 drivers/net/wireless/ath/ath10k/usb.h
 create mode 100644 drivers/net/wireless/intel/iwlwifi/fw/api/alive.h
 create mode 100644 drivers/net/wireless/intel/iwlwifi/fw/api/binding.h
 rename drivers/net/wireless/intel/iwlwifi/fw/{api.h => api/cmdhdr.h} (82%)
 rename drivers/net/wireless/intel/iwlwifi/{mvm/fw-api-coex.h => fw/api/coex.h} (84%)
 create mode 100644 drivers/net/wireless/intel/iwlwifi/fw/api/commands.h
 create mode 100644 drivers/net/wireless/intel/iwlwifi/fw/api/config.h
 create mode 100644 drivers/net/wireless/intel/iwlwifi/fw/api/context.h
 rename drivers/net/wireless/intel/iwlwifi/{mvm/fw-api-d3.h => fw/api/d3.h} (98%)
 create mode 100644 drivers/net/wireless/intel/iwlwifi/fw/api/datapath.h
 create mode 100644 drivers/net/wireless/intel/iwlwifi/fw/api/debug.h
 create mode 100644 drivers/net/wireless/intel/iwlwifi/fw/api/filter.h
 create mode 100644 drivers/net/wireless/intel/iwlwifi/fw/api/led.h
 create mode 100644 drivers/net/wireless/intel/iwlwifi/fw/api/mac-cfg.h
 rename drivers/net/wireless/intel/iwlwifi/{mvm/fw-api-mac.h => fw/api/mac.h} (93%)
 create mode 100644 drivers/net/wireless/intel/iwlwifi/fw/api/nvm-reg.h
 create mode 100644 drivers/net/wireless/intel/iwlwifi/fw/api/offload.h
 create mode 100644 drivers/net/wireless/intel/iwlwifi/fw/api/paging.h
 create mode 100644 drivers/net/wireless/intel/iwlwifi/fw/api/phy-ctxt.h
 create mode 100644 drivers/net/wireless/intel/iwlwifi/fw/api/phy.h
 rename drivers/net/wireless/intel/iwlwifi/{mvm/fw-api-power.h => fw/api/power.h} (98%)
 rename drivers/net/wireless/intel/iwlwifi/{mvm/fw-api-rs.h => fw/api/rs.h} (97%)
 rename drivers/net/wireless/intel/iwlwifi/{mvm/fw-api-rx.h => fw/api/rx.h} (95%)
 rename drivers/net/wireless/intel/iwlwifi/{mvm/fw-api-scan.h => fw/api/scan.h} (98%)
 create mode 100644 drivers/net/wireless/intel/iwlwifi/fw/api/sf.h
 rename drivers/net/wireless/intel/iwlwifi/{mvm/fw-api-sta.h => fw/api/sta.h} (98%)
 rename drivers/net/wireless/intel/iwlwifi/{mvm/fw-api-stats.h => fw/api/stats.h} (97%)
 create mode 100644 drivers/net/wireless/intel/iwlwifi/fw/api/tdls.h
 create mode 100644 drivers/net/wireless/intel/iwlwifi/fw/api/time-event.h
 rename drivers/net/wireless/intel/iwlwifi/{mvm/fw-api-tof.h => fw/api/tof.h} (98%)
 rename drivers/net/wireless/intel/iwlwifi/{mvm/fw-api-tx.h => fw/api/tx.h} (96%)
 create mode 100644 drivers/net/wireless/intel/iwlwifi/fw/api/txq.h
 create mode 100644 drivers/net/wireless/intel/iwlwifi/fw/common_rx.c
 rename drivers/net/wireless/intel/iwlwifi/{mvm/fw-dbg.c => fw/dbg.c} (67%)
 rename drivers/net/wireless/intel/iwlwifi/{mvm/fw-dbg.h => fw/dbg.h} (59%)
 create mode 100644 drivers/net/wireless/intel/iwlwifi/fw/init.c
 create mode 100644 drivers/net/wireless/intel/iwlwifi/fw/nvm.c
 create mode 100644 drivers/net/wireless/intel/iwlwifi/fw/paging.c
 create mode 100644 drivers/net/wireless/intel/iwlwifi/fw/runtime.h
 create mode 100644 drivers/net/wireless/intel/iwlwifi/fw/smem.c
 create mode 100644 drivers/net/wireless/rsi/rsi_91x_ps.c
 create mode 100644 drivers/net/wireless/rsi/rsi_ps.h
 create mode 100644 drivers/phy/marvell/phy-mvebu-cp110-comphy.c
 create mode 100644 drivers/staging/irda/TODO
 rename drivers/{net/irda => staging/irda/drivers}/Kconfig (100%)
 rename drivers/{net/irda => staging/irda/drivers}/Makefile (96%)
 rename drivers/{net/irda => staging/irda/drivers}/act200l-sir.c (100%)
 rename drivers/{net/irda => staging/irda/drivers}/actisys-sir.c (100%)
 rename drivers/{net/irda => staging/irda/drivers}/ali-ircc.c (100%)
 rename drivers/{net/irda => staging/irda/drivers}/ali-ircc.h (100%)
 rename drivers/{net/irda => staging/irda/drivers}/au1k_ir.c (100%)
 rename drivers/{net/irda => staging/irda/drivers}/bfin_sir.c (100%)
 rename drivers/{net/irda => staging/irda/drivers}/bfin_sir.h (100%)
 rename drivers/{net/irda => staging/irda/drivers}/donauboe.c (100%)
 rename drivers/{net/irda => staging/irda/drivers}/donauboe.h (100%)
 rename drivers/{net/irda => staging/irda/drivers}/esi-sir.c (100%)
 rename drivers/{net/irda => staging/irda/drivers}/girbil-sir.c (100%)
 rename drivers/{net/irda => staging/irda/drivers}/irda-usb.c (99%)
 rename drivers/{net/irda => staging/irda/drivers}/irda-usb.h (100%)
 rename drivers/{net/irda => staging/irda/drivers}/irtty-sir.c (100%)
 rename drivers/{net/irda => staging/irda/drivers}/irtty-sir.h (100%)
 rename drivers/{net/irda => staging/irda/drivers}/kingsun-sir.c (99%)
 rename drivers/{net/irda => staging/irda/drivers}/ks959-sir.c (99%)
 rename drivers/{net/irda => staging/irda/drivers}/ksdazzle-sir.c (99%)
 rename drivers/{net/irda => staging/irda/drivers}/litelink-sir.c (100%)
 rename drivers/{net/irda => staging/irda/drivers}/ma600-sir.c (100%)
 rename drivers/{net/irda => staging/irda/drivers}/mcp2120-sir.c (100%)
 rename drivers/{net/irda => staging/irda/drivers}/mcs7780.c (99%)
 rename drivers/{net/irda => staging/irda/drivers}/mcs7780.h (100%)
 rename drivers/{net/irda => staging/irda/drivers}/nsc-ircc.c (100%)
 rename drivers/{net/irda => staging/irda/drivers}/nsc-ircc.h (100%)
 rename drivers/{net/irda => staging/irda/drivers}/old_belkin-sir.c (100%)
 rename drivers/{net/irda => staging/irda/drivers}/pxaficp_ir.c (100%)
 rename drivers/{net/irda => staging/irda/drivers}/sa1100_ir.c (100%)
 rename drivers/{net/irda => staging/irda/drivers}/sh_sir.c (100%)
 rename drivers/{net/irda => staging/irda/drivers}/sir-dev.h (100%)
 rename drivers/{net/irda => staging/irda/drivers}/sir_dev.c (100%)
 rename drivers/{net/irda => staging/irda/drivers}/sir_dongle.c (100%)
 rename drivers/{net/irda => staging/irda/drivers}/smsc-ircc2.c (100%)
 rename drivers/{net/irda => staging/irda/drivers}/smsc-ircc2.h (100%)
 rename drivers/{net/irda => staging/irda/drivers}/smsc-sio.h (100%)
 rename drivers/{net/irda => staging/irda/drivers}/stir4200.c (99%)
 rename drivers/{net/irda => staging/irda/drivers}/tekram-sir.c (100%)
 rename drivers/{net/irda => staging/irda/drivers}/toim3232-sir.c (100%)
 rename drivers/{net/irda => staging/irda/drivers}/via-ircc.c (100%)
 rename drivers/{net/irda => staging/irda/drivers}/via-ircc.h (100%)
 rename drivers/{net/irda => staging/irda/drivers}/vlsi_ir.c (100%)
 rename drivers/{net/irda => staging/irda/drivers}/vlsi_ir.h (100%)
 rename drivers/{net/irda => staging/irda/drivers}/w83977af.h (100%)
 rename drivers/{net/irda => staging/irda/drivers}/w83977af_ir.c (100%)
 rename drivers/{net/irda => staging/irda/drivers}/w83977af_ir.h (100%)
 rename {include => drivers/staging/irda/include}/net/irda/af_irda.h (100%)
 rename {include => drivers/staging/irda/include}/net/irda/crc.h (100%)
 rename {include => drivers/staging/irda/include}/net/irda/discovery.h (100%)
 rename {include => drivers/staging/irda/include}/net/irda/ircomm_core.h (100%)
 rename {include => drivers/staging/irda/include}/net/irda/ircomm_event.h (100%)
 rename {include => drivers/staging/irda/include}/net/irda/ircomm_lmp.h (100%)
 rename {include => drivers/staging/irda/include}/net/irda/ircomm_param.h (100%)
 rename {include => drivers/staging/irda/include}/net/irda/ircomm_ttp.h (100%)
 rename {include => drivers/staging/irda/include}/net/irda/ircomm_tty.h (100%)
 rename {include => drivers/staging/irda/include}/net/irda/ircomm_tty_attach.h (100%)
 rename {include => drivers/staging/irda/include}/net/irda/irda.h (100%)
 rename {include => drivers/staging/irda/include}/net/irda/irda_device.h (100%)
 rename {include => drivers/staging/irda/include}/net/irda/iriap.h (100%)
 rename {include => drivers/staging/irda/include}/net/irda/iriap_event.h (100%)
 rename {include => drivers/staging/irda/include}/net/irda/irias_object.h (100%)
 rename {include => drivers/staging/irda/include}/net/irda/irlan_client.h (100%)
 rename {include => drivers/staging/irda/include}/net/irda/irlan_common.h (100%)
 rename {include => drivers/staging/irda/include}/net/irda/irlan_eth.h (100%)
 rename {include => drivers/staging/irda/include}/net/irda/irlan_event.h (100%)
 rename {include => drivers/staging/irda/include}/net/irda/irlan_filter.h (100%)
 rename {include => drivers/staging/irda/include}/net/irda/irlan_provider.h (100%)
 rename {include => drivers/staging/irda/include}/net/irda/irlap.h (100%)
 rename {include => drivers/staging/irda/include}/net/irda/irlap_event.h (100%)
 rename {include => drivers/staging/irda/include}/net/irda/irlap_frame.h (100%)
 rename {include => drivers/staging/irda/include}/net/irda/irlmp.h (100%)
 rename {include => drivers/staging/irda/include}/net/irda/irlmp_event.h (100%)
 rename {include => drivers/staging/irda/include}/net/irda/irlmp_frame.h (100%)
 rename {include => drivers/staging/irda/include}/net/irda/irmod.h (100%)
 rename {include => drivers/staging/irda/include}/net/irda/irqueue.h (100%)
 rename {include => drivers/staging/irda/include}/net/irda/irttp.h (100%)
 rename {include => drivers/staging/irda/include}/net/irda/parameters.h (100%)
 rename {include => drivers/staging/irda/include}/net/irda/qos.h (100%)
 rename {include => drivers/staging/irda/include}/net/irda/timer.h (100%)
 rename {include => drivers/staging/irda/include}/net/irda/wrapper.h (100%)
 rename {net/irda => drivers/staging/irda/net}/Kconfig (94%)
 rename {net/irda => drivers/staging/irda/net}/Makefile (88%)
 rename {net/irda => drivers/staging/irda/net}/af_irda.c (100%)
 rename {net/irda => drivers/staging/irda/net}/discovery.c (100%)
 rename {net/irda => drivers/staging/irda/net}/ircomm/Kconfig (100%)
 rename {net/irda => drivers/staging/irda/net}/ircomm/Makefile (100%)
 rename {net/irda => drivers/staging/irda/net}/ircomm/ircomm_core.c (100%)
 rename {net/irda => drivers/staging/irda/net}/ircomm/ircomm_event.c (100%)
 rename {net/irda => drivers/staging/irda/net}/ircomm/ircomm_lmp.c (100%)
 rename {net/irda => drivers/staging/irda/net}/ircomm/ircomm_param.c (100%)
 rename {net/irda => drivers/staging/irda/net}/ircomm/ircomm_ttp.c (100%)
 rename {net/irda => drivers/staging/irda/net}/ircomm/ircomm_tty.c (100%)
 rename {net/irda => drivers/staging/irda/net}/ircomm/ircomm_tty_attach.c (100%)
 rename {net/irda => drivers/staging/irda/net}/ircomm/ircomm_tty_ioctl.c (100%)
 rename {net/irda => drivers/staging/irda/net}/irda_device.c (100%)
 rename {net/irda => drivers/staging/irda/net}/iriap.c (100%)
 rename {net/irda => drivers/staging/irda/net}/iriap_event.c (100%)
 rename {net/irda => drivers/staging/irda/net}/irias_object.c (100%)
 rename {net/irda => drivers/staging/irda/net}/irlan/Kconfig (100%)
 rename {net/irda => drivers/staging/irda/net}/irlan/Makefile (100%)
 rename {net/irda => drivers/staging/irda/net}/irlan/irlan_client.c (100%)
 rename {net/irda => drivers/staging/irda/net}/irlan/irlan_client_event.c (100%)
 rename {net/irda => drivers/staging/irda/net}/irlan/irlan_common.c (100%)
 rename {net/irda => drivers/staging/irda/net}/irlan/irlan_eth.c (100%)
 rename {net/irda => drivers/staging/irda/net}/irlan/irlan_event.c (100%)
 rename {net/irda => drivers/staging/irda/net}/irlan/irlan_filter.c (100%)
 rename {net/irda => drivers/staging/irda/net}/irlan/irlan_provider.c (100%)
 rename {net/irda => drivers/staging/irda/net}/irlan/irlan_provider_event.c (100%)
 rename {net/irda => drivers/staging/irda/net}/irlap.c (100%)
 rename {net/irda => drivers/staging/irda/net}/irlap_event.c (100%)
 rename {net/irda => drivers/staging/irda/net}/irlap_frame.c (100%)
 rename {net/irda => drivers/staging/irda/net}/irlmp.c (100%)
 rename {net/irda => drivers/staging/irda/net}/irlmp_event.c (100%)
 rename {net/irda => drivers/staging/irda/net}/irlmp_frame.c (100%)
 rename {net/irda => drivers/staging/irda/net}/irmod.c (99%)
 rename {net/irda => drivers/staging/irda/net}/irnet/Kconfig (100%)
 rename {net/irda => drivers/staging/irda/net}/irnet/Makefile (100%)
 rename {net/irda => drivers/staging/irda/net}/irnet/irnet.h (100%)
 rename {net/irda => drivers/staging/irda/net}/irnet/irnet_irda.c (100%)
 rename {net/irda => drivers/staging/irda/net}/irnet/irnet_irda.h (100%)
 rename {net/irda => drivers/staging/irda/net}/irnet/irnet_ppp.c (100%)
 rename {net/irda => drivers/staging/irda/net}/irnet/irnet_ppp.h (100%)
 rename {net/irda => drivers/staging/irda/net}/irnetlink.c (100%)
 rename {net/irda => drivers/staging/irda/net}/irproc.c (100%)
 rename {net/irda => drivers/staging/irda/net}/irqueue.c (100%)
 rename {net/irda => drivers/staging/irda/net}/irsysctl.c (100%)
 rename {net/irda => drivers/staging/irda/net}/irttp.c (100%)
 rename {net/irda => drivers/staging/irda/net}/parameters.c (100%)
 rename {net/irda => drivers/staging/irda/net}/qos.c (100%)
 rename {net/irda => drivers/staging/irda/net}/timer.c (100%)
 rename {net/irda => drivers/staging/irda/net}/wrapper.c (100%)
 create mode 100644 include/linux/phylink.h
 create mode 100644 include/linux/platform_data/mdio-bcm-unimac.h
 create mode 100644 include/linux/seg6_local.h
 create mode 100644 include/linux/sfp.h
 create mode 100644 include/linux/tnum.h
 create mode 100644 include/net/erspan.h
 create mode 100644 include/net/fib_notifier.h
 delete mode 100644 include/net/flowcache.h
 create mode 100644 include/net/nsh.h
 create mode 100644 include/net/tun_proto.h
 create mode 100644 include/trace/events/bridge.h
 create mode 100644 include/trace/events/qdisc.h
 rename include/{ => uapi}/linux/rxrpc.h (54%)
 create mode 100644 include/uapi/linux/seg6_local.h
 create mode 100644 kernel/bpf/devmap.c
 create mode 100644 kernel/bpf/sockmap.c
 create mode 100644 kernel/bpf/tnum.c
 create mode 100644 net/core/fib_notifier.c
 delete mode 100644 net/core/flow.c
 create mode 100644 net/ipv6/fib6_notifier.c
 create mode 100644 net/ipv6/seg6_local.c
 create mode 100644 net/netfilter/nft_fib_netdev.c
 create mode 100644 net/nsh/Kconfig
 create mode 100644 net/nsh/Makefile
 create mode 100644 net/nsh/nsh.c
 rename include/rxrpc/packet.h => net/rxrpc/protocol.h (78%)
 create mode 100644 net/vmw_vsock/hyperv_transport.c
 create mode 100644 samples/bpf/syscall_tp_kern.c
 create mode 100644 samples/bpf/syscall_tp_user.c
 create mode 100644 samples/bpf/xdp_monitor_kern.c
 create mode 100644 samples/bpf/xdp_monitor_user.c
 create mode 100644 samples/bpf/xdp_redirect_kern.c
 create mode 100644 samples/bpf/xdp_redirect_map_kern.c
 create mode 100644 samples/bpf/xdp_redirect_map_user.c
 create mode 100644 samples/bpf/xdp_redirect_user.c
 create mode 100644 samples/sockmap/Makefile
 create mode 100644 samples/sockmap/sockmap_kern.c
 create mode 100644 samples/sockmap/sockmap_user.c
 delete mode 100755 tools/hv/bondvf.sh
 create mode 100644 tools/testing/selftests/bpf/sockmap_parse_prog.c
 create mode 100644 tools/testing/selftests/bpf/sockmap_verdict_prog.c
 create mode 100644 tools/testing/selftests/bpf/test_xdp_redirect.c
 create mode 100755 tools/testing/selftests/bpf/test_xdp_redirect.sh
 create mode 100644 tools/testing/selftests/net/msg_zerocopy.c
 create mode 100755 tools/testing/selftests/net/msg_zerocopy.sh
 create mode 100755 tools/testing/selftests/net/rtnetlink.sh
 create mode 100644 tools/testing/selftests/networking/timestamping/rxtimestamp.c
