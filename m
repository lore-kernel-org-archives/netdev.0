From: David Miller <davem@davemloft.net>
Subject: [GIT]: Networking
Date: Sun, 15 Mar 2009 20:56:31 -0700 (PDT)
Message-ID: <20090315.205631.219535931.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:34338
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751690AbZCPD4p convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 15 Mar 2009 23:56:45 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Almost all driver stuff, as usually is the case at this point.

1) Two new drivers, for Dave DNET and be2net ethernet controllers.

2) Missing second part of ASPM L0 IGB fix, from Alexander Duyck.
   The first part went in via the PCI tree already.

3) BUG fix when ipv6 module is unloaded, missing check on disabled
   module option.  From John Dykstra.

4) r8169 fixes from fran=E7ois romieu.

5) IBM EMAC bug fix from Benjamin Herrenschmidt.

6) Fix regression in IPSEC xfrm_state lookups wrt. wildcard source
   addresses.

7) QLGE bug fixes from Ron Mercer.

8) unicast filtering fixes in IXGBE and MV643XX_ETH.

Please pull, thanks a lot.

The following changes since commit 326d8519fc97be186c55ac605c3a7c957c75=
8ae1:
  Linus Torvalds (1):
        Merge branch 'upstream' of git://ftp.linux-mips.org/pub/scm/ups=
tream-linus

are available in the git repository at:

  master.kernel.org:/pub/scm/linux/kernel/git/davem/net-2.6.git master

Alexander Duyck (1):
      igb: remove ASPM L0s workaround

Benjamin Herrenschmidt (1):
      emac: Fix clock control for 405EX and 405EXr chips

Chris Leech (1):
      ixgbe: fix multiple unicast address support

Dave Jones (1):
      via-velocity: Fix DMA mapping length errors on transmit.

David S. Miller (2):
      dnet: Fix warnings on 64-bit.
      xfrm: Fix xfrm_state_find() wrt. wildcard source address.

Dhananjay Phadke (1):
      netxen: remove old flash check.

Eilon Greenstein (3):
      bnx2x: Adding restriction on sge_buf_size
      bnx2x: Casting page alignment
      bnx2x: Using DMAE to initialize the chip

Ilya Yanok (2):
      dnet: Dave DNET ethernet controller driver (updated)
      dnet: replace obsolete *netif_rx_* functions with *napi_*

John Dykstra (1):
      ipv6:  Fix BUG when disabled ipv6 module is unloaded

Lennert Buytenhek (1):
      mv643xx_eth: fix unicast address filter corruption on mtu change

Ron Mercer (4):
      qlge: bugfix: Increase filter on inbound csum.
      qlge: bugfix: Tell hw to strip vlan header.
      qlge: bugfix: Move netif_napi_del() to common call point.
      qlge: bugfix: Pad outbound frames smaller than 60 bytes.

Sathya Perla (1):
      net: Add be2net driver.

fran=E7ois romieu (2):
      r8169: use hardware auto-padding.
      r8169: revert "r8169: read MAC address from EEPROM on init (2nd a=
ttempt)"

 MAINTAINERS                          |    9 +
 drivers/net/Kconfig                  |   13 +
 drivers/net/Makefile                 |    2 +
 drivers/net/benet/Kconfig            |    7 +
 drivers/net/benet/Makefile           |    7 +
 drivers/net/benet/be.h               |  327 ++++++
 drivers/net/benet/be_cmds.c          |  861 +++++++++++++++
 drivers/net/benet/be_cmds.h          |  688 ++++++++++++
 drivers/net/benet/be_ethtool.c       |  362 +++++++
 drivers/net/benet/be_hw.h            |  211 ++++
 drivers/net/benet/be_main.c          | 1903 ++++++++++++++++++++++++++=
++++++++
 drivers/net/bnx2x.h                  |    2 +-
 drivers/net/bnx2x_init.h             |    4 -
 drivers/net/bnx2x_main.c             |   21 +-
 drivers/net/dnet.c                   |  994 ++++++++++++++++++
 drivers/net/dnet.h                   |  225 ++++
 drivers/net/ibm_newemac/core.c       |    3 +
 drivers/net/igb/igb_main.c           |   26 +-
 drivers/net/ixgbe/ixgbe_main.c       |    1 +
 drivers/net/mv643xx_eth.c            |   10 +-
 drivers/net/netxen/netxen_nic.h      |    1 -
 drivers/net/netxen/netxen_nic_hw.c   |   22 -
 drivers/net/netxen/netxen_nic_main.c |    3 -
 drivers/net/qlge/qlge.h              |    1 +
 drivers/net/qlge/qlge_main.c         |   57 +-
 drivers/net/r8169.c                  |  122 +---
 drivers/net/via-velocity.c           |   15 +-
 net/ipv6/af_inet6.c                  |    3 +
 net/xfrm/xfrm_state.c                |   90 +-
 29 files changed, 5741 insertions(+), 249 deletions(-)
 create mode 100644 drivers/net/benet/Kconfig
 create mode 100644 drivers/net/benet/Makefile
 create mode 100644 drivers/net/benet/be.h
 create mode 100644 drivers/net/benet/be_cmds.c
 create mode 100644 drivers/net/benet/be_cmds.h
 create mode 100644 drivers/net/benet/be_ethtool.c
 create mode 100644 drivers/net/benet/be_hw.h
 create mode 100644 drivers/net/benet/be_main.c
 create mode 100644 drivers/net/dnet.c
 create mode 100644 drivers/net/dnet.h
