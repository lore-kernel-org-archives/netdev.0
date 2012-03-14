From: David Miller <davem@davemloft.net>
Subject: [GIT] Networking
Date: Tue, 13 Mar 2012 17:53:12 -0700 (PDT)
Message-ID: <20120313.175312.248147811152254607.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


The most important bit here is the TCP syncookies issue, which seems
to have been busted for some time.  That fix has been verified in
production by the reporter.

1) Persistent TUN devices erroneously hold on to the network
   namespace in such a way that it cannot be shutdown.  Fix
   from Stanislav Kinsbursky with help from Eric Dumazet.

2) TCP SYN cookies have been broken for a while due to how the route
   lookup flow key is managed, connections can be delayed by as much
   as 20 seconds due to this bug.  Fix from Eric Dumazet.

3) Missing jiffies.h include in lib/dynamic_queue_limits.c can break
   the build, from Tom Herbert.

4) Add USB device ID for Sitecom LN-031, from Joerg Neikes.

5) Fix OOPS in delayed workqueue in iwlegacy, from Stanislaw Gruszka.

6) rt2x00 TX queue can be disabled forever due to races, fix by
   synchronizing pause/unpause with a lock.  Also from Stanislaw
   Gruszka.

7) Statistics and endian fix in bnx2x driver from Yuval Mintz,
   Eilon Greenstein, and Ariel Elior.

Please pull, thanks a lot.

The following changes since commit 2f1c2b8155865ba3c2909f468ac8be60f52ed56b:

  Merge branch 'for_linus' of git://cavan.codon.org.uk/platform-drivers-x86 (2012-03-12 22:59:34 -0700)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/davem/net.git master

Ariel Elior (1):
      bnx2x: added cpu_to_le16 when preparing ramrod's data

Eric Dumazet (1):
      tcp: fix syncookie regression

Joerg Neikes (1):
      usb: asix: Patch for Sitecom LN-031

John W. Linville (1):
      Merge branch 'master' of git://git.kernel.org/.../linville/wireless into for-davem

Stanislav Kinsbursky (1):
      tun: don't hold network namespace by tun sockets

Stanislaw Gruszka (2):
      iwl3945: fix possible il->txq NULL pointer dereference in delayed works
      rt2x00: fix random stalls

Tom Herbert (1):
      dql: Fix undefined jiffies

Yuval Mintz (3):
      bnx2x: pfc statistics counts pfc events twice
      bnx2x: dcb bit indices flags used as bits
      bnx2x: FCoE statistics id fixed

 drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c   |    2 +-
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.h   |   12 ++++++--
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_dcb.c   |    8 +++--
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_sp.c    |    2 +-
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_stats.c |   12 --------
 drivers/net/tun.c                                 |   15 ++++++++--
 drivers/net/usb/asix.c                            |    4 +++
 drivers/net/wireless/iwlegacy/3945-mac.c          |    2 +-
 drivers/net/wireless/iwlegacy/3945.c              |    7 +++--
 drivers/net/wireless/rt2x00/rt2x00dev.c           |    6 +++-
 drivers/net/wireless/rt2x00/rt2x00mac.c           |    9 ++++++
 drivers/net/wireless/rt2x00/rt2x00queue.c         |    3 ++
 lib/dynamic_queue_limits.c                        |    1 +
 net/ipv4/syncookies.c                             |   30 +++++++++++---------
 net/ipv4/tcp_ipv4.c                               |   10 +++++--
 15 files changed, 78 insertions(+), 45 deletions(-)
