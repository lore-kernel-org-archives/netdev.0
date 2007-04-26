From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 00/14] AF_RXRPC socket family and AFS rewrite [net-2.6]
Date: Thu, 26 Apr 2007 16:15:22 -0700 (PDT)
Message-ID: <20070426.161522.76328746.davem@davemloft.net>
References: <20070426195415.24531.78794.stgit@warthog.cambridge.redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: dhowells@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:57604
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1755190AbXDZXPQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Apr 2007 19:15:16 -0400
In-Reply-To: <20070426195415.24531.78794.stgit@warthog.cambridge.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: David Howells <dhowells@redhat.com>
Date: Thu, 26 Apr 2007 20:54:15 +0100

> [This set of patches is built against Dave Miller's net-2.6 GIT tree]

Ok, I applied it all and added a compiler warning fix for 64-bit
at the end.

Thanks for all of your hard work pushing this stuff along David.

commit ba3e0e1accd8d5bb12eaeb0977429d8dc04f6d1e
Author: David S. Miller <davem@sunset.davemloft.net>
Date:   Thu Apr 26 16:06:22 2007 -0700

    [AFS]: Fix u64 printing in debug logging.
    
    Need 'unsigned long long' casts to quiet warnings on
    64-bit platforms when using %ll on a u64.
    
    Signed-off-by: David S. Miller <davem@davemloft.net>

diff --git a/fs/afs/dir.c b/fs/afs/dir.c
index dbbe75d..dac5b99 100644
--- a/fs/afs/dir.c
+++ b/fs/afs/dir.c
@@ -419,7 +419,8 @@ static int afs_lookup_filldir(void *_cookie, const char *name, int nlen,
 	struct afs_lookup_cookie *cookie = _cookie;
 
 	_enter("{%s,%Zu},%s,%u,,%llu,%u",
-	       cookie->name, cookie->nlen, name, nlen, ino, dtype);
+	       cookie->name, cookie->nlen, name, nlen,
+	       (unsigned long long) ino, dtype);
 
 	/* insanity checks first */
 	BUILD_BUG_ON(sizeof(union afs_dir_block) != 2048);
diff --git a/fs/afs/fsclient.c b/fs/afs/fsclient.c
index f036b4c..2393d2a 100644
--- a/fs/afs/fsclient.c
+++ b/fs/afs/fsclient.c
@@ -105,7 +105,8 @@ static void xdr_decode_AFSFetchStatus(const __be32 **_bp,
 		status->data_version = data_version;
 		if (vnode && !test_bit(AFS_VNODE_UNSET, &vnode->flags)) {
 			_debug("vnode modified %llx on {%x:%u}",
-			       data_version, vnode->fid.vid, vnode->fid.vnode);
+			       (unsigned long long) data_version,
+			       vnode->fid.vid, vnode->fid.vnode);
 			set_bit(AFS_VNODE_MODIFIED, &vnode->flags);
 			set_bit(AFS_VNODE_ZAP_DATA, &vnode->flags);
 		}
diff --git a/fs/afs/inode.c b/fs/afs/inode.c
index 56ca858..c184a4e 100644
--- a/fs/afs/inode.c
+++ b/fs/afs/inode.c
@@ -36,7 +36,7 @@ static int afs_inode_map_status(struct afs_vnode *vnode, struct key *key)
 	_debug("FS: ft=%d lk=%d sz=%llu ver=%Lu mod=%hu",
 	       vnode->status.type,
 	       vnode->status.nlink,
-	       vnode->status.size,
+	       (unsigned long long) vnode->status.size,
 	       vnode->status.data_version,
 	       vnode->status.mode);
 
