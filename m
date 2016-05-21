From: David Miller <davem@davemloft.net>
Subject: [GIT] Networking
Date: Fri, 20 May 2016 20:09:41 -0400 (EDT)
Message-ID: <20160520.200941.1820002186726366788.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


1) Tunneling fixes from Tom Herbert and Alexander Duyck.

2) AF_UNIX updates some struct sock bit fields with the socket lock,
   whereas setsockopt() sets overlapping ones with locking.  Seperate
   out the synchronized vs. the AF_UNIX unsynchronized ones to avoid
   corruption.  From Andrey Ryabinin.

3) Mount BPF filesystem with mount_nodev rather than mount_ns, from
   Eric bieferman.

4) A couple kmemdup conversions, from Muhammad Falak R Wani.

5) BPF verifier fixes from Alexei Starovoitov.

6) Don't let tunneled UDP packets get stuck in socket queues, if
   something goes wrong during the encapsulation just drop the
   packet rather than signalling an error up the call stack.
   From Hannes Frederic Sowa.

7) SKB ref after free in batman-adv, from Florian Westphal.

8) TCP iSCSI, ocfs2, rds, and tipc have to disable BH in it's TCP
   callbacks since the TCP stack runs pre-emptibly now.  From Eric
   Dumazet.

9) Fix crash in fixed_phy_add, from Rabin Vincent.

10) Fix length checks in xen-netback, from Paul Durrant.

11) Fix mixup in KEY vs. KEYID macsec attributes, from Sabrina
    Dubroca.

12) RDS connection spamming bug fixes from Sowmini Varadhan.

Please pull, thanks a lot!

The following changes since commit 07b75260ebc2c789724c594d7eaf0194fa47=
b3be:

  Merge branch 'upstream' of git://git.linux-mips.org/pub/scm/ralf/upst=
ream-linus (2016-05-19 10:02:26 -0700)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/davem/net.git=20

for you to fetch changes up to 95829b3a9c0b1d88778b23bc2afdf5a83de066ff=
:

  net: suppress warnings on dev_alloc_skb (2016-05-20 19:58:32 -0400)

----------------------------------------------------------------
Alan Liu (1):
      ath10k: add max_tx_power for QCA6174 WLAN.RM.2.0 firmware

Alexander Duyck (2):
      ip6_gre: Do not allow segmentation offloads GRE_CSUM is enabled w=
ith FOU/GUE
      intel: Add support for IPv6 IP-in-IP offload

Alexei Starovoitov (2):
      bpf: support decreasing order in direct packet access
      bpf: teach verifier to recognize imm +=3D ptr pattern

Amit Ghadge (1):
      net: Fix coding style warnings and errors.

Andrey Ryabinin (1):
      net: sock: move ->sk_shutdown out of bitfields.

Anilkumar Kolli (1):
      ath10k: fix kernel panic, move arvifs list head init before htt i=
nit

Antonio Quartulli (1):
      batman-adv: make sure ELP/OGM orig MAC is updated on address chan=
ge

Arnd Bergmann (1):
      mlx5: avoid unused variable warning

Bjorn Andersson (1):
      wcn36xx: Set SMD timeout to 10 seconds

Christian Daudt (1):
      brcmfmac: Add 4356 sdio support

Dan Carpenter (3):
      rtlwifi: rtl818x: silence uninitialized variable warning
      airo: prevent potential underflow in airo_set_freq()
      atmel: potential underflow in atmel_set_freq()

Daniel Borkmann (1):
      bpf: rather use get_random_int for randomizations

David S. Miller (8):
      Merge branch 'tcp_bh_fixes'
      Merge tag 'batman-adv-fix-for-davem' of git://git.open-mesh.org/l=
inux-merge
      Revert "net: pegasus: remove dead coding"
      Merge branch 'GREoIPV6'
      Merge branch 'rds-conn-spamming'
      Merge branch 'GREoIPV6-followups'
      Merge tag 'wireless-drivers-next-for-davem-2016-05-13' of git://g=
it.kernel.org/.../kvalo/wireless-drivers-next
      Merge branch 'bpf-verifier-fixes'

Denys Vlasenko (1):
      rtlwifi: rtl818x: Deinline indexed IO functions, save 21568 bytes

Emmanuel Grumbach (4):
      iwlwifi: mvm: allow a debug knob for Tx A-MSDU even if rate contr=
ol forbids it
      iwlwifi: remove IWLWIFI_DEBUG_EXPERIMENTAL_UCODE
      iwlwifi: don't access a nonexistent register upon assert
      iwlwifi: add default value to disable_11ac mod param description

Eric Dumazet (4):
      scsi_tcp: block BH in TCP callbacks
      ocfs2/cluster: block BH in TCP callbacks
      rds: tcp: block BH in TCP callbacks
      tipc: block BH in TCP callbacks

Eric W. Biederman (1):
      bpf: Use mount_nodev not mount_ns to mount the bpf filesystem

=46abio Estevam (1):
      Revert "phy: add support for a reset-gpio specification"

=46lorian Westphal (1):
      batman-adv: fix skb deref after free

Golan Ben-Ami (1):
      iwlwifi: mvm: add more registers to dump upon error

Gregory Greenman (2):
      iwlwifi: consider VHT 160MHz while parsing NVM
      iwlwifi: turn on SGI support for VHT 160MHz

Guy Mishol (1):
      wlcore/wl12xx: Fix fw logger over sdio

Haim Dreyfuss (4):
      iwlwifi: Rename 9560 to 9260 and add new PCI IDs for it
      iwlwifi: allow combining different phy images with mac images
      iwlwifi: Fix firmware name maximum length definition
      iwlwifi: pcie: don't wake up the NIC when writing CSRs in MSIX mo=
de

Hannes Frederic Sowa (1):
      udp: prevent skbs lingering in tunnel socket queues

Helmut Schaa (4):
      ath9k: reuse ar9003_hw_tx_power_regwrite for tx99 setup
      ath9k: Move TX99 config option under ath9k debugging
      ath9k: Simplify ar9003_hw_tx99_set_txpower
      ath9k: Fix symbol overlap window for half/quarter channels

Jason Wang (1):
      tuntap: correctly wake up process during uninit

Jes Sorensen (11):
      rtl8xxxu: Rename rtl8xxxu.c to rtl8xxxu_core.c
      rtl8xxxu: move rtl8192e related code into rtl8xxxu_8192e.c
      rtl8xxxu: move rtl8723b related code into rtl8xxxu_8723b.c
      rtl8xxxu: move rtl8723a related code into rtl8xxxu_8723a.c
      rtl8xxxu: move rtl8188[cr] and rtl8192c related code into rtl8xxx=
u_8192c.c
      rtl8xxxu: Rename rtl8723a_stop_tx_beacon() to rtl8xxxu_stop_tx_be=
acon()
      rtl8xxxu: rename rtl8723a_channel_group() to rtl8xxxu_gen1_channe=
l_to_group()
      rtl8xxxu: Rename rtl8723a_disabled_to_emu() to rtl8xxxu_disabled_=
to_emu()
      rtl8xxxu: Split rtl8723a_h2c_cmd() into a gen1 and a gen2 version
      rtl8xxxu: rtl8xxxu_prepare_calibrate() is never used on gen1
      rtl8xxxu: Remove the now obsolete mbox_ext_reg info from rtl8xxxu=
_fileops

Johannes Berg (7):
      ath10k: remove VHT capabilities from 2.4GHz
      iwlwifi: mvm: add firmware API name comment
      iwlwifi: mvm: advertise RSS queue usage
      iwlwifi: mvm: pass station to mac80211 RX where known
      iwlwifi: make configuration structs smaller
      iwlwifi: pcie: extend device reset delay
      iwlwifi: pcie: avoid msleep() with short timeout

Julia Lawall (1):
      rtlwifi: rtl818x: constify rtl_intf_ops structures

Kalle Valo (2):
      Merge tag 'iwlwifi-next-for-kalle-2016-05-10' of git://git.kernel=
=2Eorg/.../iwlwifi/iwlwifi-next
      Merge ath-next from ath.git

Liad Kaufman (4):
      iwlwifi: mvm: allocate queue for probe response in dqa mode
      iwlwifi: mvm: support p2p device frames tx on dqa queue #2
      iwlwifi: mvm: support queue removal in ADD_STA hcmd
      iwlwifi: mvm: support dqa-mode agg on non-shared queue

Linus L=FCssing (1):
      batman-adv: Avoid duplicate neigh_node additions

Lior David (1):
      wil6210: support regular scan on P2P_DEVICE interface

Luca Coelho (6):
      Merge tag 'mac80211-next-for-davem-2016-04-13' of git://git.kerne=
l.org/.../jberg/mac80211-next into master
      Merge tag 'iwlwifi-for-kalle-2016-05-04' of git://git.kernel.org/=
=2E../iwlwifi/iwlwifi-fixes
      iwlwifi: trans: don't call the trans-specific ref/unref directly
      iwlwifi: wake from runtime suspend before sending sync commands
      iwlwifi: mvm: add a new mvm reference type for RX data
      MAINTAINERS: add myself as co-maintainer of the iwlwifi driver

Lukas Wunner (1):
      mwifiex: Drop unnecessary include pcieport_if.h

Manish Chopra (1):
      qede: Fix DMA address APIs usage

Marek Lindner (1):
      batman-adv: initialize ELP orig address on secondary interfaces

Maya Erez (6):
      wil6210: add function name to wil log macros
      wil6210: change RX_HTRSH interrupt print level to debug
      wil6210: print debug message when transmitting while disconnected
      wil6210: unmask RX_HTRSH interrupt only when connected
      wil6210: prevent deep sleep of 60G device in critical paths
      wil6210: add support for device led configuration

Mohammed Shafi Shajakhan (2):
      ath10k: fix a typo in ath10k_start()
      ath10k: move spectral related structures under ath10k debugfs

Mordechai Goodstein (1):
      iwlwifi: Edit the 8265 SDIO ID

Muhammad Falak R Wani (3):
      net:liquidio: use kmemdup
      ps3_gelic: use kmemdup
      net: usb: ch9200: use kmemdup

Neil Horman (1):
      net: suppress warnings on dev_alloc_skb

Nicolas Dichtel (1):
      uapi glibc compat: fix compilation when !__USE_MISC in glibc

Paul Durrant (2):
      xen-netback: correct length checks on hash copy_ops
      xen-netback: only deinitialized hash if it was initialized

Rabin Vincent (1):
      phy: fix crash in fixed_phy_add()

Rafal Redzimski (1):
      net: cdc_ncm: update datagram size after changing mtu

Rajkumar Manoharan (5):
      ath10k: add pdev bss channel info wmi definitions
      ath10k: implement wmi_pdev_bss_chan_info_request
      ath10k: handle pdev_chan_info wmi event
      ath10k: update bss channel survey information
      ath10k: release pre_cal_file while unloading driver

Sabrina Dubroca (1):
      macsec: fix netlink attribute for key id

Sara Sharon (15):
      iwlwifi: mvm: implement driver RX queues sync command
      iwlwifi: mvm: change RX sync notification to be an attribute and =
not a type
      iwlwifi: mvm: add infrastructure for tracking BA session in drive=
r
      iwlwifi: mvm: add reorder buffer per queue
      iwlwifi: mvm: add reorder timeout per frame
      iwlwifi: mvm: utilize the frame release infrastructure
      iwlwifi: mvm: add a flag to disable checksum
      iwlwifi: mvm: don't allow negative reference count
      iwlwifi: mvm: loosen nssn comparison to reorder buffer head
      iwlwifi: mvm: set correct vht capability
      iwlwifi: mvm: make phy_db size dynamic
      iwlwifi: mvm: remove redundant alloc_ctx parameter
      iwlwifi: mvm: use helpers to get iwl_mvm_sta
      iwlwifi: pcie: use shadow registers for updating write pointer
      iwlwifi: pcie: grab NIC access only once on RX init

Shengzhen Li (1):
      mwifiex: change sleep cookie poll count

Sowmini Varadhan (2):
      RDS: TCP: rds_tcp_accept_worker() must exit gracefully when termi=
nating rds-tcp
      RDS: TCP: Avoid rds connection churn from rogue SYNs

Steve deRosier (2):
      ath6kl: fix missing uart debug pin for 6004 HW 3.0
      ath6kl: add ability to set debug uart baud rate

Sven Eckelmann (4):
      batman-adv: Avoid nullptr derefence in batadv_v_neigh_is_sob
      batman-adv: Fix refcnt leak in batadv_v_neigh_*
      batman-adv: Fix unexpected free of bcast_own on add_if error
      batman-adv: Fix integer overflow in batadv_iv_ogm_calc_tq

Tom Herbert (16):
      gso: Remove arbitrary checks for unsupported GSO
      net: define gso types for IPx over IPv4 and IPv6
      ipv6: Fix nexthdr for reinjection
      ipv6: Change "final" protocol processing for encapsulation
      net: Cleanup encap items in ip_tunnels.h
      fou: Call setup_udp_tunnel_sock
      fou: Split out {fou,gue}_build_header
      fou: Support IPv6 in fou
      ip6_tun: Add infrastructure for doing encapsulation
      fou: Add encap ops for IPv6 tunnels
      ip6_gre: Add support for fou/gue encapsulation
      ip6_tunnel: Add support for fou/gue encapsulation
      ipv6: Set features for IPv6 tunnels
      ip6ip6: Support for GSO/GRO
      ip4ip6: Support for GSO/GRO
      ipv6: Don't reset inner headers in ip6_tnl_xmit

Vasanthakumar Thiagarajan (2):
      ath10k: suppress warnings when getting wmi peer_rate_code_list ev=
ent
      ath10k: Fix survey reporting with QCA4019

WANG Cong (1):
      kcm: fix a signedness in kcm_splice_read()

Wei-Ning Huang (1):
      mwifiex: fixup error messages

wang yanqing (3):
      rtlwifi: Fix logic error in enter/exit power-save mode
      rtlwifi: Remove double check for cnt_after_linked
      rtlwifi: pci: use dev_kfree_skb_irq instead of kfree_skb in rtl_p=
ci_reset_trx_ring

xypron.glpk@gmx.de (6):
      net: thunderx: avoid null pointer dereference
      net: ehea: avoid null pointer dereference
      net: ieee802154/adf7242: syntax error ifdef DEBUG
      net: irda: avoid null pointer dereference
      net: au1000 eth: simplify logical expression
      net: pegasus: remove dead coding

 Documentation/devicetree/bindings/net/phy.txt                         =
|    3 -
 MAINTAINERS                                                           =
|    1 +
 drivers/net/Space.c                                                   =
|   21 +-
 drivers/net/ethernet/amd/au1000_eth.c                                 =
|    2 +-
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c                      =
|    5 +-
 drivers/net/ethernet/broadcom/bnxt/bnxt.c                             =
|    5 +-
 drivers/net/ethernet/cavium/liquidio/octeon_device.c                  =
|    4 +-
 drivers/net/ethernet/cavium/thunder/thunder_bgx.c                     =
|    4 +-
 drivers/net/ethernet/ibm/ehea/ehea_main.c                             =
|    9 +-
 drivers/net/ethernet/intel/i40e/i40e_main.c                           =
|    4 +-
 drivers/net/ethernet/intel/i40e/i40e_txrx.c                           =
|    4 +-
 drivers/net/ethernet/intel/i40evf/i40e_txrx.c                         =
|    4 +-
 drivers/net/ethernet/intel/i40evf/i40evf_main.c                       =
|    4 +-
 drivers/net/ethernet/intel/igb/igb_main.c                             =
|    4 +-
 drivers/net/ethernet/intel/igbvf/netdev.c                             =
|    4 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c                         =
|    4 +-
 drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c                     =
|    4 +-
 drivers/net/ethernet/qlogic/qede/qede_main.c                          =
|    7 +-
 drivers/net/ethernet/toshiba/ps3_gelic_wireless.c                     =
|    4 +-
 drivers/net/geneve.c                                                  =
|   10 +-
 drivers/net/ieee802154/adf7242.c                                      =
|    1 -
 drivers/net/irda/nsc-ircc.c                                           =
|    3 +-
 drivers/net/macsec.c                                                  =
|    4 +-
 drivers/net/phy/fixed_phy.c                                           =
|    6 +-
 drivers/net/phy/phy_device.c                                          =
|    8 -
 drivers/net/tun.c                                                     =
|    6 +-
 drivers/net/usb/cdc_ncm.c                                             =
|    6 +-
 drivers/net/usb/ch9200.c                                              =
|    3 +-
 drivers/net/vxlan.c                                                   =
|    4 +-
 drivers/net/wireless/ath/ath10k/core.c                                =
|   18 +-
 drivers/net/wireless/ath/ath10k/core.h                                =
|    4 +-
 drivers/net/wireless/ath/ath10k/mac.c                                 =
|   40 +-
 drivers/net/wireless/ath/ath10k/wmi-ops.h                             =
|   21 +
 drivers/net/wireless/ath/ath10k/wmi.c                                 =
|   88 +-
 drivers/net/wireless/ath/ath10k/wmi.h                                 =
|   26 +
 drivers/net/wireless/ath/ath6kl/core.c                                =
|    3 +
 drivers/net/wireless/ath/ath6kl/core.h                                =
|    1 +
 drivers/net/wireless/ath/ath6kl/init.c                                =
|    9 +
 drivers/net/wireless/ath/ath9k/Kconfig                                =
|   40 +-
 drivers/net/wireless/ath/ath9k/ar9003_eeprom.c                        =
|    2 +-
 drivers/net/wireless/ath/ath9k/ar9003_eeprom.h                        =
|    1 +
 drivers/net/wireless/ath/ath9k/ar9003_phy.c                           =
|   72 +-
 drivers/net/wireless/ath/wcn36xx/smd.h                                =
|    2 +-
 drivers/net/wireless/ath/wil6210/cfg80211.c                           =
|    5 +-
 drivers/net/wireless/ath/wil6210/debug.c                              =
|   22 +-
 drivers/net/wireless/ath/wil6210/debugfs.c                            =
|  137 +-
 drivers/net/wireless/ath/wil6210/interrupt.c                          =
|   93 +-
 drivers/net/wireless/ath/wil6210/main.c                               =
|   95 +-
 drivers/net/wireless/ath/wil6210/p2p.c                                =
|    6 +
 drivers/net/wireless/ath/wil6210/txrx.c                               =
|    2 +-
 drivers/net/wireless/ath/wil6210/wil6210.h                            =
|   67 +-
 drivers/net/wireless/ath/wil6210/wmi.c                                =
|   97 +-
 drivers/net/wireless/ath/wil6210/wmi.h                                =
|   61 +
 drivers/net/wireless/atmel/atmel.c                                    =
|    2 +-
 drivers/net/wireless/broadcom/brcm80211/brcmfmac/bcmsdh.c             =
|    1 +
 drivers/net/wireless/broadcom/brcm80211/brcmfmac/chip.c               =
|    1 +
 drivers/net/wireless/broadcom/brcm80211/brcmfmac/sdio.c               =
|    4 +-
 drivers/net/wireless/cisco/airo.c                                     =
|    2 +-
 drivers/net/wireless/intel/iwlwifi/Kconfig                            =
|    6 -
 drivers/net/wireless/intel/iwlwifi/iwl-1000.c                         =
|    2 +-
 drivers/net/wireless/intel/iwlwifi/iwl-2000.c                         =
|    2 -
 drivers/net/wireless/intel/iwlwifi/iwl-5000.c                         =
|    2 +-
 drivers/net/wireless/intel/iwlwifi/iwl-6000.c                         =
|    3 -
 drivers/net/wireless/intel/iwlwifi/iwl-7000.c                         =
|    1 -
 drivers/net/wireless/intel/iwlwifi/iwl-8000.c                         =
|   15 +-
 drivers/net/wireless/intel/iwlwifi/iwl-9000.c                         =
|   34 +-
 drivers/net/wireless/intel/iwlwifi/iwl-config.h                       =
|  122 +-
 drivers/net/wireless/intel/iwlwifi/iwl-csr.h                          =
|   15 +
 drivers/net/wireless/intel/iwlwifi/iwl-drv.c                          =
|   39 +-
 drivers/net/wireless/intel/iwlwifi/iwl-eeprom-parse.h                 =
|    1 +
 drivers/net/wireless/intel/iwlwifi/iwl-fh.h                           =
|    3 +
 drivers/net/wireless/intel/iwlwifi/iwl-nvm-parse.c                    =
|   16 +-
 drivers/net/wireless/intel/iwlwifi/iwl-phy-db.c                       =
|   68 +-
 drivers/net/wireless/intel/iwlwifi/iwl-phy-db.h                       =
|    4 +-
 drivers/net/wireless/intel/iwlwifi/iwl-trans.h                        =
|    2 +
 drivers/net/wireless/intel/iwlwifi/mvm/constants.h                    =
|    1 +
 drivers/net/wireless/intel/iwlwifi/mvm/d3.c                           =
|    8 +-
 drivers/net/wireless/intel/iwlwifi/mvm/debugfs-vif.c                  =
|    9 +-
 drivers/net/wireless/intel/iwlwifi/mvm/debugfs.c                      =
|    2 +
 drivers/net/wireless/intel/iwlwifi/mvm/fw-api-d3.h                    =
|    2 +-
 drivers/net/wireless/intel/iwlwifi/mvm/fw-api-rx.h                    =
|    9 +-
 drivers/net/wireless/intel/iwlwifi/mvm/fw-api-sta.h                   =
|   10 +-
 drivers/net/wireless/intel/iwlwifi/mvm/fw-api.h                       =
|    5 +
 drivers/net/wireless/intel/iwlwifi/mvm/fw-dbg.c                       =
|   60 +-
 drivers/net/wireless/intel/iwlwifi/mvm/fw.c                           =
|    2 +-
 drivers/net/wireless/intel/iwlwifi/mvm/mac-ctxt.c                     =
|   22 +-
 drivers/net/wireless/intel/iwlwifi/mvm/mac80211.c                     =
|   74 +-
 drivers/net/wireless/intel/iwlwifi/mvm/mvm.h                          =
|  106 +-
 drivers/net/wireless/intel/iwlwifi/mvm/ops.c                          =
|   21 +-
 drivers/net/wireless/intel/iwlwifi/mvm/rx.c                           =
|   26 +-
 drivers/net/wireless/intel/iwlwifi/mvm/rxmq.c                         =
|  356 ++-
 drivers/net/wireless/intel/iwlwifi/mvm/sta.c                          =
|  410 ++-
 drivers/net/wireless/intel/iwlwifi/mvm/sta.h                          =
|   13 +-
 drivers/net/wireless/intel/iwlwifi/mvm/tt.c                           =
|    8 +-
 drivers/net/wireless/intel/iwlwifi/mvm/tx.c                           =
|   59 +-
 drivers/net/wireless/intel/iwlwifi/mvm/utils.c                        =
|   45 +-
 drivers/net/wireless/intel/iwlwifi/pcie/drv.c                         =
|   31 +-
 drivers/net/wireless/intel/iwlwifi/pcie/internal.h                    =
|    3 -
 drivers/net/wireless/intel/iwlwifi/pcie/rx.c                          =
|  111 +-
 drivers/net/wireless/intel/iwlwifi/pcie/trans.c                       =
|   29 +-
 drivers/net/wireless/intel/iwlwifi/pcie/tx.c                          =
|   21 +-
 drivers/net/wireless/marvell/mwifiex/pcie.h                           =
|    3 +-
 drivers/net/wireless/marvell/mwifiex/sdio.c                           =
|    5 +-
 drivers/net/wireless/realtek/rtl818x/rtl8187/rtl8187.h                =
|   99 +-
 drivers/net/wireless/realtek/rtl818x/rtl8187/rtl8225.c                =
|   93 +
 drivers/net/wireless/realtek/rtl8xxxu/Makefile                        =
|    3 +
 drivers/net/wireless/realtek/rtl8xxxu/rtl8xxxu.h                      =
|   81 +-
 drivers/net/wireless/realtek/rtl8xxxu/rtl8xxxu_8192c.c                =
|  586 ++++
 drivers/net/wireless/realtek/rtl8xxxu/rtl8xxxu_8192e.c                =
| 1525 ++++++++++
 drivers/net/wireless/realtek/rtl8xxxu/rtl8xxxu_8723a.c                =
|  397 +++
 drivers/net/wireless/realtek/rtl8xxxu/rtl8xxxu_8723b.c                =
| 1682 +++++++++++
 drivers/net/wireless/realtek/rtl8xxxu/{rtl8xxxu.c =3D> rtl8xxxu_core.c=
} | 5334 +++++------------------------------
 drivers/net/wireless/realtek/rtlwifi/base.c                           =
|    4 +-
 drivers/net/wireless/realtek/rtlwifi/pci.c                            =
|    4 +-
 drivers/net/wireless/realtek/rtlwifi/pci.h                            =
|    2 +-
 drivers/net/wireless/realtek/rtlwifi/ps.c                             =
|   12 +-
 drivers/net/wireless/realtek/rtlwifi/rtl8192se/rf.c                   =
|    3 +-
 drivers/net/wireless/realtek/rtlwifi/usb.c                            =
|    2 +-
 drivers/net/wireless/realtek/rtlwifi/wifi.h                           =
|    2 +-
 drivers/net/wireless/ti/wl12xx/main.c                                 =
|    4 +-
 drivers/net/wireless/ti/wlcore/io.c                                   =
|   17 +-
 drivers/net/wireless/ti/wlcore/io.h                                   =
|    3 +-
 drivers/net/xen-netback/hash.c                                        =
|    4 +-
 drivers/net/xen-netback/interface.c                                   =
|    3 +-
 drivers/scsi/iscsi_tcp.c                                              =
|   12 +-
 fs/ocfs2/cluster/tcp.c                                                =
|   17 +-
 include/linux/mmc/sdio_ids.h                                          =
|    1 +
 include/linux/netdev_features.h                                       =
|   12 +-
 include/linux/netdevice.h                                             =
|    4 +-
 include/linux/skbuff.h                                                =
|    8 +-
 include/net/act_api.h                                                 =
|    2 +-
 include/net/fou.h                                                     =
|   10 +-
 include/net/inet_common.h                                             =
|    5 +
 include/net/ip6_tunnel.h                                              =
|   58 +
 include/net/ip_tunnels.h                                              =
|   76 +-
 include/net/sock.h                                                    =
|    9 +-
 include/uapi/linux/libc-compat.h                                      =
|    2 +-
 kernel/bpf/core.c                                                     =
|    4 +-
 kernel/bpf/inode.c                                                    =
|    2 +-
 kernel/bpf/verifier.c                                                 =
|   30 +-
 net/batman-adv/bat_iv_ogm.c                                           =
|    9 +-
 net/batman-adv/bat_v.c                                                =
|   66 +-
 net/batman-adv/bat_v_elp.c                                            =
|   31 +-
 net/batman-adv/bat_v_elp.h                                            =
|    2 +
 net/batman-adv/originator.c                                           =
|    6 +-
 net/batman-adv/routing.c                                              =
|    4 +-
 net/core/ethtool.c                                                    =
|    4 +-
 net/ipv4/af_inet.c                                                    =
|   32 +-
 net/ipv4/fou.c                                                        =
|  144 +-
 net/ipv4/gre_offload.c                                                =
|   14 -
 net/ipv4/ip_tunnel.c                                                  =
|   45 -
 net/ipv4/ip_tunnel_core.c                                             =
|    9 +
 net/ipv4/ipip.c                                                       =
|    2 +-
 net/ipv4/tcp_offload.c                                                =
|   19 -
 net/ipv4/udp.c                                                        =
|    2 +-
 net/ipv4/udp_offload.c                                                =
|   10 -
 net/ipv6/Makefile                                                     =
|    1 +
 net/ipv6/fou6.c                                                       =
|  140 +
 net/ipv6/ip6_gre.c                                                    =
|   91 +-
 net/ipv6/ip6_input.c                                                  =
|   33 +-
 net/ipv6/ip6_offload.c                                                =
|   77 +-
 net/ipv6/ip6_tunnel.c                                                 =
|  190 +-
 net/ipv6/sit.c                                                        =
|    4 +-
 net/ipv6/udp.c                                                        =
|    2 +-
 net/ipv6/udp_offload.c                                                =
|   13 -
 net/kcm/kcmsock.c                                                     =
|    2 +-
 net/mpls/mpls_gso.c                                                   =
|   11 +-
 net/netfilter/ipvs/ip_vs_xmit.c                                       =
|   17 +-
 net/rds/tcp_connect.c                                                 =
|    4 +-
 net/rds/tcp_listen.c                                                  =
|   17 +-
 net/rds/tcp_recv.c                                                    =
|    4 +-
 net/rds/tcp_send.c                                                    =
|    4 +-
 net/tipc/server.c                                                     =
|    8 +-
 173 files changed, 8244 insertions(+), 5741 deletions(-)
 create mode 100644 drivers/net/wireless/realtek/rtl8xxxu/rtl8xxxu_8192=
c.c
 create mode 100644 drivers/net/wireless/realtek/rtl8xxxu/rtl8xxxu_8192=
e.c
 create mode 100644 drivers/net/wireless/realtek/rtl8xxxu/rtl8xxxu_8723=
a.c
 create mode 100644 drivers/net/wireless/realtek/rtl8xxxu/rtl8xxxu_8723=
b.c
 rename drivers/net/wireless/realtek/rtl8xxxu/{rtl8xxxu.c =3D> rtl8xxxu=
_core.c} (56%)
 create mode 100644 net/ipv6/fou6.c
