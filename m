From: David Miller <davem@davemloft.net>
Subject: [GIT]: Networking
Date: Mon, 22 Jun 2009 02:42:14 -0700 (PDT)
Message-ID: <20090622.024214.139570425.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46145
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754023AbZFVJmK convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 22 Jun 2009 05:42:10 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


1) Last set of wireless updates from John Linville before he headed
   out to LinuxTAG in Berlin and the wireless summit there.

2) VIA Velocity bug fix from Dave Jones.  The length computed for
   DMA unmap accidently evaluated to a boolean, and thus "0" or "1" :-(

   Another bug caught thanks to the DMA API debugging layer.

3) PXA gadget bug fix for USBNET from David Brownell.

4) IUCV protocol error return fixes for sendmsg(), from Hendrik Brueckn=
er.

5) qla3xxx sleeps while atomic, during reset, fix from Jiri Slaby.

6) More whitelist IDs for CDC Ether from Jonas Sj=F6quist.

7) Fix endianness bugs in pegasus usb-net, from Michael Buesch.

8) NULL deref fix in routing cache when caching is disabled, from
   Neil Horman.  There is another fix coming for this code soon.

9) mv643xx_eth filter programming fix from Prabhanjan Sarnaik.

10) be2net bug fixes from Sathya Perla, and mlx4_en fixes from
    Yevgeny Petrilin.

11) ISDN documentation index mismerge fix from Tilman Schmidt.

I also anticipate some netfilter regression fixes from Patrick McHardy
soon.

Please pull thanks a lot!

The following changes since commit f234012f52a37e48f2330e1ca2df69800e79=
7c3b:
  Linus Torvalds (1):
        Merge branch 'for-linus' of git://git.kernel.org/.../drzeus/mmc

are available in the git repository at:

  master.kernel.org:/pub/scm/linux/kernel/git/davem/net-next-2.6.git ma=
ster

Alan Jenkins (4):
      rfkill: rfkill_set_block() when suspended nitpick
      rfkill: don't restore software blocked state on persistent device=
s
      eeepc-laptop: read rfkill soft-blocked state on resume
      rfkill: export persistent attribute in sysfs

Andrey Yurovsky (2):
      cfg80211: allow adding/deleting stations on mesh
      cfg80211: allow setting station parameters in mesh

Andy Gospodarek (1):
      e1000e: stop unnecessary polling when using msi-x

Dave Jones (1):
      via-velocity: Fix velocity driver unmapping incorrect size.

David Brownell (1):
      usbnet cdc_subset: fix issues talking to PXA gadgets

David S. Miller (1):
      Merge branch 'master' of git://git.kernel.org/.../linville/wirele=
ss-next-2.6

Dmitry Eremin-Solenikov (2):
      ieee802154: use standard routine for printing dumps
      MAINTAINERS: fix address of IEEE 802.15.4 git tree

=46lorian Westphal (1):
      r8169: remove unused variable

Gabor Juhos (2):
      ath9k: wait for beacon frame along with CAB
      ath9k: restore PS mode, before we put the chip into FULL SLEEP st=
ate.

Hendrik Brueckner (2):
      af_iucv: Change if condition in sendmsg() for more readability
      af_iucv: Return -EAGAIN if iucv msg limit is exceeded

Hin-Tak Leung (1):
      zd1211rw: adding 083a:e503 as a ZD1211B device

Jiri Slaby (2):
      ath5k: fix beacon_int handling
      Net: qla3xxx, remove sleeping in atomic

Joe Perches (1):
      MAINTAINERS: Fix Atheros pattern paths

Johannes Berg (1):
      cfg80211: validate station settings

Jonas Sj=F6quist (1):
      cdc_ether: additional PID's to the whitelist

Jouni Malinen (2):
      ath9k: Fix PCI FATAL interrupts by restoring RETRY_TIMEOUT disabl=
ing
      ath5k: avoid PCI FATAL interrupts by restoring RETRY_TIMEOUT disa=
bling

Michael Buesch (1):
      pegasus usb-net: Fix endianness bugs

Neil Horman (1):
      ipv4: fix NULL pointer + success return in route lookup path

Prabhanjan Sarnaik (1):
      mv643xx_eth: fix unicast filter programming in promiscuous mode

Sathya Perla (4):
      be2net: Add MCC queue mechanism for BE cmds
      be2net: Use MCC queue for cmds that may be called in BH context
      be2net: cleanup multicast_set cmd to avoid mc_list copy
      be2net: receive asynchronous link status notifications from BE

Tilman Schmidt (1):
      isdn: clean up documentation index

Troy Moure (1):
      acer-wmi: fix rfkill conversion

Yevgeny Petrilin (6):
      mlx4_en: Counting all the dropped packets on the TX side
      mlx4_en: Removed redundant skb->len check
      mlx4_en: using stop/start_all_queues
      mlx4_en: Cancel port_up check in transmit function
      mlx4_en: Removed redundant check on lso header size
      mlx4_en: Remove redundant refill code on RX

Zhu Yi (4):
      iwmc3200wifi: check for iwm_priv_init error
      iwmc3200wifi: add iwm_if_add and iwm_if_remove
      iwmc3200wifi: fix potential kernel oops on module removal
      iwmc3200wifi: add a mutex to protect iwm_reset_worker

 Documentation/isdn/00-INDEX                |   19 +--
 Documentation/rfkill.txt                   |    2 +
 MAINTAINERS                                |    8 +-
 drivers/net/benet/be.h                     |  102 ++++++---
 drivers/net/benet/be_cmds.c                |  368 ++++++++++++++++++++=
+-------
 drivers/net/benet/be_cmds.h                |   80 ++++++-
 drivers/net/benet/be_hw.h                  |    8 +-
 drivers/net/benet/be_main.c                |  299 ++++++++++++++------=
---
 drivers/net/e1000e/netdev.c                |    2 +-
 drivers/net/mlx4/en_netdev.c               |    8 +-
 drivers/net/mlx4/en_rx.c                   |   96 -------
 drivers/net/mlx4/en_tx.c                   |   29 +--
 drivers/net/mlx4/mlx4_en.h                 |    5 -
 drivers/net/mv643xx_eth.c                  |    7 +-
 drivers/net/qla3xxx.c                      |    2 +
 drivers/net/r8169.c                        |    3 -
 drivers/net/usb/Kconfig                    |    4 +-
 drivers/net/usb/cdc_ether.c                |   25 ++
 drivers/net/usb/cdc_subset.c               |    7 +-
 drivers/net/usb/pegasus.c                  |   29 ++-
 drivers/net/via-velocity.c                 |    2 +-
 drivers/net/wireless/ath/ath5k/base.c      |   11 +-
 drivers/net/wireless/ath/ath9k/main.c      |    2 +-
 drivers/net/wireless/ath/ath9k/pci.c       |   18 ++
 drivers/net/wireless/ath/ath9k/recv.c      |    7 +-
 drivers/net/wireless/iwmc3200wifi/iwm.h    |    4 +
 drivers/net/wireless/iwmc3200wifi/main.c   |   64 +++++-
 drivers/net/wireless/iwmc3200wifi/netdev.c |   49 +++--
 drivers/net/wireless/iwmc3200wifi/sdio.c   |   11 +-
 drivers/net/wireless/zd1211rw/zd_usb.c     |    1 +
 drivers/platform/x86/acer-wmi.c            |    4 +-
 drivers/platform/x86/eeepc-laptop.c        |   50 ++++-
 drivers/platform/x86/thinkpad_acpi.c       |   14 +-
 include/linux/rfkill.h                     |   33 ++-
 include/net/iucv/af_iucv.h                 |    2 -
 net/ieee802154/af_ieee802154.c             |   12 +-
 net/ipv4/route.c                           |   14 +-
 net/iucv/af_iucv.c                         |  297 ++++++++++++++------=
---
 net/rfkill/core.c                          |   56 +++--
 net/wireless/nl80211.c                     |   95 ++++++--
 40 files changed, 1213 insertions(+), 636 deletions(-)
