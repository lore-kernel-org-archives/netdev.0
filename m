From: David Miller <davem@davemloft.net>
Subject: [GIT]: Networking
Date: Mon, 10 Nov 2008 22:22:59 -0800 (PST)
Message-ID: <20081110.222259.261412751.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:56479
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751821AbYKKGW7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Nov 2008 01:22:59 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


1) Policy destroy on AF_KEY operations can BUG in some situations
   because we don't make sure the policy is marked dead first,
   fix from Alexey Dobriyan.

2) /proc/net/snmp reads can corrupt kernel memory.  Report and
   initial patch by Alexey Dobriyan, final patch from Eric
   Dumazet.

3) VLAN procfs output can overrun on-stack string buffer by
   one byte.  Fix from Ferenc Wagner

4) skb_recycle_check() can cause a BUG() due to incorrect ordering
   of skb->data update.  Fix from Lennert Buytenhek.

5) ip6_mr_init() error path destroys and releases in wrong order,
   fix from Benjamin Thery.

6) Two DSA layer fixes from Lennert Buytenhek, having to do with
   device promisc/allmulti handling, and setting of skb->pkt_type
   on receive.

7) I/O AT bug fixes from Maciej Sosnowski.

8) Fix empty sub-menu for CONFIG_SSB, from Mike Frysinger.

9) SSB doesn't build on non-PCI platforms, from Michael Buesch.

10) Several small device driver cures from Al Viro, Ben Hutchings,
    Jonathan McDowell, Paulius Zaleckas, and Yevgeny Petrilin.

Please pull, thanks a lot!

The following changes since commit 4bab0ea1d42dd1927af9df6fbf0003fc00617c50:
  Linus Torvalds (1):
        Merge git://git.kernel.org/.../davem/net-2.6

are available in the git repository at:

  master.kernel.org:/pub/scm/linux/kernel/git/davem/net-2.6.git master

Al Viro (1):
      el3_common_init() should be __devinit, not __init

Alexey Dobriyan (1):
      af_key: mark policy as dead before destroying

Ben Hutchings (1):
      sfc: Correct address of gPXE boot configuration in EEPROM

Benjamin Thery (1):
      ipv6: fix ip6_mr_init error path

Dan Williams (1):
      [4/4] dca: fixup initialization dependency

David S. Miller (1):
      Merge branch 'davem-fixes' of master.kernel.org:/.../jgarzik/netdev-2.6

Eric Dumazet (1):
      net: fix /proc/net/snmp as memory corruptor

Ferenc Wagner (1):
      vlan: Fix typos in proc output string

Harvey Harrison (1):
      netfilter: payload_len is be16, add size of struct rather than size of pointer

Jianjun Kong (1):
      mac80211: fix a buffer overrun in station debug code

Jonathan McDowell (1):
      [netdrvr] usb/hso: Cleanup rfkill error handling

Lennert Buytenhek (3):
      net: fix setting of skb->tail in skb_recycle_check()
      dsa: fix skb->pkt_type when mac address of slave interface differs
      dsa: fix master interface allmulti/promisc handling

Maciej Sosnowski (3):
      [1/4] I/OAT: fix channel resources free for not allocated channels
      [2/4] I/OAT: fix dma_pin_iovec_pages() error handling
      [3/4] I/OAT: fix async_tx.callback checking

Michael Buesch (1):
      ssb: Fix DMA-API compilation for non-PCI systems

Mike Frysinger (1):
      SSB: hide empty sub menu

Paulius Zaleckas (1):
      hso: rfkill type should be WWAN

Yevgeny Petrilin (1):
      mlx4_en: Start port error flow bug fix

 drivers/dca/dca-core.c          |    2 +-
 drivers/dma/ioat_dma.c          |   11 +++++-
 drivers/dma/iovlock.c           |   17 +++------
 drivers/net/mlx4/en_netdev.c    |    2 +-
 drivers/net/sfc/ethtool.c       |    4 +-
 drivers/net/usb/hso.c           |   12 ++++---
 drivers/ssb/Kconfig             |    5 ++-
 include/linux/ssb/ssb.h         |   42 +++++++++++++++++++----
 net/8021q/vlanproc.c            |    2 +-
 net/core/skbuff.c               |    2 +-
 net/dsa/slave.c                 |   72 +++++++++++++++++++++++++++++++++++++-
 net/dsa/tag_dsa.c               |    1 +
 net/dsa/tag_edsa.c              |    1 +
 net/dsa/tag_trailer.c           |    1 +
 net/ipv4/proc.c                 |   58 ++++++++++++++++---------------
 net/ipv6/ip6mr.c                |    9 +++--
 net/key/af_key.c                |    1 +
 net/mac80211/debugfs_sta.c      |    2 +-
 net/netfilter/ipvs/ip_vs_xmit.c |    3 +-
 19 files changed, 178 insertions(+), 69 deletions(-)
