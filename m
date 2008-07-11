From: David Miller <davem@davemloft.net>
Subject: [GIT]: Networking
Date: Thu, 10 Jul 2008 17:21:59 -0700 (PDT)
Message-ID: <20080710.172159.229303434.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59386
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1755340AbYGKAV7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Jul 2008 20:21:59 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


The usual slew of small fixup, but there is an OOPS'er and
a leak fix or two in here.  Highlights:

1) fib_trie can OOPS due to inconsistent error return value
   handling.  Fix from Ben Hutchings.

2) Duplicate address handling race in ipv6 fixed by Andrey Vagin.

3) TUN devices can get wedged with TX flow control disabled,
   fix from Max Krasnyansky.  This aparently hits virtualization
   folks a bit, particularly kvm.

4) netfilter TCP connection tracking can get into an endless
   loop, fix from Patrick McHardy.

5) SCTP bug fixes from Vlad Yasevich.

6) Various IRDA small fixups.

7) Merge of wireless bug fixes via John W. Linville

8) IPv4 sysctl documentation improvements from J. Bruce Fields
   and Stephen Hemminger.

9) Netlabel SKB double-free cure, and an ipv6 namespace fixup
   from Denis V. Lunev

Please pull, thanks a lot!

The following changes since commit 7f2d38eb7a42bea1c1df51bbdaa2ca0f0bdda07f:
  Oliver Hartkopp (1):
        can: add sanity checks

are available in the git repository at:

  master.kernel.org:/pub/scm/linux/kernel/git/davem/net-2.6.git master

Andrey Vagin (1):
      ipv6: fix race between ipv6_del_addr and DAD timer

Ben Hutchings (1):
      ipv4: fib_trie: Fix lookup error return

Darren Jenkins (1):
      drivers/net/wireless/iwlwifi/iwl-3945.c Fix type issue on 64bit

David Howells (1):
      netfilter: nf_nat_snmp_basic: fix a range check in NAT for SNMP

David S. Miller (1):
      Merge branch 'master' of git://git.kernel.org/.../linville/wireless-2.6

Denis V. Lunev (2):
      netlabel: netlink_unicast calls kfree_skb on error path by itself
      ipv6: missed namespace context in ipv6_rthdr_rcv

Firat Birlik (1):
      zd1211rw: add ID for AirTies WUS-201

Guy Cohen (1):
      mac80211: move netif_carrier_on to after ieee80211_bss_info_change_notify

Ihar Hrachyshka (1):
      libertas: fix memory alignment problems on the blackfin

Ivo van Doorn (2):
      mac80211: Only flush workqueue when last interface was removed
      rt2x00: Disable synchronization during initialization

J. Bruce Fields (1):
      Documentation: clarify tcp_{r,w}mem sysctl docs

John W. Linville (1):
      hostap_cs: correct poor NULL checks in suspend/resume routines

Julius Volz (1):
      irda: Fix netlink error path return value

Luis Carlos Cobo (1):
      zd1211rw: stop beacons on remove_interface

Mattias Nissler (1):
      rc80211_pid: Fix fast_start parameter handling

Max Krasnyansky (1):
      tun: Persistent devices can get stuck in xoff state

Michael Buesch (1):
      ssb-pcicore: Fix IRQ-vector init on embedded devices

Milton Miller (1):
      tcp: correct kcalloc usage

Patrick McHardy (1):
      netfilter: nf_conntrack_tcp: fix endless loop

Steffen Klassert (1):
      xfrm: Add a XFRM_STATE_AF_UNSPEC flag to xfrm_usersa_info

Stephen Hemminger (1):
      ip: sysctl documentation cleanup

Ville Syrjala (1):
      irda: New device ID for nsc-ircc

Vlad Yasevich (2):
      sctp: Mark the tsn as received after all allocations finish
      sctp: Add documentation for sctp sysctl variable

Vladimir Koutny (1):
      mac80211: don't report selected IBSS when not found

Wang Chen (1):
      irda: via-ircc proper dma freeing

 Documentation/networking/ip-sysctl.txt  |  256 ++++++++++++++++++++++++++-----
 drivers/net/irda/nsc-ircc.c             |    1 +
 drivers/net/irda/via-ircc.c             |    3 +
 drivers/net/tun.c                       |    6 +
 drivers/net/wireless/hostap/hostap_cs.c |   12 +-
 drivers/net/wireless/iwlwifi/iwl-3945.c |    4 +-
 drivers/net/wireless/libertas/scan.c    |    4 +-
 drivers/net/wireless/rt2x00/rt2400pci.c |   11 ++
 drivers/net/wireless/rt2x00/rt2500pci.c |   11 ++
 drivers/net/wireless/rt2x00/rt2500usb.c |    7 +
 drivers/net/wireless/rt2x00/rt61pci.c   |    9 +
 drivers/net/wireless/rt2x00/rt73usb.c   |    9 +
 drivers/net/wireless/zd1211rw/zd_mac.c  |    1 +
 drivers/net/wireless/zd1211rw/zd_usb.c  |    1 +
 drivers/ssb/driver_pcicore.c            |    7 +
 include/linux/xfrm.h                    |    1 +
 net/ipv4/fib_trie.c                     |   17 +--
 net/ipv4/netfilter/nf_nat_snmp_basic.c  |    2 +-
 net/ipv4/tcp_probe.c                    |    2 +-
 net/ipv6/addrconf.c                     |    4 +-
 net/ipv6/exthdrs.c                      |    2 +-
 net/irda/irnetlink.c                    |    4 +-
 net/mac80211/main.c                     |    4 +-
 net/mac80211/mlme.c                     |   13 +-
 net/mac80211/rc80211_pid.h              |    5 -
 net/mac80211/rc80211_pid_algo.c         |   31 ++---
 net/netfilter/nf_conntrack_proto_tcp.c  |   10 +-
 net/netlabel/netlabel_cipso_v4.c        |    7 +-
 net/netlabel/netlabel_mgmt.c            |   12 +--
 net/netlabel/netlabel_unlabeled.c       |    6 +-
 net/sctp/sm_statefuns.c                 |    9 +-
 net/sctp/ulpevent.c                     |    5 +
 net/xfrm/xfrm_user.c                    |    3 +-
 33 files changed, 351 insertions(+), 128 deletions(-)
