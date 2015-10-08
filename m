From: Jason Baron <jbaron@akamai.com>
Subject: [PATCH v3 0/3] net: unix: fix use-after-free
Date: Wed,  7 Oct 2015 23:19:34 -0400
Message-ID: <cover.1444272769.git.jbaron@akamai.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	minipli@googlemail.com, normalperson@yhbt.net,
	eric.dumazet@gmail.com, rweikusat@mobileactivedefense.com,
	viro@zeniv.linux.org.uk, davidel@xmailserver.org,
	dave@stgolabs.net, olivier@mauras.ch, pageexec@freemail.hu,
	torvalds@linux-foundation.org, peterz@infradead.org,
	joe@perches.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from a23-79-238-175.deploy.static.akamaitechnologies.com ([23.79.238.175]:53028
	"EHLO prod-mail-xrelay07.akamai.com" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751039AbbJHDWA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Oct 2015 23:22:00 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

These patches are against mainline, I can re-base to net-next, just
let me know.

They have been tested against: https://lkml.org/lkml/2015/9/13/195,
which causes the use-after-free quite quickly and here:
https://lkml.org/lkml/2015/10/2/693.

Thanks,

-Jason

v3:
-beef up memory barrier comments in 3/3 (Peter Zijlstra)
-clean up unix_dgram_writable() function in 3/3 (Joe Perches)

Jason Baron (3):
  net: unix: fix use-after-free in unix_dgram_poll()
  net: unix: Convert gc_flags to flags
  net: unix: optimize wakeups in unix_dgram_recvmsg()

 include/net/af_unix.h |   4 +-
 net/unix/af_unix.c    | 117 +++++++++++++++++++++++++++++++++++++++-----------
 net/unix/garbage.c    |  12 +++---
 3 files changed, 101 insertions(+), 32 deletions(-)

-- 
2.6.1
