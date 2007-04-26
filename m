From: David Howells <dhowells@redhat.com>
Subject: [PATCH 05/14] AFS: Clean up the AFS sources [net-2.6]
Date: Thu, 26 Apr 2007 20:54:41 +0100
Message-ID: <20070426195441.24531.63876.stgit@warthog.cambridge.redhat.com>
References: <20070426195415.24531.78794.stgit@warthog.cambridge.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: dhowells@redhat.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:57869 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754991AbXDZTy4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 26 Apr 2007 15:54:56 -0400
Received: from int-mx1.corp.redhat.com (int-mx1.corp.redhat.com [172.16.52.254])
	by mx1.redhat.com (8.13.1/8.13.1) with ESMTP id l3QJssI9028489
	for <netdev@vger.kernel.org>; Thu, 26 Apr 2007 15:54:54 -0400
In-Reply-To: <20070426195415.24531.78794.stgit@warthog.cambridge.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Clean up the AFS sources.

Also remove references to AFS keys.  RxRPC keys are used instead.

David
---

 fs/afs/Makefile     |    2 -
 fs/afs/cache.h      |   12 +---
 fs/afs/callback.c   |    9 +--
 fs/afs/cell.c       |   51 ++++++----------
 fs/afs/cell.h       |   30 +++-------
 fs/afs/cmservice.c  |   46 ++++-----------
 fs/afs/cmservice.h  |   17 +++--
 fs/afs/dir.c        |   50 ++++++----------
 fs/afs/errors.h     |   14 +++-
 fs/afs/file.c       |   20 ++----
 fs/afs/fsclient.c   |   73 ++++++++++-------------
 fs/afs/fsclient.h   |   48 ++++++++-------
 fs/afs/inode.c      |   29 +++------
 fs/afs/internal.h   |   36 ++++-------
 fs/afs/kafsasyncd.c |   22 ++-----
 fs/afs/kafsasyncd.h |   22 +++----
 fs/afs/kafstimod.c  |   31 +++-------
 fs/afs/kafstimod.h  |   20 +++---
 fs/afs/main.c       |   94 +++++-------------------------
 fs/afs/misc.c       |    6 +-
 fs/afs/mntpt.c      |   27 +++------
 fs/afs/mount.h      |    8 +--
 fs/afs/proc.c       |  161 ++++++++++++++++++---------------------------------
 fs/afs/server.c     |   47 +++++----------
 fs/afs/server.h     |   41 ++++++-------
 fs/afs/super.c      |   62 +++++++-------------
 fs/afs/super.h      |   16 ++---
 fs/afs/transport.h  |    8 +--
 fs/afs/types.h      |   34 +++--------
 fs/afs/vlclient.c   |   58 +++++++-----------
 fs/afs/vlclient.h   |   34 ++++-------
 fs/afs/vlocation.c  |  102 +++++++++++---------------------
 fs/afs/vnode.c      |   36 ++++-------
 fs/afs/vnode.h      |   36 ++++-------
 fs/afs/volume.c     |   58 +++++++-----------
 fs/afs/volume.h     |   52 ++++++----------
 36 files changed, 506 insertions(+), 906 deletions(-)

diff --git a/fs/afs/Makefile b/fs/afs/Makefile
index 4029c9d..8e71973 100644
--- a/fs/afs/Makefile
+++ b/fs/afs/Makefile
@@ -2,8 +2,6 @@
 # Makefile for Red Hat Linux AFS client.
 #
 
-#CFLAGS += -finstrument-functions
-
 kafs-objs := \
 	callback.o \
 	cell.o \
diff --git a/fs/afs/cache.h b/fs/afs/cache.h
index 9eb7722..36a3642 100644
--- a/fs/afs/cache.h
+++ b/fs/afs/cache.h
@@ -1,4 +1,4 @@
-/* cache.h: AFS local cache management interface
+/* AFS local cache management interface
  *
  * Copyright (C) 2002 Red Hat, Inc. All Rights Reserved.
  * Written by David Howells (dhowells@redhat.com)
@@ -9,8 +9,8 @@
  * 2 of the License, or (at your option) any later version.
  */
 
-#ifndef _LINUX_AFS_CACHE_H
-#define _LINUX_AFS_CACHE_H
+#ifndef AFS_CACHE_H
+#define AFS_CACHE_H
 
 #undef AFS_CACHING_SUPPORT
 
@@ -20,8 +20,4 @@
 #endif
 #include "types.h"
 
-#ifdef __KERNEL__
-
-#endif /* __KERNEL__ */
-
-#endif /* _LINUX_AFS_CACHE_H */
+#endif /* AFS_CACHE_H */
diff --git a/fs/afs/callback.c b/fs/afs/callback.c
index 9cb206e..26a48fe 100644
--- a/fs/afs/callback.c
+++ b/fs/afs/callback.c
@@ -21,7 +21,6 @@
 #include "internal.h"
 #include "cmservice.h"
 
-/*****************************************************************************/
 /*
  * allow the fileserver to request callback state (re-)initialisation
  */
@@ -79,9 +78,8 @@ int SRXAFSCM_InitCallBackState(struct afs_server *server)
 
 	_leave(" = 0");
 	return 0;
-} /* end SRXAFSCM_InitCallBackState() */
+}
 
-/*****************************************************************************/
 /*
  * allow the fileserver to break callback promises
  */
@@ -156,9 +154,8 @@ int SRXAFSCM_CallBack(struct afs_server *server, size_t count,
 
 	_leave(" = 0");
 	return 0;
-} /* end SRXAFSCM_CallBack() */
+}
 
-/*****************************************************************************/
 /*
  * allow the fileserver to see if the cache manager is still alive
  */
@@ -166,4 +163,4 @@ int SRXAFSCM_Probe(struct afs_server *server)
 {
 	_debug("SRXAFSCM_Probe(%p)\n", server);
 	return 0;
-} /* end SRXAFSCM_Probe() */
+}
diff --git a/fs/afs/cell.c b/fs/afs/cell.c
index 1fc5783..28ed84e 100644
--- a/fs/afs/cell.c
+++ b/fs/afs/cell.c
@@ -1,4 +1,4 @@
-/* cell.c: AFS cell and server record management
+/* AFS cell and server record management
  *
  * Copyright (C) 2002 Red Hat, Inc. All Rights Reserved.
  * Written by David Howells (dhowells@redhat.com)
@@ -44,7 +44,6 @@ struct cachefs_index_def afs_cache_cell_index_def = {
 };
 #endif
 
-/*****************************************************************************/
 /*
  * create a cell record
  * - "name" is the name of the cell
@@ -137,16 +136,15 @@ int afs_cell_create(const char *name, char *vllist, struct afs_cell **_cell)
 	_leave(" = 0 (%p)", cell);
 	return 0;
 
- badaddr:
+badaddr:
 	printk(KERN_ERR "kAFS: bad VL server IP address: '%s'\n", vllist);
- error:
+error:
 	up_write(&afs_cells_sem);
 	kfree(cell);
 	_leave(" = %d", ret);
 	return ret;
-} /* end afs_cell_create() */
+}
 
-/*****************************************************************************/
 /*
  * initialise the cell database from module parameters
  */
@@ -199,10 +197,8 @@ int afs_cell_init(char *rootcell)
 
 	_leave(" = %d", ret);
 	return ret;
+}
 
-} /* end afs_cell_init() */
-
-/*****************************************************************************/
 /*
  * lookup a cell record
  */
@@ -234,8 +230,7 @@ int afs_cell_lookup(const char *name, unsigned namesz, struct afs_cell **_cell)
 
 		if (cell)
 			ret = 0;
-	}
-	else {
+	} else {
 		read_lock(&afs_cells_lock);
 
 		cell = afs_cell_root;
@@ -247,8 +242,7 @@ int afs_cell_lookup(const char *name, unsigned namesz, struct afs_cell **_cell)
 			 * for other reasons.
 			 */
 			ret = -EDESTADDRREQ;
-		}
-		else {
+		} else {
 			afs_get_cell(cell);
 			ret = 0;
 		}
@@ -259,10 +253,8 @@ int afs_cell_lookup(const char *name, unsigned namesz, struct afs_cell **_cell)
 	*_cell = cell;
 	_leave(" = %d (%p)", ret, cell);
 	return ret;
+}
 
-} /* end afs_cell_lookup() */
-
-/*****************************************************************************/
 /*
  * try and get a cell record
  */
@@ -281,9 +273,8 @@ struct afs_cell *afs_get_cell_maybe(struct afs_cell **_cell)
 	write_unlock(&afs_cells_lock);
 
 	return cell;
-} /* end afs_get_cell_maybe() */
+}
 
-/*****************************************************************************/
 /*
  * destroy a cell record
  */
@@ -315,9 +306,8 @@ void afs_put_cell(struct afs_cell *cell)
 	BUG_ON(!list_empty(&cell->vl_graveyard));
 
 	_leave(" [unused]");
-} /* end afs_put_cell() */
+}
 
-/*****************************************************************************/
 /*
  * destroy a cell record
  */
@@ -359,9 +349,8 @@ static void afs_cell_destroy(struct afs_cell *cell)
 	kfree(cell);
 
 	_leave(" [destroyed]");
-} /* end afs_cell_destroy() */
+}
 
-/*****************************************************************************/
 /*
  * lookup the server record corresponding to an Rx RPC peer
  */
@@ -411,7 +400,7 @@ int afs_server_find_by_peer(const struct rxrpc_peer *peer,
 	return -ENOENT;
 
 	/* we found it in the graveyard - resurrect it */
- found_dead_server:
+found_dead_server:
 	list_move_tail(&server->link, &cell->sv_list);
 	afs_get_server(server);
 	afs_kafstimod_del_timer(&server->timeout);
@@ -419,20 +408,18 @@ int afs_server_find_by_peer(const struct rxrpc_peer *peer,
 	goto success;
 
 	/* we found it - increment its ref count and return it */
- found_server:
+found_server:
 	afs_get_server(server);
 
- success:
+success:
 	write_unlock(&cell->sv_lock);
 	read_unlock(&afs_cells_lock);
 
 	*_server = server;
 	_leave(" = 0 (s=%p c=%p)", server, cell);
 	return 0;
+}
 
-} /* end afs_server_find_by_peer() */
-
-/*****************************************************************************/
 /*
  * purge in-memory cell database on module unload or afs_init() failure
  * - the timeout daemon is stopped before calling this
@@ -520,9 +507,8 @@ void afs_cell_purge(void)
 	}
 
 	_leave("");
-} /* end afs_cell_purge() */
+}
 
-/*****************************************************************************/
 /*
  * match a cell record obtained from the cache
  */
@@ -542,10 +528,9 @@ static cachefs_match_val_t afs_cell_cache_match(void *target,
 
 	_leave(" = FAILED");
 	return CACHEFS_MATCH_FAILED;
-} /* end afs_cell_cache_match() */
+}
 #endif
 
-/*****************************************************************************/
 /*
  * update a cell record in the cache
  */
@@ -563,5 +548,5 @@ static void afs_cell_cache_update(void *source, void *entry)
 	       cell->vl_addrs,
 	       min(sizeof(ccell->vl_servers), sizeof(cell->vl_addrs)));
 
-} /* end afs_cell_cache_update() */
+}
 #endif
diff --git a/fs/afs/cell.h b/fs/afs/cell.h
index 4834910..c135b00 100644
--- a/fs/afs/cell.h
+++ b/fs/afs/cell.h
@@ -1,4 +1,4 @@
-/* cell.h: AFS cell record
+/* AFS cell record
  *
  * Copyright (C) 2002 Red Hat, Inc. All Rights Reserved.
  * Written by David Howells (dhowells@redhat.com)
@@ -9,8 +9,8 @@
  * 2 of the License, or (at your option) any later version.
  */
 
-#ifndef _LINUX_AFS_CELL_H
-#define _LINUX_AFS_CELL_H
+#ifndef AFS_CELL_H
+#define AFS_CELL_H
 
 #include "types.h"
 #include "cache.h"
@@ -19,22 +19,18 @@
 
 extern volatile int afs_cells_being_purged; /* T when cells are being purged by rmmod */
 
-/*****************************************************************************/
 /*
  * entry in the cached cell catalogue
  */
-struct afs_cache_cell
-{
+struct afs_cache_cell {
 	char			name[64];	/* cell name (padded with NULs) */
 	struct in_addr		vl_servers[15];	/* cached cell VL servers */
 };
 
-/*****************************************************************************/
 /*
  * AFS cell record
  */
-struct afs_cell
-{
+struct afs_cell {
 	atomic_t		usage;
 	struct list_head	link;		/* main cell list link */
 	struct list_head	proc_link;	/* /proc cell list link */
@@ -61,18 +57,14 @@ struct afs_cell
 	char			name[0];	/* cell name - must go last */
 };
 
-extern int afs_cell_init(char *rootcell);
-
-extern int afs_cell_create(const char *name, char *vllist, struct afs_cell **_cell);
-
-extern int afs_cell_lookup(const char *name, unsigned nmsize, struct afs_cell **_cell);
+extern int afs_cell_init(char *);
+extern int afs_cell_create(const char *, char *, struct afs_cell **);
+extern int afs_cell_lookup(const char *, unsigned, struct afs_cell **);
 
 #define afs_get_cell(C) do { atomic_inc(&(C)->usage); } while(0)
 
-extern struct afs_cell *afs_get_cell_maybe(struct afs_cell **_cell);
-
-extern void afs_put_cell(struct afs_cell *cell);
-
+extern struct afs_cell *afs_get_cell_maybe(struct afs_cell **);
+extern void afs_put_cell(struct afs_cell *);
 extern void afs_cell_purge(void);
 
-#endif /* _LINUX_AFS_CELL_H */
+#endif /* AFS_CELL_H */
diff --git a/fs/afs/cmservice.c b/fs/afs/cmservice.c
index 3d097fd..3f45857 100644
--- a/fs/afs/cmservice.c
+++ b/fs/afs/cmservice.c
@@ -1,4 +1,4 @@
-/* cmservice.c: AFS Cache Manager Service
+/* AFS Cache Manager Service
  *
  * Copyright (C) 2002 Red Hat, Inc. All Rights Reserved.
  * Written by David Howells (dhowells@redhat.com)
@@ -106,7 +106,6 @@ static DEFINE_SPINLOCK(afscm_calls_lock);
 static DEFINE_SPINLOCK(kafscmd_attention_lock);
 static int kafscmd_die;
 
-/*****************************************************************************/
 /*
  * AFS Cache Manager kernel thread
  */
@@ -177,10 +176,8 @@ static int kafscmd(void *arg)
 
 	/* and that's all */
 	complete_and_exit(&kafscmd_dead, 0);
+}
 
-} /* end kafscmd() */
-
-/*****************************************************************************/
 /*
  * handle a call coming in to the cache manager
  * - if I want to keep the call, I must increment its usage count
@@ -202,10 +199,8 @@ static int afscm_new_call(struct rxrpc_call *call)
 
 	_leave(" = 0");
 	return 0;
+}
 
-} /* end afscm_new_call() */
-
-/*****************************************************************************/
 /*
  * queue on the kafscmd queue for attention
  */
@@ -226,9 +221,8 @@ static void afscm_attention(struct rxrpc_call *call)
 	wake_up(&kafscmd_sleepq);
 
 	_leave(" {u=%d}", atomic_read(&call->usage));
-} /* end afscm_attention() */
+}
 
-/*****************************************************************************/
 /*
  * handle my call being aborted
  * - clean up, dequeue and put my ref to the call
@@ -266,9 +260,8 @@ static void afscm_error(struct rxrpc_call *call)
 	wake_up(&kafscmd_sleepq);
 
 	_leave("");
-} /* end afscm_error() */
+}
 
-/*****************************************************************************/
 /*
  * map afs abort codes to/from Linux error codes
  * - called with call->lock held
@@ -285,9 +278,8 @@ static void afscm_aemap(struct rxrpc_call *call)
 	default:
 		break;
 	}
-} /* end afscm_aemap() */
+}
 
-/*****************************************************************************/
 /*
  * start the cache manager service if not already started
  */
@@ -316,18 +308,16 @@ int afscm_start(void)
 
 	return 0;
 
- kill:
+kill:
 	kafscmd_die = 1;
 	wake_up(&kafscmd_sleepq);
 	wait_for_completion(&kafscmd_dead);
 
- out:
+out:
 	up_write(&afscm_sem);
 	return ret;
+}
 
-} /* end afscm_start() */
-
-/*****************************************************************************/
 /*
  * stop the cache manager service
  */
@@ -394,10 +384,8 @@ void afscm_stop(void)
 	}
 
 	up_write(&afscm_sem);
+}
 
-} /* end afscm_stop() */
-
-/*****************************************************************************/
 /*
  * handle the fileserver breaking a set of callbacks
  */
@@ -460,8 +448,7 @@ static void _SRXAFSCM_CallBack(struct rxrpc_call *call)
 					pcb->version	= ntohl(*bp++);
 					pcb->expiry	= ntohl(*bp++);
 					pcb->type	= ntohl(*bp++);
-				}
-				else {
+				} else {
 					pcb->version	= 0;
 					pcb->expiry	= 0;
 					pcb->type	= AFSCM_CB_UNTYPED;
@@ -512,10 +499,8 @@ static void _SRXAFSCM_CallBack(struct rxrpc_call *call)
 	afs_put_server(server);
 
 	_leave(" = %d", ret);
+}
 
-} /* end _SRXAFSCM_CallBack() */
-
-/*****************************************************************************/
 /*
  * handle the fileserver asking us to initialise our callback state
  */
@@ -580,10 +565,8 @@ static void _SRXAFSCM_InitCallBackState(struct rxrpc_call *call)
 	afs_put_server(server);
 
 	_leave(" = %d", ret);
+}
 
-} /* end _SRXAFSCM_InitCallBackState() */
-
-/*****************************************************************************/
 /*
  * handle a probe from a fileserver
  */
@@ -648,5 +631,4 @@ static void _SRXAFSCM_Probe(struct rxrpc_call *call)
 	afs_put_server(server);
 
 	_leave(" = %d", ret);
-
-} /* end _SRXAFSCM_Probe() */
+}
diff --git a/fs/afs/cmservice.h b/fs/afs/cmservice.h
index af8d4d6..66e10c1 100644
--- a/fs/afs/cmservice.h
+++ b/fs/afs/cmservice.h
@@ -1,4 +1,4 @@
-/* cmservice.h: AFS Cache Manager Service declarations
+/* AFS Cache Manager Service declarations
  *
  * Copyright (C) 2002 Red Hat, Inc. All Rights Reserved.
  * Written by David Howells (dhowells@redhat.com)
@@ -9,8 +9,8 @@
  * 2 of the License, or (at your option) any later version.
  */
 
-#ifndef _LINUX_AFS_CMSERVICE_H
-#define _LINUX_AFS_CMSERVICE_H
+#ifndef AFS_CMSERVICE_H
+#define AFS_CMSERVICE_H
 
 #include <rxrpc/transport.h>
 #include "types.h"
@@ -20,10 +20,9 @@ extern int afscm_start(void);
 extern void afscm_stop(void);
 
 /* cache manager server functions */
-extern int SRXAFSCM_InitCallBackState(struct afs_server *server);
-extern int SRXAFSCM_CallBack(struct afs_server *server,
-			     size_t count,
-			     struct afs_callback callbacks[]);
-extern int SRXAFSCM_Probe(struct afs_server *server);
+extern int SRXAFSCM_InitCallBackState(struct afs_server *);
+extern int SRXAFSCM_CallBack(struct afs_server *, size_t,
+			     struct afs_callback[]);
+extern int SRXAFSCM_Probe(struct afs_server *);
 
-#endif /* _LINUX_AFS_CMSERVICE_H */
+#endif /* AFS_CMSERVICE_H */
diff --git a/fs/afs/dir.c b/fs/afs/dir.c
index b6dc2eb..2f6d923 100644
--- a/fs/afs/dir.c
+++ b/fs/afs/dir.c
@@ -112,7 +112,6 @@ struct afs_dir_lookup_cookie {
 	int		found;
 };
 
-/*****************************************************************************/
 /*
  * check that a directory page is valid
  */
@@ -157,13 +156,11 @@ static inline void afs_dir_check_page(struct inode *dir, struct page *page)
 	SetPageChecked(page);
 	return;
 
- error:
+error:
 	SetPageChecked(page);
 	SetPageError(page);
+}
 
-} /* end afs_dir_check_page() */
-
-/*****************************************************************************/
 /*
  * discard a page cached in the pagecache
  */
@@ -171,10 +168,8 @@ static inline void afs_dir_put_page(struct page *page)
 {
 	kunmap(page);
 	page_cache_release(page);
+}
 
-} /* end afs_dir_put_page() */
-
-/*****************************************************************************/
 /*
  * get a page into the pagecache
  */
@@ -197,12 +192,11 @@ static struct page *afs_dir_get_page(struct inode *dir, unsigned long index)
 	}
 	return page;
 
- fail:
+fail:
 	afs_dir_put_page(page);
 	return ERR_PTR(-EIO);
-} /* end afs_dir_get_page() */
+}
 
-/*****************************************************************************/
 /*
  * open an AFS directory file
  */
@@ -218,10 +212,8 @@ static int afs_dir_open(struct inode *inode, struct file *file)
 
 	_leave(" = 0");
 	return 0;
+}
 
-} /* end afs_dir_open() */
-
-/*****************************************************************************/
 /*
  * deal with one block in an AFS directory
  */
@@ -316,9 +308,8 @@ static int afs_dir_iterate_block(unsigned *fpos,
 
 	_leave(" = 1 [more]");
 	return 1;
-} /* end afs_dir_iterate_block() */
+}
 
-/*****************************************************************************/
 /*
  * read an AFS directory
  */
@@ -377,12 +368,11 @@ static int afs_dir_iterate(struct inode *dir, unsigned *fpos, void *cookie,
 		ret = 0;
 	}
 
- out:
+out:
 	_leave(" = %d", ret);
 	return ret;
-} /* end afs_dir_iterate() */
+}
 
-/*****************************************************************************/
 /*
  * read an AFS directory
  */
@@ -399,9 +389,8 @@ static int afs_dir_readdir(struct file *file, void *cookie, filldir_t filldir)
 
 	_leave(" = %d", ret);
 	return ret;
-} /* end afs_dir_readdir() */
+}
 
-/*****************************************************************************/
 /*
  * search the directory for a name
  * - if afs_dir_iterate_block() spots this function, it'll pass the FID
@@ -426,9 +415,8 @@ static int afs_dir_lookup_filldir(void *_cookie, const char *name, int nlen,
 
 	_leave(" = -1 [found]");
 	return -1;
-} /* end afs_dir_lookup_filldir() */
+}
 
-/*****************************************************************************/
 /*
  * look up an entry in a directory
  */
@@ -498,9 +486,8 @@ static struct dentry *afs_dir_lookup(struct inode *dir, struct dentry *dentry,
 	       dentry->d_inode->i_version);
 
 	return NULL;
-} /* end afs_dir_lookup() */
+}
 
-/*****************************************************************************/
 /*
  * check that a dentry lookup hit has found a valid entry
  * - NOTE! the hit can be a negative hit too, so we can't assume we have an
@@ -605,18 +592,18 @@ static int afs_d_revalidate(struct dentry *dentry, struct nameidata *nd)
 			(void *) (unsigned long) AFS_FS_I(dir)->status.version;
 	}
 
- out_valid:
+out_valid:
 	dput(parent);
 	_leave(" = 1 [valid]");
 	return 1;
 
 	/* the dirent, if it exists, now points to a different vnode */
- not_found:
+not_found:
 	spin_lock(&dentry->d_lock);
 	dentry->d_flags |= DCACHE_NFSFS_RENAMED;
 	spin_unlock(&dentry->d_lock);
 
- out_bad:
+out_bad:
 	if (inode) {
 		/* don't unhash if we have submounts */
 		if (have_submounts(dentry))
@@ -633,9 +620,8 @@ static int afs_d_revalidate(struct dentry *dentry, struct nameidata *nd)
 
 	_leave(" = 0 [bad]");
 	return 0;
-} /* end afs_d_revalidate() */
+}
 
-/*****************************************************************************/
 /*
  * allow the VFS to enquire as to whether a dentry should be unhashed (mustn't
  * sleep)
@@ -657,7 +643,7 @@ static int afs_d_delete(struct dentry *dentry)
 	_leave(" = 0 [keep]");
 	return 0;
 
- zap:
+zap:
 	_leave(" = 1 [zap]");
 	return 1;
-} /* end afs_d_delete() */
+}
diff --git a/fs/afs/errors.h b/fs/afs/errors.h
index 574d94a..bcc0a33 100644
--- a/fs/afs/errors.h
+++ b/fs/afs/errors.h
@@ -1,4 +1,4 @@
-/* errors.h: AFS abort/error codes
+/* AFS abort/error codes
  *
  * Copyright (C) 2002 Red Hat, Inc. All Rights Reserved.
  * Written by David Howells (dhowells@redhat.com)
@@ -9,12 +9,14 @@
  * 2 of the License, or (at your option) any later version.
  */
 
-#ifndef _LINUX_AFS_ERRORS_H
-#define _LINUX_AFS_ERRORS_H
+#ifndef AFS_ERRORS_H
+#define AFS_ERRORS_H
 
 #include "types.h"
 
-/* file server abort codes */
+/*
+ * file server abort codes
+ */
 typedef enum {
 	VSALVAGE	= 101,	/* volume needs salvaging */
 	VNOVNODE	= 102,	/* no such file/dir (vnode) */
@@ -29,6 +31,6 @@ typedef enum {
 	VMOVED		= 111,	/* volume moved to new server - ask this FS where */
 } afs_rxfs_abort_t;
 
-extern int afs_abort_to_error(int abortcode);
+extern int afs_abort_to_error(int);
 
-#endif /* _LINUX_AFS_ERRORS_H */
+#endif /* AFS_ERRORS_H */
diff --git a/fs/afs/file.c b/fs/afs/file.c
index b176345..01df30d 100644
--- a/fs/afs/file.c
+++ b/fs/afs/file.c
@@ -40,7 +40,6 @@ const struct address_space_operations afs_fs_aops = {
 	.invalidatepage	= afs_file_invalidatepage,
 };
 
-/*****************************************************************************/
 /*
  * deal with notification that a page was read from the cache
  */
@@ -58,10 +57,9 @@ static void afs_file_readpage_read_complete(void *cookie_data,
 		SetPageUptodate(page);
 	unlock_page(page);
 
-} /* end afs_file_readpage_read_complete() */
+}
 #endif
 
-/*****************************************************************************/
 /*
  * deal with notification that a page was written to the cache
  */
@@ -74,11 +72,9 @@ static void afs_file_readpage_write_complete(void *cookie_data,
 	_enter("%p,%p,%p,%d", cookie_data, page, data, error);
 
 	unlock_page(page);
-
-} /* end afs_file_readpage_write_complete() */
+}
 #endif
 
-/*****************************************************************************/
 /*
  * AFS read page from file (or symlink)
  */
@@ -184,10 +180,8 @@ static int afs_file_readpage(struct file *file, struct page *page)
 
 	_leave(" = %d", ret);
 	return ret;
+}
 
-} /* end afs_file_readpage() */
-
-/*****************************************************************************/
 /*
  * get a page cookie for the specified page
  */
@@ -202,10 +196,9 @@ int afs_cache_get_page_cookie(struct page *page,
 
 	_leave(" = %d", ret);
 	return ret;
-} /* end afs_cache_get_page_cookie() */
+}
 #endif
 
-/*****************************************************************************/
 /*
  * invalidate part or all of a page
  */
@@ -240,9 +233,8 @@ static void afs_file_invalidatepage(struct page *page, unsigned long offset)
 	}
 
 	_leave(" = %d", ret);
-} /* end afs_file_invalidatepage() */
+}
 
-/*****************************************************************************/
 /*
  * release a page and cleanup its private data
  */
@@ -267,4 +259,4 @@ static int afs_file_releasepage(struct page *page, gfp_t gfp_flags)
 
 	_leave(" = 0");
 	return 0;
-} /* end afs_file_releasepage() */
+}
diff --git a/fs/afs/fsclient.c b/fs/afs/fsclient.c
index 61bc371..f1c3a18 100644
--- a/fs/afs/fsclient.c
+++ b/fs/afs/fsclient.c
@@ -29,7 +29,6 @@
 #define FSGETROOTVOLUME		151	/* AFS Get root volume name */
 #define FSLOOKUP		161	/* AFS lookup file in directory */
 
-/*****************************************************************************/
 /*
  * map afs abort codes to/from Linux error codes
  * - called with call->lock held
@@ -46,9 +45,8 @@ static void afs_rxfs_aemap(struct rxrpc_call *call)
 	default:
 		break;
 	}
-} /* end afs_rxfs_aemap() */
+}
 
-/*****************************************************************************/
 /*
  * get the root volume name from a fileserver
  * - this operation doesn't seem to work correctly in OpenAFS server 1.2.2
@@ -162,23 +160,22 @@ int afs_rxfs_get_root_volume(struct afs_server *server,
 		BUG();
 	}
 
- abort:
+abort:
 	set_current_state(TASK_UNINTERRUPTIBLE);
 	rxrpc_call_abort(call, ret);
 	schedule();
- out_unwait:
+out_unwait:
 	set_current_state(TASK_RUNNING);
 	remove_wait_queue(&call->waitq, &myself);
 	rxrpc_put_call(call);
- out_put_conn:
+out_put_conn:
 	afs_server_release_fsconn(server, conn);
- out:
+out:
 	kleave("");
 	return ret;
-} /* end afs_rxfs_get_root_volume() */
+}
 #endif
 
-/*****************************************************************************/
 /*
  * get information about a volume
  */
@@ -275,26 +272,24 @@ int afs_rxfs_get_volume_info(struct afs_server *server,
 	/* success */
 	ret = 0;
 
- out_unwait:
+out_unwait:
 	set_current_state(TASK_RUNNING);
 	remove_wait_queue(&call->waitq, &myself);
 	rxrpc_put_call(call);
- out_put_conn:
+out_put_conn:
 	afs_server_release_fsconn(server, conn);
- out:
+out:
 	_leave("");
 	return ret;
 
- abort:
+abort:
 	set_current_state(TASK_UNINTERRUPTIBLE);
 	rxrpc_call_abort(call, ret);
 	schedule();
 	goto out_unwait;
-
-} /* end afs_rxfs_get_volume_info() */
+}
 #endif
 
-/*****************************************************************************/
 /*
  * fetch the status information for a file
  */
@@ -401,24 +396,23 @@ int afs_rxfs_fetch_file_status(struct afs_server *server,
 	/* success */
 	ret = 0;
 
- out_unwait:
+out_unwait:
 	set_current_state(TASK_RUNNING);
 	remove_wait_queue(&call->waitq, &myself);
 	rxrpc_put_call(call);
- out_put_conn:
+out_put_conn:
 	afs_server_release_callslot(server, &callslot);
- out:
+out:
 	_leave("");
 	return ret;
 
- abort:
+abort:
 	set_current_state(TASK_UNINTERRUPTIBLE);
 	rxrpc_call_abort(call, ret);
 	schedule();
 	goto out_unwait;
-} /* end afs_rxfs_fetch_file_status() */
+}
 
-/*****************************************************************************/
 /*
  * fetch the contents of a file or directory
  */
@@ -547,31 +541,29 @@ int afs_rxfs_fetch_file_data(struct afs_server *server,
 	/* success */
 	ret = 0;
 
- out_unwait:
+out_unwait:
 	set_current_state(TASK_RUNNING);
 	remove_wait_queue(&call->waitq,&myself);
 	rxrpc_put_call(call);
- out_put_conn:
+out_put_conn:
 	afs_server_release_callslot(server, &callslot);
- out:
+out:
 	_leave(" = %d", ret);
 	return ret;
 
- read_failed:
+read_failed:
 	if (ret == -ECONNABORTED) {
 		ret = call->app_errno;
 		goto out_unwait;
 	}
 
- abort:
+abort:
 	set_current_state(TASK_UNINTERRUPTIBLE);
 	rxrpc_call_abort(call, ret);
 	schedule();
 	goto out_unwait;
+}
 
-} /* end afs_rxfs_fetch_file_data() */
-
-/*****************************************************************************/
 /*
  * ask the AFS fileserver to discard a callback request on a file
  */
@@ -655,24 +647,23 @@ int afs_rxfs_give_up_callback(struct afs_server *server,
 		BUG();
 	}
 
- out_unwait:
+out_unwait:
 	set_current_state(TASK_RUNNING);
 	remove_wait_queue(&call->waitq, &myself);
 	rxrpc_put_call(call);
- out_put_conn:
+out_put_conn:
 	afs_server_release_callslot(server, &callslot);
- out:
+out:
 	_leave("");
 	return ret;
 
- abort:
+abort:
 	set_current_state(TASK_UNINTERRUPTIBLE);
 	rxrpc_call_abort(call, ret);
 	schedule();
 	goto out_unwait;
-} /* end afs_rxfs_give_up_callback() */
+}
 
-/*****************************************************************************/
 /*
  * look a filename up in a directory
  * - this operation doesn't seem to work correctly in OpenAFS server 1.2.2
@@ -818,20 +809,20 @@ int afs_rxfs_lookup(struct afs_server *server,
 	/* success */
 	ret = 0;
 
- out_unwait:
+out_unwait:
 	set_current_state(TASK_RUNNING);
 	remove_wait_queue(&call->waitq, &myself);
 	rxrpc_put_call(call);
- out_put_conn:
+out_put_conn:
 	afs_server_release_fsconn(server, conn);
- out:
+out:
 	kleave("");
 	return ret;
 
- abort:
+abort:
 	set_current_state(TASK_UNINTERRUPTIBLE);
 	rxrpc_call_abort(call, ret);
 	schedule();
 	goto out_unwait;
-} /* end afs_rxfs_lookup() */
+}
 #endif
diff --git a/fs/afs/fsclient.h b/fs/afs/fsclient.h
index 8ba3e74..e2b0b7b 100644
--- a/fs/afs/fsclient.h
+++ b/fs/afs/fsclient.h
@@ -1,4 +1,4 @@
-/* fsclient.h: AFS File Server client stub declarations
+/* AFS File Server client stub declarations
  *
  * Copyright (C) 2002 Red Hat, Inc. All Rights Reserved.
  * Written by David Howells (dhowells@redhat.com)
@@ -9,18 +9,18 @@
  * 2 of the License, or (at your option) any later version.
  */
 
-#ifndef _LINUX_AFS_FSCLIENT_H
-#define _LINUX_AFS_FSCLIENT_H
+#ifndef AFS_FSCLIENT_H
+#define AFS_FSCLIENT_H
 
 #include "server.h"
 
-extern int afs_rxfs_get_volume_info(struct afs_server *server,
-				    const char *name,
-				    struct afs_volume_info *vinfo);
+extern int afs_rxfs_get_volume_info(struct afs_server *,
+				    const char *,
+				    struct afs_volume_info *);
 
-extern int afs_rxfs_fetch_file_status(struct afs_server *server,
-				      struct afs_vnode *vnode,
-				      struct afs_volsync *volsync);
+extern int afs_rxfs_fetch_file_status(struct afs_server *,
+				      struct afs_vnode *,
+				      struct afs_volsync *);
 
 struct afs_rxfs_fetch_descriptor {
 	struct afs_fid	fid;		/* file ID to fetch */
@@ -30,25 +30,25 @@ struct afs_rxfs_fetch_descriptor {
 	size_t		actual;		/* actual size sent back by server */
 };
 
-extern int afs_rxfs_fetch_file_data(struct afs_server *server,
-				    struct afs_vnode *vnode,
-				    struct afs_rxfs_fetch_descriptor *desc,
-				    struct afs_volsync *volsync);
+extern int afs_rxfs_fetch_file_data(struct afs_server *,
+				    struct afs_vnode *,
+				    struct afs_rxfs_fetch_descriptor *,
+				    struct afs_volsync *);
 
-extern int afs_rxfs_give_up_callback(struct afs_server *server,
-				     struct afs_vnode *vnode);
+extern int afs_rxfs_give_up_callback(struct afs_server *,
+				     struct afs_vnode *);
 
 /* this doesn't appear to work in OpenAFS server */
-extern int afs_rxfs_lookup(struct afs_server *server,
-			   struct afs_vnode *dir,
-			   const char *filename,
-			   struct afs_vnode *vnode,
-			   struct afs_volsync *volsync);
+extern int afs_rxfs_lookup(struct afs_server *,
+			   struct afs_vnode *,
+			   const char *,
+			   struct afs_vnode *,
+			   struct afs_volsync *);
 
 /* this is apparently mis-implemented in OpenAFS server */
-extern int afs_rxfs_get_root_volume(struct afs_server *server,
-				    char *buf,
-				    size_t *buflen);
+extern int afs_rxfs_get_root_volume(struct afs_server *,
+				    char *,
+				    size_t *);
 
 
-#endif /* _LINUX_AFS_FSCLIENT_H */
+#endif /* AFS_FSCLIENT_H */
diff --git a/fs/afs/inode.c b/fs/afs/inode.c
index 9d9bca6..900c8bb 100644
--- a/fs/afs/inode.c
+++ b/fs/afs/inode.c
@@ -29,7 +29,6 @@ struct afs_iget_data {
 	struct afs_volume	*volume;	/* volume on which resides */
 };
 
-/*****************************************************************************/
 /*
  * map the AFS file status to the inode member variables
  */
@@ -87,9 +86,8 @@ static int afs_inode_map_status(struct afs_vnode *vnode)
 	}
 
 	return 0;
-} /* end afs_inode_map_status() */
+}
 
-/*****************************************************************************/
 /*
  * attempt to fetch the status of an inode, coelescing multiple simultaneous
  * fetches
@@ -107,10 +105,8 @@ static int afs_inode_fetch_status(struct inode *inode)
 		ret = afs_inode_map_status(vnode);
 
 	return ret;
+}
 
-} /* end afs_inode_fetch_status() */
-
-/*****************************************************************************/
 /*
  * iget5() comparator
  */
@@ -120,9 +116,8 @@ static int afs_iget5_test(struct inode *inode, void *opaque)
 
 	return inode->i_ino == data->fid.vnode &&
 		inode->i_version == data->fid.unique;
-} /* end afs_iget5_test() */
+}
 
-/*****************************************************************************/
 /*
  * iget5() inode initialiser
  */
@@ -137,9 +132,8 @@ static int afs_iget5_set(struct inode *inode, void *opaque)
 	vnode->volume = data->volume;
 
 	return 0;
-} /* end afs_iget5_set() */
+}
 
-/*****************************************************************************/
 /*
  * inode retrieval
  */
@@ -169,7 +163,7 @@ inline int afs_iget(struct super_block *sb, struct afs_fid *fid,
 	/* deal with an existing inode */
 	if (!(inode->i_state & I_NEW)) {
 		ret = afs_vnode_fetch_status(vnode);
-		if (ret==0)
+		if (ret == 0)
 			*_inode = inode;
 		else
 			iput(inode);
@@ -204,16 +198,15 @@ inline int afs_iget(struct super_block *sb, struct afs_fid *fid,
 	return 0;
 
 	/* failure */
- bad_inode:
+bad_inode:
 	make_bad_inode(inode);
 	unlock_new_inode(inode);
 	iput(inode);
 
 	_leave(" = %d [bad]", ret);
 	return ret;
-} /* end afs_iget() */
+}
 
-/*****************************************************************************/
 /*
  * read the attributes of an inode
  */
@@ -235,8 +228,7 @@ int afs_inode_getattr(struct vfsmount *mnt, struct dentry *dentry,
 		_leave(" = %d [%d %p]",
 		       ret, atomic_read(&dentry->d_count), dentry->d_inode);
 		return ret;
-	}
-	else if (ret < 0) {
+	} else if (ret < 0) {
 		make_bad_inode(inode);
 		_leave(" = %d", ret);
 		return ret;
@@ -252,9 +244,8 @@ int afs_inode_getattr(struct vfsmount *mnt, struct dentry *dentry,
 	       vnode->cb_type);
 
 	return 0;
-} /* end afs_inode_getattr() */
+}
 
-/*****************************************************************************/
 /*
  * clear an AFS inode
  */
@@ -282,4 +273,4 @@ void afs_clear_inode(struct inode *inode)
 #endif
 
 	_leave("");
-} /* end afs_clear_inode() */
+}
diff --git a/fs/afs/internal.h b/fs/afs/internal.h
index 5151d5d..b6dd20a 100644
--- a/fs/afs/internal.h
+++ b/fs/afs/internal.h
@@ -1,4 +1,4 @@
-/* internal.h: internal AFS stuff
+/* internal AFS stuff
  *
  * Copyright (C) 2002 Red Hat, Inc. All Rights Reserved.
  * Written by David Howells (dhowells@redhat.com)
@@ -73,26 +73,16 @@ extern const struct address_space_operations afs_fs_aops;
 extern const struct inode_operations afs_file_inode_operations;
 
 #ifdef AFS_CACHING_SUPPORT
-extern int afs_cache_get_page_cookie(struct page *page,
-				     struct cachefs_page **_page_cookie);
+extern int afs_cache_get_page_cookie(struct page *, struct cachefs_page **);
 #endif
 
 /*
  * inode.c
  */
-extern int afs_iget(struct super_block *sb, struct afs_fid *fid,
-		    struct inode **_inode);
-extern int afs_inode_getattr(struct vfsmount *mnt, struct dentry *dentry,
-			     struct kstat *stat);
-extern void afs_clear_inode(struct inode *inode);
-
-/*
- * key_afs.c
- */
-#ifdef CONFIG_KEYS
-extern int afs_key_register(void);
-extern void afs_key_unregister(void);
-#endif
+extern int afs_iget(struct super_block *, struct afs_fid *, struct inode **);
+extern int afs_inode_getattr(struct vfsmount *, struct dentry *,
+			     struct kstat *);
+extern void afs_clear_inode(struct inode *);
 
 /*
  * main.c
@@ -110,7 +100,7 @@ extern struct afs_timer afs_mntpt_expiry_timer;
 extern struct afs_timer_ops afs_mntpt_expiry_timer_ops;
 extern unsigned long afs_mntpt_expiry_timeout;
 
-extern int afs_mntpt_check_symlink(struct afs_vnode *vnode);
+extern int afs_mntpt_check_symlink(struct afs_vnode *);
 
 /*
  * super.c
@@ -123,17 +113,17 @@ extern void afs_fs_exit(void);
 extern struct list_head afs_cb_hash_tbl[];
 extern spinlock_t afs_cb_hash_lock;
 
-#define afs_cb_hash(SRV,FID) \
-	afs_cb_hash_tbl[((unsigned long)(SRV) + \
-			(FID)->vid + (FID)->vnode + (FID)->unique) % \
-			AFS_CB_HASH_COUNT]
+#define afs_cb_hash(SRV, FID)						\
+	afs_cb_hash_tbl[((unsigned long)(SRV) +				\
+			 (FID)->vid + (FID)->vnode + (FID)->unique) &	\
+			(AFS_CB_HASH_COUNT - 1)]
 
 /*
  * proc.c
  */
 extern int afs_proc_init(void);
 extern void afs_proc_cleanup(void);
-extern int afs_proc_cell_setup(struct afs_cell *cell);
-extern void afs_proc_cell_remove(struct afs_cell *cell);
+extern int afs_proc_cell_setup(struct afs_cell *);
+extern void afs_proc_cell_remove(struct afs_cell *);
 
 #endif /* AFS_INTERNAL_H */
diff --git a/fs/afs/kafsasyncd.c b/fs/afs/kafsasyncd.c
index 615df24..8ca01c2 100644
--- a/fs/afs/kafsasyncd.c
+++ b/fs/afs/kafsasyncd.c
@@ -1,4 +1,4 @@
-/* kafsasyncd.c: AFS asynchronous operation daemon
+/* AFS asynchronous operation daemon
  *
  * Copyright (C) 2002 Red Hat, Inc. All Rights Reserved.
  * Written by David Howells (dhowells@redhat.com)
@@ -50,7 +50,6 @@ static void kafsasyncd_null_call_error_func(struct rxrpc_call *call)
 {
 }
 
-/*****************************************************************************/
 /*
  * start the async daemon
  */
@@ -65,9 +64,8 @@ int afs_kafsasyncd_start(void)
 	wait_for_completion(&kafsasyncd_alive);
 
 	return ret;
-} /* end afs_kafsasyncd_start() */
+}
 
-/*****************************************************************************/
 /*
  * stop the async daemon
  */
@@ -77,10 +75,8 @@ void afs_kafsasyncd_stop(void)
 	kafsasyncd_die = 1;
 	wake_up(&kafsasyncd_sleepq);
 	wait_for_completion(&kafsasyncd_dead);
+}
 
-} /* end afs_kafsasyncd_stop() */
-
-/*****************************************************************************/
 /*
  * probing daemon
  */
@@ -187,10 +183,8 @@ static int kafsasyncd(void *arg)
 	/* and that's all */
 	_leave("");
 	complete_and_exit(&kafsasyncd_dead, 0);
+}
 
-} /* end kafsasyncd() */
-
-/*****************************************************************************/
 /*
  * begin an operation
  * - place operation on busy queue
@@ -209,9 +203,8 @@ void afs_kafsasyncd_begin_op(struct afs_async_op *op)
 	spin_unlock(&kafsasyncd_async_lock);
 
 	_leave("");
-} /* end afs_kafsasyncd_begin_op() */
+}
 
-/*****************************************************************************/
 /*
  * request attention for an operation
  * - move to attention queue
@@ -229,9 +222,8 @@ void afs_kafsasyncd_attend_op(struct afs_async_op *op)
 	wake_up(&kafsasyncd_sleepq);
 
 	_leave("");
-} /* end afs_kafsasyncd_attend_op() */
+}
 
-/*****************************************************************************/
 /*
  * terminate an operation
  * - remove from either queue
@@ -252,4 +244,4 @@ void afs_kafsasyncd_terminate_op(struct afs_async_op *op)
 	wake_up(&kafsasyncd_sleepq);
 
 	_leave("");
-} /* end afs_kafsasyncd_terminate_op() */
+}
diff --git a/fs/afs/kafsasyncd.h b/fs/afs/kafsasyncd.h
index 791803f..1273eb5 100644
--- a/fs/afs/kafsasyncd.h
+++ b/fs/afs/kafsasyncd.h
@@ -1,4 +1,4 @@
-/* kafsasyncd.h: AFS asynchronous operation daemon
+/* AFS asynchronous operation daemon
  *
  * Copyright (C) 2002 Red Hat, Inc. All Rights Reserved.
  * Written by David Howells (dhowells@redhat.com)
@@ -9,24 +9,22 @@
  * 2 of the License, or (at your option) any later version.
  */
 
-#ifndef _LINUX_AFS_KAFSASYNCD_H
-#define _LINUX_AFS_KAFSASYNCD_H
+#ifndef AFS_KAFSASYNCD_H
+#define AFS_KAFSASYNCD_H
 
 #include "types.h"
 
 struct afs_async_op;
 
 struct afs_async_op_ops {
-	void (*attend)(struct afs_async_op *op);
-	void (*discard)(struct afs_async_op *op);
+	void (*attend)(struct afs_async_op *);
+	void (*discard)(struct afs_async_op *);
 };
 
-/*****************************************************************************/
 /*
  * asynchronous operation record
  */
-struct afs_async_op
-{
+struct afs_async_op {
 	struct list_head		link;
 	struct afs_server		*server;	/* server being contacted */
 	struct rxrpc_call		*call;		/* RxRPC call performing op */
@@ -45,8 +43,8 @@ static inline void afs_async_op_init(struct afs_async_op *op,
 extern int afs_kafsasyncd_start(void);
 extern void afs_kafsasyncd_stop(void);
 
-extern void afs_kafsasyncd_begin_op(struct afs_async_op *op);
-extern void afs_kafsasyncd_attend_op(struct afs_async_op *op);
-extern void afs_kafsasyncd_terminate_op(struct afs_async_op *op);
+extern void afs_kafsasyncd_begin_op(struct afs_async_op *);
+extern void afs_kafsasyncd_attend_op(struct afs_async_op *);
+extern void afs_kafsasyncd_terminate_op(struct afs_async_op *);
 
-#endif /* _LINUX_AFS_KAFSASYNCD_H */
+#endif /* AFS_KAFSASYNCD_H */
diff --git a/fs/afs/kafstimod.c b/fs/afs/kafstimod.c
index 694344e..3526dcc 100644
--- a/fs/afs/kafstimod.c
+++ b/fs/afs/kafstimod.c
@@ -1,4 +1,4 @@
-/* kafstimod.c: AFS timeout daemon
+/* AFS timeout daemon
  *
  * Copyright (C) 2002 Red Hat, Inc. All Rights Reserved.
  * Written by David Howells (dhowells@redhat.com)
@@ -30,7 +30,6 @@ static DEFINE_SPINLOCK(kafstimod_lock);
 
 static int kafstimod(void *arg);
 
-/*****************************************************************************/
 /*
  * start the timeout daemon
  */
@@ -45,9 +44,8 @@ int afs_kafstimod_start(void)
 	wait_for_completion(&kafstimod_alive);
 
 	return ret;
-} /* end afs_kafstimod_start() */
+}
 
-/*****************************************************************************/
 /*
  * stop the timeout daemon
  */
@@ -57,10 +55,8 @@ void afs_kafstimod_stop(void)
 	kafstimod_die = 1;
 	wake_up(&kafstimod_sleepq);
 	wait_for_completion(&kafstimod_dead);
+}
 
-} /* end afs_kafstimod_stop() */
-
-/*****************************************************************************/
 /*
  * timeout processing daemon
  */
@@ -77,7 +73,7 @@ static int kafstimod(void *arg)
 	complete(&kafstimod_alive);
 
 	/* loop around looking for things to attend to */
- loop:
+loop:
 	set_current_state(TASK_INTERRUPTIBLE);
 	add_wait_queue(&kafstimod_sleepq, &myself);
 
@@ -101,8 +97,7 @@ static int kafstimod(void *arg)
 		spin_lock(&kafstimod_lock);
 		if (list_empty(&kafstimod_list)) {
 			timeout = MAX_SCHEDULE_TIMEOUT;
-		}
-		else {
+		} else {
 			timer = list_entry(kafstimod_list.next,
 					   struct afs_timer, link);
 			timeout = timer->timo_jif;
@@ -110,10 +105,7 @@ static int kafstimod(void *arg)
 
 			if (time_before_eq((unsigned long) timeout, jif))
 				goto immediate;
-
-			else {
-				timeout = (long) timeout - (long) jiffies;
-			}
+			timeout = (long) timeout - (long) jiffies;
 		}
 		spin_unlock(&kafstimod_lock);
 
@@ -126,7 +118,7 @@ static int kafstimod(void *arg)
 	 * - we come here with the lock held and timer pointing to the expired
 	 *   entry
 	 */
- immediate:
+immediate:
 	remove_wait_queue(&kafstimod_sleepq, &myself);
 	set_current_state(TASK_RUNNING);
 
@@ -141,10 +133,8 @@ static int kafstimod(void *arg)
 
 	_debug("@@@ End Timeout");
 	goto loop;
+}
 
-} /* end kafstimod() */
-
-/*****************************************************************************/
 /*
  * (re-)queue a timer
  */
@@ -176,9 +166,8 @@ void afs_kafstimod_add_timer(struct afs_timer *timer, unsigned long timeout)
 	wake_up(&kafstimod_sleepq);
 
 	_leave("");
-} /* end afs_kafstimod_add_timer() */
+}
 
-/*****************************************************************************/
 /*
  * dequeue a timer
  * - returns 0 if the timer was deleted or -ENOENT if it wasn't queued
@@ -202,4 +191,4 @@ int afs_kafstimod_del_timer(struct afs_timer *timer)
 
 	_leave(" = %d", ret);
 	return ret;
-} /* end afs_kafstimod_del_timer() */
+}
diff --git a/fs/afs/kafstimod.h b/fs/afs/kafstimod.h
index e312f1a..0d39bec 100644
--- a/fs/afs/kafstimod.h
+++ b/fs/afs/kafstimod.h
@@ -1,4 +1,4 @@
-/* kafstimod.h: AFS timeout daemon
+/* AFS timeout daemon
  *
  * Copyright (C) 2002 Red Hat, Inc. All Rights Reserved.
  * Written by David Howells (dhowells@redhat.com)
@@ -9,8 +9,8 @@
  * 2 of the License, or (at your option) any later version.
  */
 
-#ifndef _LINUX_AFS_KAFSTIMOD_H
-#define _LINUX_AFS_KAFSTIMOD_H
+#ifndef AFS_KAFSTIMOD_H
+#define AFS_KAFSTIMOD_H
 
 #include "types.h"
 
@@ -18,15 +18,13 @@ struct afs_timer;
 
 struct afs_timer_ops {
 	/* called when the front of the timer queue has timed out */
-	void (*timed_out)(struct afs_timer *timer);
+	void (*timed_out)(struct afs_timer *);
 };
 
-/*****************************************************************************/
 /*
  * AFS timer/timeout record
  */
-struct afs_timer
-{
+struct afs_timer {
 	struct list_head		link;		/* link in timer queue */
 	unsigned long			timo_jif;	/* timeout time */
 	const struct afs_timer_ops	*ops;		/* timeout expiry function */
@@ -41,9 +39,7 @@ static inline void afs_timer_init(struct afs_timer *timer,
 
 extern int afs_kafstimod_start(void);
 extern void afs_kafstimod_stop(void);
+extern void afs_kafstimod_add_timer(struct afs_timer *, unsigned long);
+extern int afs_kafstimod_del_timer(struct afs_timer *);
 
-extern void afs_kafstimod_add_timer(struct afs_timer *timer,
-				    unsigned long timeout);
-extern int afs_kafstimod_del_timer(struct afs_timer *timer);
-
-#endif /* _LINUX_AFS_KAFSTIMOD_H */
+#endif /* AFS_KAFSTIMOD_H */
diff --git a/fs/afs/main.c b/fs/afs/main.c
index f2704ba..5bf39f6 100644
--- a/fs/afs/main.c
+++ b/fs/afs/main.c
@@ -1,4 +1,4 @@
-/* main.c: AFS client file system
+/* AFS client file system
  *
  * Copyright (C) 2002 Red Hat, Inc. All Rights Reserved.
  * Written by David Howells (dhowells@redhat.com)
@@ -62,7 +62,6 @@ struct cachefs_netfs afs_cache_netfs = {
 };
 #endif
 
-/*****************************************************************************/
 /*
  * initialise the AFS client FS module
  */
@@ -87,70 +86,61 @@ static int __init afs_init(void)
 	ret = cachefs_register_netfs(&afs_cache_netfs,
 				     &afs_cache_cell_index_def);
 	if (ret < 0)
-		goto error;
-#endif
-
-#ifdef CONFIG_KEYS_TURNED_OFF
-	ret = afs_key_register();
-	if (ret < 0)
 		goto error_cache;
 #endif
 
 	/* initialise the cell DB */
 	ret = afs_cell_init(rootcell);
 	if (ret < 0)
-		goto error_keys;
+		goto error_cell_init;
 
 	/* start the timeout daemon */
 	ret = afs_kafstimod_start();
 	if (ret < 0)
-		goto error_keys;
+		goto error_kafstimod;
 
 	/* start the async operation daemon */
 	ret = afs_kafsasyncd_start();
 	if (ret < 0)
-		goto error_kafstimod;
+		goto error_kafsasyncd;
 
 	/* create the RxRPC transport */
 	ret = rxrpc_create_transport(7001, &afs_transport);
 	if (ret < 0)
-		goto error_kafsasyncd;
+		goto error_transport;
 
 	afs_transport->peer_ops = &afs_peer_ops;
 
 	/* register the filesystems */
 	ret = afs_fs_init();
 	if (ret < 0)
-		goto error_transport;
+		goto error_fs;
 
 	return ret;
 
- error_transport:
+error_fs:
 	rxrpc_put_transport(afs_transport);
- error_kafsasyncd:
+error_transport:
 	afs_kafsasyncd_stop();
- error_kafstimod:
+error_kafsasyncd:
 	afs_kafstimod_stop();
- error_keys:
-#ifdef CONFIG_KEYS_TURNED_OFF
-	afs_key_unregister();
- error_cache:
-#endif
+error_kafstimod:
+error_cell_init:
 #ifdef AFS_CACHING_SUPPORT
 	cachefs_unregister_netfs(&afs_cache_netfs);
- error:
+error_cache:
 #endif
 	afs_cell_purge();
 	afs_proc_cleanup();
 	printk(KERN_ERR "kAFS: failed to register: %d\n", ret);
 	return ret;
-} /* end afs_init() */
+}
 
 /* XXX late_initcall is kludgy, but the only alternative seems to create
  * a transport upon the first mount, which is worse. Or is it?
  */
 late_initcall(afs_init);	/* must be called after net/ to create socket */
-/*****************************************************************************/
+
 /*
  * clean up on module removal
  */
@@ -163,19 +153,14 @@ static void __exit afs_exit(void)
 	afs_kafstimod_stop();
 	afs_kafsasyncd_stop();
 	afs_cell_purge();
-#ifdef CONFIG_KEYS_TURNED_OFF
-	afs_key_unregister();
-#endif
 #ifdef AFS_CACHING_SUPPORT
 	cachefs_unregister_netfs(&afs_cache_netfs);
 #endif
 	afs_proc_cleanup();
-
-} /* end afs_exit() */
+}
 
 module_exit(afs_exit);
 
-/*****************************************************************************/
 /*
  * notification that new peer record is being added
  * - called from krxsecd
@@ -208,9 +193,8 @@ static int afs_adding_peer(struct rxrpc_peer *peer)
 	afs_put_server(server);
 
 	return 0;
-} /* end afs_adding_peer() */
+}
 
-/*****************************************************************************/
 /*
  * notification that a peer record is being discarded
  * - called from krxiod or krxsecd
@@ -236,50 +220,4 @@ static void afs_discarding_peer(struct rxrpc_peer *peer)
 	spin_unlock(&afs_server_peer_lock);
 
 	_leave("");
-
-} /* end afs_discarding_peer() */
-
-/*****************************************************************************/
-/*
- * clear the dead space between task_struct and kernel stack
- * - called by supplying -finstrument-functions to gcc
- */
-#if 0
-void __cyg_profile_func_enter (void *this_fn, void *call_site)
-__attribute__((no_instrument_function));
-
-void __cyg_profile_func_enter (void *this_fn, void *call_site)
-{
-       asm volatile("  movl    %%esp,%%edi     \n"
-                    "  andl    %0,%%edi        \n"
-                    "  addl    %1,%%edi        \n"
-                    "  movl    %%esp,%%ecx     \n"
-                    "  subl    %%edi,%%ecx     \n"
-                    "  shrl    $2,%%ecx        \n"
-                    "  movl    $0xedededed,%%eax     \n"
-                    "  rep stosl               \n"
-                    :
-                    : "i"(~(THREAD_SIZE - 1)), "i"(sizeof(struct thread_info))
-                    : "eax", "ecx", "edi", "memory", "cc"
-                    );
-}
-
-void __cyg_profile_func_exit(void *this_fn, void *call_site)
-__attribute__((no_instrument_function));
-
-void __cyg_profile_func_exit(void *this_fn, void *call_site)
-{
-       asm volatile("  movl    %%esp,%%edi     \n"
-                    "  andl    %0,%%edi        \n"
-                    "  addl    %1,%%edi        \n"
-                    "  movl    %%esp,%%ecx     \n"
-                    "  subl    %%edi,%%ecx     \n"
-                    "  shrl    $2,%%ecx        \n"
-                    "  movl    $0xdadadada,%%eax     \n"
-                    "  rep stosl               \n"
-                    :
-                    : "i"(~(THREAD_SIZE - 1)), "i"(sizeof(struct thread_info))
-                    : "eax", "ecx", "edi", "memory", "cc"
-                    );
 }
-#endif
diff --git a/fs/afs/misc.c b/fs/afs/misc.c
index e4fce66..55bc677 100644
--- a/fs/afs/misc.c
+++ b/fs/afs/misc.c
@@ -1,4 +1,4 @@
-/* misc.c: miscellaneous bits
+/* miscellaneous bits
  *
  * Copyright (C) 2002 Red Hat, Inc. All Rights Reserved.
  * Written by David Howells (dhowells@redhat.com)
@@ -15,7 +15,6 @@
 #include "errors.h"
 #include "internal.h"
 
-/*****************************************************************************/
 /*
  * convert an AFS abort code to a Linux error number
  */
@@ -35,5 +34,4 @@ int afs_abort_to_error(int abortcode)
 	case VMOVED:		return -ENXIO;
 	default:		return -EIO;
 	}
-
-} /* end afs_abort_to_error() */
+}
diff --git a/fs/afs/mntpt.c b/fs/afs/mntpt.c
index 68495f0..ca3fa81 100644
--- a/fs/afs/mntpt.c
+++ b/fs/afs/mntpt.c
@@ -1,4 +1,4 @@
-/* mntpt.c: mountpoint management
+/* mountpoint management
  *
  * Copyright (C) 2002 Red Hat, Inc. All Rights Reserved.
  * Written by David Howells (dhowells@redhat.com)
@@ -54,7 +54,6 @@ struct afs_timer afs_mntpt_expiry_timer;
 
 unsigned long afs_mntpt_expiry_timeout = 20;
 
-/*****************************************************************************/
 /*
  * check a symbolic link to see whether it actually encodes a mountpoint
  * - sets the AFS_VNODE_MOUNTPOINT flag on the vnode appropriately
@@ -99,16 +98,14 @@ int afs_mntpt_check_symlink(struct afs_vnode *vnode)
 
 	ret = 0;
 
- out_free:
+out_free:
 	kunmap(page);
 	page_cache_release(page);
- out:
+out:
 	_leave(" = %d", ret);
 	return ret;
+}
 
-} /* end afs_mntpt_check_symlink() */
-
-/*****************************************************************************/
 /*
  * no valid lookup procedure on this sort of dir
  */
@@ -125,9 +122,8 @@ static struct dentry *afs_mntpt_lookup(struct inode *dir,
 	       dentry->d_name.name);
 
 	return ERR_PTR(-EREMOTE);
-} /* end afs_mntpt_lookup() */
+}
 
-/*****************************************************************************/
 /*
  * no valid open procedure on this sort of dir
  */
@@ -142,9 +138,8 @@ static int afs_mntpt_open(struct inode *inode, struct file *file)
 	       file->f_path.dentry->d_name.name);
 
 	return -EREMOTE;
-} /* end afs_mntpt_open() */
+}
 
-/*****************************************************************************/
 /*
  * create a vfsmount to be automounted
  */
@@ -210,7 +205,7 @@ static struct vfsmount *afs_mntpt_do_automount(struct dentry *mntpt)
 	kleave(" = %p", mnt);
 	return mnt;
 
- error:
+error:
 	if (page)
 		page_cache_release(page);
 	if (devname)
@@ -219,9 +214,8 @@ static struct vfsmount *afs_mntpt_do_automount(struct dentry *mntpt)
 		free_page((unsigned long) options);
 	kleave(" = %d", ret);
 	return ERR_PTR(ret);
-} /* end afs_mntpt_do_automount() */
+}
 
-/*****************************************************************************/
 /*
  * follow a link from a mountpoint directory, thus causing it to be mounted
  */
@@ -260,9 +254,8 @@ static void *afs_mntpt_follow_link(struct dentry *dentry, struct nameidata *nd)
 
 	kleave(" = %d", err);
 	return ERR_PTR(err);
-} /* end afs_mntpt_follow_link() */
+}
 
-/*****************************************************************************/
 /*
  * handle mountpoint expiry timer going off
  */
@@ -276,4 +269,4 @@ static void afs_mntpt_expiry_timed_out(struct afs_timer *timer)
 				afs_mntpt_expiry_timeout * HZ);
 
 	kleave("");
-} /* end afs_mntpt_expiry_timed_out() */
+}
diff --git a/fs/afs/mount.h b/fs/afs/mount.h
index 9d2f46e..41b8483 100644
--- a/fs/afs/mount.h
+++ b/fs/afs/mount.h
@@ -1,4 +1,4 @@
-/* mount.h: mount parameters
+/* mount parameters
  *
  * Copyright (C) 2002 Red Hat, Inc. All Rights Reserved.
  * Written by David Howells (dhowells@redhat.com)
@@ -9,8 +9,8 @@
  * 2 of the License, or (at your option) any later version.
  */
 
-#ifndef _LINUX_AFS_MOUNT_H
-#define _LINUX_AFS_MOUNT_H
+#ifndef AFS_MOUNT_H
+#define AFS_MOUNT_H
 
 struct afs_mountdata {
 	const char		*volume;	/* name of volume */
@@ -20,4 +20,4 @@ struct afs_mountdata {
 	uint32_t		servers[10];	/* IP addresses of servers in this cell */
 };
 
-#endif /* _LINUX_AFS_MOUNT_H */
+#endif /* AFS_MOUNT_H */
diff --git a/fs/afs/proc.c b/fs/afs/proc.c
index ae6b85b..5ebcc0c 100644
--- a/fs/afs/proc.c
+++ b/fs/afs/proc.c
@@ -1,4 +1,4 @@
-/* proc.c: /proc interface for AFS
+/* /proc interface for AFS
  *
  * Copyright (C) 2002 Red Hat, Inc. All Rights Reserved.
  * Written by David Howells (dhowells@redhat.com)
@@ -130,7 +130,6 @@ static const struct file_operations afs_proc_cell_servers_fops = {
 	.release	= afs_proc_cell_servers_release,
 };
 
-/*****************************************************************************/
 /*
  * initialise the /proc/fs/afs/ directory
  */
@@ -142,47 +141,43 @@ int afs_proc_init(void)
 
 	proc_afs = proc_mkdir("fs/afs", NULL);
 	if (!proc_afs)
-		goto error;
+		goto error_dir;
 	proc_afs->owner = THIS_MODULE;
 
 	p = create_proc_entry("cells", 0, proc_afs);
 	if (!p)
-		goto error_proc;
+		goto error_cells;
 	p->proc_fops = &afs_proc_cells_fops;
 	p->owner = THIS_MODULE;
 
 	p = create_proc_entry("rootcell", 0, proc_afs);
 	if (!p)
-		goto error_cells;
+		goto error_rootcell;
 	p->proc_fops = &afs_proc_rootcell_fops;
 	p->owner = THIS_MODULE;
 
 	_leave(" = 0");
 	return 0;
 
- error_cells:
+error_rootcell:
  	remove_proc_entry("cells", proc_afs);
- error_proc:
+error_cells:
 	remove_proc_entry("fs/afs", NULL);
- error:
+error_dir:
 	_leave(" = -ENOMEM");
 	return -ENOMEM;
+}
 
-} /* end afs_proc_init() */
-
-/*****************************************************************************/
 /*
  * clean up the /proc/fs/afs/ directory
  */
 void afs_proc_cleanup(void)
 {
+	remove_proc_entry("rootcell", proc_afs);
 	remove_proc_entry("cells", proc_afs);
-
 	remove_proc_entry("fs/afs", NULL);
+}
 
-} /* end afs_proc_cleanup() */
-
-/*****************************************************************************/
 /*
  * open "/proc/fs/afs/cells" which provides a summary of extant cells
  */
@@ -199,9 +194,8 @@ static int afs_proc_cells_open(struct inode *inode, struct file *file)
 	m->private = PDE(inode)->data;
 
 	return 0;
-} /* end afs_proc_cells_open() */
+}
 
-/*****************************************************************************/
 /*
  * set up the iterator to start reading from the cells list and return the
  * first item
@@ -225,9 +219,8 @@ static void *afs_proc_cells_start(struct seq_file *m, loff_t *_pos)
 			break;
 
 	return _p != &afs_proc_cells ? _p : NULL;
-} /* end afs_proc_cells_start() */
+}
 
-/*****************************************************************************/
 /*
  * move to next cell in cells list
  */
@@ -241,19 +234,16 @@ static void *afs_proc_cells_next(struct seq_file *p, void *v, loff_t *pos)
 	_p = v == (void *) 1 ? afs_proc_cells.next : _p->next;
 
 	return _p != &afs_proc_cells ? _p : NULL;
-} /* end afs_proc_cells_next() */
+}
 
-/*****************************************************************************/
 /*
  * clean up after reading from the cells list
  */
 static void afs_proc_cells_stop(struct seq_file *p, void *v)
 {
 	up_read(&afs_proc_cells_sem);
+}
 
-} /* end afs_proc_cells_stop() */
-
-/*****************************************************************************/
 /*
  * display a header line followed by a load of cell lines
  */
@@ -261,19 +251,18 @@ static int afs_proc_cells_show(struct seq_file *m, void *v)
 {
 	struct afs_cell *cell = list_entry(v, struct afs_cell, proc_link);
 
-	/* display header on line 1 */
 	if (v == (void *) 1) {
+		/* display header on line 1 */
 		seq_puts(m, "USE NAME\n");
 		return 0;
 	}
 
 	/* display one cell per line on subsequent lines */
-	seq_printf(m, "%3d %s\n", atomic_read(&cell->usage), cell->name);
-
+	seq_printf(m, "%3d %s\n",
+		   atomic_read(&cell->usage), cell->name);
 	return 0;
-} /* end afs_proc_cells_show() */
+}
 
-/*****************************************************************************/
 /*
  * handle writes to /proc/fs/afs/cells
  * - to add cells: echo "add <cellname> <IP>[:<IP>][:<IP>]"
@@ -331,25 +320,23 @@ static ssize_t afs_proc_cells_write(struct file *file, const char __user *buf,
 			goto done;
 
 		printk("kAFS: Added new cell '%s'\n", name);
-	}
-	else {
+	} else {
 		goto inval;
 	}
 
 	ret = size;
 
- done:
+done:
 	kfree(kbuf);
 	_leave(" = %d", ret);
 	return ret;
 
- inval:
+inval:
 	ret = -EINVAL;
 	printk("kAFS: Invalid Command on /proc/fs/afs/cells file\n");
 	goto done;
-} /* end afs_proc_cells_write() */
+}
 
-/*****************************************************************************/
 /*
  * Stubs for /proc/fs/afs/rootcell
  */
@@ -369,7 +356,6 @@ static ssize_t afs_proc_rootcell_read(struct file *file, char __user *buf,
 	return 0;
 }
 
-/*****************************************************************************/
 /*
  * handle writes to /proc/fs/afs/rootcell
  * - to initialize rootcell: echo "cell.name:192.168.231.14"
@@ -407,14 +393,13 @@ static ssize_t afs_proc_rootcell_write(struct file *file,
 	if (ret >= 0)
 		ret = size;	/* consume everything, always */
 
- infault:
+infault:
 	kfree(kbuf);
- nomem:
+nomem:
 	_leave(" = %d", ret);
 	return ret;
-} /* end afs_proc_rootcell_write() */
+}
 
-/*****************************************************************************/
 /*
  * initialise /proc/fs/afs/<cell>/
  */
@@ -426,25 +411,25 @@ int afs_proc_cell_setup(struct afs_cell *cell)
 
 	cell->proc_dir = proc_mkdir(cell->name, proc_afs);
 	if (!cell->proc_dir)
-		return -ENOMEM;
+		goto error_dir;
 
 	p = create_proc_entry("servers", 0, cell->proc_dir);
 	if (!p)
-		goto error_proc;
+		goto error_servers;
 	p->proc_fops = &afs_proc_cell_servers_fops;
 	p->owner = THIS_MODULE;
 	p->data = cell;
 
 	p = create_proc_entry("vlservers", 0, cell->proc_dir);
 	if (!p)
-		goto error_servers;
+		goto error_vlservers;
 	p->proc_fops = &afs_proc_cell_vlservers_fops;
 	p->owner = THIS_MODULE;
 	p->data = cell;
 
 	p = create_proc_entry("volumes", 0, cell->proc_dir);
 	if (!p)
-		goto error_vlservers;
+		goto error_volumes;
 	p->proc_fops = &afs_proc_cell_volumes_fops;
 	p->owner = THIS_MODULE;
 	p->data = cell;
@@ -452,17 +437,17 @@ int afs_proc_cell_setup(struct afs_cell *cell)
 	_leave(" = 0");
 	return 0;
 
- error_vlservers:
+error_volumes:
 	remove_proc_entry("vlservers", cell->proc_dir);
- error_servers:
+error_vlservers:
 	remove_proc_entry("servers", cell->proc_dir);
- error_proc:
+error_servers:
 	remove_proc_entry(cell->name, proc_afs);
+error_dir:
 	_leave(" = -ENOMEM");
 	return -ENOMEM;
-} /* end afs_proc_cell_setup() */
+}
 
-/*****************************************************************************/
 /*
  * remove /proc/fs/afs/<cell>/
  */
@@ -476,9 +461,8 @@ void afs_proc_cell_remove(struct afs_cell *cell)
 	remove_proc_entry(cell->name, proc_afs);
 
 	_leave("");
-} /* end afs_proc_cell_remove() */
+}
 
-/*****************************************************************************/
 /*
  * open "/proc/fs/afs/<cell>/volumes" which provides a summary of extant cells
  */
@@ -500,9 +484,8 @@ static int afs_proc_cell_volumes_open(struct inode *inode, struct file *file)
 	m->private = cell;
 
 	return 0;
-} /* end afs_proc_cell_volumes_open() */
+}
 
-/*****************************************************************************/
 /*
  * close the file and release the ref to the cell
  */
@@ -511,14 +494,12 @@ static int afs_proc_cell_volumes_release(struct inode *inode, struct file *file)
 	struct afs_cell *cell = PDE(inode)->data;
 	int ret;
 
-	ret = seq_release(inode,file);
+	ret = seq_release(inode, file);
 
 	afs_put_cell(cell);
-
 	return ret;
-} /* end afs_proc_cell_volumes_release() */
+}
 
-/*****************************************************************************/
 /*
  * set up the iterator to start reading from the cells list and return the
  * first item
@@ -545,9 +526,8 @@ static void *afs_proc_cell_volumes_start(struct seq_file *m, loff_t *_pos)
 			break;
 
 	return _p != &cell->vl_list ? _p : NULL;
-} /* end afs_proc_cell_volumes_start() */
+}
 
-/*****************************************************************************/
 /*
  * move to next cell in cells list
  */
@@ -562,12 +542,11 @@ static void *afs_proc_cell_volumes_next(struct seq_file *p, void *v,
 	(*_pos)++;
 
 	_p = v;
-	_p = v == (void *) 1 ? cell->vl_list.next : _p->next;
+	_p = (v == (void *) 1) ? cell->vl_list.next : _p->next;
 
-	return _p != &cell->vl_list ? _p : NULL;
-} /* end afs_proc_cell_volumes_next() */
+	return (_p != &cell->vl_list) ? _p : NULL;
+}
 
-/*****************************************************************************/
 /*
  * clean up after reading from the cells list
  */
@@ -576,10 +555,8 @@ static void afs_proc_cell_volumes_stop(struct seq_file *p, void *v)
 	struct afs_cell *cell = p->private;
 
 	up_read(&cell->vl_sem);
+}
 
-} /* end afs_proc_cell_volumes_stop() */
-
-/*****************************************************************************/
 /*
  * display a header line followed by a load of volume lines
  */
@@ -600,13 +577,11 @@ static int afs_proc_cell_volumes_show(struct seq_file *m, void *v)
 		   vlocation->vldb.vid[0],
 		   vlocation->vldb.vid[1],
 		   vlocation->vldb.vid[2],
-		   vlocation->vldb.name
-		   );
+		   vlocation->vldb.name);
 
 	return 0;
-} /* end afs_proc_cell_volumes_show() */
+}
 
-/*****************************************************************************/
 /*
  * open "/proc/fs/afs/<cell>/vlservers" which provides a list of volume
  * location server
@@ -629,9 +604,8 @@ static int afs_proc_cell_vlservers_open(struct inode *inode, struct file *file)
 	m->private = cell;
 
 	return 0;
-} /* end afs_proc_cell_vlservers_open() */
+}
 
-/*****************************************************************************/
 /*
  * close the file and release the ref to the cell
  */
@@ -644,11 +618,9 @@ static int afs_proc_cell_vlservers_release(struct inode *inode,
 	ret = seq_release(inode,file);
 
 	afs_put_cell(cell);
-
 	return ret;
-} /* end afs_proc_cell_vlservers_release() */
+}
 
-/*****************************************************************************/
 /*
  * set up the iterator to start reading from the cells list and return the
  * first item
@@ -672,9 +644,8 @@ static void *afs_proc_cell_vlservers_start(struct seq_file *m, loff_t *_pos)
 		return NULL;
 
 	return &cell->vl_addrs[pos];
-} /* end afs_proc_cell_vlservers_start() */
+}
 
-/*****************************************************************************/
 /*
  * move to next cell in cells list
  */
@@ -692,9 +663,8 @@ static void *afs_proc_cell_vlservers_next(struct seq_file *p, void *v,
 		return NULL;
 
 	return &cell->vl_addrs[pos];
-} /* end afs_proc_cell_vlservers_next() */
+}
 
-/*****************************************************************************/
 /*
  * clean up after reading from the cells list
  */
@@ -703,10 +673,8 @@ static void afs_proc_cell_vlservers_stop(struct seq_file *p, void *v)
 	struct afs_cell *cell = p->private;
 
 	up_read(&cell->vl_sem);
+}
 
-} /* end afs_proc_cell_vlservers_stop() */
-
-/*****************************************************************************/
 /*
  * display a header line followed by a load of volume lines
  */
@@ -722,11 +690,9 @@ static int afs_proc_cell_vlservers_show(struct seq_file *m, void *v)
 
 	/* display one cell per line on subsequent lines */
 	seq_printf(m, "%u.%u.%u.%u\n", NIPQUAD(addr->s_addr));
-
 	return 0;
-} /* end afs_proc_cell_vlservers_show() */
+}
 
-/*****************************************************************************/
 /*
  * open "/proc/fs/afs/<cell>/servers" which provides a summary of active
  * servers
@@ -747,11 +713,9 @@ static int afs_proc_cell_servers_open(struct inode *inode, struct file *file)
 
 	m = file->private_data;
 	m->private = cell;
-
 	return 0;
-} /* end afs_proc_cell_servers_open() */
+}
 
-/*****************************************************************************/
 /*
  * close the file and release the ref to the cell
  */
@@ -764,11 +728,9 @@ static int afs_proc_cell_servers_release(struct inode *inode,
 	ret = seq_release(inode, file);
 
 	afs_put_cell(cell);
-
 	return ret;
-} /* end afs_proc_cell_servers_release() */
+}
 
-/*****************************************************************************/
 /*
  * set up the iterator to start reading from the cells list and return the
  * first item
@@ -796,9 +758,8 @@ static void *afs_proc_cell_servers_start(struct seq_file *m, loff_t *_pos)
 			break;
 
 	return _p != &cell->sv_list ? _p : NULL;
-} /* end afs_proc_cell_servers_start() */
+}
 
-/*****************************************************************************/
 /*
  * move to next cell in cells list
  */
@@ -816,9 +777,8 @@ static void *afs_proc_cell_servers_next(struct seq_file *p, void *v,
 	_p = v == (void *) 1 ? cell->sv_list.next : _p->next;
 
 	return _p != &cell->sv_list ? _p : NULL;
-} /* end afs_proc_cell_servers_next() */
+}
 
-/*****************************************************************************/
 /*
  * clean up after reading from the cells list
  */
@@ -828,10 +788,8 @@ static void afs_proc_cell_servers_stop(struct seq_file *p, void *v)
 	struct afs_cell *cell = p->private;
 
 	read_unlock(&cell->sv_lock);
+}
 
-} /* end afs_proc_cell_servers_stop() */
-
-/*****************************************************************************/
 /*
  * display a header line followed by a load of volume lines
  */
@@ -849,10 +807,7 @@ static int afs_proc_cell_servers_show(struct seq_file *m, void *v)
 	/* display one cell per line on subsequent lines */
 	sprintf(ipaddr, "%u.%u.%u.%u", NIPQUAD(server->addr));
 	seq_printf(m, "%3d %-15.15s %5d\n",
-		   atomic_read(&server->usage),
-		   ipaddr,
-		   server->fs_state
-		   );
+		   atomic_read(&server->usage), ipaddr, server->fs_state);
 
 	return 0;
-} /* end afs_proc_cell_servers_show() */
+}
diff --git a/fs/afs/server.c b/fs/afs/server.c
index 44aff81..44b0ce5 100644
--- a/fs/afs/server.c
+++ b/fs/afs/server.c
@@ -1,4 +1,4 @@
-/* server.c: AFS server record management
+/* AFS server record management
  *
  * Copyright (C) 2002 Red Hat, Inc. All Rights Reserved.
  * Written by David Howells (dhowells@redhat.com)
@@ -41,7 +41,6 @@ static const struct afs_timer_ops afs_server_timer_ops = {
 	.timed_out	= __afs_server_timeout,
 };
 
-/*****************************************************************************/
 /*
  * lookup a server record in a cell
  * - TODO: search the cell's server list
@@ -106,7 +105,7 @@ int afs_server_lookup(struct afs_cell *cell, const struct in_addr *addr,
 	return 0;
 
 	/* found a matching active server */
- use_active_server:
+use_active_server:
 	_debug("active server");
 	afs_get_server(active);
 	write_unlock(&cell->sv_lock);
@@ -119,7 +118,7 @@ int afs_server_lookup(struct afs_cell *cell, const struct in_addr *addr,
 
 	/* found a matching server in the graveyard, so resurrect it and
 	 * dispose of the new record */
- resurrect_server:
+resurrect_server:
 	_debug("resurrecting server");
 
 	list_move_tail(&zombie->link, &cell->sv_list);
@@ -133,10 +132,8 @@ int afs_server_lookup(struct afs_cell *cell, const struct in_addr *addr,
 	*_server = zombie;
 	_leave(" = 0 (%p)", zombie);
 	return 0;
+}
 
-} /* end afs_server_lookup() */
-
-/*****************************************************************************/
 /*
  * destroy a server record
  * - removes from the cell list
@@ -175,9 +172,8 @@ void afs_put_server(struct afs_server *server)
 	write_unlock(&cell->sv_lock);
 
 	_leave(" [killed]");
-} /* end afs_put_server() */
+}
 
-/*****************************************************************************/
 /*
  * timeout server record
  * - removes from the cell's graveyard if the usage count is zero
@@ -230,9 +226,8 @@ void afs_server_do_timeout(struct afs_server *server)
 	kfree(server);
 
 	_leave(" [destroyed]");
-} /* end afs_server_do_timeout() */
+}
 
-/*****************************************************************************/
 /*
  * get a callslot on a connection to the fileserver on the specified server
  */
@@ -323,7 +318,7 @@ int afs_server_request_callslot(struct afs_server *server,
 	}
 
 	/* got a callslot, but no connection */
- obtained_slot:
+obtained_slot:
 
 	/* need to get hold of the RxRPC connection */
 	down_write(&server->sem);
@@ -337,8 +332,7 @@ int afs_server_request_callslot(struct afs_server *server,
 		/* reuse an existing connection */
 		rxrpc_get_connection(server->fs_conn[nconn]);
 		callslot->conn = server->fs_conn[nconn];
-	}
-	else {
+	} else {
 		/* create a new connection */
 		ret = rxrpc_create_connection(afs_transport,
 					      htons(7000),
@@ -360,23 +354,21 @@ int afs_server_request_callslot(struct afs_server *server,
 	return 0;
 
 	/* handle an error occurring */
- error_release_upw:
+error_release_upw:
 	up_write(&server->sem);
 
- error_release:
+error_release:
 	/* either release the callslot or pass it along to another deserving
 	 * task */
 	spin_lock(&server->fs_lock);
 
 	if (nconn < 0) {
 		/* no callslot allocated */
-	}
-	else if (list_empty(&server->fs_callq)) {
+	} else if (list_empty(&server->fs_callq)) {
 		/* no one waiting */
 		server->fs_conn_cnt[nconn]++;
 		spin_unlock(&server->fs_lock);
-	}
-	else {
+	} else {
 		/* someone's waiting - dequeue them and wake them up */
 		pcallslot = list_entry(server->fs_callq.next,
 				       struct afs_server_callslot, link);
@@ -400,10 +392,8 @@ int afs_server_request_callslot(struct afs_server *server,
 
 	_leave(" = %d", ret);
 	return ret;
+}
 
-} /* end afs_server_request_callslot() */
-
-/*****************************************************************************/
 /*
  * release a callslot back to the server
  * - transfers the RxRPC connection to the next pending callslot if possible
@@ -426,8 +416,7 @@ void afs_server_release_callslot(struct afs_server *server,
 		/* no one waiting */
 		server->fs_conn_cnt[callslot->nconn]++;
 		spin_unlock(&server->fs_lock);
-	}
-	else {
+	} else {
 		/* someone's waiting - dequeue them and wake them up */
 		pcallslot = list_entry(server->fs_callq.next,
 				       struct afs_server_callslot, link);
@@ -449,9 +438,8 @@ void afs_server_release_callslot(struct afs_server *server,
 	rxrpc_put_connection(callslot->conn);
 
 	_leave("");
-} /* end afs_server_release_callslot() */
+}
 
-/*****************************************************************************/
 /*
  * get a handle to a connection to the vlserver (volume location) on the
  * specified server
@@ -473,8 +461,7 @@ int afs_server_get_vlconn(struct afs_server *server,
 		rxrpc_get_connection(server->vlserver);
 		conn = server->vlserver;
 		up_read(&server->sem);
-	}
-	else {
+	} else {
 		/* create a new connection */
 		up_read(&server->sem);
 		down_write(&server->sem);
@@ -496,4 +483,4 @@ int afs_server_get_vlconn(struct afs_server *server,
 	*_conn = conn;
 	_leave(" = %d", ret);
 	return ret;
-} /* end afs_server_get_vlconn() */
+}
diff --git a/fs/afs/server.h b/fs/afs/server.h
index c3d2411..e1a0068 100644
--- a/fs/afs/server.h
+++ b/fs/afs/server.h
@@ -1,4 +1,4 @@
-/* server.h: AFS server record
+/* AFS server record
  *
  * Copyright (C) 2002 Red Hat, Inc. All Rights Reserved.
  * Written by David Howells (dhowells@redhat.com)
@@ -9,8 +9,8 @@
  * 2 of the License, or (at your option) any later version.
  */
 
-#ifndef _LINUX_AFS_SERVER_H
-#define _LINUX_AFS_SERVER_H
+#ifndef AFS_SERVER_H
+#define AFS_SERVER_H
 
 #include "types.h"
 #include "kafstimod.h"
@@ -19,12 +19,10 @@
 
 extern spinlock_t afs_server_peer_lock;
 
-/*****************************************************************************/
 /*
  * AFS server record
  */
-struct afs_server
-{
+struct afs_server {
 	atomic_t		usage;
 	struct afs_cell		*cell;		/* cell in which server resides */
 	struct list_head	link;		/* link in cell's server list */
@@ -50,20 +48,19 @@ struct afs_server
 	spinlock_t		cb_lock;	/* access lock */
 };
 
-extern int afs_server_lookup(struct afs_cell *cell,
-			     const struct in_addr *addr,
-			     struct afs_server **_server);
+extern int afs_server_lookup(struct afs_cell *, const struct in_addr *,
+			     struct afs_server **);
 
 #define afs_get_server(S) do { atomic_inc(&(S)->usage); } while(0)
 
-extern void afs_put_server(struct afs_server *server);
-extern void afs_server_do_timeout(struct afs_server *server);
+extern void afs_put_server(struct afs_server *);
+extern void afs_server_do_timeout(struct afs_server *);
 
-extern int afs_server_find_by_peer(const struct rxrpc_peer *peer,
-				   struct afs_server **_server);
+extern int afs_server_find_by_peer(const struct rxrpc_peer *,
+				   struct afs_server **);
 
-extern int afs_server_get_vlconn(struct afs_server *server,
-				 struct rxrpc_connection **_conn);
+extern int afs_server_get_vlconn(struct afs_server *,
+				 struct rxrpc_connection **);
 
 static inline
 struct afs_server *afs_server_get_from_peer(struct rxrpc_peer *peer)
@@ -79,12 +76,10 @@ struct afs_server *afs_server_get_from_peer(struct rxrpc_peer *peer)
 	return server;
 }
 
-/*****************************************************************************/
 /*
  * AFS server callslot grant record
  */
-struct afs_server_callslot
-{
+struct afs_server_callslot {
 	struct list_head	link;		/* link in server's list */
 	struct task_struct	*task;		/* process waiting to make call */
 	struct rxrpc_connection	*conn;		/* connection to use (or NULL on error) */
@@ -93,10 +88,10 @@ struct afs_server_callslot
 	int			errno;		/* error number if nconn==-1 */
 };
 
-extern int afs_server_request_callslot(struct afs_server *server,
-				       struct afs_server_callslot *callslot);
+extern int afs_server_request_callslot(struct afs_server *,
+				       struct afs_server_callslot *);
 
-extern void afs_server_release_callslot(struct afs_server *server,
-					struct afs_server_callslot *callslot);
+extern void afs_server_release_callslot(struct afs_server *,
+					struct afs_server_callslot *);
 
-#endif /* _LINUX_AFS_SERVER_H */
+#endif /* AFS_SERVER_H */
diff --git a/fs/afs/super.c b/fs/afs/super.c
index eb7e323..0470a5c 100644
--- a/fs/afs/super.c
+++ b/fs/afs/super.c
@@ -1,4 +1,5 @@
-/*
+/* AFS superblock handling
+ *
  * Copyright (c) 2002 Red Hat, Inc. All rights reserved.
  *
  * This software may be freely redistributed under the terms of the
@@ -9,7 +10,7 @@
  * Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
  *
  * Authors: David Howells <dhowells@redhat.com>
- *          David Woodhouse <dwmw2@cambridge.redhat.com>
+ *          David Woodhouse <dwmw2@redhat.com>
  *
  */
 
@@ -68,7 +69,6 @@ static const struct super_operations afs_super_ops = {
 static struct kmem_cache *afs_inode_cachep;
 static atomic_t afs_count_active_inodes;
 
-/*****************************************************************************/
 /*
  * initialise the filesystem
  */
@@ -105,9 +105,8 @@ int __init afs_fs_init(void)
 
 	kleave(" = 0");
 	return 0;
-} /* end afs_fs_init() */
+}
 
-/*****************************************************************************/
 /*
  * clean up the filesystem
  */
@@ -122,10 +121,8 @@ void __exit afs_fs_exit(void)
 	}
 
 	kmem_cache_destroy(afs_inode_cachep);
+}
 
-} /* end afs_fs_exit() */
-
-/*****************************************************************************/
 /*
  * check that an argument has a value
  */
@@ -136,9 +133,8 @@ static int want_arg(char **_value, const char *option)
 		return 0;
 	}
 	return 1;
-} /* end want_arg() */
+}
 
-/*****************************************************************************/
 /*
  * check that there's no subsequent value
  */
@@ -150,9 +146,8 @@ static int want_no_value(char *const *_value, const char *option)
 		return 0;
 	}
 	return 1;
-} /* end want_no_value() */
+}
 
-/*****************************************************************************/
 /*
  * parse the mount options
  * - this function has been shamelessly adapted from the ext3 fs which
@@ -183,14 +178,12 @@ static int afs_super_parse_options(struct afs_mount_params *params,
 				return -EINVAL;
 			params->rwpath = 1;
 			continue;
-		}
-		else if (strcmp(key, "vol") == 0) {
+		} else if (strcmp(key, "vol") == 0) {
 			if (!want_arg(&value, "vol"))
 				return -EINVAL;
 			*devname = value;
 			continue;
-		}
-		else if (strcmp(key, "cell") == 0) {
+		} else if (strcmp(key, "cell") == 0) {
 			if (!want_arg(&value, "cell"))
 				return -EINVAL;
 			afs_put_cell(params->default_cell);
@@ -209,12 +202,11 @@ static int afs_super_parse_options(struct afs_mount_params *params,
 
 	ret = 0;
 
- error:
+error:
 	_leave(" = %d", ret);
 	return ret;
-} /* end afs_super_parse_options() */
+}
 
-/*****************************************************************************/
 /*
  * check a superblock to see if it's the one we're looking for
  */
@@ -224,9 +216,8 @@ static int afs_test_super(struct super_block *sb, void *data)
 	struct afs_super_info *as = sb->s_fs_info;
 
 	return as->volume == params->volume;
-} /* end afs_test_super() */
+}
 
-/*****************************************************************************/
 /*
  * fill in the superblock
  */
@@ -276,7 +267,7 @@ static int afs_fill_super(struct super_block *sb, void *data, int silent)
 	kleave(" = 0");
 	return 0;
 
- error:
+error:
 	iput(inode);
 	afs_put_volume(as->volume);
 	kfree(as);
@@ -285,9 +276,8 @@ static int afs_fill_super(struct super_block *sb, void *data, int silent)
 
 	kleave(" = %d", ret);
 	return ret;
-} /* end afs_fill_super() */
+}
 
-/*****************************************************************************/
 /*
  * get an AFS superblock
  * - TODO: don't use get_sb_nodev(), but rather call sget() directly
@@ -354,15 +344,14 @@ static int afs_get_sb(struct file_system_type *fs_type,
 	_leave(" = 0 [%p]", 0, sb);
 	return 0;
 
- error:
+error:
 	afs_put_volume(params.volume);
 	afs_put_cell(params.default_cell);
 	afscm_stop();
 	_leave(" = %d", ret);
 	return ret;
-} /* end afs_get_sb() */
+}
 
-/*****************************************************************************/
 /*
  * finish the unmounting process on the superblock
  */
@@ -376,16 +365,15 @@ static void afs_put_super(struct super_block *sb)
 	afscm_stop();
 
 	_leave("");
-} /* end afs_put_super() */
+}
 
-/*****************************************************************************/
 /*
  * initialise an inode cache slab element prior to any use
  */
 static void afs_i_init_once(void *_vnode, struct kmem_cache *cachep,
 			    unsigned long flags)
 {
-	struct afs_vnode *vnode = (struct afs_vnode *) _vnode;
+	struct afs_vnode *vnode = _vnode;
 
 	if ((flags & (SLAB_CTOR_VERIFY|SLAB_CTOR_CONSTRUCTOR)) ==
 	    SLAB_CTOR_CONSTRUCTOR) {
@@ -398,10 +386,8 @@ static void afs_i_init_once(void *_vnode, struct kmem_cache *cachep,
 		afs_timer_init(&vnode->cb_timeout,
 			       &afs_vnode_cb_timed_out_ops);
 	}
+}
 
-} /* end afs_i_init_once() */
-
-/*****************************************************************************/
 /*
  * allocate an AFS inode struct from our slab cache
  */
@@ -409,8 +395,7 @@ static struct inode *afs_alloc_inode(struct super_block *sb)
 {
 	struct afs_vnode *vnode;
 
-	vnode = (struct afs_vnode *)
-		kmem_cache_alloc(afs_inode_cachep, GFP_KERNEL);
+	vnode = kmem_cache_alloc(afs_inode_cachep, GFP_KERNEL);
 	if (!vnode)
 		return NULL;
 
@@ -424,9 +409,8 @@ static struct inode *afs_alloc_inode(struct super_block *sb)
 	vnode->flags		= 0;
 
 	return &vnode->vfs_inode;
-} /* end afs_alloc_inode() */
+}
 
-/*****************************************************************************/
 /*
  * destroy an AFS inode struct
  */
@@ -435,7 +419,5 @@ static void afs_destroy_inode(struct inode *inode)
 	_enter("{%lu}", inode->i_ino);
 
 	kmem_cache_free(afs_inode_cachep, AFS_FS_I(inode));
-
 	atomic_dec(&afs_count_active_inodes);
-
-} /* end afs_destroy_inode() */
+}
diff --git a/fs/afs/super.h b/fs/afs/super.h
index 32de8cc..c95b48e 100644
--- a/fs/afs/super.h
+++ b/fs/afs/super.h
@@ -1,4 +1,4 @@
-/* super.h: AFS filesystem internal private data
+/* AFS filesystem internal private data
  *
  * Copyright (c) 2002 Red Hat, Inc. All rights reserved.
  *
@@ -14,21 +14,17 @@
  *
  */
 
-#ifndef _LINUX_AFS_SUPER_H
-#define _LINUX_AFS_SUPER_H
+#ifndef AFS_SUPER_H
+#define AFS_SUPER_H
 
 #include <linux/fs.h>
 #include "server.h"
 
-#ifdef __KERNEL__
-
-/*****************************************************************************/
 /*
  * AFS superblock private data
  * - there's one superblock per volume
  */
-struct afs_super_info
-{
+struct afs_super_info {
 	struct afs_volume	*volume;	/* volume record */
 	char			rwparent;	/* T if parent is R/W AFS volume */
 };
@@ -40,6 +36,4 @@ static inline struct afs_super_info *AFS_FS_S(struct super_block *sb)
 
 extern struct file_system_type afs_fs_type;
 
-#endif /* __KERNEL__ */
-
-#endif /* _LINUX_AFS_SUPER_H */
+#endif /* AFS_SUPER_H */
diff --git a/fs/afs/transport.h b/fs/afs/transport.h
index 7013ae6..f56be4b 100644
--- a/fs/afs/transport.h
+++ b/fs/afs/transport.h
@@ -1,4 +1,4 @@
-/* transport.h: AFS transport management
+/* AFS transport management
  *
  * Copyright (C) 2002 Red Hat, Inc. All Rights Reserved.
  * Written by David Howells (dhowells@redhat.com)
@@ -9,8 +9,8 @@
  * 2 of the License, or (at your option) any later version.
  */
 
-#ifndef _LINUX_AFS_TRANSPORT_H
-#define _LINUX_AFS_TRANSPORT_H
+#ifndef AFS_TRANSPORT_H
+#define AFS_TRANSPORT_H
 
 #include "types.h"
 #include <rxrpc/transport.h>
@@ -18,4 +18,4 @@
 /* the cache manager transport endpoint */
 extern struct rxrpc_transport *afs_transport;
 
-#endif /* _LINUX_AFS_TRANSPORT_H */
+#endif /* AFS_TRANSPORT_H */
diff --git a/fs/afs/types.h b/fs/afs/types.h
index b1a2367..db2b5dc 100644
--- a/fs/afs/types.h
+++ b/fs/afs/types.h
@@ -1,4 +1,4 @@
-/* types.h: AFS types
+/* AFS types
  *
  * Copyright (C) 2002 Red Hat, Inc. All Rights Reserved.
  * Written by David Howells (dhowells@redhat.com)
@@ -9,12 +9,10 @@
  * 2 of the License, or (at your option) any later version.
  */
 
-#ifndef _LINUX_AFS_TYPES_H
-#define _LINUX_AFS_TYPES_H
+#ifndef AFS_TYPES_H
+#define AFS_TYPES_H
 
-#ifdef __KERNEL__
 #include <rxrpc/types.h>
-#endif /* __KERNEL__ */
 
 typedef unsigned			afs_volid_t;
 typedef unsigned			afs_vnodeid_t;
@@ -33,23 +31,18 @@ typedef enum {
 	AFS_FTYPE_SYMLINK	= 3,
 } afs_file_type_t;
 
-#ifdef __KERNEL__
-
 struct afs_cell;
 struct afs_vnode;
 
-/*****************************************************************************/
 /*
  * AFS file identifier
  */
-struct afs_fid
-{
+struct afs_fid {
 	afs_volid_t	vid;		/* volume ID */
 	afs_vnodeid_t	vnode;		/* file index within volume */
 	unsigned	unique;		/* unique ID number (file index version) */
 };
 
-/*****************************************************************************/
 /*
  * AFS callback notification
  */
@@ -60,8 +53,7 @@ typedef enum {
 	AFSCM_CB_DROPPED	= 3,	/* CB promise cancelled by file server */
 } afs_callback_type_t;
 
-struct afs_callback
-{
+struct afs_callback {
 	struct afs_server	*server;	/* server that made the promise */
 	struct afs_fid		fid;		/* file identifier */
 	unsigned		version;	/* callback version */
@@ -71,12 +63,10 @@ struct afs_callback
 
 #define AFSCBMAX 50
 
-/*****************************************************************************/
 /*
  * AFS volume information
  */
-struct afs_volume_info
-{
+struct afs_volume_info {
 	afs_volid_t		vid;		/* volume ID */
 	afs_voltype_t		type;		/* type of this volume */
 	afs_volid_t		type_vids[5];	/* volume ID's for possible types for this vol */
@@ -88,12 +78,10 @@ struct afs_volume_info
 	} servers[8];
 };
 
-/*****************************************************************************/
 /*
  * AFS file status information
  */
-struct afs_file_status
-{
+struct afs_file_status {
 	unsigned		if_version;	/* interface version */
 #define AFS_FSTATUS_VERSION	1
 
@@ -111,15 +99,11 @@ struct afs_file_status
 	time_t			mtime_server;	/* last time server changed data */
 };
 
-/*****************************************************************************/
 /*
  * AFS volume synchronisation information
  */
-struct afs_volsync
-{
+struct afs_volsync {
 	time_t			creation;	/* volume creation time */
 };
 
-#endif /* __KERNEL__ */
-
-#endif /* _LINUX_AFS_TYPES_H */
+#endif /* AFS_TYPES_H */
diff --git a/fs/afs/vlclient.c b/fs/afs/vlclient.c
index 7b0e319..dac9faa 100644
--- a/fs/afs/vlclient.c
+++ b/fs/afs/vlclient.c
@@ -1,4 +1,4 @@
-/* vlclient.c: AFS Volume Location Service client
+/* AFS Volume Location Service client
  *
  * Copyright (C) 2002 Red Hat, Inc. All Rights Reserved.
  * Written by David Howells (dhowells@redhat.com)
@@ -30,7 +30,6 @@
 static void afs_rxvl_get_entry_by_id_attn(struct rxrpc_call *call);
 static void afs_rxvl_get_entry_by_id_error(struct rxrpc_call *call);
 
-/*****************************************************************************/
 /*
  * map afs VL abort codes to/from Linux error codes
  * - called with call->lock held
@@ -87,10 +86,9 @@ static void afs_rxvl_aemap(struct rxrpc_call *call)
 	default:
 		return;
 	}
-} /* end afs_rxvl_aemap() */
+}
 
 #if 0
-/*****************************************************************************/
 /*
  * probe a volume location server to see if it is still alive -- unused
  */
@@ -159,24 +157,22 @@ static int afs_rxvl_probe(struct afs_server *server, int alloc_flags)
 		BUG();
 	}
 
- abort:
+abort:
 	set_current_state(TASK_UNINTERRUPTIBLE);
 	rxrpc_call_abort(call, ret);
 	schedule();
 
- out_unwait:
+out_unwait:
 	set_current_state(TASK_RUNNING);
 	remove_wait_queue(&call->waitq, &myself);
 	rxrpc_put_call(call);
- out_put_conn:
+out_put_conn:
 	rxrpc_put_connection(conn);
- out:
+out:
 	return ret;
-
-} /* end afs_rxvl_probe() */
+}
 #endif
 
-/*****************************************************************************/
 /*
  * look up a volume location database entry by name
  */
@@ -294,24 +290,23 @@ int afs_rxvl_get_entry_by_name(struct afs_server *server,
 	entry->rtime = get_seconds();
 	ret = 0;
 
- out_unwait:
+out_unwait:
 	set_current_state(TASK_RUNNING);
 	remove_wait_queue(&call->waitq, &myself);
 	rxrpc_put_call(call);
- out_put_conn:
+out_put_conn:
 	rxrpc_put_connection(conn);
- out:
+out:
 	_leave(" = %d", ret);
 	return ret;
 
- abort:
+abort:
 	set_current_state(TASK_UNINTERRUPTIBLE);
 	rxrpc_call_abort(call, ret);
 	schedule();
 	goto out_unwait;
-} /* end afs_rxvl_get_entry_by_name() */
+}
 
-/*****************************************************************************/
 /*
  * look up a volume location database entry by ID
  */
@@ -434,24 +429,23 @@ int afs_rxvl_get_entry_by_id(struct afs_server *server,
 	entry->rtime = get_seconds();
 	ret = 0;
 
- out_unwait:
+out_unwait:
 	set_current_state(TASK_RUNNING);
 	remove_wait_queue(&call->waitq, &myself);
 	rxrpc_put_call(call);
- out_put_conn:
+out_put_conn:
 	rxrpc_put_connection(conn);
- out:
+out:
 	_leave(" = %d", ret);
 	return ret;
 
- abort:
+abort:
 	set_current_state(TASK_UNINTERRUPTIBLE);
 	rxrpc_call_abort(call, ret);
 	schedule();
 	goto out_unwait;
-} /* end afs_rxvl_get_entry_by_id() */
+}
 
-/*****************************************************************************/
 /*
  * look up a volume location database entry by ID asynchronously
  */
@@ -533,14 +527,12 @@ int afs_rxvl_get_entry_by_id_async(struct afs_async_op *op,
 		break;
 	}
 
- out:
+out:
 	rxrpc_put_call(call);
 	_leave(" = %d", ret);
 	return ret;
+}
 
-} /* end afs_rxvl_get_entry_by_id_async() */
-
-/*****************************************************************************/
 /*
  * attend to the asynchronous get VLDB entry by ID
  */
@@ -630,14 +622,13 @@ int afs_rxvl_get_entry_by_id_async2(struct afs_async_op *op,
 	_leave(" = -EAGAIN");
 	return -EAGAIN;
 
- done:
+done:
 	rxrpc_put_call(op->call);
 	op->call = NULL;
 	_leave(" = %d", ret);
 	return ret;
-} /* end afs_rxvl_get_entry_by_id_async2() */
+}
 
-/*****************************************************************************/
 /*
  * handle attention events on an async get-entry-by-ID op
  * - called from krxiod
@@ -674,10 +665,8 @@ static void afs_rxvl_get_entry_by_id_attn(struct rxrpc_call *call)
 	}
 
 	_leave("");
+}
 
-} /* end afs_rxvl_get_entry_by_id_attn() */
-
-/*****************************************************************************/
 /*
  * handle error events on an async get-entry-by-ID op
  * - called from krxiod
@@ -691,5 +680,4 @@ static void afs_rxvl_get_entry_by_id_error(struct rxrpc_call *call)
 	afs_kafsasyncd_attend_op(op);
 
 	_leave("");
-
-} /* end afs_rxvl_get_entry_by_id_error() */
+}
diff --git a/fs/afs/vlclient.h b/fs/afs/vlclient.h
index e3d6011..11dc10f 100644
--- a/fs/afs/vlclient.h
+++ b/fs/afs/vlclient.h
@@ -1,4 +1,4 @@
-/* vlclient.h: Volume Location Service client interface
+/* Volume Location Service client interface
  *
  * Copyright (C) 2002 Red Hat, Inc. All Rights Reserved.
  * Written by David Howells (dhowells@redhat.com)
@@ -9,8 +9,8 @@
  * 2 of the License, or (at your option) any later version.
  */
 
-#ifndef _LINUX_AFS_VLCLIENT_H
-#define _LINUX_AFS_VLCLIENT_H
+#ifndef AFS_VLCLIENT_H
+#define AFS_VLCLIENT_H
 
 #include "types.h"
 
@@ -68,26 +68,18 @@ struct afs_vldbentry {
 #define AFS_VLSF_RWVOL		0x0004	/* this server holds a R/W instance of the volume */
 #define AFS_VLSF_BACKVOL	0x0008	/* this server holds a backup instance of the volume */
 	} servers[8];
-
 };
 
-/* look up a volume location database entry by name */
-extern int afs_rxvl_get_entry_by_name(struct afs_server *server,
-				      const char *volname,
-				      unsigned volnamesz,
-				      struct afs_cache_vlocation *entry);
-
-/* look up a volume location database entry by ID */
-extern int afs_rxvl_get_entry_by_id(struct afs_server *server,
-				    afs_volid_t	volid,
-				    afs_voltype_t voltype,
-				    struct afs_cache_vlocation *entry);
+extern int afs_rxvl_get_entry_by_name(struct afs_server *, const char *,
+				      unsigned, struct afs_cache_vlocation *);
+extern int afs_rxvl_get_entry_by_id(struct afs_server *, afs_volid_t,
+				    afs_voltype_t,
+				    struct afs_cache_vlocation *);
 
-extern int afs_rxvl_get_entry_by_id_async(struct afs_async_op *op,
-					  afs_volid_t volid,
-					  afs_voltype_t voltype);
+extern int afs_rxvl_get_entry_by_id_async(struct afs_async_op *,
+					  afs_volid_t, afs_voltype_t);
 
-extern int afs_rxvl_get_entry_by_id_async2(struct afs_async_op *op,
-					   struct afs_cache_vlocation *entry);
+extern int afs_rxvl_get_entry_by_id_async2(struct afs_async_op *,
+					   struct afs_cache_vlocation *);
 
-#endif /* _LINUX_AFS_VLCLIENT_H */
+#endif /* AFS_VLCLIENT_H */
diff --git a/fs/afs/vlocation.c b/fs/afs/vlocation.c
index 782ee7c..e48728c 100644
--- a/fs/afs/vlocation.c
+++ b/fs/afs/vlocation.c
@@ -1,4 +1,4 @@
-/* vlocation.c: volume location management
+/* volume location management
  *
  * Copyright (C) 2002 Red Hat, Inc. All Rights Reserved.
  * Written by David Howells (dhowells@redhat.com)
@@ -73,7 +73,6 @@ struct cachefs_index_def afs_vlocation_cache_index_def = {
 };
 #endif
 
-/*****************************************************************************/
 /*
  * iterate through the VL servers in a cell until one of them admits knowing
  * about the volume in question
@@ -146,13 +145,11 @@ static int afs_vlocation_access_vl_by_name(struct afs_vlocation *vlocation,
 		cell->vl_curr_svix %= cell->vl_naddrs;
 	}
 
- out:
+out:
 	_leave(" = %d", ret);
 	return ret;
+}
 
-} /* end afs_vlocation_access_vl_by_name() */
-
-/*****************************************************************************/
 /*
  * iterate through the VL servers in a cell until one of them admits knowing
  * about the volume in question
@@ -225,13 +222,11 @@ static int afs_vlocation_access_vl_by_id(struct afs_vlocation *vlocation,
 		cell->vl_curr_svix %= cell->vl_naddrs;
 	}
 
- out:
+out:
 	_leave(" = %d", ret);
 	return ret;
+}
 
-} /* end afs_vlocation_access_vl_by_id() */
-
-/*****************************************************************************/
 /*
  * lookup volume location
  * - caller must have cell->vol_sem write-locked
@@ -321,7 +316,7 @@ int afs_vlocation_lookup(struct afs_cell *cell,
 
 	goto found_on_vlserver;
 
- found_in_graveyard:
+found_in_graveyard:
 	/* found in the graveyard - resurrect */
 	_debug("found in graveyard");
 	atomic_inc(&vlocation->usage);
@@ -331,16 +326,16 @@ int afs_vlocation_lookup(struct afs_cell *cell,
 	afs_kafstimod_del_timer(&vlocation->timeout);
 	goto active;
 
- found_in_memory:
+found_in_memory:
 	/* found in memory - check to see if it's active */
 	_debug("found in memory");
 	atomic_inc(&vlocation->usage);
 
- active:
+active:
 	active = 1;
 
 #ifdef AFS_CACHING_SUPPORT
- found_in_cache:
+found_in_cache:
 #endif
 	/* try to look up a cached volume in the cell VL databases by ID */
 	_debug("found in cache");
@@ -364,16 +359,13 @@ int afs_vlocation_lookup(struct afs_cell *cell,
 	if (vlocation->vldb.vidmask & AFS_VOL_VTM_RW) {
 		vid = vlocation->vldb.vid[0];
 		voltype = AFSVL_RWVOL;
-	}
-	else if (vlocation->vldb.vidmask & AFS_VOL_VTM_RO) {
+	} else if (vlocation->vldb.vidmask & AFS_VOL_VTM_RO) {
 		vid = vlocation->vldb.vid[1];
 		voltype = AFSVL_ROVOL;
-	}
-	else if (vlocation->vldb.vidmask & AFS_VOL_VTM_BAK) {
+	} else if (vlocation->vldb.vidmask & AFS_VOL_VTM_BAK) {
 		vid = vlocation->vldb.vid[2];
 		voltype = AFSVL_BACKVOL;
-	}
-	else {
+	} else {
 		BUG();
 		vid = 0;
 		voltype = 0;
@@ -400,7 +392,7 @@ int afs_vlocation_lookup(struct afs_cell *cell,
 		goto error;
 	}
 
- found_on_vlserver:
+found_on_vlserver:
 	_debug("Done VL Lookup: %*.*s %02x { %08x(%x) %08x(%x) %08x(%x) }",
 	       namesz, namesz, name,
 	       vldb.vidmask,
@@ -430,12 +422,11 @@ int afs_vlocation_lookup(struct afs_cell *cell,
 	_leave(" = 0 (%p)",vlocation);
 	return 0;
 
- error:
+error:
 	if (vlocation) {
 		if (active) {
 			__afs_put_vlocation(vlocation);
-		}
-		else {
+		} else {
 			list_del(&vlocation->link);
 #ifdef AFS_CACHING_SUPPORT
 			cachefs_relinquish_cookie(vlocation->cache, 0);
@@ -447,9 +438,8 @@ int afs_vlocation_lookup(struct afs_cell *cell,
 
 	_leave(" = %d", ret);
 	return ret;
-} /* end afs_vlocation_lookup() */
+}
 
-/*****************************************************************************/
 /*
  * finish using a volume location record
  * - caller must have cell->vol_sem write-locked
@@ -489,9 +479,8 @@ static void __afs_put_vlocation(struct afs_vlocation *vlocation)
 	spin_unlock(&cell->vl_gylock);
 
 	_leave(" [killed]");
-} /* end __afs_put_vlocation() */
+}
 
-/*****************************************************************************/
 /*
  * finish using a volume location record
  */
@@ -504,9 +493,8 @@ void afs_put_vlocation(struct afs_vlocation *vlocation)
 		__afs_put_vlocation(vlocation);
 		up_write(&cell->vl_sem);
 	}
-} /* end afs_put_vlocation() */
+}
 
-/*****************************************************************************/
 /*
  * timeout vlocation record
  * - removes from the cell's graveyard if the usage count is zero
@@ -543,9 +531,8 @@ void afs_vlocation_do_timeout(struct afs_vlocation *vlocation)
 	kfree(vlocation);
 
 	_leave(" [destroyed]");
-} /* end afs_vlocation_do_timeout() */
+}
 
-/*****************************************************************************/
 /*
  * send an update operation to the currently selected server
  */
@@ -564,16 +551,13 @@ static int afs_vlocation_update_begin(struct afs_vlocation *vlocation)
 	if (vlocation->vldb.vidmask & AFS_VOL_VTM_RW) {
 		vid = vlocation->vldb.vid[0];
 		voltype = AFSVL_RWVOL;
-	}
-	else if (vlocation->vldb.vidmask & AFS_VOL_VTM_RO) {
+	} else if (vlocation->vldb.vidmask & AFS_VOL_VTM_RO) {
 		vid = vlocation->vldb.vid[1];
 		voltype = AFSVL_ROVOL;
-	}
-	else if (vlocation->vldb.vidmask & AFS_VOL_VTM_BAK) {
+	} else if (vlocation->vldb.vidmask & AFS_VOL_VTM_BAK) {
 		vid = vlocation->vldb.vid[2];
 		voltype = AFSVL_BACKVOL;
-	}
-	else {
+	} else {
 		BUG();
 		vid = 0;
 		voltype = 0;
@@ -604,9 +588,8 @@ static int afs_vlocation_update_begin(struct afs_vlocation *vlocation)
 
 	_leave(" = %d", ret);
 	return ret;
-} /* end afs_vlocation_update_begin() */
+}
 
-/*****************************************************************************/
 /*
  * abandon updating a VL record
  * - does not restart the update timer
@@ -634,9 +617,8 @@ static void afs_vlocation_update_abandon(struct afs_vlocation *vlocation,
 	spin_unlock(&afs_vlocation_update_lock);
 
 	_leave("");
-} /* end afs_vlocation_update_abandon() */
+}
 
-/*****************************************************************************/
 /*
  * handle periodic update timeouts and busy retry timeouts
  * - called from kafstimod
@@ -663,8 +645,7 @@ static void afs_vlocation_update_timer(struct afs_timer *timer)
 		if (afs_vlocation_update) {
 			list_add(&vlocation->upd_op.link,
 				 &afs_vlocation_update_pendq);
-		}
-		else {
+		} else {
 			afs_get_vlocation(vlocation);
 			afs_vlocation_update = vlocation;
 			vlocation->upd_state = AFS_VLUPD_INPROGRESS;
@@ -706,16 +687,13 @@ static void afs_vlocation_update_timer(struct afs_timer *timer)
 	_leave("");
 	return;
 
- out_unlock2:
+out_unlock2:
 	spin_unlock(&afs_vlocation_update_lock);
- out_unlock1:
+out_unlock1:
 	spin_unlock(&vlocation->cell->vl_gylock);
 	_leave("");
-	return;
-
-} /* end afs_vlocation_update_timer() */
+}
 
-/*****************************************************************************/
 /*
  * attend to an update operation upon which an event happened
  * - called in kafsasyncd context
@@ -818,7 +796,7 @@ static void afs_vlocation_update_attend(struct afs_async_op *op)
 	}
 
 	/* try contacting the next server */
- try_next:
+try_next:
 	vlocation->upd_busy_cnt = 0;
 
 	/* discard the server record */
@@ -856,15 +834,13 @@ static void afs_vlocation_update_attend(struct afs_async_op *op)
 	}
 
 	/* abandon the update */
- abandon:
+abandon:
 	afs_vlocation_update_abandon(vlocation, AFS_VLUPD_SLEEP, ret);
 	afs_kafstimod_add_timer(&vlocation->upd_timer, HZ * 10);
 	afs_put_vlocation(vlocation);
 	_leave(" [abandoned]");
+}
 
-} /* end afs_vlocation_update_attend() */
-
-/*****************************************************************************/
 /*
  * deal with an update operation being discarded
  * - called in kafsasyncd context when it's dying due to rmmod
@@ -883,9 +859,8 @@ static void afs_vlocation_update_discard(struct afs_async_op *op)
 	afs_put_vlocation(vlocation);
 
 	_leave("");
-} /* end afs_vlocation_update_discard() */
+}
 
-/*****************************************************************************/
 /*
  * match a VLDB record stored in the cache
  * - may also load target from entry
@@ -908,9 +883,7 @@ static cachefs_match_val_t afs_vlocation_cache_match(void *target,
 			vlocation->valid = 1;
 			_leave(" = SUCCESS [c->m]");
 			return CACHEFS_MATCH_SUCCESS;
-		}
-		/* need to update cache if cached info differs */
-		else if (memcmp(&vlocation->vldb, vldb, sizeof(*vldb)) != 0) {
+		} else if (memcmp(&vlocation->vldb, vldb, sizeof(*vldb)) != 0) {
 			/* delete if VIDs for this name differ */
 			if (memcmp(&vlocation->vldb.vid,
 				   &vldb->vid,
@@ -921,8 +894,7 @@ static cachefs_match_val_t afs_vlocation_cache_match(void *target,
 
 			_leave(" = UPDATE");
 			return CACHEFS_MATCH_SUCCESS_UPDATE;
-		}
-		else {
+		} else {
 			_leave(" = SUCCESS");
 			return CACHEFS_MATCH_SUCCESS;
 		}
@@ -930,10 +902,9 @@ static cachefs_match_val_t afs_vlocation_cache_match(void *target,
 
 	_leave(" = FAILED");
 	return CACHEFS_MATCH_FAILED;
-} /* end afs_vlocation_cache_match() */
+}
 #endif
 
-/*****************************************************************************/
 /*
  * update a VLDB record stored in the cache
  */
@@ -946,6 +917,5 @@ static void afs_vlocation_cache_update(void *source, void *entry)
 	_enter("");
 
 	*vldb = vlocation->vldb;
-
-} /* end afs_vlocation_cache_update() */
+}
 #endif
diff --git a/fs/afs/vnode.c b/fs/afs/vnode.c
index cf62da5..4ab1ed7 100644
--- a/fs/afs/vnode.c
+++ b/fs/afs/vnode.c
@@ -1,4 +1,4 @@
-/* vnode.c: AFS vnode management
+/* AFS vnode management
  *
  * Copyright (C) 2002 Red Hat, Inc. All Rights Reserved.
  * Written by David Howells (dhowells@redhat.com)
@@ -43,7 +43,6 @@ struct cachefs_index_def afs_vnode_cache_index_def = {
 };
 #endif
 
-/*****************************************************************************/
 /*
  * handle a callback timing out
  * TODO: retain a ref to vnode struct for an outstanding callback timeout
@@ -78,9 +77,8 @@ static void afs_vnode_cb_timed_out(struct afs_timer *timer)
 	afs_put_server(oldserver);
 
 	_leave("");
-} /* end afs_vnode_cb_timed_out() */
+}
 
-/*****************************************************************************/
 /*
  * finish off updating the recorded status of a file
  * - starts callback expiry timer
@@ -105,7 +103,7 @@ static void afs_vnode_finalise_status_update(struct afs_vnode *vnode,
 
 		spin_lock(&afs_cb_hash_lock);
 		list_move_tail(&vnode->cb_hash_link,
-			      &afs_cb_hash(server, &vnode->fid));
+			       &afs_cb_hash(server, &vnode->fid));
 		spin_unlock(&afs_cb_hash_lock);
 
 		/* swap ref to old callback server with that for new callback
@@ -122,13 +120,11 @@ static void afs_vnode_finalise_status_update(struct afs_vnode *vnode,
 			spin_lock(&server->cb_lock);
 			list_add_tail(&vnode->cb_link, &server->cb_promises);
 			spin_unlock(&server->cb_lock);
-		}
-		else {
+		} else {
 			/* same server */
 			oldserver = NULL;
 		}
-	}
-	else if (ret == -ENOENT) {
+	} else if (ret == -ENOENT) {
 		/* the file was deleted - clear the callback timeout */
 		oldserver = xchg(&vnode->cb_server, NULL);
 		afs_kafstimod_del_timer(&vnode->cb_timeout);
@@ -146,10 +142,8 @@ static void afs_vnode_finalise_status_update(struct afs_vnode *vnode,
 	afs_put_server(oldserver);
 
 	_leave("");
+}
 
-} /* end afs_vnode_finalise_status_update() */
-
-/*****************************************************************************/
 /*
  * fetch file status from the volume
  * - don't issue a fetch if:
@@ -222,7 +216,7 @@ int afs_vnode_fetch_status(struct afs_vnode *vnode)
 		return vnode->flags & AFS_VNODE_DELETED ? -ENOENT : 0;
 	}
 
- get_anyway:
+get_anyway:
 	/* okay... we're going to have to initiate the op */
 	vnode->update_cnt++;
 
@@ -247,9 +241,8 @@ int afs_vnode_fetch_status(struct afs_vnode *vnode)
 
 	_leave(" = %d", ret);
 	return ret;
-} /* end afs_vnode_fetch_status() */
+}
 
-/*****************************************************************************/
 /*
  * fetch file data from the volume
  * - TODO implement caching and server failover
@@ -290,10 +283,8 @@ int afs_vnode_fetch_data(struct afs_vnode *vnode,
 
 	_leave(" = %d", ret);
 	return ret;
+}
 
-} /* end afs_vnode_fetch_data() */
-
-/*****************************************************************************/
 /*
  * break any outstanding callback on a vnode
  * - only relevent to server that issued it
@@ -337,9 +328,8 @@ int afs_vnode_give_up_callback(struct afs_vnode *vnode)
 
 	_leave(" = %d", ret);
 	return ret;
-} /* end afs_vnode_give_up_callback() */
+}
 
-/*****************************************************************************/
 /*
  * match a vnode record stored in the cache
  */
@@ -371,10 +361,9 @@ static cachefs_match_val_t afs_vnode_cache_match(void *target,
 
 	_leave(" = SUCCESS");
 	return CACHEFS_MATCH_SUCCESS;
-} /* end afs_vnode_cache_match() */
+}
 #endif
 
-/*****************************************************************************/
 /*
  * update a vnode record stored in the cache
  */
@@ -389,6 +378,5 @@ static void afs_vnode_cache_update(void *source, void *entry)
 	cvnode->vnode_id	= vnode->fid.vnode;
 	cvnode->vnode_unique	= vnode->fid.unique;
 	cvnode->data_version	= vnode->status.version;
-
-} /* end afs_vnode_cache_update() */
+}
 #endif
diff --git a/fs/afs/vnode.h b/fs/afs/vnode.h
index b86a971..7f6d05b 100644
--- a/fs/afs/vnode.h
+++ b/fs/afs/vnode.h
@@ -1,4 +1,4 @@
-/* vnode.h: AFS vnode record
+/* AFS vnode record
  *
  * Copyright (C) 2002 Red Hat, Inc. All Rights Reserved.
  * Written by David Howells (dhowells@redhat.com)
@@ -9,24 +9,22 @@
  * 2 of the License, or (at your option) any later version.
  */
 
-#ifndef _LINUX_AFS_VNODE_H
-#define _LINUX_AFS_VNODE_H
+#ifndef AFS_VNODE_H
+#define AFS_VNODE_H
 
 #include <linux/fs.h>
 #include "server.h"
 #include "kafstimod.h"
 #include "cache.h"
 
-#ifdef __KERNEL__
-
 struct afs_rxfs_fetch_descriptor;
 
-/*****************************************************************************/
+extern struct afs_timer_ops afs_vnode_cb_timed_out_ops;
+
 /*
  * vnode catalogue entry
  */
-struct afs_cache_vnode
-{
+struct afs_cache_vnode {
 	afs_vnodeid_t		vnode_id;	/* vnode ID */
 	unsigned		vnode_unique;	/* vnode ID uniquifier */
 	afs_dataversion_t	data_version;	/* data version */
@@ -36,12 +34,10 @@ struct afs_cache_vnode
 extern struct cachefs_index_def afs_vnode_cache_index_def;
 #endif
 
-/*****************************************************************************/
 /*
  * AFS inode private data
  */
-struct afs_vnode
-{
+struct afs_vnode {
 	struct inode		vfs_inode;	/* the VFS's inode record */
 
 	struct afs_volume	*volume;	/* volume on which vnode resides */
@@ -72,7 +68,7 @@ struct afs_vnode
 
 static inline struct afs_vnode *AFS_FS_I(struct inode *inode)
 {
-	return container_of(inode,struct afs_vnode,vfs_inode);
+	return container_of(inode, struct afs_vnode, vfs_inode);
 }
 
 static inline struct inode *AFS_VNODE_TO_I(struct afs_vnode *vnode)
@@ -80,15 +76,9 @@ static inline struct inode *AFS_VNODE_TO_I(struct afs_vnode *vnode)
 	return &vnode->vfs_inode;
 }
 
-extern int afs_vnode_fetch_status(struct afs_vnode *vnode);
-
-extern int afs_vnode_fetch_data(struct afs_vnode *vnode,
-				struct afs_rxfs_fetch_descriptor *desc);
-
-extern int afs_vnode_give_up_callback(struct afs_vnode *vnode);
-
-extern struct afs_timer_ops afs_vnode_cb_timed_out_ops;
-
-#endif /* __KERNEL__ */
+extern int afs_vnode_fetch_status(struct afs_vnode *);
+extern int afs_vnode_fetch_data(struct afs_vnode *,
+				struct afs_rxfs_fetch_descriptor *);
+extern int afs_vnode_give_up_callback(struct afs_vnode *);
 
-#endif /* _LINUX_AFS_VNODE_H */
+#endif /* AFS_VNODE_H */
diff --git a/fs/afs/volume.c b/fs/afs/volume.c
index 768c6db..c82e1bb 100644
--- a/fs/afs/volume.c
+++ b/fs/afs/volume.c
@@ -1,4 +1,4 @@
-/* volume.c: AFS volume management
+/* AFS volume management
  *
  * Copyright (C) 2002 Red Hat, Inc. All Rights Reserved.
  * Written by David Howells (dhowells@redhat.com)
@@ -43,7 +43,6 @@ struct cachefs_index_def afs_volume_cache_index_def = {
 };
 #endif
 
-/*****************************************************************************/
 /*
  * lookup a volume by name
  * - this can be one of the following:
@@ -97,14 +96,11 @@ int afs_volume_lookup(const char *name, struct afs_cell *cell, int rwpath,
 		if (strcmp(suffix, ".readonly") == 0) {
 			type = AFSVL_ROVOL;
 			force = 1;
-		}
-		else if (strcmp(suffix, ".backup") == 0) {
+		} else if (strcmp(suffix, ".backup") == 0) {
 			type = AFSVL_BACKVOL;
 			force = 1;
-		}
-		else if (suffix[1] == 0) {
-		}
-		else {
+		} else if (suffix[1] == 0) {
+		} else {
 			suffix = NULL;
 		}
 	}
@@ -116,8 +112,7 @@ int afs_volume_lookup(const char *name, struct afs_cell *cell, int rwpath,
 		cellname = name;
 		cellnamesz = volname - name;
 		volname++;
-	}
-	else {
+	} else {
 		volname = name;
 		cellname = NULL;
 		cellnamesz = 0;
@@ -139,8 +134,7 @@ int afs_volume_lookup(const char *name, struct afs_cell *cell, int rwpath,
 			       cellname ?: "");
 			goto error;
 		}
-	}
-	else {
+	} else {
 		afs_get_cell(cell);
 	}
 
@@ -161,14 +155,11 @@ int afs_volume_lookup(const char *name, struct afs_cell *cell, int rwpath,
 	if (force) {
 		if (!(srvtmask & (1 << type)))
 			goto error;
-	}
-	else if (srvtmask & AFS_VOL_VTM_RO) {
+	} else if (srvtmask & AFS_VOL_VTM_RO) {
 		type = AFSVL_ROVOL;
-	}
-	else if (srvtmask & AFS_VOL_VTM_RW) {
+	} else if (srvtmask & AFS_VOL_VTM_RW) {
 		type = AFSVL_RWVOL;
-	}
-	else {
+	} else {
 		goto error;
 	}
 
@@ -225,23 +216,23 @@ int afs_volume_lookup(const char *name, struct afs_cell *cell, int rwpath,
 
 	vlocation->vols[type] = volume;
 
- success:
+success:
 	_debug("kAFS selected %s volume %08x",
 	       afs_voltypes[volume->type], volume->vid);
 	*_volume = volume;
 	ret = 0;
 
 	/* clean up */
- error_up:
+error_up:
 	up_write(&cell->vl_sem);
- error:
+error:
 	afs_put_vlocation(vlocation);
 	afs_put_cell(cell);
 
 	_leave(" = %d (%p)", ret, volume);
 	return ret;
 
- error_discard:
+error_discard:
 	up_write(&cell->vl_sem);
 
 	for (loop = volume->nservers - 1; loop >= 0; loop--)
@@ -249,9 +240,8 @@ int afs_volume_lookup(const char *name, struct afs_cell *cell, int rwpath,
 
 	kfree(volume);
 	goto error;
-} /* end afs_volume_lookup() */
+}
 
-/*****************************************************************************/
 /*
  * destroy a volume record
  */
@@ -296,9 +286,8 @@ void afs_put_volume(struct afs_volume *volume)
 	kfree(volume);
 
 	_leave(" [destroyed]");
-} /* end afs_put_volume() */
+}
 
-/*****************************************************************************/
 /*
  * pick a server to use to try accessing this volume
  * - returns with an elevated usage count on the server chosen
@@ -373,9 +362,8 @@ int afs_volume_pick_fileserver(struct afs_volume *volume,
 	up_read(&volume->server_sem);
 	_leave(" = %d", ret);
 	return ret;
-} /* end afs_volume_pick_fileserver() */
+}
 
-/*****************************************************************************/
 /*
  * release a server after use
  * - releases the ref on the server struct that was acquired by picking
@@ -469,16 +457,14 @@ int afs_volume_release_fileserver(struct afs_volume *volume,
 	return 1;
 
 	/* tell the caller to loop around and try the next server */
- try_next_server_upw:
+try_next_server_upw:
 	up_write(&volume->server_sem);
- try_next_server:
+try_next_server:
 	afs_put_server(server);
 	_leave(" [try next server]");
 	return 0;
+}
 
-} /* end afs_volume_release_fileserver() */
-
-/*****************************************************************************/
 /*
  * match a volume hash record stored in the cache
  */
@@ -498,10 +484,9 @@ static cachefs_match_val_t afs_volume_cache_match(void *target,
 
 	_leave(" = FAILED");
 	return CACHEFS_MATCH_FAILED;
-} /* end afs_volume_cache_match() */
+}
 #endif
 
-/*****************************************************************************/
 /*
  * update a volume hash record stored in the cache
  */
@@ -514,6 +499,5 @@ static void afs_volume_cache_update(void *source, void *entry)
 	_enter("");
 
 	vhash->vtype = volume->type;
-
-} /* end afs_volume_cache_update() */
+}
 #endif
diff --git a/fs/afs/volume.h b/fs/afs/volume.h
index bfdcf19..a605bea 100644
--- a/fs/afs/volume.h
+++ b/fs/afs/volume.h
@@ -1,4 +1,4 @@
-/* volume.h: AFS volume management
+/* AFS volume management
  *
  * Copyright (C) 2002 Red Hat, Inc. All Rights Reserved.
  * Written by David Howells (dhowells@redhat.com)
@@ -9,8 +9,8 @@
  * 2 of the License, or (at your option) any later version.
  */
 
-#ifndef _LINUX_AFS_VOLUME_H
-#define _LINUX_AFS_VOLUME_H
+#ifndef AFS_VOLUME_H
+#define AFS_VOLUME_H
 
 #include "types.h"
 #include "fsclient.h"
@@ -23,15 +23,12 @@ typedef enum {
 	AFS_VLUPD_PENDING,		/* on pending queue */
 	AFS_VLUPD_INPROGRESS,		/* op in progress */
 	AFS_VLUPD_BUSYSLEEP,		/* sleeping because server returned EBUSY */
-	
 } __attribute__((packed)) afs_vlocation_upd_t;
 
-/*****************************************************************************/
 /*
  * entry in the cached volume location catalogue
  */
-struct afs_cache_vlocation
-{
+struct afs_cache_vlocation {
 	uint8_t			name[64];	/* volume name (lowercase, padded with NULs) */
 	uint8_t			nservers;	/* number of entries used in servers[] */
 	uint8_t			vidmask;	/* voltype mask for vid[] */
@@ -49,12 +46,10 @@ struct afs_cache_vlocation
 extern struct cachefs_index_def afs_vlocation_cache_index_def;
 #endif
 
-/*****************************************************************************/
 /*
  * volume -> vnode hash table entry
  */
-struct afs_cache_vhash
-{
+struct afs_cache_vhash {
 	afs_voltype_t		vtype;		/* which volume variation */
 	uint8_t			hash_bucket;	/* which hash bucket this represents */
 } __attribute__((packed));
@@ -63,12 +58,10 @@ struct afs_cache_vhash
 extern struct cachefs_index_def afs_volume_cache_index_def;
 #endif
 
-/*****************************************************************************/
 /*
  * AFS volume location record
  */
-struct afs_vlocation
-{
+struct afs_vlocation {
 	atomic_t		usage;
 	struct list_head	link;		/* link in cell volume location list */
 	struct afs_timer	timeout;	/* decaching timer */
@@ -90,22 +83,18 @@ struct afs_vlocation
 	unsigned short		valid;		/* T if valid */
 };
 
-extern int afs_vlocation_lookup(struct afs_cell *cell,
-				const char *name,
-				unsigned namesz,
-				struct afs_vlocation **_vlocation);
+extern int afs_vlocation_lookup(struct afs_cell *, const char *, unsigned,
+				struct afs_vlocation **);
 
 #define afs_get_vlocation(V) do { atomic_inc(&(V)->usage); } while(0)
 
-extern void afs_put_vlocation(struct afs_vlocation *vlocation);
-extern void afs_vlocation_do_timeout(struct afs_vlocation *vlocation);
+extern void afs_put_vlocation(struct afs_vlocation *);
+extern void afs_vlocation_do_timeout(struct afs_vlocation *);
 
-/*****************************************************************************/
 /*
  * AFS volume access record
  */
-struct afs_volume
-{
+struct afs_volume {
 	atomic_t		usage;
 	struct afs_cell		*cell;		/* cell to which belongs (unrefd ptr) */
 	struct afs_vlocation	*vlocation;	/* volume location */
@@ -121,20 +110,17 @@ struct afs_volume
 	struct rw_semaphore	server_sem;	/* lock for accessing current server */
 };
 
-extern int afs_volume_lookup(const char *name,
-			     struct afs_cell *cell,
-			     int rwpath,
-			     struct afs_volume **_volume);
+extern int afs_volume_lookup(const char *, struct afs_cell *, int,
+			     struct afs_volume **);
 
 #define afs_get_volume(V) do { atomic_inc(&(V)->usage); } while(0)
 
-extern void afs_put_volume(struct afs_volume *volume);
+extern void afs_put_volume(struct afs_volume *);
 
-extern int afs_volume_pick_fileserver(struct afs_volume *volume,
-				      struct afs_server **_server);
+extern int afs_volume_pick_fileserver(struct afs_volume *,
+				      struct afs_server **);
 
-extern int afs_volume_release_fileserver(struct afs_volume *volume,
-					 struct afs_server *server,
-					 int result);
+extern int afs_volume_release_fileserver(struct afs_volume *,
+					 struct afs_server *, int);
 
-#endif /* _LINUX_AFS_VOLUME_H */
+#endif /* AFS_VOLUME_H */

