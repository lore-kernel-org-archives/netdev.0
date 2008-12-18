From: David Miller <davem@davemloft.net>
Subject: [GIT]: Networking
Date: Wed, 17 Dec 2008 20:13:24 -0800 (PST)
Message-ID: <20081217.201324.216972839.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59259
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751009AbYLRENW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Dec 2008 23:13:22 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Several small fixes:

1) BNX2 driver DMA unmapping uses wrong loop index.  Fix from
   Michael Chan.

2) Two TLAN bug fixes from Sakari Ailus.  First, when we send a
   smaller than 64 byte packet, we must use a 64-byte length
   in the descriptor length as well as pad the packet out.  Second,
   DMA unmapping wasn't using the correct length either.

3) Netfilter fix from Pablo Neira Ayuso for conntrack netlink
   attribute parsing.

4) MDIO layer registry sets the state too early, so that if
   some middle operation fails and we try to unwind the
   state we crash.  Fix from Krzysztof Halasa.

5) Temporary fix for IRDA, dealing with incompatible skb->cb[]
   usage between IRDA device layer and the generic networking
   packet scheduler.  This will have a better fix in future
   releases, but this gets things working in a simple way for
   now.  From Samuel Ortiz.

6) JME driver header has a CPP test typo, from Wei-Min Chen.

7) ENC28J60 driver should use netif_rx_ni() instead of netif_rx()
   because it does packet reception outside of interrupt context.
   Fix from Baruch Siach.

8) If the starfire driver processes exactly 'quota' number of
   RX packets, it returns the wrong state back to the generic
   NAPI polling layer of the networking and we crash.  Fix from
   Jarek Poplawski.

Please pull, thanks a lot!

The following changes since commit a3dd15444baa9c7522c8457ab564c41219dfb44c:
  Linus Torvalds (1):
        Merge master.kernel.org:/home/rmk/linux-2.6-arm

are available in the git repository at:

  master.kernel.org:/pub/scm/linux/kernel/git/davem/net-2.6.git master

Baruch Siach (1):
      enc28j60: use netif_rx_ni() to deliver RX packets

Jarek Poplawski (1):
      drivers/net: starfire: Fix napi ->poll() weight handling

Krzysztof Halasa (1):
      net: kernel BUG at drivers/net/phy/mdio_bus.c:165!

Michael Chan (1):
      bnx2: Fix bug in bnx2_free_rx_mem().

Pablo Neira Ayuso (1):
      netfilter: ctnetlink: fix missing CTA_NAT_SEQ_UNSPEC

Sakari Ailus (2):
      tlan: Fix small (< 64 bytes) datagram transmissions
      tlan: Fix pci memory unmapping

Samuel Ortiz (1):
      irda: Add irda_skb_cb qdisc related padding

cwm97m (1):
      jme: Fixed a typo

 drivers/net/bnx2.c                            |    6 +++---
 drivers/net/enc28j60.c                        |    2 +-
 drivers/net/jme.h                             |    2 +-
 drivers/net/phy/mdio_bus.c                    |    5 +++--
 drivers/net/starfire.c                        |    5 +++++
 drivers/net/tlan.c                            |   23 +++++++++++++++--------
 include/linux/netfilter/nfnetlink_conntrack.h |    1 +
 include/net/irda/irda_device.h                |    4 +++-
 8 files changed, 32 insertions(+), 16 deletions(-)
