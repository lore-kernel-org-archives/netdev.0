From: David Miller <davem@davemloft.net>
Subject: [GIT] Networking
Date: Mon, 22 Sep 2014 18:54:04 -0400 (EDT)
Message-ID: <20140922.185404.1893813541008460948.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54412 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754119AbaIVWyH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Sep 2014 18:54:07 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


1) If the user gives us a msg_namelen of 0, don't try to interpret anything
   pointed to by msg_name.  From Ani Sinha.

2) Fix some bnx2i/bnx2fc randconfig compilation errors.

   The gist of the issue is that we firstly have drivers that span
   both SCSI and networking.  And at the top of that chain of
   dependencies we have things like SCSI_FC_ATTRS and SCSI_NETLINK
   which are selected.

   But since select is a sledgehammer and ignores dependencies,
   everything to select's SCSI_FC_ATTRS and/or SCSI_NETLINK has
   to also explicitly select their dependencies and so on and so
   forth.

   Generally speaking 'select' is supposed to only be used for child
   nodes, those which have no dependencies of their own.  And this
   whole chain of dependencies in the scsi layer violates that rather
   strongly.

   So just make SCSI_NETLINK depend upon it's dependencies, and so
   on and so forth for the things selecting it (either directly or
   indirectly).

   From Anish Bhatt and Randy Dunlap.

3) Fix generation of blackhole routes in IPSEC, from Steffen Klassert.

4) Actually notice netdev feature changes in rtl_open() code, from
   Hayes Wang.

5) Fix divide by zero in bond enslaving, from Nikolay Aleksandrov.

6) Missing memory barrier in sunvnet driver, from David Stevens.

7) Don't leave anycast addresses around when ipv6 interface is
   destroyed, from Sabrina Dubroca.

8) Don't call efx_{arch}_filter_sync_rx_mode before addr_list_lock
   is initialized in SFC driver, from Edward Cree.

9) Fix missing DMA error checking in 3c59x, from Neal Horman.

10) Openvswitch doesn't emit OVS_FLOW_CMD_NEW notifications accidently,	
    fix from Samuel Gauthier.

11) pch_gbe needs to select NET_PTP_CLASSIFY otherwise we can get
    a build error.

12) Fix macvlan regression wherein we stopped emitting
    broadcast/multicast frames over software devices.  From Nicolas
    Dichtel.

13) Fix infiniband bug due to unintended overflow of skb->cb[], from
    Eric Dumazet.  And add an assertion so this doesn't happen again.

14) dm9000_parse_dt() should return error pointers, not NULL.  From	
    Tobias Klauser.

15) IP tunneling code uses this_cpu_ptr() in preemptible contexts, fix
    from Eric Dumazet.

Please pull, thanks a lot!

The following changes since commit 35af25616c6c0c42416545f732d36b2ba7199519:

  Merge branch 'for-linus' of git://git.kernel.org/pub/scm/linux/kernel/git/s390/linux (2014-09-08 08:27:00 -0700)

are available in the git repository at:


  git://git.kernel.org/pub/scm/linux/kernel/git/davem/net.git master

for you to fetch changes up to e18b7faae15dbd47e5811ed748bd5b500dcfaa2d:

  Merge branch 'bcmgenet' (2014-09-22 18:38:53 -0400)

----------------------------------------------------------------

Aaro Koskinen (1):
      drivers: net: ethernet: octeon_mgmt: fix a compiler warning

Alexander Y. Fomichev (1):
      net: fix creation adjacent device symlinks

Alexei Starovoitov (1):
      sparc: bpf_jit: fix support for ldx/stx mem and SKF_AD_VLAN_TAG

Ani Sinha (1):
      net:socket: set msg_namelen to 0 if msg_name is passed as NULL in msghdr struct from userland.

Anish Bhatt (2):
      scsi_netlink : Make SCSI_NETLINK dependent on NET instead of selecting NET
      bnx2i/bnx2fc : fix randconfig error in next-20140909

Arend van Spriel (3):
      brcmfmac: conditionally compile firmware protocol source code
      brcmfmac: obtain ifp through wdev structure
      brcmfmac: handle IF event for P2P_DEVICE interface

Beniamino Galvani (2):
      net: arc_emac: enable tx interrupts
      net: arc_emac: prevent reuse of unreclaimed tx descriptors

Dan Carpenter (1):
      r8169: fix an if condition

David Dueck (1):
      can: at91_can: add missing prepare and unprepare of the clock

David Howells (1):
      RxRPC: Fix missing __user annotation

David Jander (3):
      can: flexcan: avoid calling usleep_range from interrupt context
      can: flexcan: correctly initialize mailboxes
      can: flexcan: implement workaround for errata ERR005829

David L Stevens (1):
      sunvnet - add missing rmb() for sunvnet driver

David S. Miller (14):
      Merge branch 'oom_fixes'
      Merge branch 'mlx4'
      Merge branch 'arc_emac'
      Merge tag 'linux-can-fixes-for-3.17-20140911' of git://gitorious.org/linux-can/linux-can
      Merge tag 'master-2014-09-11' of git://git.kernel.org/.../linville/wireless
      Merge branch 'r8169-net'
      Merge branch 'bridge_vlan_filtering'
      Merge branch 'bnx2-deps'
      Merge tag 'master-2014-09-16' of git://git.kernel.org/.../linville/wireless
      Merge tag 'linux-can-fixes-for-3.17-20140918' of git://gitorious.org/linux-can/linux-can
      scsi: Use 'depends' with LIBFC instead of 'select'.
      pch_gbe: 'select' NET_PTP_CLASSIFY.
      Merge branch 'master' of git://git.kernel.org/.../klassert/ipsec
      Merge branch 'bcmgenet'

Edward Cree (1):
      sfc: fix addr_list_lock spinlock use before init

Eliad Peller (1):
      iwlwifi: increase DEFAULT_MAX_TX_POWER

Emmanuel Grumbach (5):
      iwlwifi: mvm: enable scheduled scan on newest firmware
      mac80211: use bss_conf->dtim_period instead of conf.ps_dtim_period
      iwlwifi: mvm: fix endianity issues with Smart Fifo commands
      iwlwiwi: mvm: use bss_conf->dtim_period instead of conf.ps_dtim_period
      iwlwifi: dvm: disable power save by default

Eric Dumazet (4):
      net: fix skb_page_frag_refill() kerneldoc
      net: sched: shrink struct qdisc_skb_cb to 28 bytes
      ipoib: validate struct ipoib_cb size
      ipv4: do not use this_cpu_ptr() in preemptible context

Eyal Shapira (2):
      iwlwifi: mvm: treat EAPOLs like mgmt frames wrt rate
      iwlwifi: mvm: fix an overflow in iwl_mvm_get_signal_strength

Fabian Frederick (1):
      lib: rhashtable: remove second linux/log2.h inclusion

Florian Fainelli (4):
      net: systemport: check harder for out of memory conditions
      net: bcmgenet: check harder for out of memory conditions
      net: bcmgenet: fix TX reclaim accounting for fragments
      net: bcmgenet: call bcmgenet_dma_teardown in bcmgenet_fini_dma

Francesco Ruggeri (1):
      net: allow macvlans to move to net namespace

Hante Meuleman (1):
      brcmfmac: Fix memory leak and missing assignment.

Hariprasad Shenai (1):
      cxgb4: Don't allocate adapter structure for all PF's

Ivan Vecera (1):
      net/mlx4_en: do not ignore autoneg in mlx4_en_set_pauseparam()

Johannes Berg (4):
      nl80211: clear skb cb before passing to netlink
      iwlwifi: mvm: BT Coex - remove shadowing variable
      iwlwifi: mvm: correctly handle PM/QoS changes from mac80211
      iwlwifi: mvm: BT Coex - always initialize smps_mode

Johannes Stezenbach (1):
      ath9k_htc: fix random decryption failure

John W. Linville (2):
      Merge tag 'mac80211-for-john-2014-09-08' of git://git.kernel.org/.../jberg/mac80211
      Merge branch 'for-john' of git://git.kernel.org/.../iwlwifi/iwlwifi-fixes

Luciano Coelho (1):
      iwlwifi: mvm: set MAC_FILTER_IN_BEACON correctly for STA/P2P client

Marc Kleine-Budde (3):
      can: flexcan: mark TX mailbox as TX_INACTIVE
      can: flexcan: put TX mailbox into TX_INACTIVE mode after tx-complete
      can: flexcan: increase FLEXCAN_MCR_MAXMB() macro to 7 bits

Marcel Holtmann (1):
      net: rfkill: gpio: Enable module auto-loading for ACPI based switches

Mark Einon (1):
      drivers: net: b44: Fix typo in returning multicast stats

Markos Chandras (1):
      Documentation: filter: Add MIPS to architectures with BPF JIT

Masanari Iida (1):
      net:bonding: Add missing space in bonding driver parameter description

Matan Barak (4):
      net/mlx4: Correctly configure single ported VFs from the host
      net/mlx4: Use the correct VSD mask in UPDATE_QP
      net/mlx4: Avoid dealing with MAC index in UPDATE_QP wrapper if not needed
      net/mlx4: Set vlan stripping policy by the right command

Mike Looijmans (1):
      net/phy: micrel: Disable asymmetric pause for KSZ9031

Mugunthan V N (2):
      drivers: net: cpsw: dual_emac: fix reducing of rx descriptor during ifdown
      drivers: net: cpsw: dual_emac: in suspend/resume bring down/up all the netdev

Neil Horman (2):
      3c59x: Add dma error checking and recovery
      3c59x: Fix bad offset spec in skb_frag_dma_map

Nicolas Dichtel (2):
      genetlink: add function genl_has_listeners()
      macvlan: allow to enqueue broadcast pkt on virtual device

Nikolay Aleksandrov (1):
      bonding: fix div by zero while enslaving and transmitting

Oliver Hartkopp (1):
      can: peak_pci: add PCI ID definition pcie card variant

Or Gerlitz (1):
      mlx4: Fix wrong endianess access with QP context flags

Oren Givon (1):
      iwlwifi: add PCI IDs and add then new 3165 series

Randy Dunlap (2):
      scsi: fix build errors, SCSI_FC_ATTRS needs to depend on SCSI && NET
      scsi: use 'depends' instead of 'select' for SCSI_FC_ATTRS

Roger Quadros (1):
      can: c_can_platform: fix parameters of c_can_hw_raminit_ti()

Sabrina Dubroca (1):
      ipv6: clean up anycast when an interface is destroyed

Samuel Gauthier (1):
      openvswitch: restore OVS_FLOW_CMD_NEW notifications

Steffen Klassert (2):
      xfrm: Generate blackhole routes only from route lookup functions
      xfrm: Generate queueing routes only from route lookup functions

Sujith Manoharan (1):
      Revert "ath9k: Calculate sleep duration"

Tobias Klauser (1):
      dm9000: Return an ERR_PTR() in all error conditions of dm9000_parse_dt()

Vlad Yasevich (4):
      bridge: Check if vlan filtering is enabled only once.
      bridge: Allow clearing of pvid and untagged bitmap
      bridge: Fix br_should_learn to check vlan_enabled
      tg3: Work around HW/FW limitations with vlan encapsulated frames

hayeswang (4):
      r8169: fix the default setting of rx vlan
      r8169: fix setting rx vlan
      r8169: adjust __rtl8169_set_features
      r8152: disable ALDPS

 Documentation/networking/filter.txt                   |   6 +--
 arch/sparc/net/bpf_jit_comp.c                         |  25 +++++++---
 drivers/infiniband/hw/mlx4/main.c                     |   2 +-
 drivers/infiniband/hw/mlx4/qp.c                       |   2 +-
 drivers/infiniband/ulp/ipoib/ipoib.h                  |   6 +++
 drivers/infiniband/ulp/ipoib/ipoib_main.c             |   4 +-
 drivers/message/fusion/Kconfig                        |   2 +-
 drivers/net/bonding/bond_main.c                       |  19 ++++++--
 drivers/net/can/at91_can.c                            |   8 +--
 drivers/net/can/c_can/c_can_platform.c                |   4 +-
 drivers/net/can/flexcan.c                             |  53 ++++++++++++++++----
 drivers/net/can/sja1000/peak_pci.c                    |   6 ++-
 drivers/net/ethernet/3com/3c59x.c                     |  50 +++++++++++++++----
 drivers/net/ethernet/arc/emac_main.c                  |  53 ++++++++++++++------
 drivers/net/ethernet/broadcom/b44.c                   |   2 +-
 drivers/net/ethernet/broadcom/bcmsysport.c            |  31 +++++++-----
 drivers/net/ethernet/broadcom/genet/bcmgenet.c        | 143 ++++++++++++++++++++++++++++--------------------------
 drivers/net/ethernet/broadcom/tg3.c                   |  20 +++++++-
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c       |  49 ++++++++++---------
 drivers/net/ethernet/davicom/dm9000.c                 |   2 +-
 drivers/net/ethernet/mellanox/mlx4/cmd.c              |  21 ++++++++
 drivers/net/ethernet/mellanox/mlx4/en_ethtool.c       |   3 ++
 drivers/net/ethernet/mellanox/mlx4/qp.c               |  12 ++++-
 drivers/net/ethernet/mellanox/mlx4/resource_tracker.c |  38 +++++++++++----
 drivers/net/ethernet/octeon/octeon_mgmt.c             |   4 +-
 drivers/net/ethernet/oki-semi/pch_gbe/Kconfig         |   1 +
 drivers/net/ethernet/realtek/r8169.c                  |  67 +++++++++++++------------
 drivers/net/ethernet/sfc/farch.c                      |   3 ++
 drivers/net/ethernet/sun/sunvnet.c                    |   7 ++-
 drivers/net/ethernet/ti/cpsw.c                        |  52 ++++++++++++++++++--
 drivers/net/macvlan.c                                 |   4 +-
 drivers/net/phy/micrel.c                              |   3 +-
 drivers/net/usb/r8152.c                               |  62 ++++++++++++++++-------
 drivers/net/wireless/ath/ath9k/common-beacon.c        |   5 +-
 drivers/net/wireless/ath/ath9k/htc_drv_txrx.c         |   2 +-
 drivers/net/wireless/brcm80211/Kconfig                |  10 ++++
 drivers/net/wireless/brcm80211/brcmfmac/Makefile      |  10 ++--
 drivers/net/wireless/brcm80211/brcmfmac/bcdc.h        |   7 ++-
 drivers/net/wireless/brcm80211/brcmfmac/fweh.c        |  12 +++--
 drivers/net/wireless/brcm80211/brcmfmac/fweh.h        |   2 +
 drivers/net/wireless/brcm80211/brcmfmac/msgbuf.h      |  11 ++++-
 drivers/net/wireless/brcm80211/brcmfmac/wl_cfg80211.c |   9 +++-
 drivers/net/wireless/iwlwifi/dvm/power.c              |   2 +-
 drivers/net/wireless/iwlwifi/iwl-7000.c               |  16 ++++++
 drivers/net/wireless/iwlwifi/iwl-config.h             |   3 ++
 drivers/net/wireless/iwlwifi/iwl-nvm-parse.c          |   4 +-
 drivers/net/wireless/iwlwifi/mvm/coex.c               |   9 ++--
 drivers/net/wireless/iwlwifi/mvm/debugfs-vif.c        |   3 +-
 drivers/net/wireless/iwlwifi/mvm/fw-api.h             |   4 +-
 drivers/net/wireless/iwlwifi/mvm/mac-ctxt.c           |  10 ++--
 drivers/net/wireless/iwlwifi/mvm/mac80211.c           |  25 +++++-----
 drivers/net/wireless/iwlwifi/mvm/power.c              |   5 +-
 drivers/net/wireless/iwlwifi/mvm/rx.c                 |   6 +--
 drivers/net/wireless/iwlwifi/mvm/sf.c                 |   2 +-
 drivers/net/wireless/iwlwifi/mvm/tx.c                 |   8 ++-
 drivers/net/wireless/iwlwifi/pcie/drv.c               |   7 +++
 drivers/scsi/Kconfig                                  |  20 ++++----
 drivers/scsi/bnx2fc/Kconfig                           |   5 +-
 drivers/scsi/bnx2i/Kconfig                            |   1 +
 drivers/scsi/csiostor/Kconfig                         |   2 +-
 drivers/scsi/qla2xxx/Kconfig                          |   4 +-
 include/linux/mlx4/device.h                           |   1 +
 include/linux/mlx4/qp.h                               |  12 ++++-
 include/net/addrconf.h                                |   1 +
 include/net/dst.h                                     |  16 +++++-
 include/net/genetlink.h                               |   8 +++
 include/net/sch_generic.h                             |   3 +-
 lib/rhashtable.c                                      |   1 -
 net/bridge/br_private.h                               |   3 ++
 net/bridge/br_vlan.c                                  |  16 ++++--
 net/core/dev.c                                        |  18 ++++---
 net/core/sock.c                                       |   2 +-
 net/ipv4/ip_tunnel.c                                  |   6 +--
 net/ipv4/route.c                                      |   6 +--
 net/ipv6/addrconf.c                                   |   8 +--
 net/ipv6/anycast.c                                    |  21 ++++++++
 net/ipv6/ip6_output.c                                 |   4 +-
 net/mac80211/sta_info.c                               |   2 +-
 net/openvswitch/datapath.c                            |   9 ++--
 net/rfkill/rfkill-gpio.c                              |   1 +
 net/rxrpc/ar-key.c                                    |   2 +-
 net/sched/sch_choke.c                                 |  18 +++++--
 net/socket.c                                          |   3 ++
 net/wireless/nl80211.c                                |   6 +++
 net/xfrm/xfrm_policy.c                                |  48 +++++++++++++++---
 85 files changed, 828 insertions(+), 355 deletions(-)
