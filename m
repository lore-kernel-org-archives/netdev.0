From: David Miller <davem@davemloft.net>
Subject: [GIT]: Networking
Date: Mon, 23 Mar 2009 01:40:53 -0700 (PDT)
Message-ID: <20090323.014053.100569459.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60788
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1757404AbZCWIlG convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 23 Mar 2009 04:41:06 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


1) Driver bug fixes:

   ucc_geth OOPS fix from Anton Vorontsov
   dm9000 IRQ locking fix from David Brownell
   IRQ handler selection fix in bnx2 from Michael Chan
   sh_eth IRQ handler and register address fix from Nobuhiro Iwamatsu
   tulip crash on interface up with shirq debug, from Kyle McMartin
   be2net RX ring replenish under OOM fix from Sathya Perla
   dnet build fix from Stephen Rothwell
   sungem netdev_ops conversion regression fix from Stephen Hemminger
   bas_gigaset USB transfer buffer allocation fix from Tilman Schmidt

2) SCTP byte swapping fix from Al Viro.

3) IP fragmentation network namespace OOPS fix from Jorge Boncompte

4) Legacy GRO input path crash fix from Herbert Xu.

5) Bonding speed/duplex update fix from Jay Vosburgh

6) kfree(skb) =3D=3D OOPS fix from Roel Kluin

7) SIT ipv6 tunnel regression fix wrt. netdev_ops conversion
   from Bj=F8rn Mork

8) Wireless bug fixes from John Linville and the wireless crew.

9) Netfilter bug fixes from Christoph Paasch (conntrack packet dropping
   and sanity check errors) and Pablo Neira Ayuso (conntrack netlink).

Please pull, thanks a lot!

The following changes since commit ee568b25ee9e160b32d1aef73d8b2ee9c05d=
34db:
  Linus Torvalds (1):
        Avoid 64-bit "switch()" statements on 32-bit architectures

are available in the git repository at:

  master.kernel.org:/pub/scm/linux/kernel/git/davem/net-2.6.git master

Al Viro (1):
      net: fix sctp breakage

Anton Vorontsov (1):
      ucc_geth: Fix oops when using fixed-link support

Bj=F8rn Mork (1):
      ipv6: fix display of local and remote sit endpoints

Christoph Paasch (2):
      netfilter: conntrack: fix dropping packet after l4proto->packet()
      netfilter: conntrack: check for NEXTHDR_NONE before header sanity=
 checking

David Brownell (1):
      dm9000: locking bugfix

David S. Miller (3):
      Merge branch 'master' of git://git.kernel.org/.../kaber/nf-2.6
      Merge branch 'master' of git://git.kernel.org/.../linville/wirele=
ss-2.6
      Merge branch 'master' of git://git.kernel.org/.../linville/wirele=
ss-2.6

Herbert Xu (1):
      gro: Fix legacy path napi_complete crash

Ilya Yanok (1):
      dnet: DNET should depend on HAS_IOMEM

Jay Vosburgh (1):
      bonding: Fix updating of speed/duplex changes

John W. Linville (1):
      lib80211: silence excessive crypto debugging messages

Jorge Boncompte [DTI2] (1):
      netns: oops in ip[6]_frag_reasm incrementing stats

Jouni Malinen (3):
      mac80211: Fix panic on fragmentation with power saving
      zd1211rw: Do not panic on device eject when associated
      nl80211: Check that function pointer !=3D NULL before using it

Kyle McMartin (1):
      tulip: fix crash on iface up with shirq debug

Luis R. Rodriguez (2):
      ath9k: implement IO serialization
      ath9k: AR9280 PCI devices must serialize IO as well

Maciej Sosnowski (1):
      dca: add missing copyright/license headers

Michael Chan (1):
      bnx2: Fix problem of using wrong IRQ handler.

Nobuhiro Iwamatsu (2):
      sh_eth: Change handling of IRQ
      sh_eth: Fix mistake of the address of SH7763

Pablo Neira Ayuso (2):
      netfilter: conntrack: don't deliver events for racy packets
      netfilter: ctnetlink: fix crash during expectation creation

Pantelis Koukousoulas (1):
      virtio_net: Make virtio_net support carrier detection

Roel Kluin (1):
      net: kfree(napi->skb) =3D> kfree_skb

Sathya Perla (2):
      be2net: replenish when posting to rx-queue is starved in out of m=
em conditions
      be2net: fix to restore vlan ids into BE2 during a IF DOWN->UP cyc=
le

Stanislaw Gruszka (1):
      net: Document /proc/sys/net/core/netdev_budget

Stephen Hemminger (1):
      sungem: missing net_device_ops

Stephen Rothwell (1):
      net: update dnet.c for bus_id removal

Steve Glendinning (1):
      smsc911x: reset last known duplex and carrier on open

Tilman Schmidt (1):
      bas_gigaset: correctly allocate USB interrupt transfer buffer

 Documentation/filesystems/proc.txt        |    7 +++
 drivers/dca/dca-sysfs.c                   |   21 ++++++++++
 drivers/isdn/gigaset/bas-gigaset.c        |   16 ++++++-
 drivers/net/Kconfig                       |    2 +-
 drivers/net/benet/be.h                    |    1 +
 drivers/net/benet/be_main.c               |   60 ++++++++++++++++-----=
-------
 drivers/net/bnx2.c                        |   12 +++---
 drivers/net/bonding/bond_main.c           |   25 ++++++++++--
 drivers/net/dm9000.c                      |    6 ++-
 drivers/net/dnet.c                        |    6 +-
 drivers/net/sh_eth.c                      |   20 ++++++++-
 drivers/net/sh_eth.h                      |    4 +-
 drivers/net/smsc911x.c                    |    4 ++
 drivers/net/sungem.c                      |    9 ++--
 drivers/net/tulip/tulip_core.c            |   45 ++++++++++++++-------=
-
 drivers/net/ucc_geth.c                    |   34 +++++-----------
 drivers/net/ucc_geth.h                    |    3 +-
 drivers/net/virtio_net.c                  |    3 +
 drivers/net/wireless/ath9k/ath9k.h        |    4 +-
 drivers/net/wireless/ath9k/core.h         |   33 ++++++++++++++++
 drivers/net/wireless/ath9k/hw.c           |   22 ++++++++++-
 drivers/net/wireless/ath9k/main.c         |    1 +
 drivers/net/wireless/zd1211rw/zd_mac.c    |    8 +++-
 include/linux/dca.h                       |   20 ++++++++++
 include/net/netfilter/nf_conntrack_core.h |    3 +-
 net/core/dev.c                            |    7 ++-
 net/ipv4/ip_fragment.c                    |    3 +-
 net/ipv6/netfilter/nf_conntrack_reasm.c   |    8 ++--
 net/ipv6/reassembly.c                     |    7 +--
 net/ipv6/sit.c                            |    2 +-
 net/mac80211/tx.c                         |    2 +
 net/netfilter/nf_conntrack_core.c         |    2 +-
 net/netfilter/nf_conntrack_netlink.c      |    1 +
 net/netfilter/nf_conntrack_proto_tcp.c    |    4 +-
 net/sctp/endpointola.c                    |    3 +-
 net/wireless/Kconfig                      |   10 +++++
 net/wireless/lib80211_crypt_ccmp.c        |    2 +
 net/wireless/lib80211_crypt_tkip.c        |    4 ++
 net/wireless/nl80211.c                    |   11 +++++
 39 files changed, 314 insertions(+), 121 deletions(-)
