From: Phil Sutter <phil@nwl.cc>
Subject: [PATCH v2 0/4] improve fault-tolerance of rhashtable runtime-test
Date: Fri, 20 Nov 2015 18:17:16 +0100
Message-ID: <1448039840-11367-1-git-send-email-phil@nwl.cc>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	tgraf@suug.ch, fengguang.wu@intel.com, wfg@linux.intel.com,
	lkp@01.org
To: davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The following series aims to improve lib/test_rhashtable in different
situations:

Patch 1 allows the kernel to reschedule so the test does not block too
        long on slow systems.
Patch 2 fixes behaviour under pressure, retrying inserts in non-permanent
        error case (-EBUSY).
Patch 3 auto-adjusts the upper table size limit according to the number
        of threads (in concurrency test). In fact, the current default is
	already too small.
Patch 4 makes it possible to retry inserts even in supposedly permanent
        error case (-ENOMEM) to expose rhashtable's remaining problem of
	-ENOMEM being not as permanent as it is expected to be.

Changes since v1:
- Introduce insert_retry() which is then used in single-threaded test as
  well.
- Do not retry inserts by default if -ENOMEM was returned.
- Rename the retry counter to be a bit more verbose about what it
  contains.
- Add patch 4 as a debugging aid.

Phil Sutter (4):
  rhashtable-test: add cond_resched() to thread test
  rhashtable-test: retry insert operations
  rhashtable-test: calculate max_entries value by default
  rhashtable-test: allow to retry even if -ENOMEM was returned

 lib/test_rhashtable.c | 76 +++++++++++++++++++++++++++++++++------------------
 1 file changed, 50 insertions(+), 26 deletions(-)

-- 
2.1.2
