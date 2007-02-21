From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Subject: [PATCH 25/29] nfs: only use stable storage for swap
Date: Wed, 21 Feb 2007 15:43:29 +0100
Message-ID: <20070221144843.989983000@taijtu.programming.kicks-ass.net>
References: <20070221144304.512721000@taijtu.programming.kicks-ass.net>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>,
	Trond Myklebust <trond.myklebust@fys.uio.no>,
	Thomas Graf <tgraf@suug.ch>, David Miller <davem@davemloft.net>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:34536 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751299AbXBUPFf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 21 Feb 2007 10:05:35 -0500
Content-Disposition: inline; filename=nfs-wb_priority.patch
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

unstable writes don't make sense for swap pages.

Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Trond Myklebust <trond.myklebust@fys.uio.no>
---
 fs/nfs/write.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

Index: linux-2.6-git/fs/nfs/write.c
===================================================================
--- linux-2.6-git.orig/fs/nfs/write.c	2007-02-21 12:15:10.000000000 +0100
+++ linux-2.6-git/fs/nfs/write.c	2007-02-21 12:15:13.000000000 +0100
@@ -197,7 +197,7 @@ static int nfs_writepage_setup(struct nf
 static int wb_priority(struct writeback_control *wbc)
 {
 	if (wbc->for_reclaim)
-		return FLUSH_HIGHPRI;
+		return FLUSH_HIGHPRI|FLUSH_STABLE;
 	if (wbc->for_kupdate)
 		return FLUSH_LOWPRI;
 	return 0;

-- 

