From: Jason Baron <jbaron@akamai.com>
Subject: [PATCH v4 0/3] net: unix: fix use-after-free
Date: Fri,  9 Oct 2015 00:15:59 -0400
Message-ID: <cover.1444363559.git.jbaron@akamai.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	minipli@googlemail.com, normalperson@yhbt.net,
	eric.dumazet@gmail.com, rweikusat@mobileactivedefense.com,
	viro@zeniv.linux.org.uk, davidel@xmailserver.org,
	dave@stgolabs.net, olivier@mauras.ch, pageexec@freemail.hu,
	torvalds@linux-foundation.org, peterz@infradead.org,
	joe@perches.com
To: davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

These patches are against mainline, I can re-base to net-next, please
let me know.

They have been tested against: https://lkml.org/lkml/2015/9/13/195,
which causes the use-after-free quite quickly and here:
https://lkml.org/lkml/2015/10/2/693.

Thanks,

-Jason

v4:
-set UNIX_NOSPACE only if the peer socket has receive space

v3:
-beef up memory barrier comments in 3/3 (Peter Zijlstra)
-clean up unix_dgram_writable() function in 3/3 (Joe Perches)

Jason Baron (3):
  net: unix: fix use-after-free in unix_dgram_poll()
  net: unix: Convert gc_flags to flags
  net: unix: optimize wakeups in unix_dgram_recvmsg()

 include/net/af_unix.h |   4 +-
 net/unix/af_unix.c    | 124 ++++++++++++++++++++++++++++++++++++++++----------
 net/unix/garbage.c    |  12 ++---
 3 files changed, 108 insertions(+), 32 deletions(-)

-- 
2.6.1
