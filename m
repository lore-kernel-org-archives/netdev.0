From: David Miller <davem@davemloft.net>
Subject: [GIT]: Networking
Date: Thu, 05 Feb 2009 15:59:45 -0800 (PST)
Message-ID: <20090205.155945.262721512.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:38650
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753424AbZBEX7t (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Feb 2009 18:59:49 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


1) UDP input calculates the UDP header pointer before potentially
   reallocating the SKB data (thus making that pointer invalid).
   Fix from Jesper Brouer.

2) The TCP URG revert...

3) gianfar driver fixes from Andy Fleming

4) Wireless driver fixes via John Linville

5) RAW ipv6 socket send calls using MSG_MORE can retain kernel stack
   pointers in the socket cork area where we store options.  Just
   copy these things to avoid the problem as nobody cares about
   performance when using socket options in weird ways like this.

   This fixes crashes when using the icmpv6fuzz tool.

   Fix from Herbert Xu.

6) cxgb3 LRO enable bug fix from Divy Le Ray

Please pull, thanks a lot!

The following changes since commit f01d1d546abb2f4028b5299092f529eefb01253a:
  Alexey Dobriyan (1):
        seq_file: fix big-enough lseek() + read()

are available in the git repository at:

  master.kernel.org:/pub/scm/linux/kernel/git/davem/net-2.6.git master

Andy Fleming (2):
      gianfar: Fix BD_LENGTH_MASK definition
      gianfar: Fix potential soft reset race

David S. Miller (2):
      Merge branch 'master' of git://git.kernel.org/.../linville/wireless-2.6
      Revert "tcp: Always set urgent pointer if it's beyond snd_nxt"

Divy Le Ray (1):
      cxgb3: Fix lro switch

Herbert Xu (1):
      ipv6: Copy cork options in ip6_append_data

Jesper Dangaard Brouer (1):
      udp: Fix UDP short packet false positive

Reinette Chatre (2):
      iwlwifi: clean key table in iwl_clear_stations_table
      iwlwifi: save PCI state before suspend, restore after resume

 drivers/net/cxgb3/sge.c                     |    3 +-
 drivers/net/gianfar.c                       |    3 +
 drivers/net/gianfar.h                       |    2 +-
 drivers/net/wireless/iwlwifi/iwl-agn.c      |    2 +
 drivers/net/wireless/iwlwifi/iwl-sta.c      |    3 +
 drivers/net/wireless/iwlwifi/iwl3945-base.c |    2 +
 net/ipv4/tcp_output.c                       |   12 ++---
 net/ipv4/udp.c                              |    3 +-
 net/ipv6/ip6_output.c                       |   67 +++++++++++++++++++++------
 9 files changed, 70 insertions(+), 27 deletions(-)
