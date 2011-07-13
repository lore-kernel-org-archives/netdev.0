From: David Miller <davem@davemloft.net>
Subject: [GIT] Networking
Date: Wed, 13 Jul 2011 12:31:08 -0700 (PDT)
Message-ID: <20110713.123108.129467621253660515.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=euc-kr
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:55525 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750745Ab1GMTbP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Jul 2011 15:31:15 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


1) SLIP config ifdefs surround wrong bits of code, fix from
   Matvejchikov Ilya.

2) Natsemi does DMA unmaps using wrong length, fix from Jim Cromie.

3) Two SCTP fixes from Thomas Graf.  Do not deadlock on graceful
   shutdown when data chunks exist in the retransmit queue.  Also,
   if behave like TCP if receiver closes with data still queued up
   on receive by emitting an ABORT.

4) Fix use after free in HSO driver, from Octavian Purdila.

5) Natsemi module parms permissions are busted, from Jean Delvare.

6) Fix memory leak in XFRM state code, from Tushar Gohad.

7) Fix vulnerability in mac80211 TKIP replay handling, from Johannes
   Berg.

8) Several bluetooth fixes:
	Buffer overflow in l2cap from Dan Rosenberg
	HIDP disconnect deadlocks from Peter Hurley
	Incoming L2CAP regression fix from Gustavo F. Padovan
	Memory leak in hci_conn from Tomas Targownik

9) ath5k driver stores "ieee80211_hw" pointer in drvdata but then
   tries to use it as a "ath5k_softc" pointer, fix from Pavel roskin.

10) Fix deadlock in rfkill/sched_scan code of cfg80211 by using a new
    mutex, fix from Luciano Coelho.

Please pull, thanks a lot!

The following changes since commit 8d86e5f91440aa56a5df516bf58fe3883552=
ad56:

  Merge branch 'merge' of git://git.kernel.org/pub/scm/linux/kernel/git=
/benh/powerpc (2011-07-12 14:21:19 -0700)

are available in the git repository at:

  master.kernel.org:/pub/scm/linux/kernel/git/davem/net-2.6.git master

Christian Lamparter (1):
      carl9170: add NEC WL300NU-AG usbid

Dan Rosenberg (1):
      Bluetooth: Prevent buffer overflow in l2cap config request

David S. Miller (2):
      net: Fix default in docs for tcp_orphan_retries.
      Merge branch 'for-davem' of git://git.kernel.org/.../linville/wir=
eless-2.6

Greg Kroah-Hartman (1):
      hso: fix a use after free condition

Gustavo F. Padovan (1):
      Bluetooth: Fix regression with incoming L2CAP connections

Jean Delvare (1):
      net/natsemi: Fix module parameter permissions

Jim Cromie (1):
      natsemi: fix another dma-debug report

Johannes Berg (1):
      mac80211: fix TKIP replay vulnerability

John W. Linville (2):
      Merge branch 'master' of master.kernel.org:/.../padovan/bluetooth=
-2.6
      Merge branch 'master' of git://git.kernel.org/.../linville/wirele=
ss-2.6 into for-davem

Luciano Coelho (2):
      cfg80211: fix deadlock with rfkill/sched_scan by adding new mutex
      mac80211: fix ie memory allocation for scheduled scans

Matvejchikov Ilya (1):
      slip: fix wrong SLIP6 ifdef-endif placing

Pavel Roskin (2):
      ath5k: fix incorrect use of drvdata in sysfs code
      ath5k: fix incorrect use of drvdata in PCI suspend/resume code

Peter Hurley (1):
      Bluetooth: Fix hidp disconnect deadlocks and lost wakeup

Rafa=A9=A9 Mi=A9=A9ecki (1):
      ssb: fix init regression of hostmode PCI core

Rajkumar Manoharan (1):
      ath9k: Fix tx throughput drops for AR9003 chips with AES encrypti=
on

Thomas Graf (2):
      sctp: Enforce retransmission limit during shutdown
      sctp: ABORT if receive, reassmbly, or reodering queue is not empt=
y while closing socket

Tomas Targownik (1):
      Bluetooth: Fix memory leak under page timeouts

Tushar Gohad (1):
      XFRM: Fix memory leak in xfrm_state_update

Yoann DI-RUZZA (1):
      rtlwifi: rtl8192cu: Add new USB ID for Netgear WNA1000M

 Documentation/networking/ip-sysctl.txt      |    2 +-
 drivers/net/natsemi.c                       |    6 ++--
 drivers/net/slip.c                          |    2 +-
 drivers/net/usb/hso.c                       |    7 +++--
 drivers/net/wireless/ath/ath5k/pci.c        |    7 ++++-
 drivers/net/wireless/ath/ath5k/sysfs.c      |    9 +++++--
 drivers/net/wireless/ath/ath9k/xmit.c       |    3 +-
 drivers/net/wireless/ath/carl9170/usb.c     |    2 +
 drivers/net/wireless/rtlwifi/rtl8192cu/sw.c |    1 +
 drivers/ssb/driver_pcicore.c                |   18 +++++++-------
 include/net/sctp/command.h                  |    1 +
 include/net/sctp/ulpevent.h                 |    2 +-
 net/bluetooth/hci_conn.c                    |    3 ++
 net/bluetooth/hidp/core.c                   |   18 +++++++++------
 net/bluetooth/hidp/hidp.h                   |    1 +
 net/bluetooth/l2cap_core.c                  |    5 ++-
 net/mac80211/scan.c                         |    3 +-
 net/mac80211/wpa.c                          |   16 +++++++++++--
 net/sctp/outqueue.c                         |   20 ++++++++++++++++-
 net/sctp/sm_sideeffect.c                    |   20 +++++++++++++++-
 net/sctp/sm_statefuns.c                     |   32 +++++++++++++++++++=
-------
 net/sctp/sm_statetable.c                    |    2 +-
 net/sctp/socket.c                           |   13 ++++++----
 net/sctp/ulpevent.c                         |   16 +++++++++++--
 net/wireless/core.c                         |   12 +++++++--
 net/wireless/core.h                         |    2 +
 net/wireless/nl80211.c                      |   24 +++++++++++++++----=
-
 net/wireless/scan.c                         |   10 ++++----
 net/xfrm/xfrm_state.c                       |    2 +
 29 files changed, 187 insertions(+), 72 deletions(-)


