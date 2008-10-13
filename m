From: David Miller <davem@davemloft.net>
Subject: [GIT]: Networking
Date: Mon, 13 Oct 2008 00:03:25 -0700 (PDT)
Message-ID: <20081013.000325.205907850.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60501
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753202AbYJMHDt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Oct 2008 03:03:49 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Almost entirely fixes of one sort or another, plus some
new chipset IDs for smc network driver:

1) ACPI_TOSHIBA randconfig build failure fix

2) Compilation and namespace fixes from Adrian Bunk for cases
   resulting from the phylib changes in the 2.6.28 net merge.

3) Dimitris Michailidis noticed and off-by-one bug in the error
   path of skb_dma_map()

4) Include touchups (remove dups and remove unnecessary version.h usage)
   from Huang Weiyi.

5) mac80211 wireless build fix from Ingo Molnar

6) r8169 NULL deref regression fix from Petr Vandrovec

7) SKY2 wake-on-lan regression fix from Rafael J. Wysocki, this one
   goes back to 2.6.26 it seems

Please pull, thanks a lot!

The following changes since commit f3073ac76755abd63b1d4c3d145f4c15b65b5355:
  Guennadi Liakhovetski (1):
        smc911x: Fix external PHY detection

are available in the git repository at:

  master.kernel.org:/pub/scm/linux/kernel/git/davem/net-2.6.git master

Adrian Bunk (3):
      net/tc35815.c: fix compilation
      net/au1000_eth.c MDIO namespace fixes
      net/bfin_mac.c MDIO namespace fixes

David S. Miller (1):
      acpi: Make ACPI_TOSHIBA depend on INPUT.

Dimitris Michailidis (1):
      net: Fix off-by-one in skb_dma_map

Guennadi Liakhovetski (1):
      smc911x: Add support for LAN921{5,7,8} chips from SMSC

Huang Weiyi (4):
      wireless: remove duplicated #include
      qlge: remove duplicated #include
      netfilter: remove unused #include <version.h>
      jme: remove unused #include <version.h>

Ingo Molnar (1):
      net/mac80211/rx.c: fix build error

Petr Vandrovec (1):
      r8169: NULL pointer dereference on r8169 load

Rafael J. Wysocki (1):
      sky2: Fix WOL regression

 drivers/acpi/Kconfig            |    2 +-
 drivers/net/au1000_eth.c        |   27 ++++++++++++++-------------
 drivers/net/bfin_mac.c          |   26 +++++++++++++-------------
 drivers/net/jme.c               |    1 -
 drivers/net/qlge/qlge_ethtool.c |    1 -
 drivers/net/qlge/qlge_main.c    |    1 -
 drivers/net/r8169.c             |    3 ++-
 drivers/net/sky2.c              |   19 +++++--------------
 drivers/net/smc911x.c           |    6 ++++--
 drivers/net/smc911x.h           |   14 ++++++++++----
 drivers/net/tc35815.c           |    2 +-
 net/core/skb_dma_map.c          |    2 +-
 net/mac80211/rx.c               |    5 ++++-
 net/netfilter/nf_tproxy_core.c  |    1 -
 net/wireless/core.c             |    1 -
 15 files changed, 55 insertions(+), 56 deletions(-)
