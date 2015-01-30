From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH 0/6 net-next] rhashtable fixes
Date: Fri, 30 Jan 2015 01:20:37 +0100
Message-ID: <cover.1422576760.git.tgraf@suug.ch>
Cc: netdev@vger.kernel.org, ying.xue@windriver.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([198.137.202.9]:53161 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758834AbbA3AUs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Jan 2015 19:20:48 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a series of fixes which have accumulated while tracking
down the race condition reoprted by Ying Xue. The original
DEBUG_PAGEALLOC splat is resolved.

However, there is still a race (harder to trigger) remaining in
which certain entries are unfindable when removing them from the
table via netlink_remove() and thus they cause a use after free
later on.

Regardless, these fixes can go in now.

Thomas Graf (6):
  rhashtable: key_hashfn() must return full hash value
  rhashtable: Use a single bucket lock for sibling buckets
  rhashtable: Wait for RCU readers after final unzip work
  rhashtable: Dump bucket tables on locking violation under
    PROVE_LOCKING
  rhashtable: Add more lock verification
  rhashtable: Avoid bucket cross reference after removal

 lib/rhashtable.c | 301 ++++++++++++++++++++++++++++++-------------------------
 1 file changed, 166 insertions(+), 135 deletions(-)

-- 
1.9.3
