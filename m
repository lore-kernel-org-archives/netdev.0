From: David Miller <davem@davemloft.net>
Subject: [GIT]: Networking
Date: Tue, 30 Jun 2009 21:39:27 -0700 (PDT)
Message-ID: <20090630.213927.180401151.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43819
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751278AbZGAEjW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Jul 2009 00:39:22 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


1) Revert ARP windows IP conflict verification support, it breaks
   things, from Eric W. Biederman.

2) SCTP unintentionally broken by routing changes, fix from
   Wei Yongjun.

3) XFRM layer code does xfrm_addr_cmp() by hand, leading to
   code duplication and the usual assortment of cut&paste
   bugs.  Also from Wei Yongjun.

4) Netfilter fixes from Patrick McHardy, Jaswinder Singh Rajput,
   Jan Engelhardt, and Jesper Dangaard Brouer.

5) bnx2x driver has same link reporting bug as bnx2 driver, from
   Naohiro Ooiwa.

6) More fib_trie rebalancing fixes from Jarek Poplawski.

7) usbnet was converted to use netdev->stats to record stats
   instead of using a private copy.  Unfortunately, there are
   a bunch of sub-drivers that code share with usbnet, and those
   did not get converted so stats got lost.  Fixed by Herbert Xu.

8) Fixes for the new ieee802154 stack from Dmitry Eremin-Solenikov.

9) Non-TSO packets can become TSO ones and vice versa, which is
   illegal and results in packets which have an illegal state.
   Fixes from Herbert Xu.

10) bfin_sir doesn't compile, missed net_device_ops conversion.
    Fix from Graf Yang.

11) Intel ethernet driver fixes from J. Kirsher and the rest of
    the Intel driver team.  In particular, more bugs caught by
    the DMA mapping API debugging layer.

Please pull, thanks a lot.

The following changes since commit 52989765629e7d182b4f146050ebba0abf2cb0b7:
  Linus Torvalds (1):
        Merge git://git.kernel.org/.../davem/net-2.6

are available in the git repository at:

  master.kernel.org:/pub/scm/linux/kernel/git/davem/net-2.6.git master

Alexander Duyck (1):
      igb: return PCI_ERS_RESULT_DISCONNECT on permanent error

Andre Detsch (1):
      e1000: return PCI_ERS_RESULT_DISCONNECT on permanent error

David S. Miller (2):
      Merge branch 'master' of git://git.kernel.org/.../kaber/nf-2.6
      Merge branch 'for-linus' of git://git.kernel.org/.../lowpan/lowpan

Dmitry Eremin-Solenikov (3):
      MAINTAINERS: ieee802154 lists are moderated for non-subscribers.
      nl802154: fix Oops in ieee802154_nl_get_dev
      nl802154: add module license and description

Don Skidmore (1):
      ixgbe: Fix SFP log messages

Eric W. Biederman (1):
      Revert "ipv4: arp announce, arp_proxy and windows ip conflict verification"

Graf Yang (1):
      net/irda: convert bfin_sir to net_device_ops

Herbert Xu (9):
      tcp: Stop non-TSO packets morphing into TSO
      tcp: Do not tack on TSO data to non-TSO packet
      cdc_eem: Use netdev stats structure
      dm9601: Use netdev stats structure
      net1080: Use netdev stats structure
      rndis_host: Use netdev stats structure
      smsc95xx: Use netdev stats structure
      usbnet: Use netdev stats structure
      usbnet: Remove private stats structure

Jan Engelhardt (1):
      netfilter: xtables: conntrack match revision 2

Jarek Poplawski (1):
      ipv4: Fix fib_trie rebalancing, part 3

Jaswinder Singh Rajput (1):
      netfilter: headers_check fix: linux/netfilter/xt_osf.h

Jesper Dangaard Brouer (1):
      nf_conntrack: Use rcu_barrier()

Jesse Brandeburg (3):
      ixgbe: fix unmap length bug
      igb: fix unmap length bug
      e1000: fix unmap bug

Mallikarjuna R Chilakala (2):
      ixgbe: Fix device capabilities of 82599 single speed fiber NICs.
      ixgbe: Fix link capabilities during adapter resets

Mike Mason (1):
      e1000e: io_error_detected callback should return PCI_ERS_RESULT_DISCONNECT

Naohiro Ooiwa (1):
      bnx2x: Fix the behavior of ethtool when ONBOOT=no

Patrick McHardy (1):
      netfilter: tcp conntrack: fix unacknowledged data detection with NAT

Wei Yongjun (2):
      xfrm: use xfrm_addr_cmp() instead of compare addresses directly
      sctp: xmit sctp packet always return no route error

 MAINTAINERS                            |    2 +-
 drivers/net/bnx2x_main.c               |   10 ++++-
 drivers/net/e1000/e1000_main.c         |   11 +++++-
 drivers/net/e1000e/netdev.c            |    3 +
 drivers/net/igb/igb_main.c             |   14 ++++--
 drivers/net/irda/bfin_sir.c            |   16 +++++---
 drivers/net/ixgbe/ixgbe_ethtool.c      |    5 +-
 drivers/net/ixgbe/ixgbe_main.c         |   45 ++++++++++++++-------
 drivers/net/usb/cdc_eem.c              |    2 +-
 drivers/net/usb/dm9601.c               |   10 ++--
 drivers/net/usb/net1080.c              |   12 +++---
 drivers/net/usb/rndis_host.c           |    2 +-
 drivers/net/usb/smsc95xx.c             |   10 ++--
 drivers/net/usb/usbnet.c               |   30 +++++++-------
 include/linux/netfilter/xt_conntrack.h |   13 ++++++
 include/linux/netfilter/xt_osf.h       |    2 +
 include/linux/usb/usbnet.h             |    1 -
 include/net/netfilter/nf_conntrack.h   |    4 +-
 net/ieee802154/netlink.c               |    6 +++
 net/ipv4/arp.c                         |    7 +--
 net/ipv4/fib_trie.c                    |    3 +
 net/ipv4/netfilter/nf_nat_helper.c     |   17 +++++---
 net/ipv4/tcp.c                         |   15 +++++--
 net/ipv4/tcp_output.c                  |    3 +-
 net/netfilter/nf_conntrack_expect.c    |    4 +-
 net/netfilter/nf_conntrack_extend.c    |    2 +-
 net/netfilter/nf_conntrack_proto_tcp.c |    6 +-
 net/netfilter/xt_conntrack.c           |   66 +++++++++++++++++++++++++++++---
 net/sctp/output.c                      |    2 +-
 net/xfrm/xfrm_state.c                  |   57 ++++-----------------------
 30 files changed, 235 insertions(+), 145 deletions(-)
