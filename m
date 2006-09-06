From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Subject: [PATCH 08/21] nfs: enable swap on NFS
Date: Wed, 06 Sep 2006 15:16:38 +0200
Message-ID: <20060906133954.264033000@chello.nl>
References: <20060906131630.793619000@chello.nl>>
Cc: Daniel Phillips <phillips@google.com>,
	Rik van Riel <riel@redhat.com>,
	David Miller <davem@davemloft.net>,
	Andrew Morton <akpm@osdl.org>,
	Peter Zijlstra <a.p.zijlstra@chello.nl>,
	Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <netdev-owner@vger.kernel.org>
Received: from amsfep17-int.chello.nl ([213.46.243.15]:2837 "EHLO
	amsfep14-int.chello.nl") by vger.kernel.org with ESMTP
	id S1751070AbWIFN5d (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 6 Sep 2006 09:57:33 -0400
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
Content-Disposition: inline; filename=nfs_swapfile.patch
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Now that NFS can handle swap cache pages, add a swapfile method to allow
swapping over NFS.

NOTE: this dummy method is obviously not enough to make it safe.
A more complete version of the nfs_swapfile() function will be present
in the next VM deadlock avoidance patches.

Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
CC: Trond Myklebust <trond.myklebust@fys.uio.no>
---
 fs/nfs/file.c |    6 ++++++
 1 file changed, 6 insertions(+)

Index: linux-2.6/fs/nfs/file.c
===================================================================
--- linux-2.6.orig/fs/nfs/file.c
+++ linux-2.6/fs/nfs/file.c
@@ -321,6 +321,11 @@ static int nfs_release_page(struct page 
 		return 0;
 }
 
+static int nfs_swapfile(struct address_space *mapping, int enable)
+{
+	return 0;
+}
+
 const struct address_space_operations nfs_file_aops = {
 	.readpage = nfs_readpage,
 	.readpages = nfs_readpages,
@@ -334,6 +339,7 @@ const struct address_space_operations nf
 #ifdef CONFIG_NFS_DIRECTIO
 	.direct_IO = nfs_direct_IO,
 #endif
+	.swapfile = nfs_swapfile,
 };
 
 /* 

--
