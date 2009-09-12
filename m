From: David Miller <davem@davemloft.net>
Subject: [GIT]: Networking
Date: Fri, 11 Sep 2009 20:25:43 -0700 (PDT)
Message-ID: <20090911.202543.52533792.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1757323AbZILDZm@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Besides the usual plethora of driver updates, here are the
changes that stand out:

1) Major cleanup of pktgen from Stephen Hemminger, including
   a long overdue conversion to ktime_t and hrtimers

2) Multiqueue devices are handled more cleanly in the packet scheduler
   by using a new dummy classful queue discipline called 'mq', and
   this makes us report statistics on multiqueue devices properly
   too.  From Patrick McHardy.

3) proc_create*() and seq_file conversions from Alexey Dobriyan.

4) MDIO ioctl cleanups from Ben Hutchings.

5) Dropped a lot of old compat netfilter bits, from Jan Engelhardt and
   Patrick McHardy.

6) Make VLAN and MACVLAN drivers support multiqueue, from Eric Dumazet.

7) ETRM support in bluetooth from Gustavo F. Padovan

8) fib_trie adjustments and fixes from Jarek Poplawski and Jens L=E5=E5=
s

9) Return type of net driver xmit routines is formalized into
   a netdev_tx_t so we can catch drivers returning undefined
   garbage at compile time.  From Stephen Hemminger.

10) default qdisc optimizations from Krishna Kumar

11) Lots of bluetooth fixes and cleanups from Marcel Holtmann

12) Add a sysfs file that helps userland distinguish wimax, wireless,
    etc. device types easily.  Also from Marcel.

13) FD sending over unix sockets was broken with stream sockets when
    multiple segments were necessary, fix from Miklos Szeredi and
    this is a old'ish regression so this will be sent to -stable too.

14) Networking tracepoint enhancements from Neil Horman and Xiao Guangr=
ong.

15) Fix premature termination of FIN_WAIT2, from Octavian Purdila.

16) Several fixes and enhancements for SW UDP fragmentation offload
    support.  From Sridhar Samudrala.

17) Lots of SCTP cures from Vlad Yasevich and Wei Yongjun.

18) FCOE offloading infrastructure and support for Intel cards from
    Yi Zou.

19) New Marvel bluetooth driver from Bing Zhao

20) Add TCP support to RDS stack, from Andy Grover.

Actually, relatively speaking, it's a slow release cycle for networking=
=2E
Maybe we'll therefore introduce less regressions this time. :-)

Please pull, thanks a lot!

The following changes since commit 86d710146fb9975f04c505ec78caa43d227c=
1018:
  Linus Torvalds (1):
        Merge git://git.linux-nfs.org/projects/trondmy/nfs-2.6

are available in the git repository at:

  master.kernel.org:/pub/scm/linux/kernel/git/davem/net-next-2.6.git ma=
ster

Abhijeet Kolekar (1):
      iwlwifi: fix remove key error

Ajit Khaparde (4):
      be2net: Add GRO support to the be2net driver. LRO is not supporte=
d anymore.
      net/ethtool: Add support for the ethtool feature to flash firmwar=
e image from a specified file.
      be2net: Changes to support flashing of the be2 network adapter
      be2net: Code changes in Tx path to use skb_dma_map/skb_dma_unmap

Albert Herranz (1):
      ssb: Implement SDIO host bus support

Alexander Beregalov (1):
      ar9170: fix build error when !CONFIG_AR9170_LEDS

Alexander Duyck (17):
      igb: remove media type fiber as it is misleading
      igb: make serdes power down available for 82575 in addition to 82=
576 parts
      igb: change configure_pcs_link to void since it always returns 0
      igb: do not overwrite EEPROM LED settings
      igb: add completion timeout workaround for 82575/82576
      igb: move all multicast addresses into multicast table array
      igb: cleanup receive address register initialization
      igb: remove unused switch statement from igb_set_wol
      igb: add support for 82576 mezzanine card
      igb: use buffer_info->dma instead of shinfo->nr_frags to determin=
e unmap
      igb: cleanup flow control configuration to make requested/current=
 more clear
      igb: initialize mailbox function pointers prior to phy init
      igbvf: resolve "frees DMA memory with different size" warnings
      igb/ixgbe: add IPV6_CSUM support to vlan_features
      igb: add support for set_rx_mode netdevice operation
      igb: only disable/enable interrupt bits for igb physical function
      igb: set vf rlpml wasn't taking vlan tag into account

Alexey Dobriyan (6):
      pktgen: use proc_create_data()
      can: switch to seq_file
      netfilter: nf_conntrack: netns fix re reliable conntrack event de=
livery
      netns: embed ip6_dst_ops directly
      sctp: use proc_create()
      headers: net/ipv[46]/protocol.c header trim

Amit Kumar Salecha (8):
      netxen: support for ethtool set ringparam
      netxen: implement pci driver shutdown
      netxen: fix ip addr hashing after firmware reset
      netxen: pre calculate register addresses
      netxen: fix check for ip addr hashing support
      netxen: fix tx descriptor structure
      netxen: change firmware write size
      netxen: fix tx timeout recovery

Andi Kleen (1):
      TCP: Add comments to (near) all functions in tcp_output.c v3

Andrey Yurovsky (7):
      libertas: remove ps_supported flag, use fwcapinfo
      libertas: copy WPA keys to priv when associating
      libertas: correct card cleanup order in SPI driver
      libertas: fix card cleanup order in SDIO driver
      libertas: check valid bits in SPI bus mode reg
      mac80211: Use correct sign for mesh active path refresh.
      libertas: don't use dynamic-sized array

Andy Grover (20):
      RDS: Set retry_count to 2 and make modifiable via modparam
      RDS/IB: Improve RDS protocol version checking
      RDS/IB: Handle connections using RDS 3.0 wire protocol
      RDS/IB: Fix printk to indicate remote IP, not local
      RDS/RDMA: Fix cut-n-paste errors in printks in rdma_transport.c
      RDS/IB: Rename byte_len to data_len to enhance readability
      RDS: Don't set c_version in __rds_conn_create()
      RDS/IB: Move tx/rx ring init and refill to later
      RDS/IB: Disable flow control in sysctl and explain why
      RDS/IB: Drop connection when a fatal QP event is received
      RDS: Fix completion notifications on blocking sockets
      RDS/IB: Always use PAGE_SIZE for FMR page size
      RDS/IW: Remove page_shift variable from iwarp transport
      RDS/IW: Remove dead code
      RDS: Refactor end of __conn_create for readability
      RDS: Add TCP transport to RDS
      RDS: Export symbols from core RDS
      RDS: Modularize RDMA and TCP transports
      RDS: Track transports via an array, not a list
      RDS: Add a debug message suggesting to load transport modules

Anton Vorontsov (10):
      ucc_geth: Add support for skb recycling
      netpoll: Introduce netpoll_carrier_timeout kernel option
      ucc_geth: Fix NULL pointer dereference in uec_get_ethtool_stats()
      powerpc/qe: Implement qe_alive_during_sleep() helper function
      ucc_geth: Factor out MAC initialization steps into a call
      ucc_geth: Remove UGETH_MAGIC_PACKET Kconfig symbol and code
      ucc_geth: Implement suspend/resume and Wake-On-LAN support
      phy/marvell: Make non-aneg speed/duplex forcing work for 88E1111 =
PHYs
      ucc_geth: Rearrange some code to avoid forward declarations
      ucc_geth: Fix hangs after switching from full to half duplex

Ari Kauppi (2):
      wl12xx: Fix incorrect warning message.
      wl12xx: Fix CMD_TEST regression via netlink.

Arnaldo Carvalho de Melo (1):
      Subject: [PATCH] appletalk: Fix skb leak when ipddp interface is =
not loaded

Arnd Hannemann (2):
      mac80211: Remove unnused throughput field from minstrel_rate.
      mac80211: Fix output of minstrels rc_stats

Atsushi Nemoto (5):
      tc35815: Disable StripCRC
      tc35815: Improve BLEx / FDAEx handling
      tc35815: Increase timeout for mdio
      tc35815: Fix rx_missed_errors count
      tc35815: Use 0 RxFragSize.MinFrag value for non-packing mode

Ben Greear (1):
      veth: Zero timestamp in xmit path.

Ben Hutchings (10):
      mdio: mdio_if_info::mmds should not be __bitwise
      sfc: Fix ordering of device registration and initial netif_carrie=
r_off()
      sfc: Do not reinitialise XAUI serdes before it has completed rese=
t
      mdio: Check MDIO_STAT1_FAULT in mdio45_links_ok()
      sfc: QT2025C: Use hard reset only
      sfc: Work around XMAC bug causing packet loss with some peers
      sfc: Improve reliability of RX queue flushing
      netdev: Remove SIOCDEVPRIVATE aliases for MDIO ioctls
      netdev: Remove redundant checks for CAP_NET_ADMIN in MDIO impleme=
ntations
      netdev: Convert MDIO ioctl implementation to use struct mii_ioctl=
_data

Benjamin LaHaise (6):
      vxge: don't drop frame on tx queue full
      vxge: fix pktgen hangs (don't abuse skb->cb[])
      vxge: improve tx performance by using mmiowb() instead of wmb()
      vxge: prefetch RxD descriptors
      vxge: prefetch skb->data
      vxge: Version update

Benoit PAPILLAULT (1):
      rt2x00: Add support for retry rates

Bhaskar Dutta (1):
      sctp: Sysctl configuration for IPv4 Address Scoping

Bing Zhao (5):
      Bluetooth: Add btmrvl driver for Marvell Bluetooth devices
      Bluetooth: Add Marvell BT-over-SDIO driver
      Bluetooth: Add debugfs support to btmrvl driver
      Bluetooth: Add documentation for Marvell Bluetooth driver
      Bluetooth: Fix incorrect alignment in Marvell BT-over-SDIO driver

Bob Copeland (25):
      ath5k: cleanup ath5k_hw struct
      ath5k: enable hardware LEDs
      ath5k: send buffered frames after the beacon
      ath5k: rework beacon configuration
      ath: remove unnecessary return in ath_regd_get_band_ctl
      ath5k: do not release irq across suspend/resume
      ath5k: write PCU registers on initial reset
      mac80211: disable beacons before removing the associated interfac=
e
      ath5k: update PCU opmode whenever a new interface is added
      ath5k: fix CAB queue operation
      wl1251: separate bus i/o code into io.c
      wl1251: use wiphy_dev instead of wl->spi->dev
      wl1251: introduce wl1251_if_operations struct
      wl1251: make wl1251_set_partition bus agnostic
      wl1251: move module probe methods into spi.c
      wl1251: split spi interface into separate module
      wl1251: add sdio support
      wl1251: make irq handling interface specific
      wl1251: correct definitions for 0th bit defines
      wl1251: halt the embedded CPU before loading firmware
      ath5k: clean up filter flags setting
      ath5k: use the skb->cb directly for RX status
      ath5k: add hardware CCMP encyption support
      ath5k: clarify srev comparison for CCMP check
      cfg80211: fix looping soft lockup in find_ie()

Brian Haley (2):
      netlink: silence compiler warning
      ipv6: Add IFA_F_DADFAILED flag

Brice Goglin (1):
      myri10ge: improve parity error detection and recovery

Changli Gao (1):
      net: remove redundant sched/ in net/Makefile

Christian Lamparter (28):
      ar9170usb: module link in sysfs
      p54: redo rx_status into skb->cb
      p54: Move eeprom code
      p54: Move eeprom header
      p54: Move firmware code
      p54: Move LED code
      p54: Move LMAC interface definitions
      p54: Move mac80211 glue code
      p54: Move TX/RX code
      p54: Modify p54 files for new organization
      p54: two endian fixes
      p54spi: remove dead code and definitions
      p54usb: fix stalls caused by urb allocation failures
      p54: fix queue stall due to underrun
      p54: re-enable power save feature
      p54: generate channel list dynamically
      ar9170: implement transmit aggregation
      p54: remove useless code
      p54: fix beaconing related firmware crash
      p54: fix a fw crash caused by statistic feedback
      mac80211: do not monitor the connection while scanning
      mac80211: fix spare warnings in driver-trace.h
      p54: Write outside array bounds
      p54: implement rfkill
      p54: disable PS by default
      ar9170: refactor configure_filter
      p54: fix broadcast buffering in AP mode
      ar9170: implement frequency calibration for one-stage/openfw

Cosmin Ratiu (1):
      ipv6: Fix tcp_v6_send_response(): it didn't set skb transport hea=
der

Cyrill Gorcunov (3):
      net, bridge: align br_nf_ops assignment
      net, netns_xt: shrink netns_xt members
      net,pppoe: fixup module init/exit subsequent calls

Damian Lukowski (5):
      Revert Backoff [v3]: Rename skb to icmp_skb in tcp_v4_err()
      Revert Backoff [v3]: Revert RTO on ICMP destination unreachable
      Revert Backoff [v3]: Calculate TCP's connection close threshold a=
s a time value.
      RTO connection timeout: coding style fixes and comments
      RTO connection timeout: sysctl documentation update

Dan Williams (1):
      libertas: clean up and clarify get_common_rates

Daniel C Halperin (13):
      iwlwifi: clear iwl_cmd_meta structure before use
      iwlwifi: remove unused HT configuration entry tx_chan_width
      iwlwifi: include HT configuration when adding stations through rs=
_rate_init
      iwlwifi: refactor packet reception code
      iwlwifi: configure HT40 channels in iwl_mac_config
      iwlwifi: check short GI support per-station rather than globally
      iwlwifi: use station HT capabilities and BSS operating mode for G=
reen-field
      iwlwifi: fix erroneous use of iwl_rx_packet.len as a length
      iwlwifi: clear rate control flags on non-HT packet
      iwlwifi: set HT flags in ieee80211_rx_status for received packets
      iwlwifi: remove 60 Mbps from sband bitrates table
      iwlwifi: remove incorrect uses of ieee80211_get_tx_rate to preven=
t TX stall
      iwlwifi: use iwl_hwrate_get_mac80211_idx where appropriate

Daniel Mack (2):
      net: smsc911x: switch to new dev_pm_ops
      libertas: name the network device wlan%d

Daniel Silverstone (1):
      IEEE80154: Add documentation to the IEEE80154 netlink and fakehar=
d driver

Daniel Walker (1):
      mac80211: New stat counters for multicast and unicast forwarded f=
rames

Dave Jones (4):
      Remove unused zero-copy code from velocity NIC driver.
      Fix up CodingStyle problems in via-velocity.c
      Remove unnecessary forward declarations from velocity NIC driver.
      Fix typos in comments in via-velocity header.

David Kilroy (32):
      cfg80211: add wrapper function to get wiphy from priv pointer
      cfg80211: Advertise ciphers via WE according to driver capability
      cfg80211: allow drivers that can't scan for specific ssids
      cfg80211: set WE encoding size based on available ciphers
      cfg80211: infer WPA and WPA2 support from TKIP and CCMP
      orinoco: Move firmware capability determination into hw.c
      orinoco: Move card reading code into hw.c
      orinoco: Move FID allocation to hw.c
      orinoco: use dev_err in early initialisation routines
      orinoco: firmware helpers should use dev_err and friends
      orinoco: Replace net_device with orinoco_private in driver interf=
aces
      orinoco: initialise independently of netdev
      orinoco: Change set_tkip to use orinoco_private instead of hermes=
_t
      orinoco: initiate cfg80211 conversion
      orinoco: make firmware download less verbose
      orinoco: move netdev interface creation to main driver
      airport: store irq in card private structure
      orinoco: Handle suspend/restore in core driver
      orinoco: provide generic commit function
      orinoco: convert mode setting to cfg80211
      orinoco: convert scanning to cfg80211
      orinoco: convert giwrange to cfg80211
      orinoco: remove WE nickname support
      orinoco: fix printk format specifier for size_t arguments
      orinoco: prefer_port3 can be a single bit
      orinoco: use local types for auth alg and sequence length
      orinoco: pass orinoco_set_tkip_key the sequence lengths
      orinoco: move disassociation to hw.c
      orinoco: add function to retrieve current bssid
      orinoco: consolidate storage of WEP and TKIP keys
      cfg80211: fix leaks of wdev->conn->ie
      orinoco: remove spare whitespace

David S. Miller (30):
      Merge branch 'master' of master.kernel.org:/.../davem/net-2.6
      Merge branch 'master' of master.kernel.org:/.../davem/net-2.6
      Merge branch 'master' of master.kernel.org:/.../davem/net-2.6
      Merge branch 'master' of master.kernel.org:/.../davem/net-2.6
      Merge branch 'for_david' of git://git.kernel.org/.../kkeil/ISDN-2=
=2E6-net-next
      Merge branch 'master' of git://git.kernel.org/.../linville/wirele=
ss-next-2.6
      phonet: Fix build.
      Merge branch 'for-linus' of git://git.kernel.org/.../lowpan/lowpa=
n
      Merge branch 'master' of master.kernel.org:/.../davem/net-2.6
      Merge branch 'master' of git://git.kernel.org/.../linville/wirele=
ss-next-2.6
      xfrm6: Fix xfrm6_policy.c build when SYSCTL disabled.
      Merge branch 'master' of git://git.kernel.org/.../linville/wirele=
ss-next-2.6
      Merge branch 'master' of master.kernel.org:/.../davem/net-2.6
      Merge branch 'master' of master.kernel.org:/.../davem/net-2.6
      Merge branch 'master' of git://git.kernel.org/.../linville/wirele=
ss-next-2.6
      Merge branch 'master' of master.kernel.org:/.../davem/net-2.6
      ppp_generic: Help GCC see that 'flen' is always initialized.
      Merge branch 'master' of git://git.kernel.org/.../linville/wirele=
ss-next-2.6
      Merge branch 'for-next' of git://git.kernel.org/.../lowpan/lowpan
      net: Temporarily backout SKB sources tracer.
      Merge branch 'master' of git://git.kernel.org/.../linville/wirele=
ss-next-2.6
      Merge branch 'master' of git://git.kernel.org/.../holtmann/blueto=
oth-next-2.6
      xilinx_emaclite: Fix permissions on driver sources.
      Merge branch 'master' of master.kernel.org:/.../davem/net-2.6
      Merge branch 'master' of git://git.kernel.org/.../linville/wirele=
ss-next-2.6
      WAN: dscc4: Fix warning pointing out a bug.
      net_sched: add classful multiqueue dummy scheduler
      r8169: Fix warning in rtl8169_start_xmit().
      Merge branch 'master' of git://git.kernel.org/.../linville/wirele=
ss-next-2.6
      Merge branch 'master' of git://git.kernel.org/.../kaber/nf-next-2=
=2E6

David Ward (1):
      ipv6: Update Neighbor Cache when IPv6 RA is received on a router

David Woo (2):
      mac80211: Mark a destination sequence number as valid when a PREQ=
 is received.
      mac80211: Fix invalid length passed to IE parser for PLINK CONFIR=
M frames

Dean Nelson (9):
      atl1c: return PCI_ERS_RESULT_DISCONNECT on permanent failure
      atl1e: return PCI_ERS_RESULT_DISCONNECT on permanent failure
      bnx2: return PCI_ERS_RESULT_DISCONNECT on permanent failure
      bnx2x: return PCI_ERS_RESULT_DISCONNECT on permanent failure
      igbvf: return PCI_ERS_RESULT_DISCONNECT on permanent failure
      ixgb: return PCI_ERS_RESULT_DISCONNECT on permanent failure
      qlge: return PCI_ERS_RESULT_DISCONNECT on permanent failure
      s2io: return PCI_ERS_RESULT_DISCONNECT on permanent failure
      vxge: return PCI_ERS_RESULT_DISCONNECT on permanent failure

Dhananjay Phadke (31):
      netxen: refresh firmware info after reset
      netxen: enable ip addr hashing
      netxen: configure interrupt coalesce defaults
      netxen: annotate dma watchdog setup
      netxen: refactor tso code
      netxen: Add default and limit macros for ring sizes.
      netxen: clean up firmware version checks
      netxen: refactor net_device setup code
      netxen: fix skb alloc size for legacy firmware
      netxen: add vlan tx acceleration support
      netxen: update version to 4.0.41
      netxen: fix CONFIG_INET=3Dn build
      netxen: fix vlan tso case
      netxen: remove unnecessary structures
      netxen: add hardware LRO support
      netxen: fix firmware reset logic
      netxen: refactor tx dma mapping code
      netxen: remove netxen_nic_phan_reg.h
      netxen: remove unused code
      netxen: implement generic pcie semaphore functions
      netxen: remove netxen_nic_niu.c
      netxen: fix lro buffer allocation
      netxen: remove duplicate napi_add
      netxen: fix infinite loop on dma mapping failure
      netxen: handle firmware load errors
      netxen: firmware hang detection
      netxen: refactor firmware info code
      netxen: update version to 4.0.50
      netxen: improve pci memory access
      netxen: fix file firmware leak
      netxen: update copyright

Divy Le Ray (11):
      cxgb3: AQ100X phy support update
      cxgb3: fix phy power down
      cxgb3: Fix T3C MAC max packet size access
      cxgb3: AEL2020 phy support update
      cxgb3: use request_firmware() for the EDC registers setup
      cxgb3: Fix mss table initialization
      cxgb3: fix mac index mapping
      cxgb3: Drain Mac Tx fifo when the port goes down.
      cxgb3: fix EDC filename string
      cxgb3: fix Gen2 pci default settings
      cxgb3: fix 2 ports 1G regression

Dmitry Eremin-Solenikov (14):
      ieee802154: move headers out of extra directory
      af_ieee802154: drop IEEE802154_SIOC_ADD_SLAVE declaration
      nl802154: make ieee802154_policy constant
      documentation: fix wrt. headers rename
      nl802154: add support for dumping WPAN interface information
      af_ieee802154: minor cleanup in dgram_bind
      af_ieee802154: add support for WANT_ACK socket option
      nl802154: support START-CONFIRM primitive
      fakehard: use START-CONFIRM primitive to report START failure
      ieee802154: document the skb->cb usage clearly.
      ieee802154: add a sysfs representation of WPAN master devices
      fakehard: add binding to wpan-phy device
      ieee802154: add support for channel pages from IEEE 802.15.4-2006
      Drop ARPHRD_IEEE802154_PHY

Don Skidmore (1):
      ixgbe: cleanup functions that should have been defined static

Doug Graham (1):
      sctp: Fix piggybacked ACKs

Eilon Greenstein (50):
      bnx2x: Stop management traffic in loopback test
      bnx2x: Fan failure
      bnx2x: Fan failure early detection
      bnx2x: Adding some mmiowb
      bnx2x: SMP-safe inter_sem
      bnx2x: Update vlan_features
      bnx2x: Supporting BCM8727 PHY
      bnx2x: Set LED in loopback test
      bnx2x: Missing parenthesis might result with wrong casting
      bnx2x: Version 1.48.113-1
      bnx2x: Receive traffic that maches management filtering rules
      bnx2x: Self-test kills management traffic
      bnx2x: WoL only with current MAC address
      bnx2x: Version 1.48.114-1
      bnx2x: New FW files
      bnx2x: Using the new FW
      bnx2x: Removing old FW files
      bnx2x: Supporting Device Control Channel
      bnx2x: Advertize flow control normally in MF mode
      bnx2x: BCM8481 LED4 instead of LASI
      bnx2x: Reading the FW version of the BCM8481 PHY
      bnx2x: get_ext_phy_fw_version returns NULL if not applicable
      bnx2x: BCM8727 FW load
      bnx2x: Adding XAUI CL73 autoneg support
      bnx2x: MDC/MDIO CL45 IOCTLs
      bnx2x: Supporting PHY FW upgrade
      bnx2x: Removing old PHY FW upgrade code
      bnx2x: Reporting host statistics to management FW
      bnx2x: Prefetch the page containing the BD descriptor
      bnx2x: Adding Likely directive
      bnx2x: Configurable pause scheme
      bnx2x: Calling pci_set_drvdata earlier
      bnx2x: Stop loading if error condition detected
      bnx2x: Combine get_pcie_width and get_pcie_speed
      bnx2x: Move printing of version from probe to the init
      bnx2x: Updating regdump_len at drvinfo
      bnx2x: Remove the init_dmae field from bp
      bnx2x: Check unzip return code
      bnx2x: Keep only one HW path active
      bnx2x: Remove SGMII configuration when not required
      bnx2x: Missing smp_wmb for statistics state machine
      bnx2x: Re-arrange the link structures for better alignment
      bnx2x: Using macro for phy address
      bnx2x: Adding explicit casting
      bnx2x: Using PCI_DEVICE macro
      bnx2x: Re-factor the initialization code
      bnx2x: Beautify bnx2x_dump.h
      bnx2x: Removing unused definitions
      bnx2x: Whitespaces and comments
      bnx2x: update version to 1.52.1

Eric Dumazet (22):
      udp: cleanups
      af_packet: style cleanups
      bnx2x: Dont update vlan_features in bnx2x_set_tso()
      bnx2: Update vlan_features
      phonet: phonet_device_get() fix
      net: ethtool_op_get_rx_csum() should be public and exported
      neigh: Convert garbage collection from softirq to workqueue
      netfilter: bridge: refcount fix
      ipv4: af_inet.c cleanups
      tcp: keepalive cleanups
      net: ip_rt_send_redirect() optimization
      macvlan: Use compare_ether_addr_64bits()
      bonding: use compare_ether_addr_64bits() in ALB
      ipv6: ip6_push_pending_frames() should increment IPSTATS_MIB_OUTD=
ISCARDS
      vlan: multiqueue vlan device
      ip: Report qdisc packet drops
      drivers: Kill now superfluous ->last_rx stores
      net: net/core/dev.c cleanups
      vlan: enable multiqueue xmits
      net: Remove debugging code
      macvlan: add multiqueue capability
      vlan: adds drops accounting

=46ischer, Anna (1):
      net/bridge: Add 'hairpin' port forwarding mode

=46lorian Fainelli (7):
      cpmac: fix wrong MDIO bus identifier
      ar7: add fixed PHY support for the two on-board cpmac
      cpmac: add support for fixed PHY
      cpmac: wait longer after MDIO reset
      cpmac: bump version to 0.5.1
      cpmac: unmark as broken
      r6040: bump to version 0.25 and 20 August 2009 release date

=46lorian Westphal (1):
      net: remove NET_RX_BAD and NET_RX_CN* defines

=46rank Blaschka (1):
      qeth: scheduling while atomic during ifconfig online sequence

Gabor Juhos (9):
      ath9k: remove unnecessary clearing of SC_OP_WAIT_{BEACON,CAB} fla=
gs
      ath9k: remove ath_rx_ps_back_to_sleep helper
      ath9k: serialize ath9k_hw_setpower calls
      ath9k: uninline ath9k_ps_{wakeup,restore} functions
      ath9k: serialize ath9k_ps_{wakeup,restore} calls
      ath9k: wake up the chip for TSF reset
      ath9k: make use ath9k_hw_wait int ath9k_hw_reset_tsf
      ath9k: fix race with IEEE80211_CONF_PS checks
      ath9k: get rid of unnecessary setpower calls

Gerrit Renker (4):
      mcastv6: Local variable shadows function argument
      inet6: functions shadow global variable
      inet6: Conversion from u8 to int
      inet6: Set default traffic class

Graham, David (2):
      e1000: Remove unused function e1000_mta_set.
      e1000: Fix for e1000 kills IPMI on a tagged vlan.

Guo-Fu Tseng (7):
      jme: Some minor coding style consistency modifications
      jme: Fix unmatched tasklet_{enable|disable} pair
      jme: Fix typo
      jme: Change bufinf memory location
      jme: Remove shadow register support
      jme: Tuning rxsum function
      jme: Advance driver version number

Gustavo F. Padovan (15):
      Bluetooth: Add configuration support for ERTM and Streaming mode
      Bluetooth: Create separate l2cap_send_disconn_req() function
      Bluetooth: Add initial support for ERTM packets transfers
      Bluetooth: Add support for Segmentation and Reassembly of SDUs
      Bluetooth: Initial support for retransmission of packets with REJ=
 frames
      Bluetooth: Add support for Retransmission and Monitor Timers
      Bluetooth: Enable Streaming Mode for L2CAP
      Bluetooth: Add support for FCS option to L2CAP
      Bluetooth: Add support for L2CAP SREJ exception
      Bluetooth: Full support for receiving L2CAP SREJ frames
      Bluetooth: Add locking scheme to L2CAP timeout callbacks
      Bluetooth: Use proper *_unaligned_le{16,32} helpers for L2CAP
      Bluetooth: Acknowledge L2CAP packets when receiving RR-frames (F-=
bit=3D1)
      Bluetooth: Handle L2CAP case when the remote receiver is busy
      Bluetooth: Add support for L2CAP 'Send RRorRNR' action

G=E1bor Stefanik (47):
      cfg80211: fix disabling WPA via wext (SIOCSIWAUTH)
      b43: implement baseband init for LP-PHY <=3D rev1
      b43: Add LP 2063 radio init
      b43: Typo fixes & minor cleanup
      b43: Fix fallout from the IEEE80211_IF_TYPE to NL80211_IFTYPE cha=
nge.
      b43: LP-PHY: Implement STX synchronization
      b43: Implement LP-PHY baseband table initialization
      b43: Update LP-PHY rev2+ baseband init to match the specs
      ssb: Implement the remaining rev.8 SPROM vars needed for LP-PHY
      b43: Fix a typo in the sync_stx routine
      b43: LP-PHY: Implement reading band SPROM
      b43: Implement RC calibration for rev.2+ LP PHYs
      b43: LP-PHY: Refactor TX gain table I/O
      b43: Implement RC calibration for rev.0/1 LP-PHYs
      b43: Update dummy transmission to match V4 specs
      b43: LP-PHY: Initialize TX power control
      b43: LP-PHY: Implement channel switching for rev2+/B2063 radio
      b43: LP-PHY: Implement channel switching for rev0/1/B2062 radio
      ssb: Fix typo in the rev8 SPROM extraction routine
      b43: Add LP-PHY firmware loading support
      b43: Make LP-PHY testable
      b43: LP-PHY: Don't adjust gain table for rev2+ when setting chann=
el
      b43: LP-PHY: Update TX gain override for a spec typo fix
      b43: LP-PHY: Fix another TX power control abuse
      b43: Handle B43_PHYTYPE_LP in RX path
      b43: LP-PHY: Update baseband init for recent spec changes
      b43: LP-PHY: Fix a spec error in the B2062 channel switch routine
      b43: LP-PHY: Update code for spec fixes, and fix a few typos
      b43: LP-PHY: Fix a bug in the B2062 channel tune path
      b43: LP-PHY: Update B2062 radio init with recent spec changes
      b43: LP-PHY: Remove BROKEN from B43_PHY_LP
      b43: LP-PHY: Fix reading old mode in the set TX power control rou=
tine
      b43: LP-PHY: Fix setting TX power control mode during RC calibrat=
ion
      b43: LP-PHY: Two small spec updates
      b43: LP-PHY: Implement spec updates and remove resolved FIXMEs
      iwlwifi: Make injection of non-broadcast frames work again
      b43: LP-PHY: Fix a few typos in the RC calibration code
      b43: LP-PHY: Fix and simplify Qdiv roundup
      b43: Fix and update LP-PHY code
      ssb: Implement PMU LDO control and use it in b43
      b43: LP-PHY: Revert to the original PHY register write routine
      b43: Enable LP-PHY support by default and remove Kconfig warning
      b43: Implement antenna diversity support for LP-PHY
      b43: Refactor and update antenna diversity for A/G-PHY
      b43: Add myself to module authors & to LP-PHY file copyright noti=
ces
      b43: Fix typo in modparam_btcoex description
      b43: LP-PHY: Fix TX gain tables

Hannes Eder (2):
      IPVS: use pr_fmt
      IPVS: use pr_err and friends instead of IP_VS_ERR and friends

Helmut Schaa (10):
      mac80211: shorten the passive dwell time for sw scans
      cfg80211: update misleading comment
      mac80211: refactor the scan code
      mac80211: advance the state machine immediately if no delay is ne=
eded
      mac80211: introduce a new scan state "decision"
      mac80211: Replace {sw, hw}_scanning variables with a bitfield
      mac80211: implement basic background scanning
      mac80211: rename scan_state to next_scan_state
      cfg80211: increase scan result expire time
      mac80211: fix an oops in ieee80211_scan_state_set_channel

Herbert Xu (1):
      vlan: Propagate physical MTU changes

Herton Ronaldo Krzesinski (2):
      rtl8187: fix circular locking (rtl8187_stop/rtl8187_work)
      rtl8187: Implement rfkill support

Hin-Tak Leung (3):
      zd1211rw: sort vid/pid pairs by numerical value
      zd1211rw: adding Accton Technology Corp (083a:e501) as a ZD1211B =
device
      rtl8187: updating Kconfig with info of branded devices

Holger Schurig (2):
      orinoco: enable cfg80211 "set_channel" operation
      cfg80211: allow scanning on specified frequencies when using wext=
-compatibility

Huang Weiyi (1):
      dropmon: remove duplicated #include

Igor Perminov (4):
      mac80211: FIF_PSPOLL filter flag
      rt2x00: Fix for race condition while update beacon
      rt2x00: FIF_PSPOLL filter flag support
      rt2x00: Fix beacon de-synchronization while update beacon

Ivo van Doorn (18):
      rt2x00: use wiphy rfkill interface
      rt2x00: Remove DEVICE_STATE_DISABLED_RADIO_HW
      rt2x00: Fix build error when crypto support is disabled
      rt2x00: Remove usage of deprecated radio_enabled & IEEE80211_CONF=
_CHANGE_RADIO_ENABLED
      rt2x00: Use IEEE80211_TX_CTL_MORE_FRAMES flag
      rt2x00: Align ieee80211 header to 4-byte boundary for PCI devices
      rt2x00: Fix RFKILL polling
      rt2x00: Fix for rt2800usb for SHARED_KEY_TABLE initializations
      rt2x00: Add new RF chip defines
      rt2x00: Set SKBDESC_L2_PADDED in RX path
      rt2x00: wireless CLI ID and packet ID must not be 0
      rt2x00: Fix MCS register intialization
      rt2x00: configure_filter() callback is allowed to sleep
      rt2x00: bss_info_changed() callback is allowed to sleep
      rt2x00: Cleanup rt2x00mac_bss_info_changed()
      rt2x00: Fix TX status reporting
      rt2x00: Reorganize padding & L2 padding
      rt2x00: Hardcode TX ack timeout and consume time

Jan Engelhardt (22):
      net: mark read-only arrays as const
      net: implement a SO_PROTOCOL getsockoption
      net: implement a SO_DOMAIN getsockoption
      netfilter: xtables: remove xt_TOS v0
      netfilter: xtables: remove xt_CONNMARK v0
      netfilter: xtables: remove xt_MARK v0, v1
      netfilter: xtables: remove xt_connmark v0
      netfilter: xtables: remove xt_conntrack v0
      netfilter: xtables: remove xt_iprange v0
      netfilter: xtables: remove xt_mark v0
      netfilter: xtables: remove xt_owner v0
      netfilter: xtables: remove redirecting header files
      netfilter: conntrack: switch hook PFs to nfproto
      netfilter: xtables: switch hook PFs to nfproto
      netfilter: xtables: switch table AFs to nfproto
      netfilter: xtables: realign struct xt_target_param
      netfilter: iptables: remove unused datalen variable
      netfilter: xtables: use memcmp in unconditional check
      netfilter: xtables: ignore unassigned hooks in check_entry_size_a=
nd_hooks
      netfilter: xtables: check for unconditionality of policies
      netfilter: xtables: check for standard verdicts in policies
      netfilter: xtables: mark initial tables constant

Jarek Poplawski (3):
      ipv4: Use synchronize_rcu() during trie_rebalance()
      ipv4: Fix inflate_threshold_root automatically
      ipv4: fib_trie: Use tnode_get_child_rcu() and node_parent_rcu() i=
n lookups

Jaswinder Singh Rajput (5):
      net: cs89x0: includecheck fix for cs89x0.c
      net: pcmcia/axnet_cs: includecheck fix axnet_cs.c
      net: include/linux/icmpv6: includecheck fix for icmpv6.h
      net: smc911x: includecheck fix for smc911x.h
      PRISM54: fix compilation warning

Javier Cardona (12):
      mac80211: Assign next hop address to pending mesh frames
      mac80211: Fix regression in mesh forwarding path.
      mac80211: Improve dequeing from mpath frame queue.
      mac80211: Use 3-address format for mesh broadcast frames.
      mac80211: Update the station failed frames average when minstrel =
is used.
      mac80211: Early detection of broken mesh paths when using minstre=
l.
      mac80211: Assign a default mesh beaconing interval.
      mac80211: Move mpath and mpp growth to mesh workqueue.
      mac80211: Fix unresolved mesh frames queued without valid control=
=2Evif
      mac80211: Decouple fail_avg stats used by mesh from rate control =
algorithm.
      mac80211: Update mesh config IE to 11s draft 3.02
      ath9k: Add support FIF_OTHER_BSS filtering mode.

Jay Sternberg (3):
      iwlwifi: Handle new firmware file with ucode build number in head=
er
      iwlwifi: update 1000 series API version to match firmware
      iwlwifi: remove duplicated version info from sysfs

Jay Vosburgh (1):
      bonding: propogate vlan_features to bonding master

Jens L=E5=E5s (1):
      fib_trie: resize rework

Jens Rosenboom (1):
      ipv6: Log the explicit address that triggered DAD failure

Jesse Brandeburg (3):
      e1000: allow ethtool coalesece to adjust interrupts per second
      e1000: implement jumbo receive with partial descriptors
      e1000: fix flow control thresholds

Jiri Pirko (1):
      bonding: wipe out printk's

Jiri Slaby (3):
      ath5k: remove permissions from debugfs files
      ath9k: remove permissions from debugfs files
      wireless: wl12xx, fix lock imbalance

Joe Perches (17):
      drivers/net/wireless: Use PCI_VDEVICE
      drivers/net/wireless/ath/ath9k: Remove unnecessary semicolons
      MAINTAINERS: Update rtl8180 patterns
      MAINTAINERS: NETWORKING [WIRELESS] additional patterns
      MAINTAINERS: update information for sfc network driver
      lib/vsprintf.c: Add "%pI6c" - print pointer as compressed ipv6 ad=
dress
      s2io.c: Use const for strings
      s2io.c: Shorten code line length by using intermediate pointers
      s2io.c: Use calculated size in kmallocs
      s2io.c: use kzalloc
      s2io.c: Make more conforming to normal kernel style
      s2io.c: convert printks to pr_<level>
      s2io.c: fix spelling explaination
      s2io.c: Standardize statistics accessors
      s2io.c: Convert skipped nic->config.tx_cfg[i]. to tx_cfg->
      s2io: Generate complete messages using single line DBG_PRINTs
      MAINTAINERS: Add Atheros Linux wireless drivers home page

Joerg Albert (6):
      ath5k: fix missing output in monitor mode after ifconfig up
      ar9170: cleanup of bss_info_changed and beacon config
      ar9170: remove unnecessary call to ar9170_set_beacon_timers
      ar9170: added phy register initialisation from eeprom values
      ath,ar9170: move CTL_ defines into regd.h
      ath,ar9170: implemented conformance test limit calc. for tx power

Johannes Berg (151):
      cfg80211: pass netdev to change_virtual_intf
      cfg80211: issue netlink notification when scan starts
      rt2x00: remove skb->do_not_encrypt usage
      mac80211: push rx status into skb->cb
      mac80211: improve per-sta debugfs
      cfg80211: prohibit scanning the same channel more than once
      mac80211_hwsim: clean up the skb before passing it back
      cfg80211: send wext MLME-MICHAELMICFAILURE.indication
      wext: allow returning NULL stats
      mac80211: fix todo lock
      wext: default to y
      cfg80211: move break statement to correct place
      nl80211: clean up function definitions
      cfg80211: use proper allocation flags
      cfg80211: remove wireless_dev->bssid
      mac80211: tell SME about real auth state
      wext: constify extra argument to wireless_send_event
      cfg80211: introduce nl80211 testmode command
      mac80211: remove an unused function declaration
      wireless: define AKM suites
      cfg80211: emulate connect with auth/assoc
      cfg80211: managed mode wext compatibility
      cfg80211: implement iwpower
      cfg80211: implement IWAP for WDS
      cfg80211: implement IWRATE
      cfg80211: implement get_wireless_stats
      mac80211: re-add HT disabling
      mac80211: remove auth algorithm retry
      mac80211: remove dead code, clean up
      cfg80211: send events for userspace SME
      cfg80211: reset auth algorithm
      cfg80211: assimilate and export ieee80211_bss_get_ie
      cfg80211: keep track of BSSes
      cfg80211: refuse authenticating to same BSSID twice
      nl80211: limit to one pairwise cipher for associate()
      cfg80211: fix giwrange
      iwlwifi: make software queue assignment more efficient
      iwlwifi: scan requested channels only
      iwlwifi: fix aggregation limit
      rfkill: prep for rfkill API changes
      cfg80211: let SME control reassociation vs. association
      mac80211: remove dead code from mlme
      mac80211: rework MLME for multiple authentications
      mac80211: refactor the WEP code to be directly usable
      cfg80211: fix netdev down problem
      cfg80211: dont use union for wext
      cfg80211: mlme API must be able to sleep
      cfg80211: warn again on spurious deauth
      cfg80211: properly name driver locking
      cfg80211: fix MFP bug, sparse warnings
      cfg80211: fix locking
      cfg80211: clean up naming once and for all
      cfg80211: disallow configuring unsupported interfaces
      hwsim: make testmode_cmd static
      netlink: remove unused exports
      netlink: use call_rcu for netlink_change_ngroups
      net: make namespace iteration possible under RCU
      genetlink: make netns aware
      net: move and export get_net_ns_by_pid
      wireless extensions: make netns aware
      wext: optimise, comment and fix event sending
      net/compat/wext: send different messages to compat tasks
      gianfar: remove unused DECLARE_MAC_BUF
      net: explain netns notifiers a little better
      mac80211: fix sparse warning
      mac80211: driver operation debugging
      cfg80211: fix race in giwrate
      cfg80211: fix two buglets
      nl80211: introduce new key attributes
      cfg80211: rework key operation
      mac80211: fix multi-use timer
      mac80211: monitor the connection
      cfg80211: fix a locking bug
      mac80211: mesh: fix two small problems
      cfg80211: fix wext stats
      mac80211_hwsim: report fixed signal strength
      cfg80211: don't look at wdev->ssid for giwessid
      cfg80211: fix wext setting SSID
      nl80211: report BSS status
      cfg80211: fix more bugs in mlme handling
      mac80211: cancel the connection monitor timers/work
      cfg80211: fix unregistration
      iwlwifi: make some logging functions static/unexport
      wireless: remove print_mac uses
      cfg80211: don't optimise wext calls too much
      net: export __dev_addr_sync/__dev_addr_unsync
      mac80211: remove master netdev
      net: remove unused skb->do_not_encrypt
      mac80211: fix ieee80211_xmit call context
      net: deprecate print_mac
      mac80211: cooperate more with network namespaces
      cfg80211: make aware of net namespaces
      mac80211: allow using network namespaces
      mac80211: fix mlme timeouts
      mac80211: fix PS-poll response, race
      iwlwifi: fix up command sending
      iwlwifi: remove command callback return value
      cfg80211: fix circular lock dependency (1)
      mac80211: fix receiving deauth
      nl80211: add missing parameter clearing
      cfg80211: fix disassoc while not associated
      mac80211: verify info->control.vif is not NULL
      cfg80211: combine iwfreq implementations
      cfg80211: combine IWAP handlers
      cfg80211: combine IWESSID handlers
      cfg80211: self-contained wext handling where possible
      mac80211: disable software retry for now
      cfg80211: keep track of current_bss for userspace SME
      mac80211: fix sparse warnings/errors
      iwlwifi: don't export symbols not needed in other modules
      cfg80211: fix NETDEV_UNREGISTER notifier
      mac80211: fix powersave
      cfg80211: lower dynamic PS timeout to 100ms
      cfg80211: clear SSID on disconnect/no connection
      mac80211: stay authenticated after disassoc
      cfg80211: fix nl80211 disconnected events
      cfg80211: fix SME association after disassociation
      cfg80211: validate channel settings across interfaces
      cfg80211: use reassociation when possible
      nl80211: add generation number to all dumps
      mac80211: explain TX retry and status
      mac80211: document TX powersave filter requirements
      mac80211: allow DMA optimisation
      cfg80211: fix alignment problem in scan request
      iwlwifi: refactor some thermal throttle code
      iwlwifi: automatically adjust sleep level
      cfg80211: fix locking for SIWFREQ
      cfg80211: add missing device list locking
      mac80211: take statistics before encryption
      mac80211: sequence number micro-optimisation
      mac80211: small tx code cleanup
      cfg80211: check for and abort dangling scan requests
      cfg80211: allow driver to override PS default
      iwlwifi: remove unused members of iwl_ht_info
      iwlwifi: disable PS by default
      cfg80211: fix deadlock
      cfg80211: report userspace SME connected event properly
      mac80211: allow configure_filter callback to sleep
      mac80211: remove deprecated API
      cfg80211: fix dangling scan request checking
      mac80211: fix register_hw error path
      mac80211: fix configure_filter invocation after stop
      cfg80211: check lost scans later, fix bug
      cfg80211: make spurious warnings less likely, configurable
      cfg80211: clean up properly on interface type change
      mac80211: remove tasklet enable/disable
      mac80211: fix RX skb leaks
      mac80211: fix scan cancel on ifdown
      iwlwifi: fix ICT irq table endianness
      iwlwifi: use sleep interval succession
      rfkill: relicense header file

John Dykstra (1):
      tcp: Remove redundant copy of MD5 authentication key

John Linn (1):
      net: add Xilinx emac lite device driver

John W. Linville (7):
      mac80211_hwsim: fix-up build damage from removal of skb->dst
      ray_cs: remove bogus NULL check at head of ray_get_wireless_stats
      rc80211_pid_algo.c: remove unused variable declaration
      wl1271: remove print_mac usage
      libipw: switch from ieee80211_* to libipw_* naming policy
      mac80211: remove ieee80211_rx namespace hack
      libipw: initiate cfg80211 API conversion

Jouni Malinen (1):
      mac80211: Check pending scan request after having processed mgd w=
ork

Julia Lawall (18):
      drivers/net/cs89x0.c: Avoid using magic number in set_dma_mode
      drivers/net/bonding: Adjust constant name
      drivers/net: Drop unnecessary NULL test
      drivers/isdn: Drop unnecessary NULL test
      drivers/net: Correct redundant test
      net/netlabel: Correct redundant test
      drivers/atm: Correct redundant test
      drivers/net: Use DIV_ROUND_CLOSEST
      drivers/atm: Use DIV_ROUND_CLOSEST
      drivers/net/wireless: Use DIV_ROUND_CLOSEST
      net/rds: Use AF_INET for sin_family field
      drivres/net: Change constant name
      drivers/net/tokenring: Use status field rather than state field
      drivers/net: Correct use of request_region/request_mem_region
      drivers/net/wireless/ath/ath5k: Change constant name
      Bluetooth: Add missing kmalloc NULL tests to Marvell driver
      drivers/net/wan: introduce missing kfree
      drivers/net/phy: introduce missing kfree

Julius Volz (1):
      IPVS: Add handling of incoming ICMPV6 messages

Jussi Kivilinna (39):
      rndis_wlan: convert get/set frag/rts to cfg80211
      usbnet: Add stop function pointer to 'struct rndis_data'.
      rndis_wlan: convert set/get txpower to cfg80211
      usbnet: allow "minidriver" to prevent urb unlinking on usbnet_sto=
p
      rndis_wlan: stop workers on rndis_wlan_stop() and restore on rndi=
s_wlan_reset()
      rndis_wlan: clear cfg80211 scan on rndis_wlan_stop()
      rndis_wlan: reset device and restore multicast list on rndis_wlan=
_reset()
      rndis_wlan: set current packet filter to zero on stop
      rndis_wlan: add rndis_set/query_oid debugging
      rndis_host: allow rndis_wlan to see all indications
      rndis_wlan: handle 802.11 indications from device
      rndis_wlan: add missing padding to struct rndis_80211_remove_key
      rndis_wlan: rework key handling
      usbnet: add rx queue pausing
      cfg80211: export cfg80211_wext_siwfreq
      rndis_wlan: fix broken logic in add_wep_key()
      rndis_wlan: set cipher suites for cfg80211
      rndis_wlan: ignore OID_802_11_ADD_KEY triggered media connect ind=
ications
      rndis_wlan: get bssid scan list before new scan
      rndis_wlan: resize bssid list if too small
      rndis_wlan: increase scan timer delay
      rndis_wlan: move link up/down work to separate functions
      rndis_wlan: use is_zero_ether_addr() and is_broadcast_ether_addr(=
)
      rndis_wlan: set ieee80211_ptr->iftype in rndis_change_virtual_int=
f
      rndis_wlan: enable infrastructure before setting random essid
      rndis_wlan: add cfg80211 connect, disconnect, join_ibss and leave=
_ibss
      rndis_wlan: add cfg80211 set_channel
      rndis_wlan: add cfg80211 key handling
      rndis_wlan: add cfg80211 get_station
      rndis_wlan: add cfg80211 dump_station
      rndis_wlan: rename wireless stats worker to device poller
      rndis_wlan: remove unneeded SIOCSIWCOMMIT
      rndis_wlan: convert mic failure wireless event to cfg80211
      rndis_wlan: disable IWEVPMKIDCAND wireless event
      rndis_wlan: use cfg80211_wext_handler
      rndis_wlan: use bool for on/off switches
      rndis_wlan: cleanup
      rndis_wlan: fix sparse endianess warnings
      rndis_wlan: remove 'select WIRELESS_EXT' in Kconfig

Juuso Oikarinen (4):
      wl12xx: removed chipset interrupt source configuration from fw wa=
keup
      wl12xx: Moved wl1251 TX path implementation into chip specific fi=
les
      wl12xx: Add support for block reading from a fixed register addre=
ss
      wl12xx: Use chipset specific join commands

Kalle Valo (41):
      wl12xx: cmd and acx interface rework
      wl12xx: reserver buffer for read32()/write32() in struct wl12xx
      wl12xx: fix error handling in wl12xx_probe()
      wl12xx: reserve buffer for partition command in struct wl12xx
      wl12xx: allocate buffer spi read/write command buffer kzalloc()
      wl12xx: allocate buffer the spi busy word from struct wl12xx
      wl12xx: use wl12xx_mem_read32() to read the rx counter
      wl12xx: fix rx descriptor use
      wl12xx: protect wl12xx_op_set_rts_threshold()
      wl12xx: optimise elp wakeup and sleep calls
      wl12xx: check if elp wakeup failed
      wl12xx: enable ELP mode
      wl12xx: rename wl1251.c wl1251_ops.c
      wl12xx: rename driver to wl1251
      wl1251: remove wl1271_setup()
      wl1251: add wl1251 prefix to all 1251 files
      wl1251: rename wl12xx.h to wl1251.h
      wl12xx: remove unused wl12xx_hw_init_mem_config()
      wl1251: use wl1251 prefix everywhere
      wl1251: fix a checkpatch warning
      wl1251: remove accidentally added wl1251_netlink.c
      wl1251: remove wl1251_plt_start/stop()
      MAINTAINERS: add wl1251 wireless driver
      wl1251: remove fixed address support from spi commands
      wl1251: remove wl1251_ops
      wl1251: reorder wl1251_cmd_join() arguments
      wl1251: use beacon interval and dtim period provided by mac80211
      wl1251: remove wait parameter from wl1251_cmd_join()
      wl1251: initialise default channel to zero
      wl1251: add channel to wl1251_cmd_join() parameters
      wl1251: create wl1251_join()
      wl1251: fix channel setting in wl1251_op_config()
      wl1251: move wl1251_acx_wake_up_conditions() to wl1251_ps_set_mod=
e()
      wl1251: use workqueue provided by mac80211
      wl1251: rename reg.h to wl1251_reg.h
      wl1251: remove Luciano as maintainer
      wl1251: add hw scan completed debug message
      wl1251: hack to disable filters for fixing association
      iwl3945: fix compilation error in iwl3945_pass_packet_to_mac80211=
()
      wl1251: remove wl1251_ops.c
      wl1251: remove unused definitions from wl1251_reg.h

Karl Hiramoto (1):
      atm/br2684: netif_stop_queue() when atm device busy and netif_wak=
e_queue() when we can send packets again.

Karsten Keil (13):
      ISDN: Make isdnhdlc usable for other ISDN drivers
      ISDN: Clean up isdnhdlc code
      ISDN: Add support for none reverse bitstreams to isdnhdc
      ISDN: Fix isdnhdlc for one byte hdlc packets
      mISDN: Make clearing B-channel a common function
      mISDN: Add driver for Infineon ISDN chipset family
      mISDN: Driver for AVM Fritz!CARD PCI
      mISDN: Add support for Speedfax+ cards
      mISDN: Add driver for Winbond cards
      mISDN: Add support for Traverse Technologies NETJet PCI cards
      ISDN: ARRAY_SIZE changes
      mISDN: hfcmulti display real PCI ids for not supported cards
      mISDN: Fix wrong struct name in macro and clarifications

Kiran Divekar (1):
      libertas: add NULL check on return value of get_zeroed_page

Klaus-Dieter Wacker (3):
      qeth: HiperSockets SIGA retry support on CC=3D2.
      qeth: Cleanup for cast-type determination.
      qeth: display service_level info only when valid.

Krishna Kumar (5):
      net: Avoid enqueuing skb for default qdiscs
      Speed-up pfifo_fast lookup using a private bitmap
      netdevice: Consolidate to use existing macros where available.
      net: convert remaining non-symbolic return values in dev_queue_xm=
it
      pkt_sched: Fix resource limiting in pfifo_fast

Krzysztof Halasa (3):
      WAN/LMC: Fix type_trans().
      WAN: remove deprecated PCI_DEVICE_ID from PCI200SYN driver.
      IXP42x HSS support for setting internal clock rate

Larry Finger (4):
      hostap_cs: Enable shared interrupts
      p54: Eliminate unnecessary initialization
      b43: Work around mac80211 race condition
      b43legacy: Work around mac80211 race condition

Lars Ericsson (3):
      rt2x00: Don't alter rt2x00dev->default_ant
      rt2x00: Fix quality houskeeping for software diversity
      rt2x00: Fix rounding errors in RSSI average calculation

Lennert Buytenhek (33):
      mwl8k: remove various unused struct members and defines
      mwl8k: s/IEEE80211_ADDR_LEN/ETH_ALEN/g
      mwl8k: sort firmware command list by opcode, and trim unused comm=
ands
      mwl8k: various coding style cleanups
      mwl8k: remove MWL8K_RADIO_* defines
      mwl8k: remove MWL8K_RADIO_*_PREAMBLE defines
      mwl8k: remove MWL8K_WMM_* defines
      mwl8k: remove MWL8K_*_SLOTTIME defines
      mwl8k: fix mwl8k_configure_filter() parameter lifetime issue
      mwl8k: ->add_interface() is not called for monitor interfaces
      mwl8k: dma header manipulations can't fail
      mwl8k: don't touch 'command done' interrupt during firmware load
      mwl8k: don't hardcode the number of transmit queues
      mwl8k: no need to hold ->tx_lock while setting the hardware inter=
rupt mask
      mwl8k: implement idle mode
      mwl8k: mwl8k_txq_xmit() rework
      mwl8k: mwl8k_queue_work() cleanup
      mwl8k: fix firmware command serialisation
      mwl8k: get rid of mwl8k_start() workqueue use
      mwl8k: get rid of mwl8k_stop() workqueue use
      mwl8k: get rid of mwl8k_config() workqueue use
      mwl8k: get rid of mwl8k_bss_info_changed() workqueue use
      mwl8k: get rid of mwl8k_set_rts_threshold() workqueue use
      mwl8k: get rid of mwl8k_conf_tx() workqueue use
      mwl8k: get rid of mwl8k_get_stats() workqueue use
      mwl8k: get rid of mwl8k_configure_filter() workqueue use
      mwl8k: remove mwl8k_queue_work()
      mwl8k: update copyright and version number
      MAINTAINERS: add information for mwl8k wireless driver
      mwl8k: fix inverted error test in mwl8k_bss_info_changed()
      mwl8k: fix pci dma mapping leak in mwl8k_post_cmd() error path
      mwl8k: missing endian conversion when printing firmware command r=
esult
      mwl8k: separate driver and device info reporting during probe

Luciano Coelho (10):
      wl12xx: add wl12xx_spi_reg_read() and wl12xx_spi_reg_write() func=
tions
      wl12xx: moved firmware version reading routine to chip-specific f=
unctions
      wl12xx: add support for new WL1271 chip revision
      wl12xx: add support for fixed address in wl12xx_spi_read
      wl12xx: pass the wake up condition when configuring the wake up e=
vent
      wl1251: change psm enabled/disabled info to debug
      wl1271: add wl1271 driver files
      wl1271: add wl1271 to Kconfig and the Makefile
      MAINTAINERS: add information for wl1271 wireless driver
      wl1271: fix compiler warnings on 64 bit archs

Lucy Liu (1):
      ixgbe: allow vlan egress priority mapping in DCB mode

Luis Correia (1):
      rt2x00: Comment spellchecking

Luis R. Rodriguez (94):
      ath9k: differentiate quality reporting between legacy and HT conf=
igurations
      mac80211: drop frames for sta with no valid rate
      ath9k: downgrade assert in rc.c for invalid rate
      iwlwifi: remove rs_get_rate workaround
      ath9k: cleanup try count for MRR in rate control
      ath9k: remove unused min rate calculation code
      ath9k: remove unused stepdown when looking for the next rate
      ath9k: remove pointless wrapper ath_rc_rate_getidx()
      ath9k: rename ath_rc_get_nextlowervalid_txrate()
      ath9k: remove unused ath_rc_isvalid_txmask()
      ath9k: remove ATH9K_MODE_11B
      ath9k: remap ATH9K_MODE_*
      ath9k: rename ath_rc_ratefind_ht() to ath_rc_get_highest_rix()
      ath9k: remove unnecessary IEEE80211_TX_CTL_NO_ACK checks
      mac80211: make minstrel/pid RC use ieee80211_is_data(fc)
      iwlwifi: use ieee80211_is_data(fc)
      mac80211: add helper for management / no-ack frame rate decision
      ath9k: remove rate control wraper
      ath9k: disable radio when all devices are marked idle
      cfg80211: treat ieee80211_regdom hints as user hints
      ath9k: do not stop the queues in driver stop
      adm8211: remove uneeded code during suspend/resume
      ath: map TH to FCC3_WORLD
      mac80211: fix MLME issuing of probe requests while scanning
      mac80211: fix oops due to missing private data
      ath9k: remove unused ATH_PCI_VERSION
      ath9k: re-order cancelling of work on mac80211 workqueue
      ath9k: move cancel_delayed_work_sync() out of ath_deinit_leds()
      ath9k: move workqueue cancels to stop callback
      ar76c50x-usb: cancel promisc work during mac80211 stop
      at76c50x-usb: cancel scan work at stop callback
      ar9170: remove unneeded flush_workqueue()
      wext: remove extra return on wireless_nlevent_init()
      ath: depend on cfg80211
      ath: simplify kconfig dependency and add documentation
      ath: use menuconfig to put ath stuff in its own page
      ath5k: remove EXPERIMENTAL marker
      wireless: use menuconfig for WLAN_PRE80211 and WLAN_80211
      rt2x00: move experimental on kconfig only to rt2800usb
      ar9170: remove EXPERIMENTAL marker
      at76c50x-usb: remove unneeded flush_workqueue() at usb disconnect
      mac80211: redefine usage of the mac80211 workqueue
      cfg80211: use goto out on country IE reg hint failure
      cfg80211: do not iterate over rdev list on country IE hint
      cfg80211: decouple regulatory variables from cfg80211_mutex
      cfg80211: enable country IE support to all cfg80211 drivers
      iwlwifi: remove usage of orig_flags
      ath9k: remove usage of AR_SREV_*() wrapper to detect supported hw
      ath9k: use a switch for revising supported hw mac revisions
      ath9k: propagate hw initialization errors
      ath9k: move memory allocation of ath_hw to ath_init()
      ath9k: move devid cache setting to ath_init()
      ath9k: move cache setting of softc ah prior to attach
      ath9k: call hw initializer directly
      ath9k: pass only one argument to hw attach
      ath9k: move hw macrevision checker to helper
      ath9k: rename ath9k_hw_newstate() to ath9k_hw_init_defaults()
      ath9k: rename ath9k_hw_set_defaults() to ath9k_hw_init_config()
      ath9k: remove debug message for no memoery on ath_init()
      ath9k: break up hw initialization into a few more helpers
      ath9k: describe hw initialization better
      ath9k: distinguish between device initialization and ath_softc in=
it
      ath9k: remove !NULL check before kfree()
      ath9k: use helper macro to kfree and nullify on ath9k_hw_rfdetach=
()
      ath9k: rename ath9k_hw_rfdetach() to ath9k_hw_rf_free()
      ath9k: rename ath9k_hw_ani_detach() to ath9k_hw_ani_disable()
      ath9k: set ah to null after freeing
      ath9k: set sc->sc_ah to NULL after freeing it
      ath9k: call ath9k_hw_detach() once upon hw init failure
      ath9k: remove dangling error check on keycache reset on hw init
      ath9k: remove spurious check for channel on keycache reset
      ath9k: Remove _t postfix for ar9287_eeprom structure
      ath9k: add ar9271 revision and subrevision ID helpers
      ath9k: add initvals and registry definitions for AR9271
      ath9k: add initial hardware support for ar9271
      ath9k: cancel xmit poll work at stop() callback
      ath9k: fix compile warning on ath9k_hw_AR9287_check_eeprom()
      ath9k: use new FIF_PSPOLL configure filter
      zd1211rw: make it clear we don't use leds.h LED stuff
      mac80211: fix compilation of mesh (although its disabled)
      ath9k: Fix regression on receiving PS poll frames
      ath: add common ath_rxbuf_alloc() and make ath9k use it
      ath5k: use common ath.ko ath_rxbuf_alloc()
      ath5k: use bit shift operators for cache line size
      ath9k: update kconfig to indicate support for AR9002 family
      ath: move regulatory info into shared common structure
      wireless: update top level wireless driver entry
      wireless: update reg debug kconfig entry
      wireless: remove mac80211 rate selection extra menu
      ath9k: propagate ieee80211_alloc_hw() failure
      ath9k: propagate errors on ath_init_device() and request_irq()
      ath9k: claim irq for ath9k, not ath for pci
      wireless: update cfg80211 kconfig entry
      wireless: mark prism54 as deprecated and mark for removal

Luiz Augusto von Dentz (1):
      Bluetooth: Fix rejected connection not disconnecting ACL link

Maithili Hinge (1):
      libertas: Fix WEP association failure with open source wpa_suppli=
cant 0.5.10

Mallikarjuna R Chilakala (3):
      ixgbe: Fix isues while reporting 8259x backplane link capabilitie=
s
      ixgbe: refactor link setup code
      ixgbe: Patch to fix 82599 multispeed fiber link issues when drive=
r is loaded without any cable and reconnecting it to 1G partner

Marcel Holtmann (20):
      Bluetooth: Add proper shutdown support to SCO sockets
      Bluetooth: Disconnect HIDRAW devices on disconnect
      Bluetooth: Add extra device reference counting for connections
      Bluetooth: Let HIDP grab the device reference for connections
      Bluetooth: Fix Kconfig for Marvell Bluetooth driver
      Bluetooth: Fix compilation of Marvell driver without debugfs
      Bluetooth: Remove pointless ifdef protection for Marvell header f=
iles
      Bluetooth: Remove pointless casts from Marvell debugfs support
      Bluetooth: Some coding style cleanup for Marvell core driver
      Bluetooth: Fix complicated assignment of firmware for Marvell dev=
ices
      Bluetooth: Fix module description strings for Marvell driver
      Bluetooth: Remove private device name of Marvell SDIO driver
      Bluetooth: Fix Marvell driver to use skb_put and hci_opcode_pack
      Bluetooth: Fix last few compiler warning within Marvell core driv=
er
      Bluetooth: Remove Enter/Leave debug statements from Marvell drive=
r
      Bluetooth: Coding style cleanup from previous rfcomm_init bug fix
      Bluetooth: Add module option to enable L2CAP ERTM support
      Bluetooth: Allow setting of L2CAP ERTM via socket option
      Bluetooth: Add L2CAP RFC option if ERTM is enabled
      net: Add DEVTYPE support for Ethernet based devices

Marcin Slusarz (1):
      wireless: fix supported cards for rtl8187

Marcos Chaparro (1):
      ath5k: add led pin configuration for compaq c700 laptop

Marek Vasut (1):
      libertas: Add support for Marvell Libertas CF8305

Mark Kelly (2):
      r6040: remove unused pioaddr variable
      r6040: move down second PHY detection to r6040_init_one

Mark Smith (3):
      ipv6: correct return on ipv6_rcv() packet drop
      econet: use NET_RX_SUCCESS instead of magic number 0 for econet_r=
cv successful return
      Use correct NET_RX_* returns for atalk_rcv()

Matt Carlson (48):
      tg3: Fix 57780 asic rev PCIe link receiver errors
      tg3: Prevent tx BD corruption
      tg3: Fix TSO test against wrong flags var
      tg3: Preserve PCIe MPS setting for new devs
      tg3: Add 57788, remove 57720
      tg3: Tune 5785 clock switching
      tg3: Create MII_TG3_FET namespace
      tg3: Convert code to use PHY_IS_FET
      broadcom: Add BCM50610M support
      broadcom: Add AC131 phy support
      broadcom: Make the 57780 IEEE compliant
      tg3: Update version to 3.100
      tg3: Delay mdio bus init until fw finishes
      tg3: Add new 5785 10/100 only device ID
      tg3: Reformat NVRAM case statements
      tg3: Break out mini producer ring handling
      tg3: Move the JUMBO_CAPABLE and SUPPORT_MSI flags
      tg3: Clarify rx buffer relationships
      tg3: Create rx producer ring setup routines
      tg3: Create a new prodring_set structure
      tg3: Use ext rx bds
      tg3: Cleanup interrupt setup / teardown
      tg3: Move napi to per-int struct
      tg3: Convert ISR parameter to tnapi
      tg3: Convert napi handlers to use tnapi
      tg3: Move general int members to a per-int struct
      tg3: Move per-int rx members to per-int struct
      tg3: Move per-int tx members to a per-int struct
      tg3: Update version to 3.101
      tg3: inline tg3_cond_int()
      tg3: Add per-int coalesce now member
      tg3: Create tg3_rings_reset()
      tg3: Add support code around kernel interrupt API
      tg3: Add MSI-X support
      tg3: Add mailbox assignments
      tg3: Add tx and rx ring resource tracking
      tg3: Update intmbox and coal_now for msix
      tg3: Add TSS support
      tg3: Enable NAPI instances for other int vectors
      tg3: Add coalesce parameters for msix vectors
      tg3: Add RSS support
      tg3: Adjust RSS ring allocation strategies
      tg3: Assign rx ret producer indexes by vector
      tg3: Add 5717 asic rev
      tg3: Add 5717 NVRAM detection routines
      tg3: Add MDIO bus address assignments
      tg3: Update version to 3.102
      tg3: Fix return ring size breakage

Maxim Levitsky (2):
      mac80211: Retry probe request few times
      mac80211: Increase timeouts for station polling

Maxime Bizon (1):
      MIPS: BCM63XX: Add integrated ethernet PHY support for phylib.

Maximilian Engelhardt (1):
      netfilter: nf_nat: fix inverted logic for persistent NAT mappings

Michael Buesch (13):
      b43: Fix unaligned 32bit SHM-shared access
      b43: Fix hardware key index handling
      rtl818x: Add some documentation to the TX desc flags
      b43: Use a threaded IRQ handler
      b43: Remove TX spinlock
      b43: Remove DMA/PIO queue locks
      b43: Remove PIO RX workqueue
      b43: remove SHM spinlock
      ssb: Fail ssb modinit, if attach of the buses failed.
      b43: PCMCIA is not experimental anymore
      b43: Really disable QoS, if requested
      b43: Fix sparse warning in hw-tkip code
      b44/b43/b43legacy: Fix switch warnings introduced by SSB-SDIO

Michael Chan (11):
      bnx2: Zero out status block before chip reset.
      bnx2: Check if_running() before touching chip registers.
      bnx2: Close device if MTU change or ring size change fails.
      bnx2: Apply BROKEN_STATS workaround to 5706 and 5708.
      bnx2: Report FTQ discard counter.
      bnx2: Refine coalescing parameters.
      bnx2: Use const on flash_table structure.
      bnx2: Update version to 2.0.2.
      cnic: Put rx/tx ring allocation in separate function.
      cnic: Put uio init in separate function.
      bnx2: Update firmware to 5.0.0.j3.

Michael Opdenacker (1):
      Minor code cleanup in drivers/net/r6040.c

Michael S. Tsirkin (1):
      tun: reuse struct sock fields

Mikael Pettersson (1):
      mv643xx_eth.c: remove unused txq_set_wrr()

Mike Frysinger (3):
      connector: make callback argument type explicit
      connector: clean up grammar/style in documentation
      connector: get test code working by default

Mike McCormack (6):
      sky2: remove unnecessary assignment
      sky2: Avoid rewinding sky2->tx_prod
      sky2: Move tx reset functionality to sky2_tx_reset()
      sky2: Reset tx train after interrupts disabled.
      sky2: Create buffer alloc and free helpers
      sky2: Use 32bit read to read Y2_VAUX_AVAIL

Mike Rapoport (1):
      dm9000: switch to dev_pm_ops

Miklos Szeredi (1):
      net: unix: fix sending fds in multiple buffers

Mohamed Abbas (1):
      iwlwifi: Check HW ready before prepare card.

Narender Kumar (2):
      netxen: ethtool statistics and control for LRO
      netxen: bridged mode optimizations

Neil Horman (6):
      xfrm: export xfrm garbage collector thresholds via sysctl
      xfrm: select sane defaults for xfrm[4|6] gc_thresh
      net: skb ftracer - add tracepoint to skb_copy_datagram_iovec (v3)
      net: skb ftracer - Add config option to enable new ftracer (v3)
      net: skb ftracer - Add actual ftrace code to kernel (v3)
      net: drop_monitor: make last_rx timestamp private

Nick Kossifidis (5):
      ath5k: Check EEPROM before tweaking SERDES
      ath5k: Linear PCDAC code fixes
      ath5k: Wakeup fixes
      ath5k: Preserve pcicfg bits during attach
      ath5k: Use SWI to trigger calibration

Nicolas de Peslo=FCan (1):
      bonding: Fix useless test: int > INT_MAX

Octavian Purdila (1):
      tcp: fix premature termination of FIN_WAIT2 time-wait sockets

Oliver Hartkopp (2):
      can: Use WARN_ONCE() instead of BUG_ON() for sanity check in rece=
ive path
      can: use correct NET_RX_ return values

Oliver Neukum (1):
      Bluetooth: Add USB autosuspend support to btusb driver

Pat Erley (1):
      mac80211: remove max_bandwidth

Patrick McHardy (15):
      net: use NETDEV_TX_OK instead of 0 in ndo_start_xmit() functions
      net: convert remaining non-symbolic return values in ndo_start_xm=
it() functions
      Merge branch 'master' of git://dev.medozas.de/linux
      netfilter: nf_conntrack: log packets dropped by helpers
      netlink: constify nlmsghdr arguments
      netfilter: nfnetlink: constify message attributes and headers
      netfilter: ip6t_eui: fix read outside array bounds
      netfilter: ebt_ulog: fix checkentry return value
      net_sched: fix class grafting errno codes
      net_sched: make cls_ops->tcf_chain() optional
      net_sched: make cls_ops->change and cls_ops->delete optional
      net_sched: remove some unnecessary checks in classful schedulers
      net_sched: reintroduce dev->qdisc for use by sch_api
      net_sched: move dev_graft_qdisc() to sch_generic.c
      net_sched: fix estimator lock selection for mq child qdiscs

Paul Moore (1):
      tun: Remove a dead line of code

Pavel Machek (1):
      iwlwifi: fix LED config option

Pavel Roskin (6):
      ath5k: fix values for bus error bits in ISR2
      rt61pci: fix module reloading
      rt2x00: cancel all work on disconnect
      cfg80211: fix disassociation warning due to misuse of wdev->curre=
nt_bss
      ath5k: fix uninitialized value use in ath5k_eeprom_read_turbo_mod=
es()
      ath5k: don't use PCI ID to find the chip revision

Peter P Waskiewicz Jr (5):
      ixgbe: Remove legacy descriptor support
      ixgbe: Make sure boolean assignments from bitwise operations done=
 correctly
      ixgbe: Add device support for a new copper 82598 device
      ixgbe: Bump version number
      ixgbe: Properly disable DCB arbiters prior to applying changes

Petri Gynther (1):
      bonding: Have bond_check_dev_link examine netif_running

Phil Sutter (2):
      korina: fix printk formatting, add final info line
      korina: add error-handling to korina_alloc_ring

Rafael Laufer (1):
      netfilter: nf_conntrack: add SCTP support for SO_ORIGINAL_DST

Rajashekhara, Sudhakar (1):
      TI DaVinci EMAC: delay DaVinci EMAC initialization

Ralf Baechle (1):
      NET: Fix possible corruption in bpqether driver

Rami Rosen (2):
      cleanup: remove unused member in scm_cookie.
      sctp: remove unused union (sctp_cmsg_data_t) definition

Randy Dunlap (7):
      xfrm4: fix build when SYSCTLs are disabled
      trace_skb: fix build when CONFIG_NET is not enabled
      phonet: fix build when PROC_FS is disabled
      Bluetooth: Add missing selection of CONFIG_CRC16 for L2CAP layer
      ipw2200: fix kconfig dependencies
      net: fix hydra printk format warning
      netxen: build fix for INET=3Dn

Reinette Chatre (22):
      iwlagn: re-enable PS support for iwlagn
      iwlwifi: add utility to print buffer when error occurs
      iwlwifi: always print buffer when error condition occurs
      iwlwifi: fix permissions on debugfs files
      iwl3945: cleanup number of queues settings
      iwlagn: fix minimum number of queues setting
      iwlagn: do not send key clear commands when rfkill enabled
      iwlwifi: make debug level more user friendly
      iwlwifi: clarify hardware error message
      iwlwifi: inform user about rfkill state changes
      iwlwifi: print packet contents in error case
      iwlagn: fix null pointer access during ucode load on 1000
      iwlagn: fix sparse warning when compiling without debug
      iwlwifi: re-introduce per device debugging
      iwlwifi: revert uCode Alive notification with timeout
      iwlwifi: fix missing EXPORT_SYMBOL
      iwlwifi: prevent read outside array bounds
      ipw2x00: fix sparse warnings
      ipw2x00: update contact information
      MAINTAINERS: Update ipw2x00 and iwlwifi entries
      iwlwifi: fix situation in which debug message is printed
      iwl3945: reduce debug noise when default debug flags used

Roel Kluin (5):
      wireless: remove redundant tests on unsigned
      arlan: inverted logic?
      libertas: Read buffer overflow
      nl80211: jump to out_err upon unsupported iftype
      ath9k: Fix read buffer overflow

Ron Mercer (3):
      qlge: Get rid of 'default' rx_ring type.
      qlge: Allow running MSIx with fewer vectors.
      qlge: Move TX completions from workqueue to NAPI.

R=E9mi Denis-Courmont (9):
      Phonet: sockets list through proc_fs
      Phonet: account for dropped RX packets
      Phonet: dropped datagrams accounting
      f_phonet: lock-less MTU change
      f_phonet: use page-sized rather than MTU-sized RX buffers
      Phonet: fix /proc/net/phonet with network namespaces
      Phonet: fix netlink address dump error handling
      Phonet: back-end for autoconfigured addresses
      cdc-phonet: autoconfigure Phonet address

Sachin Sant (1):
      net: Fix a build break because of a typo in drivers/net/3c503.c

Samuel Ortiz (13):
      iwmc3200wifi: invalidate keys when changing the BSSID
      iwmc3200wifi: handling wifi_if_ntfy responses
      iwmc3200wifi: cfg80211 key hooks implemetation
      iwmc3200wifi: cache keys when interface is down
      cfg80211: connect/disconnect API
      cfg80211: check for current_bss from giwrate
      iwmc3200wifi: cfg80211 managed mode port
      cfg80211: Set WEP ciphers
      iwmc3200wifi: Set WEP key from connect
      iwmc3200wifi: Fix sparse warning
      iwmc3200wifi: New initial LMAC calibration
      iwmc3200wifi: Handle UMAC stalls and UMAC assert properly
      iwmc3200wifi: Add a last_fw_err debugfs entry

Sarveshwar Bandi (1):
      be2net:Creating/destroying queues regardless of netif_running() i=
n suspend/resume path

Sascha Hlusiak (1):
      sit: allow ip fragmentation when using nopmtudisc to fix package =
loss

Sathya Perla (11):
      be2net: get rid of be_ctrl_info struct/abstraction
      be2net: remove pci_func field from be_adapter struct
      be2net: replace some printks with dev_err()/dev_warn()
      be2net: some name changes for consistency
      be2net: delete unnecessary code from be_cmd_POST()
      be2net: Clear pending tx completions before destroying tx queue
      be2net: fix bad queue traversal in be_rx_q_clean()
      be2net: clear & notify residual events before destroying event qu=
eues
      be2net: Set mac addr in hw regardless of netif_running()
      be2net: refactor be_msix_(un)register() code.
      be2net: destroy mcc queue before tx queues

Scott Feldman (11):
      enic: add support for multiple BARs
      enic: workaround A0 erratum
      enic: bug fix: split TSO fragments larger than 16K into multiple =
descs
      enic: use netdev_alloc_skb
      enic: bug fix: protect fw call i/f with spinlock
      enic: bug fix: included MAC drops in rx_dropped netstat
      enic: provision for multiple Rx/Tx queues; prepare for RSS suppor=
t
      enic: bug fix: enable VLAN filtering
      enic: changes to driver/firmware interface
      enic: bug fix: check for zero port MTU before posting warning
      enic: organize device initialization/deinit into separate functio=
ns

Sebastian Haas (1):
      can: sja1000: Add support for the new 4 channel EMS CPC-PCI cards

Senthil Balasubramanian (7):
      ath9k: remove unnecessary STATION mode check.
      ath9k: stop ani when the STA gets disconnected.
      ath9k: race condition in SCANNING state check during ANI calibrat=
ion
      ath9k: Handle different TX and RX streams properly.
      ath9k: Manipulate and report the correct RSSI
      ath9k: RX stucks during heavy traffic in HT40 mode.
      ath9k: Fix TX hang issue with Atheros chipsets

Simon Horman (1):
      ipvs: Use atomic operations atomicly

Sreenivasa Honnur (9):
      vxge: Removed ioremap of unused bar addresses and their reference=
s
      vxge: Fixed memory leak by freeing memory allocated for device_co=
nfig
      vxge: check for card status before continuing in device close
      vxge: Corrected Register map entry for xmac_link registers
      vxge: Removed the code to bounds check the mss value
      vxge: Fixes in isr routine
      vxge: Disable fcs stripping.
      vxge: Printing the function's configured mode of operation
      vxge: Version update

Sridhar Samudrala (8):
      udpv4: Handle large incoming UDP/IPv4 packets and support softwar=
e UFO.
      udpv6: Fix HW checksum support for outgoing UFO packets
      udpv6: Fix gso_size setting in ip6_ufo_append_data
      udpv6: Remove unused skb argument of ipv6_select_ident()
      udpv6: Handle large incoming UDP/IPv6 packets and support softwar=
e UFO
      virtio-net: Allow UFO feature to be set and advertised.
      tun: Allow tap device to send/receive UFO packets.
      ethtool: device independent rx_csum and get_flags routines

Stefan Steuerwald (1):
      rt2x00: Implement set_tim callback for all drivers

Stefan Weil (1):
      wl12xx: fix spelling

Stephen Hemminger (59):
      vlan: allow creating vlan when real device is not up
      sky2: hold spinlock around phy_power_down
      sky2: hold RTNL when doing suspend/shutdown operations
      sky2: cleanup restart operations
      sky2: lock less transmit completion
      sky2: fix pause negotiation
      sky2: version 1.24
      sky2: remove restarting workaround flag
      sky2: use upper/lower 32 bits
      sky2: transmit ring 64 bit conservation
      sky2: simplify list element error
      sky2: dynamic size transmit ring
      sky2: optimize transmit completion
      sky2: no recycling
      sky2: version 1.25
      bonding: use compare_ether_addr
      pktgen: minor cleanup
      pktgen: change inlining
      pktgen: mark read-only/mostly variables
      pktgen: stop_device cleanup
      pktgen: xmit logic reorganization
      pktgen: cleanup clone count test
      pktgen: use netdev_alloc_skb
      pktgen: reorganize transmit loop
      pktgen: avoid calling gettimeofday
      pktgen: convert to use ktime_t
      pktgen: spin using hrtimer
      pktgen: use common idle routine
      pktgen: cleanup checkpatch warnings
      pktgen: increase version
      netdev: change transmit to limited range type
      netdev: convert pseudo-devices to netdev_tx_t
      convert ATM drivers to netdev_tx_t
      convert hamradio drivers to netdev_txreturnt_t
      isdn: convert to netdev_tx_t
      usbnet: convert to netdev_tx_t
      tokenring: convert to netdev_tx_t
      wan: convert drivers to netdev_tx_t
      hdlc: convert to netdev_tx_t
      netdev: convert pcmcia drivers to netdev_tx_t
      irda: convert to netdev_tx_t
      netdev: convert pseudo drivers to netdev_tx_t
      uwb: convert to netdev_tx_t
      tulip: convert drivers to netdev_tx_t
      3com: convert drivers to netdev_tx_t
      intel: convert drivers to netdev_tx_t
      appletalk: convert drivers to netdev_tx_t
      wireless: convert drivers to netdev_tx_t
      netdev: convert bulk of drivers to netdev_tx_t
      sky2: fix management of driver LED
      net: make neigh_ops constant
      netdev: drivers should make ethtool_ops const
      net: seq_operations should be const
      tcp: MD5 operations should be const
      inet: inet_connection_sock_af_ops const
      net: file_operations should be const
      sky2: only enable Vaux if capable of wakeup
      wan: dlci/sdla transmit return dehacking
      net: force bridge module(s) to be GPL

Stephen Rothwell (1):
      net: fix multiple definitions of setup_w6692

Steve Glendinning (1):
      smsc95xx: remove EEPROM loaded check

Sujith (31):
      mac80211: Add a few 802.11n defines for AMPDU parameters
      ath9k: Trivial fix in Kconfig
      ath9k: Fix a sparse warning
      ath9k: Remove redundant HT macros
      ath9k: Cleanup return values
      ath9k: Remove a few redundant variables/macros
      ath9k: Add debug counters for TX
      ath9k: Remove unneeded assignment of protocol field
      ath9k: Cleanup function return types
      ath9k: Try to fix whitespace damage
      ath9k: Remove a few DEBUG mesages
      ath9k: Split eeprom.c into manageable pieces
      ath9k: Cleanup ath9k_hw_4k_set_gain() interface
      ath9k: Add macros for Antenna Diversity
      ath9k: Clean antenna configuration for 4K EEPROM chips
      ath9k: Cleanup TX power calculation for 4K chips
      ath9k: Remove local chainmask variable
      ath9k: Update beacon RSSI
      ath9k: Remove has_hw_phycounters
      ath9k: Remove duplicate variables
      ath9k: Fix bug in PCI resume
      ath9k: Set HW state properly
      ath9k: Fix TX poll cancelling
      ath9k: Fix chainmask selection during scanning
      ath9k: Reduce the frequency of PA offset calibration
      ath9k: Fix bugs in programming registers during PA CAL
      ath9k: Handle PA cal usage properly
      ath9k: Update INITVALs for AR9285
      ath9k: Wrap DMA dump function with PS wakeup/restore
      ath9k: Fix RX Filter handling for BAR
      ath9k: Fix channelFlags for 2GHZ

Thadeu Lima de Souza Cascardo (2):
      trivial: fix typo in ieee802154 documentation and add it to index
      trivial: remove duplicate "different" from comment

Thomas Gleixner (1):
      Bluetooth: Convert hdev->req_lock to a mutex

Tobias Klauser (5):
      net: Rename lookup_neigh_params function
      netfilter: ebtables: Use %pM conversion specifier
      niu: Use resource_size instead of private function
      dm9000: Remove unnecessary memset of netdev private data
      dm9000: Use resource_size instead of private macro

Tomas Winkler (4):
      iwlwifi: drop sw_crypto from hw_params.
      iwlwifi: unify iwl_setup_rxon_timing
      imwc3200: move iwmc3200 SDIO ids to sdio_ids.h
      rfkill: add the GPS radio type

Tushar Gohad (1):
      IPv6/addrconf: Fix minor addrlabel thinko

Ursula Braun (1):
      qeth: display "undefined" value of sysfs-attribute "layer2"

Uwe Kleine-K=F6nig (8):
      net: move sgiseeq's probe function to .devinit.text
      net: move jazzsonic's probe function to .devinit.text
      net: move meth's probe function to .devinit.text
      net: move sb1250-mac's probe function to .devinit.text
      net: move xtsonic's probe function to .devinit.text
      net: move macsonic's probe function to .devinit.text
      fec: fix recursive locking of mii_lock
      fec: don't enable irqs in hard irq context

Vasanthakumar Thiagarajan (33):
      ath9k: Nuke unneccesary helper function to see if aggr is active
      ath9k: Remove unnecessary count for addba attempt
      ath9k: downgrade ASSERT() in ath_clone_txbuf()
      ath9k: Make sure we configure a non-zero beacon interval
      ath9k: Remove dead code in rate control
      ath9k: Remove unused members from rate control structure
      ath9k: Use probe interval instead of rssi reduce interval
      ath9k: Nuke struct ath_tx_ratectrl_state
      ath9k: Remove bogus assert in ath_clone_txbuf()
      ath9k: Handle tx desc shortage more appropriately
      ath9k: Remove pointless ath9k_ps_restore() in ath_detach()
      ath9k: Update rate control for 11NA HT40 mode
      ath9k: Maintain monotonicity of PER while going across different =
phy
      ath9k: Remove unused ath9k_hw_intrget()
      ath9k: Fix bug in retrieving average beacon rssi
      ath9k: Nuke struct ath9k_node_stats
      ath9k: Split ath9k_hw_btcoex_enable() into two logical pieces
      ath9k: Move btcoex stuff from hw.[ch] to new btcoex.[ch]
      ath9k: Configure btcoex register during every reset
      ath9k: Move btcoex related data to a separate struct
      ath9k: Determine btcoex scheme type based on chip version
      ath9k: Remove hw capability bit meant for btcoex
      ath9k: Add infrastructure for generic hw timers
      ath9k: Add Bluetooth Coexistence 3-wire support
      ath9k: Do an AHB reset before doing RTC reset
      ath9k: Move generic hw timer intr handler to bottom-half
      ath9k: Call spin_lock_bh() on btcoex_lock
      ath9k: Disable ASPM when btcoex is active
      ath9k: Remove unnecessary casting to u8 in pci_read_config_byte()=
 call
      ath9k: Store subsystem id in struct hw_version
      ath9k: Enable btcoex based on the subsystem id of the device
      ath9k: Get rid of the modparam btcoex_enable
      ath9k: Initialize the priority gpio for BT coex 3-wire

Vasu Dev (2):
      vlan: adds fcoe offload related net_device_ops and updates fcoe_d=
dp_xid field
      ixgbe: updates vlan feature flags to enable FCoE offloads on vlan=
 interface

Vidhya Govindan (1):
      wl12xx: Assign value to rx msdu lifetime variable

Vikram Kandukuri (2):
      Bluetooth: Fix missing scheduling when VIRTUAL_CABLE_UNPLUG is re=
ceived
      Bluetooth: Improve USB driver throughput by increasing the frame =
size

Vivek Natarajan (9):
      ath9k: Add AR9287 based chipsets' register information.
      ath9k: Add init values for AR9287 based chipsets.
      ath9k: Add support for AR9287 based chipsets.
      ath9k: Add open loop power control support for AR9287.
      ath9k: Set AR_WA for AR9287 as it improves consistency in through=
put.
      ath9k: Enable LEDs for AR9287 chipsets.
      ath9k: Fix ref power interpolation logic for AR9287 chipsets.
      ath9k: Updates for AR9287_12 version of chipset.
      ath9k: Reconfigure beacon timers after the scan is completed.

Vlad Yasevich (18):
      sctp: release cached route when the transport goes down.
      sctp: Disallow new connection on a closing socket
      sctp: Fix data segmentation with small frag_size
      sctp: Generate SACKs when actually sending outbound DATA
      sctp: Try to encourage SACK bundling with DATA.
      sctp: Send user messages to the lower layer as one
      sctp: Fix error count increments that were results of HEARTBEATS
      sctp: Clear fast_recovery on the transport when T3 timer expires.
      sctp: drop a_rwnd to 0 when receive buffer overflows.
      sctp: Try not to change a_rwnd when faking a SACK from SHUTDOWN.
      sctp: Nagle delay should be based on path mtu
      sctp: Don't do NAGLE delay on large writes that were fragmented s=
mall
      sctp: Fix SCTP_MAXSEG socket option to comply to spec.
      sctp: Failover transmitted list on transport delete
      sctp: Correctly track if AUTH has been bundled.
      sctp: Turn flags in 'sctp_packet' into bit fields
      sctp: Get rid of an extra routing lookup when adding a transport.
      sctp: Catch bogus stream sequence numbers

Wan ZongShun (1):
      Add support for w90p910 mac driver

Wei Yongjun (8):
      sctp: avoid overwrite the return value of sctp_process_asconf_ack=
()
      sctp: check the unrecognized ASCONF parameter before access it
      sctp: update the route for non-active transports after addresses =
are added
      sctp: drop SHUTDOWN chunk if the TSN is less than the CTSN
      sctp: fix check the chunk length of received HEARTBEAT-ACK chunk
      sctp: fix to reset packet information after packet transmit
      sctp: turn flags in 'struct sctp_association' into bit fields
      sctp: remove dup code in net/sctp/output.c

Wending Weng (1):
      Bluetooth: Fix false errors from bcsp_pkt_cull function

Wey-Yi Guy (42):
      iwlwifi: modify sensitivity value for 5150
      iwlwifi: no need to refer to max_nrg_cck range value
      iwlwifi: remove disable_tx_power for device > 4965
      iwlwifi: move show_qos to debugfs
      iwlagn: modify digital SVR for 1000
      iwlwifi: fix rx signal quality reporting in dmesg
      iwlwifi: make led functions generic
      iwlwifi: add led debugfs function
      iwlwifi: Led blinking counting both tx and rx
      iwlwifi: checking unknown HW type
      iwlwifi: uCode Alive notification with timeout
      iwlwifi: change iwl_enable/disable_interrupts to "inline"
      iwlwifi: revert to active table when rate is not valid
      iwlwifi: critical temperature enter/exit condition
      iwlwifi: Thermal Throttling Management - Part 1
      iwlwifi: Thermal Throttling Management - part 2
      iwlwifi: Thermal Throttling debugfs function
      iwlwifi: Name fix for MPDU density for TX aggregation
      iwlwifi: debugFs to enable/disable HT40 support
      iwlwifi: Distinguish power amplifier for 6000 series
      iwlwifi: remove deprecated 6000 series adapters
      iwlwifi: name changed from "fat" to "ht40"
      iwlwifi: new debugging feature for dumping data traffic
      iwlwifi: Traffic type and counter for debugFs
      iwlwifi: tx/rx queue pointer information
      iwlwifi: uCode statistics notification counter
      iwlwifi: Display sensitivity and chain noise information
      iwlwifi: fix thermal throttling locking problem
      iwlwifi: fix legacy thermal throttling power index
      iwlwifi: handle the case when set power fail
      iwlwifi: display correct critical temperature infomation
      iwlwifi: traverse linklist to find the valid OTP block
      iwlwifi: add thermal throttling support to 5150
      iwlwifi: set default tx power user limit to minimal
      iwlwifi: do not allow set tx power over channel power limit
      iwlwifi: name changes from "tx_power_channel_lmt" to "tx_power_de=
vice_lmt"
      iwlwifi: error checking for setting tx_power in sysfs
      iwlwifi: change IWL6000_UCODE_API_MAX to v4
      iwlwifi: show current tx power
      iwlwifi: remove duplicated define
      iwlwifi: read enhanced tx power info from EEPROM image
      iwlwifi: fix unloading driver while scanning

Wolfgang Denk (1):
      fs_enet/mii-fec.c: fix MII speed calculation

Wolfgang Grandegger (3):
      can: add can_free_echo_skb() for upcoming drivers
      can: sja1000: fix network statistics update
      can: sja1000: legacy SJA1000 ISA bus driver

Wu Fengguang (1):
      tcp: replace hard coded GFP_KERNEL with sk_allocation

Xiao Guangrong (1):
      drop_monitor: fix trace_napi_poll_hit()

Yeasah Pell (1):
      dm9000: add checksum offload support

Yevgeny Petrilin (3):
      mlx4_en: Adaptive moderation policy change
      mlx4_en: Using real number of rings as RSS map size
      mlx4_en: Not using Shared Receive Queues

Yi Zou (13):
      net: Add NETIF_F_FCOE_MTU to indicate support for a different MTU=
 for FCoE
      ixgbe: Add support for NETIF_F_FCOE_MTU to 82599 devices
      net: Add ndo_fcoe_enable/ndo_fcoe_disable to net_device_ops
      vlan: Add support for net_devices_ops.ndo_fcoe_enable/_disable to=
 VLAN
      ixgbe: Add support for the net_device_ops.ndo_fcoe_enable/disable=
 to 82599
      dcbnl: Add support for setapp/getapp commands to dcbnl
      dcbnl: Add support for setapp/getapp to netdev dcbnl_rtnl_ops
      dcbnl: Add netlink attributes for setapp/getapp to dcbnl
      dcbnl: Add implementations of dcbnl setapp/getapp commands
      ixgbe: Add support for dcbnl_rtnl_ops.setapp/getapp
      ixgbe: Add support for multiple Tx queues for FCoE in 82599
      ixgbe: Distribute transmission of FCoE traffic in 82599
      ixgbe: Add support for using FCoE DDP in 82599 as FCoE targets

Yoshihiro Shimoda (1):
      net: sh_eth: add value of ether_link pin in platform_data

Zhu Yi (30):
      iwmc3200wifi: change coexist periodic calibration flag
      iwmc3200wifi: rfkill cleanup
      iwmc3200wifi: replace netif_rx with netif_rx_ni
      iwmc3200wifi: simplify calibration map
      iwmc3200wifi: remove B0 hardware support
      cfg80211: fix NULL dereference in IBSS SIOCGIWAP
      iwmc3200wifi: fix UMAC INIT_COMPLETE notification handling
      iwmc3200wifi: hardware does not support IP checksum
      iwmc3200wifi: set cipher_suites before registering wiphy
      iwmc3200wifi: use correct debug level
      iwmc3200wifi: remove setting WEP keys before setting essid suppor=
t
      iwmc3200wifi: make iwm_send_wifi_if_cmd return 0 on success
      iwmc3200wifi: remove key caches in driver
      cfg80211: remove WARN_ON in __cfg80211_sme_scan_done
      cfg80211: set_default_key only for WEP
      cfg80211: fix typo of IWEVASSOCRESPIE
      iwmc3200wifi: use cfg80211_connect_result to send req/resp IE
      iwmc3200wifi: fix cfg80211_connect_result is called in IBSS
      iwmc3200wifi: fix a use-after-free bug
      cfg80211: avoid setting default_key if add_key fails
      iwmc3200wifi: fix set_wpa_version and set_auth_type order
      iwmc3200wifi: set WEP key static flag correctly
      iwmc3200wifi: avoid setting default key for 802.1X and RSNA
      wireless: display wext SSID when connected by cfg80211
      iwlwifi: cleanup HT40 extension channels setup
      cfg80211: allow cfg80211_connect_result with bssid =3D=3D NULL
      iwmc3200wifi: invalidate profile when necessary before connect
      iwmc3200wifi: use cfg80211_roamed to send roam event
      iwmc3200wifi: add disconnect work
      iwmc3200wifi: fix misuse of le16_to_cpu

fran=E7ois romieu (6):
      r8169: fix r8101 quirk dupe
      r8169: differentiate close chipsets in the startup identification=
 message
      r8169: phy init for the 8169sce
      r8169: phy init for the 8169scd
      r8169: phy init for the 8169s
      r8169: phy init for the 8102e

gregor kowski (3):
      b43: remove wrong probe_resp_plcp write
      b43: remove wrong probe_resp_plcp write
      b43: add hardware tkip

oscar.medina@motorola.com (1):
      tipc: Add socket options to get number of queued messages

roel kluin (6):
      b44: strncpy does not null terminate string
      lmc: Read outside array bounds
      tipc: fix test of bearer_priority range in tipc_register_media()
      WAN: bit and/or confusion
      au1000_eth: possible NULL dereference of aup->mii_bus->irq in au1=
000_probe()
      WARNING: some request_irq() failures ignored in el2_open()

sarveshwarb (1):
      be2net: Patch to perform function reset at initialization

 Documentation/00-INDEX                             |    2 +
 Documentation/btmrvl.txt                           |  119 +
 Documentation/connector/Makefile                   |    5 +
 Documentation/connector/cn_test.c                  |   33 +-
 Documentation/connector/connector.txt              |  119 +-
 Documentation/connector/ucon.c                     |   62 +-
 Documentation/feature-removal-schedule.txt         |   54 +-
 Documentation/kernel-parameters.txt                |    5 +
 Documentation/networking/00-INDEX                  |    2 +
 Documentation/networking/ieee802154.txt            |   20 +-
 Documentation/networking/ip-sysctl.txt             |   47 +-
 MAINTAINERS                                        |   52 +-
 arch/alpha/include/asm/socket.h                    |    2 +
 arch/arm/include/asm/socket.h                      |    3 +
 arch/arm/mach-ixp4xx/common.c                      |    1 +
 arch/avr32/include/asm/socket.h                    |    3 +
 arch/cris/include/asm/socket.h                     |    3 +
 arch/frv/include/asm/socket.h                      |    3 +
 arch/h8300/include/asm/socket.h                    |    3 +
 arch/ia64/hp/sim/simeth.c                          |    2 +-
 arch/ia64/include/asm/socket.h                     |    3 +
 arch/m32r/include/asm/socket.h                     |    3 +
 arch/m68k/include/asm/socket.h                     |    3 +
 arch/mips/ar7/platform.c                           |   15 +
 arch/mips/include/asm/socket.h                     |    2 +
 arch/mips/kernel/scall64-n32.S                     |    2 +-
 arch/mips/kernel/scall64-o32.S                     |    4 +-
 arch/mn10300/include/asm/socket.h                  |    3 +
 arch/parisc/include/asm/socket.h                   |    2 +
 arch/powerpc/include/asm/qe.h                      |    1 +
 arch/powerpc/include/asm/socket.h                  |    3 +
 arch/powerpc/sysdev/qe_lib/qe.c                    |   13 +
 arch/s390/include/asm/socket.h                     |    3 +
 arch/sh/include/asm/sh_eth.h                       |    3 +
 arch/sparc/include/asm/socket.h                    |    3 +
 arch/sparc/kernel/sys32.S                          |    2 +-
 arch/um/drivers/net_kern.c                         |    4 +-
 arch/x86/include/asm/socket.h                      |    3 +
 arch/xtensa/include/asm/socket.h                   |    3 +
 arch/xtensa/platforms/iss/network.c                |    2 +-
 drivers/atm/horizon.c                              |    4 +-
 drivers/atm/solos-pci.c                            |    2 +-
 drivers/bluetooth/Kconfig                          |   25 +
 drivers/bluetooth/Makefile                         |    6 +
 drivers/bluetooth/btmrvl_debugfs.c                 |  432 +
 drivers/bluetooth/btmrvl_drv.h                     |  139 +
 drivers/bluetooth/btmrvl_main.c                    |  624 +
 drivers/bluetooth/btmrvl_sdio.c                    | 1003 ++
 drivers/bluetooth/btmrvl_sdio.h                    |  108 +
 drivers/bluetooth/btusb.c                          |  198 +-
 drivers/bluetooth/hci_bcsp.c                       |    3 +-
 drivers/char/pcmcia/synclink_cs.c                  |    7 +-
 drivers/char/synclink.c                            |    7 +-
 drivers/char/synclink_gt.c                         |    7 +-
 drivers/char/synclinkmp.c                          |    7 +-
 drivers/connector/cn_proc.c                        |    3 +-
 drivers/connector/cn_queue.c                       |    7 +-
 drivers/connector/connector.c                      |    6 +-
 drivers/firewire/net.c                             |    6 +-
 drivers/ieee1394/eth1394.c                         |   19 +-
 drivers/ieee802154/fakehard.c                      |  191 +-
 drivers/infiniband/hw/amso1100/c2.c                |    1 -
 drivers/infiniband/hw/nes/nes_hw.c                 |    2 +-
 drivers/infiniband/hw/nes/nes_nic.c                |    2 +-
 drivers/infiniband/ulp/ipoib/ipoib_cm.c            |    1 -
 drivers/infiniband/ulp/ipoib/ipoib_ib.c            |    1 -
 drivers/isdn/Kconfig                               |    6 +-
 drivers/isdn/act2000/capi.c                        |    3 +-
 drivers/isdn/act2000/module.c                      |   31 +-
 drivers/isdn/hardware/eicon/message.c              |    4 +-
 drivers/isdn/hardware/eicon/os_4bri.c              |    3 +-
 drivers/isdn/hardware/mISDN/Kconfig                |   51 +
 drivers/isdn/hardware/mISDN/Makefile               |    8 +
 drivers/isdn/hardware/mISDN/avmfritz.c             | 1152 ++
 drivers/isdn/hardware/mISDN/hfcmulti.c             |   23 +-
 drivers/isdn/hardware/mISDN/hfcpci.c               |   16 +-
 drivers/isdn/hardware/mISDN/hfcsusb.c              |   16 +-
 drivers/isdn/hardware/mISDN/iohelper.h             |  109 +
 drivers/isdn/hardware/mISDN/ipac.h                 |  405 +
 drivers/isdn/hardware/mISDN/isar.h                 |  269 +
 drivers/isdn/hardware/mISDN/mISDNinfineon.c        | 1178 ++
 drivers/isdn/hardware/mISDN/mISDNipac.c            | 1655 +++
 drivers/isdn/hardware/mISDN/mISDNisar.c            | 1726 +++
 drivers/isdn/hardware/mISDN/netjet.c               | 1156 ++
 drivers/isdn/hardware/mISDN/netjet.h               |   58 +
 drivers/isdn/hardware/mISDN/speedfax.c             |  526 +
 drivers/isdn/hardware/mISDN/w6692.c                | 1440 +++
 drivers/isdn/hardware/mISDN/w6692.h                |  190 +
 drivers/isdn/hisax/Kconfig                         |    6 +-
 drivers/isdn/hisax/Makefile                        |    4 -
 drivers/isdn/hisax/amd7930_fn.c                    |    2 -
 drivers/isdn/hisax/callc.c                         |    4 +-
 drivers/isdn/hisax/hfc_pci.c                       |    2 -
 drivers/isdn/hisax/hfc_sx.c                        |    2 -
 drivers/isdn/hisax/icc.c                           |    2 -
 drivers/isdn/hisax/isac.c                          |    2 -
 drivers/isdn/hisax/isdnhdlc.h                      |   70 -
 drivers/isdn/hisax/isdnl1.c                        |   12 +-
 drivers/isdn/hisax/isdnl2.c                        |    4 +-
 drivers/isdn/hisax/isdnl3.c                        |    4 +-
 drivers/isdn/hisax/l3_1tr6.c                       |   20 +-
 drivers/isdn/hisax/l3dss1.c                        |   26 +-
 drivers/isdn/hisax/l3ni1.c                         |   26 +-
 drivers/isdn/hisax/q931.c                          |   24 +-
 drivers/isdn/hisax/st5481.h                        |    2 +-
 drivers/isdn/hisax/st5481_b.c                      |    5 +-
 drivers/isdn/hisax/st5481_d.c                      |    2 +-
 drivers/isdn/hisax/st5481_usb.c                    |   11 +-
 drivers/isdn/hisax/tei.c                           |    4 +-
 drivers/isdn/hisax/w6692.c                         |    2 -
 drivers/isdn/hysdn/hysdn_net.c                     |    4 +-
 drivers/isdn/i4l/Kconfig                           |   11 +
 drivers/isdn/i4l/Makefile                          |    1 +
 drivers/isdn/i4l/isdn_net.c                        |   21 +-
 drivers/isdn/i4l/isdn_ppp.c                        |    6 +-
 drivers/isdn/{hisax =3D> i4l}/isdnhdlc.c             |  429 +-
 drivers/isdn/mISDN/hwchannel.c                     |   15 +-
 drivers/isdn/mISDN/layer2.c                        |    2 -
 drivers/media/dvb/dvb-core/dvb_net.c               |    2 +-
 drivers/message/fusion/mptlan.c                    |    2 +-
 drivers/misc/sgi-xp/xpnet.c                        |    5 +-
 drivers/net/3c501.c                                |    4 +-
 drivers/net/3c501.h                                |    2 +-
 drivers/net/3c503.c                                |   10 +-
 drivers/net/3c505.c                                |    6 +-
 drivers/net/3c507.c                                |    8 +-
 drivers/net/3c509.c                                |    6 +-
 drivers/net/3c515.c                                |   12 +-
 drivers/net/3c523.c                                |    6 +-
 drivers/net/3c527.c                                |   10 +-
 drivers/net/3c59x.c                                |   14 +-
 drivers/net/7990.c                                 |    2 +-
 drivers/net/8139cp.c                               |    5 +-
 drivers/net/8139too.c                              |   11 +-
 drivers/net/82596.c                                |    9 +-
 drivers/net/8390.c                                 |    2 +-
 drivers/net/8390.h                                 |    4 +-
 drivers/net/8390p.c                                |    2 +-
 drivers/net/Kconfig                                |   13 +-
 drivers/net/Makefile                               |    1 +
 drivers/net/a2065.c                                |    7 +-
 drivers/net/acenic.c                               |    3 +-
 drivers/net/acenic.h                               |    3 +-
 drivers/net/amd8111e.c                             |    8 +-
 drivers/net/appletalk/cops.c                       |    8 +-
 drivers/net/appletalk/ipddp.c                      |   12 +-
 drivers/net/appletalk/ltpc.c                       |    6 +-
 drivers/net/arcnet/arcnet.c                        |    3 +-
 drivers/net/ariadne.c                              |   10 +-
 drivers/net/arm/am79c961a.c                        |    2 +-
 drivers/net/arm/at91_ether.c                       |    2 +-
 drivers/net/arm/ep93xx_eth.c                       |    2 +-
 drivers/net/arm/ether1.c                           |    2 +-
 drivers/net/arm/ether3.c                           |    4 +-
 drivers/net/arm/ixp4xx_eth.c                       |    2 +-
 drivers/net/arm/ks8695net.c                        |    3 +-
 drivers/net/arm/w90p910_ether.c                    |  207 +-
 drivers/net/at1700.c                               |    8 +-
 drivers/net/atarilance.c                           |    4 +-
 drivers/net/atl1c/atl1c_ethtool.c                  |    2 +-
 drivers/net/atl1c/atl1c_main.c                     |   15 +-
 drivers/net/atl1e/atl1e_ethtool.c                  |    2 +-
 drivers/net/atl1e/atl1e_main.c                     |   14 +-
 drivers/net/atlx/atl1.c                            |    3 +-
 drivers/net/atlx/atl2.c                            |    9 +-
 drivers/net/atp.c                                  |    8 +-
 drivers/net/au1000_eth.c                           |    7 +-
 drivers/net/b44.c                                  |   23 +-
 drivers/net/benet/Kconfig                          |    1 -
 drivers/net/benet/be.h                             |   64 +-
 drivers/net/benet/be_cmds.c                        |  421 +-
 drivers/net/benet/be_cmds.h                        |   77 +-
 drivers/net/benet/be_ethtool.c                     |   38 +-
 drivers/net/benet/be_hw.h                          |   88 +-
 drivers/net/benet/be_main.c                        |  758 +-
 drivers/net/bfin_mac.c                             |    4 +-
 drivers/net/bmac.c                                 |    2 +-
 drivers/net/bnx2.c                                 |  112 +-
 drivers/net/bnx2.h                                 |    3 +-
 drivers/net/bnx2x.h                                |  128 +-
 drivers/net/bnx2x_dump.h                           |  890 +-
 drivers/net/bnx2x_fw_defs.h                        |  379 +-
 drivers/net/bnx2x_hsi.h                            |  435 +-
 drivers/net/bnx2x_init.h                           |  320 +-
 drivers/net/bnx2x_init_ops.h                       |  419 +-
 drivers/net/bnx2x_link.c                           | 2578 +++--
 drivers/net/bnx2x_link.h                           |   63 +-
 drivers/net/bnx2x_main.c                           | 2326 +++--
 drivers/net/bnx2x_reg.h                            | 1065 +--
 drivers/net/bonding/bond_3ad.c                     |  101 +-
 drivers/net/bonding/bond_alb.c                     |   99 +-
 drivers/net/bonding/bond_ipv6.c                    |    4 +-
 drivers/net/bonding/bond_main.c                    |   33 +-
 drivers/net/bonding/bond_sysfs.c                   |   63 +-
 drivers/net/bonding/bonding.h                      |    2 +-
 drivers/net/can/Kconfig                            |   14 +-
 drivers/net/can/dev.c                              |   19 +-
 drivers/net/can/sja1000/Makefile                   |    1 +
 drivers/net/can/sja1000/ems_pci.c                  |  152 +-
 drivers/net/can/sja1000/sja1000.c                  |   12 +-
 drivers/net/can/sja1000/sja1000_isa.c              |  281 +
 drivers/net/can/vcan.c                             |    2 +-
 drivers/net/cassini.c                              |   10 +-
 drivers/net/chelsio/sge.c                          |    2 +-
 drivers/net/chelsio/sge.h                          |    2 +-
 drivers/net/cnic.c                                 |   79 +-
 drivers/net/cpmac.c                                |   44 +-
 drivers/net/cris/eth_v10.c                         |    2 +-
 drivers/net/cs89x0.c                               |   11 +-
 drivers/net/cxgb3/adapter.h                        |   12 +-
 drivers/net/cxgb3/ael1002.c                        | 1193 +--
 drivers/net/cxgb3/aq100x.c                         |    7 +-
 drivers/net/cxgb3/common.h                         |   10 +
 drivers/net/cxgb3/cxgb3_main.c                     |   99 +-
 drivers/net/cxgb3/sge.c                            |    2 +-
 drivers/net/cxgb3/t3_hw.c                          |   19 +-
 drivers/net/cxgb3/xgmac.c                          |   11 +-
 drivers/net/davinci_emac.c                         |    3 +-
 drivers/net/de600.c                                |    2 +-
 drivers/net/de620.c                                |    2 +-
 drivers/net/declance.c                             |    4 +-
 drivers/net/defxx.c                                |   16 +-
 drivers/net/depca.c                                |    8 +-
 drivers/net/dl2k.c                                 |    4 +-
 drivers/net/dm9000.c                               |  134 +-
 drivers/net/dm9000.h                               |   18 +
 drivers/net/dnet.c                                 |    4 +-
 drivers/net/dummy.c                                |   22 +-
 drivers/net/e100.c                                 |    5 +-
 drivers/net/e1000/e1000.h                          |    7 +-
 drivers/net/e1000/e1000_ethtool.c                  |   51 +-
 drivers/net/e1000/e1000_hw.c                       |   48 +-
 drivers/net/e1000/e1000_hw.h                       |    3 -
 drivers/net/e1000/e1000_main.c                     |  504 +-
 drivers/net/e1000e/netdev.c                        |    5 +-
 drivers/net/eepro.c                                |   10 +-
 drivers/net/eexpress.c                             |    9 +-
 drivers/net/enc28j60.c                             |    5 +-
 drivers/net/enic/enic.h                            |   25 +-
 drivers/net/enic/enic_main.c                       |  379 +-
 drivers/net/enic/enic_res.c                        |   33 +-
 drivers/net/enic/enic_res.h                        |    2 +
 drivers/net/enic/vnic_dev.c                        |   74 +-
 drivers/net/enic/vnic_dev.h                        |   14 +-
 drivers/net/enic/vnic_devcmd.h                     |   20 +-
 drivers/net/enic/vnic_intr.c                       |    5 +
 drivers/net/enic/vnic_nic.h                        |    7 +
 drivers/net/enic/vnic_rq.c                         |   27 +-
 drivers/net/enic/vnic_rq.h                         |   19 +-
 drivers/net/enic/vnic_wq.c                         |   20 +-
 drivers/net/enic/vnic_wq.h                         |    4 +
 drivers/net/epic100.c                              |    9 +-
 drivers/net/eql.c                                  |    6 +-
 drivers/net/eth16i.c                               |    8 +-
 drivers/net/ethoc.c                                |    5 +-
 drivers/net/ewrk3.c                                |    6 +-
 drivers/net/fealnx.c                               |    6 +-
 drivers/net/fec.c                                  |   36 +-
 drivers/net/forcedeth.c                            |    5 +-
 drivers/net/fs_enet/mii-fec.c                      |   37 +-
 drivers/net/gianfar.c                              |    1 -
 drivers/net/hamachi.c                              |    8 +-
 drivers/net/hamradio/6pack.c                       |    4 +-
 drivers/net/hamradio/baycom_epp.c                  |    6 +-
 drivers/net/hamradio/bpqether.c                    |   30 +-
 drivers/net/hamradio/dmascc.c                      |    2 +-
 drivers/net/hamradio/hdlcdrv.c                     |    7 +-
 drivers/net/hamradio/mkiss.c                       |    4 +-
 drivers/net/hamradio/scc.c                         |   11 +-
 drivers/net/hamradio/yam.c                         |    5 +-
 drivers/net/hp100.c                                |   19 +-
 drivers/net/hydra.c                                |    4 +-
 drivers/net/ibm_newemac/core.c                     |   17 +-
 drivers/net/ibmlana.c                              |    2 +-
 drivers/net/ibmveth.c                              |    5 +-
 drivers/net/ifb.c                                  |    9 +-
 drivers/net/igb/e1000_82575.c                      |  193 +-
 drivers/net/igb/e1000_82575.h                      |    6 +-
 drivers/net/igb/e1000_defines.h                    |    8 +
 drivers/net/igb/e1000_hw.h                         |   18 +-
 drivers/net/igb/e1000_mac.c                        |  175 +-
 drivers/net/igb/e1000_mac.h                        |    3 +
 drivers/net/igb/e1000_phy.c                        |    4 +-
 drivers/net/igb/e1000_regs.h                       |    1 +
 drivers/net/igb/igb.h                              |    1 +
 drivers/net/igb/igb_ethtool.c                      |   67 +-
 drivers/net/igb/igb_main.c                         |  267 +-
 drivers/net/igbvf/netdev.c                         |   26 +-
 drivers/net/ioc3-eth.c                             |    2 +-
 drivers/net/ipg.c                                  |    5 +-
 drivers/net/irda/ali-ircc.c                        |   24 +-
 drivers/net/irda/au1k_ir.c                         |    4 +-
 drivers/net/irda/donauboe.c                        |   10 +-
 drivers/net/irda/irda-usb.c                        |    8 +-
 drivers/net/irda/kingsun-sir.c                     |    5 +-
 drivers/net/irda/ks959-sir.c                       |    3 +-
 drivers/net/irda/ksdazzle-sir.c                    |    3 +-
 drivers/net/irda/mcs7780.c                         |    3 +-
 drivers/net/irda/mcs7780.h                         |    3 +-
 drivers/net/irda/nsc-ircc.c                        |   22 +-
 drivers/net/irda/pxaficp_ir.c                      |    4 +-
 drivers/net/irda/sa1100_ir.c                       |    4 +-
 drivers/net/irda/sir_dev.c                         |    9 +-
 drivers/net/irda/smsc-ircc2.c                      |   31 +-
 drivers/net/irda/stir4200.c                        |    5 +-
 drivers/net/irda/via-ircc.c                        |   28 +-
 drivers/net/irda/vlsi_ir.c                         |    9 +-
 drivers/net/irda/w83977af_ir.c                     |   10 +-
 drivers/net/isa-skeleton.c                         |    2 +-
 drivers/net/iseries_veth.c                         |    4 +-
 drivers/net/ixgb/ixgb_main.c                       |   12 +-
 drivers/net/ixgbe/ixgbe.h                          |   45 +-
 drivers/net/ixgbe/ixgbe_82598.c                    |   56 +-
 drivers/net/ixgbe/ixgbe_82599.c                    |  285 +-
 drivers/net/ixgbe/ixgbe_common.c                   |    3 +-
 drivers/net/ixgbe/ixgbe_common.h                   |    1 -
 drivers/net/ixgbe/ixgbe_dcb_82599.c                |   21 +-
 drivers/net/ixgbe/ixgbe_dcb_nl.c                   |  116 +-
 drivers/net/ixgbe/ixgbe_ethtool.c                  |   56 +-
 drivers/net/ixgbe/ixgbe_fcoe.c                     |  166 +-
 drivers/net/ixgbe/ixgbe_fcoe.h                     |    4 +
 drivers/net/ixgbe/ixgbe_main.c                     |  100 +-
 drivers/net/ixgbe/ixgbe_type.h                     |   39 +-
 drivers/net/ixp2000/ixpdev.c                       |    4 +-
 drivers/net/jazzsonic.c                            |   10 +-
 drivers/net/jme.c                                  |  191 +-
 drivers/net/jme.h                                  |   21 +-
 drivers/net/korina.c                               |   46 +-
 drivers/net/ks8842.c                               |    5 +-
 drivers/net/ks8851.c                               |    5 +-
 drivers/net/lance.c                                |    8 +-
 drivers/net/lib82596.c                             |    4 +-
 drivers/net/lib8390.c                              |    5 +-
 drivers/net/ll_temac_main.c                        |    2 +-
 drivers/net/loopback.c                             |    5 +-
 drivers/net/lp486e.c                               |    8 +-
 drivers/net/mac89x0.c                              |    2 +-
 drivers/net/macb.c                                 |    4 +-
 drivers/net/mace.c                                 |    2 +-
 drivers/net/macvlan.c                              |   42 +-
 drivers/net/mdio.c                                 |   16 +-
 drivers/net/meth.c                                 |    4 +-
 drivers/net/mii.c                                  |    3 -
 drivers/net/mipsnet.c                              |    2 +-
 drivers/net/mlx4/en_main.c                         |    5 +-
 drivers/net/mlx4/en_netdev.c                       |   18 +-
 drivers/net/mlx4/en_resources.c                    |    9 +-
 drivers/net/mlx4/en_rx.c                           |  111 +-
 drivers/net/mlx4/en_tx.c                           |    8 +-
 drivers/net/mlx4/mlx4_en.h                         |   19 +-
 drivers/net/mv643xx_eth.c                          |   34 -
 drivers/net/myri10ge/myri10ge.c                    |   84 +-
 drivers/net/myri_sbus.c                            |    2 +-
 drivers/net/natsemi.c                              |   11 +-
 drivers/net/netx-eth.c                             |    2 +-
 drivers/net/netxen/Makefile                        |    9 +-
 drivers/net/netxen/netxen_nic.h                    |  572 +-
 drivers/net/netxen/netxen_nic_ctx.c                |  116 +-
 drivers/net/netxen/netxen_nic_ethtool.c            |  123 +-
 drivers/net/netxen/netxen_nic_hdr.h                |  125 +-
 drivers/net/netxen/netxen_nic_hw.c                 |  854 +-
 drivers/net/netxen/netxen_nic_hw.h                 |  132 +-
 drivers/net/netxen/netxen_nic_init.c               |  400 +-
 drivers/net/netxen/netxen_nic_main.c               | 1462 ++-
 drivers/net/netxen/netxen_nic_niu.c                |  550 -
 drivers/net/netxen/netxen_nic_phan_reg.h           |  178 -
 drivers/net/ni5010.c                               |    2 +-
 drivers/net/ni52.c                                 |    9 +-
 drivers/net/ni65.c                                 |    8 +-
 drivers/net/niu.c                                  |   28 +-
 drivers/net/ns83820.c                              |    3 +-
 drivers/net/pci-skeleton.c                         |    7 +-
 drivers/net/pcmcia/3c574_cs.c                      |   23 +-
 drivers/net/pcmcia/3c589_cs.c                      |    8 +-
 drivers/net/pcmcia/axnet_cs.c                      |   21 +-
 drivers/net/pcmcia/fmvj18x_cs.c                    |   10 +-
 drivers/net/pcmcia/nmclan_cs.c                     |    8 +-
 drivers/net/pcmcia/pcnet_cs.c                      |   11 +-
 drivers/net/pcmcia/smc91c92_cs.c                   |   12 +-
 drivers/net/pcmcia/xirc2ps_cs.c                    |   24 +-
 drivers/net/pcnet32.c                              |    8 +-
 drivers/net/phy/Kconfig                            |    6 +
 drivers/net/phy/Makefile                           |    1 +
 drivers/net/phy/bcm63xx.c                          |  132 +
 drivers/net/phy/broadcom.c                         |  233 +-
 drivers/net/phy/marvell.c                          |   21 +-
 drivers/net/phy/mdio-gpio.c                        |    2 +-
 drivers/net/phy/phy.c                              |    3 -
 drivers/net/plip.c                                 |    2 +-
 drivers/net/ppp_generic.c                          |    7 +-
 drivers/net/pppoe.c                                |   22 +-
 drivers/net/ps3_gelic_net.c                        |    2 +-
 drivers/net/ps3_gelic_wireless.c                   |    2 +-
 drivers/net/qla3xxx.c                              |    3 +-
 drivers/net/qlge/qlge.h                            |   11 +-
 drivers/net/qlge/qlge_dbg.c                        |    2 -
 drivers/net/qlge/qlge_ethtool.c                    |   16 +-
 drivers/net/qlge/qlge_main.c                       |  396 +-
 drivers/net/r6040.c                                |   33 +-
 drivers/net/r8169.c                                |  260 +-
 drivers/net/rionet.c                               |    7 +-
 drivers/net/rrunner.c                              |    5 +-
 drivers/net/rrunner.h                              |    3 +-
 drivers/net/s2io.c                                 | 3597 +++---
 drivers/net/s2io.h                                 |    5 +-
 drivers/net/sb1000.c                               |    7 +-
 drivers/net/sb1250-mac.c                           |    4 +-
 drivers/net/sc92031.c                              |    3 +-
 drivers/net/seeq8005.c                             |   10 +-
 drivers/net/sfc/efx.c                              |   28 +-
 drivers/net/sfc/efx.h                              |    5 +-
 drivers/net/sfc/ethtool.c                          |    2 +-
 drivers/net/sfc/ethtool.h                          |    2 +-
 drivers/net/sfc/falcon_hwdefs.h                    |    2 +
 drivers/net/sfc/falcon_xmac.c                      |    8 +-
 drivers/net/sfc/net_driver.h                       |    7 +-
 drivers/net/sfc/selftest.c                         |    3 +-
 drivers/net/sfc/tx.c                               |   18 +-
 drivers/net/sfc/tx.h                               |    3 +-
 drivers/net/sfc/xfp_phy.c                          |   19 +-
 drivers/net/sgiseeq.c                              |    6 +-
 drivers/net/sh_eth.c                               |    8 +-
 drivers/net/sh_eth.h                               |    3 +
 drivers/net/sis190.c                               |    3 +-
 drivers/net/sis900.c                               |    9 +-
 drivers/net/skfp/skfddi.c                          |   10 +-
 drivers/net/skge.c                                 |    6 +-
 drivers/net/sky2.c                                 |  603 +-
 drivers/net/sky2.h                                 |   34 +-
 drivers/net/slip.c                                 |    8 +-
 drivers/net/smc911x.c                              |    6 +-
 drivers/net/smc911x.h                              |    1 -
 drivers/net/smc9194.c                              |   14 +-
 drivers/net/smc91x.c                               |    4 +-
 drivers/net/smsc911x.c                             |   32 +-
 drivers/net/smsc9420.c                             |    4 +-
 drivers/net/sonic.c                                |    4 +-
 drivers/net/starfire.c                             |    6 +-
 drivers/net/sun3_82586.c                           |    4 +-
 drivers/net/sun3lance.c                            |    4 +-
 drivers/net/sunbmac.c                              |    2 +-
 drivers/net/sundance.c                             |    6 +-
 drivers/net/sungem.c                               |    7 +-
 drivers/net/sunhme.c                               |    5 +-
 drivers/net/sunlance.c                             |    2 +-
 drivers/net/sunqe.c                                |    2 +-
 drivers/net/tc35815.c                              |   79 +-
 drivers/net/tehuti.c                               |    5 +-
 drivers/net/tg3.c                                  | 2389 +++--
 drivers/net/tg3.h                                  |  223 +-
 drivers/net/tlan.c                                 |   12 +-
 drivers/net/tokenring/3c359.c                      |    6 +-
 drivers/net/tokenring/ibmtr.c                      |    8 +-
 drivers/net/tokenring/lanstreamer.c                |    8 +-
 drivers/net/tokenring/olympic.c                    |    8 +-
 drivers/net/tokenring/smctr.c                      |   44 +-
 drivers/net/tokenring/tms380tr.c                   |   21 +-
 drivers/net/tulip/de2104x.c                        |    5 +-
 drivers/net/tulip/de4x5.c                          |   11 +-
 drivers/net/tulip/dmfe.c                           |    9 +-
 drivers/net/tulip/tulip_core.c                     |    9 +-
 drivers/net/tulip/uli526x.c                        |   10 +-
 drivers/net/tulip/winbond-840.c                    |    8 +-
 drivers/net/tulip/xircom_cb.c                      |    8 +-
 drivers/net/tun.c                                  |   50 +-
 drivers/net/typhoon.c                              |    4 +-
 drivers/net/ucc_geth.c                             |  582 +-
 drivers/net/ucc_geth.h                             |    3 +
 drivers/net/ucc_geth_ethtool.c                     |   48 +-
 drivers/net/usb/asix.c                             |    4 +-
 drivers/net/usb/catc.c                             |    7 +-
 drivers/net/usb/cdc-phonet.c                       |   21 +-
 drivers/net/usb/dm9601.c                           |    2 +-
 drivers/net/usb/hso.c                              |   12 +-
 drivers/net/usb/kaweth.c                           |    9 +-
 drivers/net/usb/mcs7830.c                          |    2 +-
 drivers/net/usb/pegasus.c                          |    7 +-
 drivers/net/usb/rndis_host.c                       |   48 +-
 drivers/net/usb/rtl8150.c                          |    7 +-
 drivers/net/usb/smsc95xx.c                         |    7 +-
 drivers/net/usb/usbnet.c                           |   98 +-
 drivers/net/veth.c                                 |   11 +-
 drivers/net/via-rhine.c                            |   12 +-
 drivers/net/via-velocity.c                         | 3430 +++---
 drivers/net/via-velocity.h                         |    6 +-
 drivers/net/virtio_net.c                           |    7 +-
 drivers/net/vxge/vxge-config.c                     |   10 -
 drivers/net/vxge/vxge-config.h                     |   17 +-
 drivers/net/vxge/vxge-main.c                       |  173 +-
 drivers/net/vxge/vxge-main.h                       |    8 +-
 drivers/net/vxge/vxge-reg.h                        |    9 +-
 drivers/net/vxge/vxge-traffic.c                    |   12 +-
 drivers/net/vxge/vxge-traffic.h                    |    4 +-
 drivers/net/vxge/vxge-version.h                    |    4 +-
 drivers/net/wan/cosa.c                             |    7 +-
 drivers/net/wan/cycx_x25.c                         |   10 +-
 drivers/net/wan/dlci.c                             |   42 +-
 drivers/net/wan/dscc4.c                            |   16 +-
 drivers/net/wan/farsync.c                          |   29 +-
 drivers/net/wan/hd64570.c                          |    4 +-
 drivers/net/wan/hd64572.c                          |    4 +-
 drivers/net/wan/hdlc.c                             |    2 +-
 drivers/net/wan/hdlc_fr.c                          |    8 +-
 drivers/net/wan/hdlc_ppp.c                         |    1 +
 drivers/net/wan/hdlc_raw_eth.c                     |    2 +-
 drivers/net/wan/hdlc_x25.c                         |    6 +-
 drivers/net/wan/hostess_sv11.c                     |    3 +-
 drivers/net/wan/ixp4xx_hss.c                       |   95 +-
 drivers/net/wan/lapbether.c                        |    3 +-
 drivers/net/wan/lmc/lmc_main.c                     |   18 +-
 drivers/net/wan/pci200syn.c                        |   11 -
 drivers/net/wan/sbni.c                             |   11 +-
 drivers/net/wan/sdla.c                             |   11 +-
 drivers/net/wan/sealevel.c                         |    3 +-
 drivers/net/wan/wanxl.c                            |    4 +-
 drivers/net/wan/x25_asy.c                          |   13 +-
 drivers/net/wan/z85230.c                           |    9 +-
 drivers/net/wan/z85230.h                           |    3 +-
 drivers/net/wimax/i2400m/netdev.c                  |   12 +-
 drivers/net/wimax/i2400m/sdio.c                    |   17 +-
 drivers/net/wimax/i2400m/usb.c                     |    5 +
 drivers/net/wireless/Kconfig                       |   81 +-
 drivers/net/wireless/adm8211.c                     |   62 +-
 drivers/net/wireless/airo.c                        |   26 +-
 drivers/net/wireless/arlan-main.c                  |    8 +-
 drivers/net/wireless/at76c50x-usb.c                |   33 +-
 drivers/net/wireless/ath/Kconfig                   |   19 +-
 drivers/net/wireless/ath/ar9170/Kconfig            |    4 +-
 drivers/net/wireless/ath/ar9170/ar9170.h           |   69 +-
 drivers/net/wireless/ath/ar9170/led.c              |   11 +-
 drivers/net/wireless/ath/ar9170/mac.c              |   46 +-
 drivers/net/wireless/ath/ar9170/main.c             |  768 +-
 drivers/net/wireless/ath/ar9170/phy.c              |  420 +-
 drivers/net/wireless/ath/ar9170/usb.c              |    2 +-
 drivers/net/wireless/ath/ath.h                     |   48 +
 drivers/net/wireless/ath/ath5k/Kconfig             |    3 +-
 drivers/net/wireless/ath/ath5k/ath5k.h             |   45 +-
 drivers/net/wireless/ath/ath5k/attach.c            |   84 +-
 drivers/net/wireless/ath/ath5k/base.c              |  473 +-
 drivers/net/wireless/ath/ath5k/base.h              |   29 +-
 drivers/net/wireless/ath/ath5k/debug.c             |    8 +-
 drivers/net/wireless/ath/ath5k/eeprom.c            |   39 +-
 drivers/net/wireless/ath/ath5k/eeprom.h            |    4 +
 drivers/net/wireless/ath/ath5k/led.c               |    2 +
 drivers/net/wireless/ath/ath5k/phy.c               |   57 +-
 drivers/net/wireless/ath/ath5k/qcu.c               |    3 +-
 drivers/net/wireless/ath/ath5k/reg.h               |   12 +-
 drivers/net/wireless/ath/ath5k/reset.c             |  156 +-
 drivers/net/wireless/ath/ath9k/Kconfig             |   13 +-
 drivers/net/wireless/ath/ath9k/Makefile            |    6 +-
 drivers/net/wireless/ath/ath9k/ahb.c               |   10 +-
 drivers/net/wireless/ath/ath9k/ani.c               |  207 +-
 drivers/net/wireless/ath/ath9k/ani.h               |   25 +-
 drivers/net/wireless/ath/ath9k/ath9k.h             |   86 +-
 drivers/net/wireless/ath/ath9k/beacon.c            |   15 +-
 drivers/net/wireless/ath/ath9k/btcoex.c            |  340 +
 drivers/net/wireless/ath/ath9k/btcoex.h            |  100 +
 drivers/net/wireless/ath/ath9k/calib.c             |  218 +-
 drivers/net/wireless/ath/ath9k/calib.h             |   11 +-
 drivers/net/wireless/ath/ath9k/debug.c             |   99 +-
 drivers/net/wireless/ath/ath9k/debug.h             |   56 +
 drivers/net/wireless/ath/ath9k/eeprom.c            | 2598 +----
 drivers/net/wireless/ath/ath9k/eeprom.h            |  284 +-
 drivers/net/wireless/ath/ath9k/eeprom_4k.c         | 1188 ++
 drivers/net/wireless/ath/ath9k/eeprom_9287.c       | 1177 ++
 drivers/net/wireless/ath/ath9k/eeprom_def.c        | 1387 +++
 drivers/net/wireless/ath/ath9k/hw.c                |  891 +-
 drivers/net/wireless/ath/ath9k/hw.h                |  123 +-
 drivers/net/wireless/ath/ath9k/initvals.h          | 2239 ++++-
 drivers/net/wireless/ath/ath9k/mac.c               |   47 +-
 drivers/net/wireless/ath/ath9k/mac.h               |    9 +-
 drivers/net/wireless/ath/ath9k/main.c              |  316 +-
 drivers/net/wireless/ath/ath9k/pci.c               |   34 +-
 drivers/net/wireless/ath/ath9k/phy.c               |   65 +-
 drivers/net/wireless/ath/ath9k/phy.h               |   32 +-
 drivers/net/wireless/ath/ath9k/rc.c                |  616 +-
 drivers/net/wireless/ath/ath9k/rc.h                |   29 +-
 drivers/net/wireless/ath/ath9k/recv.c              |  150 +-
 drivers/net/wireless/ath/ath9k/reg.h               |  202 +-
 drivers/net/wireless/ath/ath9k/virtual.c           |   34 +-
 drivers/net/wireless/ath/ath9k/xmit.c              |  193 +-
 drivers/net/wireless/ath/main.c                    |   36 +
 drivers/net/wireless/ath/regd.c                    |    2 -
 drivers/net/wireless/ath/regd.h                    |   26 +-
 drivers/net/wireless/ath/regd_common.h             |    8 +-
 drivers/net/wireless/atmel.c                       |    8 +-
 drivers/net/wireless/b43/Kconfig                   |   18 +-
 drivers/net/wireless/b43/b43.h                     |   52 +-
 drivers/net/wireless/b43/debugfs.c                 |   67 +-
 drivers/net/wireless/b43/debugfs.h                 |    3 +-
 drivers/net/wireless/b43/dma.c                     |   52 +-
 drivers/net/wireless/b43/dma.h                     |    3 -
 drivers/net/wireless/b43/lo.c                      |    2 +-
 drivers/net/wireless/b43/main.c                    |  921 +-
 drivers/net/wireless/b43/main.h                    |    6 +-
 drivers/net/wireless/b43/phy_a.c                   |   48 +-
 drivers/net/wireless/b43/phy_common.c              |   37 +-
 drivers/net/wireless/b43/phy_common.h              |   21 +-
 drivers/net/wireless/b43/phy_g.c                   |   66 +-
 drivers/net/wireless/b43/phy_g.h                   |    3 +-
 drivers/net/wireless/b43/phy_lp.c                  | 1804 +++-
 drivers/net/wireless/b43/phy_lp.h                  |   58 +-
 drivers/net/wireless/b43/phy_n.c                   |    3 +-
 drivers/net/wireless/b43/pio.c                     |   75 +-
 drivers/net/wireless/b43/pio.h                     |    6 -
 drivers/net/wireless/b43/sysfs.c                   |    3 -
 drivers/net/wireless/b43/tables_lpphy.c            | 2193 ++++-
 drivers/net/wireless/b43/tables_lpphy.h            |   13 +
 drivers/net/wireless/b43/wa.c                      |    4 +-
 drivers/net/wireless/b43/xmit.c                    |   36 +-
 drivers/net/wireless/b43/xmit.h                    |    3 +-
 drivers/net/wireless/b43legacy/dma.c               |   22 +-
 drivers/net/wireless/b43legacy/main.c              |   20 +-
 drivers/net/wireless/b43legacy/xmit.c              |    4 +-
 drivers/net/wireless/hostap/hostap_80211.h         |   10 +-
 drivers/net/wireless/hostap/hostap_80211_tx.c      |   53 +-
 drivers/net/wireless/hostap/hostap_cs.c            |    3 +-
 drivers/net/wireless/ipw2x00/Kconfig               |    6 +-
 drivers/net/wireless/ipw2x00/ipw2100.c             |  228 +-
 drivers/net/wireless/ipw2x00/ipw2100.h             |   16 +-
 drivers/net/wireless/ipw2x00/ipw2200.c             | 1118 +-
 drivers/net/wireless/ipw2x00/ipw2200.h             |   16 +-
 .../net/wireless/ipw2x00/{ieee80211.h =3D> libipw.h} |  669 +-
 drivers/net/wireless/ipw2x00/libipw_geo.c          |   82 +-
 drivers/net/wireless/ipw2x00/libipw_module.c       |  124 +-
 drivers/net/wireless/ipw2x00/libipw_rx.c           |  403 +-
 drivers/net/wireless/ipw2x00/libipw_tx.c           |   78 +-
 drivers/net/wireless/ipw2x00/libipw_wx.c           |   94 +-
 drivers/net/wireless/iwlwifi/Kconfig               |    3 +
 drivers/net/wireless/iwlwifi/iwl-1000.c            |   96 +-
 drivers/net/wireless/iwlwifi/iwl-3945-hw.h         |    9 +-
 drivers/net/wireless/iwlwifi/iwl-3945-led.c        |   11 +-
 drivers/net/wireless/iwlwifi/iwl-3945-rs.c         |   24 +-
 drivers/net/wireless/iwlwifi/iwl-3945.c            |   94 +-
 drivers/net/wireless/iwlwifi/iwl-3945.h            |   12 +-
 drivers/net/wireless/iwlwifi/iwl-4965-hw.h         |    6 +-
 drivers/net/wireless/iwlwifi/iwl-4965.c            |   96 +-
 drivers/net/wireless/iwlwifi/iwl-5000.c            |  149 +-
 drivers/net/wireless/iwlwifi/iwl-6000.c            |  136 +-
 drivers/net/wireless/iwlwifi/iwl-agn-rs.c          |  321 +-
 drivers/net/wireless/iwlwifi/iwl-agn-rs.h          |    1 +
 drivers/net/wireless/iwlwifi/iwl-agn.c             |  333 +-
 drivers/net/wireless/iwlwifi/iwl-calib.c           |   13 +-
 drivers/net/wireless/iwlwifi/iwl-commands.h        |   62 +-
 drivers/net/wireless/iwlwifi/iwl-core.c            |  972 +-
 drivers/net/wireless/iwlwifi/iwl-core.h            |   89 +-
 drivers/net/wireless/iwlwifi/iwl-csr.h             |   10 +-
 drivers/net/wireless/iwlwifi/iwl-debug.h           |   37 +-
 drivers/net/wireless/iwlwifi/iwl-debugfs.c         | 1159 ++-
 drivers/net/wireless/iwlwifi/iwl-dev.h             |  293 +-
 drivers/net/wireless/iwlwifi/iwl-eeprom.c          |  514 +-
 drivers/net/wireless/iwlwifi/iwl-eeprom.h          |  124 +-
 drivers/net/wireless/iwlwifi/iwl-hcmd.c            |   65 +-
 drivers/net/wireless/iwlwifi/iwl-helpers.h         |   21 +
 drivers/net/wireless/iwlwifi/iwl-led.c             |   40 +-
 drivers/net/wireless/iwlwifi/iwl-power.c           |  822 ++-
 drivers/net/wireless/iwlwifi/iwl-power.h           |  115 +-
 drivers/net/wireless/iwlwifi/iwl-prph.h            |    5 +-
 drivers/net/wireless/iwlwifi/iwl-rx.c              |  245 +-
 drivers/net/wireless/iwlwifi/iwl-scan.c            |   42 +-
 drivers/net/wireless/iwlwifi/iwl-sta.c             |   60 +-
 drivers/net/wireless/iwlwifi/iwl-tx.c              |  255 +-
 drivers/net/wireless/iwlwifi/iwl3945-base.c        |  289 +-
 drivers/net/wireless/iwmc3200wifi/Kconfig          |    1 -
 drivers/net/wireless/iwmc3200wifi/Makefile         |    2 +-
 drivers/net/wireless/iwmc3200wifi/cfg80211.c       |  436 +-
 drivers/net/wireless/iwmc3200wifi/commands.c       |  196 +-
 drivers/net/wireless/iwmc3200wifi/commands.h       |    7 +-
 drivers/net/wireless/iwmc3200wifi/debug.h          |    2 +
 drivers/net/wireless/iwmc3200wifi/debugfs.c        |  105 +-
 drivers/net/wireless/iwmc3200wifi/eeprom.c         |    4 -
 drivers/net/wireless/iwmc3200wifi/fw.c             |   67 +-
 drivers/net/wireless/iwmc3200wifi/hal.c            |   16 +-
 drivers/net/wireless/iwmc3200wifi/iwm.h            |   47 +-
 drivers/net/wireless/iwmc3200wifi/lmac.h           |   19 +
 drivers/net/wireless/iwmc3200wifi/main.c           |  103 +-
 drivers/net/wireless/iwmc3200wifi/netdev.c         |   28 +-
 drivers/net/wireless/iwmc3200wifi/rx.c             |  205 +-
 drivers/net/wireless/iwmc3200wifi/sdio.c           |   10 +-
 drivers/net/wireless/iwmc3200wifi/sdio.h           |    3 -
 drivers/net/wireless/iwmc3200wifi/umac.h           |    8 +
 drivers/net/wireless/iwmc3200wifi/wext.c           |  723 --
 drivers/net/wireless/libertas/assoc.c              |   67 +-
 drivers/net/wireless/libertas/debugfs.c            |   28 +
 drivers/net/wireless/libertas/decl.h               |    5 +-
 drivers/net/wireless/libertas/dev.h                |    3 +-
 drivers/net/wireless/libertas/ethtool.c            |    2 +-
 drivers/net/wireless/libertas/if_cs.c              |   42 +-
 drivers/net/wireless/libertas/if_sdio.c            |    5 +-
 drivers/net/wireless/libertas/if_spi.c             |   10 +-
 drivers/net/wireless/libertas/if_usb.c             |    3 +-
 drivers/net/wireless/libertas/main.c               |    6 +-
 drivers/net/wireless/libertas/tx.c                 |    6 +-
 drivers/net/wireless/libertas/wext.c               |    4 +-
 drivers/net/wireless/libertas_tf/main.c            |   40 +-
 drivers/net/wireless/mac80211_hwsim.c              |   98 +-
 drivers/net/wireless/mwl8k.c                       | 1559 +--
 drivers/net/wireless/netwave_cs.c                  |    8 +-
 drivers/net/wireless/orinoco/Kconfig               |    1 +
 drivers/net/wireless/orinoco/Makefile              |    2 +-
 drivers/net/wireless/orinoco/airport.c             |   98 +-
 drivers/net/wireless/orinoco/cfg.c                 |  203 +
 drivers/net/wireless/orinoco/cfg.h                 |   15 +
 drivers/net/wireless/orinoco/fw.c                  |   41 +-
 drivers/net/wireless/orinoco/hermes.c              |    2 +-
 drivers/net/wireless/orinoco/hermes.h              |    2 +-
 drivers/net/wireless/orinoco/hermes_dld.c          |   50 +-
 drivers/net/wireless/orinoco/hw.c                  |  786 ++-
 drivers/net/wireless/orinoco/hw.h                  |   16 +-
 drivers/net/wireless/orinoco/main.c                | 1169 +--
 drivers/net/wireless/orinoco/main.h                |    3 +-
 drivers/net/wireless/orinoco/orinoco.h             |   65 +-
 drivers/net/wireless/orinoco/orinoco_cs.c          |   96 +-
 drivers/net/wireless/orinoco/orinoco_nortel.c      |   38 +-
 drivers/net/wireless/orinoco/orinoco_pci.c         |   38 +-
 drivers/net/wireless/orinoco/orinoco_pci.h         |   57 +-
 drivers/net/wireless/orinoco/orinoco_plx.c         |   38 +-
 drivers/net/wireless/orinoco/orinoco_tmd.c         |   38 +-
 drivers/net/wireless/orinoco/scan.c                |  291 +-
 drivers/net/wireless/orinoco/scan.h                |   21 +-
 drivers/net/wireless/orinoco/spectrum_cs.c         |   96 +-
 drivers/net/wireless/orinoco/wext.c                | 1053 +--
 drivers/net/wireless/p54/Makefile                  |    3 +
 drivers/net/wireless/p54/eeprom.c                  |  753 ++
 drivers/net/wireless/p54/eeprom.h                  |  226 +
 drivers/net/wireless/p54/fwio.c                    |  716 ++
 drivers/net/wireless/p54/led.c                     |  162 +
 drivers/net/wireless/p54/lmac.h                    |  558 +
 drivers/net/wireless/p54/main.c                    |  648 +
 drivers/net/wireless/p54/p54.h                     |  151 +-
 drivers/net/wireless/p54/p54common.c               | 2688 ----
 drivers/net/wireless/p54/p54common.h               |  644 -
 drivers/net/wireless/p54/p54pci.c                  |    9 +-
 drivers/net/wireless/p54/p54spi.c                  |   54 +-
 drivers/net/wireless/p54/p54usb.c                  |   42 +-
 drivers/net/wireless/p54/txrx.c                    |  869 ++
 drivers/net/wireless/prism54/islpci_eth.c          |    8 +-
 drivers/net/wireless/prism54/islpci_eth.h          |    2 +-
 drivers/net/wireless/prism54/islpci_hotplug.c      |    4 +-
 drivers/net/wireless/ray_cs.c                      |   21 +-
 drivers/net/wireless/rndis_wlan.c                  | 2157 ++--
 drivers/net/wireless/rt2x00/Kconfig                |   16 +-
 drivers/net/wireless/rt2x00/Makefile               |    1 -
 drivers/net/wireless/rt2x00/rt2400pci.c            |   15 +-
 drivers/net/wireless/rt2x00/rt2400pci.h            |    2 +-
 drivers/net/wireless/rt2x00/rt2500pci.c            |   15 +-
 drivers/net/wireless/rt2x00/rt2500pci.h            |    2 +-
 drivers/net/wireless/rt2x00/rt2500usb.c            |   28 +-
 drivers/net/wireless/rt2x00/rt2500usb.h            |    2 +-
 drivers/net/wireless/rt2x00/rt2800usb.c            |   49 +-
 drivers/net/wireless/rt2x00/rt2800usb.h            |   12 +-
 drivers/net/wireless/rt2x00/rt2x00.h               |   60 +-
 drivers/net/wireless/rt2x00/rt2x00config.c         |   35 +-
 drivers/net/wireless/rt2x00/rt2x00crypto.c         |   14 +-
 drivers/net/wireless/rt2x00/rt2x00dev.c            |  104 +-
 drivers/net/wireless/rt2x00/rt2x00lib.h            |   68 +-
 drivers/net/wireless/rt2x00/rt2x00link.c           |  168 +-
 drivers/net/wireless/rt2x00/rt2x00mac.c            |  127 +-
 drivers/net/wireless/rt2x00/rt2x00queue.c          |  123 +-
 drivers/net/wireless/rt2x00/rt2x00queue.h          |   12 +-
 drivers/net/wireless/rt2x00/rt2x00reg.h            |    4 +-
 drivers/net/wireless/rt2x00/rt2x00rfkill.c         |  127 -
 drivers/net/wireless/rt2x00/rt61pci.c              |   27 +-
 drivers/net/wireless/rt2x00/rt61pci.h              |    2 +-
 drivers/net/wireless/rt2x00/rt73usb.c              |   21 +-
 drivers/net/wireless/rt2x00/rt73usb.h              |    4 +-
 drivers/net/wireless/rtl818x/Makefile              |    2 +-
 drivers/net/wireless/rtl818x/rtl8180_dev.c         |   16 +-
 drivers/net/wireless/rtl818x/rtl8187.h             |    1 +
 drivers/net/wireless/rtl818x/rtl8187_dev.c         |   47 +-
 drivers/net/wireless/rtl818x/rtl8187_leds.c        |   14 +-
 drivers/net/wireless/rtl818x/rtl8187_rfkill.c      |   63 +
 drivers/net/wireless/rtl818x/rtl8187_rfkill.h      |    8 +
 drivers/net/wireless/rtl818x/rtl818x.h             |   19 +-
 drivers/net/wireless/strip.c                       |   13 +-
 drivers/net/wireless/wavelan.c                     |    5 +-
 drivers/net/wireless/wavelan.p.h                   |    2 +-
 drivers/net/wireless/wavelan_cs.c                  |    6 +-
 drivers/net/wireless/wavelan_cs.p.h                |    2 +-
 drivers/net/wireless/wl12xx/Kconfig                |   51 +-
 drivers/net/wireless/wl12xx/Makefile               |   18 +-
 drivers/net/wireless/wl12xx/acx.c                  |  689 --
 drivers/net/wireless/wl12xx/boot.c                 |  295 -
 drivers/net/wireless/wl12xx/cmd.c                  |  353 -
 drivers/net/wireless/wl12xx/init.c                 |  200 -
 drivers/net/wireless/wl12xx/wl1251.c               |  709 --
 drivers/net/wireless/wl12xx/wl1251.h               |  467 +-
 drivers/net/wireless/wl12xx/wl1251_acx.c           |  918 ++
 .../net/wireless/wl12xx/{acx.h =3D> wl1251_acx.h}    |  345 +-
 drivers/net/wireless/wl12xx/wl1251_boot.c          |  530 +
 .../net/wireless/wl12xx/{boot.h =3D> wl1251_boot.h}  |   13 +-
 drivers/net/wireless/wl12xx/wl1251_cmd.c           |  412 +
 .../net/wireless/wl12xx/{cmd.h =3D> wl1251_cmd.h}    |  196 +-
 .../wl12xx/{debugfs.c =3D> wl1251_debugfs.c}         |   60 +-
 .../wl12xx/{debugfs.h =3D> wl1251_debugfs.h}         |   16 +-
 .../wireless/wl12xx/{event.c =3D> wl1251_event.c}    |   57 +-
 .../wireless/wl12xx/{event.h =3D> wl1251_event.h}    |   12 +-
 drivers/net/wireless/wl12xx/wl1251_init.c          |  413 +
 .../net/wireless/wl12xx/{init.h =3D> wl1251_init.h}  |   29 +-
 drivers/net/wireless/wl12xx/wl1251_io.c            |  196 +
 drivers/net/wireless/wl12xx/wl1251_io.h            |   64 +
 .../net/wireless/wl12xx/{main.c =3D> wl1251_main.c}  |  890 +-
 .../wireless/wl12xx/{init.h =3D> wl1251_netlink.h}   |   22 +-
 drivers/net/wireless/wl12xx/{ps.c =3D> wl1251_ps.c}  |   80 +-
 drivers/net/wireless/wl12xx/{ps.h =3D> wl1251_ps.h}  |   18 +-
 .../net/wireless/wl12xx/{reg.h =3D> wl1251_reg.h}    |  105 +-
 drivers/net/wireless/wl12xx/{rx.c =3D> wl1251_rx.c}  |   93 +-
 drivers/net/wireless/wl12xx/{rx.h =3D> wl1251_rx.h}  |   24 +-
 drivers/net/wireless/wl12xx/wl1251_sdio.c          |  205 +
 drivers/net/wireless/wl12xx/wl1251_spi.c           |  344 +
 drivers/net/wireless/wl12xx/wl1251_spi.h           |   61 +
 drivers/net/wireless/wl12xx/{tx.c =3D> wl1251_tx.c}  |  174 +-
 drivers/net/wireless/wl12xx/{tx.h =3D> wl1251_tx.h}  |   21 +-
 drivers/net/wireless/wl12xx/{wl12xx.h =3D> wl1271.h} |  210 +-
 drivers/net/wireless/wl12xx/wl1271_acx.c           |  961 ++
 .../net/wireless/wl12xx/{acx.h =3D> wl1271_acx.h}    |  622 +-
 drivers/net/wireless/wl12xx/wl1271_boot.c          |  541 +
 drivers/net/wireless/wl12xx/wl1271_boot.h          |   72 +
 drivers/net/wireless/wl12xx/wl1271_cmd.c           |  813 ++
 drivers/net/wireless/wl12xx/wl1271_cmd.h           |  464 +
 .../wl12xx/{debugfs.c =3D> wl1271_debugfs.c}         |   62 +-
 .../wl12xx/{debugfs.h =3D> wl1271_debugfs.h}         |   18 +-
 .../wireless/wl12xx/{event.c =3D> wl1271_event.c}    |   64 +-
 drivers/net/wireless/wl12xx/wl1271_event.h         |  110 +
 drivers/net/wireless/wl12xx/wl1271_init.c          |  397 +
 drivers/net/wireless/wl12xx/wl1271_init.h          |  115 +
 drivers/net/wireless/wl12xx/wl1271_main.c          | 1394 +++
 drivers/net/wireless/wl12xx/wl1271_ps.c            |  142 +
 .../net/wireless/wl12xx/{debugfs.h =3D> wl1271_ps.h} |   22 +-
 .../net/wireless/wl12xx/{reg.h =3D> wl1271_reg.h}    |  223 +-
 drivers/net/wireless/wl12xx/wl1271_rx.c            |  200 +
 drivers/net/wireless/wl12xx/wl1271_rx.h            |  121 +
 .../net/wireless/wl12xx/{spi.c =3D> wl1271_spi.c}    |  194 +-
 .../net/wireless/wl12xx/{spi.h =3D> wl1271_spi.h}    |   68 +-
 drivers/net/wireless/wl12xx/wl1271_tx.c            |  378 +
 drivers/net/wireless/wl12xx/wl1271_tx.h            |  130 +
 drivers/net/wireless/wl3501_cs.c                   |    6 +-
 drivers/net/wireless/zd1201.c                      |    7 +-
 drivers/net/wireless/zd1211rw/zd_chip.c            |    6 +-
 drivers/net/wireless/zd1211rw/zd_chip.h            |    6 +-
 drivers/net/wireless/zd1211rw/zd_mac.c             |   51 +-
 drivers/net/wireless/zd1211rw/zd_usb.c             |   74 +-
 drivers/net/xen-netfront.c                         |    8 +-
 drivers/net/xilinx_emaclite.c                      | 1040 ++
 drivers/net/xtsonic.c                              |    2 +-
 drivers/net/yellowfin.c                            |   12 +-
 drivers/net/znet.c                                 |    9 +-
 drivers/s390/net/claw.c                            |    2 +
 drivers/s390/net/ctcm_main.c                       |   11 +-
 drivers/s390/net/lcs.c                             |    8 +-
 drivers/s390/net/netiucv.c                         |    7 +-
 drivers/s390/net/qeth_core.h                       |   10 +-
 drivers/s390/net/qeth_core_main.c                  |  114 +-
 drivers/s390/net/qeth_core_sys.c                   |    2 +-
 drivers/s390/net/qeth_l2_main.c                    |   48 +-
 drivers/s390/net/qeth_l3_main.c                    |   52 +-
 drivers/ssb/Kconfig                                |   14 +
 drivers/ssb/Makefile                               |    1 +
 drivers/ssb/driver_chipcommon_pmu.c                |   94 +
 drivers/ssb/main.c                                 |   64 +-
 drivers/ssb/pci.c                                  |   55 +-
 drivers/ssb/scan.c                                 |   11 +
 drivers/ssb/sdio.c                                 |  610 +
 drivers/ssb/ssb_private.h                          |   40 +
 drivers/staging/agnx/xmit.c                        |    3 +-
 drivers/staging/at76_usb/at76_usb.c                |   10 +-
 drivers/staging/dst/dcore.c                        |    3 +-
 drivers/staging/epl/VirtualEthernetLinux.c         |    2 +-
 drivers/staging/octeon/ethernet-mdio.c             |    2 +-
 drivers/staging/octeon/ethernet-mdio.h             |    2 +-
 drivers/staging/otus/usbdrv.c                      |    8 +-
 drivers/staging/otus/wrap_pkt.c                    |    3 -
 drivers/staging/rt2860/rt_main_dev.c               |    6 +-
 drivers/staging/rtl8187se/ieee80211/ieee80211_tx.c |    4 +-
 drivers/staging/rtl8187se/r8180_core.c             |    4 +-
 drivers/staging/slicoss/slicoss.c                  |    2 +-
 drivers/staging/stlc45xx/stlc45xx.c                |    3 +-
 drivers/staging/sxg/sxg.h                          |    2 +-
 drivers/staging/sxg/sxg_ethtool.c                  |    2 +-
 drivers/staging/winbond/wb35rx.c                   |    3 +-
 drivers/staging/wlan-ng/p80211netdev.c             |    2 +-
 drivers/usb/gadget/f_phonet.c                      |   93 +-
 drivers/usb/gadget/u_ether.c                       |   11 +-
 drivers/uwb/i1480/i1480u-wlp/i1480u-wlp.h          |    3 +-
 drivers/uwb/i1480/i1480u-wlp/tx.c                  |    3 +-
 drivers/video/uvesafb.c                            |    3 +-
 drivers/w1/w1_netlink.c                            |    3 +-
 firmware/Makefile                                  |   16 +-
 firmware/WHENCE                                    |   17 +
 firmware/bnx2/bnx2-mips-06-4.6.16.fw.ihex          | 5805 ---------
 firmware/bnx2/bnx2-mips-06-5.0.0.j3.fw.ihex        | 5841 +++++++++
 firmware/bnx2/bnx2-mips-09-4.6.17.fw.ihex          | 5816 ---------
 firmware/bnx2/bnx2-mips-09-5.0.0.j3.fw.ihex        | 6051 +++++++++
 firmware/bnx2/bnx2-rv2p-06-4.6.16.fw.ihex          |  441 -
 firmware/bnx2/bnx2-rv2p-06-5.0.0.j3.fw.ihex        |  424 +
 firmware/bnx2/bnx2-rv2p-09-4.6.15.fw.ihex          |  490 -
 firmware/bnx2/bnx2-rv2p-09-5.0.0.j3.fw.ihex        |  462 +
 firmware/bnx2/bnx2-rv2p-09ax-5.0.0.j3.fw.ihex      |  498 +
 firmware/bnx2x-e1-4.8.53.0.fw.ihex                 |10364 ------------=
----
 firmware/bnx2x-e1-5.0.21.0.fw.ihex                 |10184 ++++++++++++=
++++
 firmware/bnx2x-e1h-4.8.53.0.fw.ihex                |12028 ------------=
------
 firmware/bnx2x-e1h-5.0.21.0.fw.ihex                |12855 ++++++++++++=
++++++++
 firmware/cxgb3/ael2005_opt_edc.bin.ihex            |   69 +
 firmware/cxgb3/ael2005_twx_edc.bin.ihex            |   93 +
 firmware/cxgb3/ael2020_twx_edc.bin.ihex            |  100 +
 fs/dlm/netlink.c                                   |    2 +-
 include/asm-generic/socket.h                       |    3 +
 include/linux/arcdevice.h                          |    3 +-
 include/linux/can/dev.h                            |    1 +
 include/linux/connector.h                          |    6 +-
 include/linux/dcbnl.h                              |   18 +
 include/linux/ethtool.h                            |   15 +
 include/linux/hdlc.h                               |    8 +-
 include/linux/icmpv6.h                             |    2 -
 include/linux/ieee80211.h                          |   31 +-
 include/linux/if_addr.h                            |    1 +
 include/linux/if_arp.h                             |    1 -
 include/linux/if_ether.h                           |    4 +-
 include/linux/if_frad.h                            |    5 -
 include/linux/if_tun.h                             |    1 +
 include/linux/isdn/hdlc.h                          |   82 +
 include/linux/mISDNhw.h                            |    1 +
 include/linux/mISDNif.h                            |   16 +-
 include/linux/mdio.h                               |    2 +-
 include/linux/mmc/sdio_ids.h                       |    6 +
 include/linux/net_dropmon.h                        |    1 -
 include/linux/netdevice.h                          |   51 +-
 include/linux/netfilter/nfnetlink.h                |    3 +-
 include/linux/netfilter/x_tables.h                 |    4 +-
 include/linux/netfilter/xt_CONNMARK.h              |    6 -
 include/linux/netfilter/xt_MARK.h                  |   17 -
 include/linux/netfilter/xt_connmark.h              |    5 -
 include/linux/netfilter/xt_conntrack.h             |   36 -
 include/linux/netfilter/xt_mark.h                  |    5 -
 include/linux/netfilter_arp/arp_tables.h           |    2 +-
 include/linux/netfilter_bridge/ebtables.h          |    2 +-
 include/linux/netfilter_ipv4/Kbuild                |   32 -
 include/linux/netfilter_ipv4/ip_tables.h           |    2 +-
 include/linux/netfilter_ipv4/ipt_CLASSIFY.h        |    7 -
 include/linux/netfilter_ipv4/ipt_CONNMARK.h        |   19 -
 include/linux/netfilter_ipv4/ipt_DSCP.h            |   18 -
 include/linux/netfilter_ipv4/ipt_ECN.h             |    4 +-
 include/linux/netfilter_ipv4/ipt_MARK.h            |   18 -
 include/linux/netfilter_ipv4/ipt_NFQUEUE.h         |   16 -
 include/linux/netfilter_ipv4/ipt_TCPMSS.h          |    9 -
 include/linux/netfilter_ipv4/ipt_TOS.h             |   12 -
 include/linux/netfilter_ipv4/ipt_comment.h         |   10 -
 include/linux/netfilter_ipv4/ipt_connbytes.h       |   18 -
 include/linux/netfilter_ipv4/ipt_connmark.h        |    7 -
 include/linux/netfilter_ipv4/ipt_conntrack.h       |   28 -
 include/linux/netfilter_ipv4/ipt_dccp.h            |   15 -
 include/linux/netfilter_ipv4/ipt_dscp.h            |   21 -
 include/linux/netfilter_ipv4/ipt_ecn.h             |    4 +-
 include/linux/netfilter_ipv4/ipt_esp.h             |   10 -
 include/linux/netfilter_ipv4/ipt_hashlimit.h       |   14 -
 include/linux/netfilter_ipv4/ipt_helper.h          |    7 -
 include/linux/netfilter_ipv4/ipt_iprange.h         |   21 -
 include/linux/netfilter_ipv4/ipt_length.h          |    7 -
 include/linux/netfilter_ipv4/ipt_limit.h           |    8 -
 include/linux/netfilter_ipv4/ipt_mac.h             |    7 -
 include/linux/netfilter_ipv4/ipt_mark.h            |    9 -
 include/linux/netfilter_ipv4/ipt_multiport.h       |   15 -
 include/linux/netfilter_ipv4/ipt_owner.h           |   20 -
 include/linux/netfilter_ipv4/ipt_physdev.h         |   17 -
 include/linux/netfilter_ipv4/ipt_pkttype.h         |    7 -
 include/linux/netfilter_ipv4/ipt_policy.h          |   23 -
 include/linux/netfilter_ipv4/ipt_recent.h          |   21 -
 include/linux/netfilter_ipv4/ipt_sctp.h            |  105 -
 include/linux/netfilter_ipv4/ipt_state.h           |   15 -
 include/linux/netfilter_ipv4/ipt_string.h          |   10 -
 include/linux/netfilter_ipv4/ipt_tcpmss.h          |    7 -
 include/linux/netfilter_ipv4/ipt_tos.h             |   13 -
 include/linux/netfilter_ipv6/Kbuild                |   12 +-
 include/linux/netfilter_ipv6/ip6_tables.h          |    2 +-
 include/linux/netfilter_ipv6/ip6t_MARK.h           |    9 -
 include/linux/netfilter_ipv6/ip6t_esp.h            |   10 -
 include/linux/netfilter_ipv6/ip6t_length.h         |    8 -
 include/linux/netfilter_ipv6/ip6t_limit.h          |    8 -
 include/linux/netfilter_ipv6/ip6t_mac.h            |    7 -
 include/linux/netfilter_ipv6/ip6t_mark.h           |    9 -
 include/linux/netfilter_ipv6/ip6t_multiport.h      |   14 -
 include/linux/netfilter_ipv6/ip6t_owner.h          |   18 -
 include/linux/netfilter_ipv6/ip6t_physdev.h        |   17 -
 include/linux/netfilter_ipv6/ip6t_policy.h         |   23 -
 include/linux/netlink.h                            |   15 +-
 include/linux/nl80211.h                            |  174 +-
 include/linux/nl802154.h                           |    6 +-
 include/linux/pci_ids.h                            |    3 +-
 include/linux/phonet.h                             |   20 +
 include/linux/rds.h                                |   12 +
 include/linux/rfkill.h                             |   38 +-
 include/linux/rtnetlink.h                          |    2 +-
 include/linux/skbuff.h                             |    6 +-
 include/linux/ssb/ssb.h                            |   69 +-
 include/linux/ssb/ssb_driver_chipcommon.h          |   10 +
 include/linux/ssb/ssb_regs.h                       |   66 +-
 include/linux/tcp.h                                |    6 +-
 include/linux/tipc.h                               |    2 +
 include/linux/usb/rndis_host.h                     |   13 +-
 include/linux/usb/usbnet.h                         |   18 +-
 include/linux/wireless.h                           |    8 +
 include/net/{ieee802154 =3D> }/af_ieee802154.h       |    6 +-
 include/net/arp.h                                  |    2 +-
 include/net/bluetooth/bluetooth.h                  |    5 +-
 include/net/bluetooth/hci_core.h                   |   10 +-
 include/net/bluetooth/l2cap.h                      |  134 +-
 include/net/bluetooth/rfcomm.h                     |    2 +
 include/net/cfg80211.h                             |  570 +-
 include/net/dcbnl.h                                |    2 +
 include/net/dst.h                                  |   23 +-
 include/net/dst_ops.h                              |   28 +
 include/net/genetlink.h                            |   66 +-
 include/net/{ieee802154/mac_def.h =3D> ieee802154.h} |    4 +-
 include/net/ieee802154/nl802154.h                  |   41 -
 .../netdevice.h =3D> ieee802154_netdev.h}            |    6 +-
 include/net/ip6_fib.h                              |    6 +
 include/net/ip_vs.h                                |  119 +-
 include/net/ipv6.h                                 |   12 +
 include/net/irda/ircomm_event.h                    |    2 +-
 include/net/irda/ircomm_tty_attach.h               |    4 +-
 include/net/irda/irlap_event.h                     |    2 +-
 include/net/irda/irlmp_event.h                     |    4 +-
 include/net/iw_handler.h                           |    8 +-
 include/net/mac80211.h                             |  195 +-
 include/net/neighbour.h                            |    6 +-
 include/net/net_namespace.h                        |   26 +-
 include/net/netfilter/nf_nat_core.h                |    2 +-
 include/net/netlink.h                              |    4 +-
 include/net/netns/ipv6.h                           |    3 +-
 include/net/netns/x_tables.h                       |    3 +
 include/net/nl802154.h                             |  126 +
 include/net/phonet/pn_dev.h                        |    2 +
 include/net/pkt_sched.h                            |    3 +
 include/net/rtnetlink.h                            |    5 +-
 include/net/sch_generic.h                          |   22 +-
 include/net/scm.h                                  |    2 -
 include/net/sctp/command.h                         |    3 +
 include/net/sctp/constants.h                       |   13 +-
 include/net/sctp/sctp.h                            |    7 +-
 include/net/sctp/structs.h                         |   63 +-
 include/net/sctp/user.h                            |    6 -
 include/net/tcp.h                                  |   42 +-
 include/net/transp_v6.h                            |    2 +-
 include/net/udp.h                                  |    3 +
 include/net/wpan-phy.h                             |   63 +
 include/net/xfrm.h                                 |    2 +-
 include/trace/events/skb.h                         |   20 +
 kernel/hrtimer.c                                   |    2 +
 kernel/taskstats.c                                 |   10 +-
 lib/vsprintf.c                                     |  199 +-
 net/8021q/vlan.c                                   |   27 +-
 net/8021q/vlan_dev.c                               |  107 +-
 net/8021q/vlan_netlink.c                           |   20 +
 net/8021q/vlanproc.c                               |    2 +-
 net/Kconfig                                        |   20 +
 net/Makefile                                       |    1 -
 net/appletalk/aarp.c                               |   16 +-
 net/appletalk/ddp.c                                |   70 +-
 net/atm/br2684.c                                   |   44 +-
 net/atm/clip.c                                     |   17 +-
 net/atm/lec.c                                      |   23 +-
 net/atm/mpc.c                                      |    8 +-
 net/atm/proc.c                                     |    9 +-
 net/bluetooth/Kconfig                              |    1 +
 net/bluetooth/af_bluetooth.c                       |    4 +-
 net/bluetooth/bnep/core.c                          |    5 +
 net/bluetooth/bnep/netdev.c                        |    9 +-
 net/bluetooth/hci_conn.c                           |   17 +-
 net/bluetooth/hci_core.c                           |    2 +-
 net/bluetooth/hci_event.c                          |    2 +
 net/bluetooth/hidp/core.c                          |   66 +-
 net/bluetooth/hidp/hidp.h                          |    2 +
 net/bluetooth/l2cap.c                              | 1357 ++-
 net/bluetooth/rfcomm/core.c                        |   69 +-
 net/bluetooth/sco.c                                |   49 +-
 net/bridge/br_device.c                             |    4 +-
 net/bridge/br_forward.c                            |    3 +-
 net/bridge/br_if.c                                 |    7 +
 net/bridge/br_netfilter.c                          |   98 +-
 net/bridge/br_private.h                            |    6 +-
 net/bridge/br_stp.c                                |    2 +-
 net/bridge/br_sysfs_if.c                           |   17 +
 net/bridge/netfilter/ebt_log.c                     |   29 +-
 net/bridge/netfilter/ebt_ulog.c                    |    2 +-
 net/bridge/netfilter/ebtable_broute.c              |    2 +-
 net/bridge/netfilter/ebtable_filter.c              |    8 +-
 net/bridge/netfilter/ebtable_nat.c                 |    6 +-
 net/bridge/netfilter/ebtables.c                    |   13 +-
 net/can/af_can.c                                   |   20 +-
 net/can/bcm.c                                      |   85 +-
 net/can/proc.c                                     |  281 +-
 net/compat.c                                       |   17 +-
 net/core/datagram.c                                |    3 +
 net/core/dev.c                                     |  656 +-
 net/core/drop_monitor.c                            |   14 +-
 net/core/ethtool.c                                 |   32 +-
 net/core/neighbour.c                               |   95 +-
 net/core/net-sysfs.c                               |    2 +-
 net/core/net_namespace.c                           |   35 +-
 net/core/netpoll.c                                 |    6 +-
 net/core/pktgen.c                                  |  700 +-
 net/core/rtnetlink.c                               |   37 +-
 net/core/skbuff.c                                  |    3 -
 net/core/sock.c                                    |   16 +-
 net/dcb/dcbnl.c                                    |  130 +
 net/dccp/ccids/ccid3.c                             |    4 +-
 net/dccp/feat.c                                    |    7 +-
 net/dccp/ipv4.c                                    |    2 +-
 net/dccp/ipv6.c                                    |    8 +-
 net/dccp/proto.c                                   |    4 +-
 net/decnet/dn_neigh.c                              |    6 +-
 net/decnet/dn_route.c                              |    2 +-
 net/dsa/dsa_priv.h                                 |    6 +-
 net/dsa/tag_dsa.c                                  |    2 +-
 net/dsa/tag_edsa.c                                 |    2 +-
 net/dsa/tag_trailer.c                              |    2 +-
 net/econet/af_econet.c                             |    4 +-
 net/ieee802154/Makefile                            |    2 +-
 net/ieee802154/af_ieee802154.c                     |    8 +-
 net/ieee802154/dgram.c                             |   78 +-
 net/ieee802154/netlink.c                           |  172 +-
 net/ieee802154/nl_policy.c                         |    4 +-
 net/ieee802154/raw.c                               |    5 +-
 net/ieee802154/wpan-class.c                        |  159 +
 net/ipv4/af_inet.c                                 |  124 +-
 net/ipv4/arp.c                                     |    8 +-
 net/ipv4/fib_trie.c                                |  101 +-
 net/ipv4/inet_timewait_sock.c                      |    2 +-
 net/ipv4/ip_gre.c                                  |    8 +-
 net/ipv4/ip_output.c                               |    2 +-
 net/ipv4/ipip.c                                    |    8 +-
 net/ipv4/ipmr.c                                    |    4 +-
 net/ipv4/netfilter/arp_tables.c                    |   47 +-
 net/ipv4/netfilter/arptable_filter.c               |    4 +-
 net/ipv4/netfilter/ip_tables.c                     |   51 +-
 net/ipv4/netfilter/iptable_filter.c                |   10 +-
 net/ipv4/netfilter/iptable_mangle.c                |   16 +-
 net/ipv4/netfilter/iptable_raw.c                   |   10 +-
 net/ipv4/netfilter/iptable_security.c              |   12 +-
 net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c     |   22 +-
 net/ipv4/netfilter/nf_nat_core.c                   |    8 +-
 net/ipv4/netfilter/nf_nat_rule.c                   |    6 +-
 net/ipv4/netfilter/nf_nat_standalone.c             |    8 +-
 net/ipv4/protocol.c                                |   19 +-
 net/ipv4/raw.c                                     |    9 +-
 net/ipv4/route.c                                   |   22 +-
 net/ipv4/tcp.c                                     |   16 +-
 net/ipv4/tcp_input.c                               |    5 +-
 net/ipv4/tcp_ipv4.c                                |   66 +-
 net/ipv4/tcp_minisocks.c                           |   25 +-
 net/ipv4/tcp_output.c                              |   63 +-
 net/ipv4/tcp_timer.c                               |   16 +-
 net/ipv4/udp.c                                     |  156 +-
 net/ipv4/xfrm4_policy.c                            |   37 +-
 net/ipv6/addrconf.c                                |   12 +-
 net/ipv6/af_inet6.c                                |   20 +-
 net/ipv6/icmp.c                                    |   17 +-
 net/ipv6/ip6_fib.c                                 |   16 +-
 net/ipv6/ip6_input.c                               |    6 +-
 net/ipv6/ip6_output.c                              |   44 +-
 net/ipv6/ip6_tunnel.c                              |    6 +-
 net/ipv6/ip6mr.c                                   |   11 +-
 net/ipv6/ipv6_sockglue.c                           |    5 +-
 net/ipv6/mcast.c                                   |    1 -
 net/ipv6/ndisc.c                                   |   24 +-
 net/ipv6/netfilter/ip6_tables.c                    |   48 +-
 net/ipv6/netfilter/ip6t_eui64.c                    |    9 +-
 net/ipv6/netfilter/ip6table_filter.c               |   10 +-
 net/ipv6/netfilter/ip6table_mangle.c               |   16 +-
 net/ipv6/netfilter/ip6table_raw.c                  |   10 +-
 net/ipv6/netfilter/ip6table_security.c             |   12 +-
 net/ipv6/netfilter/nf_conntrack_l3proto_ipv6.c     |   18 +-
 net/ipv6/proc.c                                    |    4 +-
 net/ipv6/protocol.c                                |   15 +-
 net/ipv6/raw.c                                     |    9 +-
 net/ipv6/route.c                                   |   34 +-
 net/ipv6/sit.c                                     |   11 +-
 net/ipv6/sysctl_net_ipv6.c                         |    4 +-
 net/ipv6/tcp_ipv6.c                                |   21 +-
 net/ipv6/udp.c                                     |  158 +-
 net/ipv6/xfrm6_policy.c                            |   38 +
 net/irda/ircomm/ircomm_event.c                     |    4 +-
 net/irda/ircomm/ircomm_tty_attach.c                |    4 +-
 net/irda/iriap.c                                   |    4 +-
 net/irda/irlan/irlan_common.c                      |    4 +-
 net/irda/irlan/irlan_eth.c                         |   10 +-
 net/irda/irlap.c                                   |    2 +-
 net/irda/irlap_event.c                             |    4 +-
 net/irda/irlmp_event.c                             |    6 +-
 net/irda/irnet/irnet_ppp.h                         |    2 +-
 net/irda/irnetlink.c                               |    2 +-
 net/irda/irproc.c                                  |   14 +-
 net/key/af_key.c                                   |    4 +-
 net/lapb/lapb_iface.c                              |    2 +-
 net/llc/llc_proc.c                                 |    2 +-
 net/mac80211/Kconfig                               |   42 +-
 net/mac80211/Makefile                              |    4 +-
 net/mac80211/agg-tx.c                              |    3 -
 net/mac80211/cfg.c                                 |  234 +-
 net/mac80211/debugfs.c                             |    2 +-
 net/mac80211/debugfs_netdev.c                      |   52 +-
 net/mac80211/debugfs_sta.c                         |   98 +-
 net/mac80211/driver-ops.h                          |  119 +-
 net/mac80211/driver-trace.c                        |    9 +
 net/mac80211/driver-trace.h                        |  672 +
 net/mac80211/event.c                               |   23 +-
 net/mac80211/ibss.c                                |   23 +-
 net/mac80211/ieee80211_i.h                         |  260 +-
 net/mac80211/iface.c                               |  170 +-
 net/mac80211/main.c                                |  200 +-
 net/mac80211/mesh.c                                |  207 +-
 net/mac80211/mesh.h                                |   35 +-
 net/mac80211/mesh_hwmp.c                           |   47 +-
 net/mac80211/mesh_pathtbl.c                        |  177 +-
 net/mac80211/mesh_plink.c                          |    2 +-
 net/mac80211/mlme.c                                | 1988 ++--
 net/mac80211/pm.c                                  |   19 +-
 net/mac80211/rate.c                                |   31 +-
 net/mac80211/rc80211_minstrel.c                    |   23 +-
 net/mac80211/rc80211_minstrel.h                    |    1 -
 net/mac80211/rc80211_minstrel_debugfs.c            |    4 +-
 net/mac80211/rc80211_pid_algo.c                    |   28 +-
 net/mac80211/rc80211_pid_debugfs.c                 |    2 +-
 net/mac80211/rx.c                                  |  259 +-
 net/mac80211/scan.c                                |  375 +-
 net/mac80211/sta_info.c                            |    2 +
 net/mac80211/sta_info.h                            |   30 +-
 net/mac80211/tx.c                                  |  580 +-
 net/mac80211/util.c                                |  130 +-
 net/mac80211/wep.c                                 |   52 +-
 net/mac80211/wep.h                                 |    7 +-
 net/mac80211/wext.c                                |  633 -
 net/mac80211/wme.c                                 |    6 +-
 net/mac80211/wme.h                                 |    3 +-
 net/mac80211/wpa.c                                 |    3 +-
 net/netfilter/ipvs/ip_vs_app.c                     |   19 +-
 net/netfilter/ipvs/ip_vs_conn.c                    |   17 +-
 net/netfilter/ipvs/ip_vs_core.c                    |   56 +-
 net/netfilter/ipvs/ip_vs_ctl.c                     |   67 +-
 net/netfilter/ipvs/ip_vs_dh.c                      |    7 +-
 net/netfilter/ipvs/ip_vs_est.c                     |    4 +
 net/netfilter/ipvs/ip_vs_ftp.c                     |    7 +-
 net/netfilter/ipvs/ip_vs_lblc.c                    |    9 +-
 net/netfilter/ipvs/ip_vs_lblcr.c                   |   17 +-
 net/netfilter/ipvs/ip_vs_lc.c                      |    5 +-
 net/netfilter/ipvs/ip_vs_nq.c                      |    5 +-
 net/netfilter/ipvs/ip_vs_proto.c                   |   12 +-
 net/netfilter/ipvs/ip_vs_proto_ah_esp.c            |    7 +-
 net/netfilter/ipvs/ip_vs_proto_tcp.c               |    7 +-
 net/netfilter/ipvs/ip_vs_proto_udp.c               |    7 +-
 net/netfilter/ipvs/ip_vs_rr.c                      |    5 +-
 net/netfilter/ipvs/ip_vs_sched.c                   |   41 +-
 net/netfilter/ipvs/ip_vs_sed.c                     |    5 +-
 net/netfilter/ipvs/ip_vs_sh.c                      |    5 +-
 net/netfilter/ipvs/ip_vs_sync.c                    |   53 +-
 net/netfilter/ipvs/ip_vs_wlc.c                     |    3 +
 net/netfilter/ipvs/ip_vs_wrr.c                     |   14 +-
 net/netfilter/ipvs/ip_vs_xmit.c                    |   43 +-
 net/netfilter/nf_conntrack_core.c                  |    8 +-
 net/netfilter/nf_conntrack_netlink.c               |   54 +-
 net/netfilter/nfnetlink.c                          |    2 +-
 net/netfilter/nfnetlink_log.c                      |    6 +-
 net/netfilter/nfnetlink_queue.c                    |    9 +-
 net/netfilter/x_tables.c                           |    7 +-
 net/netfilter/xt_CONNMARK.c                        |  134 +-
 net/netfilter/xt_DSCP.c                            |   46 -
 net/netfilter/xt_MARK.c                            |  163 +-
 net/netfilter/xt_connmark.c                        |  101 +-
 net/netfilter/xt_conntrack.c                       |  155 +-
 net/netfilter/xt_dscp.c                            |   17 -
 net/netfilter/xt_iprange.c                         |   45 +-
 net/netfilter/xt_mark.c                            |   86 +-
 net/netfilter/xt_osf.c                             |    6 +-
 net/netfilter/xt_owner.c                           |  130 +-
 net/netlabel/netlabel_kapi.c                       |    6 +-
 net/netlink/af_netlink.c                           |   74 +-
 net/netlink/genetlink.c                            |  188 +-
 net/netrom/nr_dev.c                                |    6 +-
 net/packet/af_packet.c                             |  246 +-
 net/phonet/datagram.c                              |    5 +-
 net/phonet/pep-gprs.c                              |    6 +-
 net/phonet/pep.c                                   |    7 +-
 net/phonet/pn_dev.c                                |   34 +-
 net/phonet/pn_netlink.c                            |    2 +-
 net/phonet/socket.c                                |   99 +
 net/rds/Kconfig                                    |   26 +-
 net/rds/Makefile                                   |   11 +-
 net/rds/af_rds.c                                   |    8 -
 net/rds/bind.c                                     |    3 +
 net/rds/cong.c                                     |    1 +
 net/rds/connection.c                               |   54 +-
 net/rds/ib.c                                       |    7 +-
 net/rds/ib.h                                       |   18 +-
 net/rds/ib_cm.c                                    |   62 +-
 net/rds/ib_rdma.c                                  |   12 +-
 net/rds/ib_recv.c                                  |   53 +-
 net/rds/ib_stats.c                                 |    2 +-
 net/rds/ib_sysctl.c                                |   12 +-
 net/rds/info.c                                     |    3 +
 net/rds/iw.c                                       |   16 +-
 net/rds/iw.h                                       |    1 -
 net/rds/iw_rdma.c                                  |   28 +-
 net/rds/iw_send.c                                  |    2 +-
 net/rds/iw_stats.c                                 |    2 +-
 net/rds/message.c                                  |    6 +
 net/rds/page.c                                     |    1 +
 net/rds/rdma_transport.c                           |   16 +-
 net/rds/rds.h                                      |    9 +-
 net/rds/recv.c                                     |   28 +-
 net/rds/send.c                                     |    3 +
 net/rds/stats.c                                    |    6 +-
 net/rds/tcp.c                                      |  320 +
 net/rds/tcp.h                                      |   93 +
 net/rds/tcp_connect.c                              |  153 +
 net/rds/tcp_listen.c                               |  199 +
 net/rds/tcp_recv.c                                 |  356 +
 net/rds/tcp_send.c                                 |  263 +
 net/rds/tcp_stats.c                                |   74 +
 net/rds/threads.c                                  |    2 +
 net/rds/transport.c                                |   31 +-
 net/rfkill/core.c                                  |   14 +-
 net/rose/rose_dev.c                                |    4 +-
 net/rxrpc/ar-ack.c                                 |    2 +-
 net/sched/Makefile                                 |    2 +-
 net/sched/act_api.c                                |    2 +-
 net/sched/cls_api.c                                |   12 +-
 net/sched/sch_api.c                                |  139 +-
 net/sched/sch_cbq.c                                |   38 +-
 net/sched/sch_generic.c                            |  223 +-
 net/sched/sch_hfsc.c                               |    4 +-
 net/sched/sch_htb.c                                |   35 +-
 net/sched/sch_ingress.c                            |   14 -
 net/sched/sch_mq.c                                 |  235 +
 net/sched/sch_multiq.c                             |   33 +-
 net/sched/sch_prio.c                               |   32 +-
 net/sched/sch_red.c                                |   21 -
 net/sched/sch_sfq.c                                |    7 -
 net/sched/sch_tbf.c                                |   22 -
 net/sched/sch_teql.c                               |   10 +-
 net/sctp/associola.c                               |   93 +-
 net/sctp/bind_addr.c                               |   21 +-
 net/sctp/chunk.c                                   |   62 +-
 net/sctp/debug.c                                   |   14 +-
 net/sctp/output.c                                  |  188 +-
 net/sctp/outqueue.c                                |   47 +-
 net/sctp/proc.c                                    |    4 +-
 net/sctp/protocol.c                                |   11 +-
 net/sctp/sm_make_chunk.c                           |   25 +-
 net/sctp/sm_sideeffect.c                           |   56 +-
 net/sctp/sm_statefuns.c                            |   68 +-
 net/sctp/socket.c                                  |   38 +-
 net/sctp/sysctl.c                                  |   12 +
 net/sctp/transport.c                               |    3 +
 net/tipc/bearer.c                                  |    2 +-
 net/tipc/netlink.c                                 |    2 +-
 net/tipc/socket.c                                  |    6 +
 net/unix/af_unix.c                                 |    5 +-
 net/wireless/Kconfig                               |   75 +-
 net/wireless/Makefile                              |    5 +-
 net/wireless/chan.c                                |   89 +
 net/wireless/core.c                                |  499 +-
 net/wireless/core.h                                |  249 +-
 net/wireless/debugfs.c                             |   14 +-
 net/wireless/debugfs.h                             |    8 +-
 net/wireless/ibss.c                                |  294 +-
 net/wireless/mlme.c                                |  627 +-
 net/wireless/nl80211.c                             | 1724 ++-
 net/wireless/nl80211.h                             |   71 +-
 net/wireless/reg.c                                 |  169 +-
 net/wireless/reg.h                                 |   15 +
 net/wireless/scan.c                                |  159 +-
 net/wireless/sme.c                                 |  933 ++
 net/wireless/util.c                                |  190 +-
 net/wireless/wext-compat.c                         |  880 ++-
 net/wireless/wext-compat.h                         |   49 +
 net/wireless/wext-sme.c                            |  404 +
 net/wireless/wext.c                                |  257 +-
 net/xfrm/xfrm_proc.c                               |    2 +-
 1378 files changed, 133424 insertions(+), 83544 deletions(-)
 create mode 100644 Documentation/btmrvl.txt
 create mode 100644 drivers/bluetooth/btmrvl_debugfs.c
 create mode 100644 drivers/bluetooth/btmrvl_drv.h
 create mode 100644 drivers/bluetooth/btmrvl_main.c
 create mode 100644 drivers/bluetooth/btmrvl_sdio.c
 create mode 100644 drivers/bluetooth/btmrvl_sdio.h
 create mode 100644 drivers/isdn/hardware/mISDN/avmfritz.c
 create mode 100644 drivers/isdn/hardware/mISDN/iohelper.h
 create mode 100644 drivers/isdn/hardware/mISDN/ipac.h
 create mode 100644 drivers/isdn/hardware/mISDN/isar.h
 create mode 100644 drivers/isdn/hardware/mISDN/mISDNinfineon.c
 create mode 100644 drivers/isdn/hardware/mISDN/mISDNipac.c
 create mode 100644 drivers/isdn/hardware/mISDN/mISDNisar.c
 create mode 100644 drivers/isdn/hardware/mISDN/netjet.c
 create mode 100644 drivers/isdn/hardware/mISDN/netjet.h
 create mode 100644 drivers/isdn/hardware/mISDN/speedfax.c
 create mode 100644 drivers/isdn/hardware/mISDN/w6692.c
 create mode 100644 drivers/isdn/hardware/mISDN/w6692.h
 delete mode 100644 drivers/isdn/hisax/isdnhdlc.h
 rename drivers/isdn/{hisax =3D> i4l}/isdnhdlc.c (54%)
 create mode 100644 drivers/net/can/sja1000/sja1000_isa.c
 delete mode 100644 drivers/net/netxen/netxen_nic_niu.c
 delete mode 100644 drivers/net/netxen/netxen_nic_phan_reg.h
 create mode 100644 drivers/net/phy/bcm63xx.c
 create mode 100644 drivers/net/wireless/ath/ath.h
 create mode 100644 drivers/net/wireless/ath/ath9k/btcoex.c
 create mode 100644 drivers/net/wireless/ath/ath9k/btcoex.h
 create mode 100644 drivers/net/wireless/ath/ath9k/eeprom_4k.c
 create mode 100644 drivers/net/wireless/ath/ath9k/eeprom_9287.c
 create mode 100644 drivers/net/wireless/ath/ath9k/eeprom_def.c
 rename drivers/net/wireless/ipw2x00/{ieee80211.h =3D> libipw.h} (54%)
 delete mode 100644 drivers/net/wireless/iwmc3200wifi/wext.c
 create mode 100644 drivers/net/wireless/orinoco/cfg.c
 create mode 100644 drivers/net/wireless/orinoco/cfg.h
 create mode 100644 drivers/net/wireless/p54/eeprom.c
 create mode 100644 drivers/net/wireless/p54/eeprom.h
 create mode 100644 drivers/net/wireless/p54/fwio.c
 create mode 100644 drivers/net/wireless/p54/led.c
 create mode 100644 drivers/net/wireless/p54/lmac.h
 create mode 100644 drivers/net/wireless/p54/main.c
 delete mode 100644 drivers/net/wireless/p54/p54common.c
 delete mode 100644 drivers/net/wireless/p54/p54common.h
 create mode 100644 drivers/net/wireless/p54/txrx.c
 delete mode 100644 drivers/net/wireless/rt2x00/rt2x00rfkill.c
 create mode 100644 drivers/net/wireless/rtl818x/rtl8187_rfkill.c
 create mode 100644 drivers/net/wireless/rtl818x/rtl8187_rfkill.h
 delete mode 100644 drivers/net/wireless/wl12xx/acx.c
 delete mode 100644 drivers/net/wireless/wl12xx/boot.c
 delete mode 100644 drivers/net/wireless/wl12xx/cmd.c
 delete mode 100644 drivers/net/wireless/wl12xx/init.c
 delete mode 100644 drivers/net/wireless/wl12xx/wl1251.c
 create mode 100644 drivers/net/wireless/wl12xx/wl1251_acx.c
 copy drivers/net/wireless/wl12xx/{acx.h =3D> wl1251_acx.h} (84%)
 create mode 100644 drivers/net/wireless/wl12xx/wl1251_boot.c
 rename drivers/net/wireless/wl12xx/{boot.h =3D> wl1251_boot.h} (76%)
 create mode 100644 drivers/net/wireless/wl12xx/wl1251_cmd.c
 rename drivers/net/wireless/wl12xx/{cmd.h =3D> wl1251_cmd.h} (59%)
 copy drivers/net/wireless/wl12xx/{debugfs.c =3D> wl1251_debugfs.c} (92=
%)
 copy drivers/net/wireless/wl12xx/{debugfs.h =3D> wl1251_debugfs.h} (74=
%)
 copy drivers/net/wireless/wl12xx/{event.c =3D> wl1251_event.c} (57%)
 rename drivers/net/wireless/wl12xx/{event.h =3D> wl1251_event.h} (94%)
 create mode 100644 drivers/net/wireless/wl12xx/wl1251_init.c
 copy drivers/net/wireless/wl12xx/{init.h =3D> wl1251_init.h} (53%)
 create mode 100644 drivers/net/wireless/wl12xx/wl1251_io.c
 create mode 100644 drivers/net/wireless/wl12xx/wl1251_io.h
 rename drivers/net/wireless/wl12xx/{main.c =3D> wl1251_main.c} (53%)
 rename drivers/net/wireless/wl12xx/{init.h =3D> wl1251_netlink.h} (53%=
)
 rename drivers/net/wireless/wl12xx/{ps.c =3D> wl1251_ps.c} (51%)
 rename drivers/net/wireless/wl12xx/{ps.h =3D> wl1251_ps.h} (72%)
 copy drivers/net/wireless/wl12xx/{reg.h =3D> wl1251_reg.h} (81%)
 rename drivers/net/wireless/wl12xx/{rx.c =3D> wl1251_rx.c} (68%)
 rename drivers/net/wireless/wl12xx/{rx.h =3D> wl1251_rx.h} (88%)
 create mode 100644 drivers/net/wireless/wl12xx/wl1251_sdio.c
 create mode 100644 drivers/net/wireless/wl12xx/wl1251_spi.c
 create mode 100644 drivers/net/wireless/wl12xx/wl1251_spi.h
 rename drivers/net/wireless/wl12xx/{tx.c =3D> wl1251_tx.c} (73%)
 rename drivers/net/wireless/wl12xx/{tx.h =3D> wl1251_tx.h} (93%)
 rename drivers/net/wireless/wl12xx/{wl12xx.h =3D> wl1271.h} (67%)
 create mode 100644 drivers/net/wireless/wl12xx/wl1271_acx.c
 rename drivers/net/wireless/wl12xx/{acx.h =3D> wl1271_acx.h} (73%)
 create mode 100644 drivers/net/wireless/wl12xx/wl1271_boot.c
 create mode 100644 drivers/net/wireless/wl12xx/wl1271_boot.h
 create mode 100644 drivers/net/wireless/wl12xx/wl1271_cmd.c
 create mode 100644 drivers/net/wireless/wl12xx/wl1271_cmd.h
 rename drivers/net/wireless/wl12xx/{debugfs.c =3D> wl1271_debugfs.c} (=
92%)
 copy drivers/net/wireless/wl12xx/{debugfs.h =3D> wl1271_debugfs.h} (69=
%)
 rename drivers/net/wireless/wl12xx/{event.c =3D> wl1271_event.c} (51%)
 create mode 100644 drivers/net/wireless/wl12xx/wl1271_event.h
 create mode 100644 drivers/net/wireless/wl12xx/wl1271_init.c
 create mode 100644 drivers/net/wireless/wl12xx/wl1271_init.h
 create mode 100644 drivers/net/wireless/wl12xx/wl1271_main.c
 create mode 100644 drivers/net/wireless/wl12xx/wl1271_ps.c
 rename drivers/net/wireless/wl12xx/{debugfs.h =3D> wl1271_ps.h} (60%)
 rename drivers/net/wireless/wl12xx/{reg.h =3D> wl1271_reg.h} (93%)
 create mode 100644 drivers/net/wireless/wl12xx/wl1271_rx.c
 create mode 100644 drivers/net/wireless/wl12xx/wl1271_rx.h
 rename drivers/net/wireless/wl12xx/{spi.c =3D> wl1271_spi.c} (61%)
 rename drivers/net/wireless/wl12xx/{spi.h =3D> wl1271_spi.h} (58%)
 create mode 100644 drivers/net/wireless/wl12xx/wl1271_tx.c
 create mode 100644 drivers/net/wireless/wl12xx/wl1271_tx.h
 create mode 100644 drivers/net/xilinx_emaclite.c
 create mode 100644 drivers/ssb/sdio.c
 delete mode 100644 firmware/bnx2/bnx2-mips-06-4.6.16.fw.ihex
 create mode 100644 firmware/bnx2/bnx2-mips-06-5.0.0.j3.fw.ihex
 delete mode 100644 firmware/bnx2/bnx2-mips-09-4.6.17.fw.ihex
 create mode 100644 firmware/bnx2/bnx2-mips-09-5.0.0.j3.fw.ihex
 delete mode 100644 firmware/bnx2/bnx2-rv2p-06-4.6.16.fw.ihex
 create mode 100644 firmware/bnx2/bnx2-rv2p-06-5.0.0.j3.fw.ihex
 delete mode 100644 firmware/bnx2/bnx2-rv2p-09-4.6.15.fw.ihex
 create mode 100644 firmware/bnx2/bnx2-rv2p-09-5.0.0.j3.fw.ihex
 create mode 100644 firmware/bnx2/bnx2-rv2p-09ax-5.0.0.j3.fw.ihex
 delete mode 100644 firmware/bnx2x-e1-4.8.53.0.fw.ihex
 create mode 100644 firmware/bnx2x-e1-5.0.21.0.fw.ihex
 delete mode 100644 firmware/bnx2x-e1h-4.8.53.0.fw.ihex
 create mode 100644 firmware/bnx2x-e1h-5.0.21.0.fw.ihex
 create mode 100644 firmware/cxgb3/ael2005_opt_edc.bin.ihex
 create mode 100644 firmware/cxgb3/ael2005_twx_edc.bin.ihex
 create mode 100644 firmware/cxgb3/ael2020_twx_edc.bin.ihex
 create mode 100644 include/linux/isdn/hdlc.h
 delete mode 100644 include/linux/netfilter_ipv4/ipt_CLASSIFY.h
 delete mode 100644 include/linux/netfilter_ipv4/ipt_CONNMARK.h
 delete mode 100644 include/linux/netfilter_ipv4/ipt_DSCP.h
 delete mode 100644 include/linux/netfilter_ipv4/ipt_MARK.h
 delete mode 100644 include/linux/netfilter_ipv4/ipt_NFQUEUE.h
 delete mode 100644 include/linux/netfilter_ipv4/ipt_TCPMSS.h
 delete mode 100644 include/linux/netfilter_ipv4/ipt_TOS.h
 delete mode 100644 include/linux/netfilter_ipv4/ipt_comment.h
 delete mode 100644 include/linux/netfilter_ipv4/ipt_connbytes.h
 delete mode 100644 include/linux/netfilter_ipv4/ipt_connmark.h
 delete mode 100644 include/linux/netfilter_ipv4/ipt_conntrack.h
 delete mode 100644 include/linux/netfilter_ipv4/ipt_dccp.h
 delete mode 100644 include/linux/netfilter_ipv4/ipt_dscp.h
 delete mode 100644 include/linux/netfilter_ipv4/ipt_esp.h
 delete mode 100644 include/linux/netfilter_ipv4/ipt_hashlimit.h
 delete mode 100644 include/linux/netfilter_ipv4/ipt_helper.h
 delete mode 100644 include/linux/netfilter_ipv4/ipt_iprange.h
 delete mode 100644 include/linux/netfilter_ipv4/ipt_length.h
 delete mode 100644 include/linux/netfilter_ipv4/ipt_limit.h
 delete mode 100644 include/linux/netfilter_ipv4/ipt_mac.h
 delete mode 100644 include/linux/netfilter_ipv4/ipt_mark.h
 delete mode 100644 include/linux/netfilter_ipv4/ipt_multiport.h
 delete mode 100644 include/linux/netfilter_ipv4/ipt_owner.h
 delete mode 100644 include/linux/netfilter_ipv4/ipt_physdev.h
 delete mode 100644 include/linux/netfilter_ipv4/ipt_pkttype.h
 delete mode 100644 include/linux/netfilter_ipv4/ipt_policy.h
 delete mode 100644 include/linux/netfilter_ipv4/ipt_recent.h
 delete mode 100644 include/linux/netfilter_ipv4/ipt_sctp.h
 delete mode 100644 include/linux/netfilter_ipv4/ipt_state.h
 delete mode 100644 include/linux/netfilter_ipv4/ipt_string.h
 delete mode 100644 include/linux/netfilter_ipv4/ipt_tcpmss.h
 delete mode 100644 include/linux/netfilter_ipv4/ipt_tos.h
 delete mode 100644 include/linux/netfilter_ipv6/ip6t_MARK.h
 delete mode 100644 include/linux/netfilter_ipv6/ip6t_esp.h
 delete mode 100644 include/linux/netfilter_ipv6/ip6t_length.h
 delete mode 100644 include/linux/netfilter_ipv6/ip6t_limit.h
 delete mode 100644 include/linux/netfilter_ipv6/ip6t_mac.h
 delete mode 100644 include/linux/netfilter_ipv6/ip6t_mark.h
 delete mode 100644 include/linux/netfilter_ipv6/ip6t_multiport.h
 delete mode 100644 include/linux/netfilter_ipv6/ip6t_owner.h
 delete mode 100644 include/linux/netfilter_ipv6/ip6t_physdev.h
 delete mode 100644 include/linux/netfilter_ipv6/ip6t_policy.h
 rename include/net/{ieee802154 =3D> }/af_ieee802154.h (95%)
 create mode 100644 include/net/dst_ops.h
 rename include/net/{ieee802154/mac_def.h =3D> ieee802154.h} (98%)
 delete mode 100644 include/net/ieee802154/nl802154.h
 rename include/net/{ieee802154/netdevice.h =3D> ieee802154_netdev.h} (=
95%)
 create mode 100644 include/net/nl802154.h
 create mode 100644 include/net/wpan-phy.h
 create mode 100644 net/ieee802154/wpan-class.c
 create mode 100644 net/mac80211/driver-trace.c
 create mode 100644 net/mac80211/driver-trace.h
 delete mode 100644 net/mac80211/wext.c
 create mode 100644 net/rds/tcp.c
 create mode 100644 net/rds/tcp.h
 create mode 100644 net/rds/tcp_connect.c
 create mode 100644 net/rds/tcp_listen.c
 create mode 100644 net/rds/tcp_recv.c
 create mode 100644 net/rds/tcp_send.c
 create mode 100644 net/rds/tcp_stats.c
 create mode 100644 net/sched/sch_mq.c
 create mode 100644 net/wireless/chan.c
 create mode 100644 net/wireless/sme.c
 create mode 100644 net/wireless/wext-compat.h
 create mode 100644 net/wireless/wext-sme.c
