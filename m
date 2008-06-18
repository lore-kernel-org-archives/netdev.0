From: David Miller <davem@davemloft.net>
Subject: [GIT]: Networking
Date: Wed, 18 Jun 2008 02:15:57 -0700 (PDT)
Message-ID: <20080618.021557.81064413.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:40221
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751829AbYFRJP4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Jun 2008 05:15:56 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


To my knowledge all of the major 2.6.26 networking regressions
should be fixed after this pull.

1) The SSH connection stall is fixed, by reverting an optimization
   we tried to make in the mac80211 stack.  I know how to do it
   correctly, but that is 2.6.27 material at this point.

2) Poll was busted on UNIX sockets.  The callback test and the
   ->poll() test for "write space" was not the same.  Also
   connected datagram waiting was not being done correctly.
   Fix from Rainer Weikusat.

3) Netfilter NAT RCU bug fix (caused OOPS) and H323 conntrack
   leak/crash fixes from Patrick McHardy.

4) Wireless bug fixes from John Linville and co.

5) Wired driver bug fixes from Jeff Garzik and co.

6) HTB scheduler hysteresis hack gives horrible behavior.  It's
   meant to decrease cpu utilization but doesn't even do that
   very well.  Turn off by default, and provide a knob so folks
   can re-enable it if this happens to cause some problems.
   From Jesper Dangaard Brouer.

7) ATM bug fixes from Chas Williams, Eric Kinzie, Jorge Boncompte, and
   Robert T. Johnson.

8) Revert the rest of the 2.6.26 defer accept changes just to be
   safe.  All of this can be revisited in 2.6.27

9) VLAN TX checksum offload fix from Ben Hutchings.

10) SCTP bug fixes from Vlad Yasevich and Wei Yongjun.

11) IPV6 tunnel user interface fix from YOSHIFUJI Hideaki.

12) Eric Dumazet noticed that newlines got unintentionally removed
    from /proc/net/raw's output.

13) Patrick McHardy fixes a circular locking dependency in genetlink
    reported by lockdep.

Please pull, thanks a lot!

The following changes since commit 7775c9753b94fe429dc4323360d6502c95e0dd6e:
  Linus Torvalds (1):
        Merge git://git.kernel.org/.../kyle/parisc-2.6

are available in the git repository at:

  master.kernel.org:/pub/scm/linux/kernel/git/davem/net-2.6.git master

Abhijeet Kolekar (1):
      mac80211 : fix for iwconfig in ad-hoc mode

Ang Way Chuang (1):
      tun: Proper handling of IPv6 header in tun driver when TUN_NO_PI is set

Ben Hutchings (1):
      net: Fix test for VLAN TX checksum offload capability

Chas Williams (2):
      atm: [he] only support suni driver on multimode interfaces
      atm: [he] send idle cells instead of unassigned when in SDH mode

David Brownell (2):
      net/enc28j60: section fix
      net/enc28j60: low power mode

David S. Miller (4):
      Merge branch 'master' of master.kernel.org:/.../linville/wireless-2.6
      tcp: Revert reset of deferred accept changes in 2.6.26
      Merge branch 'davem-fixes' of master.kernel.org:/.../jgarzik/netdev-2.6
      Revert "mac80211: Use skb_header_cloned() on TX path."

Dhananjay Phadke (4):
      netxen: fix portnum for hp mezz cards
      netxen: remove global physical_port array
      netxen: cleanup debug messages
      netxen: download firmware in pci probe

Eric Dumazet (1):
      raw: Restore /proc/net/raw correct behavior

Eric Kinzie (1):
      atm: [br2864] fix routed vcmux support

Gertjan van Wingerde (1):
      rt2x00: Restrict DMA to 32-bit addresses.

Ivo van Doorn (2):
      rt2x00: Don't kill guardian_urb when it wasn't created
      rt2x00: Add D-link DWA111 support

Jesper Dangaard Brouer (2):
      pkt_sched: HTB scheduler, change default hysteresis mode to off.
      pkt_sched: Change HTB_HYSTERESIS to a runtime parameter htb_hysteresis.

Jorge Boncompte [DTI2] (3):
      atm: [br2684] Fix oops due to skb->dev being NULL
      atm: [iphase] set drvdata before enabling interrupts
      atm: [iphase] doesn't call phy->start due to a bogus #ifndef

Josh Boyer (1):
      ibm_newemac: select CRC32 in Kconfig

Michael Buesch (3):
      b43: Fix possible NULL pointer dereference in DMA code
      b43: Fix noise calculation WARN_ON
      ssb: Fix coherent DMA mask for PCI devices

Patrick McHardy (4):
      netfilter: nf_nat: fix RCU races
      netfilter: nf_conntrack_h323: fix memory leak in module initialization error path
      netfilter: nf_conntrack_h323: fix module unload crash
      netlink: genl: fix circular locking

Radu Cristescu (1):
      atl1: relax eeprom mac address error check

Rainer Weikusat (1):
      af_unix: fix 'poll for write'/ connected DGRAM sockets

Rami Rosen (1):
      ipv4: Remove unused definitions in net/ipv4/tcp_ipv4.c.

Randy Dunlap (2):
      rt2x00: INPUT build failure
      rt2x00: LEDS build failure

Robert T. Johnson (1):
      atm: [he] limit queries to the device's register space

Steffen Klassert (1):
      xfrm: fix fragmentation for ipv4 xfrm tunnel

Stephen Hemminger (1):
      sky2: 88E8040T pci device id

Tomas Winkler (1):
      mac80211: add missing new line in debug print HT_DEBUG

Vlad Yasevich (1):
      sctp: Correclty set changeover_active for SFR-CACC

Wei Yongjun (1):
      sctp: Correctly cleanup procfs entries upon failure.

YOSHIFUJI Hideaki (1):
      ipv6 sit: Avoid extra need for compat layer in PRL management.

 drivers/atm/he.c                            |   11 ++-
 drivers/atm/he.h                            |   13 +--
 drivers/atm/iphase.c                        |   27 +++---
 drivers/net/atlx/atl1.c                     |    1 -
 drivers/net/enc28j60.c                      |   87 ++++++++++++------
 drivers/net/ibm_newemac/Kconfig             |    1 +
 drivers/net/netxen/netxen_nic.h             |   18 +----
 drivers/net/netxen/netxen_nic_ethtool.c     |    6 +-
 drivers/net/netxen/netxen_nic_hw.c          |  112 ++++++++++-------------
 drivers/net/netxen/netxen_nic_init.c        |   46 ++++-----
 drivers/net/netxen/netxen_nic_isr.c         |    4 +-
 drivers/net/netxen/netxen_nic_main.c        |  133 ++++++++------------------
 drivers/net/netxen/netxen_nic_niu.c         |   22 ++--
 drivers/net/sky2.c                          |    1 +
 drivers/net/tun.c                           |   15 +++
 drivers/net/wireless/b43/b43.h              |    1 -
 drivers/net/wireless/b43/dma.c              |   65 +++++++-------
 drivers/net/wireless/b43/main.c             |   16 ++-
 drivers/net/wireless/rt2x00/Kconfig         |   19 ++--
 drivers/net/wireless/rt2x00/rt2x00pci.c     |    3 +-
 drivers/net/wireless/rt2x00/rt2x00usb.c     |    6 +
 drivers/net/wireless/rt2x00/rt73usb.c       |    1 +
 drivers/ssb/main.c                          |   12 ++-
 include/linux/if_tunnel.h                   |    2 +-
 include/net/netfilter/nf_conntrack_extend.h |    1 +
 net/atm/br2684.c                            |   78 +++++++++-------
 net/core/dev.c                              |   34 +++++--
 net/ipv4/inet_connection_sock.c             |    6 +-
 net/ipv4/netfilter/nf_nat_core.c            |    3 +-
 net/ipv4/raw.c                              |    2 +-
 net/ipv4/tcp_ipv4.c                         |    4 -
 net/ipv4/xfrm4_mode_tunnel.c                |    2 +-
 net/ipv6/sit.c                              |   44 +++++----
 net/mac80211/tx.c                           |    4 +-
 net/mac80211/wext.c                         |    3 +-
 net/mac80211/wme.c                          |    2 +-
 net/netfilter/nf_conntrack_extend.c         |    9 ++-
 net/netfilter/nf_conntrack_h323_main.c      |   22 +++--
 net/netlink/genetlink.c                     |   15 +--
 net/sched/sch_htb.c                         |   23 +++--
 net/sctp/associola.c                        |   13 ++-
 net/sctp/protocol.c                         |   15 +++-
 net/unix/af_unix.c                          |   79 ++++++++++++++--
 43 files changed, 544 insertions(+), 437 deletions(-)
