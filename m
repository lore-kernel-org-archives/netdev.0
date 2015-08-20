From: David Miller <davem@davemloft.net>
Subject: [GIT] Networking
Date: Wed, 19 Aug 2015 17:34:51 -0700 (PDT)
Message-ID: <20150819.173451.250650958122113918.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


1) Out of bounds array access in 802.11 minstrel code, from Adrien
   Schildknecht.

2) Don't use skb_get() in IGMP/MLD code paths, as this makes
   pskb_may_pull() BUG.  From Linus Luessing.

3) Fix off by one in ipv4 route dumping code, from Andy Whitcroft.

4) Fix deadlock in reqsk_queue_unlink(), from Eric Dumazet.

5) Fix ppp device deregistration wrt. netns deletion, from
   Guillaume Nault.

6) Fix deadlock when creating per-cpu ipv6 routes, from Martin KaFai
   Lau.

7) Fix memory leak in batman-adv code, from Sven Eckelmann.

Please pull, thanks a lot!

The following changes since commit 5b3e2e14eaa2a98232a4f292341fb8843868=
5734:

  Merge tag 'dm-4.2-fixes-5' of git://git.kernel.org/pub/scm/linux/kern=
el/git/device-mapper/linux-dm (2015-08-13 13:52:46 -0700)

are available in the git repository at:


  git://git.kernel.org/pub/scm/linux/kernel/git/davem/net.git master

for you to fetch changes up to fd7dec25a18f495e50d2040398fd263836ff3b28=
:

  batman-adv: Fix memory leak on tt add with invalid vlan (2015-08-18 1=
9:08:23 -0700)

----------------------------------------------------------------
Adrien Schildknecht (1):
      mac80211: fix invalid read in minstrel_sort_best_tp_rates()

Andy Whitcroft (1):
      ipv4: off-by-one in continuation handling in /proc/net/route

Calvin Owens (1):
      Revert "net: limit tcp/udp rmem/wmem to SOCK_{RCV,SND}BUF_MIN"

Claudiu Manoil (1):
      gianfar: Restore link state settings after MAC reset

Dan Carpenter (1):
      net: ethernet: micrel: fix an error code

David S. Miller (2):
      Merge tag 'mac80211-for-davem-2015-08-14' of git://git.kernel.org=
/.../jberg/mac80211
      Merge branch 'ipv6_percpu_rt_deadlock'

David Ward (1):
      net: qmi_wwan: add HP lt4111 LTE/EV-DO/HSPA+ Gobi 4G Module

Eric Dumazet (1):
      inet: fix potential deadlock in reqsk_queue_unlink()

Guillaume Nault (1):
      ppp: fix device unregistration upon netns deletion

Igor Plyatov (1):
      net: phy: workaround for buggy cable detection by LAN8700 after c=
able plugging

Ivan Vecera (1):
      be2net: avoid vxlan offloading on multichannel configs

Linus L=FCssing (1):
      net: fix wrong skb_get() usage / crash in IGMP/MLD parsing code

Martin KaFai Lau (3):
      ipv6: Remove un-used argument from ip6_dst_alloc()
      ipv6: Add rt6_make_pcpu_route()
      ipv6: Fix a potential deadlock when creating pcpu rt

Shaohui Xie (1):
      net: phy: fix PHY_RUNNING in phy_state_machine

Sven Eckelmann (1):
      batman-adv: Fix memory leak on tt add with invalid vlan

kbuild test robot (1):
      net: phy: fix semicolon.cocci warnings

 drivers/net/ethernet/emulex/benet/be_main.c |    4 ++--
 drivers/net/ethernet/freescale/gianfar.c    |    5 +++++
 drivers/net/ethernet/micrel/ks8842.c        |    5 ++---
 drivers/net/phy/phy.c                       |   16 ++++++++++++----
 drivers/net/phy/smsc.c                      |   31 +++++++++++++++++++=
------------
 drivers/net/ppp/ppp_generic.c               |   78 +++++++++++++++++++=
+++++++++++++++++++++++------------------------------------
 drivers/net/usb/qmi_wwan.c                  |    1 +
 net/batman-adv/translation-table.c          |    5 ++++-
 net/bridge/br_multicast.c                   |    4 ++--
 net/core/skbuff.c                           |   37 ++++++++++++++++++-=
------------------
 net/ipv4/fib_trie.c                         |    2 +-
 net/ipv4/igmp.c                             |   33 ++++++++++++++++++-=
--------------
 net/ipv4/inet_connection_sock.c             |    2 +-
 net/ipv4/sysctl_net_ipv4.c                  |   10 ++++------
 net/ipv6/ip6_fib.c                          |    2 ++
 net/ipv6/mcast_snoop.c                      |   33 ++++++++++++++++++-=
--------------
 net/ipv6/route.c                            |   79 +++++++++++++++++++=
++++++++++++++++++++++++++++++++++++------------------------
 net/mac80211/rc80211_minstrel.c             |   11 ++++++-----
 18 files changed, 212 insertions(+), 146 deletions(-)
