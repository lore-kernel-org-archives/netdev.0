From: Alexander Duyck <alexander.h.duyck@intel.com>
Subject: [RFC PATCH 0/2] Coalesce MMIO writes for transmits
Date: Wed, 11 Jul 2012 17:25:58 -0700
Message-ID: <20120712002103.27846.73812.stgit@gitlad.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, jeffrey.t.kirsher@intel.com,
	edumazet@google.com, bhutchings@solarflare.com,
	therbert@google.com, alexander.duyck@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:21069 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755954Ab2GLAZh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 11 Jul 2012 20:25:37 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch set is meant to address recent issues I found with ixgbe
performance being bound by Tx tail writes.  With these changes in place
and the dispatch_limit set to 1 or more I see a significant increase in
performance.

In the case of one of my systems I saw the routing rate for 7 queues jump
from 10.5 to 11.7Mpps.  The overall increase I have seen on most systems is
something on the order of about 15%.  In the case of pktgen I have also
seen a noticeable increase as the previous limit for transmits was
~12.5Mpps, but with this patch set in place and the dispatch_limit enabled
the value increases to ~14.2Mpps.

I expected there to be an increase in latency, however so far I have not
ran into that.  I have tried running NPtcp tests for latency and seen no
difference in the coalesced and non-coalesced transaction times.  I welcome
any suggestions for tests I might run that might expose any latency issues
as a result of this patch.

---

Alexander Duyck (2):
      ixgbe: Add functionality for delaying the MMIO write for Tx
      net: Add new network device function to allow for MMIO batching


 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c |   22 +++++++-
 include/linux/netdevice.h                     |   57 +++++++++++++++++++++
 net/core/dev.c                                |   67 +++++++++++++++++++++++++
 net/core/net-sysfs.c                          |   36 +++++++++++++
 4 files changed, 180 insertions(+), 2 deletions(-)

-- 
Thanks,

Alex
