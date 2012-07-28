From: David Miller <davem@davemloft.net>
Subject: [GIT] Networking
Date: Sat, 28 Jul 2012 00:52:41 -0700 (PDT)
Message-ID: <20120728.005241.2226926028836664098.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:39915 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751917Ab2G1Hwn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 28 Jul 2012 03:52:43 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Several bug fixes, some to new features appearing in this merge window,
some that have been around for a while.

I have a short list of known problems that need to be sorted out, but
all of them can be solved easily during the run up to 3.6-final.

I'll be offline until Sunday afternoon, but nothing need hold up
3.6-rc1 and the close of the merge window, networking wise, at this
point.

1) Fix interface check in ipv4 TCP early demux, from Eric Dumazet.

2) Fix a long standing bug in TCP DMA to userspace offload that can
   hang applications using MSG_TRUNC, from Jiri Kosina.

3) Don't allow TCP_USER_TIMEOUT to be negative, from Hangbin Liu.

4) Don't use GFP_KERNEL under spinlock in kaweth driver, from Dan
   Carpenter

Please pull, thanks a lot.

The following changes since commit b387e41e523c1aa347cff055455d0dd129357df4:

  Merge branch 'merge' of git://git.kernel.org/pub/scm/linux/kernel/git/benh/powerpc (2012-07-27 08:35:26 -0700)

are available in the git repository at:


  git://git.kernel.org/pub/scm/linux/kernel/git/davem/net.git master

for you to fetch changes up to 7b9b04fb728ec0b94464ed902f3395aa592c5bcf:

  Merge branch 'for-davem' of git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless (2012-07-27 14:25:40 -0700)

----------------------------------------------------------------

Dan Carpenter (1):
      USB: kaweth.c: use GFP_ATOMIC under spin_lock

David S. Miller (1):
      Merge branch 'for-davem' of git://git.kernel.org/.../linville/wireless

Eric Dumazet (1):
      ipv4: fix TCP early demux

Hangbin Liu (1):
      tcp: Add TCP_USER_TIMEOUT negative value check

Hauke Mehrtens (2):
      bcma: fix regression in interrupt assignment on mips
      bcma: add missing iounmap on error path

Jesse Gross (1):
      Revert "openvswitch: potential NULL deref in sample()"

Jiri Benc (1):
      net: fix rtnetlink IFF_PROMISC and IFF_ALLMULTI handling

Jiri Kosina (1):
      tcp: perform DMA to userspace only if there is a task waiting for it

John W. Linville (1):
      Merge branch 'master' of git://git.kernel.org/.../linville/wireless into for-davem

Thomas Huehn (1):
      mac80211_hwsim: fix possible race condition in usage of info->control.sta & control.vif

 drivers/bcma/driver_mips.c            |  6 +++---
 drivers/bcma/scan.c                   | 15 ++++++++++-----
 drivers/net/usb/kaweth.c              |  2 +-
 drivers/net/wireless/mac80211_hwsim.c |  5 -----
 net/core/rtnetlink.c                  |  8 +++++++-
 net/ipv4/tcp.c                        |  5 ++++-
 net/ipv4/tcp_input.c                  |  5 ++++-
 net/ipv4/tcp_ipv4.c                   | 14 ++++++--------
 net/ipv4/tcp_minisocks.c              |  1 +
 net/openvswitch/actions.c             |  3 ---
 10 files changed, 36 insertions(+), 28 deletions(-)
