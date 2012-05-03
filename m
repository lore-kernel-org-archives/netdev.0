From: Alexander Duyck <alexander.h.duyck@intel.com>
Subject: [v2 PATCH 0/4] Cleanup tcp_try_coalesce, fix module lockup on ixgbe
Date: Thu, 03 May 2012 00:18:54 -0700
Message-ID: <20120503071141.13636.37564.stgit@gitlad.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, jeffrey.t.kirsher@intel.com,
	edumazet@google.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:46583 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754732Ab2ECHSk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 3 May 2012 03:18:40 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This set represents the original patch I had done for trying to cleanup
tcp_try_coalesce broken into 3 patches.  The first one illustrates how I
believe we should be updating the truesize based on either the size of
sk_buff in the case of head reuse, or sk_buff plus the size of the head in
the case of a headlen of 0.

The other two patches go through and reorder things so there isn't as much
need for gotos.  I believe it makes the code much more readable since it
starts at the top and finishes at the bottom instead of looping through the
entire code path a few times.

The last patch addresses an issue I ran into on ixgbe.  It turns out the
recent HWMON patch added a but on 82598 adapters that caused the driver to
get hung in module unload.  I figured I would submit it directly since it
is a small change to fix an issue that could have a larger impact.

On that note I am going to sleep now and will respond to any reviews and/or
comments in the morning.

---

Alexander Duyck (4):
      ixgbe: Fix use after free on module remove
      tcp: move stats merge to the end of tcp_try_coalesce
      tcp: Move code related to head frag in tcp_try_coalesce
      tcp: Fix truesize accounting in tcp_try_coalesce


 drivers/net/ethernet/intel/ixgbe/ixgbe_sysfs.c |    4 +
 net/ipv4/tcp_input.c                           |   83 +++++++++++++-----------
 2 files changed, 49 insertions(+), 38 deletions(-)

-- 

Thanks,

Alex
