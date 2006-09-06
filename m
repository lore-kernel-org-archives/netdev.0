From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Subject: [PATCH 07/21] nfs: add a comment explaining the use of PG_private in the NFS client
Date: Wed, 06 Sep 2006 15:16:37 +0200
Message-ID: <20060906133954.023622000@chello.nl>
References: <20060906131630.793619000@chello.nl>>
Cc: Daniel Phillips <phillips@google.com>,
	Rik van Riel <riel@redhat.com>,
	David Miller <davem@davemloft.net>,
	Andrew Morton <akpm@osdl.org>,
	Peter Zijlstra <a.p.zijlstra@chello.nl>,
	Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1750949AbWIFNjI@vger.kernel.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
Content-Disposition: inline; filename=nfs_PG_private_comment.patch
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
CC: Trond Myklebust <trond.myklebust@fys.uio.no>
---
 fs/nfs/write.c |    5 +++++
 1 file changed, 5 insertions(+)

Index: linux-2.6/fs/nfs/write.c
===================================================================
--- linux-2.6.orig/fs/nfs/write.c
+++ linux-2.6/fs/nfs/write.c
@@ -424,6 +424,11 @@ static int nfs_inode_add_request(struct 
 		if (nfs_have_delegation(inode, FMODE_WRITE))
 			nfsi->change_attr++;
 	}
+	/*
+	 * The PG_private bit is unfortunately needed if we want to fix the
+	 * hole in the mmap semantics. If we do not set it, then the VM will
+	 * fail to call the "releasepage" address ops.
+	 */
 	SetPagePrivate(req->wb_page);
 	nfsi->npages++;
 	atomic_inc(&req->wb_count);

--
