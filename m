From: David Miller <davem@davemloft.net>
Subject: [GIT] Networking
Date: Wed, 23 Feb 2011 15:57:54 -0800 (PST)
Message-ID: <20110223.155754.232753422.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


1) Eric B.'s remaining on-stack list_head fixes.

2) inet_twsk_deschedule() called in wrong context, from Eric Dumazet.

3) sfc ethtool large stack usage exposes uninitialzed kernel data to
   user sometimes, from Eric Dumazet.

4) Packet scheduler private data needs to be long aligned, also from
   Eric Dumazet.

5) R8169 bug fixes from Hayes Wang via Francois Romieu.

6) Timewait socket fix in tproxy from Florian Westphal.

7) Someone actually tried to use the ipv6 multicast snooping support
   in bridging and it had lots of bugs.  All fixed by Linus L=FCssing.
   a) packet header u16 access needs ntohs()
   b) parsing mldv2 packets at wrong offset
   c) MAC address creation for ipv6 is wrong
   d) multicast entries stored in table with ETH_P_IP instead of ETH_P_=
IPV6

8) DM9000B locking and PHY power fixes from Henry Nestler.

9) TCP's undo_retrans can go negative, fix from Yuchung Cheng.

10) cfg80211 deadlock fix from Daniel J Blueman

Please pull, thanks a lot.

The following changes since commit 4a508dd259f5995b8d31c576b894263f5947=
d654:

  Merge branch 'for-2639-rc4/i2c-fixes' of git://git.fluff.org/bjdooks/=
linux (2011-02-22 17:13:16 -0800)

are available in the git repository at:

  master.kernel.org:/pub/scm/linux/kernel/git/davem/net-2.6.git master

Cho, Yu-Chen (1):
      Bluetooth: Add Atheros BT AR5BBU12 fw supported

Christian Lamparter (1):
      p54pci: update receive dma buffers before and after processing

Daniel J Blueman (1):
      fix cfg80211_wext_siwfreq lock ordering...

David S. Miller (3):
      Merge branch 'master' of git://git.kernel.org/.../kaber/nf-2.6
      Merge branch 'master' of git://git.kernel.org/.../linville/wirele=
ss-2.6
      Merge branch 'r8169-davem' of git://git.kernel.org/.../romieu/net=
dev-2.6

Eric Dumazet (3):
      tcp: fix inet_twsk_deschedule()
      sfc: lower stack usage in efx_ethtool_self_test
      net_sched: long word align struct qdisc_skb_cb data

Eric W. Biederman (1):
      net: Fix more stale on-stack list_head objects.

=46lorian Westphal (1):
      netfilter: tproxy: do not assign timewait sockets to skb->sk

Gertjan van Wingerde (1):
      rt2x00: Fix WPA TKIP Michael MIC failures.

Hayes Wang (3):
      r8169: fix incorrect args to oob notify.
      r8169: correct settings of rtl8102e.
      r8169: fix RTL8168DP power off issue.

Henry Nestler (2):
      DM9000B: Fix reg_save after spin_lock in dm9000_timeout
      DM9000B: Fix PHY power for network down/up

Jiri Bohac (1):
      sctp: fix reporting of unknown parameters

Joerg Marx (1):
      netfilter: ip6t_LOG: fix a flaw in printing the MAC

John Fastabend (1):
      net: dcb: match dcb_app protocol field with 802.1Qaz spec

John W. Linville (1):
      Merge branch 'master' of git://git.kernel.org/.../padovan/bluetoo=
th-2.6

Linus L=FCssing (7):
      bridge: Fix IPv6 multicast snooping by storing correct protocol t=
ype
      bridge: Fix IPv6 multicast snooping by correcting offset in MLDv2=
 report
      bridge: Add missing ntohs()s for MLDv2 report parsing
      ipv6: Add IPv6 multicast address flag defines
      bridge: Allow mcast snooping for transient link local addresses t=
oo
      bridge: Fix MLD queries' ethernet source address
      bridge: Use IPv6 link-local address for multicast listener querie=
s

Mohammed Shafi Shajakhan (1):
      ath9k: Fix ath9k prevents CPU to enter C3 states

Nick Kossifidis (1):
      ath5k: Fix fast channel switching

Nikolay Ledovskikh (1):
      ath5k: Correct channel setting for AR2317 chip

Oliver Neukum (1):
      Bluetooth: fix crash with quirky dongles doing sound

Shahar Havivi (1):
      Added support for usb ethernet (0x0fe6, 0x9700)

Stanislaw Gruszka (1):
      mac80211: fix conn_mon_timer running after disassociate

Vladislav P (1):
      Bluetooth: Release BTM while sleeping to avoid deadlock

Xose Vazquez Perez (1):
      wireless: rt2x00: rt2800pci.c: add two ids

Yuchung Cheng (1):
      tcp: undo_retrans counter fixes

 drivers/bluetooth/ath3k.c               |    3 +
 drivers/bluetooth/btusb.c               |    7 +-
 drivers/net/dm9000.c                    |    9 +-
 drivers/net/r8169.c                     |   42 +++++----
 drivers/net/sfc/ethtool.c               |   22 +++--
 drivers/net/usb/dm9601.c                |    4 +
 drivers/net/wireless/ath/ath5k/phy.c    |  143 +++++++++++++++++++----=
--------
 drivers/net/wireless/ath/ath9k/ath9k.h  |    6 --
 drivers/net/wireless/ath/ath9k/init.c   |    8 --
 drivers/net/wireless/ath/ath9k/main.c   |    8 --
 drivers/net/wireless/p54/p54pci.c       |   14 ++-
 drivers/net/wireless/rt2x00/rt2800pci.c |    8 ++
 drivers/net/wireless/rt2x00/rt2800usb.c |    6 ++
 include/linux/dcbnl.h                   |    2 +-
 include/net/ipv6.h                      |   12 +++
 include/net/netfilter/nf_tproxy_core.h  |   12 +---
 include/net/sch_generic.h               |    2 +-
 net/bluetooth/rfcomm/tty.c              |    2 +
 net/bridge/br_multicast.c               |   23 +++---
 net/ipv4/inet_timewait_sock.c           |    2 +
 net/ipv4/tcp_input.c                    |    5 +-
 net/ipv4/tcp_output.c                   |    2 +-
 net/ipv6/netfilter/ip6t_LOG.c           |    2 +-
 net/mac80211/iface.c                    |    1 +
 net/mac80211/mlme.c                     |    6 ++
 net/netfilter/nf_tproxy_core.c          |   27 +++---
 net/netfilter/xt_TPROXY.c               |   22 +++++-
 net/netfilter/xt_socket.c               |   13 +++-
 net/sched/sch_generic.c                 |    1 +
 net/sctp/sm_make_chunk.c                |   10 +-
 net/wireless/wext-compat.c              |    4 +-
 31 files changed, 258 insertions(+), 170 deletions(-)
