From: David Miller <davem@davemloft.net>
Subject: [GIT]: Networking
Date: Sun, 20 Jul 2008 10:44:11 -0700 (PDT)
Message-ID: <20080720.104411.81744468.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:34485
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1757885AbYGTRoN convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 20 Jul 2008 13:44:13 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Hello Linus.  This is the main networking merge for 2.6.27

Highlights:

1) Explicit support for multiple hardware TX queues, from your's
   truly.

2) Making MIB statistics namespace aware, from Pavel Emelyanov.

3) GVRP support from Patrick McHardy.

4) Packet capture tools can now recreate the VLAN header even
   when hardware offloading of VLAN decapsulation is being
   performed.  Also from Patrick McHardy.

5) Dynamic queueing discipline hash table sizing from Patrick
   McHardy.

6) Lots of wireless stack and driver updates from John Linville
   and the wireless crew.

7) IPV6 stack improvements from Yoshifuji Hideaki and co.

8) Various wired driver updates via Jeff Garzik and all the various
   driver maintainers.

Please pull, thanks a lot!

The following changes since commit 5b664cb235e97afbf34db9c4d77f08ebd725=
335e:
  Linus Torvalds (1):
        Merge branch 'upstream-linus' of git://git.kernel.org/.../mfash=
eh/ocfs2

are available in the git repository at:

  master.kernel.org:/pub/scm/linux/kernel/git/davem/net-2.6.git master

Abhijeet Kolekar (6):
      iwlwifi : Set monitor mode for 4965
      iwlwifi : Set monitor mode for 3945
      iwlwifi : Patch adds rfkill subsystem for 3945
      iwlwifi: Remove unnecessary code
      iwlwifi: Fix LEDs for 3945
      iwlwifi: make index unsigned int for iwl_send_led_cmd

Adam Langley (3):
      tcp: Fix MD5 signatures for non-linear skbs
      tcp: options clean up
      tcp: Remove redundant checks when setting eff_sacks

Adel Gadllah (5):
      iwlwifi: fix rfkill deps and remove input device usage
      b43/b43legacy: use RFKILL_STATE_UNBLOCKED instead of RFKILL_STATE=
_ON
      b43/b43legacy: add RFKILL_STATE_HARD_BLOCKED support
      iwlwifi: remove input device and fix rfkill state
      iwl3965: remove useless network and duplicate checking

Adrian Bunk (13):
      make sta_rx_agg_session_timer_expired() static
      remove ieee80211_tx_frame()
      remove ieee80211_wx_{get,set}_auth()
      make drivers/net/atarilance.c:lance_addr_list[] static
      make hplance_{init,cleanup}_module() static
      drivers/net/mac8390.c: make functions static
      drivers/net/: remove write-only "last_dev"
      drivers/net/macsonic.c: make functions static
      net: remove CVS keywords
      irda: remove CVS keywords
      remove the strip driver
      build algorithms into the mac80211 module
      netfilter: cleanup netfilter_ipv6.h userspace header

Akinobu Mita (2):
      airo: use simple_read_from_buffer()
      iucv: fix memory leak in cpu hotplug error path.

Al Viro (1):
      misc drivers/net endianness noise

Alan Cox (5):
      ppp: push BKL down into the driver
      wanrouter: Push down BKL
      irda: Push BKL down into irda ioctl handlers
      atm: [iphase] 64-bit cleanup
      8390: Split 8390 support into a pausing and a non pausing driver =
core

Alexander Duyck (11):
      igb: fix parameter options
      igb: fix init on 82575 with MNG enabled
      igb: update ethtool stats to support multiqueue
      igb: add 82576 MAC support
      igb: Add support for quad port WOL and feature flags
      igb: add page recycling support
      igb: add support for in kernel LRO
      net: add netif_napi_del function to allow for removal of napistru=
cts
      igb: update suspend resume
      igb: unused variable warning in igb remove
      igb: Improve multiqueue AIM support

Alexey Dobriyan (2):
      netfilter: use correct namespace in ip6table_security
      netfilter: ip6table_filter in netns for real

Allan Stephens (41):
      tipc: Simplify log buffer resizing
      tipc: Provide feedback when log buffer resizing fails
      tipc: Fix recursive spinlock invocation in print buffer code
      tipc: Fix null pointer dereference in debug code
      tipc: Elimination of print buffer chaining
      [TIPC]: Cosmetic cleanup of print buffer code
      tipc: Cosmetic cleanup of system & debug output declarations
      tipc: Exclude debug-only print buffer code when not debugging
      tipc: Update version number to TIPC 1.6.4
      tipc: Enhancements to name table initialization
      tipc: Fix race condition when creating socket or native port
      tipc: Add support for customized subscription overlap handling
      tipc: Add support for customized subscription endianness
      tipc: Fix bug in topology server byte swapping routine
      tipc: Consolidate subscriber & subscriber port references
      tipc: Cosmetic cleanup of topology service code
      tipc: Fix skb_under_panic when configuring TIPC without privilege=
s
      tipc: Prevent node object duplication due to simultaneous discove=
ry
      tipc: Optimize null pointer check during neighbor discovery
      tipc: Update "previous node" indicators when node address changes
      tipc: Fix initialization sequence problems when entering network =
mode
      tipc: Fix bug in connection setup via native API
      tipc: Standardize error checking on incoming messages via native =
API
      tipc: Fix bugs in message error code display when debugging
      tipc: Fix minor bugs in link session number handling
      tipc: Minor optimizations to received message processing
      tipc: Prevent access of non-existent field in short message heade=
r
      tipc: Optimize message initialization routine
      tipc: Prevent display of name table types with no publications
      tipc: Add missing spinlock in name table display code
      tipc: Expand link sequence gap field to 13 bits
      tipc: Message header creation optimizations
      tipc: Fix bugs in rejection of message with short header
      tipc: Message rejection rework preparatory changes
      tipc: Remove unneeded parameter to tipc_createport_raw()
      tipc: Optimize pointer dereferencing when receiving stream data
      tipc: Fix race condition that could cause accept() to fail
      tipc: Eliminate improper use of TIPC_OK error code
      tipc: Fix bug in scope checking for multicast messages
      tipc: Add missing locks when inspecting node list & link list
      tipc: Optimization to multicast name lookup algorithm

Andrew Morton (1):
      wireless: fix "iwlwifi: unify init driver flow"

Andy Gospodarek (1):
      e1000: remove e1000_clean_tx_irq call from e1000_netpoll

Assaf Krauss (6):
      iwlwifi enabling IBSS (Ad-Hoc) mode
      iwlwifi: Fix mode changes (ad-hoc <--> managed)
      mac80211: 11h Infrastructure - Parsing
      mac80211: 11h - Handling measurement request
      mac80211: add beacon timestamp to beacon template in IBSS
      iwlwifi: adjust TSF in IBSS

Atsushi Nemoto (1):
      zd1211rw: Use DMA-aware buffer for usb transfer

Auke Kok (4):
      e1000: remove PCI Express device IDs
      igb: eliminate hw from the hw_dbg macro arguments
      igb: reenable CRC stripping in hardware
      igb: Increment driver version

Ben Dooks (10):
      DM9000: Add support for DM9000A and DM9000B chips
      DM9000: Cleanups after the resource changes
      DM9000: Cleanup source code
      DM9000: Cleanup source code - remove forward declerations
      DM9000: Use NSR to determine link-status on internal PHY
      DM9000: Allow the use of the NSR register to get link status.
      DM9000: Add missing msleep() in EEPROM wait code.
      DM9000: Re-unite menuconfig entries for DM9000 driver
      DM9000: Remove DEFAULT_TRIGGER for request_irq() flags.
      DM9000: Add documentation for the driver.

Ben Hutchings (5):
      sfc: Use kernel I2C system and i2c-algo-bit driver
      sfc: Reduce I2C udelay to 5 resulting in a clock frequency of 100=
 kHz
      net: Disable LRO on devices that are forwarding
      net: Discard and warn about LRO'd skbs received for forwarding
      e1000: resolve tx multiqueue bug

Benjamin Li (8):
      bnx2: Remove the rx_offset field from the bnx2 structure.
      bnx2: Rename RX_COPY_THRESH to BNX2_RX_COPY_THRESH.
      bnx2: Pre-initialize struct cpu_reg.
      bnx2: Support secondary MAC addresses.
      bnx2: Update TPAT firmware
      bnx2: Add TX multiqueue support.
      bnx2: Fix Sparse warnings
      bnx2: Update version to 1.7.9.

Benjamin Thery (1):
      ipv6 netns: Address labels per namespace

Bernard Pidoux (1):
      rose: improving AX25 routing frames via ROSE network

Bill Moss (1):
      iwl3945: do not delay hardware scan if it is a direct scan

Bob Copeland (2):
      ath5k: Fix loop variable initializations
      ath5k: convert LED code to use mac80211 triggers

Brian Haley (1):
      net: change proto destroy method to return void

Brice Goglin (3):
      myri10ge: add routines for multislices
      myri10ge: add multislices support
      myri10ge: add Direct Cache Access support

Bruno Randolf (3):
      zd1211rw: initial IBSS support
      mac80211: use hardware flags for signal/noise units
      mac80211: make rx radiotap header more flexible

Chas Williams (3):
      atm: [suni] add support for setting loopback and framing modes
      atm: [he] remove #ifdef clutter
      atm: [fore200e] convert to use request_firmware()

Dale Farnsworth (1):
      mv643xx_eth: new maintainer

Daniel Drake (1):
      zd1211rw: beacon config error checking

Daniel Lezcano (1):
      tcp: fix kernel panic with listening_get_next

Daniel Walker (6):
      ps3: gelic: scan_lock semaphore to mutex
      ps3: gelic: assoc_stat_lock semaphore to mutex
      ps3: gelic: updown_lock semaphore to mutex
      ps3: gelic: scan_lock semaphore to mutex
      ps3: gelic: assoc_stat_lock semaphore to mutex
      ps3: gelic: updown_lock semaphore to mutex

David S. Miller (118):
      Merge branch 'upstream-next' of master.kernel.org:/.../jgarzik/ne=
tdev-2.6
      Merge branch 'master' of git://git.kernel.org/.../davem/net-2.6
      Merge branch 'master' of git://git.kernel.org/.../linville/wirele=
ss-next-2.6
      Merge branch 'master' of master.kernel.org:/.../davem/net-2.6
      wanrouter: Fix ioctl handler declaration.
      Merge branch 'upstream-next-davem' of master.kernel.org:/.../jgar=
zik/netdev-2.6
      Merge branch 'master' of master.kernel.org:/.../linville/wireless=
-next-2.6
      Merge branch 'master' of master.kernel.org:/.../davem/net-2.6
      Merge branch 'net-next-2.6-misc-20080612a' of git://git.linux-ipv=
6.org/gitroot/yoshfuji/linux-2.6-next
      Merge branch 'davem-next' of master.kernel.org:/.../jgarzik/netde=
v-2.6
      Merge branch 'master' of master.kernel.org:/.../davem/net-2.6
      Merge branch 'master' of master.kernel.org:/.../linville/wireless=
-next-2.6
      Merge branch 'master' of master.kernel.org:/.../davem/net-2.6
      wext: Remove inline from get_priv_size() and adjust_priv_size().
      wext: Make adjust_priv_size() take a "struct iw_point *".
      wext: Extract standard call iw_point handling into seperate funct=
ion.
      wext: Extract private call iw_point handling into seperate functi=
ons.
      wext: Pull ioctl permission checking out into helper function.
      wext: Parameterize the standard/private handlers.
      wext: Pass iwreq pointer down into standard/private handlers.
      wext: Pull top-level ioctl dispatch logic into helper function.
      wext: Dispatch and handle compat ioctls entirely in net/wireless/=
wext.c
      wext: Remove compat handling from fs/compat_ioctl.c
      wext: Create IW_REQUEST_FLAG_COMPAT and set it as needed.
      wext: Emit event stream entries correctly when compat.
      sctp: Kill SCTP_SOCK_SLEEP_{PRE,POST}, unused.
      decnet: Remove SOCK_SLEEP_{PRE,POST} usage.
      net: Kill SOCK_SLEEP_PRE and SOCK_SLEEP_POST, no users.
      llc: Use sock_graft() instead of by-hand version.
      ax25: Use sock_graft() and remove bogus sk_socket and sk_sleep in=
it.
      netrom: Use sock_graft() and remove bogus sk_socket and sk_sleep =
init.
      rose: Use sock_graft() and remove bogus sk_socket and sk_sleep in=
it.
      x25: Use sock_graft() and remove bogus sk_socket and sk_sleep ini=
t.
      econet: Use sock_orphan() instead of open-coded (and buggy) varia=
nt.
      x25: Use sock_orphan() instead of open-coded (and buggy) variant.
      netrom: Kill spurious NULL'ing of sk->sk_socket.
      ax25: Fix std timer socket destroy handling.
      Merge branch 'davem-next' of master.kernel.org:/.../jgarzik/netde=
v-2.6
      net: Add sk_set_socket() helper.
      Merge branch 'master' of master.kernel.org:/.../davem/net-2.6
      Merge branch 'master' of master.kernel.org:/.../davem/net-2.6
      Merge branch 'davem-next' of master.kernel.org:/.../jgarzik/netde=
v-2.6
      Merge branch 'master' of master.kernel.org:/.../linville/wireless=
-next-2.6
      Merge branch 'net-next-2.6-v6ready-20080703' of git://git.linux-i=
pv6.org/gitroot/yoshfuji/linux-2.6-next
      Merge branch 'davem-next' of master.kernel.org:/.../jgarzik/netde=
v-2.6
      Merge branch 'master' of master.kernel.org:/.../linville/wireless=
-next-2.6
      Merge branch 'master' of master.kernel.org:/.../davem/net-2.6
      Merge branch 'master' of master.kernel.org:/.../linville/wireless=
-next-2.6
      Merge branch 'master' of master.kernel.org:/.../davem/net-2.6
      pkt_sched: Remove comment reference to old style TX locking.
      netdev: Create netdev_queue abstraction.
      pkt_sched: Remove 'dev' member of struct Qdisc.
      netdev: Move queue_lock into struct netdev_queue.
      netdev: The ingress_lock member is no longer needed.
      netdev: Move rest of qdisc state into struct netdev_queue
      netdev: Kill qdisc_ingress, use netdev->rx_queue.qdisc instead.
      pkt_sched: Kill stats_lock member of struct Qdisc.
      pkt_sched: Make netem queue agnostic.
      netdev: Move next_sched into struct netdev_queue.
      pkt_sched: Add qdisc_reset_all_tx().
      pkt_sched: Add qdisc_all_tx_empty()
      net: Clean up explicit ->tx_queue references in link watch.
      pkt_sched: Add qdisc_tx_is_noop() helper and use in IPV6.
      mac80211: Decrease number of explicit ->tx_queue references.
      netdev: Move gso_skb into netdev_queue.
      netdev: Make netif_schedule() routines work with netdev_queue obj=
ects.
      pkt_sched: Make qdisc_run take a netdev_queue.
      netdev: Move _xmit_lock and xmit_lock_owner into netdev_queue.
      net: Delete NETDEVICES_MULTIQUEUE kconfig option.
      netdev: Move atomic queue state bits into netdev_queue.
      netfilter: Let nf_ct_kill() callers know if del_timer() returned =
true.
      Merge branch 'master' of master.kernel.org:/.../davem/net-2.6
      Merge branch 'master' of git://eden-feed.erg.abdn.ac.uk/net-next-=
2.6
      Merge branch 'master' of git://git.kernel.org/.../linville/wirele=
ss-next-2.6
      Merge branch 'davem-next' of master.kernel.org:/.../jgarzik/netde=
v-2.6
      netdev: Add addr_list_lock to struct net_device.
      netdev: Add netdev->addr_list_lock protection.
      netdev: Do not use TX lock to protect address lists.
      Merge branch 'stealer/ipvs/sync-daemon-cleanup-for-next' of git:/=
/git.stealer.net/linux-2.6
      igb: Kill CONFIG_NETDEVICES_MULTIQUEUE references, no longer exis=
ts.
      netdev: Allocate multiple queues for TX.
      netdev: Kill NETIF_F_MULTI_QUEUE.
      pkt_sched: Remove RR scheduler.
      mac80211: Temporarily mark QoS support BROKEN.
      net: Use queue aware tests throughout.
      netdev: Kill struct net_device_subqueue and netdev->egress_subque=
ue*
      netdev: netdev_priv() can now be sane again.
      netdev: Add netdev->select_queue() method.
      mac80211: Reimplement WME using ->select_queue().
      net: Implement simple sw TX hashing.
      netdev: Convert all drivers away from netif_schedule().
      netdev: Kill plain netif_schedule()
      niu: Add TX multiqueue support.
      pkt_sched: Move gso_skb into Qdisc.
      pkt_sched: Make QDISC_RUNNING a qdisc state.
      pkt_sched: Add and use qdisc_root() and qdisc_root_lock().
      pkt_sched: Schedule qdiscs instead of netdev_queue.
      pkt_sched: dev_init_scheduler() does not need to lock qdisc tree.
      pkt_sched: Perform bulk of qdisc destruction in RCU.
      pkt_sched: Use per-queue locking in shutdown_scheduler_queue.
      pkt_sched: Remove qdisc_lock_tree usage in cls_api.c
      pkt_sched: Kill qdisc_lock_tree usage in cls_route.c
      netdevice: Move qdisc_list back into net_device proper.
      pkt_sched: Make qdisc grafting locking more specific.
      pkt_sched: Rework {sch,tbf}_tree_lock().
      pkt_sched: Kill qdisc_lock_tree and qdisc_unlock_tree.
      pkt_sched: Kill netdev_queue lock.
      pkt_sched: Add multiqueue handling to qdisc_graft().
      pkt_sched: Don't used locked skb_queue_purge() in __qdisc_reset_q=
ueue()
      pkt_sched: Make default qdisc nonshared-multiqueue safe.
      Merge branch 'master' of master.kernel.org:/.../torvalds/linux-2.=
6
      Revert "remove the strip driver"
      pkt_sched: Get rid of u32_list.
      pkt_sched: Manage qdisc list inside of root qdisc.
      pkt_sched: Fix noqueue_qdisc initialization.
      Merge branch 'master' of git://git.kernel.org/.../holtmann/blueto=
oth-2.6
      highmem: Export totalhigh_pages.
      iucv: Fix bad merging.

David Woodhouse (4):
      libertas: Increase priority of 'unknown command' warnings
      libertas: fix multicast filtering on eth and msh interfaces
      libertas: Add reset_card() callback to hardware driver
      libertas: provide reset_card() callback on OLPC

Denis V. Lunev (14):
      netlink: Remove nonblock parameter from netlink_attachskb
      netns: add namespace parameter to rt_cache_flush
      net: add fib_rules_ops to flush_cache method
      ipv4: remove static flush_delay variable
      netns: register net.ipv4.route.flush in each namespace
      netns: make rt_secret_rebuild timer per namespace
      netns: add struct net parameter to rt_cache_invalidate
      ipv4: pass current value of rt_genid into rt_hash
      netns: place rt_genid into struct net
      netns: selective flush of rt_cache
      ipv4: remove flush_mutex from ipv4_sysctl_rtcache_flush
      netlabel: return msg overflow error from netlbl_cipsov4_list fast=
er
      ipv6: remove unused parameter from ip6_ra_control
      ipv6: remove unused macros from net/ipv6.h

Divy Le Ray (4):
      cxgb3 - Fix dma mapping error path
      cxgb3 - Add page support to jumbo frame Rx queue
      cxgb3 - Add LRO support
      cxgb3 - add missing adapter type for RDMA

Eilon Greenstein (9):
      bnx2x: Rename bnx2x.c to bnx2x_main.c
      bnx2x: New init infrastructure
      bnx2x: Remove old microcode
      bnx2x: New microcode part 1/3
      bnx2x: New microcode part 2/3
      bnx2x: New microcode part 3/3
      bnx2x: Add support for BCM57711 HW
      bnx2x: Re-factor Tx code
      bnx2x: Update version

Emmanuel Grumbach (53):
      iwlwifi: HW dependent run time calibration
      iwlwifi: HW crypto acceleration fixes
      iwlwifi: remove uneeded callback
      iwlwifi: CT-Kill configuration fix
      iwlwifi: HT IE in probe request clean up
      iwlwifi: clean up register names and defines
      iwlwifi: move Flow Handlers define to iwl-fh.h
      iwlwifi: move verify_ucode functions to iwl-core
      iwlwifi: move hw_rx_handler_setup to iwl-4965.c
      iwlwifi-5000: update the CT-Kill value for 5000 series
      iwlwifi-5000: add run time calibrations for 5000
      iwlwifi-5000: update the byte count in SCD
      iwlwifi: move iwl4965_init_alive_start to iwl-4965.c
      iwlwifi: don't switch to SGI if not supported by AP
      iwlwifi: clean up and bug fix for security
      mac80211: sends HT IE to user level through wext
      mac80211: allow disable FAT in specific configurations
      iwlwifi: disable FAT channel when not permitted
      iwlwifi: fix a memory leak in scan
      iwlwifi: remove debugfs entries before cfg80211
      iwlwifi: send calibration results as HUGE commands
      iwlwifi: removes the RUN_TIME_CALIB ifdef
      iwlwifi: clean up in setup/cancel deferred work
      iwlwifi: add possibility to disable tx_power calibration
      iwlwifi: remove redundant flags regarding to FAT channel
      iwlwifi: fix bug when moving from 11gn to 11a or 11an to 11g
      iwlwifi: fix resart flow after fw error
      iwlwifi: add bad length check for WEP keys
      iwlwifi: move iwl4965_rf_kill_ct_config to iwl-core.c
      iwlwifi: retfactor get_temperature functions
      iwlwifi: remove dead code iwl4965_calc_db_from_ratio
      iwlwifi: general code clean up
      iwlwifi: remove iwlcore_low_level_notify
      iwlwifi: unify SW rf-kill flow
      mac80211: don't return -EINVAL upon iwconfig wlan0 rts auto
      mac80211: update the authentication method
      mac80211: add last beacon time in scan list
      iwlwifi: better station table maintenance
      iwlwifi: add REPLY_TX_POWER_DBM_CMD to get_cmd_string
      iwlwifi: send ADD_STA before RXON with assoc bit
      iwlwifi: move RX stats to core, and move temperature to handler
      iwlwifi: don't send REPLY_REMOVE_ALL_STA upon exit
      iwlwifi: move RX handlers to iwl-rx.c
      iwlwifi: remove useless network and duplicate checking
      iwlwifi: setup compressed BA handler
      iwlwifi: don't bring up interface if RF-kill avoids radio
      iwlwifi: blocking mac_start until uCode is complete
      iwlwifi: clean up HW RF-kill state machine and restarts
      mac80211: add support for iwconfig wlanX frag auto
      mac80211: Fix ieee80211_rx_reorder_ampdu: ignore QoS null packets
      mac80211: dont add a STA which is not in the same IBSS
      iwlwifi: fixes RTS / CTS support
      iwlwifi: make iwl4965_mac_conf_tx in atomic context

Eric Dumazet (1):
      udp: sk_drops handling

Eric W. Biederman (1):
      wireless: Add missing locking to cfg80211_dev_rename

Ester Kummer (9):
      mac80211: correct skb allocation
      iwlwifi: move per driverdebug_level to per device
      iwlwifi: move debug_level to sysfs/bus/pci/devices
      iwlwifi: update levels of debug prints
      iwlwifi: adding parameter of fw_restart
      iwlwifi: trigger event log from debugfs
      iwlwifi: move iwl_dump_nic_error_log to iwlcore module
      iwlwifi: adding channels to sysfs
      mac80211: removing duplicated parsing of information elements

Esti Kummer (1):
      iwlwifi: adding pci device ids to iwl_hw_card_ids

=46abian Hugelshofer (2):
      netfilter: nf_conntrack: properly account terminating packets
      netfilter: ctnetlink: include conntrack status in destroy event m=
essage

=46abien Crespel (1):
      rfkill: drop current_state from tasks in rfkill-input

=46lorian Westphal (2):
      sctp: Don't abort initialization when CONFIG_PROC_FS=3Dn
      sctp: Prevent uninitialized memory access

=46rancois Romieu (13):
      r8169: multicast register update (sync with Realtek's 8.004.00 81=
68 driver)
      r8169: remove non-napi code
      netdev: remove unused S2IO_NAPI
      starfire: delete non NAPI code from the driver.
      amd8111e: delete non NAPI code from the driver.
      via-velocity: remove the bounce buffers
      via-velocity: lean and clean velocity_init_rings
      via-velocity: move residual free rx descriptors count register up=
date
      via-velocity: add velocity_set_rxbufsize helper
      cxgb: delete non NAPI code from the driver.
      via-rhine: delete non NAPI code from the driver.
      gianfar: delete non NAPI code from the driver.
      ucc_geth: delete non NAPI code from the driver.

Gerrit Renker (4):
      dccp ccid-3: Fix error in loss detection
      dccp: Upgrade NDP count from 3 to 6 bytes
      dccp ccid-3: Fix a loss detection bug
      dccp ccid-3: Length of loss intervals

Gertjan van Wingerde (10):
      rt2x00: Fix queue related oops in case of deselected mac80211 mul=
ti-queue feature.
      rt2x00: Only initialize the minimum needed fields of PCI TX descr=
iptors.
      rt2x00: Cleanup struct skb_frame_desc.
      rt2x00: Centralize RX packet alignment handling in rt2x00lib.
      rt2x00: Fix double usage of skb->cb in USB RX path.
      rt2x00: Rework alignment check.
      rt2x00: Properly clean up beacon skbs.
      rt2x00: Convert rt2x00 to use generic DMA-mapping API
      rt2x00: Centralize allocation of RX skbs.
      rt2x00: Replace statically allocated DMA buffers with mapped skb'=
s.

Grant Grundler (1):
      drivers/net/tulip: update first comment in tulip files

Greg Kroah-Hartman (1):
      HSO: add option hso driver

Gregory Greenman (3):
      iwlwifi: get_hw_cmd_size
      iwlwifi: use uCode error and event tables pointer w.r.t loaded im=
age
      iwlwifi: configure uCode to use open loop tx power algorithm

Guy Cohen (9):
      iwlwifi: remove support for Narrow Channel (10Mhz)
      iwlwifi: HT antenna/chains overhaul
      iwlwifi: TLC modifications
      iwlwifi: rate scale module cleanups
      iwlwifi: rate scale restructure toggle_antenna functions
      iwlwifi: rs fix wrong parenthesizing in rs_get_lower_rate functio=
n
      iwlwifi: rate sacaling fixes
      iwlwifi: more RS improvements
      iwlwifi: fix in-column rate scaling

Harvey Harrison (44):
      mac80211: remove unnecessary byteshifts in frame control testing
      wireless: use get/put_unaligned_* helpers
      mac80211: tkip.c use kernel-provided infrastructure
      b43: replace limit_value macro with clamp_val
      b43legacy: replace limit_value macro with clamp_val
      b43: use the bitrev helpers rather than rolling a private one
      mac80211: michael.c use kernel-provided infrastructure
      mac80211: introduce struct michael_mic_ctx and static helpers
      mac80211: add const, remove unused function, make one function st=
atic
      mac80211: add a struct to hold tkip context
      mac80211: tkip.c use struct tkip_ctx in phase 1 key mixing
      mac80211: tkip.c use struct tkip_ctx in phase 2 key mixing
      bluetooth: hci_bcsp.c small cleanups/api users
      mac80211: add helpers for frame control testing
      mac80211: remove ieee80211_get_morefrag
      mac80211: make ieee80211_get_hdrlen_from_skb return unsigned
      mac80211: add utility function to get header length
      mac80211: wpa.c use new access helpers
      mac80211: use new helpers in util.c - ieee80211_get_bssid()
      mac80211: wme.c use new helpers
      mac80211: rx.c use new helpers
      mac80211: tkip.c consolidate tkip IV writing in helper
      mac80211: tkip.c fold ieee80211_gen_rc4key into its one caller
      mac80211: tkip.c use a local struct tkip_ctx in ieee80211_get_tki=
p_key
      ath5k: use frame control helpers
      zd1211rw: use frame control helpers
      b43: use frame control helpers
      b43legacy: use frame control helpers
      adm8211: remove unnecessary protected bit mask/check
      mac80211: wep.c use new frame control helpers
      mac80211: tx.c use new frame control helpers
      mac80211: rx.c use new frame control helpers
      mac80211: mlme.c use new frame control helpers
      tulip: remove wrapper around get_unaligned
      mac80211: move QOS control helpers into ieee80211.h
      mac80211: use symbolic defines in wpa.c
      mac80211: remove one user of ieee80211_get_hdr_info
      mac80211: remove ieee80211_get_hdr_info
      mac80211: remove trivial rx_data->fc users
      mac80211: wpa.c remove rx/tx_data ->fc users
      mac80211: pass scratch buffer directly, remove additional pointer=
s
      mac80211: aes_ccm.c remove crypto wrapper and extra args
      net: make __skb_splice_bits static
      sctp: remove unnecessary byteshifting, calculate directly in big-=
endian

Heiko Carstens (2):
      iucv: fix section mismatch warning.
      iucv: prevent cpu hotplug when walking cpu_online_map.

Helmut Schaa (1):
      iwlwifi: fix typo which caused iwl_get_tx_fail_reason to ever ret=
urn an empty string

Henrique de Moraes Holschuh (16):
      rfkill: clarify meaning of rfkill states
      rfkill: fix minor typo in kernel doc
      rfkill: handle SW_RFKILL_ALL events
      rfkill: add parameter to disable radios by default
      rfkill: add read-write rfkill switch support
      rfkill: add the WWAN radio type
      rfkill: rework suspend and resume handlers
      rfkill: add notifier chains support
      rfkill: add type string helper
      rfkill: add uevent notifications
      rfkill: do not allow userspace to override ALL RADIOS OFF
      rfkill: document rw rfkill switches and clarify input subsystem i=
nteractions
      rfkill: rename the rfkill_state states and add block-locked state
      rfkill: improve documentation for kernel drivers
      rfkill: some minor kernel-doc changes for rfkill_toggle_radio
      rfkill: ignore errors from rfkill_toggle_radio in rfkill_add_swit=
ch

Herton Ronaldo Krzesinski (1):
      rtl8187: use different ANAPARAM*_OFF values for 8187B

Hin-Tak Leung (6):
      rtl8187: updating rtl8187.h to support RTL8187B
      rtl8187: updating rtl818x.h to support RTL8187B
      rtl8187: updating rtl8187_rtl8225.c to support RTL8187B
      rtl8187: change rtl8187_dev.c to support RTL8187B (part 1)
      rtl8187: change rtl8187_dev.c to support RTL8187B (part 2)
      rtl8187: updating Kconfig to support RTL8187B

Holger Schurig (15):
      libertas: debug output tweaks for lbs_thread
      libertas: make some functions void
      libertas: allow removal of card at any time
      libertas: remove lbs_get_data_rate()
      libertas: reduce command retry time
      libertas: don't spin_unlock_irq() twice
      libertas: speeds up downloading of CF firmware
      libertas: use lbs_pr_XX instead of printk
      libertas: before sleeping, check for a command result
      libertas: fix compact flash interrupt handling
      libertas: unify various CF-related defines
      libertas: fix interrupt issue
      libertas: document register meanings
      libertas: check for old, unsupported hardware
      libertas: rename some registers to clarify their meaning

Huang Weiyi (1):
      b43: nphy.c remove duplicated include

Ihar Hrachyshka (1):
      rtl8187: Fixed section mismatch in rtl8187_dev.c

Ilpo J=E4rvinen (1):
      tcp: Reorganize tcp_sock to fill 64-bit holes & improve locality

Ivo van Doorn (51):
      mac80211: Replace ieee80211_tx_control->key_idx with ieee80211_ke=
y_conf
      mac80211: Add IEEE80211_KEY_FLAG_PAIRWISE
      rt2x00: Support hardware RTS and CTS-to-self frames
      rt2x00: Remove DRIVER_SUPPORT_MIXED_INTERFACES
      rt2x00: Use rt2x00 queue numbering
      rt2x00: Add helper macros
      rt2x00: Fix kernel-doc
      rt2x00: Release rt2x00 2.1.5
      rt2x00: Clarify supported chipsets in Kconfig
      mac80211: Set IEEE80211_TXPD_REQ_TX_STATUS for all TX frames
      rt2x00: trim skb_frame_desc to 32 bytes
      rt2x00: Fix TX status reporting
      rt2x00: Remove ieee80211_tx_control argument from write_tx_desc()
      rt2x00: Preserve descriptor information after memmove()
      rt2x00: Split rt2x00lib_write_tx_desc()
      rt2x00: Remove redundant flags/dev_flags initializations
      rt2x00: Merge RX and TX entry private data
      rt2x00: Remove extra +
      rt2x00: Release rt2x00 2.1.6
      rt2x00: Calculate register offset during compile time
      rt2x00: Cleanup/optimize set_state() function callback function
      rt2x00: Move led initialization into function
      rt2x00: Remove CTS/RTS check in tx()
      rt2x00: Removed unused descriptor read in txdone
      rt2x00: Make rt2x00_set/get_field macros
      rt2x00: Release rt2x00 2.1.7
      rt2x00: Fix queue initialization
      rt2x00: Implement rt2x00usb_kick_tx_queue()
      rt2x00: Move generic TX frame writing code into rt2x00queue
      rt2x00: Don't kick TX queue after each frame
      rt2x00: Use __builtin_choose_expr() instead of ?:
      rt2x00: Clear IEEE80211_TX_CTL_USE_RTS_CTS flag for RTS frame
      rt2x00: Remove unused defines
      rt2x00: Use ieee80211 fc handlers
      rt2x00: Cleanup symbol exports
      rt2x00: Fix sparse warning on nested container_of()
      rt2x00: Increase queue size
      rt2x00: Release rt2x00 2.1.8
      rt2x00: Remove duplicate deinitialization
      rt2x00: kill URB for all TX queues during disable_radio()
      mac80211: Add RTNL warning for workqueue
      mac80211: Don't request encryption for probe response
      rt2x00: Remove input_polldev requirements for rfkill
      rt2x00: Decrease alignment headroom
      rt2x00: Use ieee80211_hw->workqueue again
      rt2x00: Report RX end time for rt2400pci
      rt2x00: Fix register comments
      rt2x00: Fix NULL pointer error in adhoc/master mode
      rt2x00: Add support for CTS protection in rt2x00lib
      rt2x00: Reorganize beacon handling
      rt2x00: Reset LED assoc status after firmware update

James Morris (2):
      netfilter: ip_tables: add iptables security table for mandatory a=
ccess control rules
      netfilter: ip6_tables: add ip6tables security table

Javier Cardona (4):
      libertas: Extend MESH_CONFIG command to access non-volatile confi=
guration
      libertas: sysfs interface for accessing non-volatile configuratio=
n
      libertas: sysfs interface for accessing default mesh channel
      libertas: rate adaptation configuration via iwconfig.

Jay Vosburgh (6):
      bonding: Use msecs_to_jiffies, eliminate panic
      bonding: remove test for IP in ARP monitor
      bonding: refactor ARP active-backup monitor
      bonding: Add "follow" option to fail_over_mac
      bonding: Rework / fix multiple gratuitous ARP support
      bonding: Allow setting max_bonds to zero

Jeb Cramer (1):
      igb: add DCA support

Jeff Garzik (6):
      drivers/net/lib8390: fix warning, trim trailing whitespace
      [netdrvr] Trim trailing whitespace for several drivers
      Merge branch 'for-2.6.27' of git://git.marvell.com/mv643xx_eth in=
to upstream-next
      [netdrvr] fealnx: clean up nasty mess of arch ifdefs
      [netdrvr] kill sync_irq-before-freq_irq pattern
      Merge branch 'r8169-next' of git://git.kernel.org/.../romieu/netd=
ev-2.6 into upstream-next

Jeff Kirsher (7):
      ixbge: allow vlan devices to use TSO and TCP CSUM offload
      igb: allow vlan devices to use TSO and TCP CSUM offload
      e1000e: allow VLAN devices to use TSO and TCP CSUM offload
      MAINTAINERS
      igb: limit EEPROM access
      igb: cleanup function header comments
      igb/ixgbe/e1000e: resolve tx multiqueue bug

Jesse Brandeburg (25):
      ixgb: maybe stop tx port missed a piece
      ixgb: repeat 32 bit ioremap cleanup
      ixgb: fix bug in descriptor ring due to prefetch corruption
      ixgb: leave room for extra hardware memory usage
      ixgb: check down state before enable irq
      ixgb: don't allow too small MTU
      ixgb: move time stamp set before setting dma pointer
      ixgb: fix race on rx_buffer_len in mtu change
      ixgb: fix unload race with timers
      ixgb: remove lltx support and update tx routine
      ixgb: update readme text
      ixgb: add copybreak parameter
      ixgb: clean up un-necessary declarations
      ixgb: format all if( to be if (
      ixgb: cleanup space after while
      ixgb: whitespace fixups
      ixgb: fix spelling errors
      ixgb: trivial fix space after for
      ixgb: cleanup checkpatch suggestions that are relevant
      ixgb: rx cleanup performance improvements
      ixgb: clean up assignments inside if statements
      ixgb: audit use of dev_kfree_skb_any
      ixgb: cleanup header
      ixgb: make NAPI the only option and the default
      ixgb: update copyright dates and versions

Johann Felix Soden (1):
      net: Remove references to wan-router.txt in Kconfigs

Johannes Berg (41):
      mac80211: a few code cleanups
      mac80211: clean up get_tx_stats callback
      mac80211: remove queue info from ieee80211_tx_status
      mac80211: QoS related cleanups
      mac80211: fix wme code
      mac80211: require four hardware queues for QoS/HT
      mac80211: proper STA info locking
      mac80211: fix queue constant confusion
      mac80211: fix bugs in queue handling functions
      mac80211: let drivers wake but not start queues
      mac80211: use rate index in TX control
      mac80211: reorder some transmit handlers
      mac80211: move TX info into skb->cb
      mac80211: dont allow fragmentation and requeuing on A-MPDU queues
      mac80211: use multi-queue master netdevice
      mac80211: remove channel use statistics
      b43: enable mesh
      mac80211: clean up skb reallocation code
      ath5k: use IEEE80211_SKB_CB
      b43legacy: fix build errors when DMA or PIO are not selected
      p54: fix skb->cb tx info conversion
      mac80211: fix rate control initialisation
      mac80211: remove shared key todo
      mac80211: use separate spinlock for sta flags
      mac80211: add single function calling tx handlers
      mac80211: rename TKIP debugging Kconfig symbol
      mac80211: make workqueue freezable
      mac80211: fix tx fragmentation
      mac80211: get rid of function pointers in TX path
      mac80211: get rid of function pointers in RX path
      mac80211: rework debug settings and make debugging safer
      mac80211: make master netdev handling sane
      mac80211: revamp virtual interface handling
      mac80211: push interface checks down
      mac80211: revamp beacon configuration
      mac80211: fix RX sequence number check
      wext: make sysfs bits optional and deprecate them
      mac80211: fix TX sequence numbers
      mac80211: fix struct ieee80211_tx_queue_params
      mac80211 hwsim: fix endianness bug
      wireless: fix warnings from QoS patch

John W. Linville (7):
      wireless: fix warning introduced by "mac80211: QoS related cleanu=
ps"
      rt2x00dev.c: fix-up merge damage
      net/mac80211/ieee80211_i.h: fix-up merge damage
      Merge master.kernel.org:/.../davem/wireless-2.6
      ath5k: remove now unused variable declared in ath5k_tx
      wireless: remove RFKILL_STATE_HARD_BLOCKED warnings
      iwl-rfkill.c: correct 'recieved' typo

Joonwoo Park (7):
      textsearch: support for case insensitive searching
      textsearch: ts_bm: support case insensitive searching in Boyer-Mo=
ore algorithm
      textsearch: ts_kmp: support case insensitive searching in Knuth-M=
orris-Pratt algorithm
      textsearch: ts_fsm: return error on request for case insensitive =
search
      textsearch: convert kmalloc + memset to kzalloc
      netfilter: fix string extension for case insensitive pattern matc=
hing
      vlan: Use is_vlan_dev()

Jorge Boncompte [DTI2] (1):
      atm: [iphase] move struct suni_priv to suni.h

Josh Boyer (1):
      ibm_emac: Remove the ibm_emac driver

Jouni Malinen (4):
      mac80211_hwsim: 802.11 radio simulator for mac80211
      mac80211_hwsim: Clean up documentation
      mac80211_hwsim: Minor cleanup
      mac80211_hwsim: Shared TX code for received frames and Beacons

Julius Volz (1):
      net/wireless/nl80211.c: fix endless Netlink callback loop.

Jussi Kivilinna (10):
      rndis_wlan: do link-down state change in worker thread
      rndis_wlan: update carrier flag when link state changes
      rndis_wlan: check if set_multicast_list work is already scheduled
      rndis_wlan: cleanup: rename and remove local pointers
      rndis_wlan: use kzalloc to allocate private data
      rndis_wlan: preallocate command buffer for set/get_oid
      rndis_host: pass buffer length to rndis_command
      net_sched: Add qdisc_enqueue wrapper
      net_sched: Add accessor function for packet length for qdiscs
      net_sched: Add size table for qdiscs

Karen Xie (1):
      cxgb3 - Add iscsi support

Krzysztof Halasa (3):
      WAN: convert drivers to use built-in netdev_stats
      WAN: Remove no longer needed pvc_desc in FR code.
      ARM: IXP4xx Ethernet NAPI fix

Kuo-lang Tseng (1):
      netfilter: ebtables: add IPv6 support

Larry Finger (2):
      b43legacy: Remove switch statement with 64-bit index
      rtl8187: Change detection of RTL8187B with USB ID of 8187

Larry.Finger@lwfinger.net (3):
      ssb: Allow reading of 440-byte SPROM that is not rev 4
      b43: Fix typo in firmware file name for 802.11 cores with rev 13
      p54: Add quality output to iwlist and iwconfig

Laurent Pinchart (4):
      net: OpenFirmware GPIO based MDIO bitbang driver
      fs_enet: MDIO on GPIO support
      DM9000: Remove the 2 resources probe scheme.
      DM9000: Fixup blackfin after removing 2 resource usage

Lennert Buytenhek (38):
      mv643xx_eth: reverse topological sort of functions
      mv643xx_eth: trim unnecessary includes
      mv643xx_eth: shorten reg names
      mv643xx_eth: get rid of individual port config register bit defin=
es
      mv643xx_eth: get rid of individual port config extend register bi=
t defines
      mv643xx_eth: delete unused SDMA config register bit defines
      mv643xx_eth: delete unused port serial control register bit defin=
es
      mv643xx_eth: nuke port status register bit defines
      mv643xx_eth: remove unused DESC_SIZE define
      mv643xx_eth: clarify irq masking and unmasking
      mv643xx_eth: move PHY wait defines into callers
      mv643xx_eth: get rid of RX_BUF_OFFSET
      mv643xx_eth: move MIB offset defines into their only user
      mv643xx_eth: remove port serial status register bit defines
      mv643xx_eth: clean up rx/tx descriptor field defines
      mv643xx_eth: get rid of ETH_/ethernet_/eth_ prefixes
      mv643xx_eth: use 'mv643xx_eth_' prefix consistently
      mv643xx_eth: kill superfluous comments
      mv643xx_eth: kill ->rx_resource_err
      mv643xx_eth: get rid of hungarian variable naming
      mv643xx_eth: move port_receive() into its only caller
      mv643xx_eth: move rx_return_buff() into its only caller
      mv643xx_eth: kill FUNC_RET_STATUS/pkt_info
      mv643xx_eth: kill private unused instance of struct net_device_st=
ats
      mv643xx_eth: massively simplify multicast address crc8 computatio=
n
      mv643xx_eth: split out rx queue state
      mv643xx_eth: split out tx queue state
      mv643xx_eth: remove write-only interrupt coalescing variables
      mv643xx_eth: general cleanup
      mv643xx_eth: add tx rate control
      mv643xx_eth: allow multiple RX queues
      mv643xx_eth: allow multiple TX queues
      mv643xx_eth: work around TX hang hardware issue
      mv643xx_eth: detect extended rx coal register field
      mv643xx_eth: detect alternate TX BW control register location
      mv643xx_eth: be more agressive about RX refill
      mv643xx_eth: add PHY-less mode
      mv643xx_eth: update driver version and author fields

Luis R. Rodriguez (1):
      mac80211: Let drivers have access to TKIP key offets for TX and R=
X MIC

Maciej W. Rozycki (2):
      PHYLIB: Kconfig: Complete the list of Broadcom PHYs supported
      sb1250: use netdev_alloc_skb

Magnus Damm (5):
      smc911x: remove unused 8-bit I/O operations
      smc911x: fix 16-bit I/O operations
      smc911x: pass along private data and use iomem
      smc911x: introduce platform data flags
      smc911x: SuperH architecture support

Mallikarjuna R Chilakala (1):
      ixgbe: add LRO support

Marcel Holtmann (26):
      [Bluetooth] Change retrieval of L2CAP features mask
      [Bluetooth] Enforce security for outgoing RFCOMM connections
      [Bluetooth] Disconnect when encryption gets disabled
      [Bluetooth] Update authentication status after successful encrypt=
ion
      [Bluetooth] Support the case when headset falls back to SCO link
      [Bluetooth] Track connection packet type changes
      [Bluetooth] Make use of the default link policy settings
      [Bluetooth] Some cleanups for HCI event handling
      [Bluetooth] Update class of device value whenever possible
      [Bluetooth] Disable disconnect timer during Simple Pairing
      [Bluetooth] Track status of Simple Pairing mode
      [Bluetooth] Track status of remote Simple Pairing mode
      [Bluetooth] Export remote Simple Pairing mode via sysfs
      [Bluetooth] Use ACL config stage to retrieve remote features
      [Bluetooth] Initiate authentication during connection establishme=
nt
      [Bluetooth] Export details about authentication requirements
      [Bluetooth] Add timestamp support to L2CAP, RFCOMM and SCO
      [Bluetooth] Add support for TIOCOUTQ and TIOCINQ ioctls
      [Bluetooth] Use a more unique bus name for connections
      [Bluetooth] Update Bluetooth core version number
      [Bluetooth] Use non-canonical TTY by default for RFCOMM
      [Bluetooth] Store remote modem status for RFCOMM TTY
      [Bluetooth] Move pending packets from RFCOMM socket to TTY
      [Bluetooth] Signal user-space for HIDP and BNEP socket errors
      [Bluetooth] Add option to disable eSCO connection creation
      [Bluetooth] Allow security for outgoing L2CAP connections

Marcin Slusarz (1):
      net/s2io: set_rxd_buffer_pointer returns -ENOMEM, not ENOMEM

Mark McLoughlin (1):
      virtio_net: Set VIRTIO_NET_F_GUEST_CSUM feature

Masakazu Mokuno (6):
      PS3: gelic: Allocate the bounce buffer dynamically
      PS3: gelic: Kill the static bounce buffer
      WEXT: Add support for passing PMK and capability flags to WEXT
      PS3: gelic: Use the new PMK interface in the gelic driver
      PS3: gelic: Deprecate the private ioctls in the gelic driver
      PS3: gelic: Add support for ESSID scan

Matt Carlson (8):
      tg3: Pure code movement.
      tg3: Code cleanup.
      tg3: Add TG3_FLG3_USE_PHYLIB
      tg3: Add mdio bus registration
      tg3: Add libphy support.
      tg3: Add 5785 ASIC revision
      tg3: Add shmem options.
      tg3: Update version to 3.93

Max Krasnyansky (1):
      tun: Fix/rewrite packet filtering logic

Michael Buesch (17):
      b43: Rewrite LO calibration algorithm
      b43: Remove some dead code
      b43: Don't disable IRQs in mac_suspend
      b43: Add hooks for firmware debugging
      b43: Allow running without PCM firmware
      b43: Add panic reason code that doesn't trigger restart
      b43: Add firmware markers support
      nl80211: Fix comment merge error
      b43: Add debugfs files for MMIO register access
      b43: Add debugfs files for random SHM access
      b43: Add mask/set capability to debugfs MMIO interface
      b43: Remove "shm" and "ucode_regs" debugfs files
      ssb, b43, b43legacy, b44: Rewrite SSB DMA API
      b43: Add simple firmware watchdog
      b43: Add debugfs firmware debugging knob
      b43: Fix PIO skb clobber
      ssb: Include dma-mapping.h

Michael Chan (15):
      bnx2: Allow phy reset to be skipped during chip reset.
      bnx2: Update version to 1.7.6.
      bnx2: Put tx ring variables in a separate struct.
      bnx2: Put rx ring variables in a separate struct.
      bnx2: Optimize fast-path tx and rx work.
      bnx2: Use one handler for all MSI-X vectors.
      bnx2: Update firmware to support multi rx rings.
      bnx2: Turn on multi rx rings.
      bnx2: Cleanup error handling in bnx2_open().
      bnx2: Update driver version to 1.7.7.
      bnx2: Prevent ethtool -s from crashing when device is down.
      bnx2: Add PCI ID for 5716.
      bnx2: Add ack parameter to bnx2_fw_sync().
      bnx2: Allow flexible VLAN tag settings.
      bnx2: Update version to 1.7.8.

Mitch Williams (1):
      igb: Remove adapter struct from these function call parameters

Mitchell Blank Jr (1):
      atm: use const where reasonable

Mohamed Abbas (3):
      iwlwifi: Add power level support
      iwlwifi: fix resume SW RF-kill
      iwlwifi: keep the STATUS_EXIT_PENDING flag till the end of down f=
low

Moni Shoua (1):
      bonding: Send more than one gratuitous ARP when slave takes over

M=E1rton N=E9meth (1):
      8139too: some style cleanups

Nate Case (1):
      PHYLIB: Add 1000Base-X support for Broadcom bcm5482

Neil Horman (2):
      sctp: add sctp/remaddr table to complete RFC remote address table=
 OID
      core: add stat to track unresolved discards in neighbor cache

Nobuhiro Iwamatsu (2):
      net: sh_eth: add support for Renesas SuperH Ethernet
      net: sh_eth: Fix compile error sh_eth

Octavian Purdila (1):
      net: refactor tcp splice receive path to improve readability

Or Gerlitz (3):
      net/core: add NETDEV_BONDING_FAILOVER event
      bonding: bond_change_active_slave() cleanup under active-backup
      bonding: deliver netdev event for fail-over under the active-back=
up mode

PJ Waskiewicz (1):
      igb: add NAPI Rx queue support

Pablo Neira Ayuso (3):
      netfilter: ctnetlink: group errors into logical errno sets
      netfilter: ctnetlink: add full support for SCTP to ctnetlink
      netfilter: nf_conntrack: add allocation flag to nf_conntrack_allo=
c

Patrick McHardy (38):
      netfilter: nf_conntrack: add nf_ct_kill()
      net: Add STP demux layer
      bridge: Use STP demux
      net: Add GARP applicant-only participant
      vlan: Change vlan_dev_set_vlan_flag() to handle multiple flags at=
 once
      vlan: Move device unregistration before lower dev cleanup
      vlan: Add GVRP support
      net-sched: add dynamically sized qdisc class hash helpers
      net-sched: sch_hfsc: use dynamic class hash helpers
      net-sched: sch_cbq: use dynamic class hash helpers
      net-sched: sch_htb: move hash and sibling list removal to htb_del=
ete
      net-sched: sch_htb: use dynamic class hash helpers
      net-sched: sch_htb: remove child and sibling lists
      net-sched: sch_htb: remove write-only qdisc filter_cnt
      net-sched: consolidate default fifo qdisc setup
      net: fix dev_set_promiscuity() breakage
      netdrv: don't truncate VLAN TCI with VLAN stripping
      netfilter: ebt_nflog: fix Kconfig typo
      vlan: fix network_header/mac_header adjustments
      vlan: Add ethtool support
      vlan: uninline __vlan_hwaccel_rx
      vlan: move struct vlan_dev_info to private header
      vlan: remove useless struct hlist_node declaration from if_vlan.h
      vlan: TCI related type and naming cleanups
      vlan: avoid header copying and linearisation where possible
      net-sched: cls_flow: add perturbation support
      vlan: Don't store VLAN tag in cb
      vlan: deliver packets received with VLAN acceleration to network =
taps
      packet: support extensible, 64 bit clean mmaped ring structure
      packet: deliver VLAN TCI to userspace
      vlan: ethtool ->get_flags support
      vlan: clean up vlan_dev_hard_header()
      vlan: clean up hard_start_xmit functions
      vlan: remove unnecessary include statements
      netdrv intel: disable VLAN filtering in promiscous mode
      netdrv intel: always enable VLAN filtering except in promiscous m=
ode
      garp: retry sending JoinIn messages after allocation failures
      packet: add PACKET_RESERVE sockopt

Paulius Zaleckas (15):
      axnet_cs: use netstats in net_device structure
      lib8390: use netstats in net_device structure
      8390.h: remove net_device_stats
      8139cp: use netstats in net_device structure
      8139too: use netstats in net_device structure
      3c574_cs: use netstats in net_device structure
      3c589_cs: use netstats in net_device structure
      6pack: use netstats in net_device structure
      acenic: use netstats in net_device structure
      3c523: use netstats in net_device structure
      3c527: use netstats in net_device structure
      3c359: use netstats in net_device structure
      airo: use netstats in net_device structure
      arlan: use netstats in net_device structure
      atmel: use netstats in net_device structure

Pavel Emelyanov (84):
      netns: Introduce sysctl root for read-only net sysctls.
      netns: Register net/core/ sysctls at read-only root.
      inet: Rename fragmentation sysctl-related functions/variables.
      ipv6: In fragmentation code, handle error returned from register_=
pernet_subsys.
      inet: Register fragmentation some ctls at read-only root.
      ipv6: Register some net/ipv6/ core sysctls at read-only root.
      net: The dev->get_stats pointer is not NULL nowadays.
      bridge: Use on-device stats instead of private ones.
      ipgre: Use on-device stats instead of private ones.
      ipip: Use on-device stats instead of private ones.
      sit: Use on-device stats instead of private ones.
      ipmr: Ipip tunnel uses on-device stats.
      tunnels: Remove stat member from ip_tunnel struct.
      ip6tnl: Use on-device stats instead of private ones.
      ipmr: Use on-device stats instead of private ones.
      ip6mr: Use on-device stats instead of private ones.
      mac80211: Brush up error paths in mesh_path_add.
      mac80211: Fix one more call to synchronize_rcu in atomic context.
      mac80211: Prepare mesh_table_grow to failing copy_node callback.
      mac80211: Report allocation failure from mesh_path_node_copy.
      mac80211: Fix sleeping allocation under lock in mesh_path_node_co=
py.
      mac80211: Do not report false error from mesh_path_add.
      mac80211: Merge error paths in mesh_table_grow().
      mac80211: Consolidate hash kfree-ing in mesh.c.
      bonding: Remove redundant argument from bond_create.
      bonding: Relax unneeded _safe lists iterations.
      bonding: Remove unneeded list_empty checks.
      udp: introduce a udp_hashfn function
      udp: provide a struct net pointer for __udp[46]_lib_mcast_deliver
      udp: add struct net argument to udp_hashfn
      inet: add struct net argument to inet_bhashfn
      inet: add struct net argument to inet_lhashfn
      inet: add struct net argument to inet_ehashfn
      inet6: add struct net argument to inet6_ehashfn
      netns: introduce the net_hash_mix "salt" for hashes
      sctp: fix error path in sctp_proc_init
      tcp: de-bloat a bit with factoring NET_INC_STATS_BH out
      MIB: add struct net to UDP_INC_STATS_USER
      MIB: add struct net to UDP_INC_STATS_BH
      MIB: add struct net to UDP6_INC_STATS_USER
      MIB: add struct net to UDP6_INC_STATS_BH
      icmp: add struct net argument to icmp_out_count
      inet: toss struct net initialization around
      icmp: drop unused MIB accounting wrappers
      mib: add struct net to ICMP_INC_STATS
      mib: add struct net to ICMP_INC_STATS_BH
      mib: add struct net to ICMPMSGOUT_INC_STATS
      mib: add struct net to ICMPMSGIN_INC_STATS_BH
      ipv4: prepare net initialization for IP accounting
      mib: drop unused IP_INC_STATS_USER
      mib: add net to IP_INC_STATS
      mib: add net to IP_INC_STATS_BH
      mib: add net to IP_ADD_STATS_BH
      inet: prepare struct net for TCP MIB accounting
      mib: drop unused TCP_XXX_STATS macros
      tcp: add net to tcp_mib_init
      mib: add net to TCP_INC_STATS
      mib: add net to TCP_INC_STATS_BH
      mib: add net to TCP_DEC_STATS
      mib: add net to TCP_ADD_STATS_USER
      sock: add net to prot->enter_memory_pressure callback
      inet: prepare net on the stack for NET accounting macros
      tcp: replace tcp_sock argument with sock in some places
      mib: add net to NET_INC_STATS
      mib: add net to NET_INC_STATS_BH
      mib: add net to NET_INC_STATS_USER
      mib: add net to NET_ADD_STATS_BH
      mib: add net to NET_ADD_STATS_USER
      mib: add netns/mib.h file
      ipv4: add pernet mib operations
      mib: put tcp statistics on struct net
      mib: put ip statistics on struct net
      mib: put net statistics on struct net
      mib: put udp statistics on struct net
      mib: put udplite statistics on struct net
      mib: put icmp statistics on struct net
      mib: put icmpmsg statistics on struct net
      ipv4: clean the init_ipv4_mibs error paths
      proc: create /proc/net/netstat file in each net
      proc: create /proc/net/snmp file in each net
      proc: show per-net ip_devconf.forwarding in /proc/net/snmp
      proc: clean the ip_misc_proc_init and ip_proc_init_net error path=
s
      proc: consolidate per-net single_open callers
      proc: consolidate per-net single-release callers

Pavel Machek (1):
      wireless: Small cleanups

Pavel Roskin (5):
      mac80211: fix panic when using hardware WEP
      hostap: don't skip any headers in hostap_80211_header_parse()
      hostap: add radiotap support in monitor mode
      hostap: use radiotap headers by default
      hostap: don't compile prism2_suspend() for hostap_pci without CON=
=46IG_PM

Pekka Enberg (7):
      netfilter: nf_conntrack_extend: use krealloc() in nf_conntrack_ex=
tend.c V2
      ipg: always compile in jumbo frame support
      ipg: remove jumbo frame #ifdef from mtu
      ipg: per-device rxfrag_size
      ipg: per-device rxsupport_size
      ipg: per-device max_rxframe_size
      ipg: run-time configurable jumbo frame support

Peter P Waskiewicz Jr (1):
      igb: Introduce multiple TX queues with infrastructure

Rafael J. Wysocki (1):
      irda: Remove useless pm_dev references

Ralf Baechle (1):
      SAA9730: Remove driver

Rami Rosen (7):
      netfilter: nf_conntrack: remove unnecessary function declaration
      netfilter: {ip,ip6,nfnetlink}_queue: misc cleanups
      ipv6 mcast: Remove unused macro (MLDV2_QQIC) from mcast.c.
      ipv6 mroute: Use MRT6_VERSION instead of MRT_VERSION in ip6mr.c.
      ipv6 addrconf: Remove IFA_GLOBAL definition from include/net/if_i=
net6.h.
      ipv6: minor cleanup in net/ipv6/tcp_ipv6.c [RESEND ].
      mac80211: remove MAC80211_DEBUG from net/mac80211/Kconfig.

Randy Dunlap (6):
      3c515: fix using pnp_get_resource when CONFIG_ISAPNP=3Dn
      cxgb3: fix build error when INET=3Dn
      bridge: fix IPV6=3Dn build
      iwlwifi: fix build for CONFIG_INPUT=3Dn
      mac80211: fix lots of kernel-doc
      bluetooth/hci_bcsp: fix bitrev Kconfig

Richard Kennedy (2):
      udp: reorder udp_iter_state to remove padding on 64bit builds
      net: remove padding from struct socket on 64bit & increase object=
s/cache

Rick Farrington (1):
      iwlwifi: fix incorrect monitor mode operation

Robert P. J. Day (1):
      rndis_wlan: Use kernel-supplied ARRAY_SIZE() macro.

Ron Rindjunsky (45):
      iwlwifi: arranging aggregation actions
      iwlwifi: expanding HW parameters control
      iwlwifi: support 64 bit DMA masks
      iwlwifi: handle shared memory
      iwlwifi: unify init driver flow
      iwlwifi: iwl-sta redundant includes clean up
      iwlwifi-5000: add iwl 5000 shared memory handlers
      iwlwifi: map A-MPDU HW queue to mac80211 A-MPDU SW queue
      iwlwifi-5000: rename iwl5000_init_nic to iwl5000_init_config
      iwlwifi: create disable SCD Tx FIFOs handler
      iwlwifi: move NIC init and Tx queues init to iwlcore
      iwlwifi: handle shared memory Rx index access
      iwlwifi: remove 4965 prefix from iwl4965_kw and iwl4965_tx_queue
      iwlwifi: fix spinlock used before initialized
      iwlwifi: changing irrelevant comment
      iwlwifi: remove iwl4965_nic_start function
      mac80211: separate Tx and Rx MCS when configuring HT
      iwlwifi: filling Tx MCS set
      iwlwifi: rename and move Tx queue activation/deactivation
      iwlwifi: add rx_handlers stub for iwl5000
      iwlwifi: add ucode loaders for iwl5000
      iwlwifi: add ucode init flow handling for iwl5000
      iwlwifi: iwl5000 WiFi/WiMax coexistence
      iwlwifi: add RTC data address for iwl5000
      iwlwifi: increase max payload of iwl_cmd
      iwlwifi: activate status ready timeout only for run time ucode
      iwlwifi: add iwl5000_tx_response structure
      iwlwlifi: impelemnt 5000 tx response path
      iwlwifi: iwl-5000 add rxon_assoc
      iwlwifi: Rx handlers common use for 4965 and 5000
      iwlwifi: move iwl_get_hw_mode to iwl-core.h
      iwlwifi: removing IWL4965_HT config
      iwlwifi: map sw and hw ampdu queues
      iwlwifi: use ieee80211_conf to examine rate capabilities
      iwlwifi: fix allow iwlwifi to aggregate according to tid load
      mac80211: do not fragment while aggregation is in use
      iwlwifi: remove 4965 prefix from iwl4965_ucode
      iwlwifi: use iwl_is_associated when possible
      iwlwifi: move rx aggregation functions to iwl-rx.c
      iwlwifi: remove obsolete lq_ready use
      iwlwifi: unite common settings of HW params
      iwlwifi: control 11n capabilities through module param
      iwlwifi: eliminate iwl4965_mac_get_tsf
      mac80211: add block ack request capability
      iwlwifi: request Tx of block ack request if necessary

Rumen G. Bogdanovski (1):
      ipvs: More reliable synchronization on connection close

Russ Dill (1):
      netfilter: Get rid of refrences to no longer existant Fast NAT.

Rusty Russell (3):
      tun: Interface to query tun/tap features.
      tun: TUNSETFEATURES to set gso features.
      tun: Allow GSO using virtio_net_hdr

Samuel Ortiz (1):
      mac80211: power management wext hooks

Santwona Behera (2):
      netdev: Add support for rx flow hash configuration, using ethtool=
=2E
      niu: Add support for rx flow hash configuration.

Scott Ashcroft (1):
      rndis_wlan: use ARRAY_SIZE instead of sizeof when adding 11g rate=
s

Sreenivasa Honnur (3):
      S2io: Fix IOMMU overflow checking.
      S2io: Enable msi-x link interrupts.
      S2io: Version update for IOMMU overflow checking and enable msi-x=
 link interrupts patches.

Stefanik G=E1bor (1):
      iwlwifi: enable packet injection for iwl3945

Stephen Hemminger (28):
      tg3: remove unneeded semicolons
      atl1: use netdev_alloc_skb
      ixp2000: use netdev_alloc_skb
      hamachi: use netdev_alloc_skb
      dl2k: use netdev_alloc_skb
      via-velocity: use netdev_alloc_skb
      via-velocity: use memmove
      tlan: get rid of padding buffer
      tlan: use netdevice stats
      tlan: remove unused devName field
      tlan: 64bit conversion
      tlan: manage rx allocation failure better
      tlan: proper shared IRQ support
      tlan: wrap source lines
      sky2: split phy power into two functions
      sky2: put PHY in sleep when down
      sky2: pci power savings
      ts108: use netdev_alloc_skb
      ns8320: use netdev_alloc_skb
      bridge: handle process all link-local frames
      bridge: make bridge address settings sticky
      sky2: phy setup changes
      sky2: chip version printout
      sky2: use DEFINE_PCI_DEVICE_TABLE
      sky2: 88E8057 chip support
      sky2: version 1.22
      icmp: fix units for ratelimit
      tcp: RTT metrics scaling

Stephen Rothwell (2):
      [netdrvr] Fix 8390 build breakage
      wireless: fix fallout from device_create removal

Sven Schnelle (1):
      macb: use random mac if stored address in EEPROM is invalid

Sven Wegener (5):
      ipvs: Initialize mcast addr at compile time
      ipvs: Use ERR_PTR for returning errors from make_receive_sock() a=
nd make_send_sock()
      ipvs: Use kthread_run() instead of doing a double-fork via kernel=
_thread()
      ipvs: Put backup thread on mcast socket wait queue
      ipvs: Use schedule_timeout_interruptible() instead of msleep_inte=
rruptible()

Takashi Iwai (1):
      Fix missing exports for net/phy/mdio-bitbang.c

Taku Izumi (2):
      e1000e: make ioport free
      igb: make ioport free

Thomas Graf (1):
      ipv4 addr: Send netlink notification for address label changes

Tobias Diedrich (5):
      [netdrvr] forcedeth: setup wake-on-lan before shutting down
      [netdrvr] forcedeth: save/restore device configuration space
      [netdrvr] forcedeth: reorder suspend/resume code
      Fix forcedeth hibernate/wake-on-lan problems
      Fix forcedeth hibernate/wake-on-lan problems

Tomas Winkler (103):
      iwlwifi: move find station to iwl-sta.c
      iwlwifi: cleanup set_pwr_src
      iwlwifi: define ANA_PLL values in iwl-csr.h
      iwlwifi: export int iwl4965_set_pwr_src
      iwlwifi: changing EEPROM layout handling
      iwlwifi: remove includes to net/ieee80211.h
      iwlwifi: add apm init handler
      iwlwifi: add iwl_hw_detect function to iwl core
      iwlwifi: check eeprom version in pci probe time
      iwlwifi: reorganize TX RX constatns
      iwlwifi: 3945 remove unused SCD definitions
      iwlwifi: remove 49 prefix from general CSR values
      iwlwifi: remove unnecessary apmg settings
      iwlwifi: wrapping nic configuration in iwl core handler
      iwlwifi-5000: adding initial recognition for the 5000 family
      iwlwifi-5000: add ops infrastructure for 5000
      iwlwifi-5000: add apm_init handler for 5000 HW family
      iwlwifi-5000: use iwl4965_set_pwr_src in 5000
      iwlwifi-5000: EEPROM settings for 5000
      iwlwifi-5000: adding iwl5000 HW parameters
      iwlwifi-5000: adjust antennas names in 5000 HW family
      iwlwifi-5000: Add HW REV of 5000 HW family
      iwlwifi-5000: add eeprom check version handler
      iwlwifi-5000: add nic config handler for 5000 HW
      iwlwifi: rename iwl-4965-commands to iwl-commands.h
      iwlwifi: rename iwl-4965.h to iwl-dev.h
      iwlwifi: move RX code to iwl-rx.c
      iwlwifi: don't override association channel with control channel
      iwlwifi: remove 4965 from station_entry
      iwlwifi: debugfs EEPROM dump
      iwlwifi: remove 4965 from rx_packet
      iwlwifi: generalize iwl4965_send_add_station function
      iwlwifi-5000: add build_addsta_hcmd handler for 5000 HW
      iwlwifi: move iwl4965_set_rxon_ht into iwlcore
      iwlwifi: compile iwl-sta into iwlcore
      iwlwifi: add device sysfs version entry
      iwlwifi: rename iwl4965_queue to iwl_queue
      iwlwifi: rename iwl4965_tx_info to iwl_tx_info
      iwlwifi: remove 4965 from iwl4965_tx_queue_update_write_ptr
      iwlwifi: remove 4965 prefix from iwl4965_frame
      iwlwifi: remove 4965 from iwl4965_rate_info
      iwlwifi: move iwl_bcast_addr to iwlcore
      iwlwifi: move more station managment into iwl-sta.c
      iwlwifi: remove 4956 form iwl4965_tx_cmd
      iwlwifi: refactor ieee80211_get_qos_ctrl
      iwlwifi: move TX code into iwl-tx.c
      iwlwifi: remove 4965 remainings in iwl-eeprom.c file
      iwlwifi: add debugfs to disable/enable run time calibration
      iwlwifi: refactor pci prob flow
      mac80211: fix ieee80211_get_buffered_bc
      mac80211: fix deadlock in sta->lock
      iwlwifi: mark 4965 ucode types
      iwlwifi: remove unused variable form __iwl4965_down
      iwlwifi: remove notif_missed_beacons variable
      iwlwifi: clean up alive_start routine
      iwlwifi: remove 4965 from alive_resp structures
      iwlwifi: setup correctly L1 L0S pi link values
      iwlwifi: implement apm reset flow
      iwlwifi: implement apm stop function
      iwlwifi: refactor stop master function
      iwlwifi: move txq_ctx_stop into iwl-tx.c
      iwlwifi: move iwl_rxq_stop into iwl-rx.c
      iwlwifi: add remove station functionality
      iwlwifi: move add sta handler to iwl-sta.c
      iwlwifi: move iwl_rx_missed_beacon_notif to iwl-rx.c
      iwlwifi-5000: implement initial calibration for 5000
      iwlwifi: move tx response common handlers to iwlcore
      iwlwifi: move 4965 tx response into iwl-4965.c
      iwlwifi: move tx reclaim flow into iwl-tx
      iwlwifi: implement txq invalidate byte count table
      iwlwifi: move iwl_sta_modify_enable_tid_tx to iwl-sta.c
      iwlwifi: move aggregation code to iwl-tx.c
      iwlwifi: add frame count limit to link quality command
      iwlwifi: clean iwl4965_mac_config
      mac80211: fix unbalanced locking in ieee80211_get_buffered_bc
      mac80211: removing shadowed sband
      iwlwifi: add TX aggregation code for 5000 HW
      iwlwifi: remove unused flag
      iwlwifi: format log prints for easier parsing
      iwlwifi: refactor tx aggregation response flow
      iwlwifi: refactor setting tx power
      iwlwifi: move scan to iwl-scan.c iwlcore
      iwlwifi: move rate helpers to iwlcore
      iwlwifi: cleans up scanning code
      mac80211: fix beacon interval value
      mac80211: add phy information to giwname
      mac80211: add spectrum capabilities
      mac80211: fix warning: unused variable invoke_tx_handlers
      iwlwifi: Add eeprom version to the version file in sysfs
      iwlwifi: fix IBSS association flow
      iwlwifi: fix 4965 uCode load
      iwlwifi: fix error path of iwl_rfkill_init
      mac80211: remove useless tid assignment for management and contro=
l frames
      mac80211: fix warning: unused variable ifsta
      mac80211: call bss_info_change only once upon disassociation
      iwlwif: remove compilation warnings iwl_add_radiotap
      iwlwifi: remove post associate work
      iwlwifi: rs always set lq_sta->priv
      iwlwifi: differentiate 4965 and 5000 hw ampdu queues number
      iwlwifi: fix LED stall
      iwlwifi: LED use correctly blink table
      iwlwifi: unify 4965 and 5000 scanning code
      iwlwifi: enable active scanning

Tony Vroon (1):
      mac80211: implement EU regulatory domain

Ursula Braun (1):
      af_iucv: exploit target message class support of IUCV

Vlad Yasevich (9):
      sctp: Support the new specification of sctp_connectx()
      sctp: Fix problems with the new SCTP_DELAYED_ACK code
      sctp: Follow security requirement of responding with 1 packet
      sctp: Kill unused variable in sctp_assoc_bh_rcv()
      sctp: Mark GET_PEER|LOCAL_ADDR_OLD deprecated.
      sctp: Support ipv6only AF_INET6 sockets.
      sctp: Do not leak memory on multiple listen() calls
      sctp: Allow only 1 listening socket with SO_REUSEADDR
      sctp: Update sctp global memory limit allocations.

Vladimir Koutny (1):
      mac80211: eliminate IBSS warning in rate_lowest_index()

Vladislav Zolotarov (1):
      bnx2x: Add TPA, Broadcoms HW LRO

Wang Chen (13):
      netdevice: change net_device->promiscuity/allmulti to unsigned in=
t
      netdevice: Fix promiscuity and allmulti overflow
      ipv6: Do cleanup for ip6_mr_init.
      ipv4: Do cleanup for ip_mr_init
      af_packet: Check return of dev_set_promiscuity/allmulti
      bonding: Check return of dev_set_promiscuity/allmulti
      bridge: Check return of dev_set_promiscuity
      ipv6: Check return of dev_set_allmulti
      ipv6: Fix using after dev_put()
      ipv4: Check return of dev_set_allmulti
      ipv4: Fix ipmr unregister device oops
      macvlan: Check return of dev_set_allmulti
      8021q: Check return of dev_set_promiscuity/allmulti

Wei Yongjun (2):
      sctp: Bring SCTP_DELAYED_ACK socket option into API compliance
      sctp: Validate Initiate Tag when handling ICMP message

Wendy Xiong (2):
      bnx2: Add EEH PCI recovery.
      bnx2x: Add PCIE EEH support

Will Newton (1):
      net/ipv4/tcp.c: Fix use of PULLHUP instead of POLLHUP in comments=
=2E

YOSHIFUJI Hideaki (20):
      ipv6 addrconf: Introduce addrconf_is_prefix_route() helper.
      key: Introduce pfkey_sockaddr_len() for raw sockaddr{} length.
      key: Share common code path to fill sockaddr{}.
      key: Share common code path to extract address from sockaddr{}.
      key: Use xfrm_addr_cmp() where appropriate.
      tcp md5sig: Share MD5 Signature option parser between IPv4 and IP=
v6.
      tcp md5sig: Remove redundant protocol argument.
      tcp md5sig: Share most of hash calcucaltion bits between IPv4 and=
 IPv6.
      tcp md5sig: Let the caller pass appropriate key for tcp_v{4,6}_do=
_calc_md5_hash().
      ipv6: Do not assign non-valid address on interface.
      ipv6: Do not forward packets with the unspecified source address.
      ipv6: Assume the loopback address in link-local scope.
      ipv6: Add disable_ipv6 sysctl to disable IPv6 operaion on specifi=
c interface.
      ipv6 addrconf: add accept_dad sysctl to control DAD operation.
      ipv6 route: Prefer outgoing interface with source address assigne=
d.
      ipv4,ipv6 mroute: Add some helper inline functions to remove ugly=
 ifdefs.
      netns: Use net_eq() to compare net-namespaces for optimization.
      ipv6 netns: Make several "global" sysctl variables namespace awar=
e.
      net: Use standard structures for generic socket address structure=
s.
      ipv6 mcast: Omit redundant address family checks in ip6_mc_source=
().

Yaniv Rosner (2):
      bnx2x: Adding bnx2x_link
      bnx2x: New link code

Yi Zhu (1):
      mac80211: add MAC80211_VERBOSE_SPECT_MGMT_DEBUG Kconfig option

Yitchak Gertner (2):
      bnx2x: New statistics code
      bnx2x: Enhanced self test

Zhu Yi (5):
      iwlwifi: create drivers debugfs dir under wiphy->debugfsdir
      iwlwifi: fix software rf_kill problem when interface is down
      iwlwifi: fix iwl4965 temperature callback calibration issue
      iwl3945: remove RFKILL_STATE_HARD_BLOCKED warnings
      iwlwifi: send TXPOWER command after a new RXON command

 Documentation/feature-removal-schedule.txt         |   22 +
 Documentation/networking/bonding.txt               |  110 +-
 Documentation/networking/dm9000.txt                |  167 +
 Documentation/networking/ip-sysctl.txt             |   21 +-
 Documentation/networking/ixgb.txt                  |  419 +-
 Documentation/networking/mac80211_hwsim/README     |   67 +
 .../networking/mac80211_hwsim/hostapd.conf         |   11 +
 .../networking/mac80211_hwsim/wpa_supplicant.conf  |   10 +
 Documentation/networking/multiqueue.txt            |   90 +-
 Documentation/networking/s2io.txt                  |    7 +-
 Documentation/powerpc/booting-without-of.txt       |   78 +-
 Documentation/rfkill.txt                           |  547 +-
 MAINTAINERS                                        |   18 +-
 arch/blackfin/mach-bf527/boards/ezkit.c            |    7 +-
 arch/blackfin/mach-bf533/boards/H8606.c            |    7 +-
 arch/blackfin/mach-bf537/boards/generic_board.c    |    7 +-
 drivers/atm/Kconfig                                |   79 +-
 drivers/atm/Makefile                               |   39 -
 drivers/atm/fore200e.c                             |  130 +-
 drivers/atm/fore200e.h                             |    3 -
 drivers/atm/fore200e_firmware_copyright            |   31 -
 drivers/atm/fore200e_mkfirm.c                      |  154 -
 drivers/atm/he.c                                   |  152 -
 drivers/atm/he.h                                   |   26 -
 drivers/atm/iphase.c                               |   30 +-
 drivers/atm/pca200e.data                           |  850 -
 drivers/atm/pca200e_ecd.data                       |  906 -
 drivers/atm/sba200e_ecd.data                       |  928 -
 drivers/atm/suni.c                                 |  130 +-
 drivers/atm/suni.h                                 |   40 +-
 drivers/bluetooth/Kconfig                          |    1 +
 drivers/bluetooth/hci_bcsp.c                       |   44 +-
 drivers/char/pcmcia/synclink_cs.c                  |   28 +-
 drivers/char/synclink.c                            |   33 +-
 drivers/char/synclink_gt.c                         |   28 +-
 drivers/char/synclinkmp.c                          |   31 +-
 drivers/infiniband/ulp/ipoib/ipoib_multicast.c     |    4 +-
 drivers/isdn/i4l/isdn_net.c                        |    2 +-
 drivers/media/dvb/dvb-core/dvb_net.c               |    4 +-
 drivers/net/3c503.c                                |   14 +-
 drivers/net/3c515.c                                |    4 +
 drivers/net/3c523.c                                |   37 +-
 drivers/net/3c527.c                                |   45 +-
 drivers/net/8139cp.c                               |   44 +-
 drivers/net/8139too.c                              |   66 +-
 drivers/net/8390.h                                 |   19 +-
 drivers/net/8390p.c                                |   66 +
 drivers/net/Kconfig                                |  191 +-
 drivers/net/Makefile                               |   15 +-
 drivers/net/a2065.c                                |    4 -
 drivers/net/acenic.c                               |   21 +-
 drivers/net/acenic.h                               |    1 -
 drivers/net/amd8111e.c                             |  137 +-
 drivers/net/arm/ixp4xx_eth.c                       |    3 +-
 drivers/net/atarilance.c                           |    2 +-
 drivers/net/atlx/atl1.c                            |    3 +-
 drivers/net/au1000_eth.c                           |    2 +-
 drivers/net/b44.c                                  |  140 +-
 drivers/net/bfin_mac.c                             |    2 +-
 drivers/net/bnx2.c                                 | 1339 +-
 drivers/net/bnx2.h                                 |  115 +-
 drivers/net/bnx2_fw.h                              |   80 +
 drivers/net/bnx2_fw2.h                             | 8858 +++++-----
 drivers/net/bnx2x.c                                | 9988 ----------
 drivers/net/bnx2x.h                                | 1585 +-
 drivers/net/bnx2x_fw_defs.h                        |  483 +-
 drivers/net/bnx2x_hsi.h                            | 1101 +-
 drivers/net/bnx2x_init.h                           |  352 +-
 drivers/net/bnx2x_init_values.h                    |19186 ++++++++++++=
++------
 drivers/net/bnx2x_link.c                           | 4527 +++++
 drivers/net/bnx2x_link.h                           |  168 +
 drivers/net/bnx2x_main.c                           |10294 +++++++++++
 drivers/net/bnx2x_reg.h                            | 1969 ++-
 drivers/net/bonding/bond_alb.c                     |    6 +-
 drivers/net/bonding/bond_main.c                    |  824 +-
 drivers/net/bonding/bond_sysfs.c                   |  103 +-
 drivers/net/bonding/bonding.h                      |   17 +-
 drivers/net/chelsio/cxgb2.c                        |    2 -
 drivers/net/chelsio/sge.c                          |   70 +-
 drivers/net/cpmac.c                                |   35 +-
 drivers/net/cxgb3/adapter.h                        |   18 +
 drivers/net/cxgb3/common.h                         |    1 +
 drivers/net/cxgb3/cxgb3_ctl_defs.h                 |    5 +-
 drivers/net/cxgb3/cxgb3_ioctl.h                    |    1 +
 drivers/net/cxgb3/cxgb3_main.c                     |   19 +
 drivers/net/cxgb3/cxgb3_offload.c                  |   32 +-
 drivers/net/cxgb3/l2t.c                            |    2 +-
 drivers/net/cxgb3/regs.h                           |   10 +-
 drivers/net/cxgb3/sge.c                            |  391 +-
 drivers/net/cxgb3/t3_cpl.h                         |   51 +
 drivers/net/cxgb3/t3cdev.h                         |    4 +-
 drivers/net/declance.c                             |    4 -
 drivers/net/dl2k.c                                 |   10 +-
 drivers/net/dm9000.c                               | 1161 +-
 drivers/net/dm9000.h                               |   11 +
 drivers/net/e1000/e1000_main.c                     |   64 +-
 drivers/net/e1000e/e1000.h                         |    4 +
 drivers/net/e1000e/netdev.c                        |   84 +-
 drivers/net/fealnx.c                               |   43 +-
 drivers/net/fec_mpc52xx.c                          |    2 +-
 drivers/net/forcedeth.c                            |   82 +-
 drivers/net/fs_enet/fs_enet-main.c                 |   33 +-
 drivers/net/gianfar.c                              |   82 +-
 drivers/net/gianfar.h                              |   11 -
 drivers/net/hamachi.c                              |   12 +-
 drivers/net/hamradio/6pack.c                       |   26 +-
 drivers/net/hamradio/bpqether.c                    |   14 +-
 drivers/net/hamradio/mkiss.c                       |    2 +
 drivers/net/hp.c                                   |   14 +-
 drivers/net/hplance.c                              |    4 +-
 drivers/net/ibm_emac/Kconfig                       |   70 -
 drivers/net/ibm_emac/Makefile                      |   11 -
 drivers/net/ibm_emac/ibm_emac.h                    |  329 -
 drivers/net/ibm_emac/ibm_emac_core.c               | 2263 ---
 drivers/net/ibm_emac/ibm_emac_core.h               |  222 -
 drivers/net/ibm_emac/ibm_emac_debug.c              |  211 -
 drivers/net/ibm_emac/ibm_emac_debug.h              |   62 -
 drivers/net/ibm_emac/ibm_emac_mal.c                |  570 -
 drivers/net/ibm_emac/ibm_emac_mal.h                |  267 -
 drivers/net/ibm_emac/ibm_emac_phy.c                |  398 -
 drivers/net/ibm_emac/ibm_emac_phy.h                |   80 -
 drivers/net/ibm_emac/ibm_emac_rgmii.c              |  200 -
 drivers/net/ibm_emac/ibm_emac_rgmii.h              |   64 -
 drivers/net/ibm_emac/ibm_emac_tah.c                |  110 -
 drivers/net/ibm_emac/ibm_emac_tah.h                |   87 -
 drivers/net/ibm_emac/ibm_emac_zmii.c               |  253 -
 drivers/net/ibm_emac/ibm_emac_zmii.h               |   82 -
 drivers/net/ibm_newemac/core.c                     |    4 +
 drivers/net/ifb.c                                  |   14 -
 drivers/net/igb/e1000_82575.c                      |  446 +-
 drivers/net/igb/e1000_82575.h                      |   36 +-
 drivers/net/igb/e1000_defines.h                    |   38 +-
 drivers/net/igb/e1000_hw.h                         |   16 +-
 drivers/net/igb/e1000_mac.c                        |  144 +-
 drivers/net/igb/e1000_mac.h                        |    1 +
 drivers/net/igb/e1000_nvm.c                        |   52 +-
 drivers/net/igb/e1000_phy.c                        |  138 +-
 drivers/net/igb/e1000_regs.h                       |    9 +-
 drivers/net/igb/igb.h                              |   51 +-
 drivers/net/igb/igb_ethtool.c                      |  203 +-
 drivers/net/igb/igb_main.c                         | 1284 +-
 drivers/net/ipg.c                                  |  105 +-
 drivers/net/ipg.h                                  |   83 +-
 drivers/net/irda/ali-ircc.h                        |    2 -
 drivers/net/irda/au1000_ircc.h                     |    1 -
 drivers/net/irda/donauboe.c                        |    6 +-
 drivers/net/irda/smsc-ircc2.c                      |    1 -
 drivers/net/irda/smsc-ircc2.h                      |    1 -
 drivers/net/irda/via-ircc.h                        |    1 -
 drivers/net/ixgb/Makefile                          |    2 +-
 drivers/net/ixgb/ixgb.h                            |   21 +-
 drivers/net/ixgb/ixgb_ee.c                         |   28 +-
 drivers/net/ixgb/ixgb_ee.h                         |   12 +-
 drivers/net/ixgb/ixgb_ethtool.c                    |  120 +-
 drivers/net/ixgb/ixgb_hw.c                         |   40 +-
 drivers/net/ixgb/ixgb_hw.h                         |    2 +-
 drivers/net/ixgb/ixgb_ids.h                        |   10 +-
 drivers/net/ixgb/ixgb_main.c                       |  499 +-
 drivers/net/ixgb/ixgb_osdep.h                      |    4 +-
 drivers/net/ixgb/ixgb_param.c                      |   44 +-
 drivers/net/ixgbe/ixgbe.h                          |    9 +
 drivers/net/ixgbe/ixgbe_ethtool.c                  |   27 +-
 drivers/net/ixgbe/ixgbe_main.c                     |  191 +-
 drivers/net/ixp2000/ixpdev.c                       |    4 +-
 drivers/net/lib8390.c                              |  100 +-
 drivers/net/loopback.c                             |    8 +-
 drivers/net/mac8390.c                              |    8 +-
 drivers/net/macb.c                                 |    8 +-
 drivers/net/macsonic.c                             |   19 +-
 drivers/net/macvlan.c                              |   30 +-
 drivers/net/mv643xx_eth.c                          | 4557 ++---
 drivers/net/myri10ge/myri10ge.c                    | 1076 +-
 drivers/net/natsemi.c                              |    4 +-
 drivers/net/ne.c                                   |   14 +-
 drivers/net/ne2.c                                  |   16 +-
 drivers/net/niu.c                                  |  203 +-
 drivers/net/niu.h                                  |    2 +-
 drivers/net/ns83820.c                              |    9 +-
 drivers/net/pci-skeleton.c                         |    1 -
 drivers/net/pcmcia/3c574_cs.c                      |   47 +-
 drivers/net/pcmcia/3c589_cs.c                      |   49 +-
 drivers/net/pcmcia/axnet_cs.c                      |   70 +-
 drivers/net/pcnet32.c                              |    6 +-
 drivers/net/phy/Kconfig                            |    9 +-
 drivers/net/phy/Makefile                           |    1 +
 drivers/net/phy/broadcom.c                         |  201 +-
 drivers/net/phy/mdio-bitbang.c                     |    2 +
 drivers/net/phy/mdio-ofgpio.c                      |  205 +
 drivers/net/ppp_generic.c                          |   22 +-
 drivers/net/ps3_gelic_net.c                        |   10 +-
 drivers/net/ps3_gelic_net.h                        |    2 +-
 drivers/net/ps3_gelic_wireless.c                   |  236 +-
 drivers/net/ps3_gelic_wireless.h                   |    7 +-
 drivers/net/qla3xxx.c                              |    4 +-
 drivers/net/r8169.c                                |  145 +-
 drivers/net/s2io.c                                 |  183 +-
 drivers/net/s2io.h                                 |    3 +-
 drivers/net/saa9730.c                              | 1139 --
 drivers/net/saa9730.h                              |  384 -
 drivers/net/sb1250-mac.c                           |    2 +-
 drivers/net/sfc/Kconfig                            |    2 +
 drivers/net/sfc/Makefile                           |    2 +-
 drivers/net/sfc/boards.c                           |    2 +-
 drivers/net/sfc/boards.h                           |    3 +-
 drivers/net/sfc/efx.c                              |    6 +-
 drivers/net/sfc/falcon.c                           |   74 +-
 drivers/net/sfc/i2c-direct.c                       |  381 -
 drivers/net/sfc/i2c-direct.h                       |   91 -
 drivers/net/sfc/net_driver.h                       |   11 +-
 drivers/net/sfc/sfe4001.c                          |  126 +-
 drivers/net/sh_eth.c                               | 1174 ++
 drivers/net/sh_eth.h                               |  464 +
 drivers/net/sis190.c                               |    2 +-
 drivers/net/sis900.c                               |    2 +-
 drivers/net/sky2.c                                 |  241 +-
 drivers/net/sky2.h                                 |   24 +-
 drivers/net/smc911x.c                              |  422 +-
 drivers/net/smc911x.h                              |  494 +-
 drivers/net/spider_net.c                           |    4 +-
 drivers/net/starfire.c                             |  111 +-
 drivers/net/sunlance.c                             |    4 -
 drivers/net/tc35815.c                              |    2 +-
 drivers/net/tehuti.c                               |    2 +-
 drivers/net/tehuti.h                               |    1 +
 drivers/net/tg3.c                                  | 1268 +-
 drivers/net/tg3.h                                  |   40 +-
 drivers/net/tlan.c                                 |  490 +-
 drivers/net/tlan.h                                 |   26 +-
 drivers/net/tokenring/3c359.c                      |   20 +-
 drivers/net/tokenring/3c359.h                      |    2 -
 drivers/net/tsi108_eth.c                           |   11 +-
 drivers/net/tulip/21142.c                          |    6 +-
 drivers/net/tulip/de2104x.c                        |   10 +-
 drivers/net/tulip/eeprom.c                         |    6 +-
 drivers/net/tulip/interrupt.c                      |    5 +-
 drivers/net/tulip/media.c                          |    5 +-
 drivers/net/tulip/pnic.c                           |    5 +-
 drivers/net/tulip/pnic2.c                          |    5 +-
 drivers/net/tulip/timer.c                          |    6 +-
 drivers/net/tulip/tulip.h                          |    4 +-
 drivers/net/tulip/tulip_core.c                     |    8 +-
 drivers/net/tun.c                                  |  458 +-
 drivers/net/typhoon.c                              |    3 -
 drivers/net/ucc_geth.c                             |   33 +-
 drivers/net/ucc_geth_ethtool.c                     |    4 +-
 drivers/net/usb/Kconfig                            |   10 +
 drivers/net/usb/Makefile                           |    1 +
 drivers/net/usb/hso.c                              | 2836 +++
 drivers/net/usb/rndis_host.c                       |   14 +-
 drivers/net/via-rhine.c                            |   27 +-
 drivers/net/via-velocity.c                         |  183 +-
 drivers/net/via-velocity.h                         |    5 -
 drivers/net/virtio_net.c                           |    3 +-
 drivers/net/wan/Kconfig                            |    3 +-
 drivers/net/wan/c101.c                             |    6 +-
 drivers/net/wan/dscc4.c                            |   22 +-
 drivers/net/wan/farsync.c                          |   70 +-
 drivers/net/wan/hd6457x.c                          |   33 +-
 drivers/net/wan/hdlc.c                             |    2 +-
 drivers/net/wan/hdlc_cisco.c                       |    4 +-
 drivers/net/wan/hdlc_fr.c                          |   54 +-
 drivers/net/wan/hdlc_raw_eth.c                     |    2 +-
 drivers/net/wan/hdlc_x25.c                         |    6 +-
 drivers/net/wan/pc300_drv.c                        |   71 +-
 drivers/net/wan/pc300_tty.c                        |    6 +-
 drivers/net/wan/wanxl.c                            |   26 +-
 drivers/net/wireless/Kconfig                       |   25 +-
 drivers/net/wireless/Makefile                      |    2 +
 drivers/net/wireless/adm8211.c                     |   58 +-
 drivers/net/wireless/adm8211.h                     |    1 -
 drivers/net/wireless/airo.c                        |  156 +-
 drivers/net/wireless/arlan-main.c                  |   40 +-
 drivers/net/wireless/arlan.h                       |    1 -
 drivers/net/wireless/ath5k/Kconfig                 |    3 +
 drivers/net/wireless/ath5k/base.c                  |  377 +-
 drivers/net/wireless/ath5k/base.h                  |   36 +-
 drivers/net/wireless/ath5k/hw.c                    |    4 +-
 drivers/net/wireless/atmel.c                       |   70 +-
 drivers/net/wireless/b43/b43.h                     |   49 +-
 drivers/net/wireless/b43/debugfs.c                 |  436 +-
 drivers/net/wireless/b43/debugfs.h                 |   24 +-
 drivers/net/wireless/b43/dma.c                     |  119 +-
 drivers/net/wireless/b43/dma.h                     |    3 +-
 drivers/net/wireless/b43/lo.c                      |  731 +-
 drivers/net/wireless/b43/lo.h                      |  115 +-
 drivers/net/wireless/b43/main.c                    |  450 +-
 drivers/net/wireless/b43/main.h                    |    7 +
 drivers/net/wireless/b43/nphy.c                    |    2 -
 drivers/net/wireless/b43/phy.c                     |  291 +-
 drivers/net/wireless/b43/phy.h                     |   16 +-
 drivers/net/wireless/b43/pio.c                     |   44 +-
 drivers/net/wireless/b43/pio.h                     |    8 +-
 drivers/net/wireless/b43/rfkill.c                  |   27 +-
 drivers/net/wireless/b43/xmit.c                    |   88 +-
 drivers/net/wireless/b43/xmit.h                    |    4 +-
 drivers/net/wireless/b43legacy/b43legacy.h         |   17 -
 drivers/net/wireless/b43legacy/dma.c               |  172 +-
 drivers/net/wireless/b43legacy/dma.h               |    7 +-
 drivers/net/wireless/b43legacy/main.c              |   72 +-
 drivers/net/wireless/b43legacy/phy.c               |   14 +-
 drivers/net/wireless/b43legacy/pio.c               |   27 +-
 drivers/net/wireless/b43legacy/pio.h               |    7 +-
 drivers/net/wireless/b43legacy/radio.c             |   12 +-
 drivers/net/wireless/b43legacy/rfkill.c            |   28 +-
 drivers/net/wireless/b43legacy/xmit.c              |   70 +-
 drivers/net/wireless/b43legacy/xmit.h              |    2 +-
 drivers/net/wireless/hostap/hostap.h               |    3 +-
 drivers/net/wireless/hostap/hostap_80211_rx.c      |   21 +
 drivers/net/wireless/hostap/hostap_ap.c            |   32 +-
 drivers/net/wireless/hostap/hostap_hw.c            |   19 +-
 drivers/net/wireless/hostap/hostap_ioctl.c         |   63 +-
 drivers/net/wireless/hostap/hostap_main.c          |   20 +-
 drivers/net/wireless/hostap/hostap_wlan.h          |   14 +-
 drivers/net/wireless/iwlwifi/Kconfig               |   32 +-
 drivers/net/wireless/iwlwifi/Makefile              |   11 +-
 drivers/net/wireless/iwlwifi/iwl-3945-hw.h         |   13 +-
 drivers/net/wireless/iwlwifi/iwl-3945-led.c        |  146 +-
 drivers/net/wireless/iwlwifi/iwl-3945-led.h        |    2 +-
 drivers/net/wireless/iwlwifi/iwl-3945-rs.c         |   17 +-
 drivers/net/wireless/iwlwifi/iwl-3945.c            |  131 +-
 drivers/net/wireless/iwlwifi/iwl-3945.h            |   51 +-
 drivers/net/wireless/iwlwifi/iwl-4965-hw.h         |  634 +-
 drivers/net/wireless/iwlwifi/iwl-4965-rs.c         | 1233 +-
 drivers/net/wireless/iwlwifi/iwl-4965-rs.h         |  105 +-
 drivers/net/wireless/iwlwifi/iwl-4965.c            | 4004 +----
 drivers/net/wireless/iwlwifi/iwl-5000-hw.h         |  134 +
 drivers/net/wireless/iwlwifi/iwl-5000.c            | 1580 ++
 drivers/net/wireless/iwlwifi/iwl-calib.c           |  802 +
 drivers/net/wireless/iwlwifi/iwl-calib.h           |   84 +
 .../{iwl-4965-commands.h =3D> iwl-commands.h}        |  462 +-
 drivers/net/wireless/iwlwifi/iwl-core.c            | 1259 ++-
 drivers/net/wireless/iwlwifi/iwl-core.h            |  219 +-
 drivers/net/wireless/iwlwifi/iwl-csr.h             |   38 +-
 drivers/net/wireless/iwlwifi/iwl-debug.h           |   31 +-
 drivers/net/wireless/iwlwifi/iwl-debugfs.c         |  103 +-
 .../net/wireless/iwlwifi/{iwl-4965.h =3D> iwl-dev.h} |  567 +-
 drivers/net/wireless/iwlwifi/iwl-eeprom.c          |  171 +-
 drivers/net/wireless/iwlwifi/iwl-eeprom.h          |  206 +-
 drivers/net/wireless/iwlwifi/iwl-fh.h              |  391 +
 drivers/net/wireless/iwlwifi/iwl-hcmd.c            |   15 +-
 drivers/net/wireless/iwlwifi/iwl-helpers.h         |   92 +-
 drivers/net/wireless/iwlwifi/iwl-led.c             |  209 +-
 drivers/net/wireless/iwlwifi/iwl-led.h             |    5 +-
 drivers/net/wireless/iwlwifi/iwl-power.c           |  423 +
 drivers/net/wireless/iwlwifi/iwl-power.h           |   76 +
 drivers/net/wireless/iwlwifi/iwl-prph.h            |  333 +-
 drivers/net/wireless/iwlwifi/iwl-rfkill.c          |  106 +-
 drivers/net/wireless/iwlwifi/iwl-rfkill.h          |    6 -
 drivers/net/wireless/iwlwifi/iwl-rx.c              | 1321 ++
 drivers/net/wireless/iwlwifi/iwl-scan.c            |  931 +
 drivers/net/wireless/iwlwifi/iwl-sta.c             |  712 +-
 drivers/net/wireless/iwlwifi/iwl-sta.h             |   28 +-
 drivers/net/wireless/iwlwifi/iwl-tx.c              | 1519 ++
 drivers/net/wireless/iwlwifi/iwl3945-base.c        |  535 +-
 drivers/net/wireless/iwlwifi/iwl4965-base.c        | 5004 +-----
 drivers/net/wireless/libertas/Makefile             |    8 +-
 drivers/net/wireless/libertas/assoc.c              |    8 +-
 drivers/net/wireless/libertas/cmd.c                |  192 +-
 drivers/net/wireless/libertas/cmd.h                |    8 +-
 drivers/net/wireless/libertas/cmdresp.c            |   25 +-
 drivers/net/wireless/libertas/decl.h               |    8 +-
 drivers/net/wireless/libertas/defs.h               |   14 +-
 drivers/net/wireless/libertas/dev.h                |    8 +-
 drivers/net/wireless/libertas/host.h               |   17 +
 drivers/net/wireless/libertas/hostcmd.h            |    4 +-
 drivers/net/wireless/libertas/if_cs.c              |  315 +-
 drivers/net/wireless/libertas/if_usb.c             |   22 +
 drivers/net/wireless/libertas/main.c               |  254 +-
 drivers/net/wireless/libertas/persistcfg.c         |  453 +
 drivers/net/wireless/libertas/rx.c                 |    4 +-
 drivers/net/wireless/libertas/scan.c               |   36 +-
 drivers/net/wireless/libertas/types.h              |   30 +
 drivers/net/wireless/libertas/wext.c               |   32 +-
 drivers/net/wireless/mac80211_hwsim.c              |  515 +
 drivers/net/wireless/orinoco.c                     |   30 +-
 drivers/net/wireless/p54/p54.h                     |    2 +-
 drivers/net/wireless/p54/p54common.c               |  138 +-
 drivers/net/wireless/p54/p54common.h               |    1 -
 drivers/net/wireless/p54/p54pci.c                  |    2 +-
 drivers/net/wireless/prism54/isl_ioctl.c           |   49 +-
 drivers/net/wireless/rndis_wlan.c                  |  205 +-
 drivers/net/wireless/rt2x00/Kconfig                |   63 +-
 drivers/net/wireless/rt2x00/rt2400pci.c            |  352 +-
 drivers/net/wireless/rt2x00/rt2400pci.h            |    7 +-
 drivers/net/wireless/rt2x00/rt2500pci.c            |  312 +-
 drivers/net/wireless/rt2x00/rt2500pci.h            |   11 +-
 drivers/net/wireless/rt2x00/rt2500usb.c            |  307 +-
 drivers/net/wireless/rt2x00/rt2500usb.h            |   47 +-
 drivers/net/wireless/rt2x00/rt2x00.h               |  105 +-
 drivers/net/wireless/rt2x00/rt2x00config.c         |    2 +
 drivers/net/wireless/rt2x00/rt2x00debug.c          |   10 +-
 drivers/net/wireless/rt2x00/rt2x00dev.c            |  362 +-
 drivers/net/wireless/rt2x00/rt2x00firmware.c       |    8 +
 drivers/net/wireless/rt2x00/rt2x00lib.h            |   78 +-
 drivers/net/wireless/rt2x00/rt2x00mac.c            |  172 +-
 drivers/net/wireless/rt2x00/rt2x00pci.c            |  231 +-
 drivers/net/wireless/rt2x00/rt2x00pci.h            |   45 +-
 drivers/net/wireless/rt2x00/rt2x00queue.c          |  413 +-
 drivers/net/wireless/rt2x00/rt2x00queue.h          |  136 +-
 drivers/net/wireless/rt2x00/rt2x00reg.h            |  145 +-
 drivers/net/wireless/rt2x00/rt2x00rfkill.c         |  114 +-
 drivers/net/wireless/rt2x00/rt2x00usb.c            |  361 +-
 drivers/net/wireless/rt2x00/rt2x00usb.h            |   69 +-
 drivers/net/wireless/rt2x00/rt61pci.c              |  344 +-
 drivers/net/wireless/rt2x00/rt61pci.h              |    7 +-
 drivers/net/wireless/rt2x00/rt73usb.c              |  270 +-
 drivers/net/wireless/rt2x00/rt73usb.h              |    7 +-
 drivers/net/wireless/rtl8180_dev.c                 |   71 +-
 drivers/net/wireless/rtl8187.h                     |  119 +-
 drivers/net/wireless/rtl8187_dev.c                 |  558 +-
 drivers/net/wireless/rtl8187_rtl8225.c             |  250 +-
 drivers/net/wireless/rtl8187_rtl8225.h             |   15 +-
 drivers/net/wireless/rtl818x.h                     |   36 +-
 drivers/net/wireless/wl3501_cs.c                   |   10 +-
 drivers/net/wireless/zd1201.c                      |   21 +-
 drivers/net/wireless/zd1211rw/zd_mac.c             |  262 +-
 drivers/net/wireless/zd1211rw/zd_mac.h             |   16 -
 drivers/net/wireless/zd1211rw/zd_usb.c             |   29 +-
 drivers/s390/net/qeth_l3_main.c                    |    4 +-
 drivers/ssb/Kconfig                                |    2 +-
 drivers/ssb/main.c                                 |   75 +-
 drivers/ssb/pci.c                                  |   20 +-
 fs/compat_ioctl.c                                  |  114 +-
 fs/proc/proc_net.c                                 |   32 +
 include/linux/brcmphy.h                            |    6 +
 include/linux/dccp.h                               |    6 +-
 include/linux/dm9000.h                             |    1 +
 include/linux/ethtool.h                            |   33 +
 include/linux/hdlc.h                               |    7 -
 include/linux/ieee80211.h                          |  499 +-
 include/linux/if_bridge.h                          |    2 -
 include/linux/if_packet.h                          |   24 +
 include/linux/if_ppp.h                             |    2 -
 include/linux/if_tun.h                             |   34 +-
 include/linux/if_vlan.h                            |  238 +-
 include/linux/igmp.h                               |    1 -
 include/linux/ip6_tunnel.h                         |    4 -
 include/linux/ipv6.h                               |    4 +
 include/linux/mroute.h                             |   28 +-
 include/linux/mroute6.h                            |   35 +-
 include/linux/mv643xx_eth.h                        |   65 +-
 include/linux/net.h                                |    4 +-
 include/linux/netdevice.h                          |  330 +-
 include/linux/netfilter/nfnetlink_conntrack.h      |   10 +
 include/linux/netfilter/xt_string.h                |   15 +-
 include/linux/netfilter_bridge/ebt_ip6.h           |   40 +
 include/linux/netfilter_bridge/ebt_log.h           |    3 +-
 include/linux/netfilter_ipv4.h                     |    1 +
 include/linux/netfilter_ipv6.h                     |    5 +
 include/linux/netlink.h                            |    2 +-
 include/linux/nl80211.h                            |   13 +-
 include/linux/notifier.h                           |    1 +
 include/linux/pci_ids.h                            |    3 +
 include/linux/pkt_cls.h                            |    1 +
 include/linux/pkt_sched.h                          |   29 +-
 include/linux/ppp-comp.h                           |    2 -
 include/linux/ppp_defs.h                           |    2 -
 include/linux/rfkill.h                             |   46 +-
 include/linux/rtnetlink.h                          |    1 +
 include/linux/seq_file_net.h                       |    3 +
 include/linux/skbuff.h                             |   27 +-
 include/linux/smc911x.h                            |   12 +
 include/linux/socket.h                             |    6 +-
 include/linux/sonet.h                              |    2 +-
 include/linux/ssb/ssb.h                            |  144 +-
 include/linux/sunrpc/auth_gss.h                    |    2 -
 include/linux/sunrpc/gss_api.h                     |    2 -
 include/linux/sunrpc/svcauth_gss.h                 |    3 -
 include/linux/tcp.h                                |   56 +-
 include/linux/textsearch.h                         |   13 +-
 include/linux/tipc_config.h                        |   10 +-
 include/linux/udp.h                                |    6 +
 include/linux/usb/rndis_host.h                     |    3 +-
 include/linux/wanrouter.h                          |    2 +-
 include/linux/wireless.h                           |   30 +
 include/net/addrconf.h                             |    3 +-
 include/net/bluetooth/bluetooth.h                  |    1 +
 include/net/bluetooth/hci.h                        |   68 +-
 include/net/bluetooth/hci_core.h                   |   19 +-
 include/net/bluetooth/rfcomm.h                     |    2 +
 include/net/compat.h                               |    2 +-
 include/net/dst.h                                  |   12 +
 include/net/fib_rules.h                            |    2 +-
 include/net/garp.h                                 |  128 +
 include/net/icmp.h                                 |   18 +-
 include/net/ieee80211.h                            |   11 -
 include/net/if_inet6.h                             |    1 -
 include/net/inet6_hashtables.h                     |   10 +-
 include/net/inet_hashtables.h                      |   12 +-
 include/net/inet_sock.h                            |    9 +-
 include/net/inetpeer.h                             |    2 -
 include/net/ip.h                                   |   19 +-
 include/net/ip6_tunnel.h                           |    5 -
 include/net/ipconfig.h                             |    2 -
 include/net/ipip.h                                 |    1 -
 include/net/ipv6.h                                 |   12 +-
 include/net/irda/irda_device.h                     |    2 +-
 include/net/iw_handler.h                           |  151 +-
 include/net/mac80211.h                             |  591 +-
 include/net/neighbour.h                            |    4 +-
 include/net/net_namespace.h                        |    5 +
 include/net/netfilter/ipv4/nf_conntrack_ipv4.h     |    2 -
 include/net/netfilter/nf_conntrack.h               |   22 +-
 include/net/netns/hash.h                           |   21 +
 include/net/netns/ipv4.h                           |    5 +
 include/net/netns/ipv6.h                           |    1 +
 include/net/netns/mib.h                            |   16 +
 include/net/pkt_sched.h                            |   14 +-
 include/net/rose.h                                 |    2 +-
 include/net/route.h                                |    2 +-
 include/net/sch_generic.h                          |  196 +-
 include/net/sctp/checksum.h                        |   23 +-
 include/net/sctp/sctp.h                            |    4 +-
 include/net/sctp/structs.h                         |    8 +-
 include/net/sctp/user.h                            |   36 +-
 include/net/snmp.h                                 |    2 -
 include/net/sock.h                                 |   41 +-
 include/net/stp.h                                  |   14 +
 include/net/tcp.h                                  |   65 +-
 include/net/tipc/tipc_port.h                       |   10 +-
 include/net/transp_v6.h                            |    2 +-
 include/net/udp.h                                  |   28 +-
 include/net/wext.h                                 |    7 +
 include/net/wireless.h                             |    6 +
 ipc/mqueue.c                                       |    2 +-
 lib/textsearch.c                                   |   14 +-
 lib/ts_bm.c                                        |   26 +-
 lib/ts_fsm.c                                       |    6 +-
 lib/ts_kmp.c                                       |   29 +-
 mm/highmem.c                                       |    1 +
 net/802/Kconfig                                    |    7 +
 net/802/Makefile                                   |    2 +
 net/802/garp.c                                     |  636 +
 net/802/stp.c                                      |  102 +
 net/8021q/Kconfig                                  |   10 +
 net/8021q/Makefile                                 |   12 +-
 net/8021q/vlan.c                                   |   80 +-
 net/8021q/vlan.h                                   |   86 +-
 net/8021q/vlan_core.c                              |   64 +
 net/8021q/vlan_dev.c                               |  298 +-
 net/8021q/vlan_gvrp.c                              |   66 +
 net/8021q/vlan_netlink.c                           |    7 +-
 net/8021q/vlanproc.c                               |   13 +-
 net/Kconfig                                        |    1 +
 net/Makefile                                       |    4 +-
 net/appletalk/aarp.c                               |    4 +-
 net/appletalk/ddp.c                                |    6 +-
 net/atm/addr.c                                     |   10 +-
 net/atm/addr.h                                     |    4 +-
 net/atm/br2684.c                                   |   14 +-
 net/atm/clip.c                                     |    2 +-
 net/atm/common.c                                   |    8 +-
 net/atm/lec.c                                      |   55 +-
 net/atm/lec.h                                      |   10 +-
 net/atm/mpc.c                                      |    2 +-
 net/ax25/af_ax25.c                                 |    8 +-
 net/ax25/ax25_in.c                                 |    2 +-
 net/ax25/ax25_std_timer.c                          |    8 +-
 net/bluetooth/af_bluetooth.c                       |   53 +-
 net/bluetooth/bnep/bnep.h                          |    4 -
 net/bluetooth/bnep/core.c                          |    9 +-
 net/bluetooth/bnep/netdev.c                        |    4 -
 net/bluetooth/bnep/sock.c                          |    4 -
 net/bluetooth/hci_conn.c                           |   96 +-
 net/bluetooth/hci_core.c                           |   42 +-
 net/bluetooth/hci_event.c                          |  512 +-
 net/bluetooth/hci_sock.c                           |   18 +-
 net/bluetooth/hci_sysfs.c                          |   31 +-
 net/bluetooth/hidp/core.c                          |   10 +
 net/bluetooth/l2cap.c                              |  337 +-
 net/bluetooth/rfcomm/core.c                        |   94 +-
 net/bluetooth/rfcomm/sock.c                        |   25 +-
 net/bluetooth/rfcomm/tty.c                         |   61 +-
 net/bluetooth/sco.c                                |   14 +-
 net/bridge/Kconfig                                 |    1 +
 net/bridge/br.c                                    |   18 +-
 net/bridge/br_device.c                             |   14 +-
 net/bridge/br_fdb.c                                |    2 -
 net/bridge/br_forward.c                            |    6 +-
 net/bridge/br_if.c                                 |   12 +-
 net/bridge/br_input.c                              |   25 +-
 net/bridge/br_ioctl.c                              |    2 -
 net/bridge/br_notify.c                             |    4 +-
 net/bridge/br_private.h                            |   10 +-
 net/bridge/br_private_stp.h                        |    2 -
 net/bridge/br_stp.c                                |    2 -
 net/bridge/br_stp_bpdu.c                           |   16 +-
 net/bridge/br_stp_if.c                             |    6 +-
 net/bridge/br_stp_timer.c                          |    2 -
 net/bridge/netfilter/Kconfig                       |   11 +-
 net/bridge/netfilter/Makefile                      |    1 +
 net/bridge/netfilter/ebt_ip6.c                     |  144 +
 net/bridge/netfilter/ebt_log.c                     |   66 +-
 net/can/af_can.c                                   |    4 +-
 net/can/bcm.c                                      |    2 +-
 net/can/raw.c                                      |    2 +-
 net/compat.c                                       |    2 +-
 net/core/dev.c                                     |  380 +-
 net/core/dev_mcast.c                               |   24 +-
 net/core/ethtool.c                                 |   37 +
 net/core/fib_rules.c                               |    2 +-
 net/core/iovec.c                                   |    2 +-
 net/core/link_watch.c                              |   11 +-
 net/core/neighbour.c                               |    8 +-
 net/core/net-sysfs.c                               |   26 +-
 net/core/netpoll.c                                 |   24 +-
 net/core/pktgen.c                                  |   71 +-
 net/core/rtnetlink.c                               |   26 +-
 net/core/skbuff.c                                  |  166 +-
 net/core/sock.c                                    |    8 +-
 net/core/sysctl_net_core.c                         |   39 +-
 net/dccp/ccids/ccid3.c                             |   14 +-
 net/dccp/ccids/lib/loss_interval.c                 |   10 +-
 net/dccp/ccids/lib/packet_history.c                |  103 +-
 net/dccp/ccids/lib/packet_history.h                |   30 +-
 net/dccp/dccp.h                                    |   17 +-
 net/dccp/ipv4.c                                    |   19 +-
 net/dccp/ipv6.c                                    |   15 +-
 net/dccp/options.c                                 |   14 +-
 net/dccp/proto.c                                   |    4 +-
 net/dccp/timer.c                                   |    4 +-
 net/decnet/af_decnet.c                             |   34 +-
 net/decnet/dn_route.c                              |    2 +-
 net/decnet/dn_rules.c                              |    2 +-
 net/econet/af_econet.c                             |    8 +-
 net/ieee80211/ieee80211_rx.c                       |    2 +-
 net/ieee80211/ieee80211_tx.c                       |   86 -
 net/ieee80211/ieee80211_wx.c                       |  137 +-
 net/ipv4/af_inet.c                                 |   87 +-
 net/ipv4/arp.c                                     |    9 +-
 net/ipv4/datagram.c                                |    2 +-
 net/ipv4/devinet.c                                 |   35 +-
 net/ipv4/fib_frontend.c                            |   19 +-
 net/ipv4/fib_hash.c                                |    8 +-
 net/ipv4/fib_rules.c                               |    4 +-
 net/ipv4/fib_semantics.c                           |    2 -
 net/ipv4/fib_trie.c                                |   30 +-
 net/ipv4/icmp.c                                    |   31 +-
 net/ipv4/igmp.c                                    |   28 +-
 net/ipv4/inet_connection_sock.c                    |   13 +-
 net/ipv4/inet_diag.c                               |    2 -
 net/ipv4/inet_hashtables.c                         |   23 +-
 net/ipv4/inet_timewait_sock.c                      |   21 +-
 net/ipv4/inetpeer.c                                |    2 -
 net/ipv4/ip_forward.c                              |   11 +-
 net/ipv4/ip_fragment.c                             |   61 +-
 net/ipv4/ip_gre.c                                  |   32 +-
 net/ipv4/ip_input.c                                |   40 +-
 net/ipv4/ip_options.c                              |    2 -
 net/ipv4/ip_output.c                               |   35 +-
 net/ipv4/ip_sockglue.c                             |    2 -
 net/ipv4/ipconfig.c                                |    6 +-
 net/ipv4/ipip.c                                    |   24 +-
 net/ipv4/ipmr.c                                    |  125 +-
 net/ipv4/ipvs/ip_vs_app.c                          |    2 -
 net/ipv4/ipvs/ip_vs_conn.c                         |    2 -
 net/ipv4/ipvs/ip_vs_core.c                         |    5 +-
 net/ipv4/ipvs/ip_vs_ctl.c                          |    2 -
 net/ipv4/ipvs/ip_vs_dh.c                           |    2 -
 net/ipv4/ipvs/ip_vs_est.c                          |    2 -
 net/ipv4/ipvs/ip_vs_ftp.c                          |    2 -
 net/ipv4/ipvs/ip_vs_lblc.c                         |    2 -
 net/ipv4/ipvs/ip_vs_lblcr.c                        |    2 -
 net/ipv4/ipvs/ip_vs_lc.c                           |    2 -
 net/ipv4/ipvs/ip_vs_nq.c                           |    2 -
 net/ipv4/ipvs/ip_vs_proto.c                        |    2 -
 net/ipv4/ipvs/ip_vs_proto_ah.c                     |    2 -
 net/ipv4/ipvs/ip_vs_proto_esp.c                    |    2 -
 net/ipv4/ipvs/ip_vs_proto_tcp.c                    |    2 -
 net/ipv4/ipvs/ip_vs_proto_udp.c                    |    2 -
 net/ipv4/ipvs/ip_vs_rr.c                           |    2 -
 net/ipv4/ipvs/ip_vs_sched.c                        |    2 -
 net/ipv4/ipvs/ip_vs_sed.c                          |    2 -
 net/ipv4/ipvs/ip_vs_sh.c                           |    2 -
 net/ipv4/ipvs/ip_vs_sync.c                         |  433 +-
 net/ipv4/ipvs/ip_vs_wlc.c                          |    2 -
 net/ipv4/ipvs/ip_vs_wrr.c                          |    2 -
 net/ipv4/ipvs/ip_vs_xmit.c                         |    2 -
 net/ipv4/netfilter/Kconfig                         |   15 +-
 net/ipv4/netfilter/Makefile                        |    1 +
 net/ipv4/netfilter/ip_queue.c                      |    5 +-
 net/ipv4/netfilter/ipt_MASQUERADE.c                |    2 +-
 net/ipv4/netfilter/iptable_security.c              |  180 +
 net/ipv4/netfilter/nf_conntrack_proto_icmp.c       |    5 +-
 net/ipv4/netfilter/nf_nat_proto_sctp.c             |    4 +-
 net/ipv4/proc.c                                    |  113 +-
 net/ipv4/protocol.c                                |    2 -
 net/ipv4/raw.c                                     |   12 +-
 net/ipv4/route.c                                   |  262 +-
 net/ipv4/syncookies.c                              |    8 +-
 net/ipv4/sysctl_net_ipv4.c                         |    5 +-
 net/ipv4/tcp.c                                     |  102 +-
 net/ipv4/tcp_diag.c                                |    2 -
 net/ipv4/tcp_input.c                               |  236 +-
 net/ipv4/tcp_ipv4.c                                |  324 +-
 net/ipv4/tcp_minisocks.c                           |   12 +-
 net/ipv4/tcp_output.c                              |  466 +-
 net/ipv4/tcp_timer.c                               |   27 +-
 net/ipv4/udp.c                                     |   76 +-
 net/ipv4/udp_impl.h                                |    2 +-
 net/ipv4/udplite.c                                 |    3 -
 net/ipv6/addrconf.c                                |   95 +-
 net/ipv6/addrlabel.c                               |  106 +-
 net/ipv6/af_inet6.c                                |   17 +-
 net/ipv6/anycast.c                                 |    2 +-
 net/ipv6/datagram.c                                |    2 -
 net/ipv6/exthdrs.c                                 |    4 +-
 net/ipv6/icmp.c                                    |    5 +-
 net/ipv6/inet6_hashtables.c                        |   13 +-
 net/ipv6/ip6_fib.c                                 |    2 -
 net/ipv6/ip6_input.c                               |    7 +-
 net/ipv6/ip6_output.c                              |   19 +-
 net/ipv6/ip6_tunnel.c                              |   28 +-
 net/ipv6/ip6mr.c                                   |   81 +-
 net/ipv6/ipv6_sockglue.c                           |   11 +-
 net/ipv6/mcast.c                                   |    9 +-
 net/ipv6/ndisc.c                                   |   11 +-
 net/ipv6/netfilter/Kconfig                         |   12 +
 net/ipv6/netfilter/Makefile                        |    1 +
 net/ipv6/netfilter/ip6_queue.c                     |    5 +-
 net/ipv6/netfilter/ip6table_filter.c               |   31 +-
 net/ipv6/netfilter/ip6table_security.c             |  172 +
 net/ipv6/netfilter/nf_conntrack_proto_icmpv6.c     |    5 +-
 net/ipv6/proc.c                                    |   33 +-
 net/ipv6/protocol.c                                |    2 -
 net/ipv6/raw.c                                     |   10 +-
 net/ipv6/reassembly.c                              |   63 +-
 net/ipv6/route.c                                   |   74 +-
 net/ipv6/sit.c                                     |   26 +-
 net/ipv6/syncookies.c                              |    6 +-
 net/ipv6/sysctl_net_ipv6.c                         |   29 +-
 net/ipv6/tcp_ipv6.c                                |  269 +-
 net/ipv6/udp.c                                     |   53 +-
 net/ipv6/udp_impl.h                                |    2 +-
 net/ipv6/udplite.c                                 |    2 -
 net/ipx/af_ipx.c                                   |    4 +-
 net/irda/irlap_frame.c                             |    2 +-
 net/irda/irnet/irnet_ppp.c                         |   54 +-
 net/irda/irnet/irnet_ppp.h                         |    7 +-
 net/iucv/af_iucv.c                                 |    1 +
 net/iucv/iucv.c                                    |   15 +-
 net/key/af_key.c                                   |  622 +-
 net/llc/af_llc.c                                   |    4 +-
 net/llc/llc_input.c                                |    2 +-
 net/mac80211/Kconfig                               |  164 +-
 net/mac80211/Makefile                              |   20 +-
 net/mac80211/aes_ccm.c                             |   53 +-
 net/mac80211/aes_ccm.h                             |    6 +-
 net/mac80211/cfg.c                                 |   42 +-
 net/mac80211/debugfs.c                             |   58 +-
 net/mac80211/debugfs_key.c                         |    8 +-
 net/mac80211/debugfs_netdev.c                      |   59 +-
 net/mac80211/debugfs_netdev.h                      |    5 -
 net/mac80211/debugfs_sta.c                         |   56 +-
 net/mac80211/ieee80211_i.h                         |  179 +-
 net/mac80211/iface.c                               |  396 +-
 net/mac80211/key.c                                 |   11 +-
 net/mac80211/key.h                                 |   54 +-
 net/mac80211/main.c                                |  609 +-
 net/mac80211/mesh.c                                |   38 +-
 net/mac80211/mesh.h                                |    2 +-
 net/mac80211/mesh_hwmp.c                           |    2 +-
 net/mac80211/mesh_pathtbl.c                        |   54 +-
 net/mac80211/mesh_plink.c                          |   88 +-
 net/mac80211/michael.c                             |  116 +-
 net/mac80211/michael.h                             |    8 +-
 net/mac80211/mlme.c                                | 1035 +-
 net/mac80211/rate.c                                |   12 +-
 net/mac80211/rate.h                                |   37 +-
 net/mac80211/rc80211_pid.h                         |    4 +-
 net/mac80211/rc80211_pid_algo.c                    |   40 +-
 net/mac80211/rc80211_pid_debugfs.c                 |    8 +-
 net/mac80211/rx.c                                  |  683 +-
 net/mac80211/sta_info.c                            |   55 +-
 net/mac80211/sta_info.h                            |  168 +-
 net/mac80211/tkip.c                                |  282 +-
 net/mac80211/tkip.h                                |    8 +-
 net/mac80211/tx.c                                  | 1167 +-
 net/mac80211/util.c                                |  136 +-
 net/mac80211/wep.c                                 |   71 +-
 net/mac80211/wep.h                                 |    2 +-
 net/mac80211/wext.c                                |  145 +-
 net/mac80211/wme.c                                 |  676 +-
 net/mac80211/wme.h                                 |   43 +-
 net/mac80211/wpa.c                                 |  403 +-
 net/netfilter/Kconfig                              |    5 +-
 net/netfilter/nf_conntrack_core.c                  |   29 +-
 net/netfilter/nf_conntrack_extend.c                |   10 +-
 net/netfilter/nf_conntrack_netlink.c               |   32 +-
 net/netfilter/nf_conntrack_proto_dccp.c            |    3 +-
 net/netfilter/nf_conntrack_proto_sctp.c            |   80 +
 net/netfilter/nf_conntrack_proto_tcp.c             |   11 +-
 net/netfilter/nf_sockopt.c                         |    2 +-
 net/netfilter/nfnetlink_queue.c                    |    3 +-
 net/netfilter/xt_CONNSECMARK.c                     |   10 +-
 net/netfilter/xt_SECMARK.c                         |   10 +-
 net/netfilter/xt_string.c                          |   38 +-
 net/netlabel/netlabel_cipso_v4.c                   |    2 +-
 net/netlabel/netlabel_unlabeled.c                  |    2 +-
 net/netlink/af_netlink.c                           |    4 +-
 net/netrom/af_netrom.c                             |   24 +-
 net/packet/af_packet.c                             |  222 +-
 net/rfkill/rfkill-input.c                          |   98 +-
 net/rfkill/rfkill-input.h                          |    1 +
 net/rfkill/rfkill.c                                |  314 +-
 net/rose/af_rose.c                                 |   26 +-
 net/rose/rose_route.c                              |   29 +-
 net/rxrpc/ar-input.c                               |    5 +-
 net/sched/act_gact.c                               |    2 +-
 net/sched/act_ipt.c                                |    2 +-
 net/sched/act_mirred.c                             |    4 +-
 net/sched/act_nat.c                                |    2 +-
 net/sched/act_pedit.c                              |    2 +-
 net/sched/act_police.c                             |    8 +-
 net/sched/act_simple.c                             |    2 +-
 net/sched/cls_api.c                                |   20 +-
 net/sched/cls_flow.c                               |   52 +-
 net/sched/cls_route.c                              |   12 +-
 net/sched/cls_u32.c                                |   18 +-
 net/sched/sch_api.c                                |  613 +-
 net/sched/sch_atm.c                                |   12 +-
 net/sched/sch_cbq.c                                |  155 +-
 net/sched/sch_dsmark.c                             |   10 +-
 net/sched/sch_fifo.c                               |   49 +-
 net/sched/sch_generic.c                            |  465 +-
 net/sched/sch_gred.c                               |   14 +-
 net/sched/sch_hfsc.c                               |  110 +-
 net/sched/sch_htb.c                                |  195 +-
 net/sched/sch_ingress.c                            |    2 +-
 net/sched/sch_netem.c                              |   65 +-
 net/sched/sch_prio.c                               |  143 +-
 net/sched/sch_red.c                                |   37 +-
 net/sched/sch_sfq.c                                |   20 +-
 net/sched/sch_tbf.c                                |   42 +-
 net/sched/sch_teql.c                               |   50 +-
 net/sctp/Kconfig                                   |    4 +-
 net/sctp/Makefile                                  |    4 +-
 net/sctp/associola.c                               |    4 +
 net/sctp/bind_addr.c                               |   37 +
 net/sctp/input.c                                   |   38 +-
 net/sctp/ipv6.c                                    |   20 +-
 net/sctp/output.c                                  |   14 +-
 net/sctp/outqueue.c                                |   34 +-
 net/sctp/proc.c                                    |  141 +
 net/sctp/protocol.c                                |   35 +-
 net/sctp/sm_make_chunk.c                           |    7 +-
 net/sctp/sm_sideeffect.c                           |   44 +-
 net/sctp/sm_statefuns.c                            |   16 +-
 net/sctp/socket.c                                  |  383 +-
 net/sctp/transport.c                               |    3 +
 net/socket.c                                       |   92 +-
 net/sunrpc/auth_gss/auth_gss.c                     |    2 -
 net/sysctl_net.c                                   |   31 +-
 net/tipc/bcast.c                                   |   14 +-
 net/tipc/bearer.c                                  |    8 +-
 net/tipc/cluster.c                                 |    4 +-
 net/tipc/config.c                                  |   11 +-
 net/tipc/core.c                                    |   13 +-
 net/tipc/core.h                                    |  126 +-
 net/tipc/dbg.c                                     |  231 +-
 net/tipc/dbg.h                                     |   12 +-
 net/tipc/discover.c                                |   14 +-
 net/tipc/discover.h                                |    2 +-
 net/tipc/eth_media.c                               |   10 +-
 net/tipc/link.c                                    |   98 +-
 net/tipc/msg.c                                     |   13 +-
 net/tipc/msg.h                                     |   42 +-
 net/tipc/name_distr.c                              |    6 +-
 net/tipc/name_table.c                              |   55 +-
 net/tipc/net.c                                     |   14 +-
 net/tipc/net.h                                     |    2 +-
 net/tipc/netlink.c                                 |   16 +-
 net/tipc/node.c                                    |   55 +-
 net/tipc/port.c                                    |  115 +-
 net/tipc/ref.c                                     |   14 +-
 net/tipc/socket.c                                  |   62 +-
 net/tipc/subscr.c                                  |  249 +-
 net/tipc/subscr.h                                  |   34 +-
 net/tipc/user_reg.c                                |   14 +-
 net/unix/af_unix.c                                 |    2 -
 net/wanrouter/Kconfig                              |    2 -
 net/wanrouter/wanmain.c                            |    6 +-
 net/wanrouter/wanproc.c                            |    2 +-
 net/wireless/Kconfig                               |   11 +
 net/wireless/core.c                                |   33 +-
 net/wireless/nl80211.c                             |    6 +-
 net/wireless/radiotap.c                            |   16 +-
 net/wireless/wext.c                                |  584 +-
 net/x25/af_x25.c                                   |   11 +-
 net/x25/x25_dev.c                                  |    2 +-
 net/xfrm/xfrm_policy.c                             |    2 +-
 891 files changed, 90318 insertions(+), 67568 deletions(-)
 create mode 100644 Documentation/networking/dm9000.txt
 create mode 100644 Documentation/networking/mac80211_hwsim/README
 create mode 100644 Documentation/networking/mac80211_hwsim/hostapd.con=
f
 create mode 100644 Documentation/networking/mac80211_hwsim/wpa_supplic=
ant.conf
 delete mode 100644 drivers/atm/fore200e_firmware_copyright
 delete mode 100644 drivers/atm/fore200e_mkfirm.c
 delete mode 100644 drivers/atm/pca200e.data
 delete mode 100644 drivers/atm/pca200e_ecd.data
 delete mode 100644 drivers/atm/sba200e_ecd.data
 create mode 100644 drivers/net/8390p.c
 delete mode 100644 drivers/net/bnx2x.c
 create mode 100644 drivers/net/bnx2x_link.c
 create mode 100644 drivers/net/bnx2x_link.h
 create mode 100644 drivers/net/bnx2x_main.c
 delete mode 100644 drivers/net/ibm_emac/Kconfig
 delete mode 100644 drivers/net/ibm_emac/Makefile
 delete mode 100644 drivers/net/ibm_emac/ibm_emac.h
 delete mode 100644 drivers/net/ibm_emac/ibm_emac_core.c
 delete mode 100644 drivers/net/ibm_emac/ibm_emac_core.h
 delete mode 100644 drivers/net/ibm_emac/ibm_emac_debug.c
 delete mode 100644 drivers/net/ibm_emac/ibm_emac_debug.h
 delete mode 100644 drivers/net/ibm_emac/ibm_emac_mal.c
 delete mode 100644 drivers/net/ibm_emac/ibm_emac_mal.h
 delete mode 100644 drivers/net/ibm_emac/ibm_emac_phy.c
 delete mode 100644 drivers/net/ibm_emac/ibm_emac_phy.h
 delete mode 100644 drivers/net/ibm_emac/ibm_emac_rgmii.c
 delete mode 100644 drivers/net/ibm_emac/ibm_emac_rgmii.h
 delete mode 100644 drivers/net/ibm_emac/ibm_emac_tah.c
 delete mode 100644 drivers/net/ibm_emac/ibm_emac_tah.h
 delete mode 100644 drivers/net/ibm_emac/ibm_emac_zmii.c
 delete mode 100644 drivers/net/ibm_emac/ibm_emac_zmii.h
 create mode 100644 drivers/net/phy/mdio-ofgpio.c
 delete mode 100644 drivers/net/saa9730.c
 delete mode 100644 drivers/net/saa9730.h
 delete mode 100644 drivers/net/sfc/i2c-direct.c
 delete mode 100644 drivers/net/sfc/i2c-direct.h
 create mode 100644 drivers/net/sh_eth.c
 create mode 100644 drivers/net/sh_eth.h
 create mode 100644 drivers/net/usb/hso.c
 create mode 100644 drivers/net/wireless/iwlwifi/iwl-5000-hw.h
 create mode 100644 drivers/net/wireless/iwlwifi/iwl-5000.c
 create mode 100644 drivers/net/wireless/iwlwifi/iwl-calib.c
 create mode 100644 drivers/net/wireless/iwlwifi/iwl-calib.h
 rename drivers/net/wireless/iwlwifi/{iwl-4965-commands.h =3D> iwl-comm=
ands.h} (89%)
 rename drivers/net/wireless/iwlwifi/{iwl-4965.h =3D> iwl-dev.h} (66%)
 create mode 100644 drivers/net/wireless/iwlwifi/iwl-fh.h
 create mode 100644 drivers/net/wireless/iwlwifi/iwl-power.c
 create mode 100644 drivers/net/wireless/iwlwifi/iwl-power.h
 create mode 100644 drivers/net/wireless/iwlwifi/iwl-rx.c
 create mode 100644 drivers/net/wireless/iwlwifi/iwl-scan.c
 create mode 100644 drivers/net/wireless/iwlwifi/iwl-tx.c
 create mode 100644 drivers/net/wireless/libertas/persistcfg.c
 create mode 100644 drivers/net/wireless/mac80211_hwsim.c
 create mode 100644 include/linux/brcmphy.h
 create mode 100644 include/linux/netfilter_bridge/ebt_ip6.h
 create mode 100644 include/linux/smc911x.h
 create mode 100644 include/net/garp.h
 create mode 100644 include/net/netns/hash.h
 create mode 100644 include/net/netns/mib.h
 create mode 100644 include/net/stp.h
 create mode 100644 net/802/Kconfig
 create mode 100644 net/802/garp.c
 create mode 100644 net/802/stp.c
 create mode 100644 net/8021q/vlan_core.c
 create mode 100644 net/8021q/vlan_gvrp.c
 create mode 100644 net/bridge/netfilter/ebt_ip6.c
 create mode 100644 net/ipv4/netfilter/iptable_security.c
 create mode 100644 net/ipv6/netfilter/ip6table_security.c
