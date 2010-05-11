From: David Miller <davem@davemloft.net>
Subject: [GIT] Networking
Date: Tue, 11 May 2010 00:01:43 -0700 (PDT)
Message-ID: <20100511.000143.221595639.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:44881
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S933062Ab0EKHBf convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 11 May 2010 03:01:35 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


1) Fix SCTP race between connect() and ICMP unreachable, from Vlad Yase=
vich.

2) Micrel phy driver OOPS fix, based upon a report by Ingo Molnar.

3) Firmware loading warn_on fix from Christian Lamparter.

4) UDP logs garbage addresses on short packets.  Fix from Bj=F8rn Mork.

5) IPV6_RECVERR incorrectly handles locally generated errors, fix from
   Brian Haley.

6) IPV4 multicast purges routes too quickly due to mishandling of timer=
s.
   Fix from Andreas Meissner.

7) Passive scans busted in iwlwifi, fix from Johannes Berg.

8) De-auth request handling fix in mac80211 from Reinette Chatre.

9) gianfar needs to purge cached recycled SKBs on MTU change, fix from
   Sebastian Andrzej Siewior

Please pull, thanks a lot!

The following changes since commit 8777c793d6a24c7f3adf52b1b1086e9706de=
4589:
  Linus Torvalds (1):
        Merge branch 'for-linus' of git://git.kernel.org/.../tj/wq

are available in the git repository at:

  master.kernel.org:/pub/scm/linux/kernel/git/davem/net-2.6.git master

Andreas Meissner (1):
      IPv4: unresolved multicast route cleanup

Bj=F8rn Mork (1):
      ipv4: udp: fix short packet and bad checksum logging

Brian Haley (1):
      IPv6: fix IPV6_RECVERR handling of locally-generated errors

Christian Lamparter (1):
      ar9170: wait for asynchronous firmware loading

David S. Miller (3):
      phy: Fix initialization in micrel driver.
      net: Fix FDDI and TR config checks in ipv4 arp and LLC.
      Merge branch 'master' of git://git.kernel.org/.../linville/wirele=
ss-2.6

Eric Dumazet (1):
      veth: Dont kfree_skb() after dev_forward_skb()

Johannes Berg (1):
      iwlwifi: work around passive scan issue

Reinette Chatre (1):
      mac80211: remove association work when processing deauth request

Sebastian Andrzej Siewior (1):
      net/gianfar: drop recycled skbs on MTU change

Vlad Yasevich (1):
      sctp: Fix a race between ICMP protocol unreachable and connect()

 drivers/net/gianfar.c                       |    2 +-
 drivers/net/phy/micrel.c                    |    1 +
 drivers/net/veth.c                          |    1 -
 drivers/net/wireless/ath/ar9170/usb.c       |   11 ++++++++
 drivers/net/wireless/ath/ar9170/usb.h       |    1 +
 drivers/net/wireless/iwlwifi/iwl-commands.h |    4 ++-
 drivers/net/wireless/iwlwifi/iwl-scan.c     |   23 ++++++++++++++----
 drivers/net/wireless/iwlwifi/iwl3945-base.c |    3 +-
 include/net/sctp/sm.h                       |    1 +
 include/net/sctp/structs.h                  |    3 ++
 net/core/dev.c                              |   11 ++++----
 net/ipv4/arp.c                              |    6 ++--
 net/ipv4/ipmr.c                             |    3 +-
 net/ipv4/udp.c                              |    6 ++--
 net/ipv6/datagram.c                         |    8 ++++-
 net/llc/llc_sap.c                           |    2 +-
 net/mac80211/mlme.c                         |    3 +-
 net/sctp/input.c                            |   22 ++++++++++++++---
 net/sctp/sm_sideeffect.c                    |   35 +++++++++++++++++++=
++++++++
 net/sctp/transport.c                        |    2 +
 20 files changed, 118 insertions(+), 30 deletions(-)
