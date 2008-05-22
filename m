From: David Miller <davem@davemloft.net>
Subject: [GIT]: Networking
Date: Wed, 21 May 2008 22:02:16 -0700 (PDT)
Message-ID: <20080521.220216.244948557.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51578
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751959AbYEVFCV convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 22 May 2008 01:02:21 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


More fixes:

1) Pull in wireless bug fixes from John Linville.

2) Sridhar Samudrala discovered that we do not respect a
   path MTU ICMP message that TCP receives after a certain=09
   number of retransmit retries.  This happens because at
   this point the socket cached route is NULL, and we reload
   it too late in retransmit processing for the PMTU to
   properly take effect.

   Reload the socket route to fix this bug.

3) Don't try to use IPV6 checksums provided by the HW in the
   cassini driver, it doesn't work for some users and we're
   not quite sure why yet.

4) Family of IPSEC selector not set correctly in AF_KEY socket layer,
   fix from Kazunori MIYAZAWA.  We had already fixed this in the
   xfrm_user layer, but simply forgot to propagate that fix over
   to AF_KEY.

5) Zero length algorithm key checks in xfrm_user are removed, they
   are valid in many cases, and the crypto layer will make sure the
   length is OK for us.

6) Several tunnel drivers have code which has existed for many
   years which is protected by a CPP conditional that there is
   no way to set without editing the code itself.  The build of
   this continually breaks, and this code can never conceivable
   be actually enabled, so it's better to just remove this stuff.

7) prior_ssthresh needs to be a u32 instead of a u16 to avoid
   potential overflows, fix from Ilpo Jarvinen.

8) Netfilter headers need to not __KERNEL__ protect linux/types.h
   inclusion, from Patrick McHardy.

Please pull, thanks a lot!

The following changes since commit d3ede327e83f202c3a0962e207318f65717c=
5eb7:
  Denis V. Lunev (1):
        pktgen: make sure that pktgen_thread_worker has been executed

are available in the git repository at:

  master.kernel.org:/pub/scm/linux/kernel/git/davem/net-2.6.git master

Bob Copeland (1):
      ath5k: Fix loop variable initializations

David S. Miller (3):
      Merge branch 'master' of master.kernel.org:/.../linville/wireless=
-2.6
      cassini: Only use chip checksum for ipv4 packets.
      xfrm_user: Remove zero length key checks.

David Woodhouse (1):
      libertas: Fix ethtool statistics

Denis Cheng (1):
      net/ipv4/arp.c: Use common hex_asc helpers

Helmut Schaa (1):
      mac80211: fix NULL pointer dereference in ieee80211_compatible_ra=
tes

Ilpo J=C3=A4rvinen (1):
      tcp: Make prior_ssthresh a u32

Johannes Berg (1):
      mac80211: don't claim iwspy support

Kazunori MIYAZAWA (1):
      af_key: Fix selector family initialization.

Oliver Neukum (1):
      rtl8187: resource leak in error case

Patrick McHardy (1):
      netfilter: Move linux/types.h inclusions outside of #ifdef __KERN=
EL__

Pavel Roskin (2):
      hostap_cs: add ID for Conceptronic CON11CPro
      orinoco_cs: add ID for SpeedStream wireless adapters

Rami Rosen (1):
      net: The world is not perfect patch.

Sridhar Samudrala (1):
      tcp: TCP connection times out if ICMP frag needed is delayed

 drivers/net/cassini.c                     |   11 ++-
 drivers/net/wireless/ath5k/base.c         |    2 +
 drivers/net/wireless/ath5k/hw.c           |    6 +-
 drivers/net/wireless/hostap/hostap_cs.c   |    1 +
 drivers/net/wireless/libertas/ethtool.c   |   27 +++---
 drivers/net/wireless/orinoco_cs.c         |    1 +
 drivers/net/wireless/rtl8187_dev.c        |   14 +++-
 include/linux/netfilter.h                 |    2 +-
 include/linux/netfilter_arp/arp_tables.h  |    2 +-
 include/linux/netfilter_ipv4/ip_tables.h  |    2 +-
 include/linux/netfilter_ipv6/ip6_tables.h |    2 +-
 include/linux/tcp.h                       |    2 +-
 net/ipv4/arp.c                            |    5 +-
 net/ipv4/ip_gre.c                         |  146 +--------------------=
--------
 net/ipv4/ipip.c                           |  130 +--------------------=
-----
 net/ipv4/tcp_output.c                     |   10 +-
 net/ipv6/sit.c                            |   89 +-----------------
 net/key/af_key.c                          |    2 +-
 net/mac80211/mlme.c                       |   15 ++-
 net/mac80211/wext.c                       |    1 -
 net/xfrm/xfrm_user.c                      |   11 --
 21 files changed, 68 insertions(+), 413 deletions(-)
