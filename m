From: akpm@linux-foundation.org
Subject: [patch 08/15] sunrpc: cleanup: use seq_release_private() where appropriate
Date: Thu, 26 Apr 2007 00:27:27 -0700
Message-ID: <200704260727.l3Q7RR5a023964@shell0.pdx.osdl.net>
Cc: netdev@vger.kernel.org, akpm@linux-foundation.org, mp3@de.ibm.com,
	neilb@suse.de, trond.myklebust@fys.uio.no
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([65.172.181.25]:38096 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S933387AbXDZH2Y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Apr 2007 03:28:24 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Martin Peschke <mp3@de.ibm.com>

We can save some lines of code by using seq_release_private().

Signed-off-by: Martin Peschke <mp3@de.ibm.com>
Cc: Trond Myklebust <trond.myklebust@fys.uio.no>
Acked-by: Neil Brown <neilb@suse.de>
Cc: "David S. Miller" <davem@davemloft.net>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 net/sunrpc/cache.c |   10 +---------
 1 file changed, 1 insertion(+), 9 deletions(-)

diff -puN net/sunrpc/cache.c~sunrpc-cleanup-use-seq_release_private-where-appropriate net/sunrpc/cache.c
--- a/net/sunrpc/cache.c~sunrpc-cleanup-use-seq_release_private-where-appropriate
+++ a/net/sunrpc/cache.c
@@ -1237,20 +1237,12 @@ static int content_open(struct inode *in
 
 	return res;
 }
-static int content_release(struct inode *inode, struct file *file)
-{
-	struct seq_file *m = (struct seq_file *)file->private_data;
-	struct handle *han = m->private;
-	kfree(han);
-	m->private = NULL;
-	return seq_release(inode, file);
-}
 
 static const struct file_operations content_file_operations = {
 	.open		= content_open,
 	.read		= seq_read,
 	.llseek		= seq_lseek,
-	.release	= content_release,
+	.release	= seq_release_private,
 };
 
 static ssize_t read_flush(struct file *file, char __user *buf,
_
