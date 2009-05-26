From: David Miller <davem@davemloft.net>
Subject: [GIT]: Networking
Date: Mon, 25 May 2009 23:48:08 -0700 (PDT)
Message-ID: <20090525.234808.75798415.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42395
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752757AbZEZGsJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 May 2009 02:48:09 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


The FIB trie crash and the routing cache leak were the two most
series regressions I was still aware of in 2.6.30  Those, amongst
others, are cured here.

1) FIB trie crashes with preempt-rcu due to missing preempt_disable()
   section, fix from Robert Olsson.

2) rxrpc_alloc_connection() return is a NULL or non-NULL pointer not
   PTR_ERR, fix from Dan Carpenter.

3) Routing cache leak regression makes net devices unremovable, two
   part fix from Eric Dumazet.

4) Fix losing interrupts, wedging the device, on r8169.  From David
   Dillow.

5) Wrong index used for ->flows[] in pktgen, resulting in out-of-range
   access and/or the wrong value used.  Fix from Florian Westphal.

6) Bug in net_device_ops conversion of mac8390 made it stop working,
   fix from Finn Thain.

7) TCP vegas adjusts ssthresh improperly, fix from Doug Leith.

8) If the wimax/i2400m USB device is not idle reset can completely
   bork the device on autosuspend.  Fix from Inaky Perez-Gonzalez.

9) Internally created kernel routes need RTPROT_KERNEL set in the
   protocol field.  IPV4 does this right, and IPV6 was half doing it
   right, this corrects all cases so that routing daemons do not get
   confused.  Fix from Jean-Mickael Guerin.

10) Missing buffer length verification for SIOCSIWENCODEEXT, fix from
    Johannes Berg.

11) Two accesses beyond ARRAY_SIZE, in wireless and ISDN gigaset, from
    Roel Kluin.

12) Really fix AIRO driver buffer overflow in airo_get_encode{,ext}().

Please pull, thanks a lot!

The following changes since commit 5805977e63a36ad56594a623f3bd2bebcb7db233:
  Linus Torvalds (1):
        Merge branch 'for-linus' of git://git.kernel.org/.../jbarnes/drm-2.6

are available in the git repository at:

  master.kernel.org:/pub/scm/linux/kernel/git/davem/net-2.6.git master

Dan Carpenter (1):
      RxRPC: Error handling for rxrpc_alloc_connection()

David Dillow (1):
      r8169: avoid losing MSI interrupts

David S. Miller (2):
      Merge branch 'master' of git://git.kernel.org/.../linville/wireless-2.6
      Merge branch 'linux-2.6.30.y' of git://git.kernel.org/.../inaky/wimax

Doug Leith (1):
      tcp: tcp_vegas ssthresh bugfix

Eric Dumazet (2):
      net: fix length computation in rt_check_expire()
      net: fix rtable leak in net/ipv4/route.c

Fabio Rossi (1):
      ath5k: fix interpolation with equal power levels

Finn Thain (1):
      mac8390: fix regression caused during net_device_ops conversion

Florian Westphal (1):
      pktgen: do not access flows[] beyond its length

Forrest Zhang (1):
      ath5k: fix exp off-by-one when computing OFDM delta slope

Inaky Perez-Gonzalez (1):
      wimax/i2400m: usb: fix device reset on autosuspend while not yet idle

Jay Sternberg (1):
      iwlwifi: update 5000 ucode support to version 2 of API

Jean-Mickael Guerin (1):
      IPv6: set RTPROT_KERNEL to initial route

Johannes Berg (1):
      wext: verify buffer size for SIOCSIWENCODEEXT

John W. Linville (1):
      airo: fix airo_get_encode{,ext} buffer overflow like I mean it...

Lennert Buytenhek (1):
      gianfar: fix BUG under load after introduction of skb recycling

Luis R. Rodriguez (1):
      cfg80211: fix race between core hint and driver's custom apply

Pavel Roskin (1):
      ath5k: fix scanning in AR2424

Reinette Chatre (1):
      iwlwifi: do not cancel delayed work inside spin_lock_irqsave

Robert Olsson (1):
      ipv4: Fix oops with FIB_TRIE

Roel Kluin (2):
      wireless: beyond ARRAY_SIZE of intf->crypto_stats
      gigaset: beyond ARRAY_SIZE of iwb->data

 drivers/isdn/gigaset/isocdata.c             |    2 +-
 drivers/net/Makefile                        |    2 +-
 drivers/net/gianfar.c                       |   11 +++-
 drivers/net/mac8390.c                       |   10 ++--
 drivers/net/r8169.c                         |  102 +++++++++++++++------------
 drivers/net/wimax/i2400m/usb.c              |   35 ++++++++--
 drivers/net/wireless/airo.c                 |   23 ++++---
 drivers/net/wireless/ath5k/phy.c            |   49 +++++++------
 drivers/net/wireless/ath5k/reset.c          |    8 +-
 drivers/net/wireless/iwlwifi/iwl-5000.c     |    2 +-
 drivers/net/wireless/iwlwifi/iwl-agn.c      |    7 --
 drivers/net/wireless/iwlwifi/iwl-scan.c     |    7 +-
 drivers/net/wireless/iwlwifi/iwl3945-base.c |    9 +--
 drivers/net/wireless/rt2x00/rt2x00debug.c   |    2 +-
 net/core/pktgen.c                           |    2 +-
 net/ipv4/fib_trie.c                         |    6 ++-
 net/ipv4/route.c                            |   60 +++++-----------
 net/ipv4/tcp_vegas.c                        |   11 +++-
 net/ipv6/route.c                            |    3 +
 net/rxrpc/ar-connection.c                   |   12 ++--
 net/wireless/reg.c                          |    7 ++
 net/wireless/wext.c                         |    7 ++
 22 files changed, 216 insertions(+), 161 deletions(-)
