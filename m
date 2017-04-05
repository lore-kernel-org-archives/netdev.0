From: Vlastimil Babka <vbabka@suse.cz>
Subject: [PATCH 0/4] more robust PF_MEMALLOC handling
Date: Wed,  5 Apr 2017 09:46:56 +0200
Message-ID: <20170405074700.29871-1-vbabka@suse.cz>
Cc: linux-mm@kvack.org,
	linux-kernel@vger.kernel.org,
	Michal Hocko <mhocko@kernel.org>,
	Mel Gorman <mgorman@techsingularity.net>,
	Johannes Weiner <hannes@cmpxchg.org>,
	linux-block@vger.kernel.org,
	nbd-general@lists.sourceforge.net,
	open-iscsi@googlegroups.com,
	linux-scsi@vger.kernel.org,
	netdev@vger.kernel.org,
	Vlastimil Babka <vbabka@suse.cz>,
	Andrey Ryabinin <aryabinin@virtuozzo.com>,
	Boris Brezillon <boris.brezillon@free-electrons.com>,
	Chris Leech <cleech@redhat.com>,
	"David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Josef Bacik <jbacik@fb.com>,
	Lee Duncan <lduncan@suse.com>,
	Michal Hocko <mhocko@suse.com>,
	Richard Weinberger <richard@nod.at>,
	stable@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <owner-linux-mm@kvack.org>
Sender: owner-linux-mm@kvack.org
List-Id: netdev.vger.kernel.org

Hi,

this series aims to unify the setting and clearing of PF_MEMALLOC, which
prevents recursive reclaim. There are some places that clear the flag
unconditionally from current->flags, which may result in clearing a
pre-existing flag. This already resulted in a bug report that Patch 1 fixes
(without the new helpers, to make backporting easier). Patch 2 introduces the
new helpers, modelled after existing memalloc_noio_* and memalloc_nofs_*
helpers, and converts mm core to use them. Patches 3 and 4 convert non-mm code.

Based on next-20170404.

Vlastimil Babka (4):
  mm: prevent potential recursive reclaim due to clearing PF_MEMALLOC
  mm: introduce memalloc_noreclaim_{save,restore}
  treewide: convert PF_MEMALLOC manipulations to new helpers
  mtd: nand: nandsim: convert to memalloc_noreclaim_*()

 drivers/block/nbd.c        |  7 ++++---
 drivers/mtd/nand/nandsim.c | 29 +++++++++--------------------
 drivers/scsi/iscsi_tcp.c   |  7 ++++---
 include/linux/sched/mm.h   | 12 ++++++++++++
 mm/page_alloc.c            | 10 ++++++----
 mm/vmscan.c                | 17 +++++++++++------
 net/core/dev.c             |  7 ++++---
 net/core/sock.c            |  7 ++++---
 8 files changed, 54 insertions(+), 42 deletions(-)

-- 
2.12.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
