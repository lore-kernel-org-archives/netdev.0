From: David Miller <davem@davemloft.net>
Subject: [GIT] Networking
Date: Fri, 23 Apr 2010 16:52:51 -0700 (PDT)
Message-ID: <20100423.165251.75236604.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46460
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755430Ab0DWXws (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Apr 2010 19:52:48 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


1) Incorrect ERR_PTR handling in rtnetlink and rdma, from
   Dan Carpenter.

2) New IPHONE ipheth driver from Diego Giagio.

3) ipv6 ipsec grabs wrong device when bundling.  Fix from Nicolas Dichtel.

4) ipv6 TCP code fixes transport header of wrong SKB, from Herbert Xu.

5) Bridge igmp snooping code missing ntohs(), from Eric Dumazet.

6) TCP bind can croak when many ports are bound, effects are exasperated
   when there are several local IP addresses.  Also from Eric Dumazet.

7) Fix cxgb3 link-up regression with certain chips, from Hiroshi Shimamoto.

8) ipv6 doesn't respect bind-to-device settings properly, fix from Jiri Olsa.

9) Races in KS8851 TX handling can result in an OOPS, from Abraham Arce.

10) Debugging build breaks due to typo in hex dump function name,
    fix from Alexander Kuznetsov.

11) gianfar/fsl_pq_mdio can OOPS due to buggy device trees which do
    exist in the real world, fix from Anton Vorontsov.

12) Fix RCU warning in dev_pick_tx(), from David Howells.

13) A few small wireless fixes (iwlwifi scanning races, bad
    aggregation handling, wrong regulatory bits checked in iwlwifi
    EEPROM) from Reinette Chatre, Johannes Berg, and Shanyu Zhao.

14) Fix mishandling of dead unaccepted sockets in x25, from Andrew
    Hendry.

Please pull, thanks a lot!

The following changes since commit 33eaf788345c0311ab48ae62673c05f59fb09bb3:
  Linus Torvalds (1):
        Merge branch 'for-linus' of git://git.kernel.org/.../tiwai/sound-2.6

are available in the git repository at:

  master.kernel.org:/pub/scm/linux/kernel/git/davem/net-2.6.git master

Abraham Arce (1):
      KS8851: NULL pointer dereference if list is empty

Alexander Kurz (1):
      net: 3c574_cs fix stats.tx_bytes counter

Alexander Kuznetsov (1):
      8139too: Fix a typo in the function name.

Anton Vorontsov (2):
      fsl_pq_mdio: Fix kernel oops during OF address translation
      gianfar: Fix potential oops during OF address translation

Dan Carpenter (2):
      rtnetlink: potential ERR_PTR dereference
      rdma: potential ERR_PTR dereference

David Howells (1):
      net: Fix an RCU warning in dev_pick_tx()

David S. Miller (2):
      Merge branch 'master' of git://git.kernel.org/.../linville/wireless-2.6
      Merge branch 'master' of /home/davem/src/GIT/linux-2.6/

Diego Giagio (1):
      drivers/net/usb: Add new driver ipheth

Eric Dumazet (2):
      bridge: add a missing ntohs()
      tcp: bind() fix when many ports are bound

Hans J. Koch (1):
      can: Fix possible NULL pointer dereference in ems_usb.c

Herbert Xu (1):
      ipv6: Fix tcp_v6_send_response transport header setting.

Hiroshi Shimamoto (1):
      cxgb3: fix linkup issue

Jiri Olsa (1):
      net: ipv6 bind to device issue

Johannes Berg (2):
      iwlwifi: fix scan races
      mac80211: remove bogus TX agg state assignment

Nicolas Dichtel (1):
      xfrm6: ensure to use the same dev when building a bundle

Reinette Chatre (1):
      mac80211: pass HT changes to driver when off channel

Shan Wei (1):
      ipv6: allow to send packet after receiving ICMPv6 Too Big message with MTU field less than IPV6_MIN_MTU

Shanyu Zhao (1):
      iwlwifi: correct 6000 EEPROM regulatory address

andrew hendry (1):
      X25 fix dead unaccepted sockets

 drivers/net/8139too.c                     |    2 +-
 drivers/net/Makefile                      |    1 +
 drivers/net/can/usb/ems_usb.c             |    8 +-
 drivers/net/cxgb3/ael1002.c               |    2 +-
 drivers/net/fsl_pq_mdio.c                 |   20 +-
 drivers/net/gianfar.c                     |    6 +-
 drivers/net/ks8851.c                      |   12 +-
 drivers/net/pcmcia/3c574_cs.c             |    7 +-
 drivers/net/usb/Kconfig                   |   12 +
 drivers/net/usb/Makefile                  |    1 +
 drivers/net/usb/ipheth.c                  |  568 +++++++++++++++++++++++++++++
 drivers/net/wireless/iwlwifi/iwl-6000.c   |    4 +-
 drivers/net/wireless/iwlwifi/iwl-agn.c    |    1 +
 drivers/net/wireless/iwlwifi/iwl-core.c   |    1 -
 drivers/net/wireless/iwlwifi/iwl-core.h   |    2 +-
 drivers/net/wireless/iwlwifi/iwl-dev.h    |    1 +
 drivers/net/wireless/iwlwifi/iwl-eeprom.h |    4 +
 drivers/net/wireless/iwlwifi/iwl-scan.c   |   31 +-
 net/bridge/br_multicast.c                 |    2 +-
 net/core/dev.c                            |    2 +-
 net/core/rtnetlink.c                      |    5 +-
 net/ipv4/inet_connection_sock.c           |   16 +-
 net/ipv6/inet6_connection_sock.c          |   15 +-
 net/ipv6/ip6_output.c                     |    2 +-
 net/ipv6/route.c                          |    2 +-
 net/ipv6/tcp_ipv6.c                       |    2 +-
 net/ipv6/xfrm6_policy.c                   |    2 +-
 net/mac80211/agg-tx.c                     |    1 -
 net/mac80211/mlme.c                       |    2 +
 net/rds/rdma_transport.c                  |    2 +-
 net/x25/af_x25.c                          |    1 +
 31 files changed, 678 insertions(+), 59 deletions(-)
 create mode 100644 drivers/net/usb/ipheth.c
