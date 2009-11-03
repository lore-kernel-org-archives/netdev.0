From: David Miller <davem@davemloft.net>
Subject: [GIT]: Networking
Date: Tue, 03 Nov 2009 00:20:46 -0800 (PST)
Message-ID: <20091103.002046.169494858.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37857
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751208AbZKCIUW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Nov 2009 03:20:22 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


1) E100 regresion results in 10 second boot delay, fixed by Bruce Allen.

2) GRE tunnel clobbers tunnel MAC address erroneously, fix from Herbert Xu

3) Wireless fixes via John Linville including a fix for the resume
   OOPS by Johannes Berg.

4) sk_forward_alloc can get corrupted on sunrpc UDP sockets due to
   missed socket locking, causing NFS crashes, fix from Eric Dumazet.

5) R8169 crops the limit on RX frame size 1 byte too drastically,
   breaking VLANs, fix from Raimonds Cicans.

6) Reverse path filter in ipv4 must properly abide by policy routing
   by specifying the mark in the route lookup, fix from Jamal Hadi Salim.

7) IBMTR can access past string message array boundaries, fix from
   Roel Kluin.

8) sky2 starts with wrong initial carrier state, fix from Brandon Philips.

Please pull, thanks a lot!

The following changes since commit 1836d95928a0f41ada0cbb2a6c4e46b027db9491:
  Linus Torvalds (1):
        Merge branch 'for-linus' of git://git.kernel.org/.../ericvh/v9fs

are available in the git repository at:

  master.kernel.org:/pub/scm/linux/kernel/git/davem/net-2.6.git master

Brandon Philips (1):
      sky2: set carrier off in probe

Bruce Allan (3):
      e100: e100_phy_init() isolates selected PHY, causes 10 second boot delay
      e1000e: config PHY via software after resets
      e1000e: rework disable K1 at 1000Mbps for 82577/82578

David S. Miller (1):
      Merge branch 'master' of git://git.kernel.org/.../linville/wireless-2.6

David Woodhouse (1):
      libertas if_usb: Fix crash on 64-bit machines

Eric Dumazet (2):
      net: fix kmemcheck annotations
      net: fix sk_forward_alloc corruption

Herbert Xu (1):
      gre: Fix dev_addr clobbering for gretap

Johannes Berg (5):
      mac80211: fix BSS leak
      mac80211: fix addba timer
      mac80211: fix reason code output endianness
      cfg80211: fix NULL ptr deref
      mac80211: check interface is down before type change

Ken Kawasaki (1):
      pcnet_cs: add cis of PreMax PE-200 ethernet pcmcia card

Luis R. Rodriguez (1):
      ath9k: fix misplaced semicolon on rate control

Michael Buesch (1):
      b43: Fix DMA TX bounce buffer copying

Raimonds Cicans (1):
      r8169: Fix card drop incoming VLAN tagged MTU byte large jumbo frames

Xose Vazquez Perez (1):
      rt73usb.c : more ids

Zhu Yi (1):
      ipw2200: fix oops on missing firmware

jamal (1):
      net: Fix RPF to work with policy routing

roel kluin (1):
      ibmtr: possible Read buffer overflow?

 drivers/net/e100.c                           |   26 +-
 drivers/net/e1000e/defines.h                 |    2 +
 drivers/net/e1000e/e1000.h                   |   14 +
 drivers/net/e1000e/hw.h                      |    1 +
 drivers/net/e1000e/ich8lan.c                 |  482 +++++++++++++++++++++-----
 drivers/net/e1000e/phy.c                     |   15 +-
 drivers/net/pcmcia/pcnet_cs.c                |    2 +-
 drivers/net/r8169.c                          |    2 +-
 drivers/net/sky2.c                           |    2 +
 drivers/net/tokenring/ibmtr.c                |   11 +-
 drivers/net/wireless/ath/ath9k/rc.c          |    2 +-
 drivers/net/wireless/b43/dma.c               |   15 +-
 drivers/net/wireless/ipw2x00/ipw2100.c       |    5 +-
 drivers/net/wireless/ipw2x00/ipw2200.c       |    2 +
 drivers/net/wireless/ipw2x00/libipw.h        |    1 +
 drivers/net/wireless/ipw2x00/libipw_module.c |   14 +-
 drivers/net/wireless/libertas/if_usb.c       |    2 +-
 drivers/net/wireless/rt2x00/rt73usb.c        |    5 +
 drivers/serial/serial_cs.c                   |    8 +-
 firmware/Makefile                            |    6 +-
 firmware/WHENCE                              |    4 +
 firmware/cis/PE-200.cis.ihex                 |    9 +
 firmware/cis/SW_555_SER.cis.ihex             |   12 +
 firmware/cis/SW_7xx_SER.cis.ihex             |   13 +
 firmware/cis/SW_8xx_SER.cis.ihex             |   13 +
 include/linux/skbuff.h                       |    6 +-
 include/net/ip_fib.h                         |    3 +-
 net/core/datagram.c                          |   10 +-
 net/ipv4/fib_frontend.c                      |    5 +-
 net/ipv4/ip_gre.c                            |   28 +-
 net/ipv4/route.c                             |    8 +-
 net/ipv4/udp.c                               |    4 +-
 net/ipv6/udp.c                               |    4 +-
 net/mac80211/agg-tx.c                        |   19 +-
 net/mac80211/cfg.c                           |    6 +-
 net/mac80211/ht.c                            |    2 +-
 net/mac80211/ibss.c                          |    6 +-
 net/sunrpc/svcsock.c                         |   10 +-
 net/wireless/sme.c                           |    7 +-
 39 files changed, 606 insertions(+), 180 deletions(-)
 create mode 100644 firmware/cis/PE-200.cis.ihex
 create mode 100644 firmware/cis/SW_555_SER.cis.ihex
 create mode 100644 firmware/cis/SW_7xx_SER.cis.ihex
 create mode 100644 firmware/cis/SW_8xx_SER.cis.ihex
