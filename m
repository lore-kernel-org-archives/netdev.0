From: David Miller <davem@davemloft.net>
Subject: [GIT] Networking
Date: Sun, 15 Jun 2014 19:33:12 -0700 (PDT)
Message-ID: <20140615.193312.2155181077359902619.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:43934 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752613AbaFPCdN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 15 Jun 2014 22:33:13 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


1) Fix checksumming regressions, from Tom Herbert.

2) Undo unintentional permissions changes for SCTP rto_alpha and
   rto_beta sysfs knobs, from Denial Borkmann.

3) VXLAN, like other IP tunnels, should advertize it's encapsulation
   size using dev->needed_headroom instead of dev->hard_header_len.
   From Cong Wang.

Please pull, thanks a lot!

The following changes since commit f9da455b93f6ba076935b4ef4589f61e529ae046:

  Merge git://git.kernel.org/pub/scm/linux/kernel/git/davem/net-next (2014-06-12 14:27:40 -0700)

are available in the git repository at:


  git://git.kernel.org/pub/scm/linux/kernel/git/davem/net.git master

for you to fetch changes up to b58537a1f5629bdc98a8b9dc2051ce0e952f6b4b:

  net: sctp: fix permissions for rto_alpha and rto_beta knobs (2014-06-15 01:17:32 -0700)

----------------------------------------------------------------
Cong Wang (1):
      vxlan: use dev->needed_headroom instead of dev->hard_header_len

Daniel Borkmann (1):
      net: sctp: fix permissions for rto_alpha and rto_beta knobs

David S. Miller (1):
      Merge branch 'csum_fixes'

Dimitris Michailidis (1):
      MAINTAINERS: update cxgb4 maintainer

Eric Dumazet (1):
      udp: ipv4: do not waste time in __udp4_lib_mcast_demux_lookup

Tom Herbert (5):
      net: Fix GSO constants to match NETIF flags
      net: Fix save software checksum complete
      udp: call __skb_checksum_complete when doing full checksum
      net: add skb_pop_rcv_encapsulation
      vxlan: Checksum fixes

 MAINTAINERS                     |  2 +-
 drivers/net/vxlan.c             | 18 +++++-------------
 include/linux/netdev_features.h |  1 +
 include/linux/netdevice.h       |  7 +++++++
 include/linux/skbuff.h          | 23 ++++++++++++++++++-----
 include/net/udp.h               |  4 +++-
 net/core/datagram.c             | 36 ++++++++++++++++++++++++++----------
 net/core/skbuff.c               |  3 +++
 net/ipv4/udp.c                  |  4 ++++
 net/sctp/sysctl.c               | 32 ++++++++++++++++++++++++++++----
 10 files changed, 96 insertions(+), 34 deletions(-)
