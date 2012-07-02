From: David Miller <davem@davemloft.net>
Subject: [GIT] Networking
Date: Sun, 01 Jul 2012 18:51:08 -0700 (PDT)
Message-ID: <20120701.185108.649191544291827386.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


1) Fix RX sequence number handling in mwifiex, from Stone Piao.

2) Netfilter ipset mis-compares device names, fix from Florian
   Westphal.

3) Fix route leak in ipv6 IPVS, from Eric Dumazet.

4) NFS fixes.  Several buffer overflows in NCI layer from Dan
   Rosenberg, and release sock OOPS'er fix from Eric Dumazet.

5) Fix WEP handling ath9k, we started using a bit the chip provides
   to indicate undecrypted packets but that bit turns out to be
   unreliable in certain configurations.  Fix from Felix Fietkau.

6) Fix Kconfig dependency bug in wlcore, from Randy Dunlap.

7) New USB IDs for rtlwifi driver from Larry Finger.

8) Fix crashes in qmi_wwan usbnet driver when disconnecting, from
   Bj=F8rn Mork.

9) Gianfar driver programs coalescing settings properly in single
   queue mode, but does not do so in multi-queue mode.  Fix from=09
   Claudiu Manoil.

10) Missing module.h include in davinci_cpdma.c, from Daniel Mack.

11) Need dummy handler for IPSET_CMD_NONE otherwise we crash in
    ipset if we get this via nfnetlink, fix from Tomasz Bursztyka.

12) Missing RCU unlock in nfnetlink error path, also from Tomasz.

13) Fix divide by zero in igbvf when the user tries to set an RX
    coalescing value of 0 usecs, from Mitch A. Williams.

14) We can process SCTP sacks for the wrong transport, oops.  Fix
    from Neil Horman.

15) Remove hw IP payload checksumming from e1000e driver.  This has
    zery value in our stack, and turning it on creates a very
    unintuitive restriction for users when using jumbo MTUs.
    Specifically, when IP payload checksums are on you cannot use both
    receive hashing offload and jumbo MTU.  Fix from Bruce Allan.

Please pull, thanks a lot!

The following changes since commit 9acc7bde23ebb19a704395f76490685e1513=
e422:

  Merge tag 'hwmon-for-linus' of git://git.kernel.org/pub/scm/linux/ker=
nel/git/groeck/linux-staging (2012-06-28 12:38:51 -0700)

are available in the git repository at:


  git://git.kernel.org/pub/scm/linux/kernel/git/davem/net master

for you to fetch changes up to 2e1706f234f86ff71056ef69683d734fbf7e9e40=
:

  e1000e: remove use of IP payload checksum (2012-07-01 00:25:32 -0700)

----------------------------------------------------------------
Amitkumar Karwar (2):
      mwifiex: fix bugs in event handling code
      mwifiex: improve error path handling in usb.c

Avinash Patil (1):
      mwifiex: fix memory leak associated with IE manamgement

Bj=F8rn Mork (1):
      net: qmi_wwan: fix Oops while disconnecting

Bruce Allan (1):
      e1000e: remove use of IP payload checksum

Claudiu Manoil (1):
      gianfar: Fix RXICr/TXICr programming for multi-queue mode

Dan Rosenberg (1):
      NFC: Prevent multiple buffer overflows in NCI

Daniel Mack (1):
      davinci_cpdma: include linux/module.h

David S. Miller (2):
      Merge branch 'for-davem' of git://git.kernel.org/.../linville/wir=
eless
      Merge branch 'master' of git://1984.lsi.us.es/nf

Eliad Peller (1):
      mac80211: clear ifmgd->bssid only after building DELBA

Eric Dumazet (2):
      netfilter: ipvs: fix dst leak in __ip_vs_addr_is_local_v6
      NFC: Return from rawsock_release when sk is NULL

=46elix Fietkau (1):
      ath9k: fix dynamic WEP related regression

=46lorian Westphal (1):
      netfilter: ipset: fix interface comparision in hash-netiface sets

Johannes Berg (2):
      iwlwifi: fix activating inactive stations
      mac80211: correct behaviour on unrecognised action frames

John W. Linville (3):
      Merge branch 'for-john' of git://git.kernel.org/.../jberg/mac8021=
1
      Merge branch 'for-wireless' of git://git.kernel.org/.../sameo/nfc=
-3.0
      Merge branch 'master' of git://git.kernel.org/.../linville/wirele=
ss into for-davem

Larry Finger (1):
      rtlwifi: rtl8192cu: New USB IDs

Mitch A Williams (1):
      igbvf: fix divide by zero

Neil Horman (1):
      sctp: be more restrictive in transport selection on bundled sacks

Pablo Neira Ayuso (1):
      netfilter: update location of my trees

Panayiotis Karabassis (1):
      ath9k: enable serialize_regmode for non-PCIE AR9287

Randy Dunlap (1):
      wlcore: drop INET dependency

Stone Piao (2):
      mwifiex: fix 11n rx packet drop issue
      mwifiex: fix WPS eapol handshake failure

Tom Hughes (1):
      ath9k: fix panic caused by returning a descriptor we have queued =
for reuse

Tomasz Bursztyka (2):
      netfilter: ipset: fix crash if IPSET_CMD_NONE command is sent
      netfilter: nfnetlink: fix missing rcu_read_unlock in nfnetlink_rc=
v_msg

Vinson Lee (1):
      net: Downgrade CAP_SYS_MODULE deprecated message from error to wa=
rning.

 MAINTAINERS                                  |    4 +--
 drivers/net/ethernet/freescale/gianfar.c     |   10 +++----
 drivers/net/ethernet/intel/e1000e/defines.h  |    1 +
 drivers/net/ethernet/intel/e1000e/netdev.c   |   75 ++++++++++--------=
-----------------------------------
 drivers/net/ethernet/intel/igbvf/ethtool.c   |   29 +++++++++++++-----=
---
 drivers/net/ethernet/ti/davinci_cpdma.c      |    1 +
 drivers/net/usb/qmi_wwan.c                   |    4 +++
 drivers/net/wireless/ath/ath.h               |    1 +
 drivers/net/wireless/ath/ath9k/hw.c          |    2 +-
 drivers/net/wireless/ath/ath9k/recv.c        |    7 ++---
 drivers/net/wireless/ath/key.c               |    4 +++
 drivers/net/wireless/iwlwifi/iwl-mac80211.c  |   12 +++++++++
 drivers/net/wireless/mwifiex/11n_rxreorder.c |    5 ++--
 drivers/net/wireless/mwifiex/11n_rxreorder.h |    7 +++++
 drivers/net/wireless/mwifiex/ie.c            |    1 +
 drivers/net/wireless/mwifiex/sdio.c          |    6 ++---
 drivers/net/wireless/mwifiex/sta_event.c     |    9 +++----
 drivers/net/wireless/mwifiex/usb.c           |   28 ++++++++++++++----=
--
 drivers/net/wireless/mwifiex/wmm.c           |    3 +++
 drivers/net/wireless/rtlwifi/rtl8192cu/sw.c  |    3 +++
 drivers/net/wireless/ti/wlcore/Kconfig       |    1 -
 include/net/sctp/structs.h                   |    4 +++
 include/net/sctp/tsnmap.h                    |    3 ++-
 net/core/dev.c                               |    4 +--
 net/mac80211/mlme.c                          |   13 +++++-----
 net/mac80211/rx.c                            |    5 +++-
 net/netfilter/ipset/ip_set_core.c            |   12 +++++++++
 net/netfilter/ipset/ip_set_hash_netiface.c   |   32 +++---------------=
-----
 net/netfilter/ipvs/ip_vs_ctl.c               |   14 +++++-----
 net/netfilter/nfnetlink.c                    |    4 ++-
 net/nfc/nci/ntf.c                            |   10 +++----
 net/nfc/rawsock.c                            |    5 +++-
 net/sctp/associola.c                         |    1 +
 net/sctp/output.c                            |    5 ++++
 net/sctp/sm_make_chunk.c                     |   16 ++++++++++++
 net/sctp/sm_sideeffect.c                     |    2 +-
 net/sctp/transport.c                         |    2 ++
 net/sctp/tsnmap.c                            |    6 ++++-
 net/sctp/ulpevent.c                          |    3 ++-
 net/sctp/ulpqueue.c                          |    2 +-
 40 files changed, 196 insertions(+), 160 deletions(-)
