From: Christoph Lameter <clameter@sgi.com>
Subject: [patch 18/21] Filesystem: Socket inode defragmentation
Date: Fri, 09 May 2008 20:08:49 -0700
Message-ID: <20080510030918.882272887@sgi.com>
References: <20080510030831.796641881@sgi.com>
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: akpm@linux-foundation.org
Return-path: <linux-fsdevel-owner@vger.kernel.org>
CC: linux-fsdevel@vger.kernel.org
Cc: Mel Gorman <mel@skynet.ie>
Cc: andi@firstfloor.org
Cc: Rik van Riel <riel@redhat.com>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: mpm@selenic.com
Content-Disposition: inline; filename=0030-FS-Socket-inode-defragmentation.patch
Sender: linux-fsdevel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Support inode defragmentation for sockets

Cc: netdev@vger.kernel.org
Reviewed-by: Rik van Riel <riel@redhat.com>
Signed-off-by: Christoph Lameter <clameter@sgi.com>
---
 net/socket.c |    8 ++++++++
 1 files changed, 8 insertions(+), 0 deletions(-)

diff --git a/net/socket.c b/net/socket.c
index 9d3fbfb..205f450 100644
--- a/net/socket.c
+++ b/net/socket.c
@@ -269,6 +269,12 @@ static void init_once(struct kmem_cache *cachep, void *foo)
 	inode_init_once(&ei->vfs_inode);
 }
 
+static void *sock_get_inodes(struct kmem_cache *s, int nr, void **v)
+{
+	return fs_get_inodes(s, nr, v,
+		offsetof(struct socket_alloc, vfs_inode));
+}
+
 static int init_inodecache(void)
 {
 	sock_inode_cachep = kmem_cache_create("sock_inode_cache",
@@ -280,6 +286,8 @@ static int init_inodecache(void)
 					      init_once);
 	if (sock_inode_cachep == NULL)
 		return -ENOMEM;
+	kmem_cache_setup_defrag(sock_inode_cachep,
+			sock_get_inodes, kick_inodes);
 	return 0;
 }
 
-- 
1.5.4.4

-- 
