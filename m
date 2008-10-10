From: David Miller <davem@davemloft.net>
Subject: [GIT]: Networking for 2.6.28
Date: Fri, 10 Oct 2008 14:49:21 -0700 (PDT)
Message-ID: <20081010.144921.115563930.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49958
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1760467AbYJJVtq convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 10 Oct 2008 17:49:46 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Here are the queued up networking changes for the 2.6.28 merge window.

Highlights:

1) Proper transparent proxy support in netfilter.  We sort of lost
   this feature 5 or so years ago, but hey better late than never to
   get it back :-)

2) Phonet stack from Nokia

3) PRIO based multiqueue packet scheduler from Intel

4) The namespace folks have made a lot of progress with netfilter
   and ipv6 statistics handling.

5) IPVS netfilter gains ipv6 support and is moved out from
   net/ipv4 to net/netfilter

6) TCP socket dumping optimizations from Andi Kleen

7) New drivers: ATL2, SMSC LAN9500, Cisco ENIC, Qlogic QLGE 10g, Jmicro=
n JME

8) Transparent Ethernet Bridging over GRE tunnels by Herbert Xu.

9) Distributed Switch Architecture protocol support and several
   support drivers by Lennert Buytenhek.

10) Some infrastructure work so that we can soon switch sk_buff over to
    using struct list_head like the rest of the kernel.

Lots of wireless and in general driver changes across the board.

Please pull, thanks a lot!

[ Note: I generated this pull request by taking a clean copy of your tr=
ee,
        making a test branch, pulling this net-next-2.6.git tree into
	there, and generating the pull request by saying something like:

            git request-pull master $(NET_NEXT_26_GIT_URL)

        so if there is anything funny here, that might be the reason.

        I remember you showing me the "master...foo" syntax, but I coul=
dn't
	figure out how to use that here with request-pull.  ]

The following changes since commit f6bccf695431da0e9bd773550ae91b8cb9ff=
b227:
  Linus Torvalds (1):
        Merge git://git.kernel.org/.../herbert/crypto-2.6

are available in the git repository at:

  master.kernel.org:/pub/scm/linux/kernel/git/davem/net-next-2.6.git ma=
ster

Abhijeet Kolekar (8):
      iwlwifi : Added bss_info_changed callback to 3945
      iwl3945: fix unbalanced mutex
      iwl3945: replace association and beacon hooks with bss_info_chang=
ed cb
      iwl3945: removed bg_post_associate work
      iwl3945: avoid redundant iwl3945_get_active_dwell_time
      iwl3945: enable active scanning on active channels
      iwl3945 : Code cleanup
      mac80211 : Fix mode change hard_start_xmit function

Adrian Bunk (1):
      [netdrvr/usb] hso_create_bulk_serial_device(): fix a double free

Alan Cox (1):
      pcmcia: Fix up legacy driver IRQs

Alexander Duyck (11):
      igb: remove unneeded cleaned variable in clean_tx_irq path
      igb: clean up a stray fake netdev code left in rx path
      ixgbe: change config srrctl to only program one register per VMDq=
/RSS id
      vlan: vlan device not reading gso max size of parent.
      pkt_sched: Add multiqueue scheduler support
      pkt_action: add new action skbedit
      skbedit: Fix a typo in the documentation
      multiq: Further multiqueue cleanup
      multiq: requeue should rewind the current_band
      ixgbe: correctly add and remove napi queues
      ixgbe: whitespace/formatting cleanup

Alexey Dobriyan (41):
      net: more #ifdef CONFIG_COMPAT
      netns bridge: allow bridges in netns!
      netns bridge: cleanup bridges during netns stop
      netfilter: netns: remove nf_*_net() wrappers
      netfilter: netns: ip6table_raw in netns for real
      netfilter: netns: ip6table_mangle in netns for real
      netfilter: netns: ip6t_REJECT in netns for real
      netfilter: netns nf_conntrack: add netns boilerplate
      netfilter: netns nf_conntrack: add ->ct_net -- pointer from connt=
rack to netns
      netfilter: netns nf_conntrack: per-netns conntrack count
      netfilter: netns nf_conntrack: per-netns conntrack hash
      netfilter: netns: fix {ip,6}_route_me_harder() in netns
      netfilter: netns nf_conntrack: per-netns expectations
      netfilter: netns nf_conntrack: per-netns unconfirmed list
      netfilter: netns nf_conntrack: pass netns pointer to nf_conntrack=
_in()
      netfilter: netns nf_conntrack: pass netns pointer to L4 protocol'=
s ->error hook
      netfilter: netns nf_conntrack: per-netns /proc/net/nf_conntrack, =
/proc/net/stat/nf_conntrack
      netfilter: netns nf_conntrack: per-netns /proc/net/nf_conntrack_e=
xpect
      netfilter: netns nf_conntrack: per-netns /proc/net/ip_conntrack, =
/proc/net/stat/ip_conntrack, /proc/net/ip_conntrack_expect
      netns: export netns list
      netfilter: netns nf_conntrack: unregister helper in every netns
      netfilter: netns nf_conntrack: cleanup after L3 and L4 proto unre=
gister in every netns
      netfilter: netns nf_conntrack: pass conntrack to nf_conntrack_eve=
nt_cache() not skb
      netfilter: netns nf_conntrack: per-netns event cache
      netfilter: netns nf_conntrack: per-netns statistics
      netfilter: netns nf_conntrack: per-netns /proc/net/stat/nf_conntr=
ack, /proc/net/stat/ip_conntrack
      netfilter: netns nf_conntrack: per-netns net.netfilter.nf_conntra=
ck_count sysctl
      netfilter: netns nf_conntrack: per-netns net.netfilter.nf_conntra=
ck_checksum sysctl
      netfilter: netns nf_conntrack: per-netns net.netfilter.nf_conntra=
ck_log_invalid sysctl
      netfilter: netns nf_conntrack: per-netns conntrack accounting
      netfilter: netns nf_conntrack: final netns tweaks
      netfilter: netns nf_conntrack: SIP conntracking in netns
      netfilter: netns nf_conntrack: H323 conntracking in netns
      netfilter: netns nf_conntrack: GRE conntracking in netns
      netfilter: netns nf_conntrack: PPTP conntracking in netns
      netfilter: netns nat: fix ipt_MASQUERADE in netns
      netfilter: netns nat: per-netns NAT table
      netfilter: netns nat: per-netns bysource hash
      netfilter: netns nf_conntrack: fixup DNAT in netns
      netfilter: netns nat: PPTP NAT in netns
      netfilter: enable netfilter in netns

Andi Kleen (3):
      tcp: Skip empty hash buckets faster in /proc/net/tcp
      inet_diag: Add empty bucket optimization to inet_diag too
      mISDN: misc timerdev fixes

Andreas Oberritter (1):
      8139too: move wmb before TX DMA start

Andrew Morton (1):
      drivers/net/mlx4/alloc.c needs mm.h

Andrey Yurovsky (1):
      ath5k: add Mesh Point support

Andy Fleming (1):
      gianfar: free/iounmap memory after an error in mii bus initializa=
tion

Anna Neal (2):
      libertas: Improvements on automatic tx power control via SIOCSIWT=
XPOW.
      libertas: Improvements on automatic tx power control via SIOCSIWT=
XPOW (fixups)

Arjan van de Ven (2):
      warn: Turn the netdev timeout WARN_ON() into a WARN()
      netdev: uniquify the tx_timeout name

Arnaldo Carvalho de Melo (2):
      net: Use hton[sl]() instead of __constant_hton[sl]() where applic=
able
      inet_hashtables: Add inet_lookup_skb helpers

Arnaud Ebalard (1):
      xfrm: MIGRATE enhancements (draft-ebalard-mext-pfkey-enhanced-mig=
rate)

Arthur Jones (1):
      e1000e: release hw semaphore after successfully writing EEPROM

Ayaz Abdulla (1):
      forcedeth fix: take phy out of reset during power up

Ben Dooks (1):
      drivers/net/bonding: sparse fixes for exported tables

Ben Hutchings (49):
      sfc: Replace net_dev->priv with netdev_priv(net_dev)
      sfc: Change first parameter type of {set,clear}_bit_le() to unsig=
ned
      sfc: Use separate hardware TX queues to select checksum generatio=
n
      sfc: Avoid mangling error codes in efx_test_loopback()
      sfc: Reduce delays in SFE4001 initialisation
      sfc: Remove mistaken hardware workaround
      sfc: XMAC statistics fix-ups
      sfc: Remove inclusion of workarounds.h from efx.c
      sfc: Reverse the XOFF/XON pause frame control fifo thresholds
      sfc: Reduce log level for XGXS lane status
      sfc: Self-test reporting cleanup
      sfc: Speed up loopback self-test
      sfc: Don't leak PCI DMA maps in the TSO code when the queue fills=
 up
      sfc: Use pci_map_single() to map the skb header when doing TSO
      sfc: Reduce the size of struct efx_tx_buffer
      sfc: Use explicit bool for boolean variables, parameters and retu=
rn values
      sfc: Set net_device::vlan_features appropriately
      sfc: Cleaned up struct tso_state fields
      sfc: Removed forced inlining of long functions
      sfc: Export boot configuration in EEPROM through ethtool
      sfc: Move CPU counting for RSS into a separate function, efx_want=
ed_rx_queues()
      sfc: Remove efx_channel::has_interrupt
      sfc: Cleanup RX queue information
      sfc: Remove initialisation of RX_FILTER_CTL_REG.NUM_KER
      sfc: Make efx_for_each_channel_rx_queue() more efficient
      sfc: Remove efx_channel::evqnum field
      sfc: Cleanup RX event processing
      sfc: Implement get_sset_count, replacing get_stats_count and self=
_test_count
      sfc: Make PHY flash mode a device attribute, not a module paramet=
er
      sfc: Enable TSO for 802.1q VLAN devices
      sfc: Remove efx_nic_dummy_op_int() as redundant with efx_port_dum=
my_op_int()
      sfc: Remove remnants of multi-port abstraction for MAC registers
      sfc: Remove some unreachable error paths
      sfc: Cleanup reset code
      sfc: Rework the bitfield header so that we can identify fields by=
 bit number
      sfc: Extend self-tests
      sfc: Remove the STATE_RESETTING flag
      sfc: Rework efx_set_multicast_hash()
      sfc: Add check for memory allocation failure in falcon_probe_nic(=
)
      sfc: Fix memory BAR release call on error path
      sfc: Remove workaround for old firmware bug
      sfc: Serialise tenxpress_special_reset() with statistics fetches
      sfc: Make queue flushes more reliable
      sfc: Stop generating bogus events in tenxpress_check_hw()
      sfc: Insert read memory barrier after checking MAC statistics fla=
g
      sfc: Disable interrupts after a fatal interrupt occurs until rese=
t
      sfc: Remove obsolete comment about PCI modes
      sfc: Use CONFIG_HAVE_EFFICIENT_UNALIGNED_ACCESS where appropriate
      sfc: Fix type of FALCON_SPI_MAX_LEN

Benjamin Li (5):
      bnx2: In bnx2_set_mac_link() return void rather then int
      bnx2: Update MODULE_DESCRIPTION to include the 5716
      bnx2: Remove name field from bnx2 structure
      bnx2: Remove timer_interval field from the bnx2 structure
      bnx2: Handle DMA mapping errors.

Benjamin Thery (1):
      net: fix scheduling of dst_gc_task by __dst_free

Bjorn Helgaas (1):
      irda: follow lspci device/vendor style

Bob Copeland (1):
      ath5k: write beacon control register twice when resetting tsf

Brandeburg, Jesse (2):
      e1000: remove unused Kconfig option for disabling packet split
      ixgb: fix bug when freeing resources

Breno Leitao (1):
      s2io: Fix enabling VLAN tag stripping at driver initialization

Brian Cavagnolo (2):
      libertas: support boot commands to write persistent firmware and =
bootloader
      libertas: add sysfs hooks to update boot2 and persistent firmware

Brian Haley (2):
      bonding: change some __constant_htons() to htons()
      ipvs: change some __constant_htons() to htons()

Brice Goglin (6):
      myri10ge: Stop scaring people when DCA is built but absent
      myri10ge: Rename DCA-related firmware counters
      myri10ge: use DCA if DCA is compiled as a module
      myri10ge: add multiqueue TX
      myri10ge: remove over-paranoid queue number modulus
      myri10ge: update driver version number to 1.4.3-1.369

Bruce Allan (4):
      e1000e: add support for the 82567LM-4 device
      e1000e: add support for 82567LM-3 and 82567LF-3 (ICH10D) parts
      e1000e: add support for new 82574L part
      e1000e: remove failed request for sw/fw/hw flag

Bruno Pr=E9mont (2):
      r8169: WoL fixes, part 1.
      r8169: WoL fixes, part 2.

Bruno Randolf (5):
      ath5k: rates cleanup
      mac80211: add rx status flag for short preamble
      mac80211: radiotap: assume modulation from rates
      iwlwifi: use generic mac80211 radiotap headers
      ath5k: set short preamble flag for rx

Chr (2):
      p54: take tx_queue's lock in rx_frame_sent
      p54: redo queue numbering

Chris Snook (2):
      atl2: add atl2 driver
      MAINTAINERS: add Atheros maintainer for atlx

Christian Lamparter (15):
      p54: rename prism54xyz -> p54xyz
      p54: fix rssi auto calibration
      p54pci: rx tasklet refactoring
      p54pci: increase ring buffer index counter when skipping
      p54: enhance firmware parser to reduce memory waste
      p54: move eeprom code into common library
      p54usb: support LM87 firmwares
      p54: set_filter refactoring
      p54: better firmware support
      p54: 32-bit tsf timestamps
      p54: add more rx filters
      p54: add lots of useful rx/tx statistics
      p54: control output power levels
      p54: 802.11a 5GHz phy support
      p54: report appropriate rate and band values for 802.11a

Christopher Leech (1):
      ixgbe: Implement HAVE_SET_RX_MODE

Dan Nicholson (1):
      sundance: set carrier status on link change events

Dan Williams (7):
      libertas: convert CMD_802_11_RF_TX_POWER to a direct command
      libertas: convert CMD_802_11_DEAUTHENTICATE to a direct command
      libertas: convert CMD_802_11_RADIO_CONTROL to a direct command
      libertas: convert adhoc operations to direct commands
      libertas: clear current command on card removal
      libertas: remove unused generic RESET command
      libertas: convert SNMP_MIB to a direct command

Daniel Wagner (2):
      rt2x00mac: In error case stop netdev queue, free skb and return N=
ETDEV_TX_OK
      mac80211: Use only precedence level of DSCP field for frame class=
ification

Dave Graham (2):
      e1000e: don't generate bad checksums for tcp packets with 0 csum
      e1000: don't generate bad checksums for tcp packets with 0 csum

David Brownell (1):
      drivers/net/usb/Makefile - shrink logspam

David Fries (2):
      [netdrvr] ne: Fix suspend and resume for ISA PnP cards.
      ne.c: fix rmmod, platform driver improvements

David Kilroy (21):
      orinoco: Add ESSID specific scanning for Agere fw
      orinoco: Update scan translation
      orinoco: Specify all three parameters to every Hermes command.
      orinoco: Move EXPORT_SYMBOL declarations next to exported functio=
n
      orinoco: Add function to execute Hermes initialisation commands s=
ynchronously
      orinoco: Move firmware download functionality into new module
      orinoco: Make firmware download logic more generic
      orinoco: Extend hermes_dld routines for Agere firmware
      orinoco: Invoke firmware download in main driver
      orinoco: Fix transmit for Agere/Lucent with fw 9.x
      orinoco: address checkpatch typedef warning
      orinoco: Use extended Agere scans available on 9.x series firmwar=
es
      orinoco: Don't use boolean parameter to record encoding type
      orinoco: Split wevent work thread from wevent sending
      orinoco: Use a macro to define wireless handlers
      orinoco: Add WE-18 ioctls for WPA
      orinoco: Send association events to userspace
      orinoco: Process bulk of receive interrupt in a tasklet
      orinoco: Add MIC on TX and check on RX
      orinoco: Fix compile warnings
      wireless: Read scan flags correctly on x86-64

David S. Miller (64):
      Merge branch 'lvs-next-2.6' of git://git.kernel.org/.../horms/lvs=
-2.6
      Merge branch 'master' of git://git.kernel.org/.../linville/wirele=
ss-next-2.6
      Merge branch 'master' of master.kernel.org:/.../davem/net-2.6
      Merge branch 'master' of git://git.kernel.org/.../linville/wirele=
ss-next-2.6
      Merge branch 'master' of master.kernel.org:/.../torvalds/linux-2.=
6
      Merge branch 'dccp' of git://eden-feed.erg.abdn.ac.uk/dccp_exp
      Merge branch 'master' of git://eden-feed.erg.abdn.ac.uk/net-next-=
2.6
      ipsec: Make xfrm_larval_drop default to 1.
      Merge branch 'master' of master.kernel.org:/.../davem/net-2.6
      Merge branch 'lvs-next-2.6' of git://git.kernel.org/.../horms/lvs=
-2.6
      ipsec: Add missing list_del() in xfrm_state_gc_task().
      ipv6: On interface down/unregister, purge icmp routes too.
      net: Add DMA mapping tokens to skb_shared_info.
      net: Add SKB DMA mapping helper functions.
      tg3: Use SKB DMA helper functions for TX.
      tg3: Fix DMA mapping leak in tigon3_dma_hwbug_workaround().
      Merge branch 'master' of git://git.kernel.org/.../linville/wirele=
ss-next-2.6
      Merge branch 'master' of master.kernel.org:/.../davem/net-2.6
      net: Fix build with ARCH=3Dum
      Merge branch 'new-drivers' of master.kernel.org:/.../jgarzik/netd=
ev-2.6
      qlge: Fix warnings in debugging code.
      qlge: Protect qlge_resume() with CONFIG_PM
      Merge branch 'master' of git://git.kernel.org/.../linville/wirele=
ss-next-2.6
      net: Remove __skb_insert() calls outside of skbuff internals.
      atm: idt77252: Use generic SKB queue management instead of home-g=
rown scheme.
      net: Add new interfaces for SKB list light-weight init and splici=
ng.
      aoe: Use SKB interfaces for list management instead of home-grown=
 stuff.
      bluetooth: hci_bcsp: Use SKB list interfaces instead of home-grow=
n stuff.
      isdn: isdn_ppp: Use SKB list facilities instead of home-grown imp=
lementation.
      cxgb3: Use SKB list interfaces instead of home-grown implementati=
on.
      usbnet: Use skb_queue_walk_safe() instead of by-hand implementati=
on.
      net: Fix bus in SKB queue splicing interfaces.
      sctp: Use skb_queue_walk_safe() and skb_queue_split_tail_init().
      pkt_sched: Make qdisc->gso_skb a list.
      pkt_sched: Always use q->requeue in dev_requeue_skb().
      de4x5: Use skb_queue_head instead of by-hand implementation.
      zd1211: Use skb_queue_walk() instead of by-hand implementation.
      usbatm: Use skb_queue_walk_safe() instead of by-hand implementati=
on.
      net: Add skb_queue_is_last().
      tcp: Use skb_queue_is_last() instead of by-hand version.
      net: Add skb_queue_next().
      net: Add skb_queue_walk_from() and skb_queue_walk_from_safe().
      tcp: Use SKB queue handling interfaces instead of by-hand version=
s.
      neigh: Remove by-hand SKB queue handling.
      ppp_generic: Use skb_peek() in ppp_receive_mp_frame().
      tcp: Fix order of tests in tcp_retransmit_skb()
      tcp: Fix queue traversal in tcp_use_frto().
      aoe: Fix OOPS after SKB queue changes.
      Merge branch 'davem-next' of master.kernel.org:/.../jgarzik/netde=
v-2.6
      Revert "ehea: fix mutex and spinlock use"
      Merge branch 'master' of git://git.kernel.org/.../linville/wirele=
ss-next-2.6
      Merge branch 'master' of git://git.kernel.org/.../linville/wirele=
ss-next-2.6
      Merge branch 'master' of master.kernel.org:/.../davem/net-2.6
      tcp: Respect SO_RCVLOWAT in tcp_poll().
      Merge branch 'master' of git://git.kernel.org/.../linville/wirele=
ss-next-2.6
      Merge branch 'master' of git://git.kernel.org/.../kaber/nf-next-2=
=2E6
      Merge branch 'lvs-next-2.6' of git://git.kernel.org/.../horms/lvs=
-2.6
      Merge branch 'master' of master.kernel.org:/.../davem/net-2.6
      dsa: Need to select PHYLIB.
      jme: Fix warnings with CONFIG_PM disabled.
      ppp: Use skb_queue_walk() in ppp_mp_insert().
      enic: Attempt to fix build in 32-bit such as i386.
      Merge branch 'r8169' of git://git.kernel.org/.../romieu/netdev-2.=
6
      Merge branch 'master' of master.kernel.org:/.../davem/net-next-2.=
6 into net2628-test

Davide Pesavento (2):
      Fix modpost failure when rx handlers are not inlined.
      wireless: fix typo in Kconfig.

Denis ChengRq (1):
      wireless: a global static to local static improvement

Denis Joseph Barrow (1):
      [netdrvr] usb/hso: throttle to prevent loss of serial data

Denis V. Lunev (23):
      netns: move /proc/net/dev_snmp6 to struct net
      netns: register /proc/net/dev_snmp6/* in each ns
      ipv6: consolidate ipv6 sock_stat code at the beginning of net/ipv=
6/proc.c
      ipv6: separate seq_ops for global & per/device ipv6 statistics
      netns: register global ipv6 mibs statistics in each namespace
      netns: allow per device ipv6 snmp statistics in non-initial names=
pace
      netns: add stub functions for per/namespace mibs allocation
      netns: make udpv6 mib per/namespace
      netns: make uplitev6 mib per/namespace
      ipv6: local dev is actually unused in ip6_fragment
      ipv6: consolidate error paths in ipv6_frag_rcv
      netns: add net parameter to IP6_INC_STATS
      ipv6: added net argument to IP6_INC_STATS_BH
      ipv6: added net argument to IP6_ADD_STATS_BH
      ipv6: added net argument to ICMP6_INC_STATS
      ipv6: added net argument to ICMP6_INC_STATS_BH
      ipv6: added net argument to ICMP6MSGOUT_INC_STATS
      ipv6: added net argument to ICMP6MSGOUT_INC_STATS_BH
      ipv6: ICMP6MSGIN_INC_STATS is not used
      ipv6: added net argument to ICMP6MSGIN_INC_STATS_BH
      ipv6: added net argument to _DEVINC/_DEVADD
      ipv6: making ip and icmp statistics per/namespace
      ipv6: remove unused not init_ipv6_mibs/cleanup_ipv6_mibs

Dhananjay Phadke (2):
      netxen: add pci ids
      netxen: enable msi-x for quad-gig boards

Divy Le Ray (10):
      cxgb3 - remove duplicate tests in lro
      [2.6.28,1/1] cxgb3 - fix race in EEH
      cxgb3: reset the adapter on fatal error
      cxgb3: Allocate multiqueues at init time
      cxgb3: allow for PHY reset status
      cxgb3: simplify port type struct and usage
      cxgb3: More flexible support for PHY interrupts.
      cxgb3: commnonize LASI phy code
      cxgb3: Support for Aeluros 2005 PHY
      cxgb3: Add 1G fiber support

Ehud Gavron (1):
      b43legacy: Fix to enhance TX speed

Emmanuel Grumbach (7):
      mac80211: Fix rate scale initialization in IBSS
      iwlwifi: fix strict_strtoul error checking
      iwlwifi: allow association on radar channel in power save
      iwlwifi: take a fresh set of supported rates at each cycle
      iwlwifi: remove uneeded declarations
      iwlwifi: remove HT flags from RXON when not in HT anymore
      mac80211: fix led behavior in IBSS

Eric Dumazet (4):
      ip: speedup /proc/net/rt_cache handling
      udp: Improve port randomization
      inet: cleanup of local_port_range
      udp: complete port availability checking

Ester Kummer (1):
      iwlwifi: enable power save setting upon config

Esti Kummer (1):
      iwlwifi: add level for debugging host command

=46elipe Balbi (1):
      rfkill: add missing line break

=46elix Fietkau (4):
      mac80211: free up 2 bytes in skb->cb
      mac80211: add multi-rate retry support
      ath5k: implement multi-rate retry support, fix tx status reportin=
g
      mac80211: add the 'minstrel' rate control algorithm

=46lorian Fainelli (2):
      r6040: fix bad usage of udelay
      r6040: fix wrong assignment in r6040_free_txbufs

=46rancois Romieu (24):
      r8169: get ethtool settings through the generic mii helper
      r8169: Tx performance tweak helper
      r8169: use pci_find_capability for the PCI-E features
      r8169: add 8168/8101 registers description
      r8169: add hw start helpers for the 8168 and the 8101
      r8169: additional 8101 and 8102 support
      r8169: fix RxMissed register access
      r8169: select MII in Kconfig
      via-velocity: Fix warnings on sparc64.
      r8169: fix early spinlock use
      r8169: wake up the PHY of the 8168
      r8169: update phy init parameters
      r8169: new phy init parameters for the 8168b
      r8169: shuffle some registers handling around (8168 operation onl=
y)
      r8169: make room for more specific 8168 hardware start procedure
      r8169: 8168b Tx performance tweak
      r8169: sync existing 8168 device hardware start sequences with ve=
ndor driver
      r8169: add a new 8168c flavor
      r8169: add a new 8168c flavor (bis)
      r8169: add a new 8168cp flavor
      r8169: change default behavior for mildly identified 8168c chipse=
ts
      r8169: support additional 8168cp chipset
      r8169: preliminary 8168d support
      r8169: add shutdown handler

=46rans Pop (1):
      e1000e: avoid duplicated output of device name in kernel warning

Gerrit Renker (108):
      dccp: Silently ignore options with nonsensical lengths
      dccp: Fill in the Data fields for "Option Error" Resets
      dccp: Empty the write queue when disconnecting
      dccp: Toggle debug output without module unloading
      dccp ccid-3: Replace lazy BUG_ON with condition
      dccp: Silently ignore options with nonsensical lengths
      dccp: Fill in the Data fields for "Option Error" Resets
      dccp: Empty the write queue when disconnecting
      dccp: Toggle debug output without module unloading
      dccp ccid-3: Replace lazy BUG_ON with condition
      dccp: Basic data structure for feature negotiation
      dccp: Implement lookup table for feature-negotiation information
      dccp: List management for new feature negotiation
      dccp: Per-socket initialisation of feature negotiation
      dccp: Cleanup routines for feature negotiation
      dccp: Limit feature negotiation to connection setup phase
      dccp: Registration routines for changing feature values
      dccp: Query supported CCIDs
      dccp: Resolve dependencies of features on choice of CCID
      dccp: Mechanism to resolve CCID dependencies
      dccp: Deprecate old setsockopt framework
      dccp: Feature negotiation for minimum-checksum-coverage
      dccp: Deprecate Ack Ratio sysctl
      dccp: Tidy up setsockopt calls
      dccp: Set per-connection CCIDs via socket options
      dccp: API to query the current TX/RX CCID
      dccp: Increase the scope of variable-length htonl/ntohl functions
      dccp: Support for Mandatory options
      dccp: Header option insertion routine for feature-negotiation
      dccp: Insert feature-negotiation options into skb
      dccp: Integrate feature-negotiation insertion code
      dccp: Preference list reconciliation
      dccp: Process incoming Change feature-negotiation options
      dccp: Processing Confirm options
      dccp: Feature activation handlers
      dccp: Integration of dynamic feature activation - part 1 (socket =
setup)
      dccp: Integration of dynamic feature activation - part 2 (server =
side)
      dccp: Integration of dynamic feature activation - part 3 (client =
side)
      dccp: Clean up old feature-negotiation infrastructure
      dccp: Remove obsolete parts of the old CCID interface
      dccp: Remove manual influence on NDP Count feature
      dccp ccid-2: Phase out the use of boolean Ack Vector sysctl
      dccp: Initialisation framework for feature negotiation
      dccp: Auto-load (when supported) CCID plugins for negotiation
      dccp: Implement both feature-local and feature-remote Sequence Wi=
ndow feature
      dccp: Initialisation and type-checking of feature sysctls
      dccp: Debugging functions for feature negotiation
      dccp: Support for the exchange of NN options in established state
      dccp: Support for exchanging of NN options in established state
      dccp ccid-2: Use feature-negotiation to report Ack Ratio changes
      dccp: Leave headroom for options when calculating the MPS
      dccp: Special case of the MPS for client-PARTOPEN with DataAcks
      dccp ccid-2: Remove ccid2hc{tx,rx}_ prefixes
      dccp ccid-3: Remove ccid3hc{tx,rx}_ prefixes
      dccp ccid-3: No more CCID control blocks in LISTEN state
      dccp ccid-3: Bug fix for the inter-packet scheduling algorithm
      dccp ccid-3: Remove ugly RTT-sampling history lookup
      dccp ccid-3: Simplify and consolidate tx_parse_options
      dccp: Add packet type information to CCID-specific option parsing
      dccp tfrc/ccid-3: Computing Loss Rate from Loss Event Rate
      dccp ccid-3: Remove redundant 'options_received' struct
      dccp: Replace magic CCID-specific numbers by symbolic constants
      dccp: Unused argument in CCID tx function
      dccp ccid-3: Remove duplicate documentation
      dccp ccid-3: Remove dead states
      dccp: Schedule an Ack when receiving timestamps
      dccp: Fix the adjustments to AWL and SWL
      dccp: Merge now-reduced connect_init() function
      dccp: Reduce noise in output and convert to ktime_t
      dccp ccid-2: Ack Vector interface clean-up
      dccp ccid-2: Separate internals of Ack Vectors from option-parsin=
g code
      dccp ccid-2: Implementation of circular Ack Vector buffer with ov=
erflow handling
      dccp ccid-2: Algorithm to update buffer state
      dccp ccid-2: Update code for the Ack Vector input/registration ro=
utine
      dccp ccid-2: Consolidate Ack-Vector processing within main DCCP m=
odule
      dccp ccid-2: Schedule Sync as out-of-band mechanism
      dccp ccid-2: Remove old infrastructure
      dccp ccid-2: Separate option parsing from CCID processing
      dccp: Return-value convention of hc_tx_send_packet()
      dccp: Extend CCID packet dequeueing interface
      dccp: Refine the wait-for-ccid mechanism
      dccp ccid-2: Stop polling
      dccp ccid-2: Remove redundant sanity tests
      dccp ccid-2: Simplify dec_pipe and rearming of RTO timer
      dccp ccid-2: Replace broken RTT estimator with better algorithm
      dccp ccid-2: Remove wrappers around sk_{reset,stop}_timer()
      dccp: Combine the functionality of enqeueing and cloning
      tcp/dccp: Consolidate common code for RFC 3390 conversion
      dccp: Clean up slow-path input processing
      dccp ccid-3: Runtime verification of timer resolution
      dccp ccid-3: Simplified handling of TX states
      dccp tfrc: Suppress unavoidable "below resolution" warning
      dccp tfrc: Receiver history initialisation routine
      dccp tfrc: Perform early loss detection
      dccp tfrc: Return type of update_i_mean is void
      dccp tfrc: Let dccp_tfrc_lib do the sampling work
      dccp ccid-3: Remove duplicate RX states
      dccp ccid-3: Always perform receiver RTT sampling
      dccp: Clamping RTT values
      dccp tfrc: Increase number of RTT samples
      dccp ccid-3: Update the computation of X_recv
      dccp ccid-3: Update the RX history records in one place
      dccp ccid-3: Implement rfc3448bis change to initial-rate computat=
ion
      dccp ccid-3: Tidy up CCID-Kconfig dependencies
      dccp ccid-3: Measuring the packet size s with regard to rfc3448bi=
s-06
      dccp ccid-3: Simplify computing and range-checking of t_ipi
      dccp ccid-3: Preventing Oscillations
      This reverts "Merge branch 'dccp' of git://eden-feed.erg.abdn.ac.=
uk/dccp_exp"

Gertjan van Wingerde (2):
      rt2x00: Fix build errors due to modularized rfkill or leds and bu=
ilt-in rt2x00.
      rt2x00: Fix rfkill structure initialization to prevent rfkill WAR=
N_ON.

Grumbach, Emmanuel (1):
      iwlwifi: use the results from disconnected antenna algorithm

Guo-Fu Tseng (5):
      jme: JMicron Gigabit Ethernet Driver
      jme: Added half-duplex mode and IPv6 RSS fix
      jme: Advances version number
      nf_conntrack_ecache.h: Fix missing braces
      tcpv6: fix error with CONFIG_TCP_MD5SIG disabled

Guy Cohen (2):
      iwlwifi: fix searching for best rate in new search column
      iwlwifi: Added support for 3 antennas

Hannes Hering (2):
      ehea: Fix DLPAR memory handling
      ehea: Enable DLPAR memory remove

Harvey Harrison (18):
      b43legacy: use le16 frame control directly, avoid byteswapping
      iwlwifi: use le16 frame control directly, use QOS symbolic consta=
nt mask
      ath5k: explicitly check skb->len
      mac80211: explicitly check skb->len
      mac80211: wme.h remove unused QOS_CONTROL_LEN
      mac80211: wep.c replace magic numbers in IV/ICV removal
      mac80211: rx.c/tx.c remove more users of tx/rx_data->fc
      mac80211: remove ieee80211_get_hdrlen
      mac80211: remove IEEE80211_FC helper
      mac80211: use ieee80211 frame control directly
      mac80211: remove rx/tx_data->fc member
      mac80211: remove WLAN_FC_DATA_PRESENT
      wireless: replace __FUNCTION__ with __func__
      libertas: use the common frame control functions
      mISDN: endian annotations for struct zt
      mISDN: annotate iomem pointer and add statics
      net: em_cmp.c use unaligned access helpers
      drivers/net: replace __FUNCTION__ with __func__

Henrique de Moraes Holschuh (9):
      rfkill: detect bogus double-registering (v2)
      rfkill: add default global states (v2)
      rfkill: add __must_check annotations
      rfkill: introduce RFKILL_STATE_MAX
      rfkill: use strict_strtoul (v2)
      rfkill: add WARN and BUG_ON paranoia (v2)
      rfkill: rename rfkill_mutex to rfkill_global_mutex
      rfkill: remove transmitter blocking on suspend
      rfkill: update LEDs for all state changes

Herbert Xu (11):
      net: Enable TSO if supported by at least one device
      ipsec: Use RCU-like construct for saved state within a walk
      ipsec: Fix xfrm_state_walk race
      ipsec: Put dumpers on the dump list
      net: BUG instead of corrupting memory in pskb_expand_head
      netdrv: Fix unregister_netdev typos
      gre: Use needed_headroom
      gre: Move MTU setting out of ipgre_tunnel_bind_dev
      gre: Add netlink interface
      gre: Add Transparent Ethernet Bridging
      inet: Make tunnel RX/TX byte counters more consistent

Herton Ronaldo Krzesinski (1):
      rtl818x: merge tx/rx descriptor flags

Huang Weiyi (2):
      wireless: remove unused #include <version.h>
      [netdrvr] removed unused #include <version.h>

Ilpo J=E4rvinen (28):
      tcp: Add tcp_validate_incoming & put duplicated code there
      tcp: Add tcp_collapse_one to eliminate duplicated code
      tcp: Add tcp_parse_aligned_timestamp
      s2io: reindented misleading for loop
      tcp: Partial hint clearing has again become meaningless
      tcp: move tcp_verify_retransmit_hint
      tcp: add helper for lost bit toggling
      tcp: convert retransmit_cnt_hint to seqno
      tcp: Kill precaution that's very likely obsolete
      tcp: No need to clear retransmit_skb_hint when SACKing
      tcp: add tcp_can_forward_retransmit
      tcp: remove obsolete validity concern
      tcp: Reorganize skb tagbit checks
      tcp: remove tp->lost_out guard to make joining diff nicer
      tcp: reorganize retransmit code loops
      tcp: remove retransmit_skb_hint clearing from failure
      tcp: don't clear retransmit_skb_hint when not necessary
      tcp: don't clear lost_skb_hint when not necessary
      tcp: back retransmit_high when it over-estimated
      ipv6: almost identical frag hashing funcs combined
      tcp: kill pointless urg_mode
      tcp: cleanup messy initializer
      tcp: fix length used for checksum in a reset
      tcpv6: fix option space offsets with md5
      tcpv[46]: fix md5 pseudoheader address field ordering
      tcpv6: trivial formatting changes to send_(ack|reset)
      tcpv6: convert opt[] -> topt in tcp_v6_send_reset
      tcpv6: combine tcp_v6_send_(reset|ack)

Ivan Vecera (1):
      r8169: read MAC address from EEPROM on init

Ivo van Doorn (16):
      rt2x00: Implement HW encryption
      rt2x00: Implement HW encryption (rt61pci)
      rt2x00: Implement HW encryption (rt73usb)
      rt2x00: Gather channel information in structure
      rt2x00: Release rt2x00 2.2.0
      rt2x00: Move lna_gain calculation to config() callback
      rt2x00: Add module parameter to disable HW crypto
      rt2x00: Fix race conditions in flag handling
      rt2x00: Map extra_tx_headroom to DMA
      rt2x00: Initialize txop during conf_tx() callback
      rt2x00: Add Signal type flag
      rt2x00: Release rt2x00 2.2.1
      rt2x00: Revert "rt2x00: Fix the beacon length bug"
      rt2x00: Make RFKILL enabled by default
      rt2x00: Make rt2x00 LEDS invisible config option
      rt2x00: Fix HW crypto key handling

Jan Engelhardt (36):
      netfilter: Use unsigned types for hooknum and pf vars
      netfilter: rename ipt_recent to xt_recent
      netfilter: xt_recent: IPv6 support
      netfilter: Introduce NFPROTO_* constants
      netfilter: x_tables: use NFPROTO_* in extensions
      netfilter: implement NFPROTO_UNSPEC as a wildcard for extensions
      netfilter: ebtables: do centralized size checking
      netfilter: change return types of check functions for Ebtables ex=
tensions
      netfilter: change return types of match functions for ebtables ex=
tensions
      netfilter: Change return types of targets/watchers for Ebtables e=
xtensions
      netfilter: add dummy members to Ebtables code to ease transition =
to Xtables
      netfilter: ebt_among: obtain match size through different means
      netfilter: change Ebtables function signatures to match Xtables's
      netfilter: move Ebtables to use Xtables
      netfilter: x_tables: output bad hook mask in hexadecimal
      netfilter: ebtables: use generic table checking
      netfilter: implement hotdrop for Ebtables
      netfilter: remove unused Ebtables functions
      netfilter: remove redundant casts from Ebtables
      netfilter: ebtables: fix one wrong return value
      netfilter: xtables: do centralized checkentry call (1/2)
      netfilter: ip6tables: fix name of hopbyhop in Kconfig
      netfilter: ip6tables: fix Kconfig entry dependency for ip6t_LOG
      netfilter: ebtables: make BRIDGE_NF_EBTABLES a menuconfig option
      netfilter: xtables: sort extensions alphabetically in Kconfig
      netfilter: xtables: use "if" blocks in Kconfig
      netfilter: xtables: move extension arguments into compound struct=
ure (1/6)
      netfilter: xtables: move extension arguments into compound struct=
ure (2/6)
      netfilter: xtables: move extension arguments into compound struct=
ure (3/6)
      netfilter: xtables: move extension arguments into compound struct=
ure (4/6)
      netfilter: xtables: move extension arguments into compound struct=
ure (5/6)
      netfilter: xtables: move extension arguments into compound struct=
ure (6/6)
      netfilter: xtables: provide invoked family value to extensions
      netfilter: xtables: cut down on static data for family-independen=
t extensions
      netfilter: xtables: use NFPROTO_UNSPEC in more extensions
      netfilter: xtables: remove bogus mangle table dependency of connm=
ark

Jarek Poplawski (6):
      pkt_sched: Check the state of tx_queue in dequeue_skb()
      pkt_sched: Remove the tx queue state check in qdisc_run()
      pkt_sched: Fix handling of gso skbs on requeuing
      pkt_sched: Simplify dev_requeue_skb and dequeue_skb
      pkt_sched: Update qdisc requeue stats in dev_requeue_skb()
      lib8390: Fix locking in ei_poll (poll controller)

Jasper Bryant-Greene (2):
      move ETH_P_PAE from ieee80211_i.h to if_ether.h
      replace net_device arguments with ieee80211_{local,sub_if_data} a=
s appropriate

Jaswinder Singh (1):
      cassini: use request_firmware

Javier Cardona (2):
      libertas: Reduce the WPA key installation time.
      libertas: Reduce the WPA key installation time (fixups)

Jay Cliburn (5):
      atl2: add tx bytes statistic
      atl1: fix transmit timeout bug
      atl1: remove LLTX
      atl1: remove EXPERIMENTAL label
      atl1: update introductory comments

Jeff Garzik (2):
      Merge branch 'r8169-fixes' of git://git.kernel.org/.../romieu/net=
dev-2.6 into upstream-next
      Merge branch 'for-2.6.28' of git://git.marvell.com/mv643xx_eth in=
to upstream-next

Jeff Kirsher (2):
      ixgbe: fix pci_resource allocation as in other drivers
      ixgbe: bump version

Jesse Brandeburg (34):
      ixgbe: fix rx csum return status misinterpretation
      ixgbe: add little endian annotations for sparse
      ixgbe: do not update stats twice each receive
      ixgbe: Cleanup references to Tx and Rx rings to becommon across t=
he driver
      ixgbe: disable flow control by default
      ixgbe: Implement Tx Head Writeback
      ixgbe: Lock RSS seed, move rx_buf_len to the rx_ring
      ixgbe: should not use HW_CSUM, should use IP* flags
      ixgbe: update dca to new interface, fix CONFIG_DCA_MODULE
      ixgbe: fix bug where lro settings are per ring
      ixgbe: fix dca hints going to wrong processor
      ixgbe: fix bug where using wake queue instead of start
      ixgbe: fix dca defines to not have spaces
      ixgbe: fix multicast address update
      ixgbe: Update watchdog thread to accomodate longerlink_up events
      ixgbe: link change interrupt was not causing link event
      ixgbe: fix bug with shared interrupts
      ixgbe: limit small mtu to minimum for ipv4 support
      ixgbe: fix ethtool register dump
      ixgbe: fix ethtool disable csum for ipv6
      ixgbe: fix initial interrupt throttle settings
      ixgbe: fix bug with lots of tx queues
      ixgbe: recycle pages in packet split mode
      ixgbe: add device support for XF LR adapters
      ixgbe: fix ring reallocation in ethtool
      ixgbe: lro stats were not counted on first ethtool -Scall
      ixgbe: add clean rx many routine
      ixgbe: update to latest common code module
      ixgbe: refresh the ixgbe_down function
      ixgbe: move set_num_queues and call it after msix failure
      ixgbe: cleanup defines
      ixgbe: lower stack space usage
      ixgbe: xmit frame refactor
      ixgbe: fix DCA dependency in Kconfig

Jie Yang (1):
      atl1e: remove the unneeded (struct atl1e_adapter *)

Jiri Slaby (1):
      Ath5k: unify resets

Johannes Berg (72):
      mac80211: fill start-sequence-number for BA session start
      mac80211: move some RCU locking into an if branch
      mac80211: make conf_tx non-atomic
      mac80211: BSS info: check channel first
      mac80211: fix action frame length checks
      mac80211: fix typo in action frame handling
      mac80211: move IE parsing to util file
      mac80211: reorder mlme code
      mac80211: use sdata pointer for scan interface
      mac80211: remove useless non-NULL tests from scan results code
      mac80211: start moving scan code from mlme
      mac80211: refactor and move scan RX code
      mac80211: move BSS handling to scan code
      mac80211: move some HT code out of mlme.c
      mac80211: move some HT code out of main.c
      mac80211: clarify scan request
      mac80211: simplify scan start
      mac80211: remove useless 'ibss' parameter
      mac80211: reorder frame code in mlme
      mac80211: consolidate deauth/disassoc
      mac80211: split ieee80211_sta_def_wmm_params
      mac80211: initialise queue QoS parameters at hw start
      mac80211: make BA session handling independent of STA mode
      mac80211: move spectrum management code out
      mac80211: make ieee80211_rx_h_mgmt more readable
      mac80211: move frame TX function
      mac80211: move ieee80211_sta_expire
      mac80211: move STA timer restart
      mac80211: dont set REQ_RUN when scan finishes
      mac80211: split off mesh handling entirely
      mac80211: fix work race
      mac80211: fix scan vs. interface removal race
      mac80211: reorder MLME code more
      mac80211: move ieee80211_set_freq to utils
      mac80211: make bridge_packets a virtual interface option
      mac80211: clean up scan namespace
      mac80211: clean up some comments
      mac80211: inform driver of basic rateset
      mac80211: use nl80211 interface types
      mac80211: move regular interface handling
      mac80211: warn on some invalid vlan operations
      mac80211 hwsim: verify vif pointers
      mac80211: share STA information with driver
      mac80211 hwsim: verify sta pointers
      mac80211: small rate control changes
      mac80211: move last_txrate_idx into RC algorithms
      mac80211: share sta->supp_rates
      mac80211: move txrate_idx into RC algorithms
      mac80211: share sta_info->ht_info
      iwlwifi: don't access mac80211's AMPDU state machine
      mac80211: pass AP vif pointer for VLANs
      mac80211: fix virtual interfaces vs. injection
      mac80211 hwsim: make radio list dynamic
      mac80211: fix sta_info kernel-doc warning
      mac80211: clean up kdoc
      mac80211: remove beacon counters
      mac80211: remove debug frame dumping
      cfg80211: fix static regdomains
      cfg80211: clean up regulatory mess
      cfg80211: fix regulatory code const
      cfg80211: clean up static regdomain mess
      cfg80211: fix code ordering in header file
      mac80211: make master iface not wireless
      cfg80211: show interface type
      cfg80211: allow set_interface without type
      mac80211: allow interface settings changes only when down
      cfg80211: reject invalid configuration items
      mac80211: fix mesh action frame handling
      mac80211: clean up rate control API
      mac80211: probe with correct SSID
      iwlagn: downgrade BUG_ON in interrupt
      mac80211: fixups for "make master iface not wireless"

John W. Linville (4):
      libertas: correct "limited range of data type" warning
      ieee80211.h: remove superfluous ETH_P_PAE definition
      ath9k: fixup some merge damage
      mac80211: avoid "Wireless Event too big" message for assoc respon=
se

Jouni Malinen (11):
      mac80211/cfg80211: Add BSS configuration options for AP mode
      ath9k: Allow AP mode to be enabled
      ath9k: Updated Beacon generation to use mac80211-style
      ath9k: Fix TX status reporting
      ath9k: Assign seq# when mac80211 requests this
      ath9k: Fix TX control flag use for no ACK and RTS/CTS
      mac80211: Handle scan result IEs in one block
      mac80211_hwsim: Add minimal IEEE 802.11n support
      ath9k: Use mac80211 for multicast power save buffering
      mac80211/cfg80211: HT capabilities for NEW_STA
      mac80211: Reorder debugfs calls during netdev deinit

Julia Lawall (5):
      net/ieee80211: adjust error handling
      drivers/isdn/capi/kcapi.c: Adjust error handling code involving c=
api_ctr_put
      drivers/atm: Use DIV_ROUND_UP
      drivers/net/wan: Use DIV_ROUND_UP
      net/atm/lec.c: drop code after return

Julian Anastasov (1):
      ipv4: Loosen source address check on IPv4 output

Julius Volz (28):
      IPVS: Add genetlink interface definitions to ip_vs.h
      IPVS: Add genetlink interface implementation
      IPVS: Integrate ESP protocol into ip_vs_proto_ah.c
      IPVS: Rename ip_vs_proto_ah.c to ip_vs_proto_ah_esp.c
      IPVS: Add CONFIG_IP_VS_IPV6 option for IPv6 support
      IPVS: Change IPVS data structures to support IPv6 addresses
      IPVS: Add general v4/v6 helper functions / data structures
      IPVS: Add debug macros for v4 and v6 address output
      IPVS: Add internal versions of sockopt interface structs
      IPVS: Convert __ip_vs_svc_get() and __ip_vs_fwm_get()
      IPVS: Add v6 support to ip_vs_service_get()
      IPVS: Add IPv6 support flag to schedulers
      IPVS: Add 'af' args to protocol handler functions
      IPVS: Add protocol debug functions for IPv6
      IPVS: Extend protocol DNAT/SNAT and state handlers
      IPVS: Extend functions for getting/creating connections
      IPVS: Add IPv6 support to xmit() support functions
      IPVS: Add and bind IPv6 xmit functions
      IPVS: Extend scheduling functions for IPv6 support
      IPVS: Add/adjust Netfilter hook functions and helpers for v6
      IPVS: Convert real server lookup functions
      IVPS: Disable sync daemon for IPv6 connections
      IPVS: Turn off FTP application helper for IPv6
      IPVS: Adjust various debug outputs to use new macros
      IPVS: Activate IPv6 Netfilter hooks
      IPVS: Allow adding IPv6 services from userspace
      IPVS: Remove incorrect ip_route_me_harder(), fix IPv6
      IPVS: Move IPVS to net/netfilter/ipvs

KOVACS Krisztian (14):
      ipv4: Implement IP_TRANSPARENT socket option
      ipv4: Make inet_sock.h independent of route.h
      ipv4: Conditionally enable transparent flow flag when connecting
      tcp: Handle TCP SYN+ACK/ACK/RST transparency
      ipv4: Make Netfilter's ip_route_me_harder() non-local address com=
patible
      tcp: Port redirection support for TCP
      udp: Export UDP socket lookup function
      inet: Add udplib_lookup_skb() helpers
      inet: Don't lookup the socket if there's a socket attached to the=
 skb
      netfilter: split netfilter IPv4 defragmentation into a separate m=
odule
      netfilter: iptables tproxy core
      netfilter: iptables socket match
      netfilter: iptables TPROXY target
      netfilter: Add documentation for tproxy

Kaihui Luo (1):
      netfilter: xt_time gives a wrong monthday in a leap year

Kevin Hao (2):
      net: add net poll support for atl2 driver
      net: remove LLTX in atl2 driver

Kevin Lo (3):
      via-rhine: changed to use netdev_alloc_skb() from dev_alloc_skb
      8139cp: use netdev_alloc_skb
      8139too: use netdev_alloc_skb

Krzysztof Halasa (1):
      wan/hdlc_x25.c: fix a NULL dereference

Kumar Gala (2):
      netdev: drop CONFIG_PPC_MERGE from Kconfig
      fs-enet: remove code associated with !CONFIG_PPC_MERGE

Larry Finger (8):
      ssb: Update for Rev. 5 SPROM
      ssb: Clean up extraction of MAC addresses from SPROM
      b43legacy: Fix failure in rate-adjustment mechanism
      b43: Issue warning when RFKILL_INPUT is not enabled
      b43: Fix Bluetooth coexistence SPROM coding error for Motorola 70=
10 variant of BCM4306
      p54: Fix sparse warnings
      b43: Fix Bluetooth Coexistence SPROM programming error for HP 12f=
8 version of BCM4306
      b43: Increase loop tries in do_dummy_tx

Lennert Buytenhek (42):
      mv643xx_eth: fix 'netdev_priv(dev) =3D=3D dev->priv' assumption
      mv643xx_eth: fix receive buffer DMA unmapping
      mv643xx_eth: get rid of IRQF_SAMPLE_RANDOM
      mv643xx_eth: get rid of modulo operations
      mv643xx_eth: switch ->phy_lock from a spinlock to a mutex
      mv643xx_eth: use the SMI done interrupt to wait for SMI access co=
mpletion
      mv643xx_eth: make napi unconditional
      mv643xx_eth: get rid of receive-side locking
      mv643xx_eth: get rid of compile-time configurable transmit checks=
umming
      mv643xx_eth: require contiguous receive and transmit queue number=
ing
      mv643xx_eth: smi sharing is a per-unit property, not a per-port o=
ne
      mv643xx_eth: remove force_phy_addr field
      mv643xx_eth: get rid of netif_{stop,wake}_queue() calls on link d=
own/up
      mv643xx_eth: delete unused and uninteresting interrupt source mas=
k bits
      mv643xx_eth: transmit multiqueue support
      mv643xx_eth: move all work to the napi poll handler
      mv643xx_eth: switch to netif tx queue lock, get rid of private sp=
inlock
      mv643xx_eth: avoid dropping tx lock during transmit reclaim
      mv643xx_eth: replace array of skbs awaiting transmit completion w=
ith a queue
      mv643xx_eth: shrink default receive and transmit queue sizes
      mv643xx_eth: avoid reading ->byte_cnt twice during receive proces=
sing
      mv643xx_eth: add support for chips without transmit bandwidth con=
trol
      mv643xx_eth: fix receive checksumming
      mv643xx_eth: deal with unexpected ethernet header sizes
      mv643xx_eth: enforce frequent hardware statistics polling
      phylib: allow incremental scanning of an mii bus
      mv643xx_eth: convert to phylib
      mv643xx_eth: bump version to 1.4
      net: add skb_recycle_check() to enable netdriver skb recycling
      mv643xx_eth: hook up skb recycling
      phylib: phy_mii_ioctl() fixes
      phylib: rename mii_bus::dev to mii_bus::parent
      phylib: move to dynamic allocation of struct mii_bus
      phylib: give mdio buses a device tree presence
      phylib: add mdiobus_{read,write}
      mv643xx_eth: include linux/ip.h to fix build
      net: Distributed Switch Architecture protocol support
      dsa: add support for original DSA tagging format
      dsa: add support for the Marvell 88E6131 switch chip
      dsa: add support for Trailer tagging format
      dsa: add support for the Marvell 88E6060 switch chip
      phylib: two dynamic mii_bus allocation fallout fixes

Linus Torvalds (1):
      wireless: restore revert lost to merge damage

Lorenzo Nava (1):
      b43: fix QoS parameters initialization

Luis Carlos Cobo (6):
      mac80211: allow no mac address until firmware load
      libertas_tf: header file
      libertas_tf: main.c, data paths and mac80211 handlers
      libertas_tf: command helper functions for libertas_tf
      libertas_tf: usb specific functions
      libertas_tf: config and makefile

Luis R. Rodriguez (9):
      cfg80211: keep track of supported interface modes
      cfg80211: Add new wireless regulatory infrastructure
      zd1211rw: make use of new regulatory_hint()
      ath9k: Add a few comments about mibevents
      ath9k: kill ath9k's memzero() and use memset() instead
      ath9k: fix oops on trying to hold the wrong spinlock
      ath9k: enable ANI to help with noisy environments
      ath9k: remove nasty FAIL macro from ath9k_hw_reset()
      ath9k: Fix return code when ath9k_hw_setpower() fails on reset

Magnus Damm (3):
      smc91x: fix nowait printout
      smc91x: SMC_IO_SHIFT platform data support for default case
      smc911x: remove duplicate debug printout

Malcolm Turnbull (1):
      ipvs: load balance IPv4 connections from a local process

Martin Gebert (1):
      [netdrvr] au1000_eth: Spinlock initialisation fix

Mats Erik Andersson (1):
      8139too: [cosmetic] fix incorrect register for flash-rom

Matthew Wilcox (1):
      [netdrvr] atl1e: Don't take the mdio_lock in atl1e_probe

Mattias Nissler (2):
      rt2x00: Only configure hardware when radio is enabled
      rt2x00: skb->data pointer should not include TX descriptor

Michael Buesch (14):
      b43: Implement dynamic PHY API
      b43: Rewrite TX power adjustment
      b43: Don't use memcpy for overlapping areas
      b43: Move remaining code from phy.c to phy_a.c
      b43: Move code from nphy.* to phy_n.*
      b43: Add LP-PHY template
      b43: Add LP-PHY read/write phyops
      b43: Add LP-PHY radio register definitions
      b43: Split PHY alloc and init
      b43: Move Analog switching into phy code
      b43: Replace hardcoded Analog switch
      b43: Fix QoS defaults
      b43 G-PHY: Remove mmiowb()
      b43: Remove QoS update workqueue

Michael Chan (5):
      bnx2: Add bnx2_shutdown_chip().
      bnx2: Check netif_running() in all ethtool operations.
      bnx2: Update 5706/5708 firmware.
      bnx2: Eliminate TSO header modifications.
      bnx2: Update version to 1.8.1.

Ming Lei (1):
      hci_usb: replace mb with smp_mb

Neil Horman (1):
      sctp: reduce memory footprint of sctp_chunk structure

Nick Kossifidis (7):
      ath5k: HW code cleanup
      ath5k: Fix bad udelay calls on AR5210 code
      ath5k: Update registers and SREV ids v2
      ath5k: Use new srevs to properly attach radio chips
      ath5k: Use QUIET mechanism on tx dma stop
      ath5k: Fix SREV reporting after SREV updates
      ath5k: Add support for AR2417 v2

Oliver Hartkopp (2):
      can: Add documentation for virtual CAN driver usage
      net: remove ifalias on empty given alias

PJ Waskiewicz (1):
      ixgbe: use different context for tso and offload

Patrick McHardy (2):
      gre: fix copy and paste error
      gre: minor cleanups in netlink interface

Peter P Waskiewicz (1):
      ixgbe: Whitespace, copyright update and version number change pat=
ch

Peter Zijlstra (4):
      ipv6: clean up ip6_route_net_init() error handling
      ipv6: initialize ip6_route sysctl vars in ip6_route_net_init()
      net: wrap sk->sk_backlog_rcv()
      net: packet split receive api

Rami Rosen (3):
      mac80211: remove wme_tx_queue and wme_rx_queue from net/mac80211/=
sta_info.h
      mac80211: remove redundant check in ieee80211_master_start_xmit (=
net/mac80211/tx.c)
      ipv4: add mc_count to in_device.

Randy Dunlap (3):
      hp-plus: fix link objects
      ath9k: uses/needs led_classdev_[un]register
      mac80211: add missing kernel-doc

Remi Denis-Courmont (12):
      Phonet: global definitions
      Phonet: PF_PHONET protocol family support
      Phonet: add CONFIG_PHONET
      Phonet: network device and address handling
      Phonet: Netlink interface
      Phonet: common socket glue
      Phonet: Phonet datagram transport protocol
      Phonet: provide MAC header operations
      Phonet: proc interface for port range
      Phonet: emit errors when a packet cannot be delivered locally
      Phonet: kernel documentation
      phonet: Protect if_phonet.h against multiple inclusions.

Robert P. J. Day (1):
      WIRELESS: Make wireless one-click selectable.

Ron Mercer (1):
      qlge: New Qlogic 10Gb Ethernet Driver.

Ron Rindjunsky (5):
      mac80211: change number of pre-assoc scans
      mac80211: add direct probe before association
      iwlwifi: remove obsolete 4965 forward declarations
      iwlwifi: allow consecutive scans in unassociated state
      iwlwifi: rename ps_mode to sm_ps

R=E9mi Denis-Courmont (10):
      ISDN sockets: add missing lockdep strings
      Phonet: Netlink factorization and cleanup
      Phonet: improve documentation
      Phonet: declare headers
      Phonet: modules auto-loading support
      Phonet: connected sockets glue
      Phonet: Pipe End Point for Phonet Pipes protocol
      Phonet: receive pipe control requests as out-of-band data
      Phonet: implement GPRS virtual interface over PEP socket
      Phonet: pipe end-point protocol documentation

Scott Feldman (5):
      enic: add Cisco 10G Ethernet NIC driver
      enic: Don't indicate IPv6 pkts using soft-LRO
      enic: fixes for review items from Ben Hutchings
      enic: Bug fix: Free MSI intr with correct data handle
      enic: bug fix: don't set netdev->name too early

Sebastien Dugue (2):
      ehea: fix phyp debugging typo
      ehea: fix mutex and spinlock use

Simon Horman (16):
      ipvs: rename __ip_vs_wlc_schedule in lblc and lblcr schedulers
      Merge branch 'master' of git://git.kernel.org/.../davem/net-2.6
      Merge branch 'master' of git://git.kernel.org/.../davem/net-2.6
      Merge branch 'master' of git://git.kernel.org/.../horms/lvs-2.6 i=
nto lvs-next-2.6
      Merge branch 'master' of git://git.kernel.org/.../davem/net-2.6
      Merge branch 'master' of git://git.kernel.org/.../davem/net-2.6
      ipvs: load balance ipv6 connections from a local process
      IPVS: fix bogus indentation
      IPVS: use ipv6_addr_copy()
      ipvs: handle PARTIAL_CHECKSUM
      Merge git://git.kernel.org/.../davem/net-next-2.6 into lvs-next-2=
=2E6
      Merge git://git.kernel.org/.../horms/lvs-2.6 into lvs-next-2.6
      ipvs: only unlock in ip_vs_edit_service() if already locked
      ipvs: supply a valid 0 address to ip_vs_conn_new()
      ipvs: add __aquire/__release annotations to ip_vs_info_seq_start/=
ip_vs_info_seq_stop
      Merge git://git.kernel.org/.../davem/net-next-2.6 into lvs-next-2=
=2E6

Stefanik G=E1bor (1):
      iwlwifi: enable packet injection for iwlagn

Stephen Hemminger (6):
      sky2: EEPROM read/write bug fixes
      sky2: display product info on boot.
      net: network device name ifalias support
      bonding: add more ethtool support
      netdev: use const for some name functions
      netdev: docbook comment update (revised)

Stephen Rothwell (1):
      net: ip_vs_proto_{tcp,udp} build fix

Steve Glendinning (2):
      net: Add SMSC LAN9500 USB2.0 10/100 ethernet adapter driver
      smsc95xx: fix usb usage on big endian platforms

Steve Hodgson (4):
      sfc: Remove unused field efx_channel::reset_work
      sfc: Do not call netif_{stop,wake}_queue() before register_netdev
      sfc: Don't use EFX_OWORD_FIELD on an event (64-bit, quad-word)
      sfc: Don't include net_driver.h from falcon_io.h

Sujith (23):
      ath9k: Merge reset functions
      ath9k: RX Filter cleanup
      ath9k: Use bitfields for buffer type
      ath9k: Remove a few unnecessary macros
      ath9k: Remove ar5416hal and assign default values directly
      ath9k: Unused macros, variables
      ath9k: Use a single opmode variable
      ath9k: Use bitfields for sc operations
      ath9k: Use ah_curchan and remove sc_curchan which is redundant
      ath9k: Trim struct ath_softc
      ath9k: Remove remaining occurences of ath_skb_map functions
      ath9k: Random cleanup
      ath9k: Miscellaneous fixes
      mac80211: Add an 802.11n definition
      ath9k: Use definition from ieee80211.h
      ath9k: Add IEEE80211_HW_RX_INCLUDES_FCS to hw flags
      ath9k: Remove more dead code
      ath9k: Do not update frame's duration field
      ath9k: Remove sc_lastrx as we don't use it anywhere
      ath9k: rc.h cleanup
      ath9k: Whitespace cleanup
      ath9k: Fix nexttbtt calculation
      ath9k: Fix TSF Adjust usage

Sven Wegener (13):
      ipvs: Only call init_service, update_service and done_service for=
 schedulers if defined
      ipvs: Create init functions for estimator code
      ipvs: Fix race conditions in lblc scheduler
      ipvs: Fix race conditions in lblcr scheduler
      ipvs: Use pointer to address from sync message
      ipvs: Return negative error values from ip_vs_edit_service()
      ipvs: Mark tcp/udp v4 and v6 debug functions static
      ipvs: Reject ipv6 link-local addresses for destinations
      ipvs: Restrict connection table size via Kconfig
      ipvs: Embed user stats structure into kernel stats structure
      ipvs: Restrict sync message to 255 connections
      ipvs: Fix unused label warning
      ipvs: Remove stray file left over from ipvs move

Takashi Iwai (1):
      drivers/net/skfp/pmf.c: Use offsetof() macro

Thomas Bogendoerfer (1):
      tulip: Fix dead 21041 ethernet after ifconfig down

Thomas Graf (1):
      netlink: Remove compat API for nested attributes

Tobias Brunner (1):
      af_key: fix SADB_X_SPDDELETE response

Tom Quetchenbach (1):
      tcp: advertise MSS requested by user

Tomas Winkler (28):
      mac80211: add ieee80211_queue_stopped)
      iwlwifi: kill struct iwl4965_lq_mngr
      mac80211: filter probes in ieee80211_rx_mgmt_probe_resp
      mac80211: cleanup mlme state namespace
      mac80211: Fix low bit rate in IBSS
      iwlwifi: clean up hw scan handler
      iwlwifi: align set channel with mac80211
      iwlwifi: use strict_strtoul instead of simple_strtoul
      iwlwifi: replace readl and writel with io/read/write/32
      iwlwifi: remove rfkill warning from iwl-io
      iwlwifi: generic init calibrations framework
      iwlwifi: cleanup PCI register handling
      iwlwifi: fix host command header according the HW spec
      iwlwifi: remove bad language from the comments
      mac80211: change MIMO_PS to SM_PS
      mac80211: restructure disassoc/deauth flows
      mac80211: disassociate when moving to new BSS
      mac80211: remove disassociation code from ieee80211_set_associate=
d
      mac80211: stop queues before carrier off
      iwlwifi: update 5350 Wifi PCI IDs
      iwlwifi: add MODULE_FIRMWARE for 5000 HW
      iwlwifi: don't delay scan in IBSS mode
      iwlwifi: make PS use named constants
      iwlwifi: don't fail if scan is issued too early
      mac80211: remove shadowed variables in ieee80211_master_start_xmi=
t
      iwlwifi: scan correct setting of valid rx_chains
      iwlwifi: scan fix comment
      iwlwifi: remove STATUS_CONF_PENDING in scanning

Tomasz Grobelny (2):
      dccp: Policy-based packet dequeueing infrastructure
      dccp qpolicy: Parameter checking of cmsg qpolicy parameters

Trent Piepho (4):
      gianfar: Fix error in mdio reset timeout
      PHY: Avoid unnecessary aneg restarts
      phylib: Wake PHY state machine on interrupt
      gianfar: Create net device with carrier down

T=F3th L=E1szl=F3 Attila (1):
      ipv4: Allow binding to non-local addresses if IP_TRANSPARENT is s=
et

Ursula Braun (2):
      qeth: use firmware MAC-address for layer2 hsi-devices
      qeth: avoid qeth recovery problems

Vasanthakumar Thiagarajan (3):
      ath9k: Add LED support
      ath9k: Re-order functions in main.c
      ath9k: Add RF kill support

Vegard Nossum (1):
      tcp_ipv6: fix use of uninitialized memory

Victor Gallardo (1):
      ibm_newemac: Fix EMAC soft reset on 460EX/GT

Vince Busam (2):
      IPVS: Convert procfs files for IPv6 entry output
      IPVS: Add function to determine if IPv6 address is local

Vlad Yasevich (11):
      bonding: Do not tx-balance some IPv6 packets on ALB/TLB bonds
      sctp: Only mark chunks as missing when there are gaps
      sctp: Optimize SFR-CACC transport list walking during SACK proces=
sing
      sctp: Retransmit list is ineligable for missing indications
      sctp: try harder to figure out address family when checking wildc=
ards
      sctp: enable cookie-echo retransmission transport switch
      sctp: correctly save sctp_adaptation from parameter.
      sctp: Rework the tsn map to use generic bitmap.
      sctp: shrink sctp_tsnmap some more by removing gabs array
      sctp: Fix SNMP number of SCTP_MIB_ABORTED during violation handli=
ng.
      sctp: update SNMP statiscts when T5 timer expired.

Wang Chen (1):
      skge: Fix skge_set_ring_param() losing error return

Wei Yongjun (5):
      dccp: Always generate a Reset in response to option errors
      dccp: Always generate a Reset in response to option errors
      sctp: Fix to start T5-shutdown-guard timer while enter SHUTDOWN-S=
ENT state
      sctp: Fix the SNMP counter of SCTP_MIB_OUTOFBLUES
      sctp: Fix the SNMP number of SCTP_MIB_CURRESTAB

Weiwei Wang (1):
      [netdrvr] convert sbmac tx to spin_lock_irqsave to prevent early =
IRQ enable

Winkler, Tomas (2):
      iwlwifi: refactor rx register initialization
      iwlwifi: use correct DMA_MASK

Xiaoming.Zhang (1):
      [10/21] driver/net/skge.c: restart the interface when it's option=
s or

YanBo (1):
      mac80211: mesh portal functionality support

Yitchak Gertner (1):
      bnx2x: EEH recovery fix

Yoichi Yuasa (1):
      cs89x0: fix warning release_irq label

Zhu Yi (2):
      iwlwifi: fix compile warning
      iwl3945: add MODULE_FIRMWARE for 3945 HW

akeemting (1):
      jme: Faulty IRQ handle bug fix

philipl@overt.org (1):
      toshiba_acpi: Add support for bluetooth toggling through rfkill (=
v8)

roel kluin (2):
      iwl-4965: test below 0 on unsigned num_tbs
      ibm_newemac: MAL[12]_IER_EVENTS definition: 2x *_OTE -> *_DE

 Documentation/DocBook/mac80211.tmpl                |   12 +-
 Documentation/feature-removal-schedule.txt         |   21 +
 Documentation/networking/LICENSE.qlge              |   46 +
 Documentation/networking/can.txt                   |   44 +-
 Documentation/networking/multiqueue.txt            |   54 +-
 Documentation/networking/phonet.txt                |  175 +
 Documentation/networking/regulatory.txt            |  194 +
 Documentation/networking/tproxy.txt                |   85 +
 Documentation/rfkill.txt                           |   32 +-
 MAINTAINERS                                        |   26 +
 arch/arm/mach-kirkwood/db88f6281-bp-setup.c        |    2 +-
 arch/arm/mach-kirkwood/rd88f6192-nas-setup.c       |    2 +-
 arch/arm/mach-kirkwood/rd88f6281-setup.c           |    2 +-
 arch/arm/mach-loki/lb88rc8480-setup.c              |    2 +-
 arch/arm/mach-mv78xx0/common.c                     |    6 +-
 arch/arm/mach-mv78xx0/db78x00-bp-setup.c           |    8 +-
 arch/arm/mach-orion5x/db88f5281-setup.c            |    2 +-
 arch/arm/mach-orion5x/dns323-setup.c               |    2 +-
 arch/arm/mach-orion5x/kurobox_pro-setup.c          |    2 +-
 arch/arm/mach-orion5x/mss2-setup.c                 |    2 +-
 arch/arm/mach-orion5x/mv2120-setup.c               |    2 +-
 arch/arm/mach-orion5x/rd88f5181l-fxo-setup.c       |    2 +-
 arch/arm/mach-orion5x/rd88f5181l-ge-setup.c        |    2 +-
 arch/arm/mach-orion5x/rd88f5182-setup.c            |    2 +-
 arch/arm/mach-orion5x/ts78xx-setup.c               |    3 +-
 arch/arm/mach-orion5x/tsx09-common.c               |    2 +-
 arch/arm/mach-orion5x/wnr854t-setup.c              |    2 +-
 arch/arm/mach-orion5x/wrt350n-v2-setup.c           |    2 +-
 arch/powerpc/include/asm/dcr-regs.h                |    4 +
 arch/powerpc/platforms/82xx/ep8248e.c              |    2 +-
 arch/powerpc/platforms/pasemi/gpio_mdio.c          |    6 +-
 arch/powerpc/sysdev/mv64x60_dev.c                  |    6 +-
 drivers/acpi/Kconfig                               |    3 +
 drivers/acpi/toshiba_acpi.c                        |  261 +-
 drivers/atm/eni.c                                  |    2 +-
 drivers/atm/horizon.c                              |    8 +-
 drivers/atm/idt77252.c                             |   32 +-
 drivers/atm/idt77252.h                             |    4 +-
 drivers/atm/zatm.c                                 |    6 +-
 drivers/block/aoe/aoe.h                            |    9 +-
 drivers/block/aoe/aoeblk.c                         |    8 +-
 drivers/block/aoe/aoechr.c                         |    8 +-
 drivers/block/aoe/aoecmd.c                         |   85 +-
 drivers/block/aoe/aoedev.c                         |   12 +-
 drivers/block/aoe/aoemain.c                        |    1 +
 drivers/block/aoe/aoenet.c                         |    9 +-
 drivers/bluetooth/hci_bcsp.c                       |   18 +-
 drivers/bluetooth/hci_usb.h                        |   10 +-
 drivers/isdn/capi/kcapi.c                          |    4 +
 drivers/isdn/hardware/mISDN/hfc_pci.h              |    4 +-
 drivers/isdn/hardware/mISDN/hfcpci.c               |   23 +-
 drivers/isdn/i4l/isdn_ppp.c                        |  352 +-
 drivers/isdn/mISDN/timerdev.c                      |   22 +-
 drivers/net/3c505.c                                |    4 +-
 drivers/net/8139cp.c                               |   14 +-
 drivers/net/8139too.c                              |   14 +-
 drivers/net/Kconfig                                |   62 +-
 drivers/net/Makefile                               |    6 +-
 drivers/net/arcnet/arcnet.c                        |   18 +-
 drivers/net/arcnet/com20020.c                      |   16 +-
 drivers/net/atl1e/atl1e_hw.c                       |    6 +-
 drivers/net/atl1e/atl1e_main.c                     |    2 -
 drivers/net/atlx/Makefile                          |    2 +
 drivers/net/atlx/atl1.c                            |   32 +-
 drivers/net/atlx/atl2.c                            | 3119 +++++++
 drivers/net/atlx/atl2.h                            |  529 ++
 drivers/net/atlx/atlx.c                            |    1 -
 drivers/net/au1000_eth.c                           |   46 +-
 drivers/net/au1000_eth.h                           |    2 +-
 drivers/net/ax88796.c                              |   14 +-
 drivers/net/bfin_mac.c                             |   39 +-
 drivers/net/bfin_mac.h                             |    2 +-
 drivers/net/bnx2.c                                 |  229 +-
 drivers/net/bnx2.h                                 |   13 +-
 drivers/net/bnx2_fw.h                              | 8654 ++++++++++--=
--------
 drivers/net/bnx2x_main.c                           |   95 +-
 drivers/net/bonding/bond_alb.c                     |   28 +-
 drivers/net/bonding/bond_main.c                    |   12 +-
 drivers/net/bonding/bonding.h                      |   10 +-
 drivers/net/cassini.c                              |   56 +-
 drivers/net/cassini.h                              | 1522 +----
 drivers/net/cpmac.c                                |   51 +-
 drivers/net/cs89x0.c                               |    2 -
 drivers/net/cxgb3/adapter.h                        |    7 +-
 drivers/net/cxgb3/ael1002.c                        | 1072 +++-
 drivers/net/cxgb3/common.h                         |   85 +-
 drivers/net/cxgb3/cxgb3_ioctl.h                    |    2 +
 drivers/net/cxgb3/cxgb3_main.c                     |  388 +-
 drivers/net/cxgb3/cxgb3_offload.c                  |    8 +-
 drivers/net/cxgb3/l2t.c                            |   39 +-
 drivers/net/cxgb3/l2t.h                            |    3 +-
 drivers/net/cxgb3/regs.h                           |    4 +
 drivers/net/cxgb3/sge.c                            |  110 +-
 drivers/net/cxgb3/t3_hw.c                          |  241 +-
 drivers/net/cxgb3/vsc8211.c                        |  206 +-
 drivers/net/e100.c                                 |    2 +-
 drivers/net/e1000/e1000.h                          |   17 -
 drivers/net/e1000/e1000_main.c                     |  471 +-
 drivers/net/e1000e/82571.c                         |  153 +-
 drivers/net/e1000e/defines.h                       |   15 +
 drivers/net/e1000e/e1000.h                         |   31 +-
 drivers/net/e1000e/es2lan.c                        |    2 +-
 drivers/net/e1000e/ethtool.c                       |   60 +-
 drivers/net/e1000e/hw.h                            |   15 +-
 drivers/net/e1000e/ich8lan.c                       |  175 +-
 drivers/net/e1000e/lib.c                           |    8 +-
 drivers/net/e1000e/netdev.c                        |  499 +-
 drivers/net/e1000e/param.c                         |   27 +
 drivers/net/e1000e/phy.c                           |  194 +-
 drivers/net/ehea/ehea.h                            |    4 +-
 drivers/net/ehea/ehea_phyp.c                       |    2 +-
 drivers/net/ehea/ehea_qmr.c                        |    3 +-
 drivers/net/enc28j60.c                             |   56 +-
 drivers/net/enic/Makefile                          |    5 +
 drivers/net/enic/cq_desc.h                         |   79 +
 drivers/net/enic/cq_enet_desc.h                    |  169 +
 drivers/net/enic/enic.h                            |  114 +
 drivers/net/enic/enic_main.c                       | 1934 +++++
 drivers/net/enic/enic_res.c                        |  370 +
 drivers/net/enic/enic_res.h                        |  151 +
 drivers/net/enic/rq_enet_desc.h                    |   60 +
 drivers/net/enic/vnic_cq.c                         |   89 +
 drivers/net/enic/vnic_cq.h                         |  113 +
 drivers/net/enic/vnic_dev.c                        |  674 ++
 drivers/net/enic/vnic_dev.h                        |  120 +
 drivers/net/enic/vnic_devcmd.h                     |  282 +
 drivers/net/enic/vnic_enet.h                       |   47 +
 drivers/net/enic/vnic_intr.c                       |   62 +
 drivers/net/enic/vnic_intr.h                       |   92 +
 drivers/net/enic/vnic_nic.h                        |   65 +
 drivers/net/enic/vnic_resource.h                   |   63 +
 drivers/net/enic/vnic_rq.c                         |  199 +
 drivers/net/enic/vnic_rq.h                         |  204 +
 drivers/net/enic/vnic_rss.h                        |   32 +
 drivers/net/enic/vnic_stats.h                      |   70 +
 drivers/net/enic/vnic_wq.c                         |  184 +
 drivers/net/enic/vnic_wq.h                         |  154 +
 drivers/net/enic/wq_enet_desc.h                    |   98 +
 drivers/net/fealnx.c                               |    6 +-
 drivers/net/fec_mpc52xx_phy.c                      |    8 +-
 drivers/net/forcedeth.c                            |    2 +-
 drivers/net/fs_enet/fs_enet-main.c                 |   22 +-
 drivers/net/fs_enet/fs_enet.h                      |    2 -
 drivers/net/fs_enet/mac-fcc.c                      |   12 -
 drivers/net/fs_enet/mac-fec.c                      |   30 -
 drivers/net/fs_enet/mac-scc.c                      |   26 -
 drivers/net/fs_enet/mii-bitbang.c                  |    9 +-
 drivers/net/fs_enet/mii-fec.c                      |    8 +-
 drivers/net/gianfar.c                              |    3 +
 drivers/net/gianfar_mii.c                          |   27 +-
 drivers/net/ibm_newemac/Kconfig                    |    2 +-
 drivers/net/ibm_newemac/core.c                     |   18 +
 drivers/net/ibm_newemac/core.h                     |    5 +
 drivers/net/ibm_newemac/mal.h                      |    4 +-
 drivers/net/ibm_newemac/phy.c                      |    2 +-
 drivers/net/igb/igb_main.c                         |   12 +-
 drivers/net/irda/vlsi_ir.c                         |    2 +-
 drivers/net/ixgb/ixgb.h                            |    2 +-
 drivers/net/ixgb/ixgb_main.c                       |    8 +-
 drivers/net/ixgbe/ixgbe.h                          |  103 +-
 drivers/net/ixgbe/ixgbe_82598.c                    |  628 ++-
 drivers/net/ixgbe/ixgbe_common.c                   | 1060 ++-
 drivers/net/ixgbe/ixgbe_common.h                   |   58 +-
 drivers/net/ixgbe/ixgbe_ethtool.c                  |  302 +-
 drivers/net/ixgbe/ixgbe_main.c                     | 1938 +++--
 drivers/net/ixgbe/ixgbe_phy.c                      |  244 +-
 drivers/net/ixgbe/ixgbe_phy.h                      |   63 +-
 drivers/net/ixgbe/ixgbe_type.h                     |  563 +-
 drivers/net/jme.c                                  | 3038 +++++++
 drivers/net/jme.h                                  | 1229 +++
 drivers/net/lib8390.c                              |    4 +-
 drivers/net/macb.c                                 |   49 +-
 drivers/net/macb.h                                 |    2 +-
 drivers/net/meth.c                                 |    2 +-
 drivers/net/mipsnet.c                              |    2 +-
 drivers/net/mlx4/alloc.c                           |    1 +
 drivers/net/mv643xx_eth.c                          | 1471 ++--
 drivers/net/myri10ge/myri10ge.c                    |  185 +-
 drivers/net/myri_sbus.c                            |    2 +-
 drivers/net/natsemi.c                              |    8 +-
 drivers/net/ne.c                                   |  281 +-
 drivers/net/netx-eth.c                             |    2 +-
 drivers/net/netxen/netxen_nic.h                    |    2 +-
 drivers/net/netxen/netxen_nic_main.c               |   20 +-
 drivers/net/pci-skeleton.c                         |    4 +-
 drivers/net/pcmcia/xirc2ps_cs.c                    |    6 +-
 drivers/net/phy/fixed.c                            |   33 +-
 drivers/net/phy/mdio-bitbang.c                     |    4 +-
 drivers/net/phy/mdio-ofgpio.c                      |   11 +-
 drivers/net/phy/mdio_bus.c                         |  231 +-
 drivers/net/phy/phy.c                              |   60 +-
 drivers/net/phy/phy_device.c                       |   49 +-
 drivers/net/ppp_generic.c                          |   13 +-
 drivers/net/pppol2tp.c                             |    2 +-
 drivers/net/qlge/Makefile                          |    7 +
 drivers/net/qlge/qlge.h                            | 1593 ++++
 drivers/net/qlge/qlge_dbg.c                        |  858 ++
 drivers/net/qlge/qlge_ethtool.c                    |  415 +
 drivers/net/qlge/qlge_main.c                       | 3956 +++++++++
 drivers/net/qlge/qlge_mpi.c                        |  150 +
 drivers/net/r6040.c                                |    6 +-
 drivers/net/r8169.c                                |  963 ++-
 drivers/net/s2io.c                                 |   62 +-
 drivers/net/s2io.h                                 |    1 +
 drivers/net/sb1250-mac.c                           |   48 +-
 drivers/net/sfc/bitfield.h                         |  178 +-
 drivers/net/sfc/boards.c                           |   12 +-
 drivers/net/sfc/boards.h                           |    2 -
 drivers/net/sfc/efx.c                              |  489 +-
 drivers/net/sfc/efx.h                              |   14 +-
 drivers/net/sfc/enum.h                             |    9 +-
 drivers/net/sfc/ethtool.c                          |  184 +-
 drivers/net/sfc/falcon.c                           | 1019 ++-
 drivers/net/sfc/falcon.h                           |   17 +-
 drivers/net/sfc/falcon_hwdefs.h                    |   80 +-
 drivers/net/sfc/falcon_io.h                        |    1 -
 drivers/net/sfc/falcon_xmac.c                      |  346 +-
 drivers/net/sfc/mac.h                              |    4 -
 drivers/net/sfc/mdio_10g.c                         |   16 +-
 drivers/net/sfc/mdio_10g.h                         |   13 +-
 drivers/net/sfc/net_driver.h                       |  144 +-
 drivers/net/sfc/phy.h                              |   10 +-
 drivers/net/sfc/rx.c                               |   78 +-
 drivers/net/sfc/rx.h                               |    4 +-
 drivers/net/sfc/selftest.c                         |  391 +-
 drivers/net/sfc/selftest.h                         |   13 +-
 drivers/net/sfc/sfe4001.c                          |  248 +-
 drivers/net/sfc/spi.h                              |   89 +-
 drivers/net/sfc/tenxpress.c                        |  149 +-
 drivers/net/sfc/tx.c                               |  385 +-
 drivers/net/sfc/tx.h                               |    2 +-
 drivers/net/sfc/workarounds.h                      |    4 -
 drivers/net/sfc/xfp_phy.c                          |   12 +-
 drivers/net/sh_eth.c                               |    4 +-
 drivers/net/skfp/pmf.c                             |   29 +-
 drivers/net/skge.c                                 |   26 +-
 drivers/net/sky2.c                                 |  170 +-
 drivers/net/smc911x.c                              |   68 +-
 drivers/net/smc91x.c                               |   43 +-
 drivers/net/smc91x.h                               |    2 +
 drivers/net/sunbmac.c                              |    2 +-
 drivers/net/sundance.c                             |   95 +-
 drivers/net/tc35815.c                              |   45 +-
 drivers/net/tehuti.h                               |    8 +-
 drivers/net/tg3.c                                  |  157 +-
 drivers/net/tg3.h                                  |    3 +-
 drivers/net/tsi108_eth.c                           |    6 +-
 drivers/net/tulip/de2104x.c                        |    1 -
 drivers/net/tulip/de4x5.c                          |   38 +-
 drivers/net/ucc_geth.c                             |  116 +-
 drivers/net/ucc_geth_mii.c                         |    9 +-
 drivers/net/usb/Kconfig                            |    8 +
 drivers/net/usb/Makefile                           |    4 +-
 drivers/net/usb/hso.c                              |  335 +-
 drivers/net/usb/mcs7830.c                          |    2 +-
 drivers/net/usb/pegasus.c                          |   20 +-
 drivers/net/usb/smsc95xx.c                         | 1225 +++
 drivers/net/usb/smsc95xx.h                         |  253 +
 drivers/net/usb/usbnet.c                           |    3 +-
 drivers/net/via-rhine.c                            |    8 +-
 drivers/net/via-velocity.c                         |    4 +-
 drivers/net/via-velocity.h                         |    2 +-
 drivers/net/wan/cycx_drv.c                         |    6 +-
 drivers/net/wan/cycx_x25.c                         |   12 +-
 drivers/net/wan/dscc4.c                            |    2 +-
 drivers/net/wan/hdlc_x25.c                         |    8 +-
 drivers/net/wan/pc300_tty.c                        |    2 +-
 drivers/net/wan/sbni.c                             |    2 +-
 drivers/net/wireless/Kconfig                       |   17 +-
 drivers/net/wireless/Makefile                      |    4 +-
 drivers/net/wireless/adm8211.c                     |   23 +-
 drivers/net/wireless/airo.c                        |   18 +-
 drivers/net/wireless/airo_cs.c                     |    2 +-
 drivers/net/wireless/airport.c                     |    3 +-
 drivers/net/wireless/ath5k/Makefile                |   12 +-
 drivers/net/wireless/ath5k/ath5k.h                 |  619 +-
 drivers/net/wireless/ath5k/attach.c                |  359 +
 drivers/net/wireless/ath5k/base.c                  |  574 +-
 drivers/net/wireless/ath5k/base.h                  |   10 +-
 drivers/net/wireless/ath5k/caps.c                  |  193 +
 drivers/net/wireless/ath5k/debug.c                 |    4 +-
 drivers/net/wireless/ath5k/desc.c                  |  692 ++
 drivers/net/wireless/ath5k/desc.h                  |  332 +
 drivers/net/wireless/ath5k/dma.c                   |  605 ++
 drivers/net/wireless/ath5k/eeprom.c                |  466 ++
 drivers/net/wireless/ath5k/eeprom.h                |  215 +
 drivers/net/wireless/ath5k/gpio.c                  |  176 +
 drivers/net/wireless/ath5k/hw.c                    | 4529 ----------
 drivers/net/wireless/ath5k/hw.h                    |  616 --
 drivers/net/wireless/ath5k/initvals.c              |   22 +-
 drivers/net/wireless/ath5k/pcu.c                   | 1014 +++
 drivers/net/wireless/ath5k/phy.c                   |   12 +-
 drivers/net/wireless/ath5k/qcu.c                   |  488 ++
 drivers/net/wireless/ath5k/reg.h                   |  679 +-
 drivers/net/wireless/ath5k/reset.c                 |  931 +++
 drivers/net/wireless/ath9k/Kconfig                 |    3 +
 drivers/net/wireless/ath9k/ath9k.h                 |   64 +-
 drivers/net/wireless/ath9k/beacon.c                |  383 +-
 drivers/net/wireless/ath9k/core.c                  |  426 +-
 drivers/net/wireless/ath9k/core.h                  |  294 +-
 drivers/net/wireless/ath9k/hw.c                    |  312 +-
 drivers/net/wireless/ath9k/hw.h                    |  120 +-
 drivers/net/wireless/ath9k/main.c                  | 1265 ++-
 drivers/net/wireless/ath9k/phy.h                   |   12 +-
 drivers/net/wireless/ath9k/rc.c                    |  280 +-
 drivers/net/wireless/ath9k/rc.h                    |  222 +-
 drivers/net/wireless/ath9k/recv.c                  |   98 +-
 drivers/net/wireless/ath9k/reg.h                   |    6 -
 drivers/net/wireless/ath9k/xmit.c                  |  412 +-
 drivers/net/wireless/atmel.c                       |    2 +-
 drivers/net/wireless/atmel_cs.c                    |    2 +-
 drivers/net/wireless/b43/Kconfig                   |   12 +
 drivers/net/wireless/b43/Makefile                  |    7 +-
 drivers/net/wireless/b43/b43.h                     |  146 +-
 drivers/net/wireless/b43/debugfs.c                 |   79 +-
 drivers/net/wireless/b43/lo.c                      |  120 +-
 drivers/net/wireless/b43/lo.h                      |    4 +-
 drivers/net/wireless/b43/main.c                    |  404 +-
 drivers/net/wireless/b43/phy.h                     |  340 -
 drivers/net/wireless/b43/phy_a.c                   |  643 ++
 drivers/net/wireless/b43/phy_a.h                   |  130 +
 drivers/net/wireless/b43/phy_common.c              |  381 +
 drivers/net/wireless/b43/phy_common.h              |  413 +
 drivers/net/wireless/b43/{phy.c =3D> phy_g.c}        | 4420 +++++-----=
-
 drivers/net/wireless/b43/phy_g.h                   |  209 +
 drivers/net/wireless/b43/phy_lp.c                  |  155 +
 drivers/net/wireless/b43/phy_lp.h                  |  540 ++
 drivers/net/wireless/b43/{nphy.c =3D> phy_n.c}       |  154 +-
 drivers/net/wireless/b43/{nphy.h =3D> phy_n.h}       |   54 +-
 drivers/net/wireless/b43/rfkill.c                  |   10 +-
 drivers/net/wireless/b43/sysfs.c                   |   23 +-
 drivers/net/wireless/b43/tables.c                  |   43 +-
 drivers/net/wireless/b43/tables_nphy.c             |    4 +-
 drivers/net/wireless/b43/wa.c                      |    2 +-
 drivers/net/wireless/b43/xmit.c                    |   14 +-
 drivers/net/wireless/b43legacy/main.c              |   38 +-
 drivers/net/wireless/b43legacy/phy.c               |   36 +-
 drivers/net/wireless/b43legacy/xmit.c              |   12 +-
 drivers/net/wireless/hermes.c                      |  124 +-
 drivers/net/wireless/hermes.h                      |   45 +
 drivers/net/wireless/hermes_dld.c                  |  730 ++
 drivers/net/wireless/hermes_dld.h                  |   48 +
 drivers/net/wireless/hermes_rid.h                  |   17 +
 drivers/net/wireless/ipw2100.c                     |    2 +-
 drivers/net/wireless/ipw2200.h                     |    4 +-
 drivers/net/wireless/iwlwifi/iwl-3945-debug.h      |    4 +-
 drivers/net/wireless/iwlwifi/iwl-3945-io.h         |   24 +-
 drivers/net/wireless/iwlwifi/iwl-3945-rs.c         |  200 +-
 drivers/net/wireless/iwlwifi/iwl-3945-rs.h         |    9 -
 drivers/net/wireless/iwlwifi/iwl-3945.c            |  205 +-
 drivers/net/wireless/iwlwifi/iwl-3945.h            |    8 +-
 drivers/net/wireless/iwlwifi/iwl-4965-hw.h         |   13 +-
 drivers/net/wireless/iwlwifi/iwl-4965.c            |   11 +-
 drivers/net/wireless/iwlwifi/iwl-5000-hw.h         |    7 +
 drivers/net/wireless/iwlwifi/iwl-5000.c            |   71 +-
 drivers/net/wireless/iwlwifi/iwl-agn-rs.c          |  331 +-
 drivers/net/wireless/iwlwifi/iwl-agn-rs.h          |   29 +-
 drivers/net/wireless/iwlwifi/iwl-agn.c             |  275 +-
 drivers/net/wireless/iwlwifi/iwl-calib.c           |   75 +-
 drivers/net/wireless/iwlwifi/iwl-commands.h        |   24 +-
 drivers/net/wireless/iwlwifi/iwl-core.c            |  136 +-
 drivers/net/wireless/iwlwifi/iwl-core.h            |   25 +-
 drivers/net/wireless/iwlwifi/iwl-csr.h             |    2 +-
 drivers/net/wireless/iwlwifi/iwl-debug.h           |   12 +-
 drivers/net/wireless/iwlwifi/iwl-dev.h             |  107 +-
 drivers/net/wireless/iwlwifi/iwl-fh.h              |    9 +-
 drivers/net/wireless/iwlwifi/iwl-hcmd.c            |   14 +-
 drivers/net/wireless/iwlwifi/iwl-io.h              |   22 +-
 drivers/net/wireless/iwlwifi/iwl-power.c           |  102 +-
 drivers/net/wireless/iwlwifi/iwl-power.h           |    8 +-
 drivers/net/wireless/iwlwifi/iwl-rx.c              |  163 +-
 drivers/net/wireless/iwlwifi/iwl-scan.c            |   41 +-
 drivers/net/wireless/iwlwifi/iwl-sta.c             |   31 +-
 drivers/net/wireless/iwlwifi/iwl-tx.c              |   65 +-
 drivers/net/wireless/iwlwifi/iwl3945-base.c        |  250 +-
 drivers/net/wireless/libertas/assoc.c              |  750 +-
 drivers/net/wireless/libertas/assoc.h              |   18 +-
 drivers/net/wireless/libertas/cmd.c                |  430 +-
 drivers/net/wireless/libertas/cmd.h                |   22 +
 drivers/net/wireless/libertas/cmdresp.c            |   80 -
 drivers/net/wireless/libertas/decl.h               |    1 -
 drivers/net/wireless/libertas/defs.h               |   41 +-
 drivers/net/wireless/libertas/dev.h                |   11 +-
 drivers/net/wireless/libertas/host.h               |   51 +-
 drivers/net/wireless/libertas/hostcmd.h            |   84 +-
 drivers/net/wireless/libertas/if_cs.c              |    2 +-
 drivers/net/wireless/libertas/if_usb.c             |  182 +-
 drivers/net/wireless/libertas/if_usb.h             |    5 +
 drivers/net/wireless/libertas/main.c               |   41 +-
 drivers/net/wireless/libertas/scan.c               |    5 +
 drivers/net/wireless/libertas/wext.c               |  363 +-
 drivers/net/wireless/libertas_tf/Makefile          |    6 +
 drivers/net/wireless/libertas_tf/cmd.c             |  669 ++
 drivers/net/wireless/libertas_tf/if_usb.c          |  766 ++
 drivers/net/wireless/libertas_tf/if_usb.h          |   98 +
 drivers/net/wireless/libertas_tf/libertas_tf.h     |  514 ++
 drivers/net/wireless/libertas_tf/main.c            |  662 ++
 drivers/net/wireless/mac80211_hwsim.c              |  211 +-
 drivers/net/wireless/netwave_cs.c                  |    2 +-
 drivers/net/wireless/orinoco.c                     | 1951 ++++-
 drivers/net/wireless/orinoco.h                     |   61 +-
 drivers/net/wireless/orinoco_cs.c                  |    5 +-
 drivers/net/wireless/orinoco_nortel.c              |    3 +-
 drivers/net/wireless/orinoco_pci.c                 |    3 +-
 drivers/net/wireless/orinoco_plx.c                 |    3 +-
 drivers/net/wireless/orinoco_tmd.c                 |    3 +-
 drivers/net/wireless/p54/p54.h                     |   55 +-
 drivers/net/wireless/p54/p54common.c               |  695 ++-
 drivers/net/wireless/p54/p54common.h               |  124 +-
 drivers/net/wireless/p54/p54pci.c                  |  427 +-
 drivers/net/wireless/p54/p54pci.h                  |   20 +-
 drivers/net/wireless/p54/p54usb.c                  |  200 +-
 drivers/net/wireless/p54/p54usb.h                  |   11 +-
 drivers/net/wireless/prism54/isl_ioctl.c           |    8 +-
 drivers/net/wireless/ray_cs.c                      |    2 +-
 drivers/net/wireless/rndis_wlan.c                  |    3 +-
 drivers/net/wireless/rt2x00/Kconfig                |  128 +-
 drivers/net/wireless/rt2x00/Makefile               |    1 +
 drivers/net/wireless/rt2x00/rt2400pci.c            |   58 +-
 drivers/net/wireless/rt2x00/rt2400pci.h            |   22 +-
 drivers/net/wireless/rt2x00/rt2500pci.c            |   59 +-
 drivers/net/wireless/rt2x00/rt2500pci.h            |   17 +-
 drivers/net/wireless/rt2x00/rt2500usb.c            |   68 +-
 drivers/net/wireless/rt2x00/rt2500usb.h            |   17 +-
 drivers/net/wireless/rt2x00/rt2x00.h               |   90 +-
 drivers/net/wireless/rt2x00/rt2x00config.c         |   16 +-
 drivers/net/wireless/rt2x00/rt2x00crypto.c         |  215 +
 drivers/net/wireless/rt2x00/rt2x00debug.c          |   97 +
 drivers/net/wireless/rt2x00/rt2x00dev.c            |  129 +-
 drivers/net/wireless/rt2x00/rt2x00lib.h            |   49 +-
 drivers/net/wireless/rt2x00/rt2x00mac.c            |  245 +-
 drivers/net/wireless/rt2x00/rt2x00queue.c          |  136 +-
 drivers/net/wireless/rt2x00/rt2x00queue.h          |   82 +-
 drivers/net/wireless/rt2x00/rt2x00reg.h            |   19 +-
 drivers/net/wireless/rt2x00/rt2x00rfkill.c         |   63 +-
 drivers/net/wireless/rt2x00/rt2x00usb.c            |   21 +-
 drivers/net/wireless/rt2x00/rt61pci.c              |  447 +-
 drivers/net/wireless/rt2x00/rt61pci.h              |   38 +-
 drivers/net/wireless/rt2x00/rt73usb.c              |  457 +-
 drivers/net/wireless/rt2x00/rt73usb.h              |   38 +-
 drivers/net/wireless/rtl8180.h                     |   31 -
 drivers/net/wireless/rtl8180_dev.c                 |   49 +-
 drivers/net/wireless/rtl8187.h                     |    6 -
 drivers/net/wireless/rtl8187_dev.c                 |   20 +-
 drivers/net/wireless/rtl818x.h                     |   35 +
 drivers/net/wireless/spectrum_cs.c                 |  428 +-
 drivers/net/wireless/wavelan_cs.c                  |    2 +-
 drivers/net/wireless/wl3501_cs.c                   |   10 +-
 drivers/net/wireless/zd1211rw/Makefile             |    2 +-
 drivers/net/wireless/zd1211rw/zd_chip.c            |    1 -
 drivers/net/wireless/zd1211rw/zd_ieee80211.c       |  100 -
 drivers/net/wireless/zd1211rw/zd_ieee80211.h       |   95 -
 drivers/net/wireless/zd1211rw/zd_mac.c             |   67 +-
 drivers/net/wireless/zd1211rw/zd_mac.h             |   65 +-
 drivers/net/wireless/zd1211rw/zd_rf.c              |    2 +-
 drivers/s390/net/qeth_core_main.c                  |    4 +-
 drivers/s390/net/qeth_l2_main.c                    |   14 +-
 drivers/s390/net/qeth_l3_main.c                    |    8 +-
 drivers/ssb/pci.c                                  |   84 +-
 drivers/usb/atm/usbatm.c                           |    5 +-
 firmware/Makefile                                  |    1 +
 firmware/WHENCE                                    |   10 +
 firmware/sun/cassini.bin.ihex                      |  143 +
 include/asm-um/dma-mapping.h                       |    7 +
 include/linux/Kbuild                               |    2 +
 include/linux/ieee80211.h                          |   36 +-
 include/linux/if.h                                 |    1 +
 include/linux/if_ether.h                           |    6 +
 include/linux/if_link.h                            |    1 +
 include/linux/if_phonet.h                          |   19 +
 include/linux/if_tunnel.h                          |   19 +
 include/linux/in.h                                 |    1 +
 include/linux/inetdevice.h                         |    1 +
 include/linux/ip_vs.h                              |  160 +
 include/linux/isdn_ppp.h                           |    2 +-
 include/linux/mv643xx_eth.h                        |   13 +-
 include/linux/netdevice.h                          |   31 +-
 include/linux/netfilter.h                          |   97 +-
 include/linux/netfilter/Kbuild                     |    1 +
 include/linux/netfilter/nf_conntrack_proto_gre.h   |    2 +-
 include/linux/netfilter/x_tables.h                 |  161 +-
 include/linux/netfilter/xt_TPROXY.h                |   14 +
 include/linux/netfilter/xt_recent.h                |   26 +
 include/linux/netfilter_bridge/ebtables.h          |   76 +-
 include/linux/netfilter_ipv4/ipt_recent.h          |   28 +-
 include/linux/nl80211.h                            |  133 +-
 include/linux/pci_ids.h                            |   13 +
 include/linux/pfkeyv2.h                            |   13 +-
 include/linux/phonet.h                             |  170 +
 include/linux/phy.h                                |   52 +-
 include/linux/pkt_sched.h                          |    7 +
 include/linux/rfkill.h                             |    7 +-
 include/linux/rtnetlink.h                          |    4 +
 include/linux/skbuff.h                             |  175 +-
 include/linux/socket.h                             |    5 +-
 include/linux/ssb/ssb_regs.h                       |   19 +-
 include/linux/tc_act/Kbuild                        |    1 +
 include/linux/tc_act/tc_skbedit.h                  |   44 +
 include/linux/tcp.h                                |   12 +-
 include/linux/xfrm.h                               |   10 +
 include/net/cfg80211.h                             |   89 +-
 include/net/dsa.h                                  |   37 +
 include/net/flow.h                                 |    2 +
 include/net/ieee80211.h                            |    4 -
 include/net/inet6_hashtables.h                     |   15 +
 include/net/inet_connection_sock.h                 |    2 +
 include/net/inet_hashtables.h                      |   18 +
 include/net/inet_sock.h                            |   20 +-
 include/net/inet_timewait_sock.h                   |    3 +-
 include/net/ip.h                                   |   13 +
 include/net/ip_vs.h                                |  311 +-
 include/net/ipip.h                                 |    2 +-
 include/net/ipv6.h                                 |   47 +-
 include/net/mac80211.h                             |  239 +-
 include/net/net_namespace.h                        |    6 +
 include/net/netfilter/ipv4/nf_defrag_ipv4.h        |    6 +
 include/net/netfilter/nf_conntrack.h               |   34 +-
 include/net/netfilter/nf_conntrack_acct.h          |   10 +-
 include/net/netfilter/nf_conntrack_core.h          |   11 +-
 include/net/netfilter/nf_conntrack_ecache.h        |   27 +-
 include/net/netfilter/nf_conntrack_expect.h        |   22 +-
 include/net/netfilter/nf_conntrack_l4proto.h       |   21 +-
 include/net/netfilter/nf_log.h                     |    8 +-
 include/net/netfilter/nf_queue.h                   |    6 +-
 include/net/netfilter/nf_tproxy_core.h             |   32 +
 include/net/netlink.h                              |   82 -
 include/net/netns/conntrack.h                      |   30 +
 include/net/netns/ipv4.h                           |    3 +
 include/net/netns/mib.h                            |    9 +
 include/net/phonet/gprs.h                          |   38 +
 include/net/phonet/pep.h                           |  160 +
 include/net/phonet/phonet.h                        |  112 +
 include/net/phonet/pn_dev.h                        |   50 +
 include/net/pkt_sched.h                            |    5 +-
 include/net/route.h                                |   11 +-
 include/net/sch_generic.h                          |    1 +
 include/net/sctp/constants.h                       |    4 +-
 include/net/sctp/sctp.h                            |   10 +-
 include/net/sctp/structs.h                         |   34 +-
 include/net/sctp/tsnmap.h                          |   53 +-
 include/net/sock.h                                 |   19 +
 include/net/tc_act/tc_skbedit.h                    |   34 +
 include/net/tcp.h                                  |   52 +-
 include/net/udp.h                                  |   21 +-
 include/net/wireless.h                             |   65 +-
 include/net/xfrm.h                                 |  104 +-
 net/8021q/vlan.c                                   |    1 +
 net/8021q/vlan_dev.c                               |    3 +-
 net/Kconfig                                        |   10 +-
 net/Makefile                                       |    2 +
 net/atm/br2684.c                                   |    8 +-
 net/atm/lec.c                                      |    1 -
 net/bridge/br.c                                    |   22 +-
 net/bridge/br_device.c                             |    3 +-
 net/bridge/br_if.c                                 |   15 +-
 net/bridge/br_ioctl.c                              |   20 +-
 net/bridge/br_netfilter.c                          |    4 +-
 net/bridge/br_netlink.c                            |   15 +-
 net/bridge/br_notify.c                             |    3 -
 net/bridge/br_private.h                            |    6 +-
 net/bridge/br_stp_bpdu.c                           |    3 -
 net/bridge/netfilter/Kconfig                       |   30 +-
 net/bridge/netfilter/ebt_802_3.c                   |   47 +-
 net/bridge/netfilter/ebt_among.c                   |   85 +-
 net/bridge/netfilter/ebt_arp.c                     |   73 +-
 net/bridge/netfilter/ebt_arpreply.c                |   49 +-
 net/bridge/netfilter/ebt_dnat.c                    |   57 +-
 net/bridge/netfilter/ebt_ip.c                      |   72 +-
 net/bridge/netfilter/ebt_ip6.c                     |   76 +-
 net/bridge/netfilter/ebt_limit.c                   |   45 +-
 net/bridge/netfilter/ebt_log.c                     |   57 +-
 net/bridge/netfilter/ebt_mark.c                    |   41 +-
 net/bridge/netfilter/ebt_mark_m.c                  |   45 +-
 net/bridge/netfilter/ebt_nflog.c                   |   44 +-
 net/bridge/netfilter/ebt_pkttype.c                 |   41 +-
 net/bridge/netfilter/ebt_redirect.c                |   63 +-
 net/bridge/netfilter/ebt_snat.c                    |   52 +-
 net/bridge/netfilter/ebt_stp.c                     |   78 +-
 net/bridge/netfilter/ebt_ulog.c                    |   58 +-
 net/bridge/netfilter/ebt_vlan.c                    |   61 +-
 net/bridge/netfilter/ebtables.c                    |  313 +-
 net/core/Makefile                                  |    1 +
 net/core/dev.c                                     |   96 +-
 net/core/dst.c                                     |    1 +
 net/core/neighbour.c                               |   21 +-
 net/core/net-sysfs.c                               |   36 +
 net/core/net_namespace.c                           |    1 +
 net/core/rtnetlink.c                               |   13 +
 net/core/skb_dma_map.c                             |   66 +
 net/core/skbuff.c                                  |   63 +-
 net/core/sock.c                                    |   13 +-
 net/dccp/ccids/ccid2.c                             |    2 +-
 net/dccp/ccids/ccid3.c                             |    2 +-
 net/dccp/ccids/lib/loss_interval.c                 |    6 +-
 net/dccp/ccids/lib/tfrc.c                          |    2 +-
 net/dccp/input.c                                   |    4 +-
 net/dccp/ipv4.c                                    |    5 +-
 net/dccp/ipv6.c                                    |   12 +-
 net/dccp/options.c                                 |   13 +-
 net/dccp/proto.c                                   |    4 +-
 net/dsa/Kconfig                                    |   60 +
 net/dsa/Makefile                                   |   13 +
 net/dsa/dsa.c                                      |  392 +
 net/dsa/dsa_priv.h                                 |  116 +
 net/dsa/mv88e6060.c                                |  287 +
 net/dsa/mv88e6123_61_65.c                          |  421 +
 net/dsa/mv88e6131.c                                |  380 +
 net/dsa/mv88e6xxx.c                                |  522 ++
 net/dsa/mv88e6xxx.h                                |   93 +
 net/dsa/slave.c                                    |  298 +
 net/dsa/tag_dsa.c                                  |  194 +
 net/dsa/tag_edsa.c                                 |  213 +
 net/dsa/tag_trailer.c                              |  130 +
 net/ethernet/eth.c                                 |   14 +-
 net/ieee80211/ieee80211_module.c                   |    8 +-
 net/ipv4/Kconfig                                   |    2 -
 net/ipv4/Makefile                                  |    1 -
 net/ipv4/af_inet.c                                 |    2 +-
 net/ipv4/igmp.c                                    |    7 +-
 net/ipv4/inet_connection_sock.c                    |   19 +-
 net/ipv4/inet_diag.c                               |    6 +-
 net/ipv4/inet_timewait_sock.c                      |    1 +
 net/ipv4/ip_gre.c                                  |  487 +-
 net/ipv4/ip_output.c                               |    4 +-
 net/ipv4/ip_sockglue.c                             |   15 +-
 net/ipv4/ipvs/ip_vs_ctl.c                          | 2373 ------
 net/ipv4/ipvs/ip_vs_proto_ah.c                     |  178 -
 net/ipv4/ipvs/ip_vs_proto_esp.c                    |  176 -
 net/ipv4/ipvs/ip_vs_xmit.c                         |  559 --
 net/ipv4/netfilter.c                               |   10 +-
 net/ipv4/netfilter/Kconfig                         |  128 +-
 net/ipv4/netfilter/Makefile                        |    4 +-
 net/ipv4/netfilter/arp_tables.c                    |  116 +-
 net/ipv4/netfilter/arpt_mangle.c                   |   15 +-
 net/ipv4/netfilter/arptable_filter.c               |    8 +-
 net/ipv4/netfilter/ip_tables.c                     |  177 +-
 net/ipv4/netfilter/ipt_CLUSTERIP.c                 |   29 +-
 net/ipv4/netfilter/ipt_ECN.c                       |   17 +-
 net/ipv4/netfilter/ipt_LOG.c                       |   21 +-
 net/ipv4/netfilter/ipt_MASQUERADE.c                |   30 +-
 net/ipv4/netfilter/ipt_NETMAP.c                    |   26 +-
 net/ipv4/netfilter/ipt_REDIRECT.c                  |   21 +-
 net/ipv4/netfilter/ipt_REJECT.c                    |   19 +-
 net/ipv4/netfilter/ipt_TTL.c                       |   15 +-
 net/ipv4/netfilter/ipt_ULOG.c                      |   23 +-
 net/ipv4/netfilter/ipt_addrtype.c                  |   35 +-
 net/ipv4/netfilter/ipt_ah.c                        |   24 +-
 net/ipv4/netfilter/ipt_ecn.c                       |   20 +-
 net/ipv4/netfilter/ipt_ttl.c                       |    9 +-
 net/ipv4/netfilter/iptable_filter.c                |    6 +-
 net/ipv4/netfilter/iptable_mangle.c                |   10 +-
 net/ipv4/netfilter/iptable_raw.c                   |    4 +-
 net/ipv4/netfilter/iptable_security.c              |    6 +-
 net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c     |   68 +-
 .../netfilter/nf_conntrack_l3proto_ipv4_compat.c   |   73 +-
 net/ipv4/netfilter/nf_conntrack_proto_icmp.c       |   22 +-
 net/ipv4/netfilter/nf_defrag_ipv4.c                |   96 +
 net/ipv4/netfilter/nf_nat_core.c                   |   72 +-
 net/ipv4/netfilter/nf_nat_helper.c                 |    3 +-
 net/ipv4/netfilter/nf_nat_pptp.c                   |    3 +-
 net/ipv4/netfilter/nf_nat_rule.c                   |   92 +-
 net/ipv4/route.c                                   |   34 +-
 net/ipv4/syncookies.c                              |    3 +
 net/ipv4/sysctl_net_ipv4.c                         |   23 +-
 net/ipv4/tcp.c                                     |   18 +-
 net/ipv4/tcp_input.c                               |  329 +-
 net/ipv4/tcp_ipv4.c                                |   51 +-
 net/ipv4/tcp_minisocks.c                           |    1 +
 net/ipv4/tcp_output.c                              |  222 +-
 net/ipv4/tcp_timer.c                               |    2 +-
 net/ipv4/udp.c                                     |  123 +-
 net/ipv6/af_inet6.c                                |   69 +-
 net/ipv6/exthdrs.c                                 |   42 +-
 net/ipv6/icmp.c                                    |    8 +-
 net/ipv6/ip6_input.c                               |   27 +-
 net/ipv6/ip6_output.c                              |   80 +-
 net/ipv6/ip6_tunnel.c                              |    4 +-
 net/ipv6/ip6mr.c                                   |    3 +-
 net/ipv6/mcast.c                                   |   22 +-
 net/ipv6/ndisc.c                                   |   12 +-
 net/ipv6/netfilter.c                               |    5 +-
 net/ipv6/netfilter/Kconfig                         |   77 +-
 net/ipv6/netfilter/ip6_tables.c                    |  173 +-
 net/ipv6/netfilter/ip6t_HL.c                       |   15 +-
 net/ipv6/netfilter/ip6t_LOG.c                      |   22 +-
 net/ipv6/netfilter/ip6t_REJECT.c                   |   39 +-
 net/ipv6/netfilter/ip6t_ah.c                       |   21 +-
 net/ipv6/netfilter/ip6t_eui64.c                    |   11 +-
 net/ipv6/netfilter/ip6t_frag.c                     |   21 +-
 net/ipv6/netfilter/ip6t_hbh.c                      |   25 +-
 net/ipv6/netfilter/ip6t_hl.c                       |    9 +-
 net/ipv6/netfilter/ip6t_ipv6header.c               |   16 +-
 net/ipv6/netfilter/ip6t_mh.c                       |   25 +-
 net/ipv6/netfilter/ip6t_rt.c                       |   21 +-
 net/ipv6/netfilter/ip6table_filter.c               |    6 +-
 net/ipv6/netfilter/ip6table_mangle.c               |   31 +-
 net/ipv6/netfilter/ip6table_raw.c                  |   20 +-
 net/ipv6/netfilter/ip6table_security.c             |    6 +-
 net/ipv6/netfilter/nf_conntrack_l3proto_ipv6.c     |   24 +-
 net/ipv6/netfilter/nf_conntrack_proto_icmpv6.c     |   19 +-
 net/ipv6/netfilter/nf_conntrack_reasm.c            |   32 +-
 net/ipv6/proc.c                                    |  121 +-
 net/ipv6/raw.c                                     |    4 +-
 net/ipv6/reassembly.c                              |   65 +-
 net/ipv6/route.c                                   |   55 +-
 net/ipv6/tcp_ipv6.c                                |  166 +-
 net/ipv6/udp.c                                     |   18 +-
 net/ipv6/udplite.c                                 |    2 -
 net/key/af_key.c                                   |  125 +-
 net/mac80211/Kconfig                               |   26 +-
 net/mac80211/Makefile                              |    7 +
 net/mac80211/cfg.c                                 |  201 +-
 net/mac80211/debugfs.c                             |    4 -
 net/mac80211/debugfs_key.c                         |    3 +-
 net/mac80211/debugfs_netdev.c                      |   72 +-
 net/mac80211/debugfs_sta.c                         |   11 +-
 net/mac80211/event.c                               |    5 +-
 net/mac80211/ht.c                                  |  992 +++
 net/mac80211/ieee80211_i.h                         |  393 +-
 net/mac80211/iface.c                               |  620 ++-
 net/mac80211/key.c                                 |   22 +-
 net/mac80211/main.c                                | 1003 +--
 net/mac80211/mesh.c                                |  368 +-
 net/mac80211/mesh.h                                |   80 +-
 net/mac80211/mesh_hwmp.c                           |  230 +-
 net/mac80211/mesh_pathtbl.c                        |  211 +-
 net/mac80211/mesh_plink.c                          |   98 +-
 net/mac80211/mlme.c                                | 3920 +++-------
 net/mac80211/rate.c                                |   71 +-
 net/mac80211/rate.h                                |  116 +-
 net/mac80211/rc80211_minstrel.c                    |  583 ++
 net/mac80211/rc80211_minstrel.h                    |   85 +
 net/mac80211/rc80211_minstrel_debugfs.c            |  164 +
 net/mac80211/rc80211_pid.h                         |    4 +-
 net/mac80211/rc80211_pid_algo.c                    |  191 +-
 net/mac80211/rx.c                                  |  367 +-
 net/mac80211/scan.c                                |  937 +++
 net/mac80211/spectmgmt.c                           |   86 +
 net/mac80211/sta_info.c                            |  100 +-
 net/mac80211/sta_info.h                            |   42 +-
 net/mac80211/tkip.c                                |    2 +-
 net/mac80211/tx.c                                  |  334 +-
 net/mac80211/util.c                                |  365 +-
 net/mac80211/wep.c                                 |   17 +-
 net/mac80211/wext.c                                |  165 +-
 net/mac80211/wme.c                                 |   14 +-
 net/mac80211/wme.h                                 |    3 -
 net/mac80211/wpa.c                                 |   10 +-
 net/netfilter/Kconfig                              |  236 +-
 net/netfilter/Makefile                             |    9 +
 net/netfilter/core.c                               |   18 +-
 net/{ipv4 =3D> netfilter}/ipvs/Kconfig               |   17 +-
 net/{ipv4 =3D> netfilter}/ipvs/Makefile              |    3 +-
 net/{ipv4 =3D> netfilter}/ipvs/ip_vs_app.c           |    0=20
 net/{ipv4 =3D> netfilter}/ipvs/ip_vs_conn.c          |  251 +-
 net/{ipv4 =3D> netfilter}/ipvs/ip_vs_core.c          |  817 ++-
 net/netfilter/ipvs/ip_vs_ctl.c                     | 3443 ++++++++
 net/{ipv4 =3D> netfilter}/ipvs/ip_vs_dh.c            |    5 +-
 net/{ipv4 =3D> netfilter}/ipvs/ip_vs_est.c           |   58 +-
 net/{ipv4 =3D> netfilter}/ipvs/ip_vs_ftp.c           |   61 +-
 net/{ipv4 =3D> netfilter}/ipvs/ip_vs_lblc.c          |  220 +-
 net/{ipv4 =3D> netfilter}/ipvs/ip_vs_lblcr.c         |  249 +-
 net/{ipv4 =3D> netfilter}/ipvs/ip_vs_lc.c            |   32 +-
 net/{ipv4 =3D> netfilter}/ipvs/ip_vs_nq.c            |   39 +-
 net/{ipv4 =3D> netfilter}/ipvs/ip_vs_proto.c         |   65 +-
 net/netfilter/ipvs/ip_vs_proto_ah_esp.c            |  235 +
 net/{ipv4 =3D> netfilter}/ipvs/ip_vs_proto_tcp.c     |  254 +-
 net/{ipv4 =3D> netfilter}/ipvs/ip_vs_proto_udp.c     |  227 +-
 net/{ipv4 =3D> netfilter}/ipvs/ip_vs_rr.c            |   20 +-
 net/{ipv4 =3D> netfilter}/ipvs/ip_vs_sched.c         |    0=20
 net/{ipv4 =3D> netfilter}/ipvs/ip_vs_sed.c           |   39 +-
 net/{ipv4 =3D> netfilter}/ipvs/ip_vs_sh.c            |    5 +-
 net/{ipv4 =3D> netfilter}/ipvs/ip_vs_sync.c          |   46 +-
 net/{ipv4 =3D> netfilter}/ipvs/ip_vs_wlc.c           |   39 +-
 net/{ipv4 =3D> netfilter}/ipvs/ip_vs_wrr.c           |   15 +-
 net/netfilter/ipvs/ip_vs_xmit.c                    | 1004 +++
 net/netfilter/nf_conntrack_acct.c                  |  100 +-
 net/netfilter/nf_conntrack_core.c                  |  344 +-
 net/netfilter/nf_conntrack_ecache.c                |   26 +-
 net/netfilter/nf_conntrack_expect.c                |  104 +-
 net/netfilter/nf_conntrack_ftp.c                   |    9 +-
 net/netfilter/nf_conntrack_h323_main.c             |    6 +-
 net/netfilter/nf_conntrack_helper.c                |   40 +-
 net/netfilter/nf_conntrack_netlink.c               |   31 +-
 net/netfilter/nf_conntrack_pptp.c                  |   36 +-
 net/netfilter/nf_conntrack_proto.c                 |   10 +-
 net/netfilter/nf_conntrack_proto_dccp.c            |   20 +-
 net/netfilter/nf_conntrack_proto_generic.c         |    2 +-
 net/netfilter/nf_conntrack_proto_gre.c             |  101 +-
 net/netfilter/nf_conntrack_proto_sctp.c            |    6 +-
 net/netfilter/nf_conntrack_proto_tcp.c             |   35 +-
 net/netfilter/nf_conntrack_proto_udp.c             |   16 +-
 net/netfilter/nf_conntrack_proto_udplite.c         |   20 +-
 net/netfilter/nf_conntrack_sip.c                   |    3 +-
 net/netfilter/nf_conntrack_standalone.c            |  146 +-
 net/netfilter/nf_internals.h                       |    4 +-
 net/netfilter/nf_log.c                             |   18 +-
 net/netfilter/nf_queue.c                           |   22 +-
 net/netfilter/nf_sockopt.c                         |   18 +-
 net/netfilter/nf_tproxy_core.c                     |   96 +
 net/netfilter/nfnetlink_log.c                      |    4 +-
 net/netfilter/x_tables.c                           |  145 +-
 net/netfilter/xt_CLASSIFY.c                        |   44 +-
 net/netfilter/xt_CONNMARK.c                        |   78 +-
 net/netfilter/xt_CONNSECMARK.c                     |   63 +-
 net/netfilter/xt_DSCP.c                            |   59 +-
 net/netfilter/xt_MARK.c                            |   76 +-
 net/netfilter/xt_NFLOG.c                           |   46 +-
 net/netfilter/xt_NFQUEUE.c                         |   10 +-
 net/netfilter/xt_NOTRACK.c                         |   30 +-
 net/netfilter/xt_RATEEST.c                         |   56 +-
 net/netfilter/xt_SECMARK.c                         |   52 +-
 net/netfilter/xt_TCPMSS.c                          |   38 +-
 net/netfilter/xt_TCPOPTSTRIP.c                     |   16 +-
 net/netfilter/xt_TPROXY.c                          |  102 +
 net/netfilter/xt_TRACE.c                           |   30 +-
 net/netfilter/xt_comment.c                         |   31 +-
 net/netfilter/xt_connbytes.c                       |   56 +-
 net/netfilter/xt_connlimit.c                       |   80 +-
 net/netfilter/xt_connmark.c                        |   68 +-
 net/netfilter/xt_conntrack.c                       |   62 +-
 net/netfilter/xt_dccp.c                            |   27 +-
 net/netfilter/xt_dscp.c                            |   51 +-
 net/netfilter/xt_esp.c                             |   25 +-
 net/netfilter/xt_hashlimit.c                       |  104 +-
 net/netfilter/xt_helper.c                          |   54 +-
 net/netfilter/xt_iprange.c                         |   27 +-
 net/netfilter/xt_length.c                          |   18 +-
 net/netfilter/xt_limit.c                           |   54 +-
 net/netfilter/xt_mac.c                             |   41 +-
 net/netfilter/xt_mark.c                            |   46 +-
 net/netfilter/xt_multiport.c                       |   71 +-
 net/netfilter/xt_owner.c                           |   51 +-
 net/netfilter/xt_physdev.c                         |   49 +-
 net/netfilter/xt_pkttype.c                         |   37 +-
 net/netfilter/xt_policy.c                          |   34 +-
 net/netfilter/xt_quota.c                           |   43 +-
 net/netfilter/xt_rateest.c                         |   58 +-
 net/netfilter/xt_realm.c                           |    9 +-
 .../ipt_recent.c =3D> netfilter/xt_recent.c}         |  348 +-
 net/netfilter/xt_sctp.c                            |   27 +-
 net/netfilter/xt_socket.c                          |  185 +
 net/netfilter/xt_state.c                           |   24 +-
 net/netfilter/xt_statistic.c                       |   45 +-
 net/netfilter/xt_string.c                          |   53 +-
 net/netfilter/xt_tcpmss.c                          |   17 +-
 net/netfilter/xt_tcpudp.c                          |   64 +-
 net/netfilter/xt_time.c                            |   47 +-
 net/netfilter/xt_u32.c                             |   33 +-
 net/phonet/Kconfig                                 |   16 +
 net/phonet/Makefile                                |   11 +
 net/phonet/af_phonet.c                             |  477 ++
 net/phonet/datagram.c                              |  197 +
 net/phonet/pep-gprs.c                              |  347 +
 net/phonet/pep.c                                   | 1076 +++
 net/phonet/pn_dev.c                                |  208 +
 net/phonet/pn_netlink.c                            |  165 +
 net/phonet/socket.c                                |  411 +
 net/phonet/sysctl.c                                |  113 +
 net/rfkill/rfkill-input.h                          |    1 +
 net/rfkill/rfkill.c                                |  259 +-
 net/sched/Kconfig                                  |   20 +
 net/sched/Makefile                                 |    2 +
 net/sched/act_ipt.c                                |   46 +-
 net/sched/act_skbedit.c                            |  203 +
 net/sched/cls_flow.c                               |   28 +-
 net/sched/em_cmp.c                                 |    9 +-
 net/sched/sch_dsmark.c                             |    8 +-
 net/sched/sch_generic.c                            |   31 +-
 net/sched/sch_multiq.c                             |  477 ++
 net/sched/sch_netem.c                              |   18 +-
 net/sched/sch_prio.c                               |    6 +-
 net/sched/sch_sfq.c                                |    4 +-
 net/sctp/associola.c                               |    9 +-
 net/sctp/bind_addr.c                               |   16 +-
 net/sctp/ipv6.c                                    |    7 +-
 net/sctp/output.c                                  |    2 +-
 net/sctp/outqueue.c                                |   65 +-
 net/sctp/sm_make_chunk.c                           |   15 +-
 net/sctp/sm_sideeffect.c                           |   81 +-
 net/sctp/sm_statefuns.c                            |   50 +-
 net/sctp/sm_statetable.c                           |    2 +-
 net/sctp/socket.c                                  |   10 +-
 net/sctp/tsnmap.c                                  |  346 +-
 net/sctp/ulpevent.c                                |   10 +-
 net/sctp/ulpqueue.c                                |    5 +-
 net/sunrpc/xprtrdma/rpc_rdma.c                     |    4 +-
 net/wireless/Kconfig                               |   32 +
 net/wireless/core.c                                |   45 +-
 net/wireless/core.h                                |    2 +-
 net/wireless/nl80211.c                             |  280 +-
 net/wireless/reg.c                                 |  910 ++-
 net/wireless/reg.h                                 |   13 +
 net/xfrm/xfrm_policy.c                             |  118 +-
 net/xfrm/xfrm_state.c                              |   84 +-
 net/xfrm/xfrm_user.c                               |   61 +-
 896 files changed, 93510 insertions(+), 44223 deletions(-)
 create mode 100644 Documentation/networking/LICENSE.qlge
 create mode 100644 Documentation/networking/phonet.txt
 create mode 100644 Documentation/networking/regulatory.txt
 create mode 100644 Documentation/networking/tproxy.txt
 create mode 100644 drivers/net/atlx/atl2.c
 create mode 100644 drivers/net/atlx/atl2.h
 create mode 100644 drivers/net/enic/Makefile
 create mode 100644 drivers/net/enic/cq_desc.h
 create mode 100644 drivers/net/enic/cq_enet_desc.h
 create mode 100644 drivers/net/enic/enic.h
 create mode 100644 drivers/net/enic/enic_main.c
 create mode 100644 drivers/net/enic/enic_res.c
 create mode 100644 drivers/net/enic/enic_res.h
 create mode 100644 drivers/net/enic/rq_enet_desc.h
 create mode 100644 drivers/net/enic/vnic_cq.c
 create mode 100644 drivers/net/enic/vnic_cq.h
 create mode 100644 drivers/net/enic/vnic_dev.c
 create mode 100644 drivers/net/enic/vnic_dev.h
 create mode 100644 drivers/net/enic/vnic_devcmd.h
 create mode 100644 drivers/net/enic/vnic_enet.h
 create mode 100644 drivers/net/enic/vnic_intr.c
 create mode 100644 drivers/net/enic/vnic_intr.h
 create mode 100644 drivers/net/enic/vnic_nic.h
 create mode 100644 drivers/net/enic/vnic_resource.h
 create mode 100644 drivers/net/enic/vnic_rq.c
 create mode 100644 drivers/net/enic/vnic_rq.h
 create mode 100644 drivers/net/enic/vnic_rss.h
 create mode 100644 drivers/net/enic/vnic_stats.h
 create mode 100644 drivers/net/enic/vnic_wq.c
 create mode 100644 drivers/net/enic/vnic_wq.h
 create mode 100644 drivers/net/enic/wq_enet_desc.h
 create mode 100644 drivers/net/jme.c
 create mode 100644 drivers/net/jme.h
 create mode 100644 drivers/net/qlge/Makefile
 create mode 100644 drivers/net/qlge/qlge.h
 create mode 100644 drivers/net/qlge/qlge_dbg.c
 create mode 100644 drivers/net/qlge/qlge_ethtool.c
 create mode 100644 drivers/net/qlge/qlge_main.c
 create mode 100644 drivers/net/qlge/qlge_mpi.c
 create mode 100644 drivers/net/usb/smsc95xx.c
 create mode 100644 drivers/net/usb/smsc95xx.h
 create mode 100644 drivers/net/wireless/ath5k/attach.c
 create mode 100644 drivers/net/wireless/ath5k/caps.c
 create mode 100644 drivers/net/wireless/ath5k/desc.c
 create mode 100644 drivers/net/wireless/ath5k/desc.h
 create mode 100644 drivers/net/wireless/ath5k/dma.c
 create mode 100644 drivers/net/wireless/ath5k/eeprom.c
 create mode 100644 drivers/net/wireless/ath5k/eeprom.h
 create mode 100644 drivers/net/wireless/ath5k/gpio.c
 delete mode 100644 drivers/net/wireless/ath5k/hw.c
 delete mode 100644 drivers/net/wireless/ath5k/hw.h
 create mode 100644 drivers/net/wireless/ath5k/pcu.c
 create mode 100644 drivers/net/wireless/ath5k/qcu.c
 create mode 100644 drivers/net/wireless/ath5k/reset.c
 delete mode 100644 drivers/net/wireless/b43/phy.h
 create mode 100644 drivers/net/wireless/b43/phy_a.c
 create mode 100644 drivers/net/wireless/b43/phy_a.h
 create mode 100644 drivers/net/wireless/b43/phy_common.c
 create mode 100644 drivers/net/wireless/b43/phy_common.h
 rename drivers/net/wireless/b43/{phy.c =3D> phy_g.c} (61%)
 create mode 100644 drivers/net/wireless/b43/phy_g.h
 create mode 100644 drivers/net/wireless/b43/phy_lp.c
 create mode 100644 drivers/net/wireless/b43/phy_lp.h
 rename drivers/net/wireless/b43/{nphy.c =3D> phy_n.c} (80%)
 rename drivers/net/wireless/b43/{nphy.h =3D> phy_n.h} (98%)
 create mode 100644 drivers/net/wireless/hermes_dld.c
 create mode 100644 drivers/net/wireless/hermes_dld.h
 create mode 100644 drivers/net/wireless/libertas_tf/Makefile
 create mode 100644 drivers/net/wireless/libertas_tf/cmd.c
 create mode 100644 drivers/net/wireless/libertas_tf/if_usb.c
 create mode 100644 drivers/net/wireless/libertas_tf/if_usb.h
 create mode 100644 drivers/net/wireless/libertas_tf/libertas_tf.h
 create mode 100644 drivers/net/wireless/libertas_tf/main.c
 create mode 100644 drivers/net/wireless/rt2x00/rt2x00crypto.c
 delete mode 100644 drivers/net/wireless/zd1211rw/zd_ieee80211.c
 delete mode 100644 drivers/net/wireless/zd1211rw/zd_ieee80211.h
 create mode 100644 firmware/sun/cassini.bin.ihex
 create mode 100644 include/linux/if_phonet.h
 create mode 100644 include/linux/netfilter/xt_TPROXY.h
 create mode 100644 include/linux/netfilter/xt_recent.h
 create mode 100644 include/linux/phonet.h
 create mode 100644 include/linux/tc_act/tc_skbedit.h
 create mode 100644 include/net/dsa.h
 create mode 100644 include/net/netfilter/ipv4/nf_defrag_ipv4.h
 create mode 100644 include/net/netfilter/nf_tproxy_core.h
 create mode 100644 include/net/netns/conntrack.h
 create mode 100644 include/net/phonet/gprs.h
 create mode 100644 include/net/phonet/pep.h
 create mode 100644 include/net/phonet/phonet.h
 create mode 100644 include/net/phonet/pn_dev.h
 create mode 100644 include/net/tc_act/tc_skbedit.h
 create mode 100644 net/core/skb_dma_map.c
 create mode 100644 net/dsa/Kconfig
 create mode 100644 net/dsa/Makefile
 create mode 100644 net/dsa/dsa.c
 create mode 100644 net/dsa/dsa_priv.h
 create mode 100644 net/dsa/mv88e6060.c
 create mode 100644 net/dsa/mv88e6123_61_65.c
 create mode 100644 net/dsa/mv88e6131.c
 create mode 100644 net/dsa/mv88e6xxx.c
 create mode 100644 net/dsa/mv88e6xxx.h
 create mode 100644 net/dsa/slave.c
 create mode 100644 net/dsa/tag_dsa.c
 create mode 100644 net/dsa/tag_edsa.c
 create mode 100644 net/dsa/tag_trailer.c
 delete mode 100644 net/ipv4/ipvs/ip_vs_ctl.c
 delete mode 100644 net/ipv4/ipvs/ip_vs_proto_ah.c
 delete mode 100644 net/ipv4/ipvs/ip_vs_proto_esp.c
 delete mode 100644 net/ipv4/ipvs/ip_vs_xmit.c
 create mode 100644 net/ipv4/netfilter/nf_defrag_ipv4.c
 create mode 100644 net/mac80211/ht.c
 create mode 100644 net/mac80211/rc80211_minstrel.c
 create mode 100644 net/mac80211/rc80211_minstrel.h
 create mode 100644 net/mac80211/rc80211_minstrel_debugfs.c
 create mode 100644 net/mac80211/scan.c
 create mode 100644 net/mac80211/spectmgmt.c
 rename net/{ipv4 =3D> netfilter}/ipvs/Kconfig (96%)
 rename net/{ipv4 =3D> netfilter}/ipvs/Makefile (88%)
 rename net/{ipv4 =3D> netfilter}/ipvs/ip_vs_app.c (100%)
 rename net/{ipv4 =3D> netfilter}/ipvs/ip_vs_conn.c (77%)
 rename net/{ipv4 =3D> netfilter}/ipvs/ip_vs_core.c (58%)
 create mode 100644 net/netfilter/ipvs/ip_vs_ctl.c
 rename net/{ipv4 =3D> netfilter}/ipvs/ip_vs_dh.c (98%)
 rename net/{ipv4 =3D> netfilter}/ipvs/ip_vs_est.c (78%)
 rename net/{ipv4 =3D> netfilter}/ipvs/ip_vs_ftp.c (87%)
 rename net/{ipv4 =3D> netfilter}/ipvs/ip_vs_lblc.c (80%)
 rename net/{ipv4 =3D> netfilter}/ipvs/ip_vs_lblcr.c (82%)
 rename net/{ipv4 =3D> netfilter}/ipvs/ip_vs_lc.c (82%)
 rename net/{ipv4 =3D> netfilter}/ipvs/ip_vs_nq.c (84%)
 rename net/{ipv4 =3D> netfilter}/ipvs/ip_vs_proto.c (79%)
 create mode 100644 net/netfilter/ipvs/ip_vs_proto_ah_esp.c
 rename net/{ipv4 =3D> netfilter}/ipvs/ip_vs_proto_tcp.c (70%)
 rename net/{ipv4 =3D> netfilter}/ipvs/ip_vs_proto_udp.c (60%)
 rename net/{ipv4 =3D> netfilter}/ipvs/ip_vs_rr.c (88%)
 rename net/{ipv4 =3D> netfilter}/ipvs/ip_vs_sched.c (100%)
 rename net/{ipv4 =3D> netfilter}/ipvs/ip_vs_sed.c (85%)
 rename net/{ipv4 =3D> netfilter}/ipvs/ip_vs_sh.c (98%)
 rename net/{ipv4 =3D> netfilter}/ipvs/ip_vs_sync.c (95%)
 rename net/{ipv4 =3D> netfilter}/ipvs/ip_vs_wlc.c (84%)
 rename net/{ipv4 =3D> netfilter}/ipvs/ip_vs_wrr.c (94%)
 create mode 100644 net/netfilter/ipvs/ip_vs_xmit.c
 create mode 100644 net/netfilter/nf_tproxy_core.c
 create mode 100644 net/netfilter/xt_TPROXY.c
 rename net/{ipv4/netfilter/ipt_recent.c =3D> netfilter/xt_recent.c} (5=
1%)
 create mode 100644 net/netfilter/xt_socket.c
 create mode 100644 net/phonet/Kconfig
 create mode 100644 net/phonet/Makefile
 create mode 100644 net/phonet/af_phonet.c
 create mode 100644 net/phonet/datagram.c
 create mode 100644 net/phonet/pep-gprs.c
 create mode 100644 net/phonet/pep.c
 create mode 100644 net/phonet/pn_dev.c
 create mode 100644 net/phonet/pn_netlink.c
 create mode 100644 net/phonet/socket.c
 create mode 100644 net/phonet/sysctl.c
 create mode 100644 net/sched/act_skbedit.c
 create mode 100644 net/sched/sch_multiq.c
 create mode 100644 net/wireless/reg.h
