From: David Miller <davem@davemloft.net>
Subject: [GIT]: Networking
Date: Sat, 05 Dec 2009 19:35:05 -0800 (PST)
Message-ID: <20091205.193505.193701079.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-2022-jp-2
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:57097
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1758027AbZLFDfC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 5 Dec 2009 22:35:02 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


As usual the bulk of the changes are in the drivers, along with
the usual large set of infrastructure changes in the wireless
mac80211 layer.

Some nice optimizations from Eric Dumazet, particularly in the
area of RCU based network device lookups and unregistering
many devices at once.

Eric Biederman simplified namespace shutdown enormously and
this has brought some namespace destruction test cased down
from several minutes to less than a second.

Please pull, thanks a lot!

The following changes since commit 6ec22f9b037fc0c2e00ddb7023fad279c365324d:
  Linus Torvalds (1):
        Merge branch 'x86-debug-for-linus' of git://git.kernel.org/.../tip/linux-2.6-tip

are available in the git repository at:

  master.kernel.org:/pub/scm/linux/kernel/git/davem/net-next-2.6.git master

Abhijeet Kolekar (7):
      iwlwifi/iwl3945 : unify apm stop operation
      iwlwifi: replace iwl_poll_direct_bit with iwl_poll_bit for CSR access
      iwlwifi/iwl3945: unify rts_tx_cmd_flag
      iwl3945: rename tx to tx_cmd
      iwlwifi/iwl3945: remove data_retry_limit
      iwl3945: rearrange the code.
      iwl3945: disable all tx fifos

Ajit Khaparde (25):
      be2net: Get rid of net_device_stats from adapter.
      e1000e: Use the instance of net_device_stats from net_device.
      netxen: Use the instance of net_device_stats from net_device.
      myri10ge: Use the instance of net_device_stats from net_device.
      ixgbe: Use the instance of net_device_stats from net_device.
      igb: Use the instance of net_device_stats from net_device.
      e1000: Use the instance of net_device_stats from net_device.
      qlge: Use the instance of net_device_stats from net_device.
      ixgb: Use the instance of net_device_stats from net_device.
      ixgbe: Fix erroneous display of stats by ethtool -S
      e1000e: Fix erroneous display of stats by ethtool -S
      e1000: Fix erroneous display of stats by ethtool -S
      igb: Fix erroneous display of stats by ethtool -S
      ixgb: Fix erroneous display of stats by ethtool -S
      be2net: Add support for next generation of BladeEngine device.
      be2net: Add the new PCI IDs to PCI_DEVICE_TABLE.
      be2net: set netdev->vlan_features appropriately
      be2net: initialize netdev->perm_addr
      be2net: check for valid ether address
      be2net: fix to allow port beacon when device is closed
      be2net: Add be_rx_polls counter
      be2net: fix unnecessary access to hardware to get link, port info
      be2net: Changes to print fw command opcode when command is failed by controller.
      be2net: Support for WoL using magic packet after suspend.
      be2net: Bump up the driver version number

Alan Cox (1):
      cosa: Kill off the use of the old ioctl path

Alban Browaeys (1):
      wireless : use a dedicated workqueue for cfg80211.

Alexander Duyck (79):
      igb: remove unused temp variable from stats clearing path
      igb: update comments for serdes config and update to handle duplex
      igb: update the approach taken to acquiring and releasing the phy lock
      igb: add locking to reads of the i2c interface
      igb: add combined function for setting rar and pool bits
      igb: make use of the uta to allow for promiscous mode filter
      igb: add support for 82576NS SerDes adapter
      igb: add function to handle mailbox lock
      igb: fix a few items where weren't correctly setup for mbx timeout
      igb: change how we handle alternate mac addresses
      igb: remove microwire support from igb
      igb: move the generic copper link setup code into e1000_phy.c
      igb: add code to retry a phy read in the event of failure on link check
      igb: add additional error handling to the phy code
      igb: add flushes between RAR writes when setting mac address
      igb: add new data structure for handling interrupts and NAPI
      igb: remove rx checksum good counter
      igb: increase minimum rx buffer size to 1K
      igb: move the tx and rx ring specific config into seperate functions
      igb: remove rx_ps_hdr_len
      igb: move SRRCTL register configuration into ring specific config
      igb: change the head and tail offsets into pointers
      igb: add pci device pointer to ring structure
      igb: move rx_buffer_len into the ring structure
      igb: move alloc_failed and csum_err stats into per rx-ring stat
      igb: add a flags value to the ring
      igb: place a pointer to the netdev struct in the ring itself
      igb: move the multiple receive queue configuration into seperate function
      igb: delay VF reset notification until after interrupts are enabed
      igb: setup vlan tag replication stripping in igb_vmm_control
      igb: re-use ring configuration code in ethtool testing
      igb: make tx ring map and free functionality non-static
      igb: make ethtool use core xmit map and free functionality
      igb: add single vector msi-x testing to interrupt test
      igb: cleanup "todo" code found in igb_ethtool.c
      igb: add support for seperate tx-usecs setting in ethtool
      igb: cleanup some of the code related to hw timestamping
      igb: misc cleanups within igb_ethtool.c
      igb: use packet buffer sizes from RXPBS register
      igb: replace the VF clear_to_send with a flags value
      igb: rework use of VMOLR in regards to PF and VFs
      igb: rework handling of the vfta and vlvf registers in relation to mng_vlan
      igb: move vf init into a seperate function
      igb: only process global stats in igb_update_stats
      igb: move global_quad_port_a from global into local static define
      igb: make tx hang check multiqueue, check eop descriptor
      igb: cleanup code related to ring resource allocation and free
      igb: change queue ordering for 82576 based adapters
      igb: cleanup interrupt enablement in regards to msix_other
      igb: Remove invalid stats counters
      igb: cleanup igb.h header whitespace and some structure formatting
      igb: cleanup igb xmit frame path
      igb: cleanup clean_rx_irq_adv and alloc_rx_buffers_adv
      igb: replace unecessary &adapter->hw with just hw where applicable
      igb: add pci_dev in few spots to clean up use of dev_err/info/warn
      igb: limit minimum mtu to 68 to keep ip bound to interface
      igb: open up SCTP checksum offloads to all MACs 82576 and newer
      igb: cleanup whitespace issues in igb_main.c
      igb: change type for ring sizes to u16 in igb_set_ring_param
      igb: move timesync init into a seperate function
      igb: when number of CPUs > 4 combine tx/rx queues to allow more queues
      igb: Rework how netdev->stats is handled
      igb: removed unused tx/rx total bytes/packets from adapter struct
      igb: check for packets on all tx rings when link is down
      igb: only recycle page if it is on our numa node
      igb: add support for the 82580 phy
      igb: add support for 82580 MAC
      igb: Add full support for 82580 devices
      ixgbe: Only set/clear VFE in ixgbe_set_rx_mode
      e1000e: remove use of skb_dma_map from e1000e driver
      e1000: remove use of skb_dma_map from e1000 driver
      ixgb: remove use of skb_dma_map from ixgb
      ixgbe: remove skb_dma_map/unmap calls from driver
      igb: remove use of skb_dma_map from driver
      igbvf: remove skb_dma_map/unmap call from drivers
      bnx2: remove skb_dma_map/unmap calls from driver
      be2net: remove use of skb_dma_map/unmap
      tg3: remove use of skb_dma_map/unmap
      skbuff: remove skb_dma_map/unmap

Alexandre Cassen (1):
      IPv6: Fix 6RD typo

Alexey Dobriyan (4):
      net: convert /proc/net/rt_acct to seq_file
      r8169: move PHY regs tables to .rodata
      ray_cs: convert to proc_fops
      ipw2x00: convert to seq_file

Ali Gholami Rudi (1):
      ixgbe: r_idx not used in ixgbe_msix_clean_rx()

Amerigo Wang (1):
      sctp: remove deprecated SCTP_GET_*_OLD stuffs

Amit Kumar Salecha (10):
      netxen: remove sub 64-bit mem accesses
      netxen: defines for next revision
      netxen: 128 memory controller support
      netxen: reset sequence changes
      netxen: onchip memory access change
      netxen: support for new firmware file format
      netxen: update MAINTAINERS
      netxen: remove PCI IDs of CNA device
      netxen: fix merge 9b963e5d0e01461099a
      netxen: fix failure cases for fw hang recovery

Amitkumar Karwar (4):
      libertas: Add auto deep sleep support for SD8385/SD8686/SD8688
      libertas: Use lbs_is_cmd_allowed() check in command handling routines.
      libertas: Check return status of command functions
      Bluetooth: Enable auto sleep mode for btmrvl driver

Anant Gole (1):
      can: add TI CAN (HECC) driver

Andreas Petlund (1):
      net: Corrected spelling error heurestics->heuristics

Andrei Pelinescu-Onciul (4):
      sctp: allow setting path_maxrxt independent of SPP_PMTUD_ENABLE
      sctp: limit maximum autoclose setsockopt value
      sctp: fix integer overflow when setting the autoclose timer
      sctp: fix sctp_setsockopt_autoclose compile warning

Andrew Hendry (1):
      X25: Enable setting of cause and diagnostic fields

Andrew Morton (1):
      drivers/atm/solos-pci.c: fix warning/bug, clean up code

Andrey Yurovsky (1):
      libertas: remove internal buffers from GSPI driver

Andy Gospodarek (1):
      net: export device speed and duplex via sysfs

Andy Grover (5):
      RDS: Add GET_MR_FOR_DEST sockopt
      RDS: Fix potential race around rds_i[bw]_allocation
      RDS: Fix panic on unload
      RDS: Do not send congestion updates to loopback connections
      RDS/IB+IW: Move recv processing to a tasklet

Anton Vorontsov (17):
      gianfar: Some cleanups for startup_gfar()
      gianfar: Simplify skb resources freeing code
      gianfar: Don't needlessly set the wrap bit for the last RX BD
      gianfar: Split allocation and initialization steps out of startup_gfar()
      gianfar: Move tbase/rbase initialization to gfar_init_mac()
      gianfar: Factor out RX BDs initialization from gfar_new_rxbdp()
      gianfar: Factor out gfar_init_bds() from gfar_alloc_skb_resources()
      gianfar: Add support for hibernation
      fsl_pq_mdio: Fix compiler/sparse warnings (part 1)
      fsl_pq_mdio: Fix compiler/sparse warnings (part 2)
      gianfar: Fix compiler and sparse warnings
      skbuff: Do not allow skb recycling with disabled IRQs
      gianfar: Remove 'Interrupt problem!' warning
      gianfar: Fix build with CONFIG_PM=y
      gianfar: Fix thinko in gfar_set_rx_stash_index()
      gianfar: Fix race between gfar_error() and gfar_start_xmit()
      gianfar: Revive SKB recycling

Arnaldo Carvalho de Melo (5):
      net: Introduce recvmmsg socket syscall
      ia64: Fix up the syscall table for recvmmsg
      net: Avoid compiler warning for mmsghdr when CONFIG_COMPAT is not selected
      alpha: Fixup recvmmsg syscall glue
      MIPS: Wire up recvmmsg syscall

Arnd Bergmann (21):
      compat: add struct compat_ifreq etc to compat.h
      net/tun: handle compat_ioctl directly
      net, compat_ioctl: handle socket ioctl abuses in tty drivers
      net: copy socket ioctl code to net/socket.h
      appletalk:,A handle SIOCATALKDIFADDR compat ioctl
      compat: move sockios handling to net/socket.c
      net, compat_ioctl: handle more ioctls correctly
      net/appletalk: push down BKL into a atalk_dgram_ops
      net/ipx: push down BKL into a ipx_dgram_ops
      net/irda: push BKL into proto_ops
      net/x25: push BKL usage into x25_proto
      net: kill proto_ops wrapper
      net, compat_ioctl: fix SIOCGMII ioctls
      net/compat_ioctl: support SIOCWANDEV
      net/compat: fix dev_ifsioc emulation corner cases
      net/atm: move all compat_ioctl handling to atm/ioctl.c
      hamradio/mkiss: fix typo in compat_ioctl
      veth: move loopback logic to common location
      macvlan: cleanup rx statistics
      macvlan: implement bridge, VEPA and private mode
      macvlan: export macvlan mode through netlink

Atis Elsts (1):
      net: Add sk_mark route lookup support for IPv4 listening sockets

Atsushi Nemoto (4):
      tc35815: Fix return value of tc35815_do_interrupt when NAPI enabled
      tc35815: Enable NAPI
      tc35815: Kill non-napi code
      tc35815: Kill unused code

Bartlomiej Zolnierkiewicz (51):
      rt2800usb: make Kconfig help entry more helpful
      rt2800pci: make Kconfig help entry more helpful
      rt2800usb: fix rt2800usb_rfcsr_read()
      rt2800pci: fix crypto in TX frame
      rt2800pci: fix comment about register access
      rt2800pci: fix comment about IV/EIV fields
      rt2x00: fix rt2x00usb_register_read() comment
      rt2800usb: use rt2x00usb_register_multiwrite() to set key entries
      rt2800usb: fix comments in rt2800usb.h
      rt2x00: remove needless ifdefs from rt2x00leds.h
      rt2800usb: add rt2800_register_[read,write]() wrappers
      rt2800pci: add rt2800_register_[read,write]() wrappers
      rt2800usb: add rt2800_register_multi[read,write]() wrappers
      rt2800pci: add rt2800_register_multi[read,write]() wrappers
      rt2800usb: add rt2800_regbusy_read() wrapper
      rt2800pci: add rt2800_regbusy_read() wrapper
      rt2800usb: add rt2800_bbp_[read,write]() wrappers
      rt2800pci: add rt2800_bbp_[read,write]() wrappers
      rt2800usb: add rt2800_rfcsr_[read,write]() wrappers
      rt2800pci: add rt2800_rfcsr_[read,write]() wrappers
      rt2800usb: add rt2800_rf_[read,write]() wrappers
      rt2800pci: add rt2800_rf_[read,write]() wrappers
      rt2800usb: add rt2800_mcu_request() wrapper
      rt2800pci: add rt2800_mcu_request() wrapper
      rt2x00: add driver private field to struct rt2x00_dev
      rt2800usb: convert to use struct rt2800_ops methods
      rt2800pci: convert to use struct rt2800_ops methods
      rt2x00: fix rt2x00usb_register_multiwrite() arguments
      rt2x00: fix rt2x00usb_regbusy_read() arguments
      rt2x00: fix rt2x00pci_register_multi[read,write]() arguments
      rt2800: add rt2800lib.h
      rt2800usb: add RXINFO_DESC_SIZE definition
      rt2800: fix duplication in header files
      rt2800: fix comments in rt2800.h
      rt2x00: add support for different chipset interfaces
      rt2800: prepare for rt2800lib addition
      rt2800: add rt2800lib (part one)
      rt2800: add rt2800lib (part two)
      rt2x00: move REGISTER_BUSY_* definitions to rt2x00.h
      rt2800: add rt2800lib (part three)
      rt2800: add rt2800lib (part four)
      rt2800: prepare for unification of EEPROM support code
      rt2800: unify EEPROM support code
      rt2800pci: add missing RF values to rf_vals table
      rt2800usb: reorganize code in rt2800usb_probe_hw_mode()
      rt2800: prepare for rt2800*_probe_hw_mode() unification
      rt2800: unify rt2800*_probe_hw_mode()
      rt2800usb: fix RX descriptor naming
      rt2800: add eFuse EEPROM support code to rt2800lib
      rt2800usb: add eFuse EEPROM support
      rt2500usb: remove dead link tuning code

Ben Dooks (1):
      DM9000: Wake on LAN support

Ben Hutchings (130):
      qeth: Convert ethtool get_stats_count() ops to get_sset_count()
      tehuti: Convert ethtool get_stats_count() ops to get_sset_count()
      net: Convert ethtool {get_stats, self_test}_count() ops to get_sset_count()
      ethtool: Remove support for obsolete string query operations
      ethtool: Add reset operation
      mdio: Advertise pause (flow control) settings even if autoneg is off
      mdio: Expose pause frame advertising flags to ethtool
      sfc: 10Xpress: Initialise pause advertising flags
      sfc: 10Xpress: Report support for pause frames
      sfc: Remove redundant header gmii.h
      sfc: Remove redundant hardware initialisation
      sfc: Rename Falcon-specific board code and types
      sfc: Merge sfe4001.c into falcon_boards.c
      sfc: Remove boards.h, moving last remaining declaration to falcon.h
      sfc: Remove versioned bitfield macros
      sfc: Move RX data FIFO thresholds out of struct efx_nic_type
      sfc: Update hardware definitions for Siena
      sfc: Rename register I/O header and functions used by both Falcon and Siena
      sfc: Eliminate indirect lookups of queue size constants
      sfc: Define DMA address mask explicitly in terms of descriptor field width
      sfc: Move all TX DMA length limiting into tx.c
      sfc: Merge struct efx_blinker into struct efx_board
      sfc: Change order of device removal to reverse of probe order
      sfc: Remove declarations of nonexistent functions
      sfc: Move efx_xmit_done() declaration into correct stanza
      sfc: Move shared members of struct falcon_nic_data into struct efx_nic
      sfc: Maintain interrupt moderation values in ticks, not microseconds
      sfc: Removed kernel-doc for nonexistent member of efx_phy_operations
      sfc: Remove pointless abstraction of memory BAR number
      sfc: Merge falcon_probe_phy() into falcon_probe_port()
      sfc: Remove incorrect assertion from efx_pci_remove_main()
      sfc: Remove unnecessary tests of efx->membase
      sfc: Move MTD probe after netdev registration and name allocation
      sfc: Merge efx_fc_resolve() into efx_mdio_get_pause()
      sfc: Remove unused code for non-autoneg speed/duplex switching
      sfc: Rename 'xfp' file and functions to reflect reality
      sfc: Really allow RX checksum offload to be disabled
      via-velocity: Remove private device list
      gro: Name the GRO result enumeration type
      gro: Change all receive functions to return GRO result codes
      sfc: Feed GRO result into RX allocation policy and interrupt moderation
      sfc: Enable heuristic selection between page and skb RX buffers
      netx: declare MODULE_FIRMWARE
      solos-pci: declare MODULE_FIRMWARE
      ambassador: declare MODULE_FIRMWARE
      bnx2x: declare MODULE_FIRMWARE
      cxgb3: declare MODULE_FIRMWARE
      myri10ge: declare MODULE_FIRMWARE
      spider-net: declare MODULE_FIRMWARE
      tms380tr: declare MODULE_FIRMWARE
      pcnet-cs: declare MODULE_FIRMWARE
      speedfax: declare MODULE_FIRMWARE
      usbnet: Set link down initially for drivers that update link state
      at76c50x-usb: declare MODULE_FIRMWARE
      atmel: declare MODULE_FIRMWARE
      ipw2100: declare MODULE_FIRMWARE
      ipw2200: declare MODULE_FIRMWARE
      iwmc3200wifi: declare MODULE_FIRMWARE
      libertas: declare MODULE_FIRMWARE
      libertas_tf_usb: declare MODULE_FIRMWARE
      mwl8k: declare MODULE_FIRMWARE
      orinoco: declare MODULE_FIRMWARE
      prism54: declare MODULE_FIRMWARE
      wl12xx: declare MODULE_FIRMWARE
      zd1201: declare MODULE_FIRMWARE
      zd1211rw: declare MODULE_FIRMWARE
      sfc: Remove pointless abstraction of memory BAR number (2)
      sfc: Remove redundant gotos from __efx_rx_packet()
      sfc: Remove ridiculously paranoid assertions
      sfc: Move assertions and buffer cleanup earlier in efx_rx_packet_lro()
      sfc: Record RX queue number on GRO path
      sfc: SFT9001: Reset LED configuration correctly after blinking
      sfc: Use a single blink implementation
      sfc: Rename efx_board::init_leds to init_phy and use for SFN4111T
      sfc: Make board information explicitly Falcon-specific
      sfc: Move definition of struct falcon_nic_data into falcon.h
      sfc: Move struct falcon_board into struct falcon_nic_data
      sfc: Move all I2C stuff into struct falcon_board
      sfc: Gather link state fields in struct efx_nic into new struct efx_link_state
      sfc: Remove unnecessary casts to struct sk_buff *
      sfc: Remove redundant efx_xmit() function
      sfc: Combine high-level header files
      sfc: Log interrupt and reset type names, not numbers
      sfc: Fix descriptor cache sizes
      sfc: Treat all MAC registers as 128-bit
      sfc: Strengthen EFX_ASSERT_RESET_SERIALISED
      sfc: Comment corrections
      sfc: Remove unused constant
      sfc: Clean up struct falcon_board and struct falcon_board_data
      sfc: Fix bugs in RX queue flushing
      sfc: Remove unused function efx_flush_queues()
      sfc: Hold MAC lock for longer in efx_init_port()
      sfc: Split MAC stats DMA initiation and completion
      sfc: Move Falcon board/PHY/MAC monitoring code to falcon.c
      sfc: Simplify XMAC link polling
      sfc: Change MAC promiscuity and multicast hash at the same time
      sfc: Move inline comment into kernel-doc
      sfc: Do not set net_device::trans_start in self-test
      sfc: Limit some hardware workarounds to Falcon
      sfc: Remove another unused workaround macro
      sfc: Remove some redundant whitespace
      sfc: Decouple NIC revision number from Falcon PCI revision number
      sfc: Move descriptor cache base addresses to struct efx_nic_type
      sfc: Clean up RX event handling
      sfc: Remove redundant writes to INT_ADR_KER
      sfc: Remove duplicate hardware structure definitions
      sfc: Turn pause frame generation on and off at the MAC, not the RX FIFO
      sfc: Move Falcon NIC operations to efx_nic_type
      sfc: Refactor link configuration
      sfc: Add power-management and wake-on-LAN support
      sfc: Implement ethtool reset operation
      sfc: Add efx_nic_type operation for register self-test
      sfc: Add efx_nic_type operation for NVRAM self-test
      sfc: Add efx_nic_type operation for identity LED control
      sfc: Separate shared NIC code from Falcon-specific and rename accordingly
      sfc: Fold falcon_probe_nic_variant() into falcon_probe_nic()
      sfc: Extend loopback mode enumeration
      sfc: Remove static PHY data and enumerations
      sfc: Extend MTD driver for use with new NICs
      sfc: Allow for additional checksum offload features
      sfc: Rename falcon.h to nic.h
      sfc: Move shared NIC code from falcon.c to new source file nic.c
      sfc: Add support for SFC9000 family (1)
      sfc: Add support for SFC9000 family (2)
      sfc: Implement TSO for TCP/IPv6
      sfc: Update version, copyright dates, authors
      atl1e: Allow TX checksum offload and TSO to be disabled and reenabled
      atl1e: Remove redundant definitions of ethtool operations
      atl1e: Remove non-implementation of ethtool set_msglevel() operation
      Bluetooth: Declare MODULE_FIRMWARE for Marvell SDIO driver

Ben M Cahill (23):
      iwl3945: update iwl3945_apm_init()
      iwlwifi: turn off device when not used.
      iwl3945: remove unnecessary call to apm_ops.reset()
      iwlagn, iwl3945: remove apm_reset() functions
      iwl3945: streamline iwl3945_rfkill_poll()
      iwl3945: move iwl_power_initialize()
      iwlwifi: consolidate apm_init() functions
      iwlwifi: make sure device is reset when unloading driver
      iwlwifi: remove unneeded locks from apm_stop() and stop_master()
      iwlwifi: remove power-wasting calls to apm_ops.init()
      iwlagn: invoke L0S workaround for 6000/1000 series
      iwlagn: Clarify FH_TX interrupt
      iwlagn: update write pointers for all tx queues after wakeup
      iwlwifi: Limit size of Event Log dump
      iwlwifi: speed up event log dumps
      iwlwifi: Update comments for struct iwl_ssid_ie
      iwlwifi: Add comments about MAC_ACCESS_REQ
      iwlagn: update write pointers in iwl_irq_tasklet()
      iwlwifi: MAC_ACCESS_REQ cleanup
      iwl3945: Reset saved POWER_TABLE_CMD in "up"
      iwlwifi: Add comments about CSR registers
      iwlwifi: Add iwl_write8()
      iwlagn: Use iwl_write8() for CSR_INT_COALESCING register

Benoit PAPILLAULT (2):
      zd1211rw: Fix TX status reporting in order to have proper rate control
      ath9k: This patch fix RX unpadding for any received frame.

Benoit Papillault (1):
      ath9k: Proper padding/unpadding for the TX/RX path.

Bob Copeland (2):
      ath5k: use noise calibration from madwifi hal
      ath5k: allow setting txpower to 0

Breno Leitao (1):
      bnx2: EEH is failing with timeout

Brian Haley (5):
      Use sk_mark for IPv6 routing lookups
      IPv6: Fix 6RD build error
      IPv6: use ipv6_addr_copy() in ip6_route_redirect()
      IPv6: use ipv6_addr_set_v4mapped()
      IPv6: use ipv6_addr_v4mapped()

Bruce Allan (35):
      e1000e: flow control doesn't re-enable
      e1000e: check WoL mode is among set of supported modes
      e1000e: add missing tests for 82583 in ethtool functions
      e1000e: clearing interrupt timers causes descriptors to get flushed
      e1000e: function pointers for ethtool set/get offloads
      e1000e: don't clean Rx ring while resetting
      e1000e: link reporting problems
      e1000e: improper return code signage
      e1000e: disable K1 on PCH LOM when in PHY loopback mode
      e1000e: Incorrect MII Link beat reporting.
      e1000e: cleanup redundant #include's
      e1000e: consolidate two dbug macros into one simpler one
      e1000e: cleanup ops function pointers
      e1000e: update copyright information
      e1000e: remove comments regarding a non-existent api module
      e1000e: provide comment for 82571 workaround
      e1000e: set bools to true/false instead of 1/0
      e1000e: cleanup - shift indentation left by exiting early in e1000_tso
      e1000e: cleanup functions that clear hardware statistics
      e1000e: set pm_qos DMA latency requirement per interface when needed
      e1000e: do not error out on identification LED init failure
      e1000e: remove redundant might_sleep()
      e1000e: cosmetic - group local variables of the same type
      e1000e: update Tx Unit hang detection message
      e1000e: provide family-specific functions to manage VLAN filter arrays
      e1000e: guard against buffer overflow in cable length tables
      e1000e: provide family-specific PHY power up/down operations
      e1000e: ensure the link state is correct for serdes links
      e1000e: enable new 82567V-3 device
      e1000e: comment corrections
      e1000e: add debug messages
      e1000e: PHY type cleanups in e1000e_check_downshift()
      e1000e: check_polarity function pointers not set for 8257x
      e1000e: refactor PHY ID detection workaround
      e1000e: correct ICH/PCH PHY operations function pointers

Changli Gao (3):
      netfilter: nf_conntrack: avoid additional compare.
      act_mirred: cleanup
      act_mirred: optimization.

Christian Lamparter (6):
      iwlwifi: drop lib80211 dependency
      ar9170: atomic pending A-MPDU counter
      ar9170usb: atomic pending urbs counter
      ar9170: don't filter BlockACK frames
      p54: disable channels with incomplete calibration data sets
      ar9170: do not discard valuable DUPOFDM frames

Christian Pellegrin (2):
      can: Driver for the Microchip MCP251x SPI CAN controllers
      can: fix setting mcp251x bit timing on open

Cindy H Kao (9):
      wimax/i2400m: fix the bootmode RX deadlock in SDIO driver
      wimax/iwmc3200: overwrite SDIO IOR timeout value to avoid platform hang
      wimax/iwmc3200: don't disable the SDIO function if enable fails
      wimax/iwmc3200: increase wait time before enable retry
      wimax/i2400m/sdio: clear the INTR status bit after reading size
      wimax/i2400m: don't write to memory allocated by request_firmware()
      wimax/iwmc3200: add new sdio device ID to support iwmc3200 2.5GHz sku
      wimax/i2400m: use JUMP cmd for last FW chunk indication
      wimax/i2400m: change the bcf_len to exclude the extended header size

Cosmin Ratiu (1):
      ipv6: fix devconf after adding force_tllao option

Cyrill Gorcunov (2):
      net,socket: introduce DECLARE_SOCKADDR helper to catch overflow at build time
      net: netlink_getname, packet_getname -- use DECLARE_SOCKADDR guard

Dan Williams (1):
      i2400m: minimal ethtool support

Daniel C Halperin (5):
      iwlwifi: clean up rs_tx_status
      iwlwifi: do not clear TX info flags when receiving BlockAckResponse
      iwlwifi: add aggregation tables to the rate scaling algorithm
      iwlwifi: fix bugs in beacon configuration
      iwlwifi: make iwlwifi send beacons

David Graham (1):
      e100: Fix to allow systems with FW based cards to resume from STD

David Kilroy (1):
      orinoco: use cfg80211 ethtool ops

David S. Miller (38):
      Merge branch 'master' of master.kernel.org:/.../davem/net-2.6
      Merge branch 'master' of git://git.kernel.org/.../linville/wireless-next-2.6
      Merge branch 'master' of master.kernel.org:/.../davem/net-2.6
      Revert "af_packet: add interframe drop cmsg (v6)"
      cnic: Need to include net/ip6_checksum.h
      Merge branch 'master' of master.kernel.org:/.../davem/net-2.6
      sparc: Add missing __NR_recvmmsg define.
      Merge branch 'master' of master.kernel.org:/.../davem/net-2.6
      igb: Fix warnings in igb_set_ringparam()
      Merge branch 'master' of git://git.kernel.org/.../linville/wireless-next-2.6
      Merge branch 'master' of master.kernel.org:/.../davem/net-2.6
      net: Fix build warning in sock_bindtodevice().
      Merge branch 'master' of master.kernel.org:/.../davem/net-2.6
      Merge branch 'linux-2.6.33.y' of git://git.kernel.org/.../inaky/wimax
      Merge branch 'for-next' of git://git.kernel.org/.../lowpan/lowpan
      net: compat: No need to define IFHWADDRLEN and IFNAMSIZ twice.
      Merge branch 'master' of master.kernel.org:/.../davem/net-2.6
      Merge branch 'master' of git://git.kernel.org/.../linville/wireless-next-2.6
      Merge branch 'master' of master.kernel.org:/.../davem/net-2.6
      ipv6: Remove unused var in inet6_dump_ifinfo()
      clocksource/timecompare: Fix symbol exports to be GPL'd.
      Merge branch 'for-next' of git://git.kernel.org/.../lowpan/lowpan
      Merge branch 'master' of master.kernel.org:/.../davem/net-2.6
      Merge branch 'master' of git://git.kernel.org/.../linville/wireless-next-2.6
      Merge branch 'master' of master.kernel.org:/.../davem/net-2.6
      tcp: Don't make syn cookies initial setting depend on CONFIG_SYSCTL
      Merge branch 'master' of git://git.kernel.org/.../linville/wireless-next-2.6
      Merge branch 'net-next' of git://git.kernel.org/.../vxy/lksctp-dev
      Merge branch 'master' of master.kernel.org:/.../davem/net-2.6
      Merge branch 'master' of /home/davem/src/GIT/linux-2.6/
      Merge branch 'master' of master.kernel.org:/.../davem/net-2.6
      Merge branch 'master' of master.kernel.org:/.../davem/net-2.6
      tcp: Fix warning on 64-bit.
      tcp: sysctl_tcp_cookie_size needs to be exported to modules.
      Merge branch 'master' of git://git.kernel.org/.../kaber/nf-next-2.6
      Merge branch 'master' of git://git.kernel.org/.../holtmann/bluetooth-next-2.6
      Merge branch 'master' of git://git.kernel.org/.../linville/wireless-next-2.6
      Merge branch 'master' of /home/davem/src/GIT/linux-2.6/

David-John Willis (2):
      wl1251: add support for PG11 chips.
      wl1251: add NVS in EEPROM support

Denis Kirjanov (1):
      mv643xx: convert to netdev_tx_t

Dhananjay Phadke (11):
      netxen: add access to on chip memory for tools
      netxen: annotate register windowing code
      netxen: separate register and memory access lock
      netxen: add sysfs entries for diag tools
      netxen: fix error codes in for tools access
      netxen; update version to 4.0.62
      netxen: refactor indirect register access
      netxen: add PCI IDs for new chip
      netxen: update module info
      netxen: module firmware hints
      netxen: update version to 4.0.65

Dirk Brandewie (5):
      wimax/i2400m: Update comments to talk about SDIO reset and not USB.
      wimax/i2400m: Ensure boot mode cmd and ack buffers are alloc'd before first message
      wimax/i2400m: Make boot retries a BUS-specific parameter
      wimax/i2400m: USB driver uses a configurable endpoint map
      wimax/i6x50: add Intel WiFi/WiMAX Link 6050 Series support

Dmitry Eremin-Solenikov (18):
      wpan-phy: add a helper to put the wpan_phy device
      wpan-phy: add wpan-phy iteration functions
      wpan-phy: init channel/page fields
      wpan-phy: use snprintf to limit the amount of chars written
      wpan-phy: allow specifying a per-page channel mask
      wpan-phy: follow usual patter of devices registration
      ieee802154: constify struct net_device in some operations
      ieee802154: merge nl802154 and wpan-class in single module
      ieee802154: split away MAC commands implementation
      ieee802154: add LIST_PHY command support
      fakehard: no need to export net_to_phy, make it static
      fakehard: claim all 2.4 Ghz channels as supported
      ieee802154: add an mlme_ops call to retrieve PHY object
      fakehard: mlme_ops->get_phy implementation
      ieee802154: add two nl802154 helpers
      ieee802154: add PHY_NAME to LIST_IFACE command results
      ieee802154: add support for creation/removal of logic interfaces
      ieee802154: make wpan-phy class registration to subsys_initcall

Don Skidmore (3):
      ixgbe: add support for 82599 based Express Module X520-P2
      ixgbe: Fix KR to KX fail over for Mezzanine cards
      ixgbe: LINKS2 is not a valid register for 82598

Eilon Greenstein (12):
      bnx2x: Add FW 5.2.7
      bnx2x: Allowing 0 as initial fairness value
      bnx2x: Remove old FW files
      bnx2x: Changing the Disabled state to a flag
      bnx2x: Adding FW mailbox mutex
      bnx2x: Do not call load/unload functionality from DCC
      bnx2x: Report the maximal available BW as link speed
      bnx2x: Update to version 1.52.1-1
      bnx2x: GSO implies CSUM offload
      bnx2x: Remove misleading error print
      bnx2x: Change coalescing granularity to 4us
      bnx2x: version 1.52.1-4

Einar Lueck (2):
      ctcm rollback in case of errors
      qeth: Exploit Connection Isolation

Eric Dumazet (100):
      icmp: No need to call sk_write_space()
      pktgen: Avoid dirtying skb->users when txq is full
      tunnels: Optimize tx path
      net: speedup sk_wake_async()
      Use sk_mark for routing lookup in more places
      pkt_sched: gen_estimator: Dont report fake rate estimators
      udp: dynamically size hash tables at boot time
      tcp: replace ehash_size by ehash_mask
      net: Add netdev_alloc_skb_ip_align() helper
      net: Use netdev_alloc_skb_ip_align()
      net: sk_drops consolidation
      inet: rename some inet_sock fields
      net: sk_drops consolidation part 2
      af_packet: Avoid cache line dirtying
      af_packet: mc_drop/flush_mclist changes
      filter: Add SKF_AD_QUEUE instruction
      rtnetlink: rtnl_setlink() and rtnl_getlink() changes
      ipv6 sit: RCU conversion phase I
      ipv6 sit: RCU conversion phase II
      xfrm6_tunnel: RCU conversion
      ipip: convert hash tables locking to RCU
      ip6tnl: convert hash tables locking to RCU
      gre: convert hash tables locking to RCU
      rtnetlink: speedup rtnl_dump_ifinfo()
      vlan: allow null VLAN ID to be used
      net: Introduce unregister_netdevice_queue()
      net: Introduce unregister_netdevice_many()
      net: add a list_head parameter to dellink() method
      vlan: Optimize multiple unregistration
      ipip: Optimize multiple unregistration
      gre: Optimize multiple unregistration
      net: sysfs: ethtool_ops can be NULL
      bridge: Optimize multiple unregistration
      ip6tnl: Optimize multiple unregistration
      ipmr: Optimize multiple unregistration
      ipv6 sit: Optimize multiple unregistration
      ip6mr: Optimize multiple unregistration
      net: Introduce dev_get_by_index_rcu()
      veth: Fix veth_dellink method
      net: use hlist_for_each_entry()
      net: Introduce dev_get_by_name_rcu()
      ipv4: inetdev_by_index() switch to RCU
      icmp: icmp_send() can avoid a dev_put()
      net: RCU locking for simple ioctl()
      ifb: RCU locking avoids touching dev refcount
      pppoe: RCU locking in get_item_by_addr()
      packet: less dev_put() calls
      ip6tnl: less dev_put() calls
      ipv6: no more dev_put() in inet6_bind()
      ipv6: no more dev_put() in datagram_send_ctl()
      net: cleanup include/net
      bnx2: avoid compiler warnings
      em_meta: avoid one dev_put()
      net: Introduce for_each_netdev_rcu() iterator
      net: cleanup include/linux
      decnet: avoid touching device refcount in dn_dev_by_index()
      netfilter: remove synchronize_net() calls in ip_queue/ip6_queue
      net: net/ipv4/devinet.c cleanups
      bridge: remove dev_put() in add_del_if()
      netlabel: remove dev_put() calls
      sctp: ipv6: avoid touching device refcount
      net_cls: Use __dev_get_by_index()
      ip_frag: dont touch device refcount
      net: sock_bindtodevice() RCU-ification
      pktgen: tx_bytes might be slightly wrong
      rtnetlink: Cleanups
      ipv6: avoid dev_hold()/dev_put() in rawv6_bind()
      udp: add a counter into udp_hslot
      udp: split sk_hash into two u16 hashes
      udp: secondary hash on (local port, local address)
      ipv4: udp: optimize unicast RX path
      ipv6: udp: optimize unicast RX path
      ipv4: udp: Optimise multicast reception
      ipv6: udp: Optimise multicast reception
      udp: multicast RX should increment SNMP/sk_drops counter in allocation failures
      udp: bind() optimisation
      ipv6: speedup inet6_dump_ifinfo()
      ipv6: Allow inet6_dump_addr() to handle more than 64 addresses
      parisc: led: Use for_each_netdev_rcu()
      ipv6: use RCU to walk list of network devices
      igmp: Use next_net_device_rcu()
      ipv4: speedup inet_dump_ifaddr()
      ipv6: speedup inet6_dump_addr()
      inetpeer: Optimize inet_getid()
      net: check the return value of ndo_select_queue()
      vlan: Use __vlan_hwaccel_put_tag() in rx
      net: add dev_txq_stats_fold() helper
      vlan: Precise RX stats accounting
      macvlan: Precise RX stats accounting
      linkwatch: linkwatch_forget_dev() to speedup device dismantle
      netns: net_identifiers should be read_mostly
      netsched: Allow var_sk_bound_if meta to work on all namespaces
      net: rename skb->iif to skb->skb_iif
      mac80211: Speedup ieee80211_remove_interfaces()
      pktgen: NUMA aware
      tcp: tcp_disconnect() should clear window_clamp
      ieee802154: merge cleanup
      tcp: diag: Dont report negative values for rx queue
      tcp: connect() race with timewait reuse
      tcp: fix a timewait refcnt race

Eric Paris (3):
      net: drop capability from protocol definitions
      net: pass kern to net_proto_family create function
      net: check kern before calling security subsystem

Eric W. Biederman (37):
      net: Allow devices to specify a device specific sysfs group.
      bond: Simply bond sysfs group creation
      bond: Simplify bond_create.
      bond: Simplify bond device destruction
      bond: Implement a basic set of rtnl link ops
      bond: Add support for multiple network namespaces
      bond: Get the rtnl_link_ops support correct
      veth: Fix unregister_netdevice_queue for veth
      net: Support specifying the network namespace upon device creation.
      net: NETDEV_UNREGISTER_PERNET -> NETDEV_UNREGISTER_BATCH
      net: Implement for_each_netdev_reverse.
      net: Batch network namespace destruction.
      net: Automatically allocate per namespace data.
      net: Simplify loopback and improve batching.
      net: Simplfy default_device_exit and improve batching.
      net: Simplify the bond drivers pernet operations.
      net: Simplify vlan pernet operations.
      net: Simplify af_key pernet operations.
      net: Simplify conntrack_proto_dccp pernet operations.
      net: Simplify conntrack_proto_gre pernet operations.
      net: Simplify ppp_generic pernet operations.
      net: Simplify pppoe pernet operations.
      net: Simplify pppol2tp pernet operations.
      net: Simplify phonet pernet operations.
      net: Simplify ip_gre pernet operations.
      net: Simplify ipip pernet operations.
      net: Simplify ip6_tunnel pernet operations.
      net: Simplify ipip6 aka sit pernet operations.
      net: remove [un]register_pernet_gen_... and update the docs.
      net: Teach vlans to cleanup as a pernet subsystem
      net: Add support for batching network namespace cleanups
      net: Move network device exit batching
      net: Allow xfrm_user_net_exit to batch efficiently.
      netns: Add an explicit rcu_barrier to unregister_pernet_{device|subsys}
      net: Allow fib_rule_unregister to batch
      net: Use rcu lookups in inet_twsk_purge.
      net: Batch inet_twsk_purge

Felix Fietkau (11):
      nl80211: add a parameter for using 4-address frames on virtual interfaces
      mac80211: implement support for 4-address frames for AP and client mode
      mac80211: fix broadcast frame handling for 4-addr AP VLANs
      nl80211: only allow adding stations to running vlan interfaces
      ath9k: fix massive rx packet loss issue
      mac80211: reduce the amount of unnecessary traffic on cooked monitor interfaces
      mac80211: add the total ampdu length to tx info
      ath9k: get rid of tx_info_priv
      ath9k: properly use the mac80211 rate control api
      ath9k: clean up rc rate table
      ath9k: separate debugfs support from CONFIG_ATH_DEBUG

Figo.zhang (2):
      NET/KS8695: add support NAPI for Rx
      NET:KS8695: add API for get rx interrupt bit

Florian Westphal (1):
      netfilter: xtables: fix conntrack match v1 ipt-save output

Frank Blaschka (3):
      ctcm: suspend has to wait for outstanding I/O
      qeth: rework TSO functions
      qeth: allow dynamic change of rx checksumming

Gabor Juhos (1):
      ath9k: enable 2GHz band only if the device supports it

Geoff Levand (1):
      net/ps3: Cleanup gelic enums

Gerrit Renker (4):
      dccp ccid-2: Overhaul CCID naming convention 1/2
      dccp ccid-3: Overhaul CCID naming convention 2/2
      dccp ccid-2: Remove CCID naming redundancy 1/2
      dccp ccid-3: Remove CCID naming redundancy 2/2

Gertjan van Wingerde (17):
      rt2x00: Move interface type assignments to generic code.
      rt2x00: Fix building of rt2800lib when rt2x00 driver is built-in.
      rt2x00: Add dynamic detection of eFuse EEPROM in rt2800pci.
      rt2x00: Update copyright statements.
      rt2x00: Fix typo in rf programming of rt2800lib.
      rt2x00: Properly detect Ralink RT3070 devices.
      rt2x00: Fix rt2800lib RF chip programming selection.
      rt2x00: Initialize rf302x RF values properly for rt2800pci.
      rt2x00: Log RT/RF chipset information correctly.
      rt2x00: Fix BUG on rt2800usb when trying to read eFuse EEPROM.
      rt2x00: Only initialize HT on rt2800 devices that support it.
      rt2x00: Remove unused variable frame_control from rt2x00mac_tx.
      rt2x00: Clean up use of rt2x00_intf_is_pci.
      rt2x00: Fix typo (lengt --> length) in rt2x00queue.c
      rt2x00: Whitespace cleanup.
      rt2x00: Centralize setting of extra TX headroom requested by rt2x00.
      rt2x00: Fix padding bug on L2PAD devices.

Gilad Ben-Yossef (9):
      Only parse time stamp TCP option in time wait sock
      Allow tcp_parse_options to consult dst entry
      Add dst_feature to query route entry features
      Add the no SACK route option feature
      Allow disabling TCP timestamp options per route
      Allow to turn off TCP window scale opt per route
      Allow disabling of DSACK TCP option per route
      tcp: Do not call IPv4 specific func in tcp_check_req
      tcp: Use defaults when no route options are available

Greg Kroah-Hartman (4):
      Staging: strip: add TODO file
      Staging: arlan: add TODO file
      Staging: wavelan: add TODO file
      Staging: netwave: add TODO file

Gustavo F. Padovan (5):
      Bluetooth: Initialize variables and timers for both channel's sides
      Bluetooth: Fix unset of SrejActioned flag
      Bluetooth: Fix sending ReqSeq on I-frames
      Bluetooth: Implement RejActioned flag
      Bluetooth: Fix 'SendRRorRNR' to send the ReqSeq value

Gábor Stefanik (1):
      b43: LP-PHY: Begin implementing calibration & software RFKILL support

Hagen Paul Pfeifer (2):
      econet: Fix redeclaration of symbol len
      ipv4: Define cipso_v4_delopt static

Hannes Eder (1):
      netfilter: nf_nat_helper: tidy up adjust_tcp_sequence

Heiko Carstens (1):
      net/s390 drivers: add missing 'const' attribute

Hendrik Brueckner (1):
      af_iucv: use sk functions to modify sk->sk_ack_backlog

Herbert Xu (1):
      sit: Clean up DF code by copying from IPIP

Hideyuki Sasaki (1):
      net/ps3: Add support for gelic link negotiation

Holger Schurig (34):
      nl80211: report age of scan results
      libertas: separate libertas' Kconfig in it's own file
      libertas: first stab at cfg80211 support
      libertas: remove extraneous select FW_LOADER
      libertas: depend on CONFIG_CFG80211
      cfg80211: no cookies in cfg80211_send_XXX()
      cfg80211: remove warning in deauth case
      libertas: make __lbs_cmd_async() non-static
      libertas: cleanup host.h and hostcmd.h
      libertas: harmonize cmd.h
      libertas: make lbs_get_channel() static
      libertas: remove unused lbs_cmd_802_11_inactivity_timeout()
      libertas: remove unused 11d code
      libertas: remove unused 11d.h as well, priv->countryinfo
      libertas: change IW_ESSID_MAX_SIZE -> IEEE80211_MAX_SSID_LEN
      libertas: move scan/assoc related stuff
      libertas: sort variables in struct lbs_private
      libertas: get current channel out of priv->curbssparams
      libertas: move association related commands into assoc.c
      libertas: move lbs_send_iwevcustom_event() to wext.c
      libertas: remove handling for CMD_802_11_LED_GPIO_CTRL
      libertas: remove handling for CMD_GET_TSF
      libertas: remove "struct cmd_ds_gen"
      libertas: move SIOCGIWAP calls to wext.c
      libertas: move mic failure event to wext.c
      libertas: sort and categorize entries in decl.h
      libertas: remove some references to IW_MODE_abc
      cfg80211: introduce nl80211_get_ifidx()
      cfg80211: return channel noise via survey API
      libertas: rename persistcfg.c -> mesh.c
      libertas: introduce mesh.h
      libertas: moveing mesh-related functions into mesh.c
      libertas: move mesh-only ethtool operations into mesh.c
      libertas: move mesh command handling into mesh.c

Huaxu Wan (2):
      iwlwifi: add module firmware info for 1000 series
      iwlwifi: clear the translate table area

Ilia K (1):
      add vif using local interface index instead of IP

Ilpo Järvinen (1):
      tcp: clear hints to avoid a stale one (nfs only affected?)

Inaky Perez-Gonzalez (47):
      wimax: indicate initial SW rfkill state is "blocked"
      wimax/i2400m: be smarter about copying command buffer to bm_cmd_buf
      wimax/i2400m: during probe, call sdio_disable at most once
      wimax/i2400m: add missing debug submodule definition
      wimax: allow specifying debug levels as command line option
      wimax/i2400m: workaround not-so-working %zd printf format
      wimax/i2400m: decide properly if using signed vs non-signed firmware loading
      wimax/i2400m: rework bootrom initialization to be more flexible
      wimax/i2400m: retry loading firmware files in sequence
      wimax/i2400m: fix reboot echo/ack barker deadlock
      wimax/i2400m: verify firmware format version is known
      wimax/i2400m: support extended firmware format
      wimax/i2400m: on firmware upload, select BCF header that matches device's request
      wimax/i2400m: clean up & add a payload argument to i2400m_schedule_work()
      wimax/i2400m: add reason argument to i2400m_dev_reset_handle()
      wimax/i2400m: cache firmware on system suspend
      wimax/i2400m: implement .reset_resume in USB subdriver
      wimax/i2400m: don't overwrite error codes when failing to load firmware
      wimax/i2400m: on device stop, clean up pending wake & TX work
      wimax/i2400m: cleanup initialization/destruction flow
      wimax/i2400m: clarify and fix i2400m->{ready,updown}
      wimax/i2400m: introduce i2400m->bus_setup/release
      wimax/i2400m: do bootmode buffer management in i2400m_setup/release()
      wimax/i2400m: Implement pre/post reset support in the USB driver
      wimax/i2400m: reduce verbosity of debug messages in boot mode
      wimax/i2400m: fix race condition with tcpdump et al
      wimax: allow user space to send messages once the device is registered
      wimax: allow WIMAX_RF_QUERY calls when state is still uninitialized
      wimax/i2400m: when stopping the device, cancel any pending message
      wimax/i2400m: fix deadlock: don't do BUS reset under i2400m->init_mutex
      wimax/i2400m: move i2400m_init() out of i2400m.h
      wimax/i2400m: queue device's report until the driver is ready for them
      wimax/i2400m: fix oops in TX when tearing down the device
      wimax/i2400m: Let device's status reports change the device state
      wimax/i2400m: fix oops caused by race condition when exiting USB kthreads
      wimax/i2400m: make i2400m->bus_dev_{stop,start}() optional
      wimax/i2400m: SDIO: fix oops on reset when TXing on uninitialized data
      wimax/i2400m: implement passive mode as a module option
      wimax/i2400m: introduce i2400m_reset(), stopping TX and carrier
      wimax/i2400m: fix device getting stuck in IDLE mode
      wimax/i2400m: Fix USB timeout specifications (to ms from HZ)
      wimax/i2400m: correctly identify all iwmc3200-based SKUs
      wimax/i2400m: don't retry SDIO enable in probe() paths
      wimax/i2400m: handle USB stalls
      wimax/i2400m: fix bad assignment of return value in i2400mu_tx_bulk_out
      wimax/i2400m: fix SDIO debugfs dentry name
      wimax/i2400m: fix inverted value in i2400ms_bus_setup()

Ivo van Doorn (3):
      rt2x00: Add rt2x00soc bus module
      rt2x00: Implement support for rt2800pci
      rt2x00: Remove deprecated ieee80211_rx_status->qual usage

Jan Engelhardt (1):
      netfilter: xt_socket: make module available for INPUT chain

Janne Ylalehto (2):
      wl1251: Add IRQ looping support
      wl1251: Filter out unwanted events

Jarek Poplawski (1):
      net: Optimize hard_start_xmit() return checking

Jason Andryuk (2):
      at76c50x-usb: Remove mac2str and replace with %pM format specifier.
      at76c50x-usb: Supply additional parameters to at76_start_monitor scan request

Jasper Spaans (1):
      bonding: Remove bond_dev from xmit_hash_policy call.

Jaswinder Singh Rajput (3):
      b43: Comment unused functions lpphy_restore_dig_flt_state and lpphy_disable_rx_gain_override
      net: Fix missing kernel-doc notation
      mac80211: Fix missing kernel-doc notation

Javier Cardona (1):
      mac80211: Learn about mesh portals from multicast traffic

Jay Sternberg (2):
      iwlwifi: add missing commands to syslog messages
      iwlwifi: Tell the ucode immediately when association state changes

Jay Vosburgh (1):
      bonding: fix 802.3ad standards compliance error

Jean Tourrilhes (1):
      WE: Fix set events not propagated

Jean-Mickael Guerin (2):
      net: compat_mmsghdr must be used in sys_recvmmsg
      net: compat_sys_recvmmsg user timespec arg can be NULL

Jesse Brandeburg (3):
      ixgbe: change default ring size
      ixgbe: performance tweaks
      ixgbe: use EIAM to automask MSI-X

Jie Yang (3):
      atl1c: duplicate atl1c_get_tpd
      atl1c: change atl1c_buffer struct and restructure clean atl1c_buffer procedure
      atl1e:disable NETIF_F_TSO6 for hardware limit

Jin Dongming (1):
      ipv6: Fix the size overflow of addrconf_sysctl array

Jiri Kosina (1):
      Bluetooth: Implement raw output support for HIDP layer

Jiri Pirko (1):
      bonding: introduce primary_reselect option

Jiri Slaby (1):
      NET: sungem, use spin_trylock_irqsave

Joe Perches (10):
      appletalk/ddp.c: Neaten checksum function
      niu.c: Use correct length in strncmp
      drivers/net: request_irq - Remove unnecessary leading & from second arg
      drivers/isdn/gigaset: tasklet_init - Remove unnecessary leading & from second arg
      drivers/net: tasklet_init - Remove unnecessary leading & from second arg
      net/ipv4: Move && and || to end of previous line
      netfilter: net/ipv[46]/netfilter: Move && and || to end of previous line
      net/ipv6: Move && and || to end of previous line
      net: Move && and || to end of previous line
      drivers/net: Move && and || to end of previous line

Joerg Albert (3):
      ar9170: fixed coding style, moved define
      ar9170: add heavy clip handling
      ar9170: handle overflow in tsf_low register during get_tsf

Johannes Berg (64):
      net: introduce NETDEV_POST_INIT notifier
      iwlwifi: clean up ht config a little
      iwlwifi: clean up ht config naming
      iwlwifi: clarify and clean up chain settings
      iwlwifi: fix a typo
      iwlwifi: default to using all chains
      iwlwifi: support idle for 6000 series hw
      wext: refactor
      iwlwifi: device tracing
      iwlwifi: LED cleanup
      wireless: make wireless drivers select core
      cfg80211/mac80211: use debugfs_remove_recursive
      mac80211_hwsim: don't register CCK rates on 5ghz
      mac80211: remove outdated comment
      mac80211: split hardware scan by band
      mac80211: fix radiotap header generation
      mac80211: remove RX_FLAG_RADIOTAP
      mac80211: introduce ieee80211_beacon_get_tim()
      mac80211: deprecate qual value
      mac80211: unconditionally set IEEE80211_TX_CTL_SEND_AFTER_DTIM
      mac80211: also drop qos-nullfunc frames silently
      mac80211: remove sent_ps_buffered
      mac80211: remove bogus code
      mac80211: make CALL_TXH a statement
      mac80211: fix scan abort sanity checks
      cfg80211: validate scan channels
      cfg80211: remove dead variable
      mac80211: make ieee80211_find_sta per virtual interface
      mac80211: fix internal scan request
      mac80211: async station powersave handling
      iwlwifi: don't double-activate queue 4
      iwlwifi: fix FIFO vs. queue confusion
      iwlwifi: add FIFO usage for 5000
      netlink: remove subscriptions check on notifier
      iwlwifi: report PS filtered status
      iwlwifi: add sleep_tx_count ucode station API
      iwlwifi: handle unicast PS buffering
      mac80211: let sta_info_get_by_idx get sta by sdata
      mac80211: convert aggregation to operate on vifs/stas
      mac80211: push michael MIC report after DA check
      mac80211: cleanup reorder buffer handling
      mac80211: trim RX data
      mac80211: improve rate handling
      mac80211: remove dev_hold/put calls
      mac80211: use fixed broadcast address
      mac80211: make software rate control optional
      cfg80211: re-join IBSS when privacy changes
      mac80211: remove encrypt parameter from ieee80211_tx_skb
      mac80211: move TX status handling
      cfg80211: convert bools into flags
      cfg80211: introduce capability for 4addr mode
      cfg80211: disallow bridging managed/adhoc interfaces
      mac80211: request TX status where needed
      mac80211: avoid spurious deauth frames/messages
      mac80211: add per-station HT capability file
      mac80211: remove dead struct member
      mac80211: fix rcu locking
      iwlwifi: separate IO tracing
      mac80211: move cmntr flag out of rx flags
      mac80211: move aMPDU RX reorder code
      mac80211: correctly place aMPDU RX reorder code
      mac80211: log more data when tracing
      b43: fix two warnings
      mac80211: fix reorder buffer release

John Dykstra (1):
      IP: Cleanups

John W. Linville (22):
      wireless: implement basic ethtool support for cfg80211 devices
      mac80211: support ETHTOOL_GPERMADDR
      iwmc3200wifi: support ETHTOOL_GPERMADDR
      ipw2200: support ETHTOOL_GPERMADDR
      orinoco: support ETHTOOL_GPERMADDR
      net/wireless/ethtool.h: drop unnecessary include of linux/ethtool.h
      mac80211: replace netif_tx_{start,stop,wake}_all_queues
      b43: use ieee80211_rx_ni()
      wl1251: re-disable PG10 chips
      strip: move driver to staging
      arlan: move driver to staging
      wavelan: move driver to staging
      netwave: move driver to staging
      wireless: remove WLAN_80211 and WLAN_PRE80211 from Kconfig
      wl1271: depend on INET
      mwl8k: use integral index instead of pointer for driver_data
      iwlwifi: fix iwl1000 "RTS/CTS for HT" merge damage
      znet: fix build failure from i82593.h relocation
      wl3501_cs: remove pedantic build warning
      libipw: initiate cfg80211 API conversion (v2)
      ath9k: set ps_default as false
      ath9k: remove warnings related to signed/unsigned type mismatch

Josef Bacik (1):
      rt2800: do not enable tbtt unless we are in a beacon mode

Jouni Malinen (6):
      cfg80211: Fix WEXT compat siwauth wpa and group cipher
      mac80211_hwsim: Check idle state on TX
      mac80211_hwsim: Send ACK frames on the hwsim0 interface
      mac80211: Do not queue Probe Request frames for station MLME
      cfg80211: Allow reassociation in associated state
      mac80211: Fix TX status reporting for injected data frames

Julia Lawall (17):
      drivers/net/wireless: correct check on CCS_START_NETWORK
      drivers/net/atl1c: remove exceptional & on function name
      drivers/net/can: remove exceptional & on function name
      drivers/net: remove exceptional & on function name
      drivers/net/ipg.c: remove exceptional & on function name
      drivers/net/irda: remove exceptional & on function name
      drivers/net/pppol2tp.c: remove exceptional & on function name
      drivers/net/r6040.c: remove exceptional & on function name
      drivers/net/smsc9420.c: remove exceptional & on function name
      drivers/net/typhoon.c: remove exceptional & on function name
      drivers/net/via-rhine.c: remove exceptional & on function name
      drivers/net/via-velocity.c: remove exceptional & on function name
      drivers/net/wan: remove exceptional & on function name
      drivers/net/adm8211.c: remove exceptional & on function name
      drivers/net/wireless/iwlwifi: remove exceptional & on function name
      drivers/net/wireless/p54: remove exceptional & on function name
      drivers/net/wireless/rtl818x: remove exceptional & on function name

Jussi Kivilinna (3):
      rndis_wlan: handle NL80211_AUTHTYPE_AUTOMATIC
      rndis_wlan: fix buffer overflow in rndis_query_oid
      rndis_wlan: disable stall workaround

Juuso Oikarinen (58):
      wl1271: Correction to TX block allocation calculation
      wl1271: Security sequence number handling for TX (for WPA)
      wl1271: Correct TKIP header space handling in TX path
      wl1271: Implement delayed entry into ELP
      wl1271: mask aid bits 14 and 15 in ps-poll template
      wl1271: Implementation for SPI busy word checking
      wl1271: Configure rate policies based on AP rates
      wl1271: Update join usage
      wl1271: Corrections to TX path
      wl1271: use workqueue provided by mac80211 instead of the default
      wl1271: Clear probe-request template after scan
      wl1271: Multicast filtering configuration
      wl1271: Use vmalloc to allocate memory for firmware
      wl1271: Add connection monitoring configuration
      wl1271: Enable beacon filtering with the stack
      wl1271: Configure beacon filtering on if PSM used
      wl1271: Mask unneeded events from firmware to conserve power
      wl1271: Update memory mapping for firmware revision 6.1.0.0.241
      wl1271: Remove RX workaround
      wl1271: Add top-register access functions
      wl1271: RefClk configuration
      wl1271: Update interrupt handling by removing an extra SPI read
      wl1271: Enable ELP
      wl1271: Enable smart reflex
      wl1271: Update TX path block calucation algo
      wl1271: Remove outdated SPI functions
      wl1271: Update boot time configuration for the new firmware
      wl1271: Workaround for reference clock setting on boot.
      wl1271: Add structure for firmware configuration values
      wl1271: Add config structure for RX path parameters
      wl1271: Add config structure for TX path parameters
      wl1271: Add config structure for connection management parameters
      wl1271: Add config structure for FW init parameters
      wl1271: Move default FW config struct away from stack
      wl1271: Fix IRQ enable handling on FW init failure
      wl1271: Implement beacon early termination support
      wl1271: Remove busy-word checking
      wl1271: Fix multicast list handling
      wl1271: Fix event handling mechanism
      wl1271: Support for IPv4 ARP filtering
      wl1271: Remove unnecessary rx_descriptor memory allocation
      wl1271: Correct memory handling for FW boot
      wl1271: Fix filter configuration
      wl1271: Set IEEE80211_FCTL_TODS in the null data template
      wl1271: Remove excess null-data template settings
      wl1271: Increase TX power value
      wl1271: Check result code of commands
      wl1271: Add retry implementation for PSM entries
      wl1271: Correct endianness-handling of command status
      wl1271: Generalize command response reading
      wl1251: Add connection monitoring configuration
      wl1251: Enable beacon filtering with the stack
      wl1251: Configure beacon filtering on if PSM used
      wl1251: Implement delayed entry into ELP mode
      wl1251: Fix regression in IRQ loop handling
      wl1271: Decrease BET consecutive terminated beacons value to 10
      wl1271: Prevent PSM-entry retry loop if PSM cancelled
      wl1271: Set PSM support flags in driver configuration

Kalle Valo (13):
      wl1251: remove wl1251_netlink.h
      cfg80211: add firmware and hardware version to wiphy
      at76c50x-usb: set firmware and hardware version in wiphy
      wl1251: rename spi device to wl1251
      mac80211: add ieee80211_rx_ni()
      wl1251: use ieee80211_rx_ni()
      mac80211: refactor dynamic power save check
      mac80211: fix dynamic power save for devices with nullfunc support in hw
      wl1251: enable power save
      wl1251: allocate space for firmware with vmalloc()
      wl1251: mask aid bits 14 and 15 in ps-poll template
      wl1251: remove depcreated qual usage
      cfg80211: indent regulatory messages with spaces

Karen Xie (1):
      cxgb3: Added private MAC address and provisioning packet handler for iSCSI

Keng-Yu Lin (1):
      ath5k: add LED support for Acer Aspire One AO751h/AO531h

Kevin Hilman (1):
      NET: smc91x: convert to dev_pm_ops

Klaus-Dieter Wacker (2):
      lcs: ODEBUG: object is on stack, but not annotated.
      lcs: Recognize return codes of ccw_device_set_online().

Krishna Kumar (8):
      cxgb3: No need to wake queue in xmit handler
      genetlink: Optimize genl_register_family()
      genetlink: Optimize and one bug fix in genl_generate_id()
      net: Introduce sk_tx_queue_mapping
      net: IPv6 changes
      net: Fix for dst_negative_advice
      net: Use sk_tx_queue_mapping for connected sockets
      cxgb3: Set the rxq

Kurt Van Dijck (1):
      can: sja1000: fix bug using library functions for skb allocation

Larry Finger (8):
      staging: Add proper selection of WIRELESS_EXT and WEXT_PRIV
      b43legacy: Fix DMA TX bounce buffer copying
      b43: Remove deprecated 'qual' from returned RX status
      b43legacy: Remove deprecated 'qual' from returned RX status
      rtl8187: Remove deprecated 'qual' from returned RX status
      ssb: Unconditionally log results of core scans
      b43: avoid PPC fault during resume
      b43legacy: avoid PPC fault during resume

Lennert Buytenhek (28):
      mwl8k: fix GET_STAT firmware command packet layout
      mwl8k: coding style cleanups
      mwl8k: minor transmit quiescing rework
      mwl8k: fix multicast address filter programming
      mwl8k: use the mac80211-provided workqueue instead of creating our own
      mwl8k: implement FIF_ALLMULTI
      mwl8k: enforce FIF_BCN_PRBRESP_PROMISC when no STA interfaces are active
      mwl8k: clear hardware MAC address if no STA interface configured
      mwl8k: use cond_resched() when loading firmware blocks
      mwl8k: clarify WME transmit queue 0/1 swizzling
      mwl8k: report rate and other information for received frames
      mwl8k: add support for enabling hardware sniffer mode
      mwl8k: shorten receive/transmit state variable names
      mwl8k: pci BAR mapping changes
      mwl8k: change pci id table driver data to a structure pointer
      mwl8k: spell out the names of firmware images in the pci driver data
      mwl8k: handle loading AP firmware images
      mwl8k: use pci_unmap_addr{,set}() to keep track of unmap addresses on rx
      mwl8k: allow for different receive descriptor formats
      mwl8k: set ->interface_modes from the driver data
      mwl8k: rename mwl8k_cmd_get_hw_spec() to mwl8k_cmd_get_hw_spec_sta()
      mwl8k: add the commands used for AP firmware initialisation
      mwl8k: implement AP firmware antenna configuration
      mwl8k: add AP firmware handling to ->configure_filter()
      mwl8k: add AP firmware handling to ->start()
      mwl8k: add AP firmware (mbss) handling to mwl8k_set_mac_addr()
      mwl8k: implement AP firmware EDCA parameter configuration
      mwl8k: add support for the 88w8366

Li Yewang (1):
      ipsec: can not add camellia cipher algorithm when using "ip xfrm state" command

Lucian Adrian Grijincu (1):
      inet: fix inet_bind_bucket_for_each

Luciano Coelho (21):
      wl1271: remove unecessary qual parameter from rx status
      wl1271: added Juuso Oikarinen as module author
      wl1271: hack to disable filters
      wl1271: implement cmd_disconnect
      wl1271: workaround to send a disconnect before rejoining
      wl1271: add workaround to avoid distortion due to excessive tx power
      wl1271: enable HW_AVAILABLE interrupt to fix ELP
      wl1271: use acx_rx_config instead of join when updating filters
      wl1271: remove unnecessary joins and join only when the bssid changes
      wl1271: make sure PS is disabled in PLT
      wl1271: fix sparse warnings about undeclared functions
      wl1271: added missing packed modifier in some acx structs
      wl1271: fix endianess issues
      wl1271: added missing packed modifier in some cmd structs
      wl1271: use ieee80211_rx_ni()
      wl1271: fix init loop timeout
      wl1271: fix the inetdev notifier callback return values
      wl1271: set radio and general params also for PLT
      wl1271: fix radio and general parameters commands
      wl1271: remove workaround to ignore -EIO from radio and general params
      wl1271: Remove REF_CLK hack

Luis R. Rodriguez (123):
      ath9k: use ath_hw for DPRINTF() and debug init/exit
      ath9k: move btcoex core driver info to its own struct
      ath9k: move hw specific btcoex info to ath_hw
      ath9k: split bluetooth hardware coex init into two helpers
      ath9k: move driver core helpers to main.c
      ath9k: split ath9k_hw_btcoex_enable() into two helpers
      ath9k: replaces SC_OP_BTCOEX_ENABLED with a bool
      ath9k: move bt_stomp_type to driver core
      ath9k: remove unused bt_duty_cycle
      ath9k: rename btcoex_scheme to just scheme
      ath9k: rename ath_btcoex_info to ath_btcoex_hw
      ath9k: simplify ath_btcoex_bt_stomp()
      ath9k: now move ath9k_hw_btcoex_set_weight() to btcoex.c
      ath9k: move ath_btcoex_config and ath_bt_mode to btcoex.c
      ath9k: rename ath_btcoex_supported() to ath9k_hw_btcoex_supported()
      ath9k: move ps helpers onto core driver when reseting tsf
      ath9k: move ath9k_ps_wakeup() and ath9k_ps_restore() to main.c
      ath9k: avoid usage of ath9k_hw_setpower() on hw.c
      ath9k: move ath9k_hw_setpower() to main.c
      ath9k: rename driver core and hw power save helpers
      ath: move ath_bcast_mac to common header
      atheros: use get_unaligned_le*() for bssid mask setting
      ath9k: make ath9k_hw_setbssidmask() and ath9k_hw_write_associd() use ath_hw
      ath9k: Use ath9k_hw_setbssidmask() on reset
      ath9k: use ath9k_hw_write_associd() on reset
      atheros/ath9k: move macaddr, curaid, curbssid and bssidmask to common
      ar9170: make use of common macaddr and curbssid
      ath5k: use common curbssid, bssidmask and macaddr
      ath5k: initialize eeprom struct early on attach
      ath9k: move ath_common to ath_hw
      ath5k: move ath_common to ath5k_hw
      ath9k: Define bus agnostic bluetooth coex prep helper
      atheros/ath9k: add common read/write ops and port ath9k to use it
      ath5k: allocate ath5k_hw prior to initializing hw
      ath5k: define ath_common ops
      atheros: define shared bssidmask setting
      atheros: add ieee80211_hw to ath_common
      ath9k: separate core driver and hw timer code
      atheros: add common debug printing
      atheros: move tx/rx chainmask to ath_common
      ath9k: remove ath9k 25 MHz HT40 spacing stuff
      ath9k: remove ath9k_ht_macmode
      ath9k: move ATH_AMPDU_LIMIT_MAX to hw.h
      ath9k: remove driver ASSERT, just use BUG_ON()
      ath9k: clarify what hw code is and remove ath9k.h from a few files
      ath9k: move ATH9K_RSSI_BAD to hw.h
      atheros: move bus ops to ath_common
      ath9k: make ath9k_common_ops const
      ath9k: use common read/write ops on pci and debug code
      ath9k: move hw code to its own module
      ath9k_hw: print device ID if not supported
      ath9k_hw: add AR9271 srev and device ID to allow hw to support ar9271
      atheros: define a common priv struct
      ath5k: fix regression on setting bssid mask on association
      ath5k: use ath_hw_setbssidmask() for bssid mask setting upon assoc
      ath5k: fix regression introduced upon the removal of AR5K_HIGH_ID()
      ath5k: simplify passed params to ath5k_hw_set_associd()
      ath5k: remove temporary low_id and high_id vars on ath5k_hw_set_associd()
      ath5k: fix regression which triggers an SME join upon assoc
      ath5k: enable Power-Save Polls by setting the association ID
      ath9k: move common->debug_mask setting to ath_init_softc()
      ath9k: initialize hw prior to debugfs
      ath9k: add helper to un-init the hw properly
      ath9k: add a helper to clean the core driver upon module unload
      ath9k: move ath_cleanup() below helpers to avoid forward declarations
      ath9k: rename ath_beaconq_setup() to ath9k_hw_beaconq_setup()
      ath9k: use right parameter for MODULE_PARM_DESC() for debug
      libertas: remove double assignment of dev->netdev_ops
      ath9k_hw: run the carrier leakage calibration fix for ar9271 as well
      ath9k_hw: run ath9k_hw_9271_pa_cal() initial calibration
      ath9k_hw: move mac name and rf name helpers to hw code
      ath9k_hw: distinguish single-chip solutions on initial probe print
      ath9k_hw: add AR9271 single chip name mapping
      ath9k_hw: correct AR_PHY_SPECTRAL_SCAN register offset
      ath9k_hw: remove bogus register write on ath9k_hw_9271_pa_cal()
      ath9k_hw: modify the rf control register for ar9271 revision 1.0
      ath9k_hw: update register initialization/reset values for ar9271
      ath9k_hw: change the way we initialize the pll for ar9271
      ath9k_hw: start documenting 802.11n RF anlong front ends
      ath9k_hw: bail out early on ath9k_hw_init_rf()
      ath9k_hw: simplify rf attach and rename to ath9k_hw_rf_alloc_ext_banks()
      ath9k_hw: simplify ath9k_hw_rf_alloc_ext_banks()
      ath9k_hw: rename ath9k_hw_rf_free() to ath9k_hw_rf_free_ext_banks()
      ath9k_hw: make both analog channel change routines return int
      ath9k_hw: use a callback for frequency change
      ath9k_hw: order phy.c code and integrate spur mitigation
      ath9k_hw: make spur mitigation a callback
      ath9k_hw: remove unused modesIndex param from ath9k_hw_write_regs()
      ath9k_hw: Fix and complete force bias for AR5416
      ath9k_hw: make ath9k_phy_modify_rx_buffer() static
      wl1271: use __dev_alloc_skb() on RX
      ath9k: fix listening to idle requests
      ath9k: update hw configuration for virtual wiphys
      ath9k: simpify RX by calling ath_get_virt_hw() once
      ath9k: use the passed ieee80211_hw on ath_rx_prepare()
      ath9k: pass the ieee80211_hw on radio enable/disable
      ath9k: use correct hw for tx aggregation TX completion
      ath9k: use the right hw on ath_tx_setup_buffer() for HT
      ath9k: handle low buffer space for virtual wiphys
      ath9k: do not pass the entire descriptor to ath_rx_prepare()
      ath9k_hw: move ath_extend_tsf() to hw code to share as ath9k_hw_extend_tsf()
      ath9k: move struct ath_ani to common area
      ath9k: use the ieee80211_hw to get to an sband on ath_rx_prepare()
      ath9k: move RX check code into helper ath9k_rx_accept()
      ath9k: remove temp variable ratecode from ath_rx_prepare()
      ath9k: move rate descriptor reading into a helper
      ath9k: move qual processing into a helper
      ath9k: move rssi processing into a helper
      ath9k: avoid the copy skb->cb on every RX'd skb
      ath9k: move the rx_stats->rs_datalen check to ath9k_rx_accept()
      ath: move the rx bufsize to common to share with ath5k/ath9k
      ath5k: remove double cache alignment, ath_rxbuf_alloc() already does it
      ath9k: move the max rx buffer size check to ath9k_rx_accept()
      ath9k: rename ath_rx_prepare() to ath9k_rx_skb_preprocess()
      ath9k: move driver keymap, keymax and splitmic to common
      ath5k: use the common->keymap
      ath9k: move RX skb post processing to a helper
      ath9k_common: add new module to share 802.11n driver helpers
      ath9k_common: remove ath9k_compute_qual()
      ath9k_common: clarify and correct jumbogram processing
      mac80211: fix max HT rate processing on mac80211
      ath9k: fix processing of TX PS null data frames
      ath9k: Fix maximum tx fifo settings for single stream devices

Lukáš Turek (1):
      ath5k: Fix I/Q calibration

Magnus Damm (2):
      net: allow sh_eth to get mac address through platform data
      net: add Runtime PM to the sh_eth driver

Mallikarjuna R Chilakala (2):
      ixgbe: Modify 82599 HWRSC statistics counters
      ixgbe: Use rx buffer length from rx ring for configuring rscctl

Manuel Lauss (2):
      net: enable smsc911x on MIPS
      net: smsc911x: allow platform_data to specify mac address

Marcel Holtmann (12):
      usbnet: Use wwan%d interface name for mobile broadband devices
      usbnet: Set device type for wlan and wwan devices
      cfg80211: assign device type in netdev notifier callback
      rfkill: Add missing description for RFKILL_TYPE_GPS
      rfkill: Add constant for RFKILL_TYPE_FM radio devices
      Bluetooth: Remove unused global minor variable
      Bluetooth: Fix miscdev ops owner for virtual driver
      Bluetooth: Return ENETDOWN when interface is down
      Bluetooth: Turn hci_recv_frame into an exported function
      Bluetooth: Unobfuscate tasklet_schedule usage
      Bluetooth: Add L2CAP option for max transmit value
      Bluetooth: Add RFCOMM option to use L2CAP ERTM mode

Marek Lindner (1):
      ath9k: adjust ahb callbacks to new struct layout to avoid compile errors

Marin Mitov (2):
      niu: Use DMA_BIT_MASK(44) instead of deprecated DMA_44BIT_MASK
      remove deprecated and not used: print_mac()

Martin Willi (4):
      xfrm: Define new XFRM netlink auth attribute with specified truncation bits
      xfrm: Store aalg in xfrm_state with a user specified truncation length
      xfrm: Use the user specified truncation length in ESP and AH
      xfrm: Add SHA384 and SHA512 HMAC authentication algorithms to XFRM

Matt Carlson (46):
      tg3: Assign flags to fixes in start_xmit_dma_bug
      tg3: Fix 5906 transmit hangs
      tg3: Fix disappearing 57780 devices
      tg3: Convert PHY_ADDR => TG3_PHY_MII_ADDR
      tg3: Prevent a PCIe tx glitch
      tg3: Add more PCI DMA map error checking
      tg3: Improve 5785 PCIe performance
      tg3: Add AC131 power down support
      tg3: 5785: Set port mode to MII when link down
      tg3: Extend loopback test timeout
      broadcom: Isolate phy dsp accesses
      broadcom: Fix slow link problem
      tg3: Add 50610M phy ID for 5785
      broadcom: Consolidate dev_flags definitions
      tg3 / broadcom: Add PHY_BRCM_CLEAR_RGMII_MODE flag
      tg3 / broadcom: Refine AC131 APD support
      tg3 / broadcom: Add code to disable rxc refclk
      tg3 / broadcom: Add APD support for GPHYs
      tg3 / broadcom: Optionally disable TXC if no link
      tg3: Update version to 3.103
      tg3: Add 5717 phy ID
      tg3: Don't touch RCB nic addresses
      tg3: Napify tg3_start_xmit_dma_bug()
      tg3: Move TG3_FLG2_PROTECTED_NVRAM to tg3_flags3
      tg3: Refine TSO and MSI discovery
      tg3: Add new HW_TSO_3 flag for 5717
      tg3: Use tg3_start_xmit_dma_bug for 5717 A0
      tg3: Allow DMAs to cross cacheline boundaries
      tg3: Create tg3_poll_msix() for non-zero MSIX vecs
      tg3: Move napi_add calls below tg3_get_invariants
      tg3: Make tg3_alloc_rx_skb() a dst-only operation
      tg3: Add prodring parameter to tg3_alloc_rx_skb()
      tg3: tg3_alloc_rx_skb(tnapi => tp)
      tg3: rename rx_[std|jmb]_ptr
      tg3: Consider rx_std_prod_idx a hw mailbox
      tg3: Lay proucer ring handling groundwork
      tg3: Create aliases for rx producer mailbox regs
      tg3: Add rx prod ring consolidation
      tg3: Fix DIDs, Enable 5717 support
      tg3: Update version to 3.104
      tg3: Make TSS enable independent of MSI-X enable
      tg3: Add 57765 asic rev
      tg3: Add some VPD preprocessor constants
      tg3: Use pci_read_vpd() instead of private method
      tg3: Clean tg3_init_one()
      tg3: Update version to 3.105

Matthew Garrett (2):
      ipw2100: Register the wiphy device
      ipw2200: Set core hw rfkill status when hardware changes state

Matthew Slattery (1):
      sfc: Remove EFX_WORKAROUND_9141 macro

Matthieu CASTET (1):
      airo : allow supend with card without power management

Michael Buesch (11):
      b43/legacy: Fix usage of host_pci pointer
      ssb: Put host pointers into a union
      b43: Remove me as maintainer
      b43: Optimize PIO scratchbuffer usage
      b43: Rewrite TX bounce buffer handling
      b43-pio: Fix RX error path for rev>=8 devices
      b43: Enforce DMA descriptor memory constraints
      b43: Rewrite DMA Tx status handling sanity checks
      ssb: Fix SPROM writing
      ssb: Fix range check in sprom write
      airo: Fix integer overflow warning

Michael Chan (18):
      bnx2x: Refactor bnx2x_sp_post().
      bnx2x: Refactor MAC address setup code.
      bnx2x: Add hw init code to support iSCSI.
      bnx2x: Add main CNIC interface functions.
      cnic: Refactor some code.
      cnic: Add bnx2x data structures.
      cnic: Add main functions to support bnx2x devices.
      cnic: Fix ring I/O address for bnx2x devices.
      cnic: Fix bnx2x ring shutdown.
      cnic: Fix bogus iSCSI MAC address
      cnic: Fix rq_page_table DMA address.
      cnic: Use dma_alloc_coherent().
      bnx2: Protect tx timeout reset with rtnl_lock().
      bnx2: Dump some state during tx timeout.
      bnx2: Print warning when unable to allocate the full SKB/page ring.
      bnx2: Read firmware version from VPD.
      bnx2: Update version to 2.0.3.
      bnx2: Refine VPD logic.

Mikulas Patocka (1):
      sunhme: fix dma warning in Sun HME

Narender Kumar (2):
      netxen: sysfs control for auto firmware recovery
      netxen : fix debug tools access for NX2031

Neil Horman (3):
      af_packet: add interframe drop cmsg (v6)
      net: Generalize socket rx gap / receive queue overflow cmsg
      sctp: Fix mis-ordering of user space data when multihoming in use

Nelson, Shannon (1):
      ixgbe: Flush the LSC mask change to prevent repeated interrupts

Nicolas de Pesloüan (3):
      bonding: fix a parameter name in error message
      bonding: remove useless assignment
      bonding: change bond_create_proc_entry() to return void

Octavian Purdila (5):
      make TLLAO option for NA packets configurable
      net: introduce NETDEV_UNREGISTER_PERNET
      ipv4: factorize cache clearing for batched unregister operations
      net: device name allocation cleanups
      net: use net_eq to compare nets

Oliver Neukum (4):
      wimax/i2400m/usb: remove unnecessary power management primitive in i2400m
      convert kaweth to use usb_reset_configuration()
      cdc-ether: Implement reset_resume()
      usbnet & cdc-ether: Autosuspend for online devices

PJ Waskiewicz (4):
      ixgbe: Make queue pairs on single MSI-X interrupts
      ixgbe: Disable Flow Control for certain devices
      ethtool: Add Direct Attach support to connector port reporting
      ixgbe: Display currently attached PHY through ethtool

Pablo Neira Ayuso (1):
      netfilter: nf_ct_tcp: improve out-of-sync situation in TCP tracking

Patrick McHardy (11):
      vlan: cleanup multiple unregistrations
      netfilter: remove unneccessary checks from netlink notifiers
      net: allow to propagate errors through ->ndo_hard_start_xmit()
      vlan/macvlan: propagate transmission state to upper layers
      vlan: support "loose binding" to the underlying network device
      ip_fragment: also adjust skb->truesize for packets not owned by a socket
      net 01/05: fib_rules: rearrange struct fib_rule
      net 02/05: fib_rules: rename ifindex/ifname/FRA_IFNAME to iifindex/iifname/FRA_IIFNAME
      net 03/05: fib_rules: add oif classification
      net 04/05: fib_rules: allow to delete local rule
      ipv4 05/05: add sysctl to accept packets with local source addresses

Patrick Mullaney (1):
      netdevice: provide common routine for macvlan and vlan operstate management

Rafael J. Wysocki (1):
      Wireless / ath5k: Simplify suspend and resume callbacks

Rahul Tank (1):
      Bluetooth: Removal of unused variable in btmrvl driver

Randy Dunlap (4):
      wireless: fix CFG80211_WEXT build problems
      netxen: fix builds for SYSFS=n or MODULES=n
      wireless: airo_cs needs WEXT_SPY
      staging/wireless: don't build when NET etc. are not enabled

Ranjith Lohithakshan (1):
      TI DaVinci EMAC: Add suspend/resume capability

Reinette Chatre (16):
      iwlwifi: fix userspace setting of sleep_level_override
      iwlwifi: move iwl_setup_mac to iwlagn
      iwlwifi: move rate scaling structures to header file
      iwlagn: store station rate scale information in mac80211 station structure
      iwlwifi: remove duplicate defines
      iwlwifi: provide firmware version
      iwlwifi: unmap memory before use
      iwlwifi: move iwl_[un]init_drv to iwlagn
      iwlwifi: split adding broadcast station from others
      iwl3945: store station rate scale information in mac80211 station structure
      iwlagn: move rate scale initialization to init function
      iwlwifi: print warning when sending host command fails
      iwlwifi: change debug message to error in failure case
      iwlagn: power up device before initializing EEPROM
      iwl3945: removed unused struct and definitions
      iwlwifi: driver version track kernel version

Roel Kluin (3):
      i2400m: keep index within ms_to_errno[]
      wimax: misplaced parenthesis
      e1000e: Use sizeof struct rather than pointer in e1000_get_eeprom()

Ron Mercer (23):
      qlge: Remove explicit setting of PCI Dev CTL reg.
      qlge: Set PCIE max read request size.
      qlge: Add handler for DCBX firmware event.
      qlge: Store firmware revision as early as possible.
      qlge: Remove inline math for small rx buf mapping.
      qlge: Get rid of firmware handler debug code.
      qlge: Don't fail open when port is not initialized.
      qlge: Add CBFC pause frame counters to ethtool stats.
      qlge: Size RX buffers based on MTU.
      qlge: Add ethtool get/set pause parameter.
      qlge: Add ethtool blink function.
      qlge: Add ethtool wake on LAN function.
      qlge: Add ethtool register dump function.
      qlge: Add ethtool self-test.
      qlge: Change naming on vlan API.
      qlge: Fix indentations.
      qlge: Add firmware/driver sub-command support.
      qlge: Clean up netdev->stats usage.
      qlge: Do not change frame routing during suspend.
      qlge: Add asic reset to open call.
      qlge: Clean up module parameter name.
      qlge: Change version to v1.00.00.23.00.00-01.
      qlge: Bonding fix for mode 6.

Rudy Matela (3):
      wan: Frame Relay/DLCI coding style corrections.
      wan: Coding style correction in HDLC/Frame Relay support routines
      net: Coding style corrections on Sealevel Systems 4021 driver.

Rui Paulo (24):
      mesh: use set_bit() to set MESH_WORK_HOUSEKEEPING.
      mac80211: update meshconf IE
      mac80211: set MESH_TTL to 31
      mac80211: implement the meshconf formation info field
      mac80211: fix typo in a comment
      mac80211: update peer link management IE and action frames
      mac80211: update the format of path selection frames
      mac80211: add MAC80211_VERBOSE_MHWMP_DEBUG
      mac80211: allow processing of more than one HWMP IE
      mac80211: improve HWMP debugging
      mac80211: improve peer link management debugging
      mac80211: implement RANN processing and forwarding
      mac80211: update PERR frame format
      mac80211: properly forward the RANN IE
      mac80211: set the AID field correctly for mesh peer frames
      mac80211: fix BSSID setup for beacon frames
      mac80211: add the DS params to the beacon
      mac80211: replace "destination" with "target" to follow the spec
      mac80211: implement a timer to send RANN action frames
      mac80211: add nl80211/cfg80211 handling of the new mesh root mode option.
      mac80211: update copyrights to 2009
      mac80211: use a structure to hold the mesh config information element
      mac80211: update cfg80211 scan result code for the updated mesh conf IE
      mac80211: fix endianess on mesh_path_error_tx() calls

Rémi Denis-Courmont (13):
      Phonet: deliver broadcast packets to broadcast sockets
      Phonet: routing table backend
      Phonet: routing table Netlink interface
      Phonet: route outgoing packets
      Phonet: forward incoming packets
      Phonet: hold socket before giving it to sk_deliver_skb()
      Phonet: remove tautologies
      Phonet: put sockets in a hash table
      Phonet: allocate and copy for pipe TX without sock lock
      Phonet: put protocols array under RCU
      Phonet: convert routing table to RCU
      Phonet: missing rcu_dereference()
      Phonet: convert devices list to RCU

Samuel Ortiz (27):
      iwmc3200wifi: WPS support
      iwmc3200wifi: CT kill support
      iwmc3200wifi: Profile flags can be WPA1 or WPA2 not both
      iwmc3200wifi: Improve rx debug
      iwmc3200wifi: Update statistics notification structure
      iwmc3200wifi: Update fixed size config definitions
      iwmc3200wifi: Tx power setting
      iwmc3200wifi: SDIO disable race fix
      iwmc3200wifi: Check for cmd pointer before dereferencing it
      iwmc3200wifi: Do not handle wifi command if the interface is not ready
      iwmc3200wifi: Try shared auth when open WEP fails
      iwmc3200wifi: Support unexpected reboot barker
      iwmc3200wifi: Set wiphy firmware version
      MAINTAINERS: Add iwmc3200wifi entry
      iwmc3200wifi: Parse HT channels EEPROM entries
      iwmc3200wifi: Dont set the UMAC power limit when interface is down
      iwmc3200wifi: Update wireless_mode with eeprom values
      iwmc3200wifi: 802.11n Tx aggregation support
      iwmc3200wifi: Add stopped queue to debugfs
      iwmc3200wifi: Remove tx concatenation option
      nl80211: PMKSA caching support
      cfg80211: Add PMKSA wext compatibility handler
      iwmc3200wifi: Implement cfg80211 PMKSA API
      iwmc3200wifi: Update wiwi priority table
      iwmc3200wifi: Coex table command does not expect a response
      iwmc3200wifi: Add wifi-wimax coexistence mode as a module parameter
      iwmc3200wifi: Enable wimax core through module parameter

Sandeep Gopalpet (7):
      gianfar: Add per queue structure support
      gianfar: Introduce logical group support.
      gianfar: Add Multiple Queue Support
      fsl_pq_mdio: Add Suport for etsec2.0 devices.
      gianfar: Add support etsec2.0 registers.
      gianfar: Add Multiple group Support
      gianfar: Basic Support for programming hash rules

Sarveshwar Bandi (3):
      be2net: Implement ethtool get_phys_id function.
      be2net: Changes to update ethtool get_settings function to return appropriate values.
      be2net: Patch to flash redboot section while firmware update.

Sathya Perla (5):
      be2net: support configuration of 64 multicast addresses instead of 32
      be2net: Fix rx_drops_no_fragments stat being incorrectly indexed
      be2net: Issue fw_init/clean cmds to fw
      be2net: Fix cleanup path in be_probe()
      be2net: remove BUG_ON() when be2net runs out of mccq wrbs

Senthil Balasubramanian (5):
      ath9k: Allow PSPOLL only when the interface is configured in AP mode
      ath9k: Handle ATH9K_BEACON_RESET_TSF properly
      ath9k: Reduce PLL Settle time and eliminate redundant PLL calls.
      ath9k: Advertise midband for AR5416 devices
      ath9k: Fix bugs in handling TX power

Shan Wei (1):
      ip: update the description of rp_filter in ip-sysctl.txt

Shannon Nelson (2):
      ixgbe: handle parameters for tx and rx EITR, no div0
      ixgbe: Fix Receive Address Register (RAR) cleaning and accounting

Shanyu Zhao (2):
      iwlwifi: use only one chain for scan in PS
      iwlwifi: use configured valid rx chain for scan

Shreyas Bhatewara (2):
      vmxnet3: remove duplicate #include
      net: Getting rid of the x86 dependency to built vmxnet3

Simon Kagstrom (7):
      via-velocity: Correct 64-byte alignment for rx buffers
      via-velocity: Add ethtool interrupt coalescing support
      via-velocity: Implement NAPI support
      via-velocity: Change DMA_LENGTH_DEF (from the VIA driver)
      via-velocity: Re-enable transmit scatter-gather support
      via-velocity: Set tx checksum from ethtool instead of module parameter
      via-velocity: Bump version

Sreenivasa Honnur (9):
      vxge: Modify __vxge_hw_device_is_privilaged() to not assume function-0 as the privileged function: Resubmit#1
      vxge: Update driver_config->vpath_per_dev for each function in probe.
      vxge: Removed accessing non-supported registers.
      vxge: Fixed crash in PAE system due to wrong typecasting.
      vxge: Removed unused functions.
      vxge: Check if FCS stripping is disabled by the firmware.
      vxge: Allow multiple functions with INTA.
      vxge: Version update.
      vxge: Configure the number of transmit descriptors per packet to MAX_SKB_FRAGS + 1.

Sridhar Samudrala (2):
      net: Make UFO on master device independent of attached devices
      bridge: Allow enable/disable UFO on bridge device via ethtool

Steffen Klassert (5):
      ah: Add struct crypto_ahash to ah_data
      ah4: convert to ahash
      ah6: convert to ahash
      ah: Remove obsolete code
      xfrm: remove skb_icv_walk

Stephen Hemminger (9):
      ipv4: fib table algorithm performance improvement
      net: mark net_proto_ops as const
      dcb: data center bridging ops should be r/o
      sky2: add SK-9E21M device id
      sky2: add register definitions for new chips
      sky2: fix receive pause thresholds
      sky2: workarounds for Yukon-2 supreme
      sky2: 88E8059 support
      sky2: version 1.26

Stephen Rothwell (2):
      net/appletalk: using compat_ptr needs inclusion of linux/compat.h
      vmxnet3: using csum_ipv6_magic requires including net/ip6_checksum.h

Steve Hodgson (7):
      sfc: Only switch Falcon MAC clocks as necessary
      sfc: Simplify PHY polling
      sfc: QT202x: Reset before reading PHY id
      sfc: Replace MDIO spinlock with mutex
      sfc: Always start Falcon using the XMAC
      sfc: Generalise link state monitoring
      sfc: Add firmware protocol definitions (MCDI)

Sujith (9):
      ath9k: Update INI release for AR9287
      ath9k: Fix RTC reset for AR5416
      ath9k: Fix TX hang poll routine
      mac80211: Fix IBSS merge
      ath9k: Cleanup bss_info_changed callback
      ath9k: Remove a few unused variables
      ath9k: Remove a few unused functions
      ath9k: Fix bug in initializing chain masks
      mac80211: Fix panic in aggregation handling

Suresh R (1):
      be2net: Add support for ethtool self test

Teemu Paasikivi (5):
      wl1271: Added 5 GHz parameters for wl1273
      wl1271: Scan only enabled channels
      wl1271: Added support to scan on 5 GHz band
      wl1271: Added 5 GHz support to join and rx
      wl1271: Checking of rx descriptor status fixed

Thadeu Lima de Souza Cascardo (2):
      rt2x00: fix some typos and punctuation in comments
      rt2800lib: fix some typos and punctuation in comments

Thiago Farina (1):
      trivial: remove duplicated MIN macro from tehuti.

Thomas Gleixner (3):
      net: Remove BKL from tun
      net: Replace old style lock initializer
      Bluetooth: Remove stub ioctl in hci_vhci

Thomas Klute (1):
      ar9170: Add support for D-Link DWA 160 A2

Thomas Sailer (1):
      hamradio: Fix bit test correctly.

Tilman Schmidt (13):
      gigaset: prepare for CAPI implementation
      gigaset: allow building without I4L
      gigaset: add Kernel CAPI interface (v3)
      net/ppp: fix comments - ppp_{sync,asynctty}_receive() may sleep
      gigaset: CAPI module readability improvements
      gigaset: fix format string typo in CAPI dial command
      gigaset: fix bad assumptions about CAPI skbuffs
      usb_gigaset: code cleanup
      gigaset: checkpatch cleanup
      ser_gigaset: checkpatch cleanup
      bas_gigaset: checkpatch cleanup
      gigaset: checkpatch cleanup of ev-layer.c
      gigaset: convert strcmp chain to table lookup

Tomas Winkler (6):
      iwmc3200top: Add Intel Wireless MultiCom 3200 top driver.
      iwmc3200wifi: select IWMC3200TOP in Kconfig
      i2400m-sdio: select IWMC3200TOP in Kconfig
      iwmc3200top: use prefered style for the device table.
      iwmc3200top: simplify the driver version
      iwmc3200top: revamp fw name handling

Tristram Ha (1):
      net: Fix ks8851 snl NULL pointer dereference Oops

Ursula Braun (6):
      af_iucv: remove duplicate sock_set_flag
      iucv: add work_queue cleanup for suspend
      s390: remove cu3088 layer for lcs and ctcm
      netiucv: displayed TX bytes value much too high
      qeth: remaining EDDP cleanup
      qeth: Recognize return codes of ccw_device_set_online

Valentine Barshak (1):
      pasemi_mac: ethtool set settings support

Vasanthakumar Thiagarajan (3):
      ath9k: Update initvals
      ath9k_hw: Fix possible OOB array indexing in gen_timer_index[] on 64-bit
      ath9k_hw: Fix AR_GPIO_INPUT_EN_VAL_BT_PRIORITY_BB and its shift value in 0x4054

Vidhya Govindan (4):
      wl1251: Add acx command to set tbtt and dtim period
      wl1251: Set the correct dtim period to the firmware
      wl1251: Increase the beacon loss timeout value and handle regain event
      wl1251: Send null data packet with "TODS" bit set

Vikram Kandukuri (1):
      Bluetooth: Fix handling of BNEP setup connection requests

Vivek Natarajan (3):
      ath9k: Add Calibration checks
      ath: Updates for regulatory and country codes.
      ath9k: Ensure a fair beacon distribution in IBSS mode.

Vlad Yasevich (7):
      sctp: Fix malformed "Invalid Stream Identifier" error
      sctp: Select a working primary during sctp_connectx()
      sctp: Update SWS avaoidance receiver side algorithm
      sctp: Remove useless last_time_used variable
      sctp: Turn the enum socket options into defines
      sctp: Update max.burst implementation
      sctp: prevent too-fast association id reuse

Vladislav Zolotarov (2):
      bnx2x: Handle Rx and Tx together in NAPI
      bnx2x: Don't set netdev->trans_start

Wan ZongShun (1):
      ARM: fix bug of checking on signed return value using unsigned statement in w90p910 platform

Wei Yongjun (3):
      sctp: implement definition for SACK-IMMEDIATELY extension
      sctp: implement the receiver side for SACK-IMMEDIATELY extension
      sctp: implement the sender side for SACK-IMMEDIATELY extension

Wey-Yi Guy (75):
      iwlwifi: modify LED blink index table
      iwlwifi: remove un-supported eeprom parameters
      iwlwifi: separate nic_config for different NIC
      iwlwifi: separate set_hw_params function for 6000 series
      iwlwifi: Adjust blink rate to compensate Clock difference
      iwlwifi: show NVM version in debugfs
      iwlwifi: Use RTS/CTS as the preferred protection mechanism for 6000 series
      iwlwifi: allow user change protection mechanism for HT
      iwlwifi: EEPROM version for 1000 and 6000 series
      iwlwifi: use S_IRUGO and S_IWUSR in module parameters
      iwlwifi: send cmd to uCode to configure valid tx antenna
      iwlwifi: update PCI Subsystem ID for 1000 series
      iwlwifi: update PCI Subsystem ID for 6000 series
      iwlwifi: add LED mode to support different LED behavior
      iwlwifi: Chain Noise Calibration for 6000 series
      iwlwifi: reliable entering of critical temperature state
      iwlwifi: change valid EEPROM version for 1000 series
      iwlwifi: set default aggregation frame count limit to 31
      iwlwifi: validate the signature for EEPROM and OTP
      iwlwifi: remove duplicated/unused definition
      iwlwifi: additional items in sensitivity range table
      iwlwifi: dynamic allocate tx queue structure
      iwlwifi: showing accumulative ucode statistics counters
      iwlwifi: update channel switch command API
      iwlwifi: show current power save status reported by uCode
      iwlwifi: identify eeprom version for 6x50 series NIC
      iwlwifi: fix incorrect otp blocks number for 6x50 series
      iwlwifi: set auto clock gate disable bit for 6x00/6x50 series
      iwlwifi: no chain noise support for 6x50 series
      iwlwifi: rework for static power save
      iwlwifi: fix gain computation for 5000 series and up
      iwlwifi: separate led function from statistic notification
      iwlwifi: update bt co-exit configuration parameter
      iwlwifi: specify the valid tx/rx chain in device config structure
      iwlwifi: increase max tfd payload size
      iwlwifi: choose thermal throttle method based on device config
      iwlwifi: issue ct_kill host command based on device config
      iwlwifi: add channel switch support to 5000 series and up
      iwlwifi: remove unused parameters
      iwlwifi: remove duplicated define
      iwlwifi: update lowest API version support for 6x00 & 6x50 series
      iwlwifi: minor comments changes for wimax co-exist command
      iwlwifi: coex API data structure
      iwlwifi: add SM PS support for 6x50 series
      iwlwifi: add wimax/wifi coexist support for 6x50 series
      iwlwifi: print rx_on config to help debug
      iwlwifi: no periodic Tx/IQ calibration for 6x00/6x50 series
      iwlwifi: remove un-used parameter
      iwlwifi: fix for channel switch
      iwlwifi: drop non-production PCI-IDs
      iwlwifi: do not base station's sm_ps setting on AP
      iwlwifi: Fix issue on file transfer stalled in HT mode
      iwlwifi: validate enhanced tx power entry
      iwlwifi: disable coex until implementation ready for 6x50
      iwlwifi: remove unused parameter from iwl_channel_info
      iwlwifi: drop non-production PCI-IDs for 6x50 series
      iwlwifi: remove external reference for non-exist data structure
      iwlwifi: update reply_statistics_cmd with 'clear' parameter
      iwlwifi: eliminate the possible 1/2 dBm tx power loss in 6x00 & 6x50 series
      iwlwifi: align tx/rx statistics debugfs format
      iwlwifi: control led while update tx/rx bytes counts
      iwlwifi: set sm_ps_mode as part of cfg parameters
      iwlwifi: reset led_tpt when clear tx/rx traffic byte counts
      iwlwifi: set read/write permission for debugfs files
      iwlwifi: increase tx_queue debugfs buffer size
      iwlwifi: dynamically allocate buffer for sram debugfs file
      iwlwifi: fix reserved2 field in iwl4965_addsta
      iwlwifi: update supported PCI_ID list for 5xx0 series
      iwlwifi: by default, dump entire sram data portion
      iwlwifi: dump error log when uCode error occurred
      iwlwifi: print limited number of event log when uCode error
      iwlwifi: change message for cmd queue full error
      iwlwifi: remove reset led_tpt from iwl_leds_init()
      iwl3945: remove duplicated event logging code
      iwlwifi: indicate uCode type when fail dump error/event log

William Allen Simpson (8):
      net: TCP_MSS_DEFAULT, TCP_MSS_DESIRED
      TCPCT part 1a: add request_values parameter for sending SYNACK
      TCPCT part 1b: generate Responder Cookie secret
      TCPCT part 1c: sysctl_tcp_cookie_size, socket option TCP_COOKIE_TRANSACTIONS
      TCPCT part 1d: define TCP cookie option, extend existing struct's
      TCPCT part 1e: implement socket option TCP_COOKIE_TRANSACTIONS
      TCPCT part 1f: Initiator Cookie => Responder
      TCPCT part 1g: Responder Cookie => Initiator

Wolfgang Grandegger (2):
      can: make the number of echo skb's configurable
      can: provide library functions for skb allocation

Wolfram Sang (12):
      net/can: add driver for mscan family & mpc52xx_mscan
      net/can/mscan: move defines into .h file
      net/can/mscan: trivial fixes
      net/can/mscan: drop support for CAN_MODE_{SLEEP|STOP}
      net/can/mscan: use {clr|set}bits8 macros
      net/can/mscan: fix function annotations
      net/can/mscan: drop assignment in while-construct
      net/can/mpc52xx_can: refactor clock-get routine
      net/can/mpc52xx_can: improve properties and their description
      net/can/mscan: replace hardcoded values with defines
      net/can/mscan: add error path to mscan_open()
      net/can/mscan: improve build

Xose Vazquez Perez (1):
      rt2x00: more ids to rt2800usb.c

YOSHIFUJI Hideaki / 吉藤英明 (4):
      ipv6 sit: 6rd (IPv6 Rapid Deployment) Support.
      ipv6 sit: Ensure to initialize 6rd parameters.
      ipv6 sit: Fix 6rd relay address.
      ipv6 sit: Set relay to 0.0.0.0 directly if relay_prefixlen == 0.

Yaniv Rosner (10):
      bnx2x: Fix Parallel-Detect settings
      bnx2x: Fix CL73 autoneg issues
      bnx2x: Miscellaneous debug print and tabs
      bnx2x: Enable FC when parallel-detect is used
      bnx2x: Modify BCM8706 link init seq
      bnx2x: Add support for BCM84823
      bnx2x: Fix BCM8726 ROM load seq
      bnx2x: Fix 10G mode in BCM8481/BCM84823
      bnx2x: Fix register access timeout in 10M
      bnx2x: version 1.52.1-3

Yi Zou (6):
      ixgbe: Add support for 82599 alternative WWNN/WWPN prefix
      net: Add ndo_fcoe_get_wwn to net_device_ops
      ixgbe: Add support for netdev_ops.ndo_fcoe_get_wwn to 82599
      vlan: Add support to netdev_ops.ndo_fcoe_get_wwn for VLAN device
      ixgbe: use known user priority for FCoE when DCB is enabled
      ixgbe: select FCoE Tx queue in ndo_select_queue

Yury Polyanskiy (1):
      xfrm: SAD entries do not expire correctly after suspend-resume

Zhu Yi (11):
      iwlwifi: use paged Rx
      iwmc3200wifi: add BGN sdio device id
      iwmc3200wifi: allow joining an existed IBSS network
      iwmc3200wifi: handle coexistence radio notification
      iwlwifi: fix use after free bug for paged rx
      iwlwifi: reuse page for notification packets
      mac80211: make align adjustment code support paged SKB
      iwlwifi: allocate 128 bytes linear buffer for rx skb
      iwmc3200wifi: Set wireless mode correctly
      iwmc3200wifi: fix NULL pointer dereference in pmkid update
      ipw2100: fix rebooting hang with driver loaded

andrew hendry (3):
      X25: Move SYSCTL ifdefs into header
      X25: Check for errors in x25_init
      X25: Fix oops and refcnt problems from x25_dev_get

chaithrika@ti.com (1):
      TI DaVinci EMAC: Minor macro related updates

fangxiaozhi (1):
      net: PPP buffer too small for higher speed connections

jamal (2):
      pkt_sched: ingress socket filter by mark
      pkt_sched: skbedit add support for setting mark

roel kluin (8):
      x25: bit and/or confusion in x25_ioctl()?
      net/hamradio: fix test in receive()
      sb1250-mac: duplicate setting of bit V_MAC_RX_PL_THRSH(4) in sbmac_channel_start()
      net: Cleanup redundant tests on unsigned
      net: Cleanup redundant tests on unsigned
      atm: Cleanup redundant tests on unsigned
      ax25: unsigned cannot be less than 0 in ax25_ctl_ioctl()
      cnic: ensure ulp_type is not negative

stephen hemminger (10):
      netdev: add netdev_continue_rcu
      vlan: eliminate use of dev_base_lock
      net: use rcu for network scheduler API
      s390: use RCU to walk list of network devices
      decnet: use RCU to find network devices
      IPV4: use rcu to walk list of devices in IGMP
      CAN: use dev_get_by_index_rcu
      netdev: fold name hash properly (v3)
      decnet: add RTNL lock when reading address list
      decnet: convert dndev_lock to spinlock

zeal (2):
      KS8695: fix ks8695_rx_irq() bug.
      KS8695: fix ks8695_rx() unreasonable action.

 Documentation/feature-removal-schedule.txt         |   12 -
 Documentation/isdn/README.gigaset                  |   34 +-
 Documentation/kernel-parameters.txt                |    3 +
 Documentation/networking/bonding.txt               |   42 +-
 Documentation/networking/ip-sysctl.txt             |   36 +-
 Documentation/powerpc/dts-bindings/fsl/mpc5200.txt |   10 +
 MAINTAINERS                                        |   14 +-
 arch/alpha/include/asm/socket.h                    |    2 +
 arch/alpha/include/asm/unistd.h                    |    3 +-
 arch/alpha/kernel/systbls.S                        |    1 +
 arch/arm/include/asm/socket.h                      |    2 +
 arch/arm/kernel/calls.S                            |    1 +
 arch/avr32/include/asm/socket.h                    |    2 +
 arch/avr32/kernel/syscall_table.S                  |    1 +
 arch/blackfin/mach-common/entry.S                  |    1 +
 arch/cris/include/asm/socket.h                     |    2 +
 arch/frv/include/asm/socket.h                      |    2 +
 arch/h8300/include/asm/socket.h                    |    2 +
 arch/ia64/include/asm/socket.h                     |    2 +
 arch/ia64/include/asm/unistd.h                     |    3 +-
 arch/ia64/kernel/entry.S                           |    1 +
 arch/m32r/include/asm/socket.h                     |    2 +
 arch/m68k/include/asm/socket.h                     |    2 +
 arch/microblaze/kernel/syscall_table.S             |    1 +
 arch/mips/include/asm/socket.h                     |    2 +
 arch/mips/include/asm/unistd.h                     |   15 +-
 arch/mips/kernel/scall32-o32.S                     |    1 +
 arch/mips/kernel/scall64-64.S                      |    1 +
 arch/mips/kernel/scall64-n32.S                     |    1 +
 arch/mips/kernel/scall64-o32.S                     |    1 +
 arch/mn10300/include/asm/socket.h                  |    2 +
 arch/parisc/include/asm/socket.h                   |    2 +
 arch/powerpc/include/asm/socket.h                  |    2 +
 arch/s390/appldata/appldata_net_sum.c              |    8 +-
 arch/s390/include/asm/socket.h                     |    2 +
 arch/sh/include/asm/sh_eth.h                       |    1 +
 arch/sh/kernel/syscalls_64.S                       |    1 +
 arch/sparc/include/asm/socket.h                    |    2 +
 arch/sparc/include/asm/unistd.h                    |    3 +-
 arch/sparc/kernel/systbls_32.S                     |    2 +-
 arch/sparc/kernel/systbls_64.S                     |    4 +-
 arch/x86/ia32/ia32entry.S                          |    1 +
 arch/x86/include/asm/unistd_32.h                   |    3 +-
 arch/x86/include/asm/unistd_64.h                   |    2 +
 arch/x86/kernel/syscall_table_32.S                 |    1 +
 arch/xtensa/include/asm/socket.h                   |    2 +
 arch/xtensa/include/asm/unistd.h                   |    4 +-
 drivers/atm/ambassador.c                           |    1 +
 drivers/atm/fore200e.c                             |    4 +-
 drivers/atm/he.c                                   |    2 +-
 drivers/atm/solos-pci.c                            |   32 +-
 drivers/bluetooth/btmrvl_debugfs.c                 |    1 -
 drivers/bluetooth/btmrvl_drv.h                     |    1 +
 drivers/bluetooth/btmrvl_main.c                    |   55 +-
 drivers/bluetooth/btmrvl_sdio.c                    |    4 +
 drivers/bluetooth/hci_vhci.c                       |   20 +-
 drivers/ieee802154/fakehard.c                      |   59 +-
 drivers/infiniband/hw/nes/nes_nic.c                |   12 +-
 drivers/isdn/gigaset/Kconfig                       |   25 +-
 drivers/isdn/gigaset/Makefile                      |    5 +-
 drivers/isdn/gigaset/asyncdata.c                   |  662 +-
 drivers/isdn/gigaset/bas-gigaset.c                 |   76 +-
 drivers/isdn/gigaset/capi.c                        | 2292 ++++
 drivers/isdn/gigaset/common.c                      |  139 +-
 drivers/isdn/gigaset/dummyll.c                     |   68 +
 drivers/isdn/gigaset/ev-layer.c                    |  578 +-
 drivers/isdn/gigaset/gigaset.h                     |  176 +-
 drivers/isdn/gigaset/i4l.c                         |  563 +-
 drivers/isdn/gigaset/interface.c                   |   41 +-
 drivers/isdn/gigaset/isocdata.c                    |  186 +-
 drivers/isdn/gigaset/proc.c                        |    2 +-
 drivers/isdn/gigaset/ser-gigaset.c                 |   56 +-
 drivers/isdn/gigaset/usb-gigaset.c                 |   71 +-
 drivers/isdn/hardware/mISDN/speedfax.c             |    1 +
 drivers/isdn/mISDN/socket.c                        |    5 +-
 drivers/misc/Kconfig                               |    1 +
 drivers/misc/Makefile                              |    1 +
 drivers/misc/iwmc3200top/Kconfig                   |   20 +
 drivers/misc/iwmc3200top/Makefile                  |   29 +
 drivers/misc/iwmc3200top/debugfs.c                 |  133 +
 drivers/misc/iwmc3200top/debugfs.h                 |   58 +
 drivers/misc/iwmc3200top/fw-download.c             |  355 +
 drivers/misc/iwmc3200top/fw-msg.h                  |  113 +
 drivers/misc/iwmc3200top/iwmc3200top.h             |  209 +
 drivers/misc/iwmc3200top/log.c                     |  347 +
 drivers/misc/iwmc3200top/log.h                     |  158 +
 drivers/misc/iwmc3200top/main.c                    |  678 ++
 drivers/net/3c501.c                                |   10 +-
 drivers/net/3c503.c                                |   15 +-
 drivers/net/3c505.c                                |    2 +-
 drivers/net/3c507.c                                |    6 +-
 drivers/net/3c509.c                                |   12 +-
 drivers/net/3c515.c                                |   15 +-
 drivers/net/3c523.c                                |    2 +-
 drivers/net/3c527.c                                |    6 +-
 drivers/net/3c59x.c                                |    7 +-
 drivers/net/8139cp.c                               |   12 +-
 drivers/net/8139too.c                              |   15 +-
 drivers/net/Kconfig                                |    4 +-
 drivers/net/appletalk/cops.c                       |    2 +-
 drivers/net/appletalk/ipddp.c                      |   12 +-
 drivers/net/appletalk/ltpc.c                       |    2 +-
 drivers/net/arcnet/arc-rimi.c                      |    8 +-
 drivers/net/arcnet/arcnet.c                        |   14 +-
 drivers/net/arcnet/com20020.c                      |    2 +-
 drivers/net/arcnet/com90io.c                       |    2 +-
 drivers/net/arcnet/com90xx.c                       |    2 +-
 drivers/net/arm/ks8695net.c                        |  131 +-
 drivers/net/arm/w90p910_ether.c                    |    4 +-
 drivers/net/at1700.c                               |   18 +-
 drivers/net/atarilance.c                           |    4 +-
 drivers/net/atl1c/atl1c.h                          |   22 +-
 drivers/net/atl1c/atl1c_main.c                     |   88 +-
 drivers/net/atl1e/atl1e_ethtool.c                  |   17 +-
 drivers/net/atl1e/atl1e_main.c                     |   42 +-
 drivers/net/atlx/atl1.c                            |   21 +-
 drivers/net/atlx/atl2.c                            |    5 +-
 drivers/net/atp.c                                  |    6 +-
 drivers/net/au1000_eth.c                           |    2 +-
 drivers/net/bcm63xx_enet.c                         |    5 +-
 drivers/net/benet/be.h                             |   24 +-
 drivers/net/benet/be_cmds.c                        |  496 +-
 drivers/net/benet/be_cmds.h                        |  152 +-
 drivers/net/benet/be_ethtool.c                     |  204 +-
 drivers/net/benet/be_hw.h                          |    9 +
 drivers/net/benet/be_main.c                        |  257 +-
 drivers/net/bfin_mac.c                             |   12 +-
 drivers/net/bmac.c                                 |    4 +-
 drivers/net/bnx2.c                                 |  217 +-
 drivers/net/bnx2.h                                 |    3 +
 drivers/net/bnx2x.h                                |   95 +-
 drivers/net/bnx2x_hsi.h                            |   21 +-
 drivers/net/bnx2x_link.c                           |  321 +-
 drivers/net/bnx2x_link.h                           |    3 +-
 drivers/net/bnx2x_main.c                           | 1443 ++-
 drivers/net/bnx2x_reg.h                            |   23 +-
 drivers/net/bonding/bond_3ad.c                     |  123 +-
 drivers/net/bonding/bond_alb.c                     |    3 -
 drivers/net/bonding/bond_ipv6.c                    |    7 +-
 drivers/net/bonding/bond_main.c                    |  316 +-
 drivers/net/bonding/bond_sysfs.c                   |   92 +-
 drivers/net/bonding/bonding.h                      |   35 +-
 drivers/net/can/Kconfig                            |   15 +
 drivers/net/can/Makefile                           |    3 +
 drivers/net/can/at91_can.c                         |   34 +-
 drivers/net/can/dev.c                              |   76 +-
 drivers/net/can/mcp251x.c                          | 1166 ++
 drivers/net/can/mscan/Kconfig                      |   23 +
 drivers/net/can/mscan/Makefile                     |    5 +
 drivers/net/can/mscan/mpc5xxx_can.c                |  259 +
 drivers/net/can/mscan/mscan.c                      |  668 +
 drivers/net/can/mscan/mscan.h                      |  296 +
 drivers/net/can/sja1000/sja1000.c                  |   19 +-
 drivers/net/can/sja1000/sja1000.h                  |    2 +
 drivers/net/can/ti_hecc.c                          |  993 ++
 drivers/net/can/usb/ems_usb.c                      |   28 +-
 drivers/net/cnic.c                                 | 1875 +++-
 drivers/net/cnic.h                                 |   64 +
 drivers/net/cnic_defs.h                            | 1917 +++
 drivers/net/cnic_if.h                              |   14 +-
 drivers/net/cpmac.c                                |    6 +-
 drivers/net/cs89x0.c                               |    2 +-
 drivers/net/cxgb3/adapter.h                        |   16 +
 drivers/net/cxgb3/common.h                         |    8 +-
 drivers/net/cxgb3/cxgb3_main.c                     |   73 +-
 drivers/net/cxgb3/sge.c                            |   31 +-
 drivers/net/davinci_emac.c                         |   30 +-
 drivers/net/declance.c                             |    4 +-
 drivers/net/depca.c                                |    2 +-
 drivers/net/dl2k.c                                 |   24 +-
 drivers/net/dm9000.c                               |  149 +-
 drivers/net/dm9000.h                               |    7 +
 drivers/net/e100.c                                 |   25 +-
 drivers/net/e1000/e1000.h                          |    2 +-
 drivers/net/e1000/e1000_ethtool.c                  |   39 +-
 drivers/net/e1000/e1000_main.c                     |  130 +-
 drivers/net/e1000e/82571.c                         |  323 +-
 drivers/net/e1000e/defines.h                       |    2 +-
 drivers/net/e1000e/e1000.h                         |   47 +-
 drivers/net/e1000e/es2lan.c                        |  213 +-
 drivers/net/e1000e/ethtool.c                       |   81 +-
 drivers/net/e1000e/hw.h                            |   52 +-
 drivers/net/e1000e/ich8lan.c                       |  530 +-
 drivers/net/e1000e/lib.c                           |  261 +-
 drivers/net/e1000e/netdev.c                        |  470 +-
 drivers/net/e1000e/param.c                         |    2 +-
 drivers/net/e1000e/phy.c                           |  516 +-
 drivers/net/e2100.c                                |    6 +-
 drivers/net/eepro.c                                |    2 +-
 drivers/net/eexpress.c                             |    2 +-
 drivers/net/ehea/ehea_main.c                       |   29 +-
 drivers/net/ehea/ehea_qmr.c                        |    4 +-
 drivers/net/enic/enic_main.c                       |   15 +-
 drivers/net/epic100.c                              |   10 +-
 drivers/net/ethoc.c                                |    6 +-
 drivers/net/fealnx.c                               |   14 +-
 drivers/net/fec_mpc52xx.c                          |    6 +-
 drivers/net/forcedeth.c                            |    6 +-
 drivers/net/fsl_pq_mdio.c                          |   67 +-
 drivers/net/fsl_pq_mdio.h                          |   11 +-
 drivers/net/gianfar.c                              | 1826 ++-
 drivers/net/gianfar.h                              |  412 +-
 drivers/net/gianfar_ethtool.c                      |  376 +-
 drivers/net/gianfar_sysfs.c                        |   81 +-
 drivers/net/hamachi.c                              |   24 +-
 drivers/net/hamradio/6pack.c                       |   21 +
 drivers/net/hamradio/baycom_epp.c                  |    6 +-
 drivers/net/hamradio/bpqether.c                    |    9 +-
 drivers/net/hamradio/dmascc.c                      |    8 +-
 drivers/net/hamradio/mkiss.c                       |   21 +
 drivers/net/hp-plus.c                              |    4 +-
 drivers/net/hp100.c                                |    4 +-
 drivers/net/ibm_newemac/core.c                     |   34 +-
 drivers/net/ibmveth.c                              |    2 +-
 drivers/net/ifb.c                                  |   10 +-
 drivers/net/igb/e1000_82575.c                      |  572 +-
 drivers/net/igb/e1000_82575.h                      |   32 +
 drivers/net/igb/e1000_defines.h                    |   50 +-
 drivers/net/igb/e1000_hw.h                         |   22 +-
 drivers/net/igb/e1000_mac.c                        |  100 +-
 drivers/net/igb/e1000_mbx.c                        |   82 +-
 drivers/net/igb/e1000_mbx.h                        |   10 +-
 drivers/net/igb/e1000_nvm.c                        |   36 +-
 drivers/net/igb/e1000_phy.c                        |  453 +-
 drivers/net/igb/e1000_phy.h                        |   37 +-
 drivers/net/igb/e1000_regs.h                       |   80 +-
 drivers/net/igb/igb.h                              |  149 +-
 drivers/net/igb/igb_ethtool.c                      |  747 +-
 drivers/net/igb/igb_main.c                         | 3450 +++---
 drivers/net/igbvf/ethtool.c                        |   25 +-
 drivers/net/igbvf/igbvf.h                          |    1 +
 drivers/net/igbvf/netdev.c                         |   83 +-
 drivers/net/ipg.c                                  |    9 +-
 drivers/net/irda/au1k_ir.c                         |    4 +-
 drivers/net/irda/irda-usb.c                        |   10 +-
 drivers/net/irda/stir4200.c                        |   12 +-
 drivers/net/irda/via-ircc.c                        |   16 +-
 drivers/net/irda/vlsi_ir.c                         |   16 +-
 drivers/net/isa-skeleton.c                         |   10 +-
 drivers/net/iseries_veth.c                         |   42 +-
 drivers/net/ixgb/ixgb.h                            |    2 +-
 drivers/net/ixgb/ixgb_ethtool.c                    |   69 +-
 drivers/net/ixgb/ixgb_main.c                       |  118 +-
 drivers/net/ixgbe/ixgbe.h                          |   33 +-
 drivers/net/ixgbe/ixgbe_82599.c                    |  178 +-
 drivers/net/ixgbe/ixgbe_common.c                   |   37 +-
 drivers/net/ixgbe/ixgbe_dcb_nl.c                   |    2 +-
 drivers/net/ixgbe/ixgbe_ethtool.c                  |  140 +-
 drivers/net/ixgbe/ixgbe_fcoe.c                     |   76 +-
 drivers/net/ixgbe/ixgbe_fcoe.h                     |    3 +
 drivers/net/ixgbe/ixgbe_main.c                     |  251 +-
 drivers/net/ixgbe/ixgbe_type.h                     |   26 +
 drivers/net/ixp2000/ixpdev.c                       |    3 +-
 drivers/net/jazzsonic.c                            |    6 +-
 drivers/net/jme.c                                  |   22 +-
 drivers/net/korina.c                               |   13 +-
 drivers/net/ks8842.c                               |    5 +-
 drivers/net/ks8851.c                               |    4 +-
 drivers/net/lance.c                                |   14 +-
 drivers/net/lib82596.c                             |   13 +-
 drivers/net/lib8390.c                              |   12 +-
 drivers/net/ll_temac_main.c                        |    4 +-
 drivers/net/loopback.c                             |   10 +-
 drivers/net/lp486e.c                               |    2 +-
 drivers/net/mac89x0.c                              |    6 +-
 drivers/net/mace.c                                 |    4 +-
 drivers/net/macsonic.c                             |    4 +-
 drivers/net/macvlan.c                              |  278 +-
 drivers/net/mdio.c                                 |   12 +-
 drivers/net/mipsnet.c                              |    2 +-
 drivers/net/mv643xx_eth.c                          |    2 +-
 drivers/net/myri10ge/myri10ge.c                    |   25 +-
 drivers/net/myri_sbus.c                            |    2 +-
 drivers/net/natsemi.c                              |   30 +-
 drivers/net/netx-eth.c                             |    5 +-
 drivers/net/netxen/netxen_nic.h                    |   78 +-
 drivers/net/netxen/netxen_nic_ethtool.c            |   38 +-
 drivers/net/netxen/netxen_nic_hdr.h                |   76 +-
 drivers/net/netxen/netxen_nic_hw.c                 |  995 +-
 drivers/net/netxen/netxen_nic_init.c               |  361 +-
 drivers/net/netxen/netxen_nic_main.c               |  334 +-
 drivers/net/ni5010.c                               |    2 +-
 drivers/net/ni52.c                                 |    6 +-
 drivers/net/ni65.c                                 |    2 +-
 drivers/net/niu.c                                  |   15 +-
 drivers/net/ns83820.c                              |   24 +-
 drivers/net/pasemi_mac.c                           |    4 +-
 drivers/net/pasemi_mac_ethtool.c                   |   14 +
 drivers/net/pci-skeleton.c                         |   12 +-
 drivers/net/pcmcia/axnet_cs.c                      |    4 +-
 drivers/net/pcmcia/fmvj18x_cs.c                    |   22 +-
 drivers/net/pcmcia/nmclan_cs.c                     |    2 +-
 drivers/net/pcmcia/pcnet_cs.c                      |   11 +-
 drivers/net/pcmcia/smc91c92_cs.c                   |    8 +-
 drivers/net/pcmcia/xirc2ps_cs.c                    |    6 +-
 drivers/net/pcnet32.c                              |   22 +-
 drivers/net/phy/broadcom.c                         |  208 +-
 drivers/net/phy/phy.c                              |   18 +-
 drivers/net/plip.c                                 |   13 +-
 drivers/net/ppp_async.c                            |   19 +-
 drivers/net/ppp_deflate.c                          |   44 +-
 drivers/net/ppp_generic.c                          |   98 +-
 drivers/net/ppp_mppe.c                             |    8 +-
 drivers/net/ppp_synctty.c                          |    9 +-
 drivers/net/pppoe.c                                |   63 +-
 drivers/net/pppol2tp.c                             |   62 +-
 drivers/net/pppox.c                                |    5 +-
 drivers/net/ps3_gelic_net.c                        |   98 +-
 drivers/net/ps3_gelic_net.h                        |   21 +-
 drivers/net/qla3xxx.c                              |    8 +-
 drivers/net/qlge/qlge.h                            |  229 +-
 drivers/net/qlge/qlge_dbg.c                        |  180 +
 drivers/net/qlge/qlge_ethtool.c                    |  290 +
 drivers/net/qlge/qlge_main.c                       |  490 +-
 drivers/net/qlge/qlge_mpi.c                        |  210 +-
 drivers/net/r6040.c                                |    5 +-
 drivers/net/r8169.c                                |   71 +-
 drivers/net/s6gmac.c                               |    8 +-
 drivers/net/sb1000.c                               |    2 +-
 drivers/net/sb1250-mac.c                           |    3 +-
 drivers/net/sc92031.c                              |   18 +-
 drivers/net/seeq8005.c                             |    4 +-
 drivers/net/sfc/Kconfig                            |   13 +-
 drivers/net/sfc/Makefile                           |    7 +-
 drivers/net/sfc/bitfield.h                         |   17 +-
 drivers/net/sfc/boards.c                           |  328 -
 drivers/net/sfc/boards.h                           |   28 -
 drivers/net/sfc/efx.c                              |  793 +-
 drivers/net/sfc/efx.h                              |   65 +-
 drivers/net/sfc/enum.h                             |  116 +-
 drivers/net/sfc/ethtool.c                          |  222 +-
 drivers/net/sfc/ethtool.h                          |   27 -
 drivers/net/sfc/falcon.c                           | 2829 ++----
 drivers/net/sfc/falcon.h                           |  145 -
 drivers/net/sfc/falcon_boards.c                    |  752 ++
 drivers/net/sfc/falcon_gmac.c                      |  123 +-
 drivers/net/sfc/falcon_hwdefs.h                    | 1333 --
 drivers/net/sfc/falcon_io.h                        |  258 -
 drivers/net/sfc/falcon_xmac.c                      |  278 +-
 drivers/net/sfc/gmii.h                             |   60 -
 drivers/net/sfc/io.h                               |  256 +
 drivers/net/sfc/mac.h                              |    6 +-
 drivers/net/sfc/mcdi.c                             | 1112 ++
 drivers/net/sfc/mcdi.h                             |  130 +
 drivers/net/sfc/mcdi_mac.c                         |  152 +
 drivers/net/sfc/mcdi_pcol.h                        | 1578 +++
 drivers/net/sfc/mcdi_phy.c                         |  597 +
 drivers/net/sfc/mdio_10g.c                         |  144 +-
 drivers/net/sfc/mdio_10g.h                         |    6 +-
 drivers/net/sfc/mtd.c                              |  559 +-
 drivers/net/sfc/net_driver.h                       |  302 +-
 drivers/net/sfc/nic.c                              | 1583 +++
 drivers/net/sfc/nic.h                              |  261 +
 drivers/net/sfc/phy.h                              |   27 +-
 drivers/net/sfc/{xfp_phy.c => qt202x_phy.c}        |  132 +-
 drivers/net/sfc/regs.h                             | 3168 +++++
 drivers/net/sfc/rx.c                               |   82 +-
 drivers/net/sfc/rx.h                               |   26 -
 drivers/net/sfc/selftest.c                         |  146 +-
 drivers/net/sfc/sfe4001.c                          |  435 -
 drivers/net/sfc/siena.c                            |  604 +
 drivers/net/sfc/spi.h                              |   18 +-
 drivers/net/sfc/tenxpress.c                        |  223 +-
 drivers/net/sfc/tx.c                               |  184 +-
 drivers/net/sfc/tx.h                               |   25 -
 drivers/net/sfc/workarounds.h                      |   20 +-
 drivers/net/sgiseeq.c                              |    7 +-
 drivers/net/sh_eth.c                               |   56 +-
 drivers/net/sh_eth.h                               |    1 +
 drivers/net/sis190.c                               |    3 +-
 drivers/net/sis900.c                               |    2 +-
 drivers/net/skge.c                                 |   32 +-
 drivers/net/sky2.c                                 |  157 +-
 drivers/net/sky2.h                                 |  185 +-
 drivers/net/slip.c                                 |   33 +-
 drivers/net/smc-mca.c                              |    6 +-
 drivers/net/smc911x.c                              |    2 +-
 drivers/net/smc9194.c                              |    2 +-
 drivers/net/smc91x.c                               |   20 +-
 drivers/net/smc91x.h                               |   10 +-
 drivers/net/smsc911x.c                             |    7 +-
 drivers/net/smsc9420.c                             |    2 +-
 drivers/net/spider_net.c                           |    1 +
 drivers/net/starfire.c                             |   10 +-
 drivers/net/stmmac/stmmac_main.c                   |    5 +-
 drivers/net/sun3_82586.c                           |    2 +-
 drivers/net/sunbmac.c                              |    2 +-
 drivers/net/sundance.c                             |   18 +-
 drivers/net/sungem.c                               |    4 +-
 drivers/net/sungem.h                               |    4 +-
 drivers/net/sunhme.c                               |   27 +-
 drivers/net/sunlance.c                             |    2 +-
 drivers/net/sunqe.c                                |    2 +-
 drivers/net/tc35815.c                              |  292 +-
 drivers/net/tehuti.c                               |   45 +-
 drivers/net/tehuti.h                               |    2 -
 drivers/net/tg3.c                                  | 1254 ++-
 drivers/net/tg3.h                                  |   99 +-
 drivers/net/tlan.c                                 |   11 +-
 drivers/net/tokenring/3c359.c                      |    3 +-
 drivers/net/tokenring/ibmtr.c                      |    2 +-
 drivers/net/tokenring/lanstreamer.c                |   10 +-
 drivers/net/tokenring/olympic.c                    |    4 +-
 drivers/net/tokenring/smctr.c                      |   86 +-
 drivers/net/tokenring/tms380tr.c                   |   26 +-
 drivers/net/tsi108_eth.c                           |   10 +-
 drivers/net/tulip/21142.c                          |    8 +-
 drivers/net/tulip/de2104x.c                        |    6 +-
 drivers/net/tulip/dmfe.c                           |    2 +-
 drivers/net/tulip/eeprom.c                         |    8 +-
 drivers/net/tulip/interrupt.c                      |   16 +-
 drivers/net/tulip/media.c                          |    4 +-
 drivers/net/tulip/pnic2.c                          |    6 +-
 drivers/net/tulip/tulip_core.c                     |   26 +-
 drivers/net/tulip/uli526x.c                        |    2 +-
 drivers/net/tulip/winbond-840.c                    |   10 +-
 drivers/net/tulip/xircom_cb.c                      |    2 +-
 drivers/net/tun.c                                  |   58 +-
 drivers/net/typhoon.c                              |    6 +-
 drivers/net/ucc_geth.c                             |   24 +-
 drivers/net/usb/asix.c                             |   24 +-
 drivers/net/usb/catc.c                             |    4 +-
 drivers/net/usb/cdc-phonet.c                       |    8 +-
 drivers/net/usb/cdc_eem.c                          |    4 +-
 drivers/net/usb/cdc_ether.c                        |   79 +-
 drivers/net/usb/dm9601.c                           |    2 +-
 drivers/net/usb/hso.c                              |   34 +-
 drivers/net/usb/kaweth.c                           |   11 +-
 drivers/net/usb/mcs7830.c                          |    4 +-
 drivers/net/usb/rndis_host.c                       |   10 +-
 drivers/net/usb/usbnet.c                           |  218 +-
 drivers/net/usb/zaurus.c                           |    4 +-
 drivers/net/veth.c                                 |   38 +-
 drivers/net/via-rhine.c                            |   20 +-
 drivers/net/via-velocity.c                         |  405 +-
 drivers/net/via-velocity.h                         |   15 +-
 drivers/net/virtio_net.c                           |   17 +-
 drivers/net/vmxnet3/vmxnet3_defs.h                 |  246 +-
 drivers/net/vmxnet3/vmxnet3_drv.c                  |  363 +-
 drivers/net/vmxnet3/vmxnet3_ethtool.c              |   10 +-
 drivers/net/vmxnet3/vmxnet3_int.h                  |   17 +-
 drivers/net/vxge/vxge-config.c                     |  300 +-
 drivers/net/vxge/vxge-config.h                     |    2 +
 drivers/net/vxge/vxge-main.c                       |  115 +-
 drivers/net/vxge/vxge-main.h                       |    1 -
 drivers/net/vxge/vxge-reg.h                        |    4 -
 drivers/net/vxge/vxge-traffic.c                    |   24 +-
 drivers/net/vxge/vxge-traffic.h                    |    2 +
 drivers/net/vxge/vxge-version.h                    |    4 +-
 drivers/net/wan/cosa.c                             |   20 +-
 drivers/net/wan/dlci.c                             |   14 +-
 drivers/net/wan/dscc4.c                            |    2 +-
 drivers/net/wan/farsync.c                          |   12 +-
 drivers/net/wan/hdlc.c                             |    4 +-
 drivers/net/wan/hdlc_fr.c                          |    6 +-
 drivers/net/wan/hostess_sv11.c                     |    2 +-
 drivers/net/wan/lmc/lmc_main.c                     |    2 +-
 drivers/net/wan/n2.c                               |    2 +-
 drivers/net/wan/pc300_drv.c                        |   17 +-
 drivers/net/wan/sbni.c                             |   28 +-
 drivers/net/wan/sdla.c                             |    2 +-
 drivers/net/wan/sealevel.c                         |   13 +-
 drivers/net/wan/x25_asy.c                          |   23 +-
 drivers/net/wimax/i2400m/Kconfig                   |    8 +
 drivers/net/wimax/i2400m/control.c                 |   16 +-
 drivers/net/wimax/i2400m/debugfs.c                 |    2 +-
 drivers/net/wimax/i2400m/driver.c                  |  500 +-
 drivers/net/wimax/i2400m/fw.c                      |  886 ++-
 drivers/net/wimax/i2400m/i2400m-sdio.h             |   16 +-
 drivers/net/wimax/i2400m/i2400m-usb.h              |   16 +-
 drivers/net/wimax/i2400m/i2400m.h                  |  209 +-
 drivers/net/wimax/i2400m/netdev.c                  |  127 +-
 drivers/net/wimax/i2400m/rx.c                      |  170 +-
 drivers/net/wimax/i2400m/sdio-fw.c                 |   11 +-
 drivers/net/wimax/i2400m/sdio-rx.c                 |   42 +-
 drivers/net/wimax/i2400m/sdio-tx.c                 |    5 +-
 drivers/net/wimax/i2400m/sdio.c                    |  205 +-
 drivers/net/wimax/i2400m/tx.c                      |   20 +-
 drivers/net/wimax/i2400m/usb-fw.c                  |   37 +-
 drivers/net/wimax/i2400m/usb-notif.c               |   35 +-
 drivers/net/wimax/i2400m/usb-rx.c                  |   60 +-
 drivers/net/wimax/i2400m/usb-tx.c                  |   61 +-
 drivers/net/wimax/i2400m/usb.c                     |  189 +-
 drivers/net/wireless/Kconfig                       |  212 +-
 drivers/net/wireless/Makefile                      |   10 -
 drivers/net/wireless/adm8211.c                     |    2 +-
 drivers/net/wireless/airo.c                        |    5 +-
 drivers/net/wireless/at76c50x-usb.c                |   55 +-
 drivers/net/wireless/ath/Kconfig                   |    9 +-
 drivers/net/wireless/ath/Makefile                  |    9 +-
 drivers/net/wireless/ath/ar9170/Kconfig            |    2 +-
 drivers/net/wireless/ath/ar9170/ar9170.h           |    6 +-
 drivers/net/wireless/ath/ar9170/cmd.c              |    3 +-
 drivers/net/wireless/ath/ar9170/cmd.h              |    1 +
 drivers/net/wireless/ath/ar9170/hw.h               |    6 +-
 drivers/net/wireless/ath/ar9170/mac.c              |   15 +-
 drivers/net/wireless/ath/ar9170/main.c             |   50 +-
 drivers/net/wireless/ath/ar9170/phy.c              |   99 +-
 drivers/net/wireless/ath/ar9170/usb.c              |   16 +-
 drivers/net/wireless/ath/ar9170/usb.h              |    2 +-
 drivers/net/wireless/ath/ath.h                     |   69 +
 drivers/net/wireless/ath/ath5k/Kconfig             |    2 +-
 drivers/net/wireless/ath/ath5k/ath5k.h             |   53 +-
 drivers/net/wireless/ath/ath5k/attach.c            |   33 +-
 drivers/net/wireless/ath/ath5k/base.c              |  140 +-
 drivers/net/wireless/ath/ath5k/base.h              |   14 -
 drivers/net/wireless/ath/ath5k/initvals.c          |    4 +-
 drivers/net/wireless/ath/ath5k/led.c               |    2 +
 drivers/net/wireless/ath/ath5k/pcu.c               |  193 +-
 drivers/net/wireless/ath/ath5k/phy.c               |  191 +-
 drivers/net/wireless/ath/ath5k/reg.h               |   19 +-
 drivers/net/wireless/ath/ath5k/reset.c             |   33 +-
 drivers/net/wireless/ath/ath9k/Kconfig             |   18 +-
 drivers/net/wireless/ath/ath9k/Makefile            |   32 +-
 drivers/net/wireless/ath/ath9k/ahb.c               |   29 +-
 drivers/net/wireless/ath/ath9k/ani.c               |  141 +-
 drivers/net/wireless/ath/ath9k/ath9k.h             |  215 +-
 drivers/net/wireless/ath/ath9k/beacon.c            |  136 +-
 drivers/net/wireless/ath/ath9k/btcoex.c            |  383 +-
 drivers/net/wireless/ath/ath9k/btcoex.h            |   64 +-
 drivers/net/wireless/ath/ath9k/calib.c             |  421 +-
 drivers/net/wireless/ath/ath9k/calib.h             |    2 +
 drivers/net/wireless/ath/ath9k/common.c            |  299 +
 drivers/net/wireless/ath/ath9k/common.h            |  127 +
 drivers/net/wireless/ath/ath9k/debug.c             |   72 +-
 drivers/net/wireless/ath/ath9k/debug.h             |   47 +-
 drivers/net/wireless/ath/ath9k/eeprom.c            |    8 +-
 drivers/net/wireless/ath/ath9k/eeprom.h            |    9 +-
 drivers/net/wireless/ath/ath9k/eeprom_4k.c         |   94 +-
 drivers/net/wireless/ath/ath9k/eeprom_9287.c       |   97 +-
 drivers/net/wireless/ath/ath9k/eeprom_def.c        |  183 +-
 drivers/net/wireless/ath/ath9k/hw.c                | 1344 +--
 drivers/net/wireless/ath/ath9k/hw.h                |   98 +-
 drivers/net/wireless/ath/ath9k/initvals.h          |  101 +-
 drivers/net/wireless/ath/ath9k/mac.c               |  200 +-
 drivers/net/wireless/ath/ath9k/mac.h               |   26 +-
 drivers/net/wireless/ath/ath9k/main.c              | 1413 ++-
 drivers/net/wireless/ath/ath9k/pci.c               |   47 +-
 drivers/net/wireless/ath/ath9k/phy.c               | 1034 ++-
 drivers/net/wireless/ath/ath9k/phy.h               |   42 +-
 drivers/net/wireless/ath/ath9k/rc.c                |  535 +-
 drivers/net/wireless/ath/ath9k/rc.h                |   25 +-
 drivers/net/wireless/ath/ath9k/recv.c              |  366 +-
 drivers/net/wireless/ath/ath9k/reg.h               |   27 +-
 drivers/net/wireless/ath/ath9k/virtual.c           |  110 +-
 drivers/net/wireless/ath/ath9k/xmit.c              |  354 +-
 drivers/net/wireless/ath/debug.c                   |   32 +
 drivers/net/wireless/ath/debug.h                   |   77 +
 drivers/net/wireless/ath/hw.c                      |  126 +
 drivers/net/wireless/ath/reg.h                     |   27 +
 drivers/net/wireless/ath/regd.c                    |    5 +-
 drivers/net/wireless/ath/regd.h                    |    8 +
 drivers/net/wireless/ath/regd_common.h             |   32 +-
 drivers/net/wireless/atmel.c                       |   16 +
 drivers/net/wireless/b43/Kconfig                   |    2 +-
 drivers/net/wireless/b43/b43.h                     |   18 +-
 drivers/net/wireless/b43/dma.c                     |  312 +-
 drivers/net/wireless/b43/dma.h                     |   13 +-
 drivers/net/wireless/b43/leds.c                    |    1 +
 drivers/net/wireless/b43/main.c                    |    6 +-
 drivers/net/wireless/b43/phy_lp.c                  |  777 +-
 drivers/net/wireless/b43/phy_lp.h                  |   11 +-
 drivers/net/wireless/b43/pio.c                     |   85 +-
 drivers/net/wireless/b43/rfkill.c                  |   10 +-
 drivers/net/wireless/b43/xmit.c                    |    8 +-
 drivers/net/wireless/b43/xmit.h                    |   19 +
 drivers/net/wireless/b43legacy/Kconfig             |    2 +-
 drivers/net/wireless/b43legacy/b43legacy.h         |    2 -
 drivers/net/wireless/b43legacy/dma.c               |   17 +-
 drivers/net/wireless/b43legacy/main.c              |    6 +-
 drivers/net/wireless/b43legacy/rfkill.c            |    7 +
 drivers/net/wireless/b43legacy/xmit.c              |    1 -
 drivers/net/wireless/hostap/Kconfig                |    3 +-
 drivers/net/wireless/ipw2x00/Kconfig               |   11 +-
 drivers/net/wireless/ipw2x00/ipw2100.c             |  147 +-
 drivers/net/wireless/ipw2x00/ipw2200.c             |  159 +-
 drivers/net/wireless/ipw2x00/libipw.h              |    8 +-
 drivers/net/wireless/ipw2x00/libipw_module.c       |   71 +-
 drivers/net/wireless/iwlwifi/Kconfig               |   30 +-
 drivers/net/wireless/iwlwifi/Makefile              |   12 +-
 drivers/net/wireless/iwlwifi/iwl-1000.c            |   51 +-
 drivers/net/wireless/iwlwifi/iwl-3945-hw.h         |   12 -
 drivers/net/wireless/iwlwifi/iwl-3945-led.c        |  371 +-
 drivers/net/wireless/iwlwifi/iwl-3945-led.h        |   22 +-
 drivers/net/wireless/iwlwifi/iwl-3945-rs.c         |  102 +-
 drivers/net/wireless/iwlwifi/iwl-3945.c            |  287 +-
 drivers/net/wireless/iwlwifi/iwl-3945.h            |   56 +-
 drivers/net/wireless/iwlwifi/iwl-4965-hw.h         |    3 -
 drivers/net/wireless/iwlwifi/iwl-4965.c            |  255 +-
 drivers/net/wireless/iwlwifi/iwl-5000.c            |  415 +-
 drivers/net/wireless/iwlwifi/iwl-6000.c            |  305 +-
 drivers/net/wireless/iwlwifi/iwl-agn-led.c         |   85 +
 drivers/net/wireless/iwlwifi/iwl-agn-led.h         |   32 +
 drivers/net/wireless/iwlwifi/iwl-agn-rs.c          |  584 +-
 drivers/net/wireless/iwlwifi/iwl-agn-rs.h          |  101 +
 drivers/net/wireless/iwlwifi/iwl-agn.c             |  776 +-
 drivers/net/wireless/iwlwifi/iwl-calib.c           |   78 +-
 drivers/net/wireless/iwlwifi/iwl-commands.h        |  297 +-
 drivers/net/wireless/iwlwifi/iwl-core.c            |  691 +-
 drivers/net/wireless/iwlwifi/iwl-core.h            |   86 +-
 drivers/net/wireless/iwlwifi/iwl-csr.h             |  189 +-
 drivers/net/wireless/iwlwifi/iwl-debug.h           |    5 +-
 drivers/net/wireless/iwlwifi/iwl-debugfs.c         |  860 +-
 drivers/net/wireless/iwlwifi/iwl-dev.h             |  150 +-
 drivers/net/wireless/iwlwifi/iwl-devtrace.c        |   14 +
 drivers/net/wireless/iwlwifi/iwl-devtrace.h        |  197 +
 drivers/net/wireless/iwlwifi/iwl-eeprom.c          |  133 +-
 drivers/net/wireless/iwlwifi/iwl-eeprom.h          |   26 +-
 drivers/net/wireless/iwlwifi/iwl-hcmd.c            |   29 +-
 drivers/net/wireless/iwlwifi/iwl-io.h              |   56 +-
 drivers/net/wireless/iwlwifi/iwl-led.c             |  324 +-
 drivers/net/wireless/iwlwifi/iwl-led.h             |   46 +-
 drivers/net/wireless/iwlwifi/iwl-power.c           |  232 +-
 drivers/net/wireless/iwlwifi/iwl-power.h           |    3 +
 drivers/net/wireless/iwlwifi/iwl-prph.h            |   19 +-
 drivers/net/wireless/iwlwifi/iwl-rx.c              |  218 +-
 drivers/net/wireless/iwlwifi/iwl-scan.c            |   40 +-
 drivers/net/wireless/iwlwifi/iwl-spectrum.c        |    2 +-
 drivers/net/wireless/iwlwifi/iwl-sta.c             |  160 +-
 drivers/net/wireless/iwlwifi/iwl-sta.h             |    4 +-
 drivers/net/wireless/iwlwifi/iwl-tx.c              |  155 +-
 drivers/net/wireless/iwlwifi/iwl3945-base.c        |  444 +-
 drivers/net/wireless/iwmc3200wifi/Kconfig          |    3 +-
 drivers/net/wireless/iwmc3200wifi/cfg80211.c       |   82 +-
 drivers/net/wireless/iwmc3200wifi/commands.c       |  108 +-
 drivers/net/wireless/iwmc3200wifi/commands.h       |   93 +-
 drivers/net/wireless/iwmc3200wifi/debugfs.c        |   23 +
 drivers/net/wireless/iwmc3200wifi/eeprom.c         |   50 +
 drivers/net/wireless/iwmc3200wifi/eeprom.h         |   29 +-
 drivers/net/wireless/iwmc3200wifi/fw.c             |    9 +
 drivers/net/wireless/iwmc3200wifi/iwm.h            |   17 +-
 drivers/net/wireless/iwmc3200wifi/lmac.h           |    8 +
 drivers/net/wireless/iwmc3200wifi/main.c           |   92 +-
 drivers/net/wireless/iwmc3200wifi/netdev.c         |    9 +
 drivers/net/wireless/iwmc3200wifi/rx.c             |  150 +-
 drivers/net/wireless/iwmc3200wifi/sdio.c           |   13 +-
 drivers/net/wireless/iwmc3200wifi/tx.c             |   66 +-
 drivers/net/wireless/iwmc3200wifi/umac.h           |   41 +-
 drivers/net/wireless/libertas/11d.c                |  696 --
 drivers/net/wireless/libertas/11d.h                |  105 -
 drivers/net/wireless/libertas/Kconfig              |   39 +
 drivers/net/wireless/libertas/Makefile             |   14 +-
 drivers/net/wireless/libertas/README               |   26 +-
 drivers/net/wireless/libertas/assoc.c              |  445 +-
 drivers/net/wireless/libertas/assoc.h              |  141 +-
 drivers/net/wireless/libertas/cfg.c                |  198 +
 drivers/net/wireless/libertas/cfg.h                |   16 +
 drivers/net/wireless/libertas/cmd.c                |  695 +-
 drivers/net/wireless/libertas/cmd.h                |  127 +-
 drivers/net/wireless/libertas/cmdresp.c            |  116 +-
 drivers/net/wireless/libertas/debugfs.c            |   27 +-
 drivers/net/wireless/libertas/decl.h               |   65 +-
 drivers/net/wireless/libertas/defs.h               |    3 +-
 drivers/net/wireless/libertas/dev.h                |  431 +-
 drivers/net/wireless/libertas/ethtool.c            |   84 +-
 drivers/net/wireless/libertas/host.h               |  959 ++-
 drivers/net/wireless/libertas/hostcmd.h            |  800 --
 drivers/net/wireless/libertas/if_cs.c              |    4 +
 drivers/net/wireless/libertas/if_sdio.c            |   62 +
 drivers/net/wireless/libertas/if_sdio.h            |    3 +-
 drivers/net/wireless/libertas/if_spi.c             |  143 +-
 drivers/net/wireless/libertas/if_usb.c             |    5 +
 drivers/net/wireless/libertas/main.c               |  720 +-
 drivers/net/wireless/libertas/mesh.c               | 1141 ++
 drivers/net/wireless/libertas/mesh.h               |   78 +
 drivers/net/wireless/libertas/persistcfg.c         |  453 -
 drivers/net/wireless/libertas/rx.c                 |   13 +-
 drivers/net/wireless/libertas/scan.c               |  250 +-
 drivers/net/wireless/libertas/scan.h               |   30 +
 drivers/net/wireless/libertas/tx.c                 |    9 +-
 drivers/net/wireless/libertas/types.h              |    4 +-
 drivers/net/wireless/libertas/wext.c               |  196 +-
 drivers/net/wireless/libertas/wext.h               |    9 +-
 drivers/net/wireless/libertas_tf/if_usb.c          |    2 +
 drivers/net/wireless/mac80211_hwsim.c              |   85 +-
 drivers/net/wireless/mwl8k.c                       | 1265 ++-
 drivers/net/wireless/orinoco/Kconfig               |    6 +-
 drivers/net/wireless/orinoco/fw.c                  |    6 +
 drivers/net/wireless/orinoco/hw.c                  |   33 +-
 drivers/net/wireless/orinoco/hw.h                  |    3 +-
 drivers/net/wireless/orinoco/main.c                |   34 +-
 drivers/net/wireless/orinoco/orinoco.h             |    1 -
 drivers/net/wireless/p54/Kconfig                   |    2 +-
 drivers/net/wireless/p54/eeprom.c                  |   31 +-
 drivers/net/wireless/p54/main.c                    |    2 +-
 drivers/net/wireless/p54/p54pci.c                  |    2 +-
 drivers/net/wireless/prism54/islpci_dev.c          |    3 +
 drivers/net/wireless/prism54/islpci_hotplug.c      |    2 +-
 drivers/net/wireless/ray_cs.c                      |   36 +-
 drivers/net/wireless/rndis_wlan.c                  |   13 +-
 drivers/net/wireless/rt2x00/Kconfig                |   46 +-
 drivers/net/wireless/rt2x00/Makefile               |    3 +
 drivers/net/wireless/rt2x00/rt2400pci.c            |   31 +-
 drivers/net/wireless/rt2x00/rt2400pci.h            |    2 +-
 drivers/net/wireless/rt2x00/rt2500pci.c            |   32 +-
 drivers/net/wireless/rt2x00/rt2500pci.h            |    2 +-
 drivers/net/wireless/rt2x00/rt2500usb.c            |  166 +-
 drivers/net/wireless/rt2x00/rt2500usb.h            |    2 +-
 drivers/net/wireless/rt2x00/rt2800.h               | 1852 +++
 drivers/net/wireless/rt2x00/rt2800lib.c            | 2284 ++++
 drivers/net/wireless/rt2x00/rt2800lib.h            |  151 +
 drivers/net/wireless/rt2x00/rt2800pci.c            | 1322 ++
 drivers/net/wireless/rt2x00/rt2800pci.h            |  159 +
 drivers/net/wireless/rt2x00/rt2800usb.c            | 2286 +----
 drivers/net/wireless/rt2x00/rt2800usb.h            | 1864 +---
 drivers/net/wireless/rt2x00/rt2x00.h               |   73 +-
 drivers/net/wireless/rt2x00/rt2x00config.c         |    2 +-
 drivers/net/wireless/rt2x00/rt2x00crypto.c         |    2 +-
 drivers/net/wireless/rt2x00/rt2x00debug.c          |    2 +-
 drivers/net/wireless/rt2x00/rt2x00debug.h          |    2 +-
 drivers/net/wireless/rt2x00/rt2x00dev.c            |   19 +-
 drivers/net/wireless/rt2x00/rt2x00dump.h           |    2 +-
 drivers/net/wireless/rt2x00/rt2x00firmware.c       |    3 +-
 drivers/net/wireless/rt2x00/rt2x00ht.c             |    2 +-
 drivers/net/wireless/rt2x00/rt2x00leds.c           |    2 +-
 drivers/net/wireless/rt2x00/rt2x00leds.h           |    6 +-
 drivers/net/wireless/rt2x00/rt2x00lib.h            |   20 +-
 drivers/net/wireless/rt2x00/rt2x00link.c           |   90 +-
 drivers/net/wireless/rt2x00/rt2x00mac.c            |   10 +-
 drivers/net/wireless/rt2x00/rt2x00pci.c            |    4 +-
 drivers/net/wireless/rt2x00/rt2x00pci.h            |   26 +-
 drivers/net/wireless/rt2x00/rt2x00queue.c          |   15 +-
 drivers/net/wireless/rt2x00/rt2x00queue.h          |    7 +-
 drivers/net/wireless/rt2x00/rt2x00reg.h            |    2 +-
 drivers/net/wireless/rt2x00/rt2x00soc.c            |  165 +
 drivers/net/wireless/rt2x00/rt2x00soc.h            |   52 +
 drivers/net/wireless/rt2x00/rt2x00usb.c            |    6 +-
 drivers/net/wireless/rt2x00/rt2x00usb.h            |   21 +-
 drivers/net/wireless/rt2x00/rt61pci.c              |   65 +-
 drivers/net/wireless/rt2x00/rt61pci.h              |    2 +-
 drivers/net/wireless/rt2x00/rt73usb.c              |   29 +-
 drivers/net/wireless/rt2x00/rt73usb.h              |    2 +-
 drivers/net/wireless/rtl818x/rtl8180_dev.c         |    2 +-
 drivers/net/wireless/rtl818x/rtl8187.h             |    1 -
 drivers/net/wireless/rtl818x/rtl8187_dev.c         |   13 +-
 drivers/net/wireless/wl12xx/Kconfig                |    3 +-
 drivers/net/wireless/wl12xx/wl1251.h               |    5 +
 drivers/net/wireless/wl12xx/wl1251_acx.c           |   68 +-
 drivers/net/wireless/wl12xx/wl1251_acx.h           |   36 +-
 drivers/net/wireless/wl12xx/wl1251_boot.c          |   55 +-
 drivers/net/wireless/wl12xx/wl1251_event.c         |   15 +
 drivers/net/wireless/wl12xx/wl1251_init.c          |    8 +-
 drivers/net/wireless/wl12xx/wl1251_main.c          |  171 +-
 drivers/net/wireless/wl12xx/wl1251_netlink.h       |   30 -
 drivers/net/wireless/wl12xx/wl1251_ps.c            |   44 +-
 drivers/net/wireless/wl12xx/wl1251_ps.h            |    1 +
 drivers/net/wireless/wl12xx/wl1251_reg.h           |    6 +
 drivers/net/wireless/wl12xx/wl1251_rx.c            |    6 +-
 drivers/net/wireless/wl12xx/wl1251_spi.c           |    4 +-
 drivers/net/wireless/wl12xx/wl1271.h               |   95 +-
 drivers/net/wireless/wl12xx/wl1271_acx.c           |  369 +-
 drivers/net/wireless/wl12xx/wl1271_acx.h           |  586 +-
 drivers/net/wireless/wl12xx/wl1271_boot.c          |  218 +-
 drivers/net/wireless/wl12xx/wl1271_boot.h          |   22 +-
 drivers/net/wireless/wl12xx/wl1271_cmd.c           |  503 +-
 drivers/net/wireless/wl12xx/wl1271_cmd.h           |  190 +-
 drivers/net/wireless/wl12xx/wl1271_conf.h          |  919 ++
 drivers/net/wireless/wl12xx/wl1271_event.c         |  121 +-
 drivers/net/wireless/wl12xx/wl1271_event.h         |   37 +-
 drivers/net/wireless/wl12xx/wl1271_init.c          |  141 +-
 drivers/net/wireless/wl12xx/wl1271_init.h          |   83 -
 drivers/net/wireless/wl12xx/wl1271_main.c          |  979 ++-
 drivers/net/wireless/wl12xx/wl1271_ps.c            |   68 +-
 drivers/net/wireless/wl12xx/wl1271_ps.h            |    2 +-
 drivers/net/wireless/wl12xx/wl1271_reg.h           |   47 +-
 drivers/net/wireless/wl12xx/wl1271_rx.c            |   88 +-
 drivers/net/wireless/wl12xx/wl1271_rx.h            |    4 +-
 drivers/net/wireless/wl12xx/wl1271_spi.c           |  311 +-
 drivers/net/wireless/wl12xx/wl1271_spi.h           |   65 +-
 drivers/net/wireless/wl12xx/wl1271_tx.c            |   76 +-
 drivers/net/wireless/wl12xx/wl1271_tx.h            |   18 +-
 drivers/net/wireless/wl12xx/wl12xx_80211.h         |    4 +-
 drivers/net/wireless/wl3501_cs.c                   |    2 +-
 drivers/net/wireless/zd1201.c                      |    3 +
 drivers/net/wireless/zd1211rw/Kconfig              |    2 +-
 drivers/net/wireless/zd1211rw/zd_chip.c            |    4 +-
 drivers/net/wireless/zd1211rw/zd_chip.h            |   18 +-
 drivers/net/wireless/zd1211rw/zd_mac.c             |  202 +-
 drivers/net/wireless/zd1211rw/zd_mac.h             |   25 +-
 drivers/net/wireless/zd1211rw/zd_usb.c             |   11 +-
 drivers/net/xilinx_emaclite.c                      |    2 +-
 drivers/net/xtsonic.c                              |    2 +-
 drivers/net/yellowfin.c                            |   10 +-
 drivers/net/znet.c                                 |    9 +-
 drivers/parisc/led.c                               |    7 +-
 drivers/s390/net/Makefile                          |    6 +-
 drivers/s390/net/claw.c                            |   82 +-
 drivers/s390/net/claw.h                            |   12 +
 drivers/s390/net/ctcm_fsms.c                       |    1 -
 drivers/s390/net/ctcm_fsms.h                       |    1 -
 drivers/s390/net/ctcm_main.c                       |  168 +-
 drivers/s390/net/ctcm_main.h                       |   20 +-
 drivers/s390/net/ctcm_mpc.c                        |    1 -
 drivers/s390/net/ctcm_sysfs.c                      |   11 +-
 drivers/s390/net/cu3088.c                          |  148 -
 drivers/s390/net/cu3088.h                          |   41 -
 drivers/s390/net/fsm.c                             |    1 +
 drivers/s390/net/fsm.h                             |    2 +
 drivers/s390/net/lcs.c                             |  115 +-
 drivers/s390/net/lcs.h                             |   18 +
 drivers/s390/net/netiucv.c                         |    4 +-
 drivers/s390/net/qeth_core.h                       |    8 +-
 drivers/s390/net/qeth_core_main.c                  |  225 +-
 drivers/s390/net/qeth_core_mpc.h                   |   45 +-
 drivers/s390/net/qeth_core_sys.c                   |   83 +-
 drivers/s390/net/qeth_l2_main.c                    |   33 +-
 drivers/s390/net/qeth_l3.h                         |    2 +
 drivers/s390/net/qeth_l3_main.c                    |  144 +-
 drivers/s390/net/qeth_l3_sys.c                     |   67 +-
 drivers/ssb/driver_pcicore.c                       |    4 +-
 drivers/ssb/main.c                                 |  126 +-
 drivers/ssb/scan.c                                 |    2 +-
 drivers/ssb/sprom.c                                |   30 +-
 drivers/ssb/ssb_private.h                          |   12 +-
 drivers/staging/Kconfig                            |    8 +
 drivers/staging/Makefile                           |    5 +
 drivers/staging/arlan/Kconfig                      |   15 +
 drivers/staging/arlan/Makefile                     |    3 +
 drivers/staging/arlan/TODO                         |    7 +
 .../{net/wireless => staging/arlan}/arlan-main.c   |    0
 .../{net/wireless => staging/arlan}/arlan-proc.c   |    0
 drivers/{net/wireless => staging/arlan}/arlan.h    |    0
 drivers/staging/netwave/Kconfig                    |   11 +
 drivers/staging/netwave/Makefile                   |    1 +
 drivers/staging/netwave/TODO                       |    7 +
 .../{net/wireless => staging/netwave}/netwave_cs.c |    0
 drivers/staging/rtl8187se/Kconfig                  |    3 +-
 drivers/staging/rtl8192e/Kconfig                   |    3 +-
 drivers/staging/strip/Kconfig                      |   22 +
 drivers/staging/strip/Makefile                     |    1 +
 drivers/staging/strip/TODO                         |    7 +
 drivers/{net/wireless => staging/strip}/strip.c    |   17 +
 drivers/staging/vt6655/Kconfig                     |    4 +-
 drivers/staging/vt6656/Kconfig                     |    4 +-
 drivers/staging/wavelan/Kconfig                    |   38 +
 drivers/staging/wavelan/Makefile                   |    2 +
 drivers/staging/wavelan/TODO                       |    7 +
 drivers/{net/wireless => staging/wavelan}/i82586.h |    0
 .../{net/wireless => staging/wavelan}/wavelan.c    |    0
 .../{net/wireless => staging/wavelan}/wavelan.h    |    0
 .../{net/wireless => staging/wavelan}/wavelan.p.h  |    0
 .../{net/wireless => staging/wavelan}/wavelan_cs.c |    0
 .../{net/wireless => staging/wavelan}/wavelan_cs.h |    0
 .../wireless => staging/wavelan}/wavelan_cs.p.h    |    2 +-
 firmware/Makefile                                  |    2 +-
 firmware/WHENCE                                    |    4 +-
 firmware/bnx2x-e1-5.0.21.0.fw.ihex                 |10184 ----------------
 firmware/bnx2x-e1-5.2.7.0.fw.ihex                  |10178 ++++++++++++++++
 firmware/bnx2x-e1h-5.0.21.0.fw.ihex                |12855 --------------------
 firmware/bnx2x-e1h-5.2.7.0.fw.ihex                 |12847 +++++++++++++++++++
 fs/compat_ioctl.c                                  |  745 --
 fs/ocfs2/cluster/netdebug.c                        |    8 +-
 include/asm-generic/socket.h                       |    1 +
 include/linux/brcmphy.h                            |   19 +-
 include/linux/can/core.h                           |    2 -
 include/linux/can/dev.h                            |   20 +-
 include/linux/can/platform/mcp251x.h               |   36 +
 include/linux/can/platform/ti_hecc.h               |   40 +
 include/linux/compat.h                             |   44 +
 include/linux/cryptohash.h                         |    1 +
 include/linux/dn.h                                 |    9 +-
 include/linux/errqueue.h                           |    6 +-
 include/linux/ethtool.h                            |   43 +-
 include/linux/fib_rules.h                          |   17 +-
 include/linux/filter.h                             |   10 +-
 include/linux/gen_stats.h                          |   15 +-
 {drivers/net/wireless => include/linux}/i82593.h   |    0
 include/linux/ieee80211.h                          |   45 +-
 include/linux/if.h                                 |   16 +-
 include/linux/if_addr.h                            |    9 +-
 include/linux/if_addrlabel.h                       |    6 +-
 include/linux/if_arcnet.h                          |   18 +-
 include/linux/if_arp.h                             |    3 +-
 include/linux/if_bonding.h                         |    3 +-
 include/linux/if_bridge.h                          |    9 +-
 include/linux/if_ec.h                              |   12 +-
 include/linux/if_ether.h                           |    4 -
 include/linux/if_fddi.h                            |   22 +-
 include/linux/if_hippi.h                           |   15 +-
 include/linux/if_link.h                            |   42 +-
 include/linux/if_packet.h                          |   27 +-
 include/linux/if_plip.h                            |    3 +-
 include/linux/if_pppol2tp.h                        |    3 +-
 include/linux/if_tunnel.h                          |   18 +-
 include/linux/if_vlan.h                            |   41 +-
 include/linux/igmp.h                               |   15 +-
 include/linux/in.h                                 |   18 +-
 include/linux/in6.h                                |    9 +-
 include/linux/inetdevice.h                         |   10 +-
 include/linux/ip_vs.h                              |    3 +-
 include/linux/ipv6.h                               |    4 +-
 include/linux/mmc/sdio_ids.h                       |    1 +
 include/linux/mroute.h                             |   31 +-
 include/linux/mroute6.h                            |   15 +-
 include/linux/neighbour.h                          |   18 +-
 include/linux/net.h                                |   90 +-
 include/linux/netdevice.h                          |  156 +-
 include/linux/netfilter.h                          |    6 +-
 include/linux/netfilter/nf_conntrack_common.h      |    6 +-
 include/linux/netfilter/nf_conntrack_ftp.h         |    3 +-
 include/linux/netfilter/nf_conntrack_sctp.h        |    3 +-
 include/linux/netfilter/nf_conntrack_tcp.h         |    6 +-
 include/linux/netfilter/nfnetlink.h                |    6 +-
 include/linux/netfilter/nfnetlink_compat.h         |    3 +-
 include/linux/netfilter/x_tables.h                 |   45 +-
 include/linux/netfilter/xt_connbytes.h             |    3 +-
 include/linux/netfilter/xt_esp.h                   |    3 +-
 include/linux/netfilter/xt_multiport.h             |    9 +-
 include/linux/netfilter/xt_policy.h                |   18 +-
 include/linux/netfilter/xt_state.h                 |    3 +-
 include/linux/netfilter/xt_string.h                |    3 +-
 include/linux/netfilter/xt_tcpudp.h                |    6 +-
 include/linux/netfilter_arp/arp_tables.h           |   21 +-
 include/linux/netfilter_bridge/ebt_802_3.h         |    3 +-
 include/linux/netfilter_bridge/ebt_among.h         |    9 +-
 include/linux/netfilter_bridge/ebt_arpreply.h      |    3 +-
 include/linux/netfilter_bridge/ebt_ip.h            |    3 +-
 include/linux/netfilter_bridge/ebt_ip6.h           |    3 +-
 include/linux/netfilter_bridge/ebt_limit.h         |    3 +-
 include/linux/netfilter_bridge/ebt_log.h           |    3 +-
 include/linux/netfilter_bridge/ebt_mark_m.h        |    3 +-
 include/linux/netfilter_bridge/ebt_mark_t.h        |    3 +-
 include/linux/netfilter_bridge/ebt_nat.h           |    3 +-
 include/linux/netfilter_bridge/ebt_pkttype.h       |    3 +-
 include/linux/netfilter_bridge/ebt_redirect.h      |    3 +-
 include/linux/netfilter_bridge/ebt_stp.h           |    6 +-
 include/linux/netfilter_bridge/ebtables.h          |   39 +-
 include/linux/netfilter_ipv4/ip_tables.h           |   27 +-
 include/linux/netfilter_ipv4/ipt_SAME.h            |    3 +-
 include/linux/netfilter_ipv4/ipt_ah.h              |    3 +-
 include/linux/netfilter_ipv6/ip6_tables.h          |   27 +-
 include/linux/netfilter_ipv6/ip6t_ah.h             |    3 +-
 include/linux/netfilter_ipv6/ip6t_frag.h           |    3 +-
 include/linux/netfilter_ipv6/ip6t_ipv6header.h     |    3 +-
 include/linux/netfilter_ipv6/ip6t_mh.h             |    3 +-
 include/linux/netfilter_ipv6/ip6t_opts.h           |    3 +-
 include/linux/netfilter_ipv6/ip6t_rt.h             |    3 +-
 include/linux/netlink.h                            |   24 +-
 include/linux/nl80211.h                            |   62 +-
 include/linux/nl802154.h                           |    6 +
 include/linux/notifier.h                           |    2 +
 include/linux/pkt_cls.h                            |   84 +-
 include/linux/pkt_sched.h                          |  111 +-
 include/linux/rculist.h                            |   14 +
 include/linux/rds.h                                |    8 +
 include/linux/rfkill.h                             |    3 +
 include/linux/route.h                              |    3 +-
 include/linux/rtnetlink.h                          |   63 +-
 include/linux/sctp.h                               |    1 +
 include/linux/skbuff.h                             |   31 +-
 include/linux/smsc911x.h                           |    1 +
 include/linux/socket.h                             |   13 +
 include/linux/spi/wl12xx.h                         |    1 +
 include/linux/ssb/ssb.h                            |   20 +-
 include/linux/syscalls.h                           |    4 +
 include/linux/sysctl.h                             |    1 +
 include/linux/tc_act/tc_defact.h                   |    6 +-
 include/linux/tc_act/tc_gact.h                     |    9 +-
 include/linux/tc_act/tc_ipt.h                      |    3 +-
 include/linux/tc_act/tc_mirred.h                   |    6 +-
 include/linux/tc_act/tc_nat.h                      |    6 +-
 include/linux/tc_act/tc_pedit.h                    |    9 +-
 include/linux/tc_act/tc_skbedit.h                  |    2 +
 include/linux/tc_ematch/tc_em_cmp.h                |    6 +-
 include/linux/tc_ematch/tc_em_meta.h               |   15 +-
 include/linux/tc_ematch/tc_em_nbyte.h              |    3 +-
 include/linux/tc_ematch/tc_em_text.h               |    3 +-
 include/linux/tcp.h                                |   72 +-
 include/linux/udp.h                                |   15 +-
 include/linux/usb/usbnet.h                         |    8 +
 include/linux/wimax/debug.h                        |   72 +
 include/linux/wimax/i2400m.h                       |   13 +-
 include/linux/x25.h                                |    1 +
 include/linux/xfrm.h                               |   35 +-
 include/net/ah.h                                   |   33 +-
 include/net/bluetooth/bluetooth.h                  |    2 +-
 include/net/bluetooth/hci_core.h                   |   39 +-
 include/net/bluetooth/l2cap.h                      |    2 +-
 include/net/cfg80211.h                             |  198 +-
 include/net/compat.h                               |   14 +-
 include/net/dn_dev.h                               |   12 +-
 include/net/dn_fib.h                               |    3 +-
 include/net/dn_nsp.h                               |   24 +-
 include/net/dst.h                                  |   23 +-
 include/net/fib_rules.h                            |   21 +-
 include/net/gen_stats.h                            |    4 +-
 include/net/genetlink.h                            |   12 +-
 include/net/ieee80211_radiotap.h                   |    2 +-
 include/net/ieee802154_netdev.h                    |   16 +-
 include/net/if_inet6.h                             |   24 +-
 include/net/inet6_hashtables.h                     |    4 +-
 include/net/inet_hashtables.h                      |   20 +-
 include/net/inet_sock.h                            |   36 +-
 include/net/inet_timewait_sock.h                   |   10 +-
 include/net/inetpeer.h                             |   19 +-
 include/net/ip.h                                   |   27 +-
 include/net/ip6_fib.h                              |   15 +-
 include/net/ip6_route.h                            |    3 +-
 include/net/ip_fib.h                               |   25 +-
 include/net/ip_vs.h                                |    6 +-
 include/net/ipip.h                                 |   25 +-
 include/net/ipv6.h                                 |   12 +-
 include/net/iw_handler.h                           |   26 +-
 include/net/mac80211.h                             |  203 +-
 include/net/neighbour.h                            |   18 +-
 include/net/net_namespace.h                        |   16 +-
 include/net/netfilter/nf_conntrack_ecache.h        |    3 +-
 include/net/netfilter/nf_conntrack_expect.h        |    6 +-
 include/net/netfilter/nf_conntrack_extend.h        |    6 +-
 include/net/netfilter/nf_conntrack_helper.h        |    3 +-
 include/net/netfilter/nf_conntrack_l3proto.h       |    3 +-
 include/net/netfilter/nf_conntrack_l4proto.h       |    3 +-
 include/net/netfilter/nf_conntrack_tuple.h         |   12 +-
 include/net/netfilter/nf_nat.h                     |   15 +-
 include/net/netfilter/nf_nat_protocol.h            |    3 +-
 include/net/netns/generic.h                        |    8 +-
 include/net/netns/xfrm.h                           |    1 +
 include/net/phonet/phonet.h                        |    2 +
 include/net/phonet/pn_dev.h                        |    8 +-
 include/net/pkt_cls.h                              |   28 +-
 include/net/pkt_sched.h                            |    3 +-
 include/net/protocol.h                             |    7 +-
 include/net/red.h                                  |    6 +-
 include/net/request_sock.h                         |    8 +-
 include/net/route.h                                |   13 +-
 include/net/rtnetlink.h                            |   11 +-
 include/net/sch_generic.h                          |   30 +-
 include/net/scm.h                                  |    9 +-
 include/net/sctp/constants.h                       |    4 +
 include/net/sctp/sctp.h                            |    3 +-
 include/net/sctp/sm.h                              |    3 +-
 include/net/sctp/structs.h                         |   16 +-
 include/net/sctp/user.h                            |  132 +-
 include/net/sock.h                                 |   46 +-
 include/net/tc_act/tc_skbedit.h                    |    2 +
 include/net/tcp.h                                  |  111 +-
 include/net/udp.h                                  |   42 +-
 include/net/wext.h                                 |   49 +-
 include/net/wimax.h                                |    6 +
 include/net/wpan-phy.h                             |   22 +-
 include/net/x25.h                                  |    6 +
 include/net/xfrm.h                                 |   47 +-
 kernel/sys_ni.c                                    |    2 +
 kernel/sysctl_check.c                              |    1 +
 kernel/time/clocksource.c                          |    6 +-
 kernel/time/timecompare.c                          |    6 +-
 net/8021q/vlan.c                                   |   90 +-
 net/8021q/vlan.h                                   |   21 +-
 net/8021q/vlan_core.c                              |   37 +-
 net/8021q/vlan_dev.c                               |   72 +-
 net/8021q/vlan_netlink.c                           |    7 +-
 net/8021q/vlanproc.c                               |   13 +-
 net/9p/trans_fd.c                                  |    4 +-
 net/appletalk/ddp.c                                |  134 +-
 net/atm/common.c                                   |    2 +-
 net/atm/ioctl.c                                    |  177 +-
 net/atm/pvc.c                                      |    5 +-
 net/atm/svc.c                                      |   11 +-
 net/ax25/af_ax25.c                                 |   14 +-
 net/bluetooth/af_bluetooth.c                       |   11 +-
 net/bluetooth/bnep/core.c                          |    5 +-
 net/bluetooth/bnep/sock.c                          |    5 +-
 net/bluetooth/cmtp/sock.c                          |    5 +-
 net/bluetooth/hci_core.c                           |   39 +-
 net/bluetooth/hci_event.c                          |    6 +-
 net/bluetooth/hci_sock.c                           |   16 +-
 net/bluetooth/hidp/core.c                          |    9 +
 net/bluetooth/hidp/sock.c                          |    5 +-
 net/bluetooth/l2cap.c                              |  137 +-
 net/bluetooth/rfcomm/core.c                        |    6 +
 net/bluetooth/rfcomm/sock.c                        |    7 +-
 net/bluetooth/sco.c                                |    5 +-
 net/bridge/br_device.c                             |    1 +
 net/bridge/br_fdb.c                                |    4 +-
 net/bridge/br_if.c                                 |   23 +-
 net/bridge/br_ioctl.c                              |    4 +-
 net/bridge/br_sysfs_br.c                           |    6 +-
 net/bridge/netfilter/ebt_stp.c                     |    4 +-
 net/can/af_can.c                                   |   20 +-
 net/can/bcm.c                                      |    9 +-
 net/can/raw.c                                      |    5 +-
 net/compat.c                                       |   40 +-
 net/core/Makefile                                  |    1 -
 net/core/datagram.c                                |    1 +
 net/core/dev.c                                     |  654 +-
 net/core/drop_monitor.c                            |    2 +-
 net/core/ethtool.c                                 |   81 +-
 net/core/fib_rules.c                               |  107 +-
 net/core/filter.c                                  |    6 +
 net/core/gen_stats.c                               |    8 +-
 net/core/link_watch.c                              |   94 +-
 net/core/neighbour.c                               |    2 +-
 net/core/net-sysfs.c                               |   59 +-
 net/core/net_namespace.c                           |  272 +-
 net/core/pktgen.c                                  |   30 +-
 net/core/rtnetlink.c                               |  179 +-
 net/core/skb_dma_map.c                             |   65 -
 net/core/skbuff.c                                  |    5 +-
 net/core/sock.c                                    |   58 +-
 net/core/sysctl_net_core.c                         |    2 +-
 net/dcb/dcbnl.c                                    |    6 +-
 net/dccp/ccids/ccid2.c                             |  327 +-
 net/dccp/ccids/ccid2.h                             |   46 +-
 net/dccp/ccids/ccid3.c                             |  400 +-
 net/dccp/ccids/ccid3.h                             |  120 +-
 net/dccp/ipv4.c                                    |   46 +-
 net/dccp/ipv6.c                                    |   37 +-
 net/dccp/minisocks.c                               |    2 +-
 net/dccp/output.c                                  |    4 +-
 net/dccp/probe.c                                   |   31 +-
 net/dccp/proto.c                                   |   17 +-
 net/dccp/timer.c                                   |    4 +-
 net/decnet/af_decnet.c                             |   15 +-
 net/decnet/dn_dev.c                                |   53 +-
 net/decnet/dn_fib.c                                |   10 +-
 net/decnet/dn_route.c                              |   10 +-
 net/decnet/dn_rules.c                              |   22 +-
 net/decnet/dn_table.c                              |    7 +-
 net/econet/af_econet.c                             |   15 +-
 net/ethernet/eth.c                                 |    7 -
 net/ieee802154/Makefile                            |    4 +-
 net/ieee802154/af_ieee802154.c                     |    6 +-
 net/ieee802154/dgram.c                             |    3 +-
 net/ieee802154/ieee802154.h                        |   53 +
 net/ieee802154/netlink.c                           |  613 +-
 net/ieee802154/nl-mac.c                            |  617 +
 net/ieee802154/nl-phy.c                            |  344 +
 net/ieee802154/nl_policy.c                         |    2 +
 net/ieee802154/raw.c                               |    3 +-
 net/ieee802154/wpan-class.c                        |   75 +-
 net/ipv4/af_inet.c                                 |   74 +-
 net/ipv4/ah4.c                                     |  297 +-
 net/ipv4/cipso_ipv4.c                              |    2 +-
 net/ipv4/datagram.c                                |   18 +-
 net/ipv4/devinet.c                                 |  158 +-
 net/ipv4/esp4.c                                    |    2 +-
 net/ipv4/fib_frontend.c                            |   50 +-
 net/ipv4/fib_hash.c                                |   25 +-
 net/ipv4/fib_rules.c                               |   16 +-
 net/ipv4/fib_semantics.c                           |    4 +-
 net/ipv4/fib_trie.c                                |   26 +-
 net/ipv4/icmp.c                                    |   13 +-
 net/ipv4/igmp.c                                    |   50 +-
 net/ipv4/inet_connection_sock.c                    |   27 +-
 net/ipv4/inet_diag.c                               |   28 +-
 net/ipv4/inet_hashtables.c                         |   49 +-
 net/ipv4/inet_lro.c                                |   36 +-
 net/ipv4/inet_timewait_sock.c                      |  112 +-
 net/ipv4/inetpeer.c                                |    5 +-
 net/ipv4/ip_fragment.c                             |   11 +-
 net/ipv4/ip_gre.c                                  |   88 +-
 net/ipv4/ip_input.c                                |    4 +-
 net/ipv4/ip_output.c                               |   23 +-
 net/ipv4/ip_sockglue.c                             |   12 +-
 net/ipv4/ipconfig.c                                |   13 +-
 net/ipv4/ipip.c                                    |   97 +-
 net/ipv4/ipmr.c                                    |   29 +-
 net/ipv4/netfilter.c                               |    8 +-
 net/ipv4/netfilter/arp_tables.c                    |   22 +-
 net/ipv4/netfilter/ip_queue.c                      |    7 +-
 net/ipv4/netfilter/ip_tables.c                     |   46 +-
 net/ipv4/netfilter/ipt_CLUSTERIP.c                 |   20 +-
 net/ipv4/netfilter/ipt_ECN.c                       |    8 +-
 net/ipv4/netfilter/ipt_LOG.c                       |   22 +-
 net/ipv4/netfilter/ipt_MASQUERADE.c                |    4 +-
 net/ipv4/netfilter/ipt_REJECT.c                    |    4 +-
 net/ipv4/netfilter/ipt_ULOG.c                      |    6 +-
 net/ipv4/netfilter/ipt_ecn.c                       |    4 +-
 net/ipv4/netfilter/iptable_mangle.c                |    4 +-
 net/ipv4/netfilter/iptable_security.c              |    4 +-
 net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c     |    8 +-
 net/ipv4/netfilter/nf_conntrack_proto_icmp.c       |   28 +-
 net/ipv4/netfilter/nf_nat_helper.c                 |   22 +-
 net/ipv4/netfilter/nf_nat_standalone.c             |   10 +-
 net/ipv4/raw.c                                     |   33 +-
 net/ipv4/route.c                                   |  102 +-
 net/ipv4/syncookies.c                              |   33 +-
 net/ipv4/sysctl_net_ipv4.c                         |   12 +-
 net/ipv4/tcp.c                                     |  289 +-
 net/ipv4/tcp_diag.c                                |    2 +-
 net/ipv4/tcp_htcp.c                                |   10 +-
 net/ipv4/tcp_input.c                               |  103 +-
 net/ipv4/tcp_ipv4.c                                |  223 +-
 net/ipv4/tcp_lp.c                                  |    4 +-
 net/ipv4/tcp_minisocks.c                           |   76 +-
 net/ipv4/tcp_output.c                              |  329 +-
 net/ipv4/tcp_probe.c                               |   13 +-
 net/ipv4/tcp_timer.c                               |   12 +-
 net/ipv4/tcp_veno.c                                |    5 +-
 net/ipv4/tcp_yeah.c                                |    4 +-
 net/ipv4/udp.c                                     |  484 +-
 net/ipv4/udplite.c                                 |    5 +-
 net/ipv6/Kconfig                                   |   19 +
 net/ipv6/addrconf.c                                |  245 +-
 net/ipv6/af_inet6.c                                |   53 +-
 net/ipv6/ah6.c                                     |  354 +-
 net/ipv6/anycast.c                                 |   35 +-
 net/ipv6/datagram.c                                |   48 +-
 net/ipv6/esp6.c                                    |    2 +-
 net/ipv6/fib6_rules.c                              |   24 +-
 net/ipv6/inet6_connection_sock.c                   |   10 +-
 net/ipv6/inet6_hashtables.c                        |   29 +-
 net/ipv6/ip6_flowlabel.c                           |   17 +-
 net/ipv6/ip6_tunnel.c                              |   93 +-
 net/ipv6/ip6mr.c                                   |   17 +-
 net/ipv6/ipv6_sockglue.c                           |    9 +-
 net/ipv6/mcast.c                                   |   51 +-
 net/ipv6/ndisc.c                                   |    1 +
 net/ipv6/netfilter/ip6_queue.c                     |    7 +-
 net/ipv6/netfilter/ip6_tables.c                    |   42 +-
 net/ipv6/netfilter/ip6t_LOG.c                      |    4 +-
 net/ipv6/netfilter/ip6t_REJECT.c                   |    4 +-
 net/ipv6/netfilter/ip6t_ah.c                       |   19 +-
 net/ipv6/netfilter/ip6t_frag.c                     |   47 +-
 net/ipv6/netfilter/ip6t_rt.c                       |    9 +-
 net/ipv6/netfilter/ip6table_filter.c               |    4 +-
 net/ipv6/netfilter/ip6table_mangle.c               |   14 +-
 net/ipv6/netfilter/nf_conntrack_proto_icmpv6.c     |   12 +-
 net/ipv6/raw.c                                     |   60 +-
 net/ipv6/reassembly.c                              |   17 +-
 net/ipv6/route.c                                   |    3 +-
 net/ipv6/sit.c                                     |  338 +-
 net/ipv6/syncookies.c                              |   34 +-
 net/ipv6/tcp_ipv6.c                                |  143 +-
 net/ipv6/udp.c                                     |  265 +-
 net/ipv6/udplite.c                                 |    1 -
 net/ipv6/xfrm6_tunnel.c                            |   47 +-
 net/ipx/af_ipx.c                                   |   61 +-
 net/irda/af_irda.c                                 |  340 +-
 net/irda/irnet/irnet_irda.c                        |    4 +-
 net/iucv/af_iucv.c                                 |   10 +-
 net/iucv/iucv.c                                    |   16 +-
 net/key/af_key.c                                   |   34 +-
 net/llc/af_llc.c                                   |    9 +-
 net/mac80211/Kconfig                               |   13 +
 net/mac80211/Makefile                              |    2 +-
 net/mac80211/agg-rx.c                              |   14 +-
 net/mac80211/agg-tx.c                              |  103 +-
 net/mac80211/cfg.c                                 |   55 +-
 net/mac80211/debugfs.c                             |   75 +-
 net/mac80211/debugfs.h                             |    2 -
 net/mac80211/debugfs_key.c                         |   44 +-
 net/mac80211/debugfs_netdev.c                      |  176 +-
 net/mac80211/debugfs_sta.c                         |   67 +-
 net/mac80211/driver-ops.h                          |    5 +-
 net/mac80211/driver-trace.h                        |   35 +-
 net/mac80211/ht.c                                  |    2 +-
 net/mac80211/ibss.c                                |    7 +-
 net/mac80211/ieee80211_i.h                         |  180 +-
 net/mac80211/iface.c                               |   44 +-
 net/mac80211/key.h                                 |   12 -
 net/mac80211/main.c                                |  350 +-
 net/mac80211/mesh.c                                |  153 +-
 net/mac80211/mesh.h                                |   30 +-
 net/mac80211/mesh_hwmp.c                           |  413 +-
 net/mac80211/mesh_pathtbl.c                        |   21 +-
 net/mac80211/mesh_plink.c                          |   58 +-
 net/mac80211/mlme.c                                |   53 +-
 net/mac80211/rate.c                                |   19 +-
 net/mac80211/rate.h                                |    9 +-
 net/mac80211/rx.c                                  |  991 +-
 net/mac80211/scan.c                                |  129 +-
 net/mac80211/spectmgmt.c                           |    2 +-
 net/mac80211/sta_info.c                            |  175 +-
 net/mac80211/sta_info.h                            |   51 +-
 net/mac80211/status.c                              |  341 +
 net/mac80211/tkip.c                                |    4 +-
 net/mac80211/tx.c                                  |  190 +-
 net/mac80211/util.c                                |   22 +-
 net/mac80211/wep.c                                 |    8 +-
 net/mac80211/wpa.c                                 |   25 +-
 net/netfilter/nf_conntrack_core.c                  |   14 +-
 net/netfilter/nf_conntrack_expect.c                |    6 +-
 net/netfilter/nf_conntrack_ftp.c                   |    8 +-
 net/netfilter/nf_conntrack_proto_dccp.c            |   33 +-
 net/netfilter/nf_conntrack_proto_gre.c             |   22 +-
 net/netfilter/nf_conntrack_proto_tcp.c             |   51 +-
 net/netfilter/nfnetlink_log.c                      |    5 +-
 net/netfilter/nfnetlink_queue.c                    |    3 +-
 net/netfilter/xt_conntrack.c                       |   61 +-
 net/netfilter/xt_socket.c                          |    8 +-
 net/netlabel/netlabel_unlabeled.c                  |    8 +-
 net/netlink/af_netlink.c                           |   11 +-
 net/netlink/genetlink.c                            |   32 +-
 net/netrom/af_netrom.c                             |    7 +-
 net/netrom/nr_route.c                              |   15 +-
 net/packet/af_packet.c                             |   71 +-
 net/phonet/af_phonet.c                             |   83 +-
 net/phonet/datagram.c                              |    6 +-
 net/phonet/pep.c                                   |   35 +-
 net/phonet/pn_dev.c                                |  219 +-
 net/phonet/pn_netlink.c                            |  138 +-
 net/phonet/socket.c                                |   82 +-
 net/rds/af_rds.c                                   |   16 +-
 net/rds/cong.c                                     |    2 +
 net/rds/connection.c                               |    6 +-
 net/rds/ib.h                                       |    2 +
 net/rds/ib_cm.c                                    |    6 +-
 net/rds/ib_rdma.c                                  |    9 +-
 net/rds/ib_recv.c                                  |   47 +-
 net/rds/ib_send.c                                  |    4 +-
 net/rds/iw.h                                       |    2 +
 net/rds/iw_cm.c                                    |    2 +
 net/rds/iw_rdma.c                                  |    9 +-
 net/rds/iw_recv.c                                  |   47 +-
 net/rds/iw_send.c                                  |    7 +-
 net/rds/message.c                                  |    3 +-
 net/rds/rdma.c                                     |   36 +-
 net/rds/rdma.h                                     |    1 +
 net/rds/recv.c                                     |   11 +-
 net/rds/send.c                                     |   27 +-
 net/rds/tcp_listen.c                               |    8 +-
 net/rds/threads.c                                  |    4 +-
 net/rfkill/core.c                                  |    4 +-
 net/rose/af_rose.c                                 |    7 +-
 net/rose/rose_route.c                              |   28 +-
 net/rxrpc/af_rxrpc.c                               |    7 +-
 net/rxrpc/ar-recvmsg.c                             |    2 +-
 net/sched/act_api.c                                |    7 +-
 net/sched/act_mirred.c                             |  107 +-
 net/sched/act_skbedit.c                            |   17 +-
 net/sched/cls_api.c                                |    8 +-
 net/sched/cls_flow.c                               |    2 +-
 net/sched/cls_rsvp.h                               |   28 +-
 net/sched/em_meta.c                                |   13 +-
 net/sched/sch_api.c                                |   19 +-
 net/sched/sch_cbq.c                                |    2 +-
 net/sched/sch_drr.c                                |    2 +-
 net/sched/sch_generic.c                            |   18 +-
 net/sched/sch_hfsc.c                               |    2 +-
 net/sched/sch_htb.c                                |    6 +-
 net/sched/sch_netem.c                              |   12 +-
 net/sched/sch_teql.c                               |   11 +-
 net/sctp/associola.c                               |   27 +-
 net/sctp/chunk.c                                   |   15 +-
 net/sctp/ipv6.c                                    |   21 +-
 net/sctp/output.c                                  |   50 +-
 net/sctp/outqueue.c                                |   26 +-
 net/sctp/protocol.c                                |   19 +-
 net/sctp/sm_make_chunk.c                           |   13 +-
 net/sctp/sm_sideeffect.c                           |    5 +-
 net/sctp/sm_statefuns.c                            |   26 +-
 net/sctp/socket.c                                  |  371 +-
 net/sctp/sysctl.c                                  |   13 +
 net/sctp/transport.c                               |   45 +-
 net/socket.c                                       |  843 ++-
 net/sunrpc/auth.c                                  |    6 +-
 net/sunrpc/auth_gss/gss_krb5_seqnum.c              |    4 +-
 net/sunrpc/auth_gss/svcauth_gss.c                  |    4 +-
 net/sunrpc/cache.c                                 |    5 +-
 net/sunrpc/svc.c                                   |    5 +-
 net/sunrpc/svc_xprt.c                              |    8 +-
 net/sunrpc/svcauth.c                               |    4 +-
 net/sunrpc/svcauth_unix.c                          |    7 +-
 net/sunrpc/svcsock.c                               |    8 +-
 net/sunrpc/xprtrdma/svc_rdma_recvfrom.c            |    7 +-
 net/sunrpc/xprtrdma/verbs.c                        |    4 +-
 net/tipc/cluster.c                                 |   16 +-
 net/tipc/link.c                                    |   12 +-
 net/tipc/socket.c                                  |   20 +-
 net/tipc/subscr.c                                  |    6 +-
 net/unix/af_unix.c                                 |   15 +-
 net/wimax/op-msg.c                                 |    2 +
 net/wimax/op-rfkill.c                              |   18 +-
 net/wimax/stack.c                                  |   11 +
 net/wireless/Kconfig                               |   44 +-
 net/wireless/Makefile                              |   10 +-
 net/wireless/core.c                                |   56 +-
 net/wireless/core.h                                |   15 +-
 net/wireless/debugfs.c                             |   15 +-
 net/wireless/debugfs.h                             |    3 -
 net/wireless/ethtool.c                             |   45 +
 net/wireless/ethtool.h                             |    6 +
 net/wireless/ibss.c                                |   16 +-
 net/wireless/mlme.c                                |  105 +-
 net/wireless/nl80211.c                             |  406 +-
 net/wireless/reg.c                                 |   19 +-
 net/wireless/scan.c                                |   58 +-
 net/wireless/sme.c                                 |   18 +-
 net/wireless/util.c                                |   40 +-
 net/wireless/wext-compat.c                         |   97 +-
 net/wireless/wext-core.c                           | 1065 ++
 net/wireless/wext-priv.c                           |  248 +
 net/wireless/wext-proc.c                           |  155 +
 net/wireless/wext-spy.c                            |  231 +
 net/wireless/wext.c                                | 1775 ---
 net/x25/af_x25.c                                   |  115 +-
 net/x25/x25_in.c                                   |    2 +-
 net/x25/x25_route.c                                |    6 +-
 net/x25/x25_subr.c                                 |    6 +
 net/xfrm/xfrm_algo.c                               |  113 +-
 net/xfrm/xfrm_state.c                              |   32 +-
 net/xfrm/xfrm_user.c                               |  147 +-
 security/lsm_audit.c                               |   12 +-
 security/selinux/hooks.c                           |    6 +-
 security/smack/smack_lsm.c                         |    4 +-
 1396 files changed, 113877 insertions(+), 71108 deletions(-)
 create mode 100644 drivers/isdn/gigaset/capi.c
 create mode 100644 drivers/isdn/gigaset/dummyll.c
 create mode 100644 drivers/misc/iwmc3200top/Kconfig
 create mode 100644 drivers/misc/iwmc3200top/Makefile
 create mode 100644 drivers/misc/iwmc3200top/debugfs.c
 create mode 100644 drivers/misc/iwmc3200top/debugfs.h
 create mode 100644 drivers/misc/iwmc3200top/fw-download.c
 create mode 100644 drivers/misc/iwmc3200top/fw-msg.h
 create mode 100644 drivers/misc/iwmc3200top/iwmc3200top.h
 create mode 100644 drivers/misc/iwmc3200top/log.c
 create mode 100644 drivers/misc/iwmc3200top/log.h
 create mode 100644 drivers/misc/iwmc3200top/main.c
 create mode 100644 drivers/net/can/mcp251x.c
 create mode 100644 drivers/net/can/mscan/Kconfig
 create mode 100644 drivers/net/can/mscan/Makefile
 create mode 100644 drivers/net/can/mscan/mpc5xxx_can.c
 create mode 100644 drivers/net/can/mscan/mscan.c
 create mode 100644 drivers/net/can/mscan/mscan.h
 create mode 100644 drivers/net/can/ti_hecc.c
 delete mode 100644 drivers/net/sfc/boards.c
 delete mode 100644 drivers/net/sfc/boards.h
 delete mode 100644 drivers/net/sfc/ethtool.h
 delete mode 100644 drivers/net/sfc/falcon.h
 create mode 100644 drivers/net/sfc/falcon_boards.c
 delete mode 100644 drivers/net/sfc/falcon_hwdefs.h
 delete mode 100644 drivers/net/sfc/falcon_io.h
 delete mode 100644 drivers/net/sfc/gmii.h
 create mode 100644 drivers/net/sfc/io.h
 create mode 100644 drivers/net/sfc/mcdi.c
 create mode 100644 drivers/net/sfc/mcdi.h
 create mode 100644 drivers/net/sfc/mcdi_mac.c
 create mode 100644 drivers/net/sfc/mcdi_pcol.h
 create mode 100644 drivers/net/sfc/mcdi_phy.c
 create mode 100644 drivers/net/sfc/nic.c
 create mode 100644 drivers/net/sfc/nic.h
 rename drivers/net/sfc/{xfp_phy.c => qt202x_phy.c} (63%)
 create mode 100644 drivers/net/sfc/regs.h
 delete mode 100644 drivers/net/sfc/rx.h
 delete mode 100644 drivers/net/sfc/sfe4001.c
 create mode 100644 drivers/net/sfc/siena.c
 delete mode 100644 drivers/net/sfc/tx.h
 create mode 100644 drivers/net/wireless/ath/ath9k/common.c
 create mode 100644 drivers/net/wireless/ath/ath9k/common.h
 create mode 100644 drivers/net/wireless/ath/debug.c
 create mode 100644 drivers/net/wireless/ath/debug.h
 create mode 100644 drivers/net/wireless/ath/hw.c
 create mode 100644 drivers/net/wireless/ath/reg.h
 create mode 100644 drivers/net/wireless/iwlwifi/iwl-agn-led.c
 create mode 100644 drivers/net/wireless/iwlwifi/iwl-agn-led.h
 create mode 100644 drivers/net/wireless/iwlwifi/iwl-devtrace.c
 create mode 100644 drivers/net/wireless/iwlwifi/iwl-devtrace.h
 delete mode 100644 drivers/net/wireless/libertas/11d.c
 delete mode 100644 drivers/net/wireless/libertas/11d.h
 create mode 100644 drivers/net/wireless/libertas/Kconfig
 create mode 100644 drivers/net/wireless/libertas/cfg.c
 create mode 100644 drivers/net/wireless/libertas/cfg.h
 delete mode 100644 drivers/net/wireless/libertas/hostcmd.h
 create mode 100644 drivers/net/wireless/libertas/mesh.c
 create mode 100644 drivers/net/wireless/libertas/mesh.h
 delete mode 100644 drivers/net/wireless/libertas/persistcfg.c
 create mode 100644 drivers/net/wireless/rt2x00/rt2800.h
 create mode 100644 drivers/net/wireless/rt2x00/rt2800lib.c
 create mode 100644 drivers/net/wireless/rt2x00/rt2800lib.h
 create mode 100644 drivers/net/wireless/rt2x00/rt2800pci.c
 create mode 100644 drivers/net/wireless/rt2x00/rt2800pci.h
 create mode 100644 drivers/net/wireless/rt2x00/rt2x00soc.c
 create mode 100644 drivers/net/wireless/rt2x00/rt2x00soc.h
 delete mode 100644 drivers/net/wireless/wl12xx/wl1251_netlink.h
 create mode 100644 drivers/net/wireless/wl12xx/wl1271_conf.h
 delete mode 100644 drivers/s390/net/cu3088.c
 delete mode 100644 drivers/s390/net/cu3088.h
 create mode 100644 drivers/staging/arlan/Kconfig
 create mode 100644 drivers/staging/arlan/Makefile
 create mode 100644 drivers/staging/arlan/TODO
 rename drivers/{net/wireless => staging/arlan}/arlan-main.c (100%)
 rename drivers/{net/wireless => staging/arlan}/arlan-proc.c (100%)
 rename drivers/{net/wireless => staging/arlan}/arlan.h (100%)
 create mode 100644 drivers/staging/netwave/Kconfig
 create mode 100644 drivers/staging/netwave/Makefile
 create mode 100644 drivers/staging/netwave/TODO
 rename drivers/{net/wireless => staging/netwave}/netwave_cs.c (100%)
 create mode 100644 drivers/staging/strip/Kconfig
 create mode 100644 drivers/staging/strip/Makefile
 create mode 100644 drivers/staging/strip/TODO
 rename drivers/{net/wireless => staging/strip}/strip.c (99%)
 create mode 100644 drivers/staging/wavelan/Kconfig
 create mode 100644 drivers/staging/wavelan/Makefile
 create mode 100644 drivers/staging/wavelan/TODO
 rename drivers/{net/wireless => staging/wavelan}/i82586.h (100%)
 rename drivers/{net/wireless => staging/wavelan}/wavelan.c (100%)
 rename drivers/{net/wireless => staging/wavelan}/wavelan.h (100%)
 rename drivers/{net/wireless => staging/wavelan}/wavelan.p.h (100%)
 rename drivers/{net/wireless => staging/wavelan}/wavelan_cs.c (100%)
 rename drivers/{net/wireless => staging/wavelan}/wavelan_cs.h (100%)
 rename drivers/{net/wireless => staging/wavelan}/wavelan_cs.p.h (99%)
 delete mode 100644 firmware/bnx2x-e1-5.0.21.0.fw.ihex
 create mode 100644 firmware/bnx2x-e1-5.2.7.0.fw.ihex
 delete mode 100644 firmware/bnx2x-e1h-5.0.21.0.fw.ihex
 create mode 100644 firmware/bnx2x-e1h-5.2.7.0.fw.ihex
 create mode 100644 include/linux/can/platform/mcp251x.h
 create mode 100644 include/linux/can/platform/ti_hecc.h
 rename {drivers/net/wireless => include/linux}/i82593.h (100%)
 delete mode 100644 net/core/skb_dma_map.c
 create mode 100644 net/ieee802154/ieee802154.h
 create mode 100644 net/ieee802154/nl-mac.c
 create mode 100644 net/ieee802154/nl-phy.c
 create mode 100644 net/mac80211/status.c
 create mode 100644 net/wireless/ethtool.c
 create mode 100644 net/wireless/ethtool.h
 create mode 100644 net/wireless/wext-core.c
 create mode 100644 net/wireless/wext-priv.c
 create mode 100644 net/wireless/wext-proc.c
 create mode 100644 net/wireless/wext-spy.c
 delete mode 100644 net/wireless/wext.c
