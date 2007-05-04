From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Subject: [PATCH 30/40] nfs: fixup missing error code
Date: Fri, 04 May 2007 12:27:21 +0200
Message-ID: <20070504103202.468420061@chello.nl>
References: <20070504102651.923946304@chello.nl>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>,
	Trond Myklebust <trond.myklebust@fys.uio.no>,
	Thomas Graf <tgraf@suug.ch>,
	David Miller <davem@davemloft.net>,
	James Bottomley <James.Bottomley@SteelEye.com>,
	Mike Christie <michaelc@cs.wisc.edu>,
	Andrew Morton <akpm@linux-foundation.org>,
	Daniel Phillips <phillips@google.com>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from amsfep17-int.chello.nl ([213.46.243.15]:46698 "EHLO
	amsfep12-int.chello.nl" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1754639AbXEDKgD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 May 2007 06:36:03 -0400
Content-Disposition: inline; filename=nfs_fix.patch
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Commit 0b67130149b006628389ff3e8f46be9957af98aa lost the setting of tk_status
to -EIO when there was no progress with short reads.

Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
---
 fs/nfs/read.c |    4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

Index: linux-2.6-git/fs/nfs/read.c
===================================================================
--- linux-2.6-git.orig/fs/nfs/read.c	2007-03-13 14:35:53.000000000 +0100
+++ linux-2.6-git/fs/nfs/read.c	2007-03-13 14:36:05.000000000 +0100
@@ -384,8 +384,10 @@ static int nfs_readpage_retry(struct rpc
 	/* This is a short read! */
 	nfs_inc_stats(data->inode, NFSIOS_SHORTREAD);
 	/* Has the server at least made some progress? */
-	if (resp->count == 0)
+	if (resp->count == 0) {
+		task->tk_status = -EIO;
 		return 0;
+	}
 
 	/* Yes, so retry the read at the end of the data */
 	argp->offset += resp->count;

--

