From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Subject: [PATCH 12/20] nbd: limit blk_queue
Date: Tue, 12 Sep 2006 17:25:49 +0200
Message-ID: <20060912144904.299910000@chello.nl>
References: <20060912143049.278065000@chello.nl>
Cc: Linus Torvalds <torvalds@osdl.org>, Andrew Morton <akpm@osdl.org>,
	David Miller <davem@davemloft.net>,
	Rik van Riel <riel@redhat.com>,
	Daniel Phillips <phillips@google.com>,
	Peter Zijlstra <a.p.zijlstra@chello.nl>,
	Pavel Machek <pavel@ucw.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from amsfep17-int.chello.nl ([213.46.243.15]:59119 "EHLO
	amsfep19-int.chello.nl") by vger.kernel.org with ESMTP
	id S1751441AbWILPvD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 12 Sep 2006 11:51:03 -0400
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
Content-Disposition: inline; filename=nbd_queue.patch
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Limit each request to 1 page, so that the request throttling also limits the
number of in-flight pages.

Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
Signed-off-by: Daniel Phillips <phillips@google.com>
CC: Pavel Machek <pavel@ucw.cz>
---
 drivers/block/nbd.c |   17 +++++++++++++++--
 1 file changed, 15 insertions(+), 2 deletions(-)

Index: linux-2.6/drivers/block/nbd.c
===================================================================
--- linux-2.6.orig/drivers/block/nbd.c	2006-09-07 18:43:41.000000000 +0200
+++ linux-2.6/drivers/block/nbd.c	2006-09-07 18:44:12.000000000 +0200
@@ -638,6 +638,9 @@ static int __init nbd_init(void)
 			put_disk(disk);
 			goto out;
 		}
+		blk_queue_max_segment_size(disk->queue, PAGE_SIZE);
+		blk_queue_max_hw_segments(disk->queue, 1);
+		blk_queue_max_phys_segments(disk->queue, 1);
 	}
 
 	if (register_blkdev(NBD_MAJOR, "nbd")) {

--

