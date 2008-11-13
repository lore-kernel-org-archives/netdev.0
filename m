From: David Miller <davem@davemloft.net>
Subject: [GIT]: Networking
Date: Wed, 12 Nov 2008 16:31:21 -0800 (PST)
Message-ID: <20081112.163121.175570126.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:35882
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750777AbYKMAbV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Nov 2008 19:31:21 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Mostly driver fixes, as usual:

1) NIU driver doesn't work properly on 32-bit

2) BNX2 driver passes wrong object down into interrupt handler from
   ->poll_controller() and also doesn't check all RX queues.  Fix from
   Neil Horman.

3) put_cmsg_compat() uses SO_TIMESTAMP* instead of SCM_TIMESTAMP*
   They are the same values, but it makes the code super confusing
   to read.

4) EEPROM handling and multiqueue fixes to CXGB3 from Divy Le Ray.

5) HTCP congestion control module does not handle state transitions
   properly in all cases.  Certain actions, in particular the
   recording of the "last congestion event" timestamp, should only
   occur when we transition back to TCP_CA_OPEN from a state where we
   know loss occurred.  Fix from Doug Leith.

6) CXGB3 can deadlock due to incorrect RTNL semaphore grabbing, fix
   from Steve Wise.

7) Add new device IDs to rtl8187 driver, from Bob Jolliffe.

8) Fix smc911x resume, from Romit Dasgupta.

Please pull, thanks a lot!

The following changes since commit f21f237cf55494c3a4209de323281a3b0528da10:
  Linus Torvalds (1):
        Merge branch 'timers-fixes-for-linus' of git://git.kernel.org/.../tip/linux-2.6-tip

are available in the git repository at:

  master.kernel.org:/pub/scm/linux/kernel/git/davem/net-2.6.git master

Bob Jolliffe (1):
      rtl8187 : support for Sitecom WL-168 0001 v4

Brice Goglin (1):
      myri10ge: fix stop/go ordering even more

Dasgupta, Romit (1):
      [netdrvr] smc911x: fix for driver resume (and compilation warning)

David S. Miller (3):
      Merge branch 'davem-fixes' of master.kernel.org:/.../jgarzik/netdev-2.6
      niu: Fix readq implementation when architecture does not provide one.
      Merge branch 'master' of git://git.kernel.org/.../linville/wireless-2.6

Divy Le Ray (2):
      cxgb3 - eeprom read fixes
      cxgb3 - Limit multiqueue setting to msi-x

Doug Leith (1):
      tcp_htcp: last_cong bug fix

Ivan Kuten (1):
      rtl8187: Add Abocom USB ID

Johannes Berg (2):
      mac80211: fix notify_mac function
      hostap: pad the skb->cb usage in lieu of a proper fix

Neil Horman (1):
      bnx2: fix poll_controller to pass proper structures and check all rx queues

Patrick Ohly (1):
      net: put_cmsg_compat + SO_TIMESTAMP[NS]: use same name for value as caller

Steve Wise (1):
      RDMA/cxgb3: deadlock in iw_cxgb3 can cause hang when configuring interface.

 drivers/infiniband/hw/cxgb3/iwch_provider.c |    6 ------
 drivers/net/bnx2.c                          |    9 ++++++---
 drivers/net/cxgb3/cxgb3_main.c              |    4 +++-
 drivers/net/cxgb3/t3_hw.c                   |    8 +++++++-
 drivers/net/myri10ge/myri10ge.c             |    4 +++-
 drivers/net/niu.c                           |    3 +--
 drivers/net/smc911x.c                       |    4 +++-
 drivers/net/wireless/hostap/hostap_wlan.h   |    5 ++++-
 drivers/net/wireless/rtl8187_dev.c          |    3 +++
 net/compat.c                                |    4 ++--
 net/ipv4/tcp_htcp.c                         |   14 ++++++++++----
 net/mac80211/mlme.c                         |    6 +++---
 12 files changed, 45 insertions(+), 25 deletions(-)
