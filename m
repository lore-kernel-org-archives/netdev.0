From: David Miller <davem@davemloft.net>
Subject: [GIT]: Networking
Date: Wed, 29 Oct 2008 13:19:46 -0700 (PDT)
Message-ID: <20081029.131946.174652987.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42668
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753725AbYJ2UUM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Oct 2008 16:20:12 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Wired and wireless driver bug fixes via Jeff Garzik
and John Linville.

Highlights:

1) amd8111e NAPI ->poll() handler processes incorrectly the case where
   there are exactly "quota" RX packets available in the ring,
   resulting in a crash.

   Fix from Chris Friesen

2) Fix resume bustage in ath5k, from Elias Oltmanns

3) ibm_newemac checks typo'd CONFIG_FOO option, fix from
   Josh Boyer

4) pktgen checks multiqueue limits using off-by-one test,
   fix from Jesse Brandeburg.

Please pull, thanks a lot!

The following changes since commit 8b5f12d04b2e93842f3dda01f029842047bf3f81:
  Florian Westphal (1):
        syncookies: fix inclusion of tcp options in syn-ack

are available in the git repository at:

  master.kernel.org:/pub/scm/linux/kernel/git/davem/net-2.6.git master

Chris Friesen (1):
      amd8111e: Fix rx return code

Christian Lamparter (2):
      p54: fix misbehavings when firmware can't be found
      p54: fix build warnings

David S. Miller (1):
      Merge branch 'davem-fixes' of master.kernel.org:/.../jgarzik/netdev-2.6

Dmitry Baryshkov (1):
      RFKILL: fix input layer initialisation

Elias Oltmanns (1):
      ath5k: Reset key cache on interface up, thus fixing resume

FUJITA Tomonori (1):
      dmfe: check pci_alloc_consistent errors

Frank Blaschka (2):
      qeth: fix offset error in non prealloc header path
      qeth: remove unnecessary support ckeck in sysfs route6

Huang Weiyi (1):
      mlx4_en: remove duplicated #include

Jeff Garzik (1):
      drivers/net/wan/syncppp: Fix unused-var warnings

Jesse Brandeburg (1):
      pktgen: fix multiple queue warning

John W. Linville (1):
      mac80211: correct warnings in minstrel rate control algorithm

Josh Boyer (1):
      ibm_newemac: Fix typo in flow control config option

Peter Korsgaard (1):
      dm9601: runtime mac address change support

Randy Dunlap (1):
      mac80211.h: fix kernel-doc excesses

Sven Hartge (1):
      via-velocity: use driver string instead of dev->name before register_netdev()

Thomas Klein (1):
      ehea: Detect 16GB hugepages for firmware restriction

Ursula Braun (2):
      qeth: remove non-recover-thread checkings
      qeth: avoid skb_under_panic for malformatted inbound data

Yevgeny Petrilin (1):
      mlx4: Setting the correct offset for default mac address

 drivers/net/amd8111e.c                  |   14 ++--
 drivers/net/ehea/ehea.h                 |    2 +-
 drivers/net/ehea/ehea_qmr.c             |   57 ++++++++++++-
 drivers/net/ehea/ehea_qmr.h             |    3 +
 drivers/net/ibm_newemac/core.c          |    2 +-
 drivers/net/mlx4/en_main.c              |    1 -
 drivers/net/mlx4/fw.c                   |    2 +-
 drivers/net/tulip/dmfe.c                |   12 +++-
 drivers/net/usb/dm9601.c                |   15 ++++
 drivers/net/via-velocity.c              |   11 ++-
 drivers/net/wan/syncppp.c               |    5 +-
 drivers/net/wireless/ath5k/base.c       |   33 +++-----
 drivers/net/wireless/p54/p54common.c    |    5 +-
 drivers/net/wireless/p54/p54pci.c       |  132 +++++++++++++++---------------
 drivers/s390/net/qeth_core_main.c       |    3 +-
 drivers/s390/net/qeth_l2_main.c         |   27 ++----
 drivers/s390/net/qeth_l3_main.c         |   13 +---
 drivers/s390/net/qeth_l3_sys.c          |    7 --
 include/net/mac80211.h                  |   11 +--
 net/core/pktgen.c                       |   27 +++---
 net/mac80211/rc80211_minstrel_debugfs.c |    6 +-
 net/rfkill/rfkill-input.c               |    5 +
 22 files changed, 220 insertions(+), 173 deletions(-)
