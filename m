From: David Miller <davem@davemloft.net>
Subject: [GIT] Networking
Date: Fri, 08 Oct 2010 20:30:34 -0700 (PDT)
Message-ID: <20101008.203034.241431376.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:44368
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751814Ab0JIDaN convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 8 Oct 2010 23:30:13 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


1) Memory out-of-bounds accesses in SCTP, from Dan Rosenberg.

2) We accidently handle v3 queries imporperly when in IGMP v2 compat mo=
de.
   Fix from David Stevens.

3) Ref-after-put bug, and lack of dev_get_by_index() failure checking
   in caif_connect(), from Eric Dumazet.

4) Bluetooh can deadlock on writes when socket send buffer fills us,
   but the packets that would release that space are in the backlog,
   because we hold the socket lock while sleeping and therefore can't
   process those backlog packets.

   Fix from Gustavo F. Padovan.

5) IPV6 doesn't check all of the necessary routes when updating the
   PMTU in response to an ICMP.  Fix from Maciej =AFenczykowski.

6) When global TCP memory hit is hit, we hang because the sk_wait_event=
()
   third argument is wrong in sk_stream_wait_memory().

   This is a very very old bug, I am very surprised nobody else has hit
   this problem.

   Fix by Nagendra Singh Tomar.

7) An old commit I made to fix a build failure with some drivers
   was wrong, and didn't fix the INET_LRO dependency problems at
   all.

   So revert that and Ben Hutchings fixes it right by adding the
   necessary "INET" dependencies to drivers which need "INET_LRO".

8) Signedness overflow in offset check of cls_u32 packet scheduler
   classifier module, from Dan Carpenter.

9) Update Intel ethernet driver docs and MAINTAINERS netry, from Jeff K=
irsher.

10) SKGE on some motherboards can't do 64-bit DMA properly, fix from
    Stanislaw Gruszka.

11) bond_masters sysfs file gives bogus WARN_ON, fix from Neil HOrman

12) Fix ath9k clock rate calcuation regression, from Felix Fietkau.

13) Kill AddBA timer, otherwise we reference a freed object.  Fix
    from Johannes Berg.

14) Revert mac80211 change to use netif_receive_skb() instead of netif_=
rx()
    since sometimes this ends up executing in the wrong context, from
    John W. Linville.

15) Use strlcpy() in isdn to avoid going past the end of a buffer.  Fro=
m
    Dan Carpenter.

16) ETHTOOL_GRXCLSRLALL exposes kernel heap to userspace.  Fix from
    Kees Cook.

17) Revert ConfigReq rejection commit that causes failures in bluetooth
    validation suite.  From Gustavo F. Padovan.

18) rfcomm_sk_state_change() needs to disable local interrupts to avoid
    illegal lock state, also from Gustavo F. Padovan.

Please pull, thanks a lot!

The following changes since commit 6b0cd00bc396daf5c2dcf17a8d8205533534=
1f46:

  Merge branch 'hwpoison-fixes' of git://git.kernel.org/pub/scm/linux/k=
ernel/git/ak/linux-mce-2.6 (2010-10-07 13:59:32 -0700)

are available in the git repository at:

  master.kernel.org:/pub/scm/linux/kernel/git/davem/net-2.6.git master

Andrei Emeltchenko (1):
      Bluetooth: fix MTU L2CAP configuration parameter

Ben Hutchings (2):
      Revert "ipv4: Make INET_LRO a bool instead of tristate."
      netdev: Depend on INET before selecting INET_LRO

Dan Carpenter (2):
      cls_u32: signedness bug
      isdn: strcpy() =3D> strlcpy()

Dan Rosenberg (2):
      sctp: prevent reading out-of-bounds memory
      sctp: Fix out-of-bounds reading in sctp_asoc_get_hmac()

David S. Miller (3):
      Merge branch 'master' of master.kernel.org:/.../torvalds/linux-2.=
6
      Merge branch 'master' of git://git.kernel.org/.../padovan/bluetoo=
th-2.6
      Merge branch 'master' of git://git.kernel.org/.../linville/wirele=
ss-2.6

David Stevens (1):
      ipv4: correct IGMP behavior on v3 query during v2-compatibility m=
ode

Eric Dumazet (1):
      caif: fix two caif_connect() bugs

=46elix Fietkau (1):
      ath9k_hw: fix regression in ANI listen time calculation

Gustavo F. Padovan (5):
      Bluetooth: Simplify L2CAP Streaming mode sending
      Bluetooth: Fix inconsistent lock state with RFCOMM
      Revert "Bluetooth: Don't accept ConfigReq if we aren't in the BT_=
CONFIG state"
      Bluetooth: Fix deadlock in the ERTM logic
      Bluetooth: Disallow to change L2CAP_OPTIONS values when connected

Jeff Kirsher (4):
      ixgbevf.txt: Update ixgbevf documentation
      e1000.txt: Update e1000 documentation
      e1000e.txt: Add e1000e documentation
      MAINTAINERS: update Intel LAN Ethernet info

Johannes Berg (1):
      mac80211: delete AddBA response timer

John W. Linville (1):
      Revert "mac80211: use netif_receive_skb in ieee80211_tx_status ca=
llpath"

Kees Cook (1):
      net: clear heap allocation for ETHTOOL_GRXCLSRLALL

Maciej =AFenczykowski (1):
      net: Fix IPv6 PMTU disc. w/ asymmetric routes

Mat Martineau (1):
      Bluetooth: Only enable L2CAP FCS for ERTM or streaming

Nagendra Tomar (1):
      net: Fix the condition passed to sk_wait_event()

Neil Horman (1):
      bonding: fix WARN_ON when writing to bond_master sysfs file

Stanislaw Gruszka (1):
      skge: add quirk to limit DMA

 Documentation/networking/e1000.txt   |  373 +++++++++-----------------=
--------
 Documentation/networking/e1000e.txt  |  302 ++++++++++++++++++++++++++=
+
 Documentation/networking/ixgbevf.txt |   40 +----
 MAINTAINERS                          |   16 ++-
 drivers/isdn/sc/interrupt.c          |   18 ++-
 drivers/net/Kconfig                  |    4 +-
 drivers/net/bonding/bond_main.c      |    9 +
 drivers/net/skge.c                   |   18 ++-
 drivers/net/wireless/ath/ath9k/ani.c |    2 +-
 include/net/bluetooth/bluetooth.h    |   18 ++
 net/bluetooth/l2cap.c                |   62 +++---
 net/bluetooth/rfcomm/sock.c          |    4 +
 net/caif/caif_socket.c               |   21 ++-
 net/core/ethtool.c                   |    2 +-
 net/core/stream.c                    |    8 +-
 net/ipv4/Kconfig                     |    2 +-
 net/ipv4/igmp.c                      |   14 ++-
 net/ipv6/route.c                     |   28 +++-
 net/mac80211/agg-tx.c                |    2 +
 net/mac80211/status.c                |    4 +-
 net/sched/cls_u32.c                  |    2 +-
 net/sctp/auth.c                      |    8 +-
 net/sctp/socket.c                    |   13 +-
 23 files changed, 590 insertions(+), 380 deletions(-)
 create mode 100644 Documentation/networking/e1000e.txt
 mode change 100755 =3D> 100644 Documentation/networking/ixgbevf.txt
